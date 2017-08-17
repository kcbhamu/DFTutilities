# -*- coding: utf-8 -*-
''' 
<< PLB_print >>
Description ===================================================================
// **** Purpose ****
// print a data array in a PiLib standard format
// **** Variables ****
// [file]: 1x1, integer
// <= the file object of the print out file 
// desc: string
// <= a string describes this data
// [A]: nxn, real or complex
// <= the data array to be print out
// **** functions ****
// r(): real value format
// i(): integer value format
// c(): complex value format
// sp(): complex sparse matrix format
// s(): string matrix format 
// **** Version ****
// 05/01/2014 1st version
// 06/05/2014 add line-text print, add data_type output
// 06/07/2014 add sparse matrix format
// 06/07/2014 add text matrix format (separated by '#')
// 04/26/2015 print row numbers for 'i', 'r', 'c' cases

Example =======================================================================
test_mode='s'

file=open('C:/Users/pipidog/Desktop/test.txt','w')
if test_mode=='i':
    A=100*np.random.rand(7,9)
    PLB_print(file,'this is a test',A).i()
elif test_mode=='r':
    A=100*np.random.rand(7,9)
    PLB_print(file,'this is a test',A).r()
elif test_mode=='c':
    A=100*np.random.rand(9,5)+np.random.rand(9,5)*1j
    PLB_print(file,'this is a test',A).c()
elif test_mode=='sp':
    A=np.zeros((6,3))+0j
    A[:,0]=np.arange(0,5+1)+0j
    A[:,1]=np.arange(0,5+1)+0j
    A[:,2]=np.random.rand(1,6)+np.random.rand(1,6)*1j
    PLB_print(file,'this is a test',A).sp()
elif test_mode=='s':
    A=100*np.random.rand(7,9)
    PLB_print(file,'this is a test',A).s()
file.close()

'''


import numpy as np
import sys



    
class PLB_print:
    # initialize
    def __init__(self,file,desc,A):
        self.desc=desc
        self.A=A
        self.file=file
        
        if np.ndim(self.A)==1:
            self.A=np.array([self.A])       
        elif np.ndim(self.A)> 2:
            print('Error: PLB_print, input is not a 2-dim array!')
            sys.exit(0)
    
        self.A_dim=self.A.shape
        self.file.write(' \n')            
        return None
    
    # print a row (numbers only)    
    def __row_print(self,print_format,A_row):
        for n in range(0,len(A_row)):
            self.file.write(print_format % (A_row[n]))
    
        self.file.write('\n') 
        return None
        
    # integer printer 
    def i(self):   
        order=0
        self.A=self.A*10**(-order)

        # print initial information
        self.file.write('============= PiLib Variable =============\n')
        self.file.write('%s\n' % self.desc)
        self.file.write('ORDER= %4d, SIZE=[%6d,%6d], TYPE=%s\n'% (order,self.A_dim[0],self.A_dim[1],'INTEGER'))
        self.file.write('\n')
        # print column index        
        self.file.write('      ')
        self.__row_print('  %6d',np.arange(1,self.A_dim[1]+1))   
        # print data matrix
        for n in range(0,self.A_dim[0]):
            self.file.write('%6d' % (n+1))
            self.__row_print('  %6d',self.A[n,:])
        return None
    
    # real printer
    def r(self):
        self.A=self.A+10**(-10)
        order=np.floor(np.log10(np.max(np.abs(self.A))))
        self.A=self.A*10**(-order)
        
        # print initial information
        self.file.write('============= PiLib Variable =============\n')
        self.file.write('%s\n' % self.desc)
        self.file.write('ORDER= %4d, SIZE=[%6d,%6d], TYPE=%s\n'% (order,self.A_dim[0],self.A_dim[1],'REAL'))
        self.file.write('\n')
        # print column index        
        self.file.write('      ')
        self.__row_print('  %10d',np.arange(1,self.A_dim[1]+1))   
        # print data matrix
        for n in range(0,self.A_dim[0]):
            self.file.write('%6d' % (n+1))
            self.__row_print('  %10.6f',self.A[n,:])
        return None
    
    # complex printer        
    def c(self):
        self.A=self.A+10**(-10)
        order=np.floor(np.log10(np.max(np.abs(self.A))))
        self.A=self.A*10**(-order)
        B=np.zeros((self.A_dim[0],self.A_dim[1]*2))
        B[:,range(0,2*self.A_dim[1],2)]=self.A.real
        B[:,range(1,2*self.A_dim[1],2)]=self.A.imag
        
        # print initial information
        self.file.write('============= PiLib Variable =============\n')
        self.file.write('%s\n' % self.desc)
        self.file.write('ORDER= %4d, SIZE=[%6d,%6d], TYPE=%s\n'% (order,self.A_dim[0],self.A_dim[1],'COMPLEX'))
        self.file.write('\n')
        # print column index        
        self.file.write('        ')
        self.__row_print('%20d',np.arange(1,self.A_dim[1]+1))
        # print data matrix
        for n in range(0,self.A_dim[0]):
            self.file.write('%6d  ' % (n+1))
            self.__row_print('%10.6f',B[n,:])
        return None
    
    # sparse printer        
    def sp(self):
        order=np.floor(np.log10(np.max(np.abs(self.A[:,2]))))
        self.A[:,2]=self.A[:,2]*10**(-order)               
        # print initial information
        self.file.write('============= PiLib Variable =============\n')
        self.file.write('%s\n' % self.desc)
        self.file.write('ORDER= %4d, SIZE=[%6d,%6d], TYPE=%s\n'% (order,self.A_dim[0],self.A_dim[1],'SPARSE'))
        self.file.write('\n')
        # print column index        
        self.file.write('  %6d  %6d  %20d\n' % (1,2,3))
        # print data matrix
        for n in range(0,self.A_dim[0]):
            self.file.write('  %6d  %6d  ' % (np.round(self.A[n,0]),np.round(self.A[n,1])))
            self.file.write('%10.6f%10.6f\n' % (self.A.real[n,2], self.A.imag[n,2]))
        return None

    # string printer            
    def s(self):
        order=0
        # print initial information
        self.file.write('============= PiLib Variable =============\n')
        self.file.write('%s\n' % self.desc)
        self.file.write('ORDER= %4d, SIZE=[%6d,%6d], TYPE=%s\n'
        % (order,self.A_dim[0],self.A_dim[1],'STRING'))
        self.file.write('\n')
        for n in range(0,self.A_dim[0]):
            for m in range(0,self.A_dim[1]):
                self.file.write('%s # ' % self.A[n,m])
            
            self.file.write('\n')
        return None




        

   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   