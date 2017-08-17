// This code helps you generate the strtarget variable in abinit
clear; clc; exec(PiLib);
// Parameters ==========================================================
P_unit='GPa' // 'GPa' / 'MPa' 
P_values=[0:2:10]; // [0,2,4,6,8,10]
// Main ================================================================
select P_unit
case 'GPa'
    unit_conv=1/29421.033;
case 'MPa'
    unit_conv=(1/29421.033)*1e-3;
end

tot_P=length(P_values);
P_output=zeros(tot_P,1);
printf('\n');
for n=1:tot_P
    if n<10 then
        s_format=' ';
    else
        s_format='';
    end
    printf('# {Pressure= %7.3f %s}\n',P_values(n),P_unit)
    printf('getcell%d%c      %d\n',n,s_format,n-1);
    printf('getxred%d%c      %d\n',n,s_format,n-1);
    printf('strtarget%d%c   -%1.5E  -%1.5E  -%1.5E  0.0  0.0  0.0\n',..
    n,s_format,P_values(n)*unit_conv*ones(1,3))
    printf('\n')
end

