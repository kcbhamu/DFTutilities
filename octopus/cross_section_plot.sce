// This if the postprocess code of Octopus. 
clear; clc; xdel(winsid());
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\CO_junc\Ag_junc'
plot_type='t'; // 't'--> tensor, 'v' --> vector
vect_component=1; // 1~3, only if plot_type='v'
fn_num='off'; // if plot_type='v'
val_abs='on'; // if abs results, if 'on', just FT-components! no physical.
E_max=5;

// Main ================================================================
cd(work_dir);
// check file existence
select plot_type
case 't'
    fid=mopen(work_dir+'\'+'cross_section_tensor','r');
    mgetl(fid,12);
    A=mfscanf(-1,fid,strcat(repmat('%f ',1,12)));
    mclose(fid);
    A(:,2:$)=100*A(:,2:$); // Mb unit
    E_ind=max(find(A(:,1) <=E_max));
    // average
    figure(1);
    plot(A(1:E_ind,1),A(1:E_ind,2));
    a=gce(); a.children.thickness=2;  
    set(gcf(),'background',8)
    set(gca(),'thickness',4,'font_size',4);        
    title('S-avg','font_size',4);
    xlabel('Energy (eV)','font_size',4); 
    ylabel('sigma (Mb)','font_size',4);
    // each component
    figure(2)    
    plot_column=[4,8,12];
    plot_title=['S-11','S-22','S-33'];
    for n=1:3
        subplot(3,1,n);    
        plot(A(1:E_ind,1),A(1:E_ind,n*4));
        a=gce(); a.children.thickness=2;  
        set(gcf(),'background',8)
        set(gca(),'thickness',4,'font_size',4);        
        title(plot_title(n),'font_size',4');
        ylabel('sigma (Mb)','font_size',4);
    end
    xlabel('Energy (eV)','font_size',4); 


    // anisotropy 
    figure(3);
    plot(A(1:E_ind,1),A(1:E_ind,3));
    a=gce(); a.children.thickness=2;   
    xlabel('Energy (eV)','fontsize',4);
    ylabel('Anisotropy (Mb)','fontsize',4)
    set(gcf(),'background',8)
    set(gca(),'thickness',4,'font_size',4);
case 'v'
    if fn_num=='on'
        fid=mopen(work_dir+'\'+'cross_section_vector.'...
        +string(vect_component),'r');
    elseif fn_num=='off'
        fid=mopen(work_dir+'\'+'cross_section_vector','r');
    end
    mgetl(fid,24);
    A=mfscanf(-1,fid,strcat(repmat('%f ',1,5)));
    mclose(fid);
    A(:,2:4)=100*A(:,2:4); // Mb unit
    E_ind=max(find(A(:,1) <=E_max));
    if val_abs=='on'
        A(:,2:5)=abs(A(:,2:5));
    end
    figure(1);
    plot(A(1:E_ind,1),A(1:E_ind,1+vect_component));
    a=gce(); a.children.thickness=2;   
    xlabel('Energy (eV)','fontsize',4);
    ylabel('sigma (Mb)','fontsize',4)
    set(gcf(),'background',8)
    set(gca(),'thickness',4,'font_size',4);
    
    figure(2);
    plot(A(1:E_ind,1),A(1:E_ind,5));
    a=gce(); a.children.thickness=2;   
    xlabel('Energy (eV)','fontsize',4);
    ylabel('Strength Func(eV)','fontsize',4)
    set(gcf(),'background',8)
    set(gca(),'thickness',4,'font_size',4);
end
