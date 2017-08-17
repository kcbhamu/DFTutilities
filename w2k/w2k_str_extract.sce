// This codes extract unit cell and atomic positions from wien2k strcut file
clear; clc; exec(PiLib);
// parameters ======================================
work_dir=[];
project_name='EuScO3_sym';
// Main ==========================================  
work_dir=PIL_dir_path(work_dir);
fid=mopen(project_name+'.struct','r');
str_dat=mgetl(fid,-1);
mclose(fid);

at_line=grep(str_dat,'/ATOM....:/','r');
tot_ineq_at=length(at_line);

at_pos=[]
at_name=[]
[nv,t,spgroup]=msscanf(str_dat(2),'%30c %d')
str_par=msscanf(str_dat(4),'%f %f %f %f %f %f');
acell=str_par(1:3);
angdeg=str_par(4:6);
for n=1:tot_ineq_at
    [nv,c1,X,c2,Y,c3,Z]=msscanf(str_dat(at_line(n)),'%12c %f %2c %f %2c %f')
    at_pos=cat(1,at_pos,[X,Y,Z]);
    [nv,s1,mult]=msscanf(str_dat(at_line(n)+1),'%s %d')
    for m=1:mult-1
        [nv,c1,X,c2,Y,c3,Z]=msscanf(str_dat(at_line(n)+1+m),'%12c %f %2c %f %2c %f')
        at_pos=cat(1,at_pos,[X,Y,Z]);
    end
    [nv,an]=msscanf(str_dat(at_line(n)+1+mult),'%2c');
    at_name=cat(1,at_name,repmat(an,mult,1)+string(n));
end
at_dat=cat(2,at_name,string(at_pos));
printf('\n')
printf('spgroup %d\n',spgroup)
printf('tolsym 1d-6\n\n');
printf('acell %f   %f   %f\n',acell);
printf('angdeg %f   %f   %f\n\n',angdeg);
printf('xred\n');
printf('%f   %f   %f  # %s\n',at_pos,at_name);
