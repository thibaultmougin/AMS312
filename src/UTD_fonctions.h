#include "xlife++-libs.h"
using namespace xlifepp;
using namespace std;

//=================================================
// stuff for UTD approximation
//=================================================
// curvilinear abcissa for P on a circle
Real curvabc(const Point& P);

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
                       const vector<Vector<real_t> >& ns, map<Real, int>& sl, Vector<Complex>& vt);

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
void UTD(TermVector& U, const TermVector& gradU, const vector<Vector<real_t> >& ns, Real k, Real R, const Fock& fock);