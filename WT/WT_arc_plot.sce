// This code is to plot the Fermi arcs output by Wannier Tools
// Besides, this code also helps you locate the positions of a particular
// area of the plot. 
// To use it, you must download 'arc.dat_l, arc.dat_r and input.dat 
// if want to plot spintexture, also need 'spindos.dat'
clear; clc; xdel(winsid());exec(PiLib);
// Parameters ========================================
work_dir=[]//['C:\MyDrive\Work\Sr2ReAuO6\arc-full\'];
arc_bulk_plot='off' // arc.dat_bulk
arc_plot='on' // arc.dat_l, arc.dat_r
spin_plot='off' // spindos.dat
spin_filter=[2.0,2]; // fliter to plot spin texure [dos_value, k_interval], 
jdos_plot='off' // arc.jdat_l, arc.jdat_r, arc.jsdat_l, arc.jsdat_r
frac_cal='off'
range_cal=[75,75;130 130];
save_fig='png' // 'scg', 'png' ,'off'
// Main ============================================

// Parse input file -----------------------------------------------------
work_dir=PIL_dir_path(work_dir);
fid=mopen(work_dir+'input.dat','r');
inp_data=mgetl(fid,-1);
mclose(fid);

Nk1_ind=grep(inp_data,'Nk1');
Nk1=msscanf(1,part(inp_data(Nk1_ind)..
,strindex(inp_data(Nk1_ind),'=')+1:length(inp_data(Nk1_ind))),'%f');

Nk2_ind=grep(inp_data,'Nk2');
Nk2=msscanf(1,part(inp_data(Nk2_ind)..
,strindex(inp_data(Nk2_ind),'=')+1:length(inp_data(Nk1_ind))),'%f')

lat_par_ind=grep(inp_data,'LATTICE');
lat_par=msscanf(3,inp_data(lat_par_ind+2:lat_par_ind+4),'%f %f %f');

surf_par_ind=grep(inp_data,'SURFACE');
surf_par=msscanf(3,inp_data(surf_par_ind+1:surf_par_ind+3),'%f %f %f');

kslab_par_ind=grep(inp_data,'KPLANE_SLAB');
kslab_par=msscanf(3,inp_data(kslab_par_ind+1:kslab_par_ind+3),'%f %f');

// calculate reciprocal lattice vectors for slab
kslab=PIL_red_BZ_vec(surf_par*lat_par);
kslab_org=kslab_par(1,:)*kslab;
kslab_v1=kslab_par(2,:)*kslab;
kslab_v2=kslab_par(3,:)*kslab;

// angle between two basis
ang_v1v2=acos(kslab_v1*kslab_v2'/(norm(kslab_v1)*norm(kslab_v2)))/%pi*180;
unit_v1=[1 0];
unit_v2=[cos(ang_v1v2) sin(ang_v1v2)];

// generate k-path data
[k1_pt,k_path_div]=PIL_k_path([kslab_org;kslab_org+kslab_v1],Nk1);
[k2_pt,k_path_div]=PIL_k_path([kslab_org;kslab_org+kslab_v2],Nk2); 
printf('\n');

// plot bulk spectrum --------------------------------------------------
if arc_bulk_plot=='on' then
    fid=mopen(work_dir+'arc.dat_bulk','r');
    arc_bulk=mfscanf(-1,fid,'%f %f %f');    
    mclose(fid);
    x_pt=arc_bulk(1:Nk2:$,1);
    y_pt=arc_bulk(1:Nk2,2);
    if find(abs(k1_pt(:,1)-x_pt)>=1e-5)~=[]
        disp('Error: k1_pt(:,1) and arc x_pt are inconsistent!');
    end
    if find(abs(k2_pt(:,2)-y_pt)>=1e-5)~=[]
        disp('Error: k2_pt(:,1) and arc y_pt are inconsistent!');
    end    
    figure(0);  

    Sgrayplot([1:Nk1]',[1:Nk2]',matrix(arc_bulk(:,3),Nk2,Nk1)');
    xset("colormap",hotcolormap(64));
    colorbar(min(arc_bulk(:,3)),max(arc_bulk(:,3)));
    title('arc-bulk','fontsize',4);

    f=gcf();
    f.background=-2;

    a=gca(); a.tight_limits='on';
    a.thickness=3;
    a.font_size=3;
    a.box='on';
    select save_fig
    case 'scg'
        xsave(work_dir+'arc-bulk.scg')
    case 'png'
        xs2png(0,work_dir+'arc-bulk.png')
    case 'off'

    end 
end

// plot Fermi arc -----------------------------------------------------------
if arc_plot=='on' then
    f_name=['arc.dat_l','arc.dat_r'];
    for n=1:2
        fid=mopen(work_dir+f_name(n),'r');
        arc_dat=mfscanf(-1,fid,'%f %f %f %f');    
        mclose(fid);

        // check if data are consistent with input
        x_pt=arc_dat(1:Nk2:$,1);
        y_pt=arc_dat(1:Nk2,2);
        if find(abs(k1_pt(:,1)-x_pt)>=1e-5)~=[]
            disp('Error: k1_pt(:,1) and arc x_pt are inconsistent!');
        end
        if find(abs(k2_pt(:,2)-y_pt)>=1e-5)~=[]
            disp('Error: k2_pt(:,1) and arc y_pt are inconsistent!');
        end        
        arc_dat(:,4)=exp(arc_dat(:,4));
        //arc_dat(:,4)=log(exp(arc_dat(:,3))-exp(arc_bulk(:,3)))
        // plot arc data
        title_text=['L-all','L-surf','R-all','R-surf']
        for m=1:2
            figure(2*(n-1)+m);
            Sgrayplot([1:Nk1]',[1:Nk2]',matrix(arc_dat(:,2+m),Nk2,Nk1)');            

            xset("colormap",hotcolormap(64));
            xlabel('Axis-1','fontsize',4); ylabel('Axis-2',"fontsize", 4);
            colorbar(min(arc_dat(:,2+m)),max(arc_dat(:,2+m)))
            title('surface-'+title_text(2*(n-1)+m),'fontsize',4);

            f=gcf();
            f.background=-2;

            a=gca(); a.tight_limits='on';
            a.thickness=3;
            a.font_size=3;
            a.box='on';
            select save_fig
            case 'scg'
                xsave(work_dir+'arc-'+title_text(2*(n-1)+m)+'.scg')
            case 'png'
                xs2png(2*(n-1)+m,work_dir+'arc-'+title_text(2*(n-1)+m)+'.png')
            case 'off'

            end

        end
    end
    printf('check variables k1_pt and k2_pt for their values!');
end

// plot spin texture --------------------------------------------------------
if spin_plot=='on' then
    fid=mopen(work_dir+'spindos.dat','r');
    mgetl(fid,1);
    spin_dat=mfscanf(-1,fid,strcat(repmat('%f ',1,6))+' \n');
    mclose(fid);

    // check if data are consistent with input
    x_pt=spin_dat(1:Nk2:$,1);
    y_pt=spin_dat(1:Nk2,2);
    if find(abs(k1_pt(:,1)-x_pt)>=1e-5)~=[]
        disp('Error: k1_pt(:,1) and spin x_pt are inconsistent!');
    end
    if find(abs(k2_pt(:,2)-y_pt)>=1e-5)~=[]
        disp('Error: k2_pt(:,1) and spin y_pt are inconsistent!');
    end  

    // pick points to plot
    spin_dat(:,1:2)=PIL_nest_loop([1,Nk1;1,Nk2]);
    spin_sel=spin_dat(..
    find(pmodulo(spin_dat(:,1),spin_filter(2))==0..
    & pmodulo(spin_dat(:,2),spin_filter(2))==0..
    & spin_dat(:,3)>= spin_filter(1)),:);

    tot_spin_sel=length(spin_sel(:,1));
    spin_sel=cat(2,spin_sel,zeros(tot_spin_sel,1));
    for n=1:tot_spin_sel
        spin_sel(n,7)=norm(spin_sel(n,4:6));
    end
    spin_sel(:,4:7)=spin_filter(2)*spin_sel(:,4:7)/max(spin_sel(:,7));

    // prepare spin plot data
    spin_plot=zeros(2*tot_spin_sel,3);
    for n=1:tot_spin_sel
        if spin_sel(n,6) >=0 then
            spin_plot(2*n-1,:)=[spin_sel(n,1:2),0];
            spin_plot(2*n,:)=[spin_sel(n,1:2),0]+spin_sel(n,4:6);
        else
            spin_plot(2*n-1,:)=[spin_sel(n,1:2),0,]+abs(spin_sel(n,4:6));
            spin_plot(2*n,:)=[spin_sel(n,1:2),0,];
        end
    end

    figure(5);
    Sgrayplot([1:Nk1]',[1:Nk2]',matrix(spin_dat(:,3),Nk2,Nk1)');
    try
        xarrows(spin_plot(:,1),spin_plot(:,2),spin_plot(:,3));
    catch
        xarrows(spin_plot(:,1),spin_plot(:,2));
    end
    xset("colormap",hotcolormap(64));
    e=gce();
    e.thickness=2; e.arrow_size=3*spin_filter(2);

    xlabel('Axis-1','fontsize',4); ylabel('Axis-2',"fontsize", 4);
    colorbar(min(spin_dat(:,3)),max(spin_dat(:,3)))

    f=gcf();
    f.background=-2;

    a=gca(); a.tight_limits='on';
    a.thickness=3;
    a.font_size=3;
    a.box='on';
    select save_fig
    case 'png'
        xs2png(5,work_dir+'spin_texture.png');
    case 'scg'
        xsave(work_dir+'spin_texture.scg');
    case 'off'

    end 
end

// plot jdos -----------------------------------------------------------
if jdos_plot=='on' then
    prefix=['jdat_l','jdat_r','jsdat_l','jsdat_r']
    for n=1:length(length(prefix))
        fid=mopen(work_dir+'arc.'+prefix(n),'r');
        jdos=mfscanf(-1,fid,'%f %f %f');    
        mclose(fid);
        x_pt=jdos(1:Nk2:$,1);
        y_pt=jdos(1:Nk2,2);
        if find(abs(k1_pt(:,1)-x_pt)>=1e-5)~=[]
            disp('Error: k1_pt(:,1) and jdos x_pt are inconsistent!');
        end
        if find(abs(k2_pt(:,2)-y_pt)>=1e-5)~=[]
            disp('Error: k2_pt(:,1) and jdos y_pt are inconsistent!');
        end    
        figure(5+n);    
        Sgrayplot([1:Nk1]',[1:Nk2]',matrix(jdos(:,3),Nk2,Nk1)');
        xset("colormap",hotcolormap(64));
        colorbar(min(jdos(:,3)),max(jdos(:,3)));
        title('arc-'+prefix(n),'fontsize',4);

        f=gcf();
        f.background=-2;

        a=gca(); a.tight_limits='on';
        a.thickness=3;
        a.font_size=3;
        a.box='on';
        select save_fig
        case 'scg'
            xsave(work_dir+prefix(n)'+'.scg')
        case 'png'
            xs2png(5+n,work_dir+prefix(n)'+'.png')            
        end
    end
end
// plot jsdos ----------------------------------------------------------

// calculate focus parameters ------------------------------------------
if frac_cal=='on' then
    range_cal=(range_cal-1)./repmat([Nk1,Nk2],2,1);
    O_pt=kslab_par(1,:)+range_cal(1,:)*kslab_par(2:3,:);
    v1=(range_cal(2,1)-range_cal(1,1))*kslab_par(2,:);
    v2=(range_cal(2,2)-range_cal(1,2))*kslab_par(3,:);

    printf('\n');
    printf('Orgin Point (fractional):\n');
    printf('%f %f \n\n',O_pt);
    printf('V1 (fractional):\n');
    printf('%f %f \n\n',v1);
    printf('V2 (fractional):\n');
    printf('%f %f \n\n',v2);
    printf('Suggested mesh ratio:\n');
    printf('%4.2f : 1.00\n\n',norm(v1*kslab)/norm(v2*kslab));
    printf('copy and paste format:\n');
    printf('%f  %f \n',[O_pt;v1;v2]);
end
