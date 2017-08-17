// This code combines the pdos data calculated by w2k and plot it. 
// To use this code, you must download case.dos1ev or case.dos1evup
// and case.dos1evdn in spin polarized cases.  
clear; clc; xdel(winsid()); exec(PiLib);
// Parameter =======================================
work_dir=[]//['/home/pipidog/Works/BSCCO/w2k-sym/'];
spin_deg='on';
proj_list=list([4,6],[1,7],[3,5],[2]) // Bi4-O6, Sr1-O7, Cu3-O5, Ca2
multiplicity=[2,1,2,2,4,2,2]  // multiplicity of each column data
E_range=[-8,1]
dos_range=[]
output_dat='on'
// Main ==========================================
work_dir=PIL_dir_path(work_dir);

// read data
if spin_deg=='off' then
    flist=dir(work_dir);
    fid=mopen(work_dir+flist(2)(grep(flist(2),'.dos1ev')),'r');
    pdos=mgetl(fid,-1);
    mclose(fid);
    pdos=evstr(pdos(4:$));
elseif spin_deg=='on'
    flist=dir(work_dir);

    fid=mopen(work_dir+flist(2)(grep(flist(2),'.dos1evup')),'r');
    pdos_up=mgetl(fid,-1);
    mclose(fid);
    pdos_up=evstr(pdos_up(4:$));

    fid=mopen(work_dir+flist(2)(grep(flist(2),'.dos1evdn')),'r');
    pdos_dn=mgetl(fid,-1);
    mclose(fid);
    pdos_dn=evstr(pdos_dn(4:$));
    pdos=pdos_up+pdos_dn;
    clear pdos_up pdos_dn
end
// add multiplicity 
if length(pdos(1,:))~=(length(multiplicity)+1) then
    disp('Error: size of pdos and multiplicity are inconsistent!');
    abort;
end
for n=2:length(pdos(1,:))
    pdos(:,n)=pdos(:,n)*multiplicity(n-1)
end
// calculate combined pdos
for n=1:length(proj_list)
    cpdos=zeros(length(pdos(:,1)),length(proj_list(n))+1);
    for m=1:length(proj_list(n))
        cpdos(:,m)=pdos(:,proj_list(n)(m)+1);
        cpdos(:,$)=cpdos(:,$)+cpdos(:,m);
    end

    figure(n);
    plot(pdos(:,1),cpdos,'thickness',3);
    legend(['column-'+string(proj_list(n)),'sum'],2);

    a=gca();
    if E_range==[] then
        if dos_range==[] then
            plot_range=[min(cpdos(:,$)),max(cpdos(:,$))];
        else
            plot_range= plot_range=[0,dos_range];
        end
        a.data_bounds=..
        [pdos(1,1),plot_range(1);pdos($,1),plot_range(2)];
    else
        E_ind=find(pdos(:,1)>=E_range(1) & pdos(:,1)<=E_range(2));
        if dos_range==[] then
            plot_range=[min(cpdos(E_ind,$)),max(cpdos(E_ind,$))];
        else
            plot_range=[0,dos_range];
        end
        a.data_bounds=..
        [pdos(E_ind(1),1),plot_range(1);..
        pdos(E_ind($),1),plot_range(2)];
    end
    plot(0*ones(20,1),linspace(plot_range(1),plot_range(2),20)','k:');

    a.tight_limits='on'
    a.font_size=4
    a.thickness=3
    f=gcf();
    f.background=8;
    xlabel('Energy(eV)','fontsize',4); ylabel('PDOS',"fontsize", 4);
    if output_dat=='on' then
        fid=mopen(work_dir+'PDOS_plot-'+string(n)+'.dat','w');
        mfprintf(fid,strcat(repmat('%9s ',1,length(proj_list(n))+2))+'\n'..
        ,['E','pdos-'+string(proj_list(n)),'sum'])
        mfprintf(fid,strcat(repmat('%9.4f ',1,length(proj_list(n))+2))+'\n'..
        ,[pdos(:,1),cpdos]);
        mclose(fid);    
    end
end

