#include "xlife++.h"
using namespace xlifepp;
using namespace std;

// incident function
Complex uinc(const Point& M, Parameters& pa = defaultParameters)
{
  Real k=pa("k");Point d=pa("dinc");
  return exp(i_*(k*dot(M,d)));
}

Vector<Complex> grad_uinc(const Point& M, Parameters& pa = defaultParameters)
{
  Real k=pa("k");Point d=pa("dinc");
  return i_*k*exp(i_*(k*dot(M,d)))*Vector<Complex>(d);
}

// tools for Kirchoff approximation
real_t shadowColoringRule(const GeomElement& gelt,
                          const vector<Vector<real_t> >& val)
{ GeomMapData *gmap=gelt.meshElement()->geomMapData_p;
  if(gmap==0)  gmap = new GeomMapData(gelt.meshElement());
  if(gmap->normalVector.size()==0) gmap->computeOrientedNormal();
  real_t res = 0.;
  for(number_t i=0; i<val.size() && res==0; i++)
    {if(dot(val[i],gmap->normalVector)>-theTolerance)
       res+=-1.;
    }
  return res;}

void restrictToLightZone(TermVector& ui)
{
  Space& V = *ui.unknown()->space();
  for(Number j=0; j<V.nbOfElements(); j++) // loop on element
  {
    const Element* elt=V.element_p(j);
    if(elt->geomElt_p->color!=0)
    {
      const std::vector<number_t>& dofNum=elt->dofNumbers;
      std::vector<number_t>::const_iterator itn = dofNum.begin();
      for(; itn!=dofNum.end(); ++itn)
          ui.setValue(*itn,0.);
    }
  }
}

// =================================
//           main program
// =================================
int main(int argc, char** argv)
{
  init(argc, argv, _lang=en);   // mandatory initialization of xlifepp
  verboseLevel(1);

  Real k=20.;    // wave number
  Real theta=0;  // incidence angle

  //mesh
  Real r1=1., r2=0.25, alpha=2;  // alpha > 1
  Point c1(0.,0.), c2(-1.5,0.5); // center of obstacles
  Real a=min(c1[0]-r1,c2[0]-r2), b=max(c1[0]+r1,c2[0]+r2);
  Real c=min(c1[1]-r1,c2[1]-r2), d=max(c1[1]+r1,c2[1]+r2);
  Real rext=alpha*max((b-a)/2,(d-c)/2);  // radius of surrounded domain
  Real hsize=2*pi_/k/10.;  // 10 pts by wavelenght
  Disk d1(_center=c1, _radius=r1, _hsteps=hsize, _domain_name="Obs1", _side_names="Gamma1");
  Disk d2(_center=c2, _radius=r2, _hsteps=hsize, _domain_name="Obs2", _side_names="Gamma2");
  Disk ext(_center=Point((a+b)/2,(c+d)/2),_radius=rext,_hsteps=2*hsize, _domain_name="Omega", _side_names="Sigma");
  Mesh m(ext-d1-d2,_triangle,1);
  theCout << "Mesh size = " << hsize <<" Number of Triangles = " << m.nbOfElements() << eol;

  Domain omega = m.domain("Omega"), sigma=m.domain("Sigma");
  Domain gamma1 = m.domain("Gamma1"),gamma2 = m.domain("Gamma2");
  gamma1.setNormalOrientation(_towardsInfinite);
  gamma2.setNormalOrientation(_towardsInfinite);
  Domain gamma=merge(gamma1,gamma2,"Gamma");  // pour full BEM
  gamma.setNormalOrientation(_towardsInfinite);
  
  //defining parameter and kernel
  Parameters pars;
  pars << Parameter(k,"k")<<Parameter(Point(cos(theta),sin(theta)),"dinc");
  Kernel G=Helmholtz2dKernel(pars);
  Function fuinc(uinc,pars);
  Function ginc(grad_uinc,pars);
  IntegrationMethods IMie(Duffy,15,0.,_defaultRule,12,1.,_defaultRule,10,2.,_defaultRule,8);// integration methods for IE
  IntegrationMethods IMir(LenoirSalles2dIR(),_singularPart,theRealMax,
                          QuadratureIM(_GaussLegendreRule,10),_regularPart,theRealMax);     //integration methods for singular IR
  IntegrationMethods IMir2(_GaussLegendreRule,10);                                          //integration methods for regular IR


  // =================================
  //             full BEM
  // =================================


  Space H(_domain=gamma, _interpolation=P1, _name="H", _notOptimizeNumbering);
  Unknown p(H, _name="p"); TestFunction q(p, _name="q");
  
  TermVector Uinc(p, gamma,fuinc,"Uinc");

  BilinearForm mlf= intg(gamma, p*q);
  BilinearForm blf= 0.5*intg(gamma, p*q)-intg(gamma, gamma, p*ndotgrad_y(G)*q,IMie);

  TermMatrix K(blf,"K"), M(mlf,"M");
  TermVector P = directSolve(K,M*Uinc);

  Space Vrep(_domain=omega, _interpolation=P1, _name="Vrep", _notOptimizeNumbering);
  Unknown ur(Vrep, _name="ur");

  TermVector Uext = integralRepresentation(ur, omega, intg(gamma, ndotgrad_y(G)*P, IMir));

  saveToFile("Uinc", Uinc, vtu); // Incident field
  saveToFile("Uext_full_BEM", Uext, vtu); // scattered field in exterior domain
  TermVector Uext_t = Uext + TermVector(ur,omega,fuinc);
  saveToFile("Uext_t_full_BEM", Uext_t, vtu); // Total field in exterior domain



  // =================================
  //        it�ratif BEM-BEM
  // =================================

  // =================================
  //      it�ratif Kirchoff-BEM
  // =================================

  // =================================
  //      it�ratif UTD-BEM
  // =================================

  theCout << "Program finished" << eol;
  return 0;
}

