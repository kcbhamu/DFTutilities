// this code plots the data of kif_sbn
clear; clc; xdel(winsid());exec(PiLib);
// parameters ==========================================================
work_dir='C:\MyDrive\Work\PiLab_projects\Ba2BiI06\wann' // work folder
project_name='Ba';  // project name
Ef=11.04;              // Fermi level
band_plot=[298,299,300];    // which band to plot
plot_Ef='off';         // whether to plot a Ef plane, 'on' or 'off'
plot_range=[80,120;80,120]//[70,130;70,130]
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
load(work_dir+project_name+'_kif_sbn.sod');

// check variables
for n=1:length(band_plot)
    if find(kif_sbn.SelBan==band_plot(n))==[] then
        disp('Error: band-'+string(band_plot(n))+' doesn''t exist!');
        abort
    end
end
// plot surface band structure
for n=1:length(band_plot)
    f=gcf();
    f.background=-2;
    f.color_map = (oceancolormap(64));    
    if plot_range==[]  
        surf(1:kif_sbn.k_mesh(1),1:kif_sbn.k_mesh(2),..
        matrix(kif_sbn.k_band(find(kif_sbn.SelBan==band_plot(n)),:)-Ef,..
        kif_sbn.k_mesh(1),kif_sbn.k_mesh(2))');    
    else
        r1=plot_range(1,1):plot_range(1,2);
        r2=plot_range(2,1):plot_range(2,2);
        tmp=matrix(kif_sbn.k_band(find(kif_sbn.SelBan==band_plot(n)),:)-Ef,..
        kif_sbn.k_mesh(1),kif_sbn.k_mesh(2))'
        surf(r1,r2,tmp(r1,r2));
    end  
    e=gce();
    e.color_mode=-1
    a=gca();
    a.tight_limits='on'
end
if plot_range==[] then
    m1=linspace(1,kif_sbn.k_mesh(1),7);
    m2=linspace(1,kif_sbn.k_mesh(2),7);
else
    m1=linspace(r1(1),r1($),7);
    m2=linspace(r2(1),r2($),7);
end
if plot_Ef=='on' then
    [X,Y]=meshgrid(m1,m2);
    plot3d3(X,Y,zeros(length(m1),length(m2)));
end

