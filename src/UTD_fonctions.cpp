#include "xlife++-libs.h"
using namespace xlifepp;
using namespace std;

//=================================================
// stuff for UTD approximation
//=================================================
// curvilinear abcissa for P on a circle
Real curvabc(const Point& P)
{
    Real t=atan2(P[1],P[0]); // argument in [-pi,pi]
    if(t<0) t+=2*pi_;        // argument in [0,2pi]
    return norm(P)*t;
}

/*build terminators and related data
  in
   U, gradU : incident field and its gradient on Gamma
   ns : outwards normal vectors on dofs (see xlifepp::interpolatedNormals function)
  out
   terminators : vector of cuvilinear abcissa of terminateurs (at least 2)
   sl : a map that relates curvilinear abcissa of dofs to shadow/light index (-1/+1)
   vt : value of incident field at terminators (as many as terminators)
*/
Reals buildTerminators(const TermVector& U, const TermVector& gradU, Real k,
                       const vector<Vector<real_t> >& ns, map<Real, int>& sl, Vector<Complex>& vt)
{
  Reals terminateurs;
  sl.clear();
  Space& V = *U.unknown()->space();
  TermVector D =(gradU/U).toImag()/k;
  for(auto i=0; i<ns.size();i++)
  {
      Real ai = curvabc(V.dof(i+1).coords());
      Real dni=dot(ns[i],D.getValue(i+1).asRealVector());
      if(dni > -theTolerance) sl[ai]=-1; else sl[ai]=1;
  }
  //travel map to locate sign change
  std::map<Real,int>::iterator itm=sl.begin();
  int status = itm->second; itm++;
  while (itm!=sl.end())
  {
    if(itm->second!=status)
    {
      terminateurs.push_back(status*itm->first);
      status=itm->second;
    }
    itm++;
  }
  // check last and first
  itm=sl.begin();
  if(itm->second!=status) terminateurs.push_back(status*itm->first);
  // fill in vt
  vt.resize(terminateurs.size());
  for(auto i=0; i<ns.size();i++)
  {
      Real ai = curvabc(V.dof(i+1).coords());
      for(Number j=0;j<terminateurs.size();j++)
        if(abs(terminateurs[j])==ai) vt[j]=U.getValue(i+1).asComplex();
  }
  return terminateurs;
}

/* solve the Gamma (circle) diffraction problem using UTD approximations
  in
   U, gradU : incident field and its gradient on Gamma
   ns : outwards normal vectors on dofs (see xlifepp::interpolatedNormals function)
   k : wavenumber
   R : Gamma radius
   fock : Fock object
  out
   U is modified and contains the new diffracted current on Gamma
*/
void UTD(TermVector& U, const TermVector& gradU, const vector<Vector<real_t> >& ns, Real k, Real R, const Fock& fock)
{
    Real q=pow(k/(2*R*R),1./3.);
    Complex xi1=-exp(-2*i_*pi_/3)*1.0187929;
    Complex c=pow(2,2./3)*i_*sqrt(pi_)/(xi1*w1_Ai(xi1));
    Real sbl=-2.4, sbs=1, sbr=q*pi_*R;
    std::map<Real, int> sl;  // shadow/light map  curv. abc -> +/- 1 (-1 shadow zone)
    Vector<Complex> vt;      // incident current on terminateurs
    Reals terminateurs = buildTerminators(U,gradU,k,ns,sl,vt);
    Space& V = *U.unknown()->space();
    //loop on dofs
    #pragma omp for
    for(Number i=0;i<U.nbDofs();i++)
    {
        Complex v=0, vi=U.getValue(i+1).asComplex();
        Real ai = curvabc(V.dof(i+1).coords());
        bool shadow = sl[ai]==-1;
        Number status=0;
        for(Number j=0;j<terminateurs.size();j++)
        {
            Real s = ai-abs(terminateurs[j]);
            if(terminateurs[j]<0) s*=-1;
            Real sb=q*s;
            if(!shadow && sb<sbl && status==0) {v=2*vi; status=1;}
            if(sb >= sbl && sb <= sbs) // Fock prioritaire
            {
               if(shadow) v=exp(i_*k*s)*conj(fock(sb))*vt[j];
               else v=exp(i_*k*s*s*s/(6*R*R))*conj(fock(sb))*vi;
               status=2;
            }
        }
        for(Number j=0;j<terminateurs.size();j++)  // contribution rampant
        {
            Real s = ai-abs(terminateurs[j]);
            if(terminateurs[j]<0) s*=-1;
            Real sb=q*s;
            if(sb>sbs && sb<sbr) v+=c*exp(i_*(k*s+xi1*sb))*vt[j];
        }
        U.setValue(i+1,v);
    }
}
