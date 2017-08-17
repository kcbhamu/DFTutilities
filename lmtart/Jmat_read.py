# This code is to read the jey files output by lmtart and plot the 
# curves of particular components 
import sys
import numpy as np
import matplotlib.pyplot as plt
# Parameters ====================================================
wkdir='/home/pipidog/work/lmtart/Eu/pnma-afm/U5-LDA/'
prefix='Eu'
task='plot'  # 'read' / 'plot'
# read parameters
tot_orb=4
lat_range=[80,120]
lat_int=2
q_point=1
# plot parameters
a0=9.4
q_plot=1
mat_ele=[0,0,3] #1:(1,2), 2:(1,3), 3:(1,4), 6:(2,3), 7:(2,4), 11:(3,4) 
# Main ==========================================================
# define Jmat reader
def Jmat_read(wkdir,q_pt):
    with open(wkdir+'jey'+str(q_pt).zfill(2),'r') as file:
        flines=file.readlines()

    # pick JMAT section
    ln=[ n for n, line in enumerate(flines) if line.find('<SECTION=JMAT>')!=-1]
    flines=flines[ln[0]:]

    # Pick tot-tot JMAT
    ln=[ n for n, line in enumerate(flines) if line.find('tot-tot')!=-1]
    tot_jmat=len(ln)

    Jmat=np.zeros((3,3,len(ln)))
    for n, val in enumerate(ln):
        for m in range(0,3):
            Jmat[m,:,n]=[float(flines[val+m+2][2:12]),float(flines[val+m+2][26:36]),float(flines[val+m+2][50:60])]
    
    return Jmat

# run over all folders
if task=='read':
    print('reading Jmat of q-point '+str(q_point)+' ...')
    Jmat=np.zeros((3,3,tot_orb**2,len(range(lat_range[0],lat_range[1]+1,lat_int))))
    for n,lat in enumerate(range(lat_range[0],lat_range[1]+1,lat_int)):
        subdir=wkdir+prefix+'-'+str(lat)+'/'
        Jmat[:,:,:,n]=Jmat_read(subdir,q_point)

    np.savez(wkdir+'Jmat-q'+str(q_point)+'.npz',Jmat=Jmat)
    print('  => Jmat saved to Jmat-q'+str(q_point)+'.npz')
elif task=='plot':
    Jmat=np.load(wkdir+'Jmat-q'+str(q_plot)+'.npz')
    tot_lat=Jmat['Jmat'].shape[3]
    a=np.linspace(lat_range[0],lat_range[1],(lat_range[1]-lat_range[0])/lat_int+1)
    EX_const=np.zeros(tot_lat)
    print('lat(%)   lat(A)     EXX(meV)        EXX(K)')
    for n in range(0,tot_lat):
        EX_const[n]=Jmat['Jmat'][mat_ele[0],mat_ele[1],mat_ele[2],n]*13.6*1000
        print((' %3i%%   %7.4f   %10.4f    %10.4f' % (a[n]-100, a0*a[n]*0.5292/100,EX_const[n],EX_const[n]*11.6)))
             
    plt.plot(a-100,EX_const*12)
    plt.plot(a-100,np.zeros(len(EX_const)),'r:')
    plt.show()
    

