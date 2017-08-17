clear; clc; xdel(winsid());
// parameters ==========================================================
band_file='C:\MyDrive\Work\TaAs_qe\ONCV\TaAs.w90-bands.dat'
gnu_file='C:\MyDrive\Work\TaAs_qe\ONCV\TaAs.w90-bands.gnu'
E_Fermi=21.2
E_bound=[-2,+2]

// Main ================================================================
//read band data
fid=mopen(band_file,'r');
band_data=mfscanf(-1,fid,'%f %f %f')
band_data(:,2)=band_data(:,2)-E_Fermi;
mclose(fid)

// read gnu data
fid=mopen(gnu_file,'r');
gnu_data=mgetl(fid,-1)
k_div_data=grep(gnu_data,'set arrow from')
k_div_point=zeros(size(k_div_data)(2),1)
for n=1:size(k_div_data)(2)
[tot,s1,s2,s3,f]=msscanf(gnu_data(k_div_data(n)),'%s %s %s %f')
k_div_point(n)=f
end
mclose(fid)



//plot band structure
xset("colormap",jetcolormap(256))
scatter(band_data(:,1),band_data(:,2),ones(band_data(:,1)),band_data(:,3))
colorbar(min(band_data(:,3)),max(band_data(:,3)))
tmp=find(band_data(:,1)<=1e-5)
tot_k=tmp(2)-tmp(1);

// plot k-path divider
for n=1:length(k_div_point)
    plot(k_div_point(n)*ones(20,1),linspace(E_bound(1),E_bound(2),20)','k:')
end

// plot E_Fermi
plot((1:tot_k)',0*ones(tot_k,1),'r:')

// setup
a=gca();
a.data_bounds=[1, E_bound(1);band_data(tot_k), E_bound(2)];
a.tight_limits='on'
a.font_size=4
a.thickness=3

title('Band Structure','fontsize',4); 
xlabel('$k$','fontsize',4); ylabel('Energy',"fontsize", 4);
