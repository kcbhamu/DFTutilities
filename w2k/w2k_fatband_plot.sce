// This code plot the fat band of wien2k. To use this code, 
// you will need to download all case.qtl* files and case.klist_band
clear; clc; xdel(winsid()); exec(PiLib); stacksize('max');
// Parameters ==================================================
work_dir=[]//['C:\MyDrive\Work\wien2k\Eu_LDAU\'];
task='plot' //'read' or 'plot'
state_grp=list([11,33])
E_bound=[-7,+3];
w_range=[];  // weight range, run empty first, then set value
marker_size=[6];
c_map=[];

// Main =======================================================
work_dir=PIL_dir_path(work_dir);
flist=dir(work_dir);
// get project name
proj_name=part(flist(2)(grep(flist(2),'klist_band')),..
1:strindex(flist(2)(grep(flist(2),'klist_band')),'.klist_band')-1);

select task
case 'read'
    // get klabel
    fid=mopen(flist(2)(grep(flist(2),'klist_band')),'r');
    klist=mgetl(fid,-1);
    klabel=[];
    for n=1:length(length(klist))-1
        if part(klist(n),1)~=' ' then
            klabel=cat(1,klabel,[string(n),msscanf(klist(n),'%s')]);
        end
    end
    mclose(fid);
    tot_k=evstr(klabel($,1));

    // get fat band file name
    f_index=grep(flist(2),'/qtl../','r');
    tot_file=length(f_index);
    if tot_file~=1 & tot_file~=2 then
        disp('Error: number of qtl files is wrong!');
        abort
    end
    // get full band data
    Ek=list();
    Ek_weight=list();
    printf('\n');
    printf('files to be read => ');
    for n=1:tot_file
        printf(' %s ;',flist(2)(f_index(n)))
    end


    for n=1:tot_file
        printf('\n\n');
        printf('  Reading data from file %s\n',flist(2)(f_index(n)));
        fid=mopen(work_dir+flist(2)(f_index(n)),'r');
        f_data=mgetl(fid,-1);
        mclose(fid);
        // get Ef
        Ef=evstr(part(f_data(3,:),57:length(f_data(3,:))));
        printf('     *Ef=%f eV\n',Ef*13.6)
        // count tot_ban
        tot_ban=length(grep(f_data,'BAND'));
        // get total atom type
        tot_jatom=length(grep(f_data(1:100),'JATOM'))
        // get state_info
        if n==1 then
            state_info=''
            state_count=1;    
            for m=1:tot_jatom
                tmp=part(f_data(m+4),32:length(f_data(m+4)))
                for p=1:length(tmp)
                    select part(tmp,p)
                    case ','
                        state_info(state_count)=string(m)..
                        +'@'+state_info(state_count);
                        state_count=state_count+1;
                        state_info(state_count)='';
                    case ' '
                        state_info(state_count)=string(m)..
                        +'@'+state_info(state_count);
                        state_count=state_count+1;
                        if (m~=tot_jatom) then
                            state_info(state_count)='';
                        end
                        break
                    else
                        state_info(state_count)=state_info(state_count)..
                        +part(tmp,p);
                    end
                end
            end
        end
        tot_proj=length(length(state_info));

        // add fatband data so all atoms has the same size of proj
        dat_add=[];
        for m=1:tot_jatom
            add_size=(13-length(evstr(f_data(5+tot_jatom+m))));
            if tmp~=0 then
                dat_add(m)=strcat(repmat(' 0',1,add_size));
            end
        end
        dat_add=repmat(dat_add,tot_k,1);

        // get band data
        Ek(n)=zeros(tot_ban,tot_k);
        Ek_weight_tmp=zeros(tot_proj*tot_k,tot_ban);
        ini_line=0;
        end_line=4+tot_jatom;
        mod_val=(pmodulo([1:tot_k*(tot_jatom+1)],tot_jatom+1)~=0)
        printf('     total band=%d\n',tot_ban);
        for m=1:tot_ban
            if pmodulo(m,10)==0 then
                printf('  %3d / %3d',m,tot_ban);
            end
            if pmodulo(m,40)==0 then
                printf('\n');
            end
            if m==tot_ban then
                printf('\n');
            end
            ini_line=end_line+1;
            end_line=ini_line+(tot_jatom+1)*tot_k;
            //check read data
            [n_v,v1,v2]=msscanf(f_data(ini_line),'%s %f');
            if v1~='BAND' | evstr(v2)~=m then
                disp('Error: Band file read error!');
                abort
            else
                tmp=f_data(ini_line+1:end_line);
                tmp=evstr(tmp(mod_val)+dat_add);

                Ek(n)(m,:)=tmp(tmp(:,2)==1,1)';
                Ek_weight_tmp(:,m)=matrix(tmp(:,3:$)',-1,1);
            end

        end

        // convert to standard format
        printf('     organizing data to standard format\n');
        Ek_weight(n)=zeros(tot_ban,tot_k,tot_proj);
        for m=1:tot_proj
            Ek_weight(n)(:,:,m)=Ek_weight_tmp(m:tot_proj:$,:)'
        end
    end
    // combine up and dn
    printf('  \ncombining data from different files\n');
    select tot_file
    case 2
        Ek=cat(1,Ek(1),Ek(2))
        Ek_weight_tmp=zeros(tot_ban*2,tot_k,2*tot_proj);
        Ek_weight_tmp(1:tot_ban,:,1:tot_proj)=Ek_weight(1);
        Ek_weight_tmp(tot_ban+1:2*tot_ban,:,tot_proj+1:$)=Ek_weight(2);

        Ek_weight=Ek_weight_tmp;    
        state_info=string([1:2*tot_proj]')+' => '+repmat(state_info,2,1);
        state_info(1:tot_proj)=state_info(1:tot_proj)+'-dn';
        state_info(tot_proj+1:$)=state_info(tot_proj+1:$)+'-up';
    case 1
        Ek=Ek(1);
        Ek_weight=Ek_weight(1);
    end
    Ek=(Ek-Ef)*13.6;

    // save read data
    save(work_dir+proj_name+'_fatband.sod','state_info',..
    'klabel','Ek','Ek_weight');
    printf('\n')
    printf('All fat band data are read !\n\n')
    printf('State info:\n');
    printf('%s\n',state_info);
case 'plot'
    load(work_dir+proj_name+'_fatband.sod');
    PIL_fatband_plot(Ek,Ek_weight,0,evstr(klabel(:,1)')..
    ,E_bound,state_grp,state_info,proj_name,[],marker_size,[],..
    c_map,w_range)
end


