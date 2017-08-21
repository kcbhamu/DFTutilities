// This code read the ONCV pseudopotential file from oncvpsp.
// and generate corresponding oncv upf file.
clear; clc; exec(PiLib);
// Parameter ===========================================================
work_dir=[]//'C:\MyDrive\Work\ONCV\Te'
input_name='Pt_ONCV_PBE_fr.upf'
output_name='Pt_ONCV_PBE_fr.upf'
pp_type='upf'   // 'psp8' / 'upf'
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
fid=mopen(work_dir+input_name,'r');
intext=mgetl(fid,-1)
select pp_type
case 'upf'
    [r,w]=grep(intext,'Begin PSP_UPF');
    mclose(fid)
case 'psp8'
    [r,w]=grep(intext,'Begin PSPCODE8');
    mclose(fid)
end


fid=mopen(work_dir+'\'+output_name,'w');
mputl(intext(r+1:$),fid)
mclose(fid)
