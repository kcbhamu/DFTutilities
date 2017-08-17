// This program is to plot the band structures calculated from quantum espresso
// To use this code, you need to download the file bands.dat
clear; clc; xdel(winsid()); exec(PiLib);
// Parameter ===========================================================
work_dir=[]//'C:\MyDrive\Work\TaAs_qe\ONCV_redo';
k_div=[12 11 15 7 11 11 15 1];   
E_Fermi=3.069; //3.1813 
E_shift='yes';    // whether to shift Ef equal to 0
E_bound=[-1,+2];  // values depending on E_shift
k_label=['$\Gamma$','X','M','$\Gamma$','Z','R','A','Z']
// Main ================================================================
work_dir=PIL_dir_path(work_dir);

fid=mopen(work_dir+'bands.dat','r'); 
mseek(0);
// read total k-point
mgetstr(12,fid);
tot_band=mfscanf(1,fid,'%d')
mgetstr(6,fid);
tot_k=mfscanf(1,fid,'%d')
mgetl(fid,1); 
if tot_k~=sum(k_div) then
    disp('Error, tot_k~=k_div')
    mclose(fid)
    abort
end

// read k-point & band eigenvalues
k_point=zeros(tot_k,3);
k_band=zeros(tot_band,tot_k);
count=0;
while meof(fid)==0
    count=count+1;
    k_point(count,:)=mfscanf(1,fid,'%f %f %f');
    mgetl(fid,1)
    k_band(:,count)=gsort(mfscanf(tot_band,fid,'%f '),'g','i');
end
mclose(fid);
if E_shift=='yes' then
    k_band=k_band-E_Fermi;
    E_Fermi=0;
end
// plot bands
plot([1:tot_k]',k_band','b','linewidth',2);

// plot k-path divider
k_loc=zeros(length(k_div)-1,1)
for n=1:length(k_div)-1
    k_loc(n)=sum(k_div(1:n))+1
    disp(k_loc(n))
    plot(k_loc(n)*ones(20,1),linspace(max(k_band)+0.5,min(k_band)-0.5,20)','k:')
end
k_loc=[1;k_loc]

// plot E_Fermi
plot((1:tot_k)',E_Fermi*ones(tot_k,1),'r:')

a=gca();
a.data_bounds=[1, E_bound(1);tot_k, E_bound(2)];
a.tight_limits='on'
a.font_size=4
a.thickness=3
b=a.x_ticks
b(2)=k_loc';
b(3)=k_label;
a.x_ticks=b
title('Band Structure','fontsize',4); 
xlabel('$k$','fontsize',4); ylabel('Energy (eV)',"fontsize", 4);
xs2png(0,'band.png')

