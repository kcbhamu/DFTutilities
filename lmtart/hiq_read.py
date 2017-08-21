# This code is to read the hiq data output by LMTART 8.0
from functools import reduce
import numpy as np
class hiqpp:
    def __init__(self,wkdir,prefix):
        if (wkdir[-1]!='/') & (wkdir[-1]!='\\'):
            wkdir+='/'
        self.wkdir=wkdir
        self.prefix=prefix
        
    def read(self,nqdiv,nOmgCHI):
        nqdiv=np.array(nqdiv)+1
        with open(self.wkdir+prefix+'.hiq') as file:
            flines=file.readlines()
            
        lr=[n for n, line in enumerate(flines) if line.find('<SECTION=REHI>')!=-1]
        li=[n for n, line in enumerate(flines) if line.find('<SECTION=IMHI>')!=-1]
        
        print(lr,li)
        freq_n=0
        freq=np.zeros((nOmgCHI+1))
        hi_r=np.zeros((reduce(lambda x,y:x*y,nqdiv),4,nOmgCHI+1))
        hi_i=np.zeros((reduce(lambda x,y:x*y,nqdiv),4,nOmgCHI+1))
        kpoint=np.zeros((reduce(lambda x,y:x*y,nqdiv),3))
        
        for part_n, part in enumerate([[lr[0],li[0]],[li[0],len(flines)]]):
            freq_n=0
            print(part)
            for n, line in enumerate(flines[part[0]:part[1]]):
                if line.find('! Frequency'):
                    line=line.replace('! Frequency','!Frequency')
                
                line_dat=line.split()
                if (len(line_dat)==2):  #freq
                    freq_n+=1
                    freq[freq_n-1]=float(line_dat[0])
                    k_n=0
                    print(line[0:-1]+' --> {0}\n'.format(n+10))
                    
                if (len(line_dat)==3):  # kpoint 
                    k_n+=1
                    spin_n=0
                    print([float(line_dat_n) for line_dat_n in line_dat])
                    kpoint[k_n-1,:]=[float(line_dat_n) for line_dat_n in line_dat]
                    print(line[0:-1]+' --> {0}\n'.format(n+10))
                    
                if (len(line_dat)==1):
                    spin_n+=1
                    if part_n==0:
                        hi_r[k_n-1,spin_n-1,freq_n-1]=float(line_dat[0])
                    elif part_n==1:
                        hi_i[k_n-1,spin_n-1,freq_n-1]=float(line_dat[0])
                    print(line[0:-1]+' --> {0}\n'.format(n+10))  

        np.savez(self.wkdir+'hiq_data.npz',hi_r=hi_r,hi_i=hi_i,freq=freq,kpoint=kpoint)
        #print(tot_freq,tot_k,tot_sum)
        # print(nVal.count(1))
        # print(nVal.count(2))
        # print(nVal.count(3))    
# main ===========================
if __name__=='__main__':
    #parameter --------------
    wkdir='C:\\MyDrive\\Work\\Eu\\lmtart\\pnma-afm\\U5-LDA-801\\Eu-100'
    prefix='Eu-100'
    nqdiv=[6,6,6] # in pnt file
    nOmgCHI=1  # in hiq file
    # run -------------------
    hiq=hiqpp(wkdir,prefix)
    hiq.read(nqdiv,nOmgCHI)