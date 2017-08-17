// This code can read the surface band sturcutre from WT. 
// To use it, you must download dos.dat_l, dos.dat_r
clear; clc; exec(PiLib);xdel(winsid());stacksize('max');
// parameter ===========================================================
work_dir=[]//['C:\MyDrive\Work\A2TePoO6\Ba2TePoO6\'];
task='plot';
Nk1=200; 
tot_k_seg=3;
k_label=['X','M','$\Gamma$','Y']
OmegaNum=500;

// main ================================================================
work_dir=PIL_dir_path(work_dir);
// read input.dat
if task=='read' then
    printf('Reading dos.dat_l ...\n');
    fid=mopen('dos.dat_l','r');
    ss_dos_l=mfscanf(-1,fid,'%f %f %f %f')
    mclose(fid);
    printf('Reading dos.dat_r ...\n');
    fid=mopen('dos.dat_r','r');
    ss_dos_r=mfscanf(-1,fid,'%f %f %f %f')
    mclose(fid);
    save(work_dir+'ss_dos.sod','ss_dos_l','ss_dos_r');
elseif task=='plot'
    load(work_dir+'ss_dos.sod')
    // plot ss_dos_l
    for n=1:2
        select n
        case 1
            ss_dos=ss_dos_l;
        case 2
            ss_dos=ss_dos_r;
        end
        figure(n);        
        // plot surface DOS
        Sgrayplot([1:tot_k_seg*Nk1]',..
        linspace(min(ss_dos(:,2)),max(ss_dos(:,2)),OmegaNum)'..
        ,matrix(ss_dos(:,3),OmegaNum,tot_k_seg*Nk1)');
        xset("colormap",oceancolormap(64));

        // put k-divider
        for m=1:tot_k_seg-1
            plot(Nk1*m*ones(10,1),linspace(min(ss_dos(:,2)),..
            max(ss_dos(:,2)),10)','w--','linewidth',2);  
        end

        //  plot Fermi level
        plot(linspace(1,tot_k_seg*Nk1,10)',zeros(10,1),'w--','linewidth',2)


        // tweak plot
        a=gca(); 
        a.auto_ticks=['off','on','off']
        a.tight_limits='on'; 
        b=a.x_ticks
        b(2)=[1,Nk1*linspace(1,tot_k_seg,tot_k_seg)];
        b(3)=k_label;
        a.x_ticks=b
        a.thickness=3;
        a.font_size=5;
        a.box='on'

        ylabel('Energy (eV)',"fontsize", 5);
        colorbar(min(ss_dos(:,3)),max(ss_dos(:,3)))
        if n==1 then
            title('surface-l','fontsize',4);
        elseif n==2
            title('surface-r','fontsize',4);
        end
        f=gcf();
        f.background=-2;
        f.children(1).font_size=4
    end
end



