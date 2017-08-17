// This code is to plot the planar pseudo density of the output from gpaw.
clear; clc; xdel(winsid());

PD_folder='C:\Users\pipidog\Dropbox\My Project\Density_Plot\nt_store\'
PD_name='nt'
Plane_fix=[3,13];

// Code Start =================
PD_dim=read(PD_folder+PD_name+'_dim.txt',3,1);
PD_data=zeros(PD_dim(1),PD_dim(2),PD_dim(3));
for n=1:PD_dim(3)
    PD_data(:,:,n)=read(PD_folder+PD_name+'_'+string(n-1)+'.txt',PD_dim(1),PD_dim(2));
end


select Plane_fix(1)
case 1
    PD_plot=squeeze(PD_data(Plane_fix(2),:,:));
case 2
    PD_plot=squeeze(PD_data(:,Plane_fix(2),:));
case 3
    PD_plot=squeeze(PD_data(:,:,Plane_fix(2)));
end
xset("colormap",hotcolormap(64))
Sgrayplot(1:length(PD_plot(:,1)),1:length(PD_plot(1,:)),PD_plot)

