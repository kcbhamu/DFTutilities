// This code perform complex Fourier transform of the input data
clear; clc; exec(PiLib); xdel(winsid())
// Parameters ==========================================================
work_dir='C:\MyDrive\Work\CO_junc\E_kick\EL' // folder of tot_charge.sod
E_max=5       // E max
data_ini=1;    // initial row to perform FT
dE=0.005       // dE in FT
inp_W=2.0        // input frequency of AC field in eV
time_period=2.06783 // use converson website to get it
// Main ================================================================
load(work_dir+'/tot_charge.sod');
//tot_charge=tot_charge-repmat(tot_charge(data_ini,:),length(tot_charge(:,1)),1);
FT_data=PIL_FT_damp(tot_charge(data_ini:$,[1,8]),E_max,dE,'exp')
FT_data(:,3)=abs(FT_data(:,2));
FT_data(:,4)=atan(imag(FT_data(:,2)),real(FT_data(:,2)));

t=linspace(0,3,200)
Amp=FT_data(min(find(real(FT_data(:,1))>=inp_W)),3);
phase=FT_data(min(find(real(FT_data(:,1))>=inp_W)),4);
y1=cos((2*%pi/time_period)*t);
y2=cos((2*%pi/time_period)*t+phase);
plot(t,y1,t,y2)
legend(['Eext','Curr']);

xlabel('time (fs)','fontsize',4);
ylabel('amplitude','fontsize',4);
set(gcf(),'background',8)
set(gca(),'thickness',4,'font_size',4);

disp('DC_term='+string(FT_data(1,2)))
disp('Amplitude='+string(Amp))
disp('phase shift='+string(phase/%pi)+'PI')
