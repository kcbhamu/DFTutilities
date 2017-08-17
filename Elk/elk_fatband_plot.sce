// This code plots the band structures of elk code
// To use this code, please download BAND.OUT, BAND_Sxx_Axxxx.OUT
clear; clc; xdel(winsid()); exec(PiLib);
// Parameters ==========================================================
work_dir=[]//['C:\MyDrive\Work\Eu-metal\elk\NSOC'];
project_name='Eu_LDAU'
task='plot' // 'read'/'plot'
state_grp=list([3,7],[26:4:46])
E_bound=[-3,+3]
k_label=['$\Gamma$','M','K','$\Gamma$','A','L','H','A']
w_range=[];  // weight range, run empty first, then set value
marker_size=[30];
c_map=[];

// Main ================================================================
work_dir=PIL_dir_path(work_dir);
flist=dir(work_dir)

// read BANDLINES.OUT
fid=mopen(work_dir+'BANDLINES.OUT','r');
bandlines=mfscanf(-1,fid,'%f  %f');
mclose(fid);
bandlines=bandlines(1:2:$,1);

// check whether fatband data exist
// read BAND_Sxx_AXXXX.OUT
fband_list=[]
for n=1:length(length(flist(2)))
    if grep(flist(2)(n),'/BAND_S\d{2}_A\d{4}.OUT/','r') then
        fband_list=cat(2,fband_list,n)
    end
end

//function to locate where are bandlines
function k_div=k_div_locate(k_point,bandlines)
    tot_div=length(bandlines)
    k_div=zeros(1,tot_div);
    for n=1:tot_div
        k_div(n)=find(abs(k_point(:,1)-bandlines(n))<=1e-6)
    end
endfunction


if task=='read' then
    fband_read=list()
    tot_state=length(fband_list)*4
    state_info=string(zeros(tot_state,1));
    for n=1:length(fband_list) // run atoms
        // build state_info
        state_info((n-1)*4+1:n*4)=string((n-1)*4+[1;2;3;4])+' => '+..
        part(flist(2)(fband_list(n)),6:14)+'-'+['s';'p';'d';'f']
        
        // read fatband data
        fid=mopen(work_dir+flist(2)(fband_list(n)),'r');
        fband_read(n)=mfscanf(-1,fid,strcat(repmat('%f ',1,7)));
        mclose(fid)

        tot_k=find(fband_read(n)(:,1)==fband_read(n)(1,1));
        tot_k=tot_k(2)-tot_k(1);
        tot_ban=length(fband_read(n)(:,1))/tot_k;
        k_point=fband_read(n)(1:tot_k,1);
        k_div=k_div_locate(k_point,bandlines)
        if n==1 then
            Ek_weight=zeros(tot_ban,tot_k,tot_state);
            Ek=matrix(fband_read(n)(:,2),tot_k,tot_ban)';
            Ek=Ek*27.2;
        end        
        for m=1:4 // run s,p,d,f
            Ek_weight(:,:,(n-1)*4+m)=matrix(fband_read(n)(:,m+3),tot_k,tot_ban)'
        end
    end
    printf('\n')
    printf('All fatband information has been read!\n');
    save(work_dir+'fatband.sod','Ek','Ek_weight','k_div','state_info');
    printf('%s\n',state_info)
elseif task=='plot'
    load(work_dir+'fatband.sod');
    PIL_fatband_plot(Ek,Ek_weight,0,k_div,E_bound,state_grp,state_info,..
    k_label,project_name,[],marker_size,[],c_map,w_range)
    for n=0:length(state_grp)
        xs2png(n,'fatband-'+string(n)+'.png')
    end
end
