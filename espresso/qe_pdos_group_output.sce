// This code can read a series of atoms calculated espresso and output them 
// in a readable CSV format
clear; clc; exec(PiLib);
// Prameters ====================================================
work_dir=[];
Ef=10.2553
//sel_atom=list([13,14],[12,19,9,21],[5,8,26,23],[1,30,27,4])
sel_atom=list([3,27,30],[6,24,25],[10,19,22])
group_orb='off'
// Main =======================================================
work_dir=PIL_dir_path(work_dir);

// get file list
flist=dir(work_dir);

// check pdos size

for n=1:length(sel_atom) // run output files
    fid_out=mopen(work_dir+'pdos_output_'+string(n)+'.csv','w')
    pdos=[]
    state_list=[]
    for m=1:length(sel_atom(n)) // run each selected atoms
        target_file=grep(flist(2),['atm#'+string(sel_atom(n)(m))+'(']);
        for p=1:length(target_file) // run each states of a selected atom
            // construct state info
            state_info=flist(2)(target_file(p))
            s1=strindex(state_info,'atm')
            s2=strindex(state_info,'_wfc')
            at_label=part(state_info,s1+4:s2-1)
            s1=strindex(at_label,'(')
            at_label=[part(at_label,1:s1-1),..
            part(at_label,s1+1:length(at_label)-1)]

            s1=strindex(state_info,'_wfc#')
            s2=length(state_info)
            state_label=part(state_info,s1+7:s2-1)
            state_label=[part(state_label,1),..
            part(state_label,3:length(state_label))]
            state_info=[at_label,state_label]
            // read data 
            fid=mopen(work_dir+flist(2)(target_file(p)),'r');
            pdos_data=mgetl(fid,-1);
            pdos_data=msscanf(length(length(pdos_data))-1,pdos_data(2:$),'%f %f');
            mclose(fid)
            state_list=cat(1,state_list,state_info)
            pdos=cat(2,pdos,pdos_data);           
        end
    end
    E=pdos(:,1)-Ef;
    pdos=pdos(:,2:2:$);
    // construct orbital pdos
    orb_list=['s','p','d','f']
    for m=1:length(sel_atom(n)) // run each atom
        for p=1:4 // run orbital
            orb_comb=find((eval(state_list(:,1))==sel_atom(n)(m))..
             & (state_list(:,3)==orb_list(p)))
            if orb_comb~=[] then
                state_list=cat(1,state_list,[state_list(orb_comb(1),1:3),'all'])
                pdos=cat(2,pdos,sum(pdos(:,orb_comb),2))
            end
        end
    end
    // total pdos
    pdos=cat(2,pdos,sum(pdos,2));
    
    // reconstruct state_list
    state_list_new=[]
    for m=1:length(length(state_list(:,1)))
        state_list_new(m)=state_list(m,1)+'-'+state_list(m,2)+'-'..
        +state_list(m,3)+'-'+state_list(m,4)    
    end
    state_list=state_list_new;
    state_list=(cat(1,state_list,'total'))';
    

    
//    mfprintf(fid_out,strcat(repmat('%15s  ',1,1+length(pdos(1,:))))+'\n',..
//    'E',state_list)
//    mfprintf(fid_out,strcat(repmat('%15.6f  ',1,1+length(pdos(1,:))))+'\n',..
//    E,pdos)
    mfprintf(fid_out,strcat(repmat('%s,',1,1+length(pdos(1,:))))+'\n',..
    'E',state_list)
    mfprintf(fid_out,strcat(repmat('%f,',1,1+length(pdos(1,:))))+'\n',..
    E,pdos)
    mclose(fid_out);
end

