// This code read the density matrix in wien2k 
// To use it, download the file case.dmatup and case.dmatdn or case.dmat for non-spin
clear; clc; exec(PiLib);
// Parameter ============================================
project_name='LDAUJ'
spin_deg='on'
// Main ===============================================
select spin_deg
case 'on'
    fid=mopen(project_name+'.dmatup');
    mgetl(fid,2);
    dmup=mfscanf(7,fid,strcat(repmat('%f ',1,14)));
    mclose(fid);
    dmup=dmup(:,1:2:$)+%i*dmup(:,2:2:$);
    printf('up-real\n');
    printf(strcat(repmat('%9.5f ',1,7))+'\n',real(dmup))
    printf('up-imag\n');
    printf(strcat(repmat('%9.5f ',1,7))+'\n',imag(dmup))

    fid=mopen(project_name+'.dmatdn');
    mgetl(fid,2);
    dmdn=mfscanf(7,fid,strcat(repmat('%f ',1,14)));
    mclose(fid);
    dmdn=dmdn(:,1:2:$)+%i*dmdn(:,2:2:$);
    printf('dn-real\n');
    printf(strcat(repmat('%9.5f ',1,7))+'\n',real(dmdn))
    printf('dn-imag\n');
    printf(strcat(repmat('%9.5f ',1,7))+'\n',imag(dmdn))

    printf('\ntot_up=%f\n', PIL_trace(dmup))
    printf('\ntot_dn=%f\n', PIL_trace(dmdn))
    printf('\ntot=%f\n',PIL_trace(dmup+dmdn))
case 'off'
    fid=mopen(project_name+'.dmat');
    mgetl(fid,2);
    dmup=mfscanf(7,fid,strcat(repmat('%f ',1,14)));
    mclose(fid);
    dmup=dmup(:,1:2:$)+%i*dmup(:,2:2:$);
    printf('real\n');
    printf(strcat(repmat('%9.5f ',1,7))+'\n',real(dmup))
    printf('imag\n');
    printf(strcat(repmat('%9.5f ',1,7))+'\n',imag(dmup))
    printf('\ntot=%f\n', PIL_trace(dmup))
end

