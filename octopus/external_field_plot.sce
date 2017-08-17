// This code is to show the external fields of Octopus
xdel(winsid()); clear;
// Parameters ==========================================================
env_type='cw', //'gaussian', 'cosinoidal', 'cw', 'trapezoidal'
F0=1e-3;
t0=5;
tau0=5;
tau1=2;
omega=2;
T_max=100;
T_div=200;

// Main ================================================================
function val=field_func(tn)
    select env_type
    case 'gaussian'
        val=F0*exp(-(tn-t0)/(2*tau0^2))*sin(omega*tn);
    case 'cosinoidal'
        if abs(tn-t0) > tau0
            val=0;
        else
            val=F0*cos((%pi/2)*(tn-2*tau0-t0)/(tau0))*sin(omega*tn) 
        end
    case 'cw'
        val=F0*cos(omega*tn)
    case 'trapezoidal'
        if tn < tau0
            val=F0*(tn/tau0)*sin(omega*tn)
        elseif tn > tau0+t0
            val=F0*(1-(tn-tau0-t0)/tau1)*sin(omega*tn)
        elseif tn > tau0 & tn < tau0+t0
            val=F0*sin(omega*tn)
        else
            val=0
        end
    end
endfunction

t=linspace(0,T_max,T_div);
field_str=zeros(T_div,1);
for n=1:T_div
    field_str(n)=field_func(t(n));
end
plot(t,field_str)
