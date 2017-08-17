'''
this class defines a series of methods that can be applied to generate 
structures for DFT calculation. 
'''
import numpy as np
import numpy.linalg as linalg
import sys, os

# Main =======================================================
class structure:        
    def __grep__(self,txtlines,kws):
        # search which line has the target keyword
        ln=[ n for n, txt in enumerate(txtlines) if txt.find(kws)!=-1]
        return ln
        
    def cart2xred(self,sublat_cart,prim):
        # convert coordinate from cartisian to reduced coordinate
        # V: the vector, prim the primitive vectros, both numpy array
        sublat_xred=np.zeros((sublat_cart.shape[0],3))
        prim_inv=linalg.inv(prim.transpose())
        for n, sublat_cart_n in enumerate(sublat_cart):
            sublat_cart_n.shape=(3,1)
            sublat_xred[n,:]=prim_inv.dot(sublat_cart_n).transpose()

        return sublat_xred
    
    def recip_vec(self,a_vec):
        # generate the reciprocal lattice row vectros 
        b_vec=np.zeros((3,3))
        I=np.eye(3,3)
        for n in range(0,3):
            bn=2*np.pi*linalg.inv(a_vec).dot(I[:,n])
            bn.shape=(1,3)
            b_vec[n,:]=bn
            
        return b_vec
        
    def kdiv(self,a_vec,kpath,kdense=20):
        b_vec=self.recip_vec(a_vec)
        kcart=np.zeros((kpath.shape[0],3))
        # convert to cartisian coordinates
        for n, kpath_n in enumerate(kpath):
            kcart[n,:]=kpath_n.dot(b_vec)
            
        # calculate # of k-point of each segment
        kdiv=[]
        for n, kcart_n in enumerate(kcart):
            if n!=kcart.shape[0]-1:
                kdiv.append(int(round(kdense*linalg.norm(kcart[n+1,:]-kcart[n,:]))))
                
        return kdiv
        
    def ptable(self):
        # this method generates the periodic table by reading periodic_table.dat
        with open(os.path.dirname(os.path.realpath(__file__))+'/periodic_table.dat','r') as file:
            ptable=[ element[0:-1] for element in file]
        
        # insert 'N/A' to atomic number 0
        ptable.insert(0,'N/A')
        return ptable

    def getxsf(self,wkdir,prefix):
        if (wkdir[-1]!='/') | (wkdir[-1]!='\\'):
            wkdir+='/'
        # read prim vectors
        with open(wkdir+prefix+'.xsf') as file:
            flines=file.readlines()        
            
        primvec_ln=self.__grep__(flines,'PRIMVEC')[0]
        a_vec=np.zeros((3,3))
        for n, a in enumerate(flines[primvec_ln+1:primvec_ln+4]):
            a_vec[n,:]=[float(a_i) for a_i in a.split()]
                
        primcoord_ln=self.__grep__(flines,'PRIMCOORD')[0]
        tot_sublat=int(flines[primcoord_ln+1].split()[0])
        atom=[]
        sublat=np.zeros((tot_sublat,3))        
        for n, pos in enumerate(flines[primcoord_ln+2:primcoord_ln+tot_sublat+2]):
            tmp=pos.split()
            atom.append(int(tmp[0]))
            sublat[n,:]=[float(pos_i) for pos_i in tmp[1:]]            
            
        # convert cartisian coordinate to reduced coordinates
        sublat=self.cart2xred(sublat,a_vec)
        
        return atom, a_vec, sublat
        
    def getkpf(self,wkdir,prefix):
        if (wkdir[-1]!='/') | (wkdir[-1]!='\\'):
            wkdir+='/'
        with open(wkdir+prefix+'.kpf') as file:
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
        
    def str_input(self,form,atom,a_vec,sublat):
        ptable=self.ptable()
        # convert atomic name format to atomic number format
        if type(atom[0])==str:
            atom=[ self.__grep__(ptable,atn)[0] for atn in atom]
        
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
                print('%12.8f %12.8f %12.8f' % tuple(a_vec[n,:].tolist()))
            
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
            for n in range(0,3):
                print('    %12.8f %12.8f %12.8f' % tuple(a_vec[n,:].tolist()))
            print('ATOMIC_SPECIES')
            for spec_n in spec:
                print('    %2s     1.000   PSP_NAME.upf' % ptable[spec_n]) 
            print('ATOMIC_POSITIONS crystal')
            for n in range(0,len(atom)):
                print('%2s  ' % ptable[atom[n]],end='')
                print('%12.8f %12.8f %12.8f 0 0 0' % tuple(sublat[n,:]))
        elif form=='elk':
            print('')
            print(' =========== Elk Inputs ===========')
            print('primcell')
            print('  .true.')
            print('scale')
            print('  1.89')
            print('avec')
            [print('  %12.8f'*3 % (a_n[0],a_n[1],a_n[2])) for a_n in a_vec]
            print('atoms')
            print('%3i        :nspecies' % len(spec))
            for spec_n in spec:
                sublat_label=np.nonzero(np.array(atom)==spec_n)[0]
                print('%2s.in      :spfname' % ptable[spec_n])
                print('%2i         :natoms; atposl, bfcmt below' % len(sublat_label))
                for label in sublat_label:
                    print('%12.8f %12.8f %12.8f   0.0   0.0   0.0' % tuple(sublat[label,:].tolist())) 
        else:
            print('Error: structure.str_input, output format does not support')

    def kpath_input(self,form,a_vec,kpath,klabel=None,kdense=20):
        kdiv=self.kdiv(a_vec,kpath,kdense)
        if form=='abt':
            print('kptopt -%i' % len(kdiv))
            print('ndivk '+'%i '*len(kdiv) % tuple(kdiv))
            print('kptbounds')
            [print('%12.8f  '*3 % tuple(kpath_n)) for kpath_n in kpath]
        elif form=='espresso':
            print('K_POINTS crystal_b')
            print('%i' % (len(kdiv)+1))
            kdiv.extend([1])
            for n, kpath_n in enumerate(kpath):
                print('%12.8f  '*3 % tuple(kpath_n),end='')
                print('%2i  ! %2s' % (kdiv[n],klabel[n]))
        elif form=='elk':
            print('! band path: '+'%s-'*kpath.shape[0] % tuple(klabel))
            print('plot1d')
            print('    %i  %i : nvp1d, npp1d '% (kpath.shape[0],sum(kdiv)))
            for n, kpath_n in enumerate(kpath):
                if n==0:
                    print('  %12.8f'*3 % tuple(kpath_n), end='')
                    print('  : vlv1d')
                else:
                    print('  %12.8f'*3 % tuple(kpath_n))
        elif form=='lmtart':
            print('%i ' % len(kdiv))
            for n, kpath_n in enumerate(kpath):
                if n!=kpath.shape[0]-1:
                    print('%s-%s' % (klabel[n],klabel[n+1]))
                    print('%12.8f, '*3 % tuple(kpath[n,:]),end='')
                    print('%12.8f, '*3 % tuple(kpath[n+1,:]))
        else:
            print('Error: structure.kpath_input, output format does not support')
            
# test =============
if __name__=='__main__':
    # parameters ==================================
    wkdir=os.path.dirname(os.path.realpath(__file__))
    prefix='Li2OsO3'
    get_str='on'
    get_kpatk='off'
    # main ========================================
    mystr=structure()
    # test getxsf
    atom, a_vec, sublat=mystr.getxsf(wkdir,prefix)
    # test getkpf
    klabel, kpath=mystr.getkpf(wkdir,prefix)
    # test kdiv
    kdiv=mystr.kdiv(a_vec,kpath)
    mystr.kpath_input('lmtart',a_vec,kpath,klabel)
    
    # b_vec=mystr.recip_vec(a_vec)
    # print(b_vec)
    # ptable=mystr.ptable()
    # atom_str=[ ptable[atn] for atn in atom]
    # mystr.str_input(atom_str,a_vec,sublat,'espresso')
    
