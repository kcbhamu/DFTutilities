// This code calculate the charge density differece bwtween td states
// note: the output must be in xsf format. After the calculation, this
// code will generat another file named "density_diff.xsf" so you can
// visualize the result by xcrysden. To use it, you must download all
// 'td.xxxxxxx' and 'static' folders  
// [Note]:
// total charge= h^(3)*sum(all density in space) 
// data_grid=[(Vx/h)+1,(Vy/h)+1,(Vz/h)+1]
clear; clc; xdel(winsid());
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\CO_junc\cw_test1' // upper of td.xxxxxxxx
ref_dir='gs'       // a number or 'gs'
start_dir=14800
end_dir=16800
dir_int=50
// Main ================================================================
// read other density
if pmodulo(start_dir,dir_int)~=0 | pmodulo(end_dir,dir_int)~=0 
    disp('Error: mod(ref_dir/start_dir/end_dir, dir_int)~=0');
    abort
end
// td folder name function
function name_str=td_name_conv(name_num)
    name_str=string(name_num);
    name_str='td.'+strcat(repmat('0',1,7-length(name_str)))+name_str;
endfunction

// read reference density
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
mclose(fid)

// calculate charge density difference
for n=1:round((end_dir-start_dir)/dir_int)+1
    tic();
    // read data
    fid=mopen(work_dir+'/'+td_name_conv(start_dir+(n-1)*dir_int)+..
    '/density.xsf','r');
    file_desc=mgetl(fid,desc_lines)
    run_data=mfscanf(prod(data_grid),fid,'%f');
    run_data=run_data-ref_data
    mclose(fid)
    // output density difference
    fid=mopen(work_dir+'/'+td_name_conv(start_dir+(n-1)*dir_int)..
    +'/density_diff.xsf','w');
    mputl(file_desc,fid);
    mfprintf(fid,'        %18.15f\n',run_data);
    mputl('END_DATAGRID3D',fid);
    mputl('END_BLOCK_DATAGRID3D',fid);
    mclose(fid);   
    disp('running folder #'+string(start_dir+(n-1)*dir_int)+'...'..
    +string(toc())+' sec')  
end

