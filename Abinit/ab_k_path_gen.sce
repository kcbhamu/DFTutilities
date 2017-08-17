// This code helps you generate k-point for band struncture calculation.
// << Variables >>
// [lat_const]: 1x1, real
// => lattice constant. primitive vectors will all multipile this constant.
// [pri_vect]: 3x3, real
// => primitive vectors in row form
// [red_path]: nx3, real
// => k-path divided points in reduced k-basis, i.e. coeff of b
// [k_div]: 1x1, real
// => number of divisions for each unit k
// [k_form]: 1x1, string, 'red' or 'cart'
// => form of the output k_point, reduced or cartesian 
// [out_format]: 1x1, string, 'ab' or 'qe'
// => for abinit or for quantum-espresso              
clear; clc; exec(PiLib);
// Parameters ==========================================================
lat_const=1.0
pri_vect=..
[
    2.5850000111   -4.4010000058    0.0000000000
    2.5850000111    4.4010000058    0.0000000000
    0.0000000000    0.0000000000    5.1253999263
]
red_path=..
[    
  0.00000000   0.00000000   0.00000000 
  0.50000000   0.00000000   0.00000000 
  0.33333333   0.33333333   0.00000000 
  0.00000000   0.00000000   0.00000000 
  0.00000000   0.00000000   0.50000000 
  0.50000000   0.00000000   0.50000000 
  0.33333333   0.33333333   0.50000000 
  0.00000000   0.00000000   0.50000000
]
k_div=20
k_form='red' // 'cart' or 'red'
out_format='ab' // 'ab' or 'qe'
// Main ================================================================
b=PIL_recip_vec(lat_const*pri_vect);
k_path=zeros(red_path);
for n=1:length(red_path(:,1))
    for m=1:3
        k_path(n,:)=k_path(n,:)+red_path(n,m)*b(m,:);
    end
end


[k_pt,k_pt_div]=PIL_k_path(k_path,k_div,'unit',lat_const)
select k_form
case 'red'
    for n=1:length(k_pt(:,1))
        k_pt(n,:)=(PIL_linexpan(k_pt(n,:),b'))'
    end
case 'cart'

end
printf('\n')
printf('kptopt %d\n',-length(k_pt_div))
printf('ndivk\n ')
printf('%d ',k_pt_div)
printf('\nkptbounds\n');
printf('  %7.4f  %7.4f  %7.4f\n',red_path);
printf('\n => total k-point='+string(sum(k_pt_div))+'\n')
printf('k-points:\n')
select out_format
case 'qe'
    k_pt=cat(2,k_pt,ones(length(k_pt(:,1)),1));

    printf('  %7.4f  %7.4f  %7.4f  %7.4f\n',k_pt)
case 'ab'
    printf('  %7.4f  %7.4f  %7.4f\n',k_pt)
end

