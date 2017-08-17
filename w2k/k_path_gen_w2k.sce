// This code helps you generate k-point for band struncture calculation.
// << Variables >>
// [lat_const]: 1x1, real
// => lattice constant. primitive vectors will all multipile this constant.
// [pri_vect]: 3x3, real
// => primitive vectors in row form
// [k_path_red]: nx3, real
// => k-path divided points in reduced k-basis, i.e. coeff of b
// [k_div]: 1x1, real
// => number of divisions for each unit k
// [k_out_form]: 1x1, string, 'red' or 'cart'
// => form of the output k_point, reduced or cartesian 
// [file_format]: 1x1, string, 'ab' or 'qe'
// => for abinit or for quantum-espresso              
clear; clc; exec(PiLib);
// Parameters ==========================================================
lat_const=1
pri_vect=..
[      2.70350    0.00000  -15.38550
      0.00000    5.41200    0.00000
      2.70350    0.00000   15.38550
]
k_path_red=..
[    0.0000000000     0.0000000000     0.0000000000
   0.2577319588     0.0000000000     0.2577319588
  -0.2577319588     0.0000000000     0.7422680412
  -0.2577319588    -0.5000000000     0.7422680412
  -0.5000000000     0.0000000000     0.5000000000
  -0.5000000000    -0.5000000000     0.5000000000
   0.0000000000    -0.5000000000     0.0000000000
   0.0000000000     0.0000000000     0.0000000000
]
k_div=50
k_out_form='red' // 'cart' or 'red'

// Main ================================================================
b=PIL_recip_vec(lat_const*pri_vect);
k_path=zeros(k_path_red);
for n=1:length(k_path_red(:,1))
    for m=1:3
        k_path(n,:)=k_path(n,:)+k_path_red(n,m)*b(m,:);
    end
end


[k_pt,k_pt_div]=PIL_k_path(k_path,k_div,'unit',lat_const);
for n=1:3
    k_pt(:,n)=k_pt(:,n)/(2*%pi/norm(pri_vect(n,:)));
end

k_pt_div=cat(1,0,k_pt_div);
for n=2:length(k_pt_div)
    k_div_loc(n-1)=sum(k_pt_div(1:n))
end
k_div_loc=cat(1,1,k_div_loc)

printf('\n');
printf('Primitive vectors:\n');
printf('%7.4f  %7.4f  %7.4f\n', pri_vect); 
printf('Reduced k-path:\n');
printf('%7.4f  %7.4f  %7.4f %4d\n', k_path_red,[k_pt_div;1]); 
printf('k-point division numbers:\n')
printf(' %d ',k_pt_div)
printf('\n  => total k-point= %d',sum(k_pt_div));
printf('\nk-points:\n')
k_pt=cat(2,k_pt,ones(length(k_pt(:,1)),1));
printf('  %3d %7.4f  %7.4f  %7.4f  %7.4f\n',cat(2,[1:length(k_pt(:,1))]',k_pt))

