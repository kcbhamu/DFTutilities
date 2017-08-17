// This code converts the coordinates among xyz, octopus and 
// quantum espresso format
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\Cu110'
file_name='Cu110_opt2.xyz'
tot_atom=30
move_inp='off'  // if move information is in input
input_format='xyz'  // 'xsf', xyz', 'qe', 'octopus'
output_format='octopus' // 'xsf', 'xyz', 'qe', 'octopus'
center_pos='no' // 'yes' / 'no' / 'manual, move structure to center?
pos_shift=1*[0.7+8.17,-0.5+5.8,0+2.45]
// Main ================================================================
// read input coordinate file
fid=mopen(work_dir+'/'+file_name);
select input_format
case 'xyz'
    mgetl(fid,2);
    A=mfscanf(tot_atom,fid,strcat(repmat('%s ',1,4)));
case 'qe'
    line_read=[];
    while grep(convstr(line_read),'atomic_positions')==[]
        line_read=mgetl(fid,1);
    end
    select move_inp
    case 'on'
        A=mfscanf(tot_atom,fid,strcat(repmat('%s ',1,7)));
    case 'off'
        A=mfscanf(tot_atom,fid,strcat(repmat('%s ',1,4)));
    end
case 'octopus'
    line_read=[];
    while grep(convstr(line_read),'%coordinates')==[]
        mgetl(fid,1);
    end
    select move_inp
    case 'on'
        A=mfscanf(tot_atom,fid,strcat(repmat('%s ',1,9)));
    case 'off'
        A=mfscanf(tot_atom,fid,strcat(repmat('%s ',1,7)));
    end
    A=A(1:2:$);
case 'xsf'
    mgetl(fid,7);
    A=mfscanf(tot_atom,fid,strcat(repmat('%s ',1,4)))
end
A=A(:,1:4);
mclose(fid);

// calculate pos shift
if center_pos=='yes' then
    B=eval(A(:,2:4));
    pos_shift=zeros(1,3);
    for n=1:3
        pos_shift(n)=-((max(B(:,n))-min(B(:,n)))/2+min(B(:,n)));
    end
    printf('\n')
    printf(' pos_shift=%f  %f  %f\n',pos_shift)
elseif center_pos=='no'
    pos_shift=[0,0,0];        
end
B=eval(A(:,2:4))+repmat(pos_shift,tot_atom,1);

// output coordinate file
fid=mopen(work_dir+'/'+'new_xyz.in','w');
select output_format
case 'xyz'
    mfprintf(fid,'%2s   %11.7f   %11.7f   %11.7f\n'..
    ,A(:,1),B)
case 'qe'
    mfprintf(fid,'%2s   %11.7f   %11.7f   %11.7f   1   1   1\n'..
    ,A(:,1),B);
case 'octopus'
    mfprintf(fid,'''%2s''  |  %11.7f  |  %11.7f  |  %11.7f  |  yes\n'..
    ,A(:,1),B);
case 'xsf'
    mfprintf(fid,'%2s   %11.7f   %11.7f   %11.7f\n'..
    ,A(:,1),B)
end
mclose(fid);
disp('Position range of each direction:')
for n=1:3
    disp([max(B(:,n)),min(B(:,n))])
end

