// This code is to perform Fourier Transform of the Octopus dipole moment output
// P(w)=(1/(2*%pi)\sum_{i} sin(w*t_i)exp(-t_i^2*sigma^2/2)*p(t_i)
// for kick, intensity=alpha_x*(2*dt*sx)/(S)

clear; xdel(winsid());
// Parameters ==========================================================
//work_dir='C:\MyDrive\Work\CO_junction\gs_lead\td.general'
work_dir='C:\MyDrive\Work\CO_junc\md_cw'
//work_dir='C:\MyDrive\Work\CO_junction\delta\td.general'
fn_num='no'    // num or 'no'
E_max=30;        //20 eV
dE=0.05;        //0.05 eV
Polar_comp=1;
cal_type='WFT'   // FT(Fourier transform), WFT(weighted FT, to ref. cross-section)
renorm_coff='on'     // renorm_coffalize FT coeffcient to 1?
// Main ================================================================
// load data ----------------------------
if fn_num=='no' then
    fid=mopen(work_dir+'\td.general\multipoles','r')
else     
    fid=mopen(work_dir+'\td.general\multipoles'+'.'+string(fn_num),'r');
end
mgetl(fid,16);
A=mfscanf(-1,fid,strcat(repmat('%f ',1,6)));
mclose(fid);

// defin parameters 
P=A(:,4:6)-repmat(A(1,4:6),length(A(:,1)),1);
t=(A(:,2)-A(1,2))
dt=A(2,2)-A(1,2)
// perform Fourier Transform ------------
// [t] in [hbar/eV] => 0.658212 fs
// [w] in [eV] => (4.136 fs)^-1 = (0.2418kTHz)

tot_w=fix(E_max/dE);
FT_P=zeros(tot_w,1);
w=linspace(0,E_max,tot_w)';

s1=P(:,Polar_comp);
s2=(1-3*(t/t($)).^2+2*(t/t($)).^3)
for n=1:tot_w    
    s3=sin(w(n)*t);
    select cal_type
    case 'FT'
        FT_P(n)=sum(s1.*s2.*s3)*dt;
    case 'WFT'
        FT_P(n)=w(n)*sum(s1.*s2.*s3)*dt;
    end
end
select renorm_coff
case 'on'
    plot(w,abs(FT_P)/max(abs(FT_P)))
case 'off'
    plot(w,abs(FT_P))    
end

a=gce(); a.children.thickness=2;   
xlabel('Energy (eV)','fontsize',4);
select cal_type
case 'FT'
    ylabel('abs FT coeff','fontsize',4)
case 'WFT'
    ylabel('abs WFT coeff','fontsize',4)
end

set(gcf(),'background',8)
set(gca(),'thickness',4,'font_size',4);
