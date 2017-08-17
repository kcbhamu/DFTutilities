// This code calculates the following properties of two separate compartment
// 1. total charges   
// 2. charge dfferent w/ repsect to a reference time
// 3. ac current flow through a plane
// To use it, you need to download all td.xxxxxxx. You will also need to 
// assign plane to separate two compartment. 
// Recall that, the meshs in Octopus are [Vx/h,Vy/z,Vz/h]. 
// Note that: it calculates the "charge" ! Therefore, when it comes to 
// current, it should have a reverse sign tot_charge(:,9) which dones't 
// include in the code. 
// revsed: change x,y,z order, 12/02/2015
clear; clc; xdel(winsid());
// Parameters ==========================================================
work_dir='D:\Work\CO_junction\md_cw1' // upper of td.xxxxxxxx
h_par=0.2 // h parameter used in Octopus
ref_dir='gs'       // a number or 'gs'
start_dir=0        // start dir
end_dir=80000//60000      // end dir
dir_int=50         // dir inteveral
time_step=0.002    // time step used in calculation
div_plane=[1,36];  // [axis,plane index], axis=1,2,3;
task='plot'        // 'plot' or 'run'
// Predef ==============================================================
// check input variables
if pmodulo(start_dir,dir_int)~=0 | pmodulo(end_dir,dir_int)~=0 
    disp('Error: mod(ref_dir/start_dir/end_dir, dir_int)~=0');
    abort
end

// td folder name function
function name_str=td_name_conv(name_num)
    name_str=string(name_num);
    name_str='td.'+strcat(repmat('0',1,7-length(name_str)))+name_str;
endfunction

// read reference density ==============================================
if task=='run' then
    if ref_dir=='gs'
        fid=mopen(work_dir+'/static/density.xsf','r')
    else
        fid=mopen(work_dir+'/'+td_name_conv(ref_dir)+'/density.xsf','r')
    end

    desc_lines=0
    while grep(mgetl(fid,1),'DATAGRID_3D_function')==[] 
        desc_lines=desc_lines+1
    end
    desc_lines=desc_lines+6;
    data_grid=mfscanf(1,fid,'%f %f %f')
    mgetl(fid,5)
    ref_data=mfscanf(prod(data_grid),fid,'%f');
    mclose(fid);

    // reshape ref_data to [x,y,z] ordering
    ref_data=matrix(ref_data,data_grid(1),data_grid(2),data_grid(3));
    // total charge of two part of the reference state
    ref_charge=zeros(1,2);
    select div_plane(1)
    case 1
        ref_charge(1)=sum(ref_data(1:div_plane(2),:,:))
        ref_charge(2)=sum(ref_data(div_plane(2)+1:$,:,:))
    case 2
        ref_charge(1)=sum(ref_data(:,1:div_plane(2),:))
        ref_charge(2)=sum(ref_data(:,div_plane(2)+1:$,:))
    case 3
        ref_charge(1)=sum(ref_data(:,:,1:div_plane(2)))
        ref_charge(2)=sum(ref_data(:,:,div_plane(2)+1:$))
    end

    // calculate total charge and current flows ============================
    tot_run=round((end_dir-start_dir)/dir_int)+1
    // tot_charge=[time,tot,tot1,tot2,gs_diff1,gs_diff2,td_diff1,td_diff2,flow]
    tot_charge=zeros(tot_run,9)  
    for n=1:tot_run
        tic();
        fold_num=start_dir+(n-1)*dir_int;
        fid=mopen(work_dir+'/'+td_name_conv(fold_num)+'/density.xsf','r');
        file_desc=mgetl(fid,desc_lines)
        clear read_data
        read_data=mfscanf(prod(data_grid),fid,'%f');

        // reshape to [z,y,x] ordering
        read_data=matrix(read_data,data_grid(1),data_grid(2),data_grid(3));

        // total charge of the whole system
        tot_charge(n,1)=(start_dir+(n-1)*dir_int)*0.002  //time
        tot_charge(n,2)=sum(read_data);  // total charge

        // total charge of two parts
        select div_plane(1)
        case 1  // x   
            tot_charge(n,3)=sum(read_data(1:div_plane(2),:,:));
            tot_charge(n,4)=sum(read_data(div_plane(2)+1:$,:,:));
        case 2  // y
            tot_charge(n,3)=sum(read_data(:,1:div_plane(2),:));
            tot_charge(n,4)=sum(read_data(:,div_plane(2)+1:$,:));
        case 3  // z
            tot_charge(n,3)=sum(read_data(:,:,1:div_plane(2)));
            tot_charge(n,4)=sum(read_data(:,:,div_plane(2)+1:$));
        end
        // charge difference compare to ref_data of two parts
        tot_charge(n,5:6)=tot_charge(n,3:4)-ref_charge
        // charge diff comp to last time step
        if n > 1 then
            tot_charge(n,7:8)=tot_charge(n,3:4)-tot_charge(n-1,3:4)
        end
        mclose(fid);
        disp('running folder #'+string(fold_num)+'...'+string(toc())+' sec')
    end
    tot_charge(:,2:8)=tot_charge(:,2:8)*h_par^3;

    // calculate current (muA)
    tot_charge(:,9)=(1.6022*tot_charge(:,8))/(time_step*dir_int*0.658212)*(1e+2);
    save(work_dir+'/tot_charge.sod','tot_charge')
elseif task=='plot'
    load(work_dir+'/tot_charge.sod');
end
// Plot ================================================================

figure(1)
plot(tot_charge(:,1)*0.658,tot_charge(:,8));
a=gce(); a.children.thickness=2; 
plot(tot_charge(:,1)*0.658,zeros(length(tot_charge(:,1)),1),'r:')
a=gce(); a.children.thickness=2; 
set(gcf(),'background',8)
set(gca(),'thickness',4)
set(gca(),'font_size',4);       
ylabel('charge(e)'); 
xlabel('time (fs)');
title('charge fluctation')
xsave(work_dir+'/tot_charge_flu.scg', gcf())

figure(2)
plot(tot_charge(:,1)*0.658,tot_charge(:,9));
a=gce(); a.children.thickness=2;  
plot(tot_charge(:,1)*0.658,zeros(length(tot_charge(:,1)),1),'r:');
a=gce(); a.children.thickness=2;  
set(gcf(),'background',8)
set(gca(),'thickness',4)
set(gca(),'font_size',4);   
ylabel('current (mu-A)'); 
xlabel('time (fs)');
title('AC current')
xsave(work_dir+'/tot_charge_ac.scg', gcf())

figure(3)
plot(tot_charge(:,1)*0.658,tot_charge(:,6));
a=gce(); a.children.thickness=2;  
plot(tot_charge(:,1)*0.658,zeros(length(tot_charge(:,1)),1),'r:');
a=gce(); a.children.thickness=2;  
set(gcf(),'background',8)
set(gca(),'thickness',4)
set(gca(),'font_size',4); 
ylabel('charge (e)'); 
xlabel('time (fs)');
title('charge accumulation')
xsave(work_dir+'/tot_charge_e.scg', gcf())

