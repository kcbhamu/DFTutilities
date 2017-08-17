// This program plot the PAW PDOS calculated by abinit
// To use this code, the parameters in abinit must be:
//prtdos 3           # calculate projected dos
//prtdosm 0          # print pdos to m-component
//pawprtdos 0/1      # calculate three contributions respectively

clear; clc; exec(PiLib); xdel(winsid())

// Parameter ===========================================================
work_dir=[];
task='plot' // 'plot' / 'read'
pawprtdos=1; // the pawprtdos variable used in your input files (0 or 1). 
at_idx=1;
E_bound=[-15.1,15.1] // values depending on E_shift (in unit of eV);
DOS_norm='off'
charge_part='ae' //'loc', 'pw', 'ae', 'pseudo'
save_png='on'
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
select task
case 'read'
    flist=dir(work_dir);
    at_idx=strcat(repmat('0',1,4-length(string(at_idx))))+string(at_idx);
    fid=mopen(work_dir+flist(2)(grep(flist(2),at_idx)),'r');
    fdata=mgetl(fid,-1);
    mclose(fid);
    [nv,s,E_Fermi]=msscanf(1,fdata(8),'%16c %f');
    //E_Fermi=0
    PDOS=list();
    // check if spin DOF
    if grep(fdata,'Spin-dn DOS')~=[] then
        select pawprtdos
        case 1
            PDOS(1)=evstr(fdata(24:grep(fdata,'Spin-dn DOS')-2));// up
            PDOS(2)=evstr(fdata(grep(fdata,'Spin-dn DOS')+9:$)); //dn
            PDOS(1)(:,1)=(PDOS(1)(:,1)-E_Fermi)*27.2;
            PDOS(2)(:,1)=(PDOS(2)(:,1)-E_Fermi)*27.2;
        case 0
            PDOS(1)=evstr(fdata(20:grep(fdata,'Spin-dn DOS')-2));// up
            PDOS(2)=evstr(fdata(grep(fdata,'Spin-dn DOS')+9:$)); //dn
            PDOS(1)(:,1)=(PDOS(1)(:,1)-E_Fermi)*27.2;
            PDOS(2)(:,1)=(PDOS(2)(:,1)-E_Fermi)*27.2;
        end
    else
        select pawprtdos
        case 1
            PDOS(1)=evstr(fdata(24:$));
            PDOS(1)(:,1)=(PDOS(1)(:,1)-E_Fermi)*27.2;    
        case 0
            PDOS(1)=evstr(fdata(20:$));
            PDOS(1)(:,1)=(PDOS(1)(:,1)-E_Fermi)*27.2;    
        end

    end
    save(work_dir+'PDOS.sod','PDOS');
case 'plot'
    load(work_dir+'PDOS.sod');
    select length(PDOS) 
    case 1
        plot_title=['PDOS']
    case 2
        plot_title=['PDOS-up','PDOS-dn','PDOS-all']
        PDOS(3)=zeros(PDOS(1));
        PDOS(3)(:,1)=PDOS(1)(:,1);
        PDOS(3)(:,2:$)=PDOS(1)(:,2:$)+PDOS(2)(:,2:$);
    end

    select pawprtdos
    case 1
        select charge_part
        case 'loc'
            c_range=[2:6]
        case 'pw'
            c_range=[7:11]
        case 'ae'
            c_range=[12:16]
        case 'pseudo'
            c_range=[17:21]
        end
    case 0
        c_range=[2:6]
    end

    for n=1:length(PDOS)
        E_range=find(PDOS(n)(:,1)>=E_bound(1) & PDOS(n)(:,1)<=E_bound(2));
        E_range=[min(E_range),max(E_range)];
        if DOS_norm=='on' then
            renorm=max(PDOS(n)(E_range(1):E_range(2),c_range));
        else
            renorm=1
        end
        figure(n);
        plot(PDOS(n)(E_range(1):E_range(2),1),..
        PDOS(n)(E_range(1):E_range(2),c_range)/renorm,'thickness',4);
        legend(['l=0','l=1','l=2','l=3','l=4'])
        plot(zeros(10,1),..
        linspace(0,max(PDOS(n)(E_range(1):E_range(2),c_range))/renorm,10)','k:')
        title(plot_title(n),'fontsize',4);
        set(gcf(),'background',8);
        set(gca(),'font_size',4);
        set(gca(),'tight_limits','on');
        set(gca(),'thickness',3);
        if save_png=='on' then
            xs2png(n,'PDOS-'+string(n)+'.png');
        end
    end
end




