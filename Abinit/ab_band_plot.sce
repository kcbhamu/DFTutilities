// This program is to plot the band structures calculated from ABINIT
// To use this code, you need to input the k-points that define pahtes
// This code will automatically search for file name with "_EIG". 
// Therefore if there are more than one "_EIG" files, the code will 
// report error !
clear; clc; xdel(winsid()); exec(PiLib);
// Parameter ===========================================================
//file_path='C:\MyDrive\Work\Ba2TePoO6\Ba2TePoO6_o_DS2_'
work_dir=[];
k_div=[    12 11 16 7 11 11 16  ]
Ef=(0.09446) // 0.04279(SOLDA), 0.04597(SOLDAU), 0.04345(LDA), 0.04537(LDAU) 
E_unit='hartree'//unit of E_Fermi and k_band, 'eV' or 'hartree'
E_shift='yes'
E_bound=[-1,2] // values depending on E_shift, always in eV
line_width=3;
k_label=['$\Gamma$','X','M','$\Gamma$','Z','R','A','Z']
save_png='on'
// Main ================================================================
work_dir=PIL_dir_path(work_dir);
flist=dir(work_dir);

fid=mopen(flist(2)(grep(flist(2),'_EIG')),'r'); 
ban_dat=mgetl(fid,-1);
mclose(fid);
[nv,s1,tot_k]=msscanf(ban_dat(1),'%32c %d')
if grep(ban_dat(1),'SPIN UP')~=[] then
    spin=2
else
    spin=1
end
[nv,s1,tot_ban]=msscanf(ban_dat(2),'%17c %d')

// read band eigenvalues
ban_loc=grep(ban_dat,'kpt#')
if (spin==2) & length(ban_loc)/tot_k~=2 then
    disp('Error: length(ban_loc)/tot_k~=2 !')
    abort
elseif (spin==1) & length(ban_loc)~=tot_k 
    disp('Error: length(ban_loc)/tot_k~=1 !')
    abort    
end

Ek=zeros(tot_ban,tot_k,spin);
k_point=zeros(tot_k,3);
for n=1:length(ban_loc)
    [nv,s1,kx,ky,kz]=msscanf(ban_dat(ban_loc(n)),'%42c %f %f %f')
    k_point(n,:)=[kx,ky,kz]
    tot_line=ceil(tot_ban/8);
    Ek_read=msscanf(tot_line-1,ban_dat(ban_loc(n)+1:ban_loc(n)+tot_line),..
    strcat(repmat('%f ',1,8)))
    Ek_read=matrix(Ek_read',-1,1);
    Ek_read=cat(1,Ek_read,(msscanf(ban_dat(ban_loc(n)+tot_line),..
    strcat(repmat('%f ',1,tot_ban-(tot_line-1)*8))))')    
    if spin==2 then
        if n<=tot_k then
            Ek(:,n,1)=Ek_read
        else
            Ek(:,n-tot_k,2)=Ek_read
        end
    else 
        Ek(:,n)=Ek_read
    end
end

if E_unit=='hartree' then
    Ek=(Ek-Ef)*27.2;
else
    Ek=(Ek-Ef);
end

// plot bands
color_order=['b','g']
for n=1:spin
    plot([1:tot_k]',Ek(:,:,n)',color_order(n),'thickness',line_width);
end

// plot k-path divider
k_loc=[]
for n=1:length(k_div)-1
    k_loc=cat(2,k_loc,sum(k_div(1:n))+1)
    plot(k_loc($)*ones(20,1),linspace(max(Ek)+0.5,min(Ek)-0.5,20)','k:')
end
k_loc=cat(2,cat(2,1,k_loc),tot_k)

// plot E_Fermi
plot((1:tot_k)',zeros(tot_k,1),'r:')

set(gcf(),'background',8);
set(gca(),'font_size',4);
set(gca(),'tight_limits','on');
set(gca(),'thickness',4);

a=gca();
a.data_bounds=[1, E_bound(1);tot_k, E_bound(2)];
a.tight_limits='on'
a.font_size=4
b=a.x_ticks
b(2)=k_loc;
b(3)=k_label;
a.x_ticks=b
title('Band Structure','fontsize',4); 
xlabel('$k$','fontsize',4); ylabel('Energy',"fontsize", 4);

if save_png=='on' then
    xs2png(0,'band.png');
end
