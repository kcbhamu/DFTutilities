// This code plot the PDOS calculated from Quantum espresso
// change the file browser to working folder. 
clear; clc; exec(PiLib); xdel(winsid());
// Parameters ==========================================================
work_dir=[] // dir where pdos files are stored
Ef=10.6726   // Fermi level
plot_atom=[-1,13,14,-2,12,19,9,21,-3,5,8,26,23,-4,1,30,27,4];  // [fig #, atom #],e.g. [-1,1:3,-2,5:6]
//plot_atom=[-1,3,27,30,-2,6,24,25,-3,10,19,22]
dos_range=[]//[]: default
E_range=[-10,10]//[Emin,Emax][]:default 
output_data='on' // 'on' / 'off'
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
file_list=dir(work_dir);

// read total dos (TDOS=[E, DOS, LDOS])
fn_ind=grep(file_list(2),['.pdos_tot']);
fid=mopen(file_list(2)(fn_ind),'r');
mgetl(fid,1);
TDOS=mfscanf(-1,fid,'%f %f %f')
mclose(fid);

// define parameters 
tot_E=length(TDOS(:,1));
plot_ind=find(plot_atom<0);
tot_plot=length(plot_ind);

// read pdos of each atom
// LDOS(n)()
LDOS=list();
for n=1:tot_plot
    figure(n);
    if n==tot_plot then
        sel_atom=plot_atom(plot_ind(n)+1:$);
    else
        sel_atom=plot_atom(plot_ind(n)+1:plot_ind(n+1)-1);
    end
    tot_sel_atom=length(sel_atom);
    LDOS(n)=zeros(tot_E,tot_sel_atom+2);
    LDOS(n)(:,1)=TDOS(:,1);
    atom_spec=[];
    for m=1:tot_sel_atom
        fn_ind=grep(file_list(2),['atm#'+string(sel_atom(m))+'(']);

        at_ind=strindex(file_list(2)(fn_ind(1)),')_wfc');
        at_spec_tmp=part(file_list(2)(fn_ind(1)),at_ind-2:at_ind-1);
        if grep(at_spec_tmp,'(')~=[] then
            at_spec_tmp=part(at_spec_tmp,2);
        end
        atom_spec=cat(2,atom_spec,at_spec_tmp);
        for p=1:length(fn_ind)
            fid=mopen(file_list(2)(fn_ind(p)));
            mgetl(fid,1);
            tmp=(matrix(mfscanf(-1,fid,'%f'),-1,tot_E))';
            LDOS(n)(:,m+2)=LDOS(n)(:,m+2)+tmp(:,2);
            mclose(fid);
        end
    end
    atom_spec=string(sel_atom)+'-'+atom_spec;
    LDOS(n)(:,2)=sum(LDOS(n)(:,3:$),2);
    LDOS(n)(:,1)=LDOS(n)(:,1)-Ef; 

    // plot figures
    figure(n);
    plot(LDOS(n)(:,1),LDOS(n)(:,2:$),'thickness',3);
    legend(['sum LDOS','atom '+atom_spec],2);

    a=gca();
    if E_range==[] then
        if dos_range==[] then
            plot_range=[min(LDOS(n)(:,2)),max(LDOS(n)(:,2))];
        else
            plot_range=[0,dos_range];
        end
        a.data_bounds=..
        [LDOS(n)(1,1),plot_range(1);LDOS(n)($,1),plot_range(2)];
    else
        E_ind=find(LDOS(n)(:,1)>=E_range(1) & LDOS(n)(:,1)<=E_range(2));
        if dos_range==[] then
            plot_range=[min(LDOS(n)(E_ind,2)),max(LDOS(n)(E_ind,2))];
        else
            plot_range=[0,dos_range];
        end
        a.data_bounds=..
        [LDOS(n)(E_ind(1),1),plot_range(1);..
        LDOS(n)(E_ind($),1),plot_range(2)];
    end
    plot(0*ones(20,1),linspace(plot_range(1),plot_range(2),20)','k:');

    a.tight_limits='on'
    a.font_size=4
    a.thickness=3
    f=gcf();
    f.background=8;
    xlabel('Energy(eV)','fontsize',4); ylabel('PDOS',"fontsize", 4);
    if output_data=='on' then
        // numerical data
        fid=mopen(work_dir+'PDOS_plot-'+string(n)+'.dat','w');
        mfprintf(fid,strcat(repmat('%9s ',1,tot_sel_atom+2))+'\n'..
        ,['E','sum',atom_spec])
        mfprintf(fid,strcat(repmat('%9.4f ',1,length(LDOS(n)(1,:))))+'\n'..
        ,LDOS(n));
        mclose(fid);    
        
        // png files
        xs2png(n,'PDOS_plot-'+string(n)+'.png')
        
    end
end





