// This code read all the output eigenvalues and k-points of _EIG
clear; clc; 
// Parameters ==========================================================
file_path='C:\MyDrive\Work\TaAs\slab2\TaAs-o_DS2_EIG'

// Main ================================================================
fid=mopen(file_path,'r'); 
mseek(0);
// read total k-point
mgetstr(32,fid);
tot_k=mfscanf(1,fid,'%f')
mgetl(fid,1); 

// read total band
mgetstr(17,fid)
tot_band=mfscanf(1,fid,'%f');
mseek(0); mgetl(fid,1);

// read k-point & band eigenvalues
k_point=zeros(tot_k,3);
k_band=zeros(tot_band,tot_k);
count=0;
while meof(fid)==0
    count=count+1;
    mgetstr(41,fid);
    k_point(count,:)=mfscanf(1,fid,'%f %f %f');
    mgetl(fid,1)
    k_band(:,count)=(mfscanf(tot_band,fid,'%f '))
end
mclose(fid)
disp('k_point=')
mfprintf(6,'%f  %f  %f\n',k_point)
