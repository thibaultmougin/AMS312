Include "/home/tmougin/xlifepp-sources-v2.3-2022-04-22/etc/gmsh/xlifepp_macros.geo";

h0=0.10000000000000001;
Call xlifepp_init;
l=0;
x1=-0.30000000000000004; y1=0; z1=0;
x2=2.2999999999999998; y2=0; z2=0;
x3=-0.30000000000000004; y3=2.6000000000000001; z3=0;
x4=-2.9000000000000004; y4=0; z4=0;
x5=-0.30000000000000004; y5=-2.6000000000000001; z5=0;
h1=h0; h2=0.016755160819145562; h3=0.016755160819145562; h4=0.016755160819145562; h5=0.016755160819145562;

Call xlifepp_Ellipse;

domain_1={E_1[],E_2[],E_3[],E_4[]};


Call xlifepp_init;
l=1;
x1=0; y1=0; z1=0;
x2=1; y2=0; z2=0;
x3=0; y3=1; z3=0;
x4=-1; y4=0; z4=0;
x5=0; y5=-1; z5=0;
h1=h0; h2=0.008377580409572781; h3=0.008377580409572781; h4=0.008377580409572781; h5=0.008377580409572781;

Call xlifepp_Ellipse;

domain_2={E_1[],E_2[],E_3[],E_4[]};


Call xlifepp_init;
l=2;
x1=-1.5; y1=0.5; z1=0;
x2=-1.3999999999999999; y2=0.5; z2=0;
x3=-1.5; y3=0.59999999999999998; z3=0;
x4=-1.6000000000000001; y4=0.5; z4=0;
x5=-1.5; y5=0.40000000000000002; z5=0;
h1=h0; h2=0.008377580409572781; h3=0.008377580409572781; h4=0.008377580409572781; h5=0.008377580409572781;

Call xlifepp_Ellipse;

domain_3={E_1[],E_2[],E_3[],E_4[]};


Plane Surface(loops_0)={loops_0[],loops_1[],loops_2[]};

domain_4={loops_0[]};

Physical Line("Sigma")= domain_1[];
Physical Line("Gamma1")= domain_2[];
Physical Line("Gamma2")= domain_3[];
Physical Surface("Omega")= domain_4[];


Mesh.ElementOrder=1;
Mesh.MshFileVersion = 2.2;
