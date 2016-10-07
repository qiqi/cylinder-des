// Gmsh allows variables; these will be used to set desired
// element sizes at various Points
radius = 0.5;
bl = 0.8;
outer = 2.3;
far = 50;

//lz = 0.0628;
lz = 6.28;
nz = 1;

n_pi = 80;
n_bl = 30; 
n_inner = 40; 
n_outer = 80; 

p_bl = 1.15;
p_inner = 1.02;
p_outer = 1.04;

a = 0.70710678118654746;

// Circle & surrounding structured-quad region
Point(1) = {0,   0, 0};
Point(2) = { radius*a,  radius*a, 0};
Point(3) = { radius*a, -radius*a, 0};
Point(4) = {-radius*a, -radius*a, 0};
Point(5) = {-radius*a,  radius*a, 0};

Point(6) = { bl*a,  bl*a, 0};
Point(7) = { bl*a, -bl*a, 0};
Point(8) = {-bl*a, -bl*a, 0};
Point(9) = {-bl*a,  bl*a, 0};

Point(10) = { outer,  outer, 0};
Point(11) = { outer, -outer, 0};
Point(12) = {-outer, -outer, 0};
Point(13) = {-outer,  outer, 0};

Point(14) = { 0,      far,   0};
Point(15) = { far,    far,   0};
Point(16) = { far,    outer, 0};
Point(17) = { far,   -outer, 0};
Point(18) = { far,   -far,   0};
Point(19) = { 0,     -far,   0};
Point(20) = {-far*a, -far*a, 0};
Point(21) = {-far*a,  far*a, 0};
Point(22) = {-outer,  outer, 0};

Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 4};
Circle(3) = {4, 1, 5};
Circle(4) = {5, 1, 2};

Circle(5) = {6, 1, 7};
Circle(6) = {7, 1, 8};
Circle(7) = {8, 1, 9};
Circle(8) = {9, 1, 6};

Transfinite Line {1,2,3,4,5,6,7,8} = n_pi/2;

Line(9)  = {2, 6};
Line(10) = {3, 7};
Line(11) = {4, 8};
Line(12) = {5, 9};

Transfinite Line {9,10,11,12} = n_bl Using Progression p_bl;

Line Loop(13) = {8, -9, -4, 12};
Plane Surface(14) = {13};
Line Loop(15) = {7, -12, -3, 11};
Plane Surface(16) = {15};
Line Loop(17) = {2, 11, -6, -10};
Plane Surface(18) = {17};
Line Loop(19) = {1, 10, -5, -9};
Plane Surface(20) = {19};

Transfinite Surface{14,16,18,20};

Circle(20) = {10, 1, 11};
Circle(21) = {11, 1, 12};
Circle(22) = {12, 1, 13};
Circle(23) = {13, 1, 10};

Transfinite Line {20,21,22,23} = n_pi/2;

Line(24) = {6, 10};
Line(25) = {7, 11};
Line(26) = {8, 12};
Line(27) = {9, 13};

Transfinite Line {24,25,26,27} = n_inner Using Progression p_inner;

Line Loop(28) = {23, -24, -8, 27};
Plane Surface(29) = {28};
Line Loop(30) = {24, 20, -25, -5};
Plane Surface(31) = {30};
Line Loop(32) = {25, 21, -26, -6};
Plane Surface(33) = {32};
Line Loop(34) = {26, 22, -27, -7};
Plane Surface(35) = {34};

Transfinite Surface{29,31,33,35};

Circle(36) = {14, 1, 21};
Circle(37) = {21, 1, 20};
Circle(38) = {20, 1, 19};

Transfinite Line {36,37,38} = n_pi/2;

Line(39) = {14, 15};
Line(40) = {16, 15};
Line(41) = {16, 17};
Line(42) = {17, 18};
Line(43) = {19, 18};
Line(44) = {11, 19};
Line(45) = {11, 17};
Line(47) = {10, 16};
Line(48) = {10, 14};
Line(49) = {13, 21};
Line(50) = {12, 20};

Transfinite Line {39,40,42,43,44,45,47,48,49,50} = n_outer Using Progression p_outer;
Transfinite Line {41} = n_pi/2;

Line Loop(51) = {39, -40, -47, 48};
Plane Surface(52) = {51};
Line Loop(53) = {48, 36, -49, 23};
Plane Surface(54) = {53};
Line Loop(55) = {49, 37, -50, 22};
Plane Surface(56) = {55};
Line Loop(57) = {50, 38, -44, 21};
Plane Surface(58) = {57};
Line Loop(59) = {-44, 45, 42, -43};
Plane Surface(60) = {59};
Line Loop(61) = {45, -41, -47, 20};
Plane Surface(62) = {61};

Transfinite Surface{52,54,56,58,60,62};
Coherence;

Recombine Surface {14,16,18,20,29,31,33,35,52,54,56,58,60,62};

Extrude {0, 0, lz} {
Surface{14,16,18,20,29,31,33,35,52,54,56,58,60,62};
Layers{nz};
Recombine;
}

Physical Surface("inflow") = {247, 273, 317, 347, 295};
Physical Surface("outflow") = {251, 343};
Physical Surface("wall") = {137, 115, 101, 79};
Physical Surface("near") = {282, 260, 304, 326, 348, 370, 194, 172, 238, 216, 150, 84, 106, 128};
Physical Surface("far") = {52, 54, 56, 58, 60, 62, 31, 33, 35, 29, 20, 18, 16, 14};

Physical Volume("fluid") = {10, 9, 11, 12, 13, 14, 5, 8, 7, 6, 1, 2, 3, 4};
