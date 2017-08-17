# this code is to read xsf file and generate the input of LMTART
import numpy as np
import sys, os

# Main =======================================================
class xsf_struct:
    def __init__(self,wkdir,prefix):
        if (wkdir[-1]!='/') & (wkdir[-1]!='\\'):
            wkdir+='/'
        
        self.wkdir=wkdir
        self.prefix=prefix
        
    def __grep__(self,txtlines,kws):
        ln=[ n for n, txt in enumerate(txtlines) if txt.find(kws)!=-1]
        return ln

    def getstr(self):
        # read prim vectors
        with open(self.wkdir+self.prefix+'.xsf') as file:
            flines=file.readlines()        
            
        primvec_ln=self.__grep__(flines,'PRIMVEC')[0]
        prim_vec=np.zeros((3,3))
        for n, a in enumerate(flines[primvec_ln+1:primvec_ln+4]):
            prim_vec[n,:]=[float(a_i) for a_i in a.split()]
                
        primcoord_ln=self.__grep__(flines,'PRIMCOORD')[0]
        tot_sublat=int(flines[primcoord_ln+1].split()[0])
        atom=[]
        sublat=np.zeros((tot_sublat,3))        
        for n, pos in enumerate(flines[primcoord_ln+2:primcoord_ln+tot_sublat+2]):
            tmp=pos.split()
            atom.append(int(tmp[0]))
            sublat[n,:]=[float(pos_i) for pos_i in tmp[1:]]            
        
        
        return atom, prim_vec, sublat
        
    def getkpath(self):
        with open(self.wkdir+self.prefix+'.kpf') as file:
            flines=file.readlines()
            
        kline_start=self.__grep__(flines,'Real form of k-point coordinates')[0]+1
        kline_end=self.__grep__(flines,'END of FILE')[0]-4
        tot_kpt=kline_end-kline_start+1
        klabel=[]
        kpath=np.zeros((tot_kpt,3))
        for n, kpt in enumerate(flines[kline_start:kline_end+1]):
            tmp=kpt.split()
            klabel.append(tmp[-1])
            kpath[n,:]=[float(kpt_i) for kpt_i in tmp[0:3]]

        return klabel, kpath
        
    def showstr(self,form):
        atom, prim_vec, sublat=self.getstr()
        atom=np.array(atom)
        spec=[]
        spec_count=[]
        for atom_n in atom:
            if len(self.__grep__(spec,str(atom_n)))==0:
                spec.append(str(atom_n))
                spec_count.append(len(np.nonzero(atom==atom_n)[0]))
                 
        if form=='abt':
            print('')
            print(' ========= Abinit Input ==============')
            print('chkprim 0   # warnin on non-primitive cell')
            print('nsym 0      # auto symmetry finder')
            print('ntypat %i' % len(set(atom)))
            print('natom %i' % len(atom))
            print('znucl '+'%s '*len(spec) % tuple(spec))
            print('typat ',end='')
            for n, natom in enumerate(spec_count):
                print('%i*%s ' % (natom, spec[n]),end='')
            print()
            print('rprim')
            for n in range(0,3):
                print('%12.8f %12.8f %12.8f' % tuple(prim_vec[n,:].tolist()))
            
            print('xred')    
            for n in range(0,len(atom)):
                print('%12.8f %12.8f %12.8f' % tuple(sublat[n,:].tolist()))
# test =============
if __name__=='__main__':
    # parameters ==================================
    wkdir='/home/pipidog/Works/Li2OsO3/str/doc/'
    prefix='Li2OsO3'
    get_str='on'
    get_kpatk='off'
    # main ========================================
    mystr=xsf_struct(wkdir,prefix)
    mystr.showstr('abt')
    
