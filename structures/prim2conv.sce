// This code is to generate the conventional cell from a primitive cell
clear; clc; exec(PiLib);
// Parameters =========================================================
work_dir=[]//['C:\MyDrive\Work\TaAs\']
xsf_title='Ba2TePoO6_slab2'
xyz_format_in='red'
xyz_format_out='red' //'red' / 'cart' (screen display only)
pc_vec=..
[    
        6.1574001312         0.0000000000         0.0000000000
        3.0787000656         5.3324649349         0.0000000000
        3.0787000656         1.7774883116         5.0274961545
]
pc_sublat=..
[
 0.000000000         0.000000000         0.000000000
 0.500000000         0.500000000         0.500000000
 0.250000000         0.250000000         0.250000000
 0.750000000         0.750000000         0.750000000
 0.250000000         0.750000000         0.750000000
 0.750000000         0.250000000         0.250000000
 0.750000000         0.250000000         0.750000000
 0.250000000         0.750000000         0.250000000
 0.750000000         0.750000000         0.250000000
 0.250000000         0.250000000         0.750000000
];
atom_spec=['1*Te','1*Po','2*Ba','6*O']
cc_vec=[-1 1 -1; -1 1 0; 3 0 0]
//cc_vec=[1 0 -1; 0 1 0; 2 -2 2]    

// Main ================================================================
work_dir=PIL_dir_path(work_dir);
select xyz_format_in
case 'cart'
    
case 'red'
    pc_sublat=pc_sublat*pc_vec;
end

conv_vec=cc_vec*pc_vec;
atom_spec=PIL_atom_spec_conv(atom_spec);

[cc_sublat]=PIL_conv_cell_vec(pc_vec,pc_sublat,cc_vec)
cc_atom_spec=atom_spec(cc_sublat(:,1));
PIL_crystal_xsf(work_dir+xsf_title,cc_vec*pc_vec,cc_atom_spec,cc_sublat(:,5:7));

printf('\n')
printf(xsf_title+'.xsf has been generated in: \n')
printf('  %s\n\n',work_dir);
printf('lattice vectors:\n')
printf('  %10.6f  %10.6f  %10.6f\n',cc_vec*pc_vec);
select xyz_format_out
case 'red'
    printf('atom positions (fractional):\n')
    printf('%2s  %10.6f  %10.6f  %10.6f\n',cc_atom_spec',cc_sublat(:,8:10));
case 'cart'
    printf('atom positions (cartisian):\n')
    printf('%2s  %10.6f  %10.6f  %10.6f\n',cc_atom_spec',cc_sublat(:,5:7));
else
    disp('Error: xyz_format incorrect!')
end

if xsf_title~=[] then
    PIL_crystal_xsf(xsf_title,cc_vec*pc_vec,..
    atom_spec(cc_sublat(:,1)),cc_sublat(:,5:7));
end
