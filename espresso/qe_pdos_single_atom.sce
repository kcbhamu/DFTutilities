// This code plot the PDOS calculated from Quantum espresso
clear; clc; exec(PiLib); xdel(winsid());
// Parameters ==========================================================
work_dir=[]//'C:\MyDrive\Work\BSCCO\PDOS-org\'; // working folder
Ef=10.6184;   // Fermi level 
atom_label=2; // atom label
dos_range=[1]//1; // set the max pdos value for plot, []: default
Ef_shift='on' // whether to shift Ef to zero
plot_comb='on'
data_output='on'
// Main ================================================================
work_dir=PIL_dir_path(work_dir);

// search for assigned file name
dir_file=dir(work_dir);
fn_ind=grep(dir_file(2),['atm#'+string(atom_label)+'(']);

for n=1:length(fn_ind)
    fid=mopen(work_dir+dir_file(2)(fn_ind(n)),'r');
    // search for orbital name
    tmp1=strsplit(dir_file(2)(fn_ind(n)));
    tmp2=find(tmp1=='#');
    atm_name=strcat(tmp1(tmp2(1)+1:tmp2(2)-5));
    orb_name=strcat(tmp1(tmp2(2)+1:$));

    // plot dos
    tot_col=length(find(strsplit(mgetl(fid,1))=='_'))+2;
    pdos=mfscanf(-1, fid,strcat(repmat('%f ',1,tot_col)));
    if Ef_shift=='on' then
        pdos(:,1)=pdos(:,1)-Ef
        Ef_plot=0;
    else
        Ef_plot=Ef;
    end
    mclose(fid);
    
    select plot_comb
    case 'on'
        subplot(2,ceil(length(fn_ind)/2),n);
    case 'off'
        figure(n);
    else
        disp('Error!')
        abort
    end

    plot(pdos(:,1),pdos(:,2:tot_col),'thickness',3);
    legend(['tot_dos',string(1:tot_col-2)])
    if dos_range==[] then
        plot_range=[min(pdos(:,2)),max(pdos(:,2))];        
    else
        plot_range=[0,dos_range];
    end
    plot(Ef_plot*ones(20,1),linspace(plot_range(1),plot_range(2),20)','k:');
    a=gca();
    a.data_bounds=[pdos(1,1),plot_range(1);pdos($,1),plot_range(2)];
    a.tight_limits='on'
    a.font_size=4
    a.thickness=3
    f=gcf();
    f.background=8;
    title(atm_name+' / '+orb_name,'fontsize',4); 
    xlabel('Energy(eV)','fontsize',4); ylabel('PDOS',"fontsize", 4);
end



