// This code plots the band structures of elk code
// To use this code, please download BAND.OUT, BANDLINES.OUT
clear; clc; xdel(winsid()); exec(PiLib);
// Parameters ==========================================================
work_dir=[]//['C:\MyDrive\Work\Eu-metal\elk\NSOC'];
E_bound=[-3,+3]
k_label=['$\Gamma$','M','K','$\Gamma$','A','L','H','A']
// Main ================================================================
work_dir=PIL_dir_path(work_dir);

// read BANDLINES.OUT
fid=mopen(work_dir+'BANDLINES.OUT','r');
bandlines=mfscanf(-1,fid,'%f  %f');
mclose(fid);
bandlines=bandlines(1:2:$,1);

//function to locate where are bandlines
function k_div=k_div_locate(k_point,bandlines)
    tot_div=length(bandlines)
    k_div=zeros(1,tot_div);
    for n=1:tot_div
        k_div(n)=find(abs(k_point(:,1)-bandlines(n))<=1e-6)
    end
endfunction

fid=mopen(work_dir+'BAND.OUT','r');
Ek=mfscanf(-1,fid,'%f %f');
mclose(fid)

tot_k=find(Ek(:,1)==Ek(1,1));
tot_k=tot_k(2)-tot_k(1);
k_point=Ek(1:tot_k,1);
tot_ban=length(Ek(:,1))/tot_k;
Ek=27.2*matrix(Ek(:,2),tot_k,tot_ban)'
k_div=k_div_locate(k_point,bandlines)

// plot band structures
plot([1:tot_k]',Ek','color','b','thickness',3);

// plot k-div
for n=2:length(k_div)-1
    plot(k_div(n)*ones(20,1),..
    linspace(max(Ek)+0.5,min(Ek)-0.5,20)','k:')
end
// plot E_Fermi
plot((1:tot_k)',zeros(tot_k,1),'r:')

// set plot properties
set(gcf(),'background',8);
set(gca(),'font_size',4);
set(gca(),'tight_limits','on');
set(gca(),'thickness',4);

a=gca();
a.data_bounds=[1, E_bound(1);tot_k, E_bound(2)];
a.tight_limits='on'
a.font_size=4
b=a.x_ticks
b(2)=k_div;
b(3)=k_label;
a.x_ticks=b
title('Band Structure','fontsize',4); 
xlabel('$k$','fontsize',4); ylabel('Energy',"fontsize", 4);
xs2png(0,'band.png')
