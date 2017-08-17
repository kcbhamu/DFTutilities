// this code generates random s-orbital projection input
clear; clc; exec(PiLib);
// Parameters ========================================
tot_wan=96;
spinor='on';
// Main ============================================
printf('\n');
select spinor
case 'on'
    tot_wan=tot_wan/2;
    wan_center=rand(tot_wan,3);
case 'off'
    wan_center=rand(tot_wan,3);
end
printf('f= %f,   %f,   %f : s\n',wan_center);
