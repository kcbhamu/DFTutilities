// this is to plot the multipole and laser files of Octopus outputs
clear; xdel(winsid());
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\CO_junc\md_cw'
plot_type='m'; // 'l'-> laser, 'm' -> multipole
fn_num='no'; // '1','2,'3', or 'no', if plot_type='m'
plot_shift='off'; // shift dipole=0 at t=0 (if plot_type='m')
T_max=120;      // max time in plot
// Main ================================================================
select plot_type
case 'l'
    fid=mopen(work_dir+'/td.general/laser','r');
    mgetl(fid,6);
    A=mfscanf(-1,fid,strcat(repmat('%f ',1,5)));
    mclose(fid);
    A_ind=max(find(A(:,2) <=T_max))
    A(:,3:$)=(1e+8)*A(:,3:$); // V/cm unit
    for n=1:3
        //subplot(3,1,n);
        figure(n)
        plot(A(1:A_ind,2),A(1:A_ind,n+2));
        a=gce(); a.children.thickness=2; 
        set(gcf(),'background',8)
        set(gca(),'thickness',4,'font_size',4);        
        ylabel('E-field (V/cm)','font_size',4); 
        xlabel('time (hbar/eV)','font_size',4); 
    end
case 'm'
    if fn_num=='no' then
        fid=mopen(work_dir+'/td.general/multipoles','r')
    else     
        fid=mopen(work_dir+'/td.general/multipoles'+'.'+string(fn_num),'r');
    end
    mgetl(fid,16);
    A=mfscanf(-1,fid,strcat(repmat('%f ',1,6)));
    mclose(fid);
    A_ind=max(find(A(:,2) <=T_max))
    for n=1:3
        //subplot(3,1,n);
        figure(n)
        select plot_shift
        case 'on'
            plot(A(1:A_ind,2),A(1:A_ind,n+3)-A(1,n+3));
            a=gce(); a.children.thickness=2;  
            plot(A(1:A_ind,2),zeros(A_ind,1),'r:');
            a=gce(); a.children.thickness=2;   
        case 'off'
            plot(A(1:A_ind,2),A(1:A_ind,n+3));
            a=gce(); a.children.thickness=2;   
            plot(A(1:A_ind,2),repmat(A(1,n+3),A_ind,1),'r:');
            a=gce(); a.children.thickness=2;  
        end
        set(gcf(),'background',8)
        set(gca(),'thickness',4,'font_size',4);        
        ylabel('Dipole (eA)','font_size',4); 
        xlabel('time (hbar/eV)','font_size',4);
        title('X'+string(n),'font_size',4)
    end
end
