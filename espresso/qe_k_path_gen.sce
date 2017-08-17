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
[   
      3.07870000  -1.77749000  -5.02750000
      3.07870000   5.33246000   0.00000000
     24.62960000 -14.21990000  20.10998000
]
k_path_red=..
[  
  0.50000000    0.00000000    0.00000000 
  0.50000000   -0.50000000    0.00000000 
  0.00000000    0.00000000    0.00000000 
  0.00000000    0.50000000    0.00000000 
]
k_div=30
k_label=['X','M','G','Y']
k_out_form='red' // 'cart' or 'red'

// Main ================================================================
b=PIL_recip_vec(lat_const*pri_vect);
k_path=zeros(k_path_red);
for n=1:length(k_path_red(:,1))
    for m=1:3
        k_path(n,:)=k_path(n,:)+k_path_red(n,m)*b(m,:);
    end
end


[k_pt,k_pt_div]=PIL_k_path(k_path,k_div,'unit',lat_const)
select k_out_form
case 'red'
    for n=1:length(k_pt(:,1))
        k_pt(n,:)=(PIL_linexpan(k_pt(n,:),b'))'
    end
case 'cart'

end
printf('\n');
printf('Primitive vectors:\n');
printf('%7.4f  %7.4f  %7.4f\n', pri_vect); 
printf('Reduced k-path:\n');
printf('K_POINTS crystal_b\n');
printf(' %d\n',length(k_path_red(:,1)))
printf('%7.4f  %7.4f  %7.4f %4d ! %s\n', k_path_red,[k_pt_div;1],k_label'); 
printf('k-point division numbers:\n')
printf(' %d ',k_pt_div)
printf('\n  => total k-point= %d',sum(k_pt_div));
printf('\nk-points:\n')
k_pt=cat(2,k_pt,ones(length(k_pt(:,1)),1));
printf('  %7.4f  %7.4f  %7.4f  %7.4f\n',k_pt)

