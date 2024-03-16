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

  Real k=50.;    // wave number
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

/*
  Space H(_domain=gamma, _interpolation=P1, _name="H", _notOptimizeNumbering);
  Unknown p(H, _name="p"); TestFunction q(p, _name="q");
  
  TermVector Uinc(p, gamma,fuinc,"Uinc");

  BilinearForm mlf= intg(gamma, p*q);
  BilinearForm blf= 0.5*intg(gamma, p*q)-intg(gamma, gamma, p*ndotgrad_y(G)*q,IMie);

  TermMatrix K(blf,"K"), M(mlf,"M");
  TermVector P = directSolve(K,M*Uinc);

  Space Vrep(_domain=omega, _interpolation=P1, _name="Vrep", _notOptimizeNumbering);
  Unknown ur(Vrep, _name="ur");

  TermVector Ud = integralRepresentation(ur, omega, intg(gamma, ndotgrad_y(G)*P, IMir));

  saveToFile("Ud_full_BEM", Ud, vtu); // scattered field in exterior domain
  TermVector Ut = Ud + TermVector(ur,omega,fuinc);
  saveToFile("Ut_full_BEM", Ut, vtu); // Total field in exterior domain
*/

  // =================================
  //        it�ratif BEM-BEM
  // =================================


  Space H_gamma1(_domain=gamma1, _interpolation=P1, _name="H_gamma1", _notOptimizeNumbering);
  Space H_gamma2(_domain=gamma2, _interpolation=P1, _name="H_gamma2", _notOptimizeNumbering);
  
  Unknown p_1(H_gamma1, _name="p_1"); TestFunction q_1(p_1, _name="q_1");
  Unknown p_2(H_gamma2, _name="p_2"); TestFunction q_2(p_2, _name="q_2");

  int n =10;

  TermVector U_1(p_1, gamma1,fuinc,"U_1");
  TermVector U_2(p_2, gamma2,fuinc,"U_2");

  TermVector P_1_sum(p_1, gamma1,0.,"P_1_sum");
  TermVector P_2_sum(p_2, gamma2,0.,"P_2_sum");

  P_1_sum=P_1_sum*0;
  P_2_sum=P_2_sum*0;

  BilinearForm mlf_1,blf_1;
  BilinearForm mlf_2,blf_2;

  mlf_1= intg(gamma1, p_1*q_1);

  TermMatrix M_1(mlf_1,"M_1");

  mlf_2= intg(gamma2, p_2*q_2);

  TermMatrix M_2(mlf_2,"M_2");


  for (int i=1;i<=n;i++){

    printf("\n \n  iteration %d \n \n", i);

    blf_1= 0.5*intg(gamma1, p_1*q_1)-intg(gamma1, gamma1, p_1*ndotgrad_y(G)*q_1,IMie);

    TermMatrix K_1(blf_1,"K_1");
    TermVector P_1 = directSolve(K_1,M_1*U_1);

    P_1_sum += P_1;

    blf_2= 0.5*intg(gamma2, p_2*q_2)-intg(gamma2, gamma2, p_2*ndotgrad_y(G)*q_2,IMie);

    TermMatrix K_2(blf_2,"K_2");
    TermVector P_2 = directSolve(K_2,M_2*U_2);

    P_2_sum += P_2;

    TermVector U_1 = integralRepresentation(p_1, gamma1, intg(gamma2, ndotgrad_y(G)*P_2, IMir));
    TermVector U_2 = integralRepresentation(p_2, gamma2, intg(gamma1, ndotgrad_y(G)*P_1, IMir));

  }


  Space Vrep(_domain=omega, _interpolation=P1, _name="Vrep", _notOptimizeNumbering);
  Unknown ur(Vrep, _name="ur");
  
  TermVector Uext_1 = integralRepresentation(ur, omega, intg(gamma1, ndotgrad_y(G)*P_1_sum, IMir));
  TermVector Uext_2 = integralRepresentation(ur, omega, intg(gamma2, ndotgrad_y(G)*P_2_sum, IMir));
  
  TermVector Ud = 0.05*Uext_1 + 0.05*Uext_2;

  saveToFile("Ud_BEM_BEM", Ud, vtu); // scattered field in exterior domain

  TermVector Ut = Ud + TermVector(ur,omega,fuinc);

  saveToFile("Ut_BEM_BEM", Ut, vtu); // scattered field in exterior domain



  // =================================
  //      it�ratif Kirchoff-BEM
  // =================================

  // =================================
  //      it�ratif UTD-BEM
  // =================================

  theCout << "Program finished" << eol;
  return 0;
}

