// This code is to perform Fourier Transform of the GPAW dipole moment output
// alpha_x=(1/(2*%pi)\sum_{i} sin(w*t_i)exp(-t_i^2*sigma^2/2)*dmx(t_i)
// for kick, intensity=alpha_x*(2*dt*sx)/(S)

// for external field 
// # 1aut=0.025fts => 1auf=(1/0.025fs)=40*(1/fs)
// # 0.05*1auf=2*(1/fs)=1/(0.5fs)=> 8.27eV => 2000 THz
// # Conclusion: 1auf=40000THz=40PetaHz=165eV
//
clear; xdel(winsid());
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\TD_tests\Gpaw\benzene\'
file_name='dm.dat'
E_max=40;        //20 eV
dE=0.05;        //0.05 eV
width=0.2123       //Gaussan width 0.2123 eV
dp_div=100;     // total divisions
format_type=1;  // 1--> formatted , 2--> 4 column, 3 --> default spec 
time_step=8;    // only if format_type=2
// Main ================================================================
// load data ----------------------------
fid=mopen(work_dir+file_name,'r');
select format_type
case 1
    mgetl(fid,2);
    dm=mfscanf(-1,fid,'%f %f %f %f %f');
    dm=dm-repmat(dm(1,:),length(dm(:,1)),1);
    dmz=dm(:,5);
    t=dm(:,1);
case 2
    dm=mfscanf(-1,fid,'%f %f %f %f');
    dm=dm-repmat(dm(1,:),length(dm(:,1)),1);
    dmz=dm(:,4);
    t=dm(:,1)*time_step*0.041;
case 3
    mgetl(fid,6);
    dm=mfscanf(-1,fid,'%f %f %f %f');
    plot(dm(:,1),dm(:,4));
    mclose(fid);
    abort    
end

mclose(fid);

// perform Fourier Transform ------------
auf_ev=27;
ev_auf=1/27;
sigma=width*ev_auf
dt=t(2)-t(1)

tot_w=fix(E_max/dE);
FT_z=zeros(tot_w,1);
w=zeros(tot_w,1)
for n=1:tot_w
    w(n)=(n-1)*dE*ev_auf
    FT_z(n)=(1/(2*%pi))*sum(sin(w(n)*t).*exp(-t.^2*sigma^2/2).*dmz);
end

// analysis dipole distribution ---------
dmz_tmp=gsort(dmz,'g','i')/0.4;
dp_sec=linspace(-max(abs(dmz_tmp)),max(abs(dmz_tmp)),dp_div)
dp_dist=zeros(dp_div-1,2);
for n=1:dp_div-1    
    dp_dist(n,1)=(dp_sec(n)+dp_sec(n+1))/2;
    dp_dist(n,2)=length(find((dmz_tmp>dp_sec(n)) & (dmz_tmp<dp_sec(n+1))));
end
    
// plot ---------------------------------
figure(1);
subplot(2,1,1);
select format_type
case 1
    plot(t*0.024,dmz/0.4);
case 2
    plot(t*0.024,dmz/0.4);
end
xlabel('Time (fs)','fontsize',4)
ylabel('electric dipole (Debye)','fontsize',4);
set(gca(),'thickness',4,'font_size',4);
a=gce(); a.children.thickness=2;
subplot(2,1,2);
select format_type
case 1
    plot(t(1:300)*0.024,dmz(1:300)/0.4)
case 2
    plot(t(1:300)*0.024,dmz(1:300)/0.4)
end
xlabel('Time (fs)','fontsize',4)
ylabel('electric dipole (Debye)','fontsize',4);
set(gcf(),'background',8);
set(gca(),'thickness',4,'font_size',4);
a=gce(); a.children.thickness=2;

figure(2)
bar(dp_dist(:,2));
plot(dp_div/2*ones(20,1)',linspace(0,max(dp_dist(:,2))',20),'r:')

figure(3)
plot(w*auf_ev,abs(FT_z));
title('Fourier Transform','fontsize',4)
xlabel('Energy (eV)','fontsize',4);
ylabel('abs(Fouruer Intensity)','fontsize',4)
set(gcf(),'background',8)
set(gca(),'thickness',4,'font_size',4);
a=gce(); a.children.thickness=2;


