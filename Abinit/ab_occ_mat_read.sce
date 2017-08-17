// This code is to read the occupation matrix of DFT+U calculation 
// from the output of abinit
clear; clc; exec(PiLib); xdel(winsid());
// Parameters ==========================================================
work_dir=[];
filename='pnma_comp.dat'
J_num=[5/2,7/2]

// Main ================================================================
work_dir=PIL_dir_path(work_dir);
tot_mj=sum(2*J_num+1);
fid=mopen(work_dir+filename,'r');
DM=zeros(tot_mj,tot_mj);
for n=1:tot_mj
    for m=1:tot_mj
        mfscanf(fid,'%s');
        DM(n,m)=mfscanf(fid,'%f');
        mfscanf(fid,'%s');
        DM(n,m)=DM(n,m)+%i*mfscanf(fid,'%f');
        mfscanf(fid,'%s');
    end
    mgetl(fid,1);
end
mclose(fid);
Jx=[]; Jy=[]; Jz=[];
for n=1:length(J_num)
    [Jx_sub,Jy_sub,Jz_sub]=PIL_J_mat(J_num(n),'i');
    Jx=PIL_dirsum(Jx,Jx_sub);
    Jy=PIL_dirsum(Jy,Jy_sub);
    Jz=PIL_dirsum(Jz,Jz_sub);
end
bar(1:tot_mj,real(diag(DM)));
a=gca();
a.x_ticks.labels=string(diag(Jz));
a.tight_limits='on';
a.thickness=3;
a.font_size=3;
a.box='on'; 
title('Occupation Number on Mj (etot='+string(sum(diag(DM)))+')','fontsize',4);
printf('total electrons=%f\n',sum(diag(DM)));
mag(1)=PIL_trace(Jx*DM);
mag(2)=PIL_trace(Jy*DM);
mag(3)=PIL_trace(Jz*DM);
printf('total magnetic moments=%f   %f   %f\n',mag'*2);


