// This file plots Casida spectrum
clear; clc; xdel(winsid());
work_dir='C:\MyDrive\Work\Ag110\e0' // upper folder of the casida folder
E_max=3;
plot_spec='eps_diff' // casida, petersilka, eps_diff
E_unit='eV' //hartree, eV
// Main ================================================================
select plot_spec
case 'casida'
    spectrum=read(work_dir+'/casida/spectrum.casida',-1,5);
case 'petersilka'
    spectrum=read(work_dir+'/casida/spectrum.petersilka',-1,5);
case 'eps_diff'
    spectrum=read(work_dir+'/casida/spectrum.eps_diff',-1,5);
else
    disp('Error: No such file!');
    abort
end
E_max_ind=max(find(spectrum(:,1) <= E_max))
select E_unit
case 'hartree'
    plot(spectrum(1:E_max_ind,1)/27.2,spectrum(1:E_max_ind,5)/27.2); 
    xlabel('energy (hartree)','font_size',4);
    ylabel('Strength function (hartree)','font_size',4);
case 'eV'
    plot(spectrum(1:E_max_ind,1),spectrum(1:E_max_ind,5));
    xlabel('energy (eV)','font_size',4);
    ylabel('Strength function (eV)','font_size',4);
end
a=gce(); a.children.thickness=2;  
set(gcf(),'background',8)
set(gca(),'thickness',4,'font_size',4);   

save(work_dir+'/'+plot_spec+'.sod','spectrum')     


