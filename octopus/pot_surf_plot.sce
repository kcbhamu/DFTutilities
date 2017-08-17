// This code read the KS potential and plot it potentiral profile along
// a particle direction
clear;clc; xdel(winsid())
// Parameter ===========================================================
work_dir='C:\MyDrive\Work\CO_junc\md_cw1' // upper of td.xxxxxxxx
h_par=0.2 // h parameter used in Octopus
target_dir=5000        // number of target folder
pot_type='Vks' // Vks, V0, Vh, Vxc, 
pot_line=[2,26;3,26];  // [axis1,val1;axis2,val2]
line_filt=-20;
pot_surf=[2,26];  //[axis, layer]
surf_filt=-25;
// Predef functions ====================================================
// td folder name function
function name_str=td_name_conv(name_num)
    name_str=string(name_num);
    name_str='td.'+strcat(repmat('0',1,7-length(name_str)))+name_str;
endfunction

// Main ================================================================
// read Vks data
fid=mopen(work_dir+'/'+td_name_conv(target_dir)+'/'+pot_type+'.xsf','r');
desc_lines=0
while grep(mgetl(fid,1),'DATAGRID_3D_function')==[] 
    desc_lines=desc_lines+1
end
desc_lines=desc_lines+6;
data_grid=mfscanf(1,fid,'%f %f %f');
mgetl(fid,5)
Vks_data=mfscanf(prod(data_grid),fid,'%f');
mclose(fid);

// read Vext data 
fid=mopen(work_dir+'/'+td_name_conv(target_dir)+'/'+'scalar_pot-1.xsf','r');
desc_lines=0
while grep(mgetl(fid,1),'DATAGRID_3D_function')==[] 
    desc_lines=desc_lines+1
end
desc_lines=desc_lines+6;
data_grid=mfscanf(1,fid,'%f %f %f');
mgetl(fid,5)
Vext_data=mfscanf(prod(data_grid),fid,'%f');
mclose(fid);

//Vtot_data=Vks_data+Vext_data;
Vtot_data=Vks_data
// reshape Vtot_data to [x,y,z] ordering
Vtot_data=matrix(Vtot_data,data_grid(1),data_grid(2),data_grid(3));

// plot potetial line
if prod(pot_line(:,1)==[1,2]')==1 then
    x=1:data_grid(3);
    val=squeeze(Vtot_data(pot_line(1,2),pot_line(2,2),:));
elseif prod(pot_line(:,1)==[1,3]')==1 
    x=1:data_grid(2);
    val=squeeze(Vtot_data(pot_line(1,2),:,pot_line(2,2)))
elseif prod(pot_line(:,1)==[2,3]')==1
    x=1:data_grid(1);
    val=squeeze(Vtot_data(:,pot_line(1,2),pot_line(2,2)))
end
val(val<=line_filt)=line_filt
figure(1)
plot(x,val);
a=gce(); a.children.thickness=2; 
set(gcf(),'background',8)
set(gca(),'thickness',4)
set(gca(),'font_size',4); 
 
 
// plot potential surface
select pot_surf(1)
case 1
    ax1=1:data_grid(2);
    ax2=1:data_grid(3);
    val=squeeze(Vtot_data(pot_surf(2),:,:));
case 2
    ax1=1:data_grid(1);
    ax2=1:data_grid(3);
    val=squeeze(Vtot_data(:,pot_surf(2),:));
case 3
    ax1=1:data_grid(1);
    ax2=1:data_grid(2);
    val=squeeze(Vtot_data(:,:,pot_surf(2)));   
end
val(val<=surf_filt)=surf_filt
figure(2)
xset("colormap", hotcolormap(64))
Sgrayplot(ax1,ax2,val);
a=gce(); a.children.thickness=2; 
a=gcf(); a.background=64;
colorbar(min(val),max(val))

