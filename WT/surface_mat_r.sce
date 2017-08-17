// This code helps you generates the surface in Wannier Tool matrix by assigning
// the slab axis in r-space. 
clear; clc; exec(PiLib);
// parameters =====================================
lat_vec=..
[  6.28893418  -0.50705784  -1.78863214
  0.00000000   6.30934241  -1.78863193
  0.00000000   0.00000000  12.02232134
]*0.5292
p_axis=[-1  -1  1];
s_range=4; // search range


// Main =========================================
printf('\n');
rec_vec=PIL_recip_vec(lat_vec);
p_vec=p_axis*lat_vec;

// serach all perperndicular lattice vectors
s_loop=PIL_nest_loop(repmat([-s_range,s_range],3,1));

orth_list=zeros(length(s_loop(:,1)),4);
count=0;
for n=1:length(s_loop(:,1))
    test_vec=s_loop(n,:)*lat_vec;
    if norm(test_vec)~=0
        in_prod_val=abs(test_vec*p_vec')/(norm(test_vec)*norm(p_vec));
        if in_prod_val <=1e-3
            count=count+1;
            orth_list(count,:)=[s_loop(n,:),in_prod_val]
        end
    end
end
if count==0 then
    disp('Error: No perpendicular vectors found!');
    abort;
end
orth_list=orth_list(1:count,:);

// sort orth_list
orth_list=cat(2,orth_list,[1:length(orth_list(:,1))]');
tmp=PIL_lsort(abs(orth_list),'c',[1,2,3,5,4],'d')
orth_list=orth_list(tmp(:,$),1:4)

// erase repeated list
count=0;
orth_list_tmp=zeros(length(orth_list(:,1)),4);
for n=1:length(orth_list(:,1))-1
    rep_check=0;
    for m=n+1:length(orth_list(:,1))
        tmp1=orth_list(n,1:3)/norm(orth_list(n,1:3));
        tmp2=orth_list(m,1:3)/norm(orth_list(m,1:3));
        if PIL_equal(tmp1,tmp2,1e-4) | PIL_equal(tmp1,-tmp2,1e-4) then
            rep_check=1;
            break;
        end
    end
    if rep_check==0 then
        count=count+1;
        orth_list_tmp(count,:)=orth_list(n,:)
    end
end
orth_list=cat(1,orth_list($,:),orth_list_tmp(1:count,:));
if length(orth_list(:,1))<=1 then
    disp('Error: Less than 2 vectors were found!');
    abort;
end

// select plane vector
printf('\n')
printf('I have found the following in plane vectors that\n');
printf('perpendicular to the p_axis\n\n');
printf('%2d => %2d %2d %2d\n',cat(2,[1:length(orth_list(:,1))]',orth_list(:,1:3)));
printf('\nyou have to pick two of them to form a plane\n')
inp_check=0
while inp_check==0
    sel_vec(1)=input('choose your 1st favored in-plane vectors (by ID) :');
    sel_vec(2)=input('choose your 2nd favored in-plane vectors (by ID) :');
    tmp=orth_list(sel_vec,1:3)*lat_vec;
    in_prod=(tmp(1,:)/norm(tmp(1,:)))*(tmp(2,:)/norm(tmp(2,:)))';
    if abs(abs(in_prod)-1) > 1e-3
        inp_check=1;
    else
        printf('  Error: the choen vectors are not linearly independent!\n\n')
    end
end
// construct transformation matrix
s_loop=PIL_nest_loop(repmat([-s_range,s_range],3,1));
Vp=lat_vec(1,:)*PIL_crossprod(lat_vec(2,:),lat_vec(3,:));
R1=orth_list(sel_vec(1),1:3)*lat_vec;
R2=orth_list(sel_vec(2),1:3)*lat_vec;
R3_list=[];
for n=1:length(s_loop(:,1))
    R3=s_loop(n,:)*lat_vec;
    Vc=R1*PIL_crossprod(R2,R3);
    if abs(Vc/Vp-1) <=1e-4 then
        R3_list=cat(1,R3_list,[s_loop(n,:)]);
    end
end
if R3_list(:,1)==[] then
    printf(' Error: not proper R3 is found!');
    abort;
end
printf('\n');
printf('I found the following allowed R3:\n');
printf('%2d => %2d   %2d   %2d \n',[1:length(R3_list(:,1))]',R3_list);
printf('\nyou have to pick one of them to be R3\n');
sel_vec(3)=input('choose your 3rd favored out-of-plane vector (by ID):');
R3=R3_list(sel_vec(3),:)*lat_vec;
printf('\n')
printf('selected R1: %2d   %2d   %2d\n',orth_list(sel_vec(1),1:3));
printf('selected R2: %2d   %2d   %2d\n',orth_list(sel_vec(2),1:3));
printf('selected R3: %2d   %2d   %2d\n',R3_list(sel_vec(3),1:3));

// calculate surface matrix
surf_mat=[orth_list(sel_vec(1),1:3);..
orth_list(sel_vec(2),1:3);..
R3_list(sel_vec(3),1:3)]
if sum(abs(surf_mat-round(surf_mat)))>=1e-5 then
    printf(' Error: surf_mat is not integer matrix!');
else
    surf_mat=round(surf_mat);
end

// check surf_mat
lat_vec_new=surf_mat*lat_vec
Vp=lat_vec(1,:)*PIL_crossprod(lat_vec(2,:),lat_vec(3,:));
Vn=lat_vec_new(1,:)*PIL_crossprod(lat_vec_new(2,:),lat_vec_new(3,:));
if abs(Vn-Vp)>=1e-4 then
    printf(' Error: surface matrix doesn''t give the same volumn!');
end

printf('\n');
printf('surface matrix for WT input:\n');
printf('%2d %2d %2d\n',surf_mat);
printf('\n')
printf('Use prim2conv to generate xsf file!\n')
printf('Enlarge last row of surface matrix to check it!\n')
// generate xsf file

