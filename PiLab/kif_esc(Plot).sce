// This code is to plot the output data of kif_esc. To use it, you must
// prepare project_kif_esc.sod file. 
clear; clc; xdel(winsid());exec(PiLib);
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\PiLab_projects\Sr2ReAuO6'
project_name='Sr2ReAuO6'
plot_range=[]//[70 130;70 130] // range of the plot
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
load(work_dir+project_name+'_kif_esc.sod');

printf('  => plotting calculated data\n');
esc_pdos=zeros(prod(kif_esc.k_mesh),1);
BZ_mesh=kif_esc.k_mesh(kif_esc.k_mesh~=1);
for n=1:length(kif_esc.k_weight(1,:))-1;
    esc_pdos(kif_esc.k_weight(:,1))=kif_esc.k_weight(:,n+1);
    figure(n);
    if plot_range==[] then
        Sgrayplot(1:BZ_mesh(1),1:BZ_mesh(2),..
        matrix(esc_pdos,BZ_mesh(2),BZ_mesh(1))');
    else
        tmp=matrix(esc_pdos,BZ_mesh(2),BZ_mesh(1))';
        Sgrayplot(plot_range(1,1):plot_range(1,2)..
        ,plot_range(2,1):plot_range(2,2),..
        tmp(plot_range(1,1):plot_range(1,2),plot_range(2,1):plot_range(2,2)));
    end
    xset("colormap",flipdim(oceancolormap(64),1));
    if n==1 then
        title('Energy Surface Cut DOS','fontsize',4);
    else
        title('Energy Surface Cut PDOS-'+string(n-1),'fontsize',4);
    end

    xlabel('Axis-1','fontsize',4); ylabel('Axis-2',"fontsize", 4);
    colorbar(min(esc_pdos),max(esc_pdos))

    f=gcf();
    f.background=-2;

    a=gca(); a.tight_limits='on';
    a.thickness=3;
    a.font_size=3;
    a.box='on';

    xsave(work_dir+project_name+'_kif_esc_p'+string(n)+'.scg');
    disp('     Output plot '+project_name..
    +'_kif_esc_p'+string(n)+'.scg saved');
end



