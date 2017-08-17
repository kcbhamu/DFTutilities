// This code perform complex Fourier transform of the input data
clear; clc; exec(PiLib); xdel(winsid())
// Parameters ==========================================================
work_dir='D:\Work\CO_junction\md_cw1'  // folder of tot_charge.sod
E_max=5       // E max
data_ini=1;    // initial row to perform FT
dE=0.005       // dE in FT
time_period=2.06783 // use converson website to get it
// Main ================================================================
load(work_dir+'/tot_charge.sod');
FT_data=PIL_FT_damp(tot_charge(data_ini:$,[1,8]),E_max,dE,'exp')
FT_data(:,3)=abs(FT_data(:,2));


figure(1)
plot(FT_data(:,1),FT_data(:,3));
a=gce(); a.children.thickness=2;  
set(gcf(),'background',8)
set(gca(),'thickness',4)
set(gca(),'font_size',4); 
xlabel('energy (eV)'); 
ylabel('FT components');
xsave(work_dir+'/charge_acc_FT.scg', gcf())
