// This code plot the bulk band structures output by WannierTools
// To use it, bulkek.dat and bulkek.gnu must be download
clear; clc; xdel(winsid()); exec(PiLib); stacksize('max');
// Parameters ==========================================================
work_dir=[]
k_label=['$\Gamma$','$\Sigma$','S','Z','N','$\Gamma$','Z','X','$\Gamma$']
E_bound=[-1,+1]
Ef=0.03
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
// read band line
fid=mopen('bulkek.gnu','r');
gnu_dat=mgetl(fid,-1);
mclose(fid);

x_range=zeros(1,2);
x_tmp=grep(gnu_dat,'set xrange');
[nv,str1,x_range(1),str2,x_range(2)]=msscanf(gnu_dat(x_tmp),'%12c %f %c %f')

k_tmp=grep(gnu_dat,'set arrow from');
k_loc=zeros(1,length(k_tmp))
for n=1:length(k_tmp)
    [nv,str,k_loc(n)]=msscanf(gnu_dat(k_tmp(n)),'%15c %f')
end
k_loc=[x_range(1),k_loc,x_range(2)]

if length(k_loc)~=length(length(k_label)) then
    disp('Error: length of k_loc and k_label are inconsistent!');
    abort
end



// read band data
Ek=read('bulkek.dat',-1,2)
tot_ban=length(find(Ek(:,1)==0))
tot_k=length(Ek(:,1))/tot_ban
k_val=Ek(1:tot_k,1);
Ek=matrix(Ek(:,2),tot_k,-1)

k_loc_new=zeros(k_loc);
for n=1:length(k_loc)
    tmp=find(abs(k_val-k_loc(n))<=1e-3);
    k_loc_new(n)=tmp(1)
end
plot(k_val,Ek,'b','linewidth',2)

//tweak plot -----------
// plot k-path divider
for n=2:length(k_loc)-1
    plot(k_loc(n)*ones(20,1),linspace(max(Ek)+0.5,min(Ek)-0.5,20)','k:')
end

// plot E_Fermi
plot(k_val,Ef*ones(tot_k,1),'r:')

a=gca();
a.data_bounds=[k_val(1), E_bound(1);k_val($), E_bound(2)];
a.tight_limits='on'
a.font_size=4
a.thickness=3
b=a.x_ticks
b(2)=k_loc;
b(3)=k_label;
a.x_ticks=b
title('Band Structure','fontsize',4); 
xlabel('$k$','fontsize',4); ylabel('Energy',"fontsize", 4);
xs2png(0,'WT_band.png')
