// This code plots the fat band structure calculated by quantum espresso.
// To run this code, you will need to download projwfc.dat, projwfc.out 
// and bands.dat
clear; clc; xdel(winsid()); exec(PiLib); //stacksize('max');
// Parameters ======================================
work_dir=[];
project_name='KCu6B4'
task='plot' //'read' or 'plot'

Ef=3.6066
k_div=[12 11 15 7 11 11 15 1];
k_label=['$\Gamma$','X','M','$\Gamma$','Z','R','A','Z']
atom_grp=[]//list([189],[190:192])

state_grp=list([189:4:252],[190:4:252,191:4:252,192:4:252]); // list([])
E_bound=[-1,+2];
w_range=[];  // weight range, run empty first, then set value
marker_size=[30];
c_map=[]//[1 0 0;0 0 1];

// Main ==========================================
work_dir=PIL_dir_path(work_dir());
select task
case 'read'
    printf('\n');
    // check file type
    flist=dir(work_dir);
    f_check=length(grep(flist(2),'/projwfc.dat$/','r'));
    f_check_spin=length(grep(flist(2),'/projwfc.dat.[down,up]/','r'));
    if f_check==1 & f_check_spin~=0 then
        disp('Error: projwfc.dat and projwfc.dat.up/down coexist!');
        abort
    elseif f_check==0 & f_check_spin~=2 
        disp('Error: projwfc.dat.up and projwfc.dat.down not coexist!');
        abort
    elseif f_check==1 & f_check_spin==0
        printf('Data are in non-spin / SOC format \n\n');
        filename=['projwfc.dat']
        tot_file=1;
    elseif f_check==0 & f_check_spin==2
        printf('Data are in LSDA format \n\n');
        filename=['projwfc.dat.down','projwfc.dat.up']
        tot_file=2;
    elseif f_check==0 & f_check_spin==0
        printf('No projwfc data exist!');
        abort
    end

    // read bands.dat
    printf('Reading band energies from bands.dat \n');
    fid=mopen(work_dir+'bands.dat','r');
    mgetstr(12,fid);
    tot_ban=mfscanf(1,fid,'%d')
    mgetstr(6,fid);
    tot_k=mfscanf(1,fid,'%d')
    mgetl(fid,1); 
    if tot_k~=sum(k_div) then
        disp('Error, tot_k~=k_div')
        mclose(fid)
        abort
    end
    k_point=zeros(tot_k,3);
    Ek=zeros(tot_ban,tot_k);
    count=0;
    while meof(fid)==0
        count=count+1;
        k_point(count,:)=mfscanf(1,fid,'%f %f %f');
        mgetl(fid,1)
        Ek(:,count)=gsort(mfscanf(tot_ban,fid,'%f '),'g','i');
    end
    mclose(fid);

    // read expansion coefficients and state_info
    for n=1:tot_file
        printf('Reading data from file %s \n', filename(n))
        fid=mopen(work_dir+filename(n),'r');
        wfc_dat=mgetl(fid,-1);
        mclose(fid);
        ini_line=grep(wfc_dat,'/[T,F]    [T,F]/','r');
        [nv,tot_state,tot_k,tot_ban]=msscanf(wfc_dat(ini_line-1),'%d %d %d');
        end_line=ini_line;
        if n==1 then
            Ek_weight=zeros(tot_ban,tot_k,tot_state*tot_file);
        end
        printf('  total orbitals=%d\n',tot_state);
        for m=1:tot_state
            printf(' %3d/%3d ; ',m,tot_state);
            if pmodulo(m,5)==0 then
                printf('\n');
            end
            start_line=end_line+2
            end_line=start_line+tot_k*tot_ban-1
            state_coeff=msscanf(end_line-start_line+1,wfc_dat(start_line:end_line),'%d %d %f');
            Ek_weight(:,:,(n-1)*tot_state+m)=..
            matrix(state_coeff(:,3),tot_ban,-1);
        end
        clear state_coeff wfc_dat
    end


    // read state info and eigenvalues
    printf('\n\n');
    printf('Reading state_info from projwfc.out ...\n');
    fid=mopen(work_dir+'projwfc.out','r');
    wfc_out=mgetl(fid,-1);
    mclose(fid);
    state_info=wfc_out(grep(wfc_out,'state #'));
    state_info=part(state_info,18:length(state_info(1,:)));
    if tot_file==2 then
        state_info=cat(1,state_info+' @dn',state_info+' @up')
    end
    state_info=string([1:length(length(state_info))]')+' => '+state_info
    clear wfc_out

    // convert to PiLib standard format
    if tot_file==2 then
        Ek=cat(1,Ek(:,:,1),Ek(:,:,2))
        Ek_weight_tmp=zeros(tot_ban*2,tot_k,tot_state*2);
        for n=1:tot_file
            for m=1:tot_state
                Ek_weight_tmp((n-1)*tot_ban+1:n*tot_ban,:,..
                (n-1)*tot_state+m)=..
                Ek_weight(:,:,(n-1)*tot_state+m)
            end
        end
        Ek_weight=(abs(Ek_weight_tmp)).^2;
        clear Ek_weight_tmp;
    else
        Ek=squeeze(Ek);
    end
    printf('\n')
    printf('All fat band information obtained!\n');
    save(work_dir+'projwfc.sod','Ek','Ek_weight','state_info')
    printf('%s\n',state_info)
case 'plot'
    load(work_dir+'projwfc.sod');

    // auto generate state_grp based on atom labels
    if state_grp(1)==[] then
        state_grp=list()
        tot_state=length(length(state_info))
        for n=1:length(atom_grp)
            state_grp(n)=[]
            for m=1:length(atom_grp(n))
                str='atom'+strcat([repmat(' ',1,4-length(string(atom_grp(n)(m))))..
                ,string(atom_grp(n)(m))])
                state_grp(n)=cat(2,state_grp(n),grep(state_info,str))
            end
        end
    end

    k_loc=[1]
    for n=1:length(k_div)-1
        k_loc=cat(2,k_loc,sum(k_div(1:n))+1)
    end    
    PIL_fatband_plot(Ek-Ef,Ek_weight,0,k_loc,E_bound,state_grp,state_info,..
    k_label,project_name,[],marker_size,[],c_map,w_range)

    for n=0:length(state_grp)
        xs2png(n,'fatband-'+string(n)+'.png')
    end

end



