// This code shows the energy difference between two surface bands
// To use this code, you must download the xxx_sbn.sod
clear; clc; xdel(winsid());exec(PiLib);
// parameters ==========================================================
work_dir='C:\MyDrive\Work\PiLab_projects\Sr2BiIO6\SBN\M-center' // work folder
project_name='Sr';  // project name
band_comp=[239,240];    // input two bands to compare
plot_range=[]//[70,130;70,130]
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
load(work_dir+project_name+'_kif_sbn.sod');

// check variables
for n=1:length(band_comp)
    if find(kif_sbn.SelBan==band_comp(n))==[] then
        disp('Error: band-'+string(band_comp(n))+' doesn''t exist!');
        abort
    end
end
if length(band_comp)~=2 then
    disp('Error: band_comp can only have two band index');
end

// plot surface band structure
for n=1:2
    band_val(:,:,n)=..
    matrix(kif_sbn.k_band(find(kif_sbn.SelBan==band_comp(n)),:),..
    kif_sbn.k_mesh(1),kif_sbn.k_mesh(2))'    
end
f=gcf();
f.background=-2;
f.color_map = (oceancolormap(64));   
surf(1:kif_sbn.k_mesh(1),1:kif_sbn.k_mesh(2),band_val(:,:,2)-band_val(:,:,1));  

e=gce();
e.color_mode=-1
f=gcf(); 
a=gca();
a.tight_limits='on'
