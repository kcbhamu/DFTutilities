// This code plots the dos calculated by abinit
clear; clc; xdel(winsid()); exec(PiLib);
// Parameters =========================================
work_dir=[]
E_bound=[-20,+20]
// Main ===============================================
work_dir=PIL_dir_path(work_dir);
flist=dir(work_dir);
grep(flist(2),'_DOS')
fid=mopen(work_dir+flist(2)(grep(flist(2),'_DOS')),'r');
mgetl(fid,16);
DOS=mfscanf(-1,fid,strcat(repmat('%f ',1,5)));
DOS(:,1)=27.2*DOS(:,1);
mclose(fid);

plot(DOS(:,1),DOS(:,2),'linewidth',2)
plot(zeros(10,1),linspace(0,max(DOS(:,2)),10)','k:')
title('DOS','fontsize',4);
set(gcf(),'background',8);
set(gca(),'font_size',4);
set(gca(),'tight_limits','on');
set(gca(),'thickness',4);
a=gca();
a.data_bounds=[E_bound(1),0;E_bound(2),max(DOS(:,2))];
if save_png=='on' then
    xs2png('DOS.png');
end
