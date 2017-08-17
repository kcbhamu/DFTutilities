// This code helps you generates the surface in Wannier Tool matrix by 
// assigning the reduced axis in k-space. 
clear; clc; exec(PiLib);
// parameters =====================================
lat_vec=..
[    6.305100000    0.000000000    0.000000000
     4.439200000    4.477400000    0.000000000
    -5.372100000   -2.238700000    2.425300000]
p_axis=[1 1 -1];
s_range=3; // search range

// Main =========================================
printf('\n');
// check p_axis is integer
if sum(abs(p_axis-round(p_axis))) >1e-3 then
    disp('Error: p_axis must be all integer!');
    abort;
end

// built necessary vectors
rec_vec=PIL_recip_vec(lat_vec);
p_vec=p_axis*rec_vec;

// serach all reciporcal lattice vectors that non-parallel to p_axis
// vec_list=[n1,n2,n3,angle]
s_loop=PIL_nest_loop(repmat([-s_range,s_range],3,1));
vec_list=zeros(length(s_loop(:,1)),4);
count=0;
for n=1:length(s_loop(:,1))
    test_vec=s_loop(n,:)*rec_vec;
    if norm(test_vec)~=0
        in_prod_val=test_vec*p_vec'/(norm(test_vec)*norm(p_vec));
        if 1-abs(in_prod_val) >=1e-2
            count=count+1;
            vec_list(count,:)=[s_loop(n,:),acos(in_prod_val)/%pi*180]
        end
    end
end
if count==0 then
    disp('Error: No non-parallel vectors found!');
    abort;
end
vec_list=vec_list(1:count,:);

// sort vec_list
vec_list=cat(2,vec_list,[1:length(vec_list(:,1))]');
tmp=PIL_lsort(abs(vec_list),'c',[1,2,3,5,4],'d')
vec_list=vec_list(tmp(:,$),1:4)

// erase repeated list
count=0;
vec_list_tmp=zeros(length(vec_list(:,1)),4);
for n=1:length(vec_list(:,1))-1
    rep_check=0;
    for m=n+1:length(vec_list(:,1))
        tmp1=vec_list(n,1:3)/norm(vec_list(n,1:3));
        tmp2=vec_list(m,1:3)/norm(vec_list(m,1:3));
        if PIL_equal(tmp1,tmp2,1e-4) | PIL_equal(tmp1,-tmp2,1e-4) then
            rep_check=1;
            break;
        end
    end
    if rep_check==0 then
        count=count+1;
        vec_list_tmp(count,:)=vec_list(n,:)
    end
end
vec_list=cat(1,vec_list($,:),vec_list_tmp(1:count,:));
if length(vec_list(:,1))<=1 then
    disp('Error: Less than 2 vectors were found!');
    abort;
end

// select a non-parallel vector
printf('\n')
printf('I have found the following vectors (R2) that\n');
printf('are not parallel to the p_axis\n\n');
printf('%4d => %2d %2d %2d\n',cat(2,[1:length(vec_list(:,1))]',vec_list(:,1:3)));
printf('\nyou have to pick one of them to form a plane with p_axis\n')
sel_vec=input('choose a favored non-parallel vector (by ID) :'); 
basis_vec=zeros(3,6);
basis_vec(2,:)=[vec_list(sel_vec,1:3),vec_list(sel_vec,1:3)*rec_vec];
basis_vec(3,:)=[p_axis,p_vec];

// search for last basis vector
s_loop=PIL_nest_loop(repmat([-s_range,s_range],3,1));
Vp=rec_vec(1,:)*PIL_crossprod(rec_vec(2,:),rec_vec(3,:));
R1_list=[];
for n=1:length(s_loop(:,1))
    R1=s_loop(n,:)*rec_vec;
    Vc=R1*PIL_crossprod(basis_vec(2,4:6),basis_vec(3,4:6));
    if abs(Vc/Vp-1) <=1e-4 then
        R1_list=cat(1,R1_list,[s_loop(n,:)]);
    end
end
if R1_list(:,1)==[] then
    printf(' Error: no proper R1 is found!');
    abort;
end

// select R1
printf('\n')
printf('I have found the following vectors that\n');
printf('are suitable to be R1\n\n');
printf('%4d => %2d %2d %2d\n',cat(2,[1:length(R1_list(:,1))]',R1_list(:,1:3)));
printf('\nyou have to pick one of them to form a plane with p_axis\n')
sel_vec=input('choose a favored non-parallel vector (by ID) :'); 
basis_vec(1,:)=[R1_list(sel_vec,:),R1_list(sel_vec,:)*rec_vec]

// generate surface matrix
// calculate surface matrix
surf_mat=zeros(3,3);
lat_vec_new=PIL_recip_vec(basis_vec(:,4:6));
for n=1:3
    surf_mat(n,:)=clean((PIL_linexpan(lat_vec_new(n,:),lat_vec')))';
end
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
