# This code is to read the hiq data output by LMTART 8.0
from functools import reduce
import os, sys
import numpy as np
import matplotlib.pyplot as plt
class hiqpp:
    def __init__(self,wkdir,prefix):
        if (wkdir[-1]!='/') & (wkdir[-1]!='\\'):
            wkdir+='/'
        self.wkdir=wkdir
        self.prefix=prefix
        
    def hiqread(self,nqdiv,nOmgCHI):
        nqdiv=np.array(nqdiv)+1
        with open(self.wkdir+prefix+'.hiq') as file:
            flines=file.readlines()
            
        lr=[n for n, line in enumerate(flines) if line.find('<SECTION=REHI>')!=-1]
        li=[n for n, line in enumerate(flines) if line.find('<SECTION=IMHI>')!=-1]
        
        # determin # of bands
        tot_freq=(nOmgCHI+1)
        tot_k=reduce(lambda x,y:x*y,nqdiv)
        tot_line=li[0]-lr[0]-1
        tot_ban_line=int((tot_line-(tot_freq)-(tot_k*tot_freq))/(tot_k*tot_freq*4))
        tot_ban=int(np.floor(np.sqrt(tot_ban_line*5-1)))

        # double check band
        if np.ceil((tot_ban**2+1)/5)*tot_freq*tot_k*4+tot_k*tot_freq+tot_freq != tot_line:
            print('Error: tot_ban not detected correctly!')        
            sys.exit()
            
        f_n=0
        freq=np.zeros((tot_freq))
        hi_mat=np.zeros((tot_ban,tot_ban,4,tot_k,tot_freq))*1j
        hi_sum=np.zeros((tot_k,4,tot_freq))*1j
        kpoint=np.zeros((tot_k,3))
        
        lcount=9
        for part in ['r','i']:
            print(flines[lcount])
            lcount+=1
            for f_n in range(0,tot_freq):
                if flines[lcount].find('Frequency')==-1:
                    print('Error: frequency read error!')
                    sys.exit()
                else:
                    print('f_n={0}'.format(f_n))
                    freq[f_n]=flines[lcount].split()[0]
                    lcount+=1
                    
                for k_n in range(0,tot_k):
                    if len(flines[lcount].split())!=3:
                        print('Error: kpoint read error!')
                        sys.exit()
                    else:
                        kpoint[k_n,:]=[float(ki) for ki in flines[lcount].split()]
                        lcount+=1
                    
                    # scattering matrix area ----------------
                    for spin_n in range(0,4):  # run spin
                        mat_ele=[]
                        for ban_line in range(0,tot_ban_line): # run scattering matrix
                           mat_ele.extend([float(banval) for banval \
                           in flines[lcount].split()])
                           lcount+=1
                           
                        if len(mat_ele)==tot_ban**2+1:
                            if part=='r':
                                hi_sum[k_n,spin_n,f_n]+=mat_ele[-1]
                                mat_ele=np.array(mat_ele[0:-1])
                                mat_ele.shape=(tot_ban,tot_ban)
                                hi_mat[:,:,spin_n,k_n,f_n]+=mat_ele
                            elif part=='i':
                                hi_sum[k_n,spin_n,f_n]+=mat_ele[-1]*1j
                                mat_ele=np.array(mat_ele[0:-1])
                                mat_ele.shape=(tot_ban,tot_ban)
                                hi_mat[:,:,spin_n,k_n,f_n]+=mat_ele*1j
                        else:
                            print('Error: # of scattering matrix elements incorrect!')
                            sys.exit()
                    # scattering matrix area ----------------
        
        np.savez(self.wkdir+'hiq_data.npz',hi_mat=hi_mat,hi_sum=hi_sum,\
        freq=freq,kpoint=kpoint)
        
    def hiqplot(self,spin,show):
        hiq=np.load(self.wkdir+'hiq_data.npz')
        if spin=='a':
            for spin_n in range(0,4):
                plt.subplot(2,2,spin_n+1)
                plt.plot(hiq['hi_sum'][:,spin_n,0].imag)            
        else:
            plt.plot(hiq['hi_sum'][:,spin,0].imag)
        
        plt.savefig(self.wkdir+prefix+'-hiq.png')
        if show=='on':
            plt.show()
        elif show=='off':
            plt.close()
        
# main ===========================
if __name__=='__main__':
    #parameter --------------
    lat_range=[80,120,2]
    for lat in range(lat_range[0],lat_range[1]+1,lat_range[2]):
        print('lat={0}'.format(lat))
        wkdir='/home/pipidog/work/lmtart/Eu/pnma-afm/U5-LDA-801/Eu-'+str(lat)
        prefix='Eu-'+str(lat)
        nqdiv=[6,6,6] # in pnt file
        nOmgCHI=1  # in hiq file
        spin=1
        show='off'
        # run -------------------
        hiq=hiqpp(wkdir,prefix)
        hiq.hiqread(nqdiv,nOmgCHI)
        hiq.hiqplot(spin,show)


