// This code compares the phase shift of ac current and laser field
clear; xdel(winsid());exec(PiLib);
work_dir='C:\MyDrive\Work\CO_junction\cw_test1' // upper of td.xxxxxxxx
dir_int=50
ini_step=30000
fin_step=35000
time_step=0.002;
// Main ================================================================
if grep(work_dir,'test1')==1
    time_period=2.06783;
elseif grep(work_dir,'test2')==1
    time_period=8271.33503;
elseif grep(work_dir,'test3')==1
    time_period=8271.33503;
elseif grep(work_dir,'test4')==1
    time_period=2.06783;
end

load(work_dir+'/tot_charge.sod');
s1=round(ini_step/dir_int)+1;
s2=round(fin_step/dir_int)+1
t=tot_charge(s1:s2,1)*0.658;
y1=tot_charge(s1:s2,6);
ratio=max(abs(y1));
y2=max(abs(y1))*cos((2*%pi/time_period)*t);

figure(1)
plot(t,y1,t,y2)
a=gce(); a.children.thickness=2;  
plot(tot_charge(s1:s2,1)*0.658,zeros(length(tot_charge(s1:s2,1)),1),'r:');
a=gce(); a.children.thickness=2;  
set(gcf(),'background',8)

// =============

//load(work_dir+'/tot_charge.sod');
//figure(1)
//s1=round(ini_step/dir_int)+1;
//s2=round(fin_step/dir_int)+1
//plot(tot_charge(s1:s2,1)*0.658,tot_charge(s1:s2,9));
//a=gce(); a.children.thickness=2;  
//plot(tot_charge(s1:s2,1)*0.658,zeros(length(tot_charge(s1:s2,1)),1),'r:');
//a=gce(); a.children.thickness=2;  
//set(gcf(),'background',8)
//set(gca(),'thickness',4,'font_size',4);   
//ylabel('current (mu-A)','font_size',4); 
//xlabel('time (fs)','font_size',4);
//title('AC current','font_size',4)
//
//fid=mopen(work_dir+'/td.general/laser','r');
//mgetl(fid,6);
//A=mfscanf(-1,fid,strcat(repmat('%f ',1,5)));
//mclose(fid);
//// renormalize A
//amp_ratio=max(abs(tot_charge(s1:s2,9)))/max(abs(A(ini_step:fin_step,3)));
//plot(A(ini_step:fin_step,2)*0.658,amp_ratio*A(ini_step:fin_step,3),'g');
//a=gce(); a.children.thickness=2; 
//set(gcf(),'background',8)
//set(gca(),'thickness',4,'font_size',4);        
//ylabel('E-field (V/A)','font_size',4); 
//xlabel('time (fs)','font_size',4); 

