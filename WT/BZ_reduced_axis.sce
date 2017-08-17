// This code calculated the reduced BZ, i.e. c3 goes to infinite. 
clear; clc; exec(PiLib);
//Parameters ==================================
a_vec=[..    
  5.992718   0.000000   0.000000
  2.996359   5.189846   0.000000
  2.996359   1.729949   4.893033]; // original lattice vectors
c_conv=[1 0 0; 0 1 0; 0  0  1]; // converted lattice vectors
N_slab=1e+6; // use a large value to see length decrease (1E+6)
// Main =======================================
printf('\n');
printf('Original BZ vectors:\n');
c_vec=c_conv*a_vec;
b0=PIL_recip_vec(c_vec);
for n=1:3
    printf('BZ vector %d=%f %f %f , norm=%f\n',..
    n,b0(n,:),norm(b0(n,:)))
end
printf('\n');
printf('Slab BZ vectors (c3-> infinity):\n');
bs=PIL_recip_vec([c_vec(1,:);c_vec(2,:);N_slab*c_vec(3,:)]);
for n=1:3
    printf('BZ vector %d=%f %f %f , norm=%f\n',..
    n,bs(n,:),norm(bs(n,:)));
end

// check if there is any axis becomes zero
bs_norm=zeros(1,3);
for n=1:3
    bs_norm(n)=norm(bs(n,:));
end
bs=bs(find(bs_norm>=1e-2),:);
if length(bs(:,1))~=2 then
    disp('Error: slab basis is not defined');
    abort    
else
    bs_norm=zeros(1,2);
    for n=1:2
        bs_norm(n)=norm(bs(n,:));
    end    
end
printf('\n')
printf('Slab 2D BZ basis found (Cartisian):\n');
printf('2D BZ vector %d= %f  %f  %f\n',[1 2]',bs)

// generate orthgonal basis
c_mat=zeros(4,2);
c_mat(1,:)=[1,0];
c_mat(2,1)=-bs(2,:)*bs(1,:)'/(bs_norm(1))^2; c_mat(2,2)=1.0;

c_mat(3,1)=1.0; c_mat(3,2)=-bs(1,:)*bs(2,:)'/(bs_norm(2))^2;
c_mat(4,:)=[0,1];

printf('\n');

for n=1:2
    printf('Suggested slab orthgonal basis set %d:\n',n);
    printf('* fractional\n')
    printf('bs1''=%+f*bs1%+f*bs2\n',c_mat((n-1)*2+1,:));
    printf('bs2''=%+f*bs1%+f*bs2\n',c_mat((n-1)*2+2,:));
    printf('* cartsian\n')
    tmp1=c_mat((n-1)*2+1,:)*bs;
    tmp2=c_mat((n-1)*2+2,:)*bs;
    printf('bs1''=%f %f %f\n',tmp1);
    printf('bs2''=%f %f %f\n',tmp2);
    printf('* unit factional\n');
    printf('bs1''=%+f*bs1%+f*bs2\n',c_mat((n-1)*2+1,:)/norm(tmp1));
    printf('bs2''=%+f*bs1%+f*bs2\n',c_mat((n-1)*2+2,:)/norm(tmp2));
    printf('\n');
end




