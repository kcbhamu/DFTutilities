clear; clc; exec(PiLib); stacksize('max');
// paremeters =========================================
work_dir=['/home/pipidog/Works/TaAs/w90_test'];
file_title='TaAs.w90'
task='run'  //'read' / 'run'
//Main =============================================
work_dir=PIL_dir_path(work_dir);
select task
case 'read'
    fid=mopen(work_dir+file_title+'.amn','r');
    mgetl(fid,1);
    ban_num=mfscanf(1,fid,'%i %i %i');
    a_mat=mfscanf(-1,fid,'%i %i %i %f %f');
    mclose(fid);

    a_mat=matrix(a_mat(:,4)+%i*a_mat(:,5),ban_num(1),ban_num(3),ban_num(2));
    save(work_dir+'a_mat.sod','a_mat');
case 'run'
    load(work_dir+'a_mat.sod');
    a_size=size(a_mat)
    for n=1:a_size(2)
        disp(norm(a_mat(:,n,1)))
    end
end

