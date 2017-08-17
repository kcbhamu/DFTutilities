// input the primitive lattice vectors and sublattice positions. 
// This code convert them to standard format used in many codes.
// You can also use this code to convert cartisian and reduced
// coordinates. 
clear; clc; exec(PiLib);
// Parameters ==========================================================
work_dir=[]
prim_vec=..
[  
0.50 1.00 0.50
0.50 0.50 1.00
1.00 0.50 0.50
]*8.19*0.529
sublatt=..
[   
0.25 0.25 0.25
0.75 0.75 0.75
0.0  0.0  0.0
0.5  0.5  0.5
]
inp_type='red'  // 'red' or 'cart'
out_type='red'  // 'red' or 'cart' (control code_output format)
atom_spec=['2*O','2*Fe'] // e.g ['1*Bi','2*Sr']
code_output='abt' // 'abt' / 'espresso' / 'elk' 

xsf_output='off'  //'on' / 'off' (xsf always in cart coordinate)
xsf_title='Ba2TePoO6'
// Main ================================================================
// check primitive vloumn
// (in abinit, if it is negative, code will report error!)
V=PIL_crossprod(prim_vec(1,:),prim_vec(2,:))'*prim_vec(3,:)';
if V<0 then
    disp('Warning: negative Volumn, swap R1 and R2!')
    disp('Volumn='+string(V))
else
    disp('Volumn='+string(V))
end
printf('\n')
work_dir=PIL_dir_path(work_dir);
atom_type=[];
if code_output=='elk' & out_type=='cart' then
    printf('Elk only accepts out_type==''red''\n');
    printf('reset out_type to ''red''\n');
    out_type='red'
end

for n=1:length(length(atom_spec))
    asterisk_loc=find(strsplit(atom_spec(n))=='*')
    atom_type=cat(1,atom_type,..
    [part(atom_spec(n),1:asterisk_loc-1),..
    part(atom_spec(n),asterisk_loc+1:length(atom_spec(n)))])
end

if inp_type=='red' & out_type=='cart' then
    sublatt_out=PIL_red_cart_conv(prim_vec, sublatt, inp_type);
elseif inp_type=='cart' & out_type=='red'
    sublatt_out=PIL_red_cart_conv(prim_vec, sublatt, inp_type);
else
    sublatt_out=sublatt;
end
// translate atom_spec
atom_typ=[]
for n=1:length(length(atom_spec))
    atom_typ=cat(2,atom_typ,part(atom_spec(n),strindex(atom_spec(n),'*')+1:$))    
end

atom_spec=PIL_atom_spec_conv(atom_spec);
if length(length(atom_spec))~=length(sublatt(:,1)) then
    disp('Error: atom_spec and sublatt are inconsistend!');
    abort
end

// geneate xsf files
if xsf_output=='on' then
    if inp_type=='red' then
        sublatt_xsf=PIL_red_cart_conv(prim_vec, sublatt, inp_type);
        PIL_crystal_xsf(work_dir+xsf_title,prim_vec,atom_spec,sublatt_xsf);
    elseif inp_type=='cart'
        PIL_crystal_xsf(work_dir+xsf_title,prim_vec,atom_spec,sublatt);
    end
end

// generate screen display
ntype=length(length(atom_type(:,1)));
natom=length(length(atom_spec))
select code_output
case 'espresso'
    printf('<< Espresso atom outputs >>:\n');
    printf('ibrv = 0,\n')
    printf('celldm(1) = 1.89,\n')
    printf('ntyp = %d,\n',ntype)
    printf('nat = %d,\n',length(length(atom_spec)))
    printf('=========================\n')
    printf('CELL_PARAMETERS alat\n')
    printf('    %11.8f  %11.8f  %11.8f\n',prim_vec)
    printf('ATOMIC_SPECIES\n')
    printf('    %2s   1.000   %2s_oncv_pbe_r.upf\n',atom_typ',atom_typ')

    select out_type
    case 'cart'
        printf('ATOMIC_POSITIONS angstrom\n')
    case 'red'
        printf('ATOMIC_POSITIONS crystal\n')
    else
        disp('Error: out_type is wrong');
    end
    printf('%2s    %11.8f    %11.8f    %11.8f  0  0  0\n',..
    atom_spec',sublatt_out);    
    printf('K_POINTS automatic\n')
    for n=1:3
        kmesh(n)=round(50/norm(prim_vec(n,:)))
    end
    printf('%i %i %i 1 1 1',kmesh')
    
case 'abt'   
    printf('<< ABINIT atom outputs >>:\n');
    printf('chkprim 0 # warning on non-primtive cell\n');
    printf('nsym 0    # atuo sym-finder\n');    
    printf('ntypat %d\n',ntype);
    printf('znucl '+strcat(repmat('? ',ntype,1))+'\n')
    printf('natom %d\n',natom)
    printf('typat '+strcat(repmat('%d*%d ',1,ntype))+'\n',..
    matrix(cat(2,eval(atom_type(:,1)),[1:ntype]')',1,-1));
    printf('acell 3*1 angstrom\n')
    printf('rprim\n');
    printf('  %11.8f  %11.8f  %11.8f\n',prim_vec)
    select out_type 
    case 'cart'
        printf('xangst\n')
    case 'red'
        printf('xred\n')    
    end
    printf('%11.8f    %11.8f    %11.8f\n',sublatt_out)
case 'elk'
    printf('<< Elk atom outputs >>:\n');
    printf('primcell\n   .true.\n')
    printf('scale\n    1.89\n')
    printf('avec\n');
    printf('  %11.8f  %11.8f  %11.8f\n',prim_vec)
    printf('atoms\n');
    printf('  %-2d        :nspecies\n',ntype)
    for n=1:ntype
            printf('  ''%s.in''   :spfname\n',atom_type(n,2));
            printf('  %-2d        :natoms; atposl, bfcmt below\n',..
            eval(atom_type(n,1)));
            printf('%11.8f %11.8f %11.8f  0.0 0.0 0.0\n',..
            sublatt_out(find(atom_spec==atom_type(n,2)),:))
    end
end



