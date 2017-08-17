// This code plot the coordinate/ velocity/ force output by octopus MD
// calculation. 
clear; xdel(winsid()); stacksize('max')
// Parameters =========================================================
work_dir='D:\Work\CO_junction\md_cw2'
tot_atom=10   // total atoms
sel_atom=10    // select the atom to plot
plot_shift='off'  // whether shift all values to 0 at t=0

// Main ===============================================================
fid=mopen(work_dir+'/td.general/coordinates','r')
mgetl(fid,5);
A=mfscanf(-1,fid,strcat(repmat('%f ',1,3*3*tot_atom+2)));
mclose(fid); 

t=A(:,2);
select plot_shift
case 'on'
    A=A-repmat(A(1,:),length(A(:,1)),1);
    X=A(:,2+(1-1)*3*tot_atom+1:2+(2-1)*3*tot_atom);
    V=A(:,2+(2-1)*3*tot_atom+1:2+(3-1)*3*tot_atom);
    F=A(:,2+(3-1)*3*tot_atom+1:2+(4-1)*3*tot_atom);    
case 'off'
    X=A(:,2+(1-1)*3*tot_atom+1:2+(2-1)*3*tot_atom);
    V=A(:,2+(2-1)*3*tot_atom+1:2+(3-1)*3*tot_atom);
    F=A(:,2+(3-1)*3*tot_atom+1:2+(4-1)*3*tot_atom);

end

// coordinate
for m=1:3
    figure(m)
    for n=1:3
        subplot(3,1,n)
        select m
        case 1 // X
            plot(t*0.658,X(:,3*(sel_atom-1)+n));
            ylabel('X'+string(n),'fontsize',4)    
        case 2 // V
            plot(t*0.658,V(:,3*(sel_atom-1)+n));
            ylabel('V'+string(n),'fontsize',4)    
        case 3 // F
            plot(t*0.658,F(:,3*(sel_atom-1)+n));
            ylabel('F'+string(n),'fontsize',4)
        end
        a=gce(); a.children.thickness=2;   
        xlabel('time (fs)','fontsize',4);
        set(gcf(),'background',8)
        //set(gca(),'thickness',4,'font_size',4);
    end
end

