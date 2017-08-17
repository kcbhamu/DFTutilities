// This code read the fatband results from abinit and rewrite it to 
// managable formate. Then plot it. Note that each folder can only 
// contain one project, else this code cannot run correctly. 
clear; clc; exec(PiLib);xdel(winsid());
// Parameter ===========================================================
work_dir=[]//'/home/pipidog/Works/Eu-metal/pres-pnma'
project_name='KCu6Br4'
task='plot' // 'read' / 'plot'
Ef=0;  // set to 0 for 8.0.2, Ef for 7.10.5
k_div=[ 12 11 16 7 11 11 16   ]
grp_type='state'  //'atom' / 'state'
state_grp=list([145:153,163:171,181:189,199:207],[154:162,172:180,190:198,208:216])
E_bound=[-3,+1];
k_label=['$\Gamma$','X','M','$\Gamma$','Z','R','A','Z']
w_range=[];  // weight range, run empty first, then set value
marker_size=[30];
c_map=[];// [low, high], e.g. [0.8 0.8 0.8; 0.0 0.0 0.6], default:[];
save_png='on'
// Main ========================================================
if work_dir==[] then
    work_dir=pwd();
end
work_dir=PIL_dir_path(work_dir);
fn=dir(work_dir);
select task
case 'read'
    // built state list from
    fn_line=grep(fn(2),'FATBANDS'); 
    tot_state=length(fn_line);
    state_info=string(zeros(tot_state,1));

    // built state info
    for n=1:tot_state
        at_str_idx=strindex(fn(2)(fn_line(n)),'at');    
        if part(fn(2)(fn_line(n)),at_str_idx+8)=='_'
            [tot_var,s1,at_idx,s2,at_name,s4,spin_idx,s5,l_idx,s6,m_idx]=..
            msscanf(fn(2)(fn_line(n))..
            ,'%'+string(at_str_idx+1)+'c%4c%1c%1c%3c%1c%2c%1c%2c%2c');
            state_info(n)=at_idx+'-'+at_name..
            +', s='+spin_idx+' l='+l_idx+' m='+m_idx;
        else
            [tot_var,s1,at_idx,s2,at_name,s4,spin_idx,s5,l_idx,s6,m_idx]=..
            msscanf(fn(2)(fn_line(n))..
            ,'%'+string(at_str_idx+1)+'c%4c%1c%2c%3c%1c%2c%1c%2c%2c');
            state_info(n)=at_idx+'-'+at_name..
            +', s='+spin_idx+' l='+l_idx+' m='+m_idx;
        end
    end
    if grep(state_info,'s=2')~=[] then
        spin=2
    else
        spin=1
    end

    // check tot_k & tot_ban
    fid=mopen(work_dir+fn(2)(fn_line(1)),'r');
    ban_data=mgetl(fid,-1);
    mclose(fid);
    ban_line=grep(ban_data,'BAND number');
    tot_k=ban_line(2)-ban_line(1)-2;
    tot_ban=length(ban_line);

    // built band structure
    Ek_up_read=grep(state_info,'s=1');
    Ek_up_read=Ek_up_read(1);
    Ek_dn_read=grep(state_info,'s=2');
    Ek_dn_read=Ek_dn_read(1);

    Ek=zeros(tot_ban,tot_k,spin);
    Ek_weight=zeros(tot_ban,tot_k,tot_state);
    printf('\n');
    for n=1:tot_state
        printf('reading state %4d\n',n);
        fid=mopen(work_dir+fn(2)(fn_line(n)),'r');
        mgetl(fid,ban_line(1)-1);
        for m=1:tot_ban
            mgetl(fid,1);
            read_data=(mfscanf(tot_k,fid,'%d %f %f'));
            Ek_weight(m,:,n)=clean(read_data(:,3)');

            if n==Ek_up_read then
                Ek(m,:,1)=clean(read_data(:,2)');
            elseif n==Ek_dn_read
                Ek(m,:,2)=clean(read_data(:,2)');
            end
            mgetl(fid,2);
        end
        mclose(fid);
    end
    if spin==2 then
        Ek=cat(1,Ek(:,:,1),Ek(:,:,2));
        Ek_weight_tmp=zeros(tot_ban*2,tot_k,tot_state);

        Ek_weight_tmp(1:tot_ban,:,1:tot_state/2)=..
        Ek_weight(:,:,1:tot_state/2);

        Ek_weight_tmp(tot_ban+1:$,:,tot_state/2+1:$)=..
        Ek_weight(:,:,tot_state/2+1:$);

        Ek_weight=Ek_weight_tmp;
    else
        Ek=squeeze(Ek);
    end

    state_info=string([1:tot_state]')+' => '+state_info;
    disp(state_info);
    save(work_dir+'fatband.sod','Ek','Ek_weight','state_info');
case 'plot'
    load(work_dir+'fatband.sod');
    // calculate k_div
    k_loc=1;
    for n=1:length(k_div)
        k_loc=cat(2,k_loc,sum(k_div(1:n))+1)
    end
    //state_grp when grp_type='atom'
    state_grp_new=list()
    select grp_type
    case 'atom'
        for n=1:length(state_grp)
            state_grp_new(n)=[]
            for m=1:length(state_grp(n))
                at_idx=strcat(repmat('0',1,..
                4-length(string(state_grp(n)(m)))))..
                +string(state_grp(n)(m))
                state_grp_new(n)=cat(2,state_grp_new(n),grep(state_info,at_idx))
            end
        end
    case 'state'
        state_grp_new=state_grp
    else
        disp('Error: grp_type can only be ''atom'' or ''state''')
        abort
    end

    PIL_fatband_plot(Ek-Ef,Ek_weight,0,k_loc,E_bound,state_grp_new,state_info,..
    k_label,project_name,[],marker_size,[],c_map,w_range)
    if save_png=='on' then
        for n=0:length(state_grp)
            xs2png(n,'fatband-'+string(n)+'.png');
        end

    end
end


