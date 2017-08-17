// This code is to submit wien2k job in parallel 
clear; clc; exec(PiLib);

// Main =====================================================================
home_dir=PIL_dir_path(unix_g('echo ~'));
fid=mopen(home_dir+'w2k_node.log');
work_dir=PIL_dir_path(mgetl(fid,1));
get_node=mgetl(fid,1);
get_core=','+mgetl(fid,1)+',';
mclose(fid);

//get_node='c1-57,c4-[32-38,40],c5-62'
//get_core=',8,8,4(x3),16(x2),6,7,8,'

// node list
c_loc=strindex(get_node,'c');
tot_c=length(c_loc);
node_list=[];
for n=1:tot_c
    if n==tot_c then
        node_str=part(get_node,c_loc(n):$);
    else
        node_str=part(get_node,c_loc(n):c_loc(n+1)-2)
    end
    node_ini=part(node_str,1:2);
    
    if grep(node_str,'[')==[]
        node_list=cat(2,node_list,node_str);
    else
        tmp=strsplit(part(node_str,5:$-1));
        tmp(find(tmp=='-'))=':';
        node_list=cat(2,node_list,node_ini+'-'+string(evstr(strcat(tmp))));
    end
end

// core list
c_loc=strindex(get_core,',');
core_num=[];
for n=1:length(c_loc)-1
    core_val=part(get_core,c_loc(n)+1:c_loc(n+1)-1);
    if grep(core_val,'x')~=[]
        tmp=msscanf(core_val,'%d(x%d)');
        core_num=cat(2,core_num,repmat(tmp(1),1,tmp(2)));
    else
        core_num=cat(2,core_num,msscanf(core_val,'%d'));
    end
end

// print .machine file
fid=mopen(work_dir+'.machines','w');
mfprintf(fid,'granularity=1\n');
for n=1:length(length(node_list))
    for m=1:core_num(n)
       mfprintf(fid,'1:'+node_list(n)+'\n');
    end
end
mclose(fid);
