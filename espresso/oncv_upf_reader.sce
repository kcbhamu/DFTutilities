// This code read the ONCV pseudopotential file from oncvpsp.
// and generate corresponding oncv upf file.
clear; clc; exec(PiLib);
// Parameter ===========================================================
work_dir=[]//'C:\MyDrive\Work\ONCV\Te'
input_name='Cu_ONCV_PBE_fr.upf'
output_name='Cu_ONCV_PBE_fr.upf'
pp_type='upf'   // 'psp8' / 'upf'
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
fid=mopen(work_dir+input_name,'r');
intext=mgetl(fid,-1)
mclose(fid)
select pp_type
case 'upf'
    row=grep(intext,'Begin PSP_UPF');
case 'psp8'
    row=grep(intext,'Begin PSPCODE8');
end
if row==[] then
    disp('Error: no PSP begin keyword found')
    abort
end

fid=mopen(work_dir+'\'+output_name,'w');
mputl(intext(row+1:$),fid)
mclose(fid)
