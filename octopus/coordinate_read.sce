// This code reads the coordinates files in td.general of Octopus. Then
// output its corresponding xsf files. 
clear; clc; exec(PiLib);
// Parameters ==========================================================
// Azulene on Ag110
work_dir='C:\MyDrive\Work\Ag110\e4'
file_type='coordinate'
tot_atom=50  // 18 / 30
tot_iter=1500; // total iterations of the file
read_step=100;   // how many step to read
atom_type=[repmat('Ag',1,32),repmat('C',1,10),repmat('H',1,8)]
// CO on Cu110
//work_dir='C:\MyDrive\Work\Cu110\cw2'
//file_type='coordinate'
//tot_atom=30  
//tot_iter=2000; // total iterations of the file
//read_step=200;   // how many step to read
//atom_type=[repmat('Cu',28,1);'C';'O']

// Main ================================================================
work_dir=PIL_dir_path(work_dir);
fid=mopen(work_dir+'coordinates','r');
mkdir(work_dir+'xyz_file');
mdelete(work_dir+'xyz_file/*.xyz');

mgetl(fid,5);
count=0;
disp('begin reading data')

for n=1:fix(tot_iter/read_step)+1
    disp(n-1);
    tmp=mfscanf(tot_atom*3*3+2,fid,'%f');
    PIL_molecule_xyz(work_dir+'xyz_file/xyz_file_'+string(n-1)..
    ,atom_type,matrix(tmp(3:tot_atom*3+2),3,-1)');
    mgetl(fid,read_step);
end

disp('finish reading data')
mclose(fid);


