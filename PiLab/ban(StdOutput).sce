// this code convert the band structure data to column format. 
// so other user can use it easier.
clear; clc; exec(PiLib);
// Parameter ===========================================================
work_dir='C:\MyDrive\Work\PiLab_projects\Sn_AlO_single'
project_name='Sn_AlO'

// Main ================================================================
work_dir=PIL_dir_path(work_dir);
load(work_dir+project_name+'_ban.sod');
//PIL_band_data_output('band_std_output.dat',ban.k_band);


tot_k=length(ban.k_point(:,1));
tot_state=length(ban.k_band(:,1));
tot_proj=length(find(ban.StateProj<0));

band=zeros(length(ban.k_band(:)),2+tot_proj);
band(:,1)=matrix(repmat([1:tot_k]',tot_state,1),-1,1);
band(:,2)=matrix(ban.k_band',-1,1);
for n=1:tot_proj
    band(:,n+2)=matrix(ban.k_weight(:,:,n)',-1,1);
end

fid=mopen(work_dir+project_name+'_ban_std_output.dat','w');
mfprintf(fid,' k-pt     E_band  '..
+strcat(repmat('    PDOS-',1,tot_proj)+string([1:tot_proj])+'  ')+'\n');
mfprintf(fid,' %4d  '+strcat(repmat('%10.6f  ',1,tot_proj+1))+'\n',band);
mclose(fid);
