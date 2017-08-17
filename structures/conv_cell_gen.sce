// This code generates the conventional cell lattice vectors. 
// To use this, one must input the original lattice vectros and the new
// reciprocal lattice vectors (in reduced coordinate) in BZ. 
// The new b's should have at least one that perpendicular to the others. 
clear; clc; exec(PiLib);
// Parameters ==========================================================
lat_vec=..
[  3.327961   -0.268323   -0.946503
 0.000000    3.338760   -0.946503
 0.000000    0.000000    6.361938]

new_rec_red=[2 0 -1; 0 2 -1; 0 0 1]; // BZ axis

// Main ================================================================
[new_a_red,orth_chk]=PIL_conv_cell_gen(lat_vec,new_rec_red)
printf('new reduced lattice vector:\n');
printf('%+d %+d %+d\n',new_a_red);
printf('\n'); 
printf('orthongal check:\n');
printf('<1|2> = %f\n', orth_chk(1));
printf('<1|3> = %f\n', orth_chk(2));
printf('<2|3> = %f\n', orth_chk(3));
