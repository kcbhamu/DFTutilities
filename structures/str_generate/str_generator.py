# this code is to read xsf file and generate the input of LMTART
import numpy as np
import numpy.linalg as la
import sys, os

# Main =======================================================
class xsf_struct:
    def __init__(self,wkdir,prefix):
        if (wkdir[-1]!='/') & (wkdir[-1]!='\\'):
            wkdir+='/'
        # define initial variable
        self.wkdir=wkdir
        self.prefix=prefix
        
    def __grep__(self,txtlines,kws):
        # search which line has the target keyword
        ln=[ n for n, txt in enumerate(txtlines) if txt.find(kws)!=-1]
        return ln
        
    def cart2xred(self,sublat_cart,prim):
        # convert coordinate from cartisian to reduced coordinate
        # V: the vector, prim the primitive vectros, both numpy array
        sublat_xred=np.zeros((sublat_cart.shape[0],3))
        prim_inv=la.inv(prim.transpose())
        for n, sublat_cart_n in enumerate(sublat_cart):
            #sublat_xred[n,:]=la.inv(prim)*sublat_cart_n
            sublat_cart_n.shape=(3,1)
            sublat_xred[n,:]=prim_inv.dot(sublat_cart_n).transpose()

        return sublat_xred
        
    def ptable(self):
        # this method generates the periodic table by reading periodic_table.dat
        with open(os.path.dirname(os.path.realpath(__file__))+'/periodic_table.dat','r') as file:
            ptable=[ element[0:-1] for element in file]
            
        ptable.insert(0,'N/A')
        return ptable

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
            
        # convert cartisian coordinate to reduced coordinates
        sublat=self.cart2xred(sublat,prim_vec)
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
        spec=sorted(tuple(set(atom)))         
        if form=='abt':
            print('')
            print(' =========== Abinit Inputs ===========')
            print('chkprim 0   # warnin on non-primitive cell')
            print('nsym 0      # auto symmetry finder')
            print('ntypat %i' % len(set(atom)))
            print('natom %i' % len(atom))
            print('znucl '+'%i '*len(spec) % tuple(spec))
            print('typat ')
            for n, atom_n in enumerate(atom):
                [print('%3i ' % (n+1),end='') for n, spec_n in enumerate(spec) if spec_n==atom_n]
                if (divmod(n,10)[1]==9) | (n+1==len(atom)):
                    print('')
            print('rprim')
            for n in range(0,3):
                print('%12.8f %12.8f %12.8f' % tuple(prim_vec[n,:].tolist()))
            
            print('xred')    
            for n in range(0,len(atom)):
                print('%12.8f %12.8f %12.8f' % tuple(sublat[n,:].tolist()))
                
        elif form=='espresso':
            print('')
            print(' =========== Quantum Espresso Inputs ===========')
            print('ibrv = 0,')
            print('celldm(1) = 1.89,')
            print('ntyp = %i' % len(spec))
            print('nat = %i' % len(atom))
            print('/')
            print('CELL_PARAMETERS alat')
            ptable=self.ptable()
            for n in range(0,3):
                print('    %12.8f %12.8f %12.8f' % tuple(prim_vec[n,:].tolist()))
            print('ATOMIC_SPECIES')
            for spec_n in spec:
                print('    %2s     1.000   PSP_NAME.upf' % ptable[spec_n]) 
            print('ATOMIC_POSITIONS crystal')
            for n in range(0,len(atom)):
                print('%2s %12.8f %12.8f %12.8f 0 0 0' % \
                (ptable[atom[n]],sublat[n,0],sublat[n,1],sublat[n,2]))
                
            
            
            
# test =============
if __name__=='__main__':
    # parameters ==================================
    wkdir=os.path.dirname(os.path.realpath(__file__))
    prefix='Li2OsO3'
    get_str='on'
    get_kpatk='off'
    # main ========================================
    mystr=xsf_struct(wkdir,prefix)
    mystr.showstr('espresso')
    atom, prim_vec, sublat=mystr.getstr()
    #print(atom)
    # sublat_xred=mystr.cart2xred(sublat,prim_vec)
    # print(sublat_xred)
    # # mystr.showstr('espresso')
    #ptable=mystr.ptable()
    #print(ptable)
    
