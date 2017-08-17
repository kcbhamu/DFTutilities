// This code plots the impurity spectral functional of CTQMC results
// To use it, you must download "optimal_spectral_function_*.dat"
clear; clc; xdel(winsid());exec(PiLib);
// parameters ====================================================
work_dir=[];
task='hub1' // 'ctqmc' / 'hub1'
E_bound=[-10,+10]
// main ==========================================================
work_dir=PIL_dir_path(work_dir);
flist=dir(work_dir);
select task
case 'ctqmc'
    findex=grep(flist(2),'/optimal_spectral_function_/','r');
    for n=1:length(findex)
        fid=mopen(flist(2)(findex(n)),'r');
        data=mfscanf(-1,fid,'%f %f');
        mclose(fid);
        data(:,1)=data(:,1);
        figure(n)
        plot(data(:,1),data(:,2),'thickness',3)

        set(gcf(),'background',8);
        set(gca(),'font_size',4);
        set(gca(),'tight_limits','on');
        set(gca(),'thickness',4);
        set(gca(),'data_bounds',[E_bound(1), 0;E_bound(2), max(data(:,2))])
        xlabel('eV','fontsize',4); ylabel('arb. unit',"fontsize", 4);
        title('CTQMC impurity spectral function','fontsize',4);
        plot(zeros(10,1),linspace(0,max(data(:,2)),10)','k:')
        e=gce(); e.children.thickness=1;
    end
case 'hub1'
    spf_atom=list();
    for n=1:length(length(flist(2)))
        if length(grep(flist(2)(n),'SpFunc'))~=0 then
            if length(grep(flist(2)(n),'iatom'))~=0 then
                at_ind=evstr(part(flist(2)(n),..
                length(flist(2)(n))-3:length(flist(2)(n))))
                fid=mopen(flist(2)(n),'r');
                mgetl(fid,2);
                spf_atom(at_ind)=mfscanf(-1,fid,'%f  %f');
                mclose(fid);
                spf_atom(at_ind)(:,1)=spf_atom(at_ind)(:,1)*27.2;

                // plot figures
                figure(at_ind);
                plot(spf_atom(at_ind)(:,1),spf_atom(at_ind)(:,2),..
                'thickness',3)
                set(gcf(),'background',8);
                set(gca(),'font_size',4);
                set(gca(),'tight_limits','on');
                set(gca(),'thickness',4);
                title('Spectrum Func-atom'+string(at_ind),'fontsize',4); 
                xlabel('Energy (eV)','fontsize',4); 
                ylabel('spectral',"fontsize", 4);
                plot(zeros(10,1),..
                linspace(0,max(spf_atom(at_ind)(:,2)),10)','k:')
                e=gce(); e.children.thickness=1;
                xs2png(at_ind,'Hub1-atom'+string(at_ind)+'.png');
            else
                fid=mopen(flist(2)(n),'r');
                spf=mfscanf(-1,fid,'%f  %f');
                mclose(fid);
                spf(:,1)=spf(:,1)*27.2

                // plot figures
                figure(0)
                plot(spf(:,1),spf(:,2),'thickness',3)
                set(gcf(),'background',8);
                set(gca(),'font_size',4);
                set(gca(),'tight_limits','on');
                set(gca(),'thickness',4);
                title('Spectrum Fruc-all','fontsize',4); 
                xlabel('Energy (eV)','fontsize',4); 
                ylabel('spectral',"fontsize", 4);
                plot(zeros(10,1),linspace(0,max(spf(:,2)),10)','k:');
                e=gce(); e.children.thickness=1;
                xs2png(0,'Hub1-all.png');
            end
        end       
    end
end

