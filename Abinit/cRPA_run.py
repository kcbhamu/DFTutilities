'''
This code is to run cRPA calculation in abinit. It reads the input U and J 
and the output U and J. If they are not self-consistent, this code will delete 
the outputs of pevious calculation, generate a new input file, and submit
a new job automatically. 
'''
import sys
import os, os.path 
import time
# parameters ===========================================
reset_input='off'  # # reset initla input to U=J=0, nsym=0
auto_sym='on' # run sym -> nosym scf automatically
bash_comd='sbatch submit'
prefix='Eu'
UJ_ds=0
tot_spec=1
corr_spec=1
U_toler=0.2
J_toler=0.1
mixing=0.5 # mixing of the new U & J
nstep_max=100
check_period=60
job_echo='off'

# class ================================================
class cRPA_run:
    def __init__(self,prefix,UJ_ds,tot_spec,corr_spec):
        if UJ_ds==0:
            UJ_ds=' '
        else:
            UJ_ds=str(UJ_ds)    
                
        self.prefix=prefix
        self.UJ_ds=UJ_ds
        self.tot_spec=tot_spec 
        self.corr_spec=corr_spec
                     
        print('self-consistent cRPA calculation begins (PID='\
              +str(os.getpid())+')')
        print('\nstart time: '\
              +time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime()))
                    
    def __grep(self,file_line,key_str,case='on'):
        ln=[]
        for n in range(0,len(file_line)):
            if case=='on':    # case sensitive
                if file_line[n].find(key_str)!=-1:
                    ln.append(n)            
            elif case=='off': # case insensitive
                if (file_line[n].lower()).find(key_str.lower())!=-1:
                    ln.append(n)
            else:
                print('Error: grep, case option is not recognized!')
                sys.exit()
    
        return ln
    
    def reset_input(self):
        with open(self.prefix+'.in','r') as file:
            fin=file.readlines()
            
        ln_u=self.__grep(fin,'upawu'+self.UJ_ds,'off')
        ln_j=self.__grep(fin,'jpawu'+self.UJ_ds,'off')
        ln_nsym=self.__grep(fin,'nsym','off')
        
        U_val=['0.0 ']*self.tot_spec; U_val[self.corr_spec-1]='0.01 '
        J_val=['0.0 ']*self.tot_spec; J_val[self.corr_spec-1]='0.001 '
        
        fin[ln_u[0]]='upawu'+self.UJ_ds+' '+''.join(U_val)+' eV\n'
        fin[ln_j[0]]='jpawu'+self.UJ_ds+' '+''.join(J_val)+' eV\n'
        fin[ln_nsym[0]]='nsym 0\n'
        
        with open(prefix+'.in','w') as file:
            file.writelines(fin)
        
        print('\n** iuput file is reset: U_in=1e-2, J_in=1e-3, nsym=0')
        
    def UJ_in_read(self):
        # read input U & J
        with open(self.prefix+'.in','r') as file:
            fin=file.readlines()
        
        ln_u=self.__grep(fin,'upawu'+self.UJ_ds)
        ln_j=self.__grep(fin,'jpawu'+self.UJ_ds)
        
        if (fin[ln_u[0]].find('eV')==-1) | (fin[ln_j[0]].find('eV')==-1):
            print('Error: upawu and jpawu must be specified in eV !')
            sys.exit()
            
        self.UJ_in=[float(fin[ln_u[0]][6:-3].split()[self.corr_spec-1]),\
               float(fin[ln_j[0]][6:-3].split()[self.corr_spec-1])]
		        
    def UJ_out_read(self):
    		 # read output U & J
        with open(self.prefix+'.out','r') as file:
            fout=file.readlines()
        
        ln=self.__grep(fout,'U(omega)')
        UJ_out=[]
        [UJ_out.append(float(val)) for val in fout[ln[0]+1].split()]
        
        if (abs(UJ_out[2])>=1e-6) | (abs(UJ_out[4])>=1e-6):
            print('Error: UJ_out are complex!') 
            sys.exit()
        else:
            self.UJ_out=[UJ_out[1],UJ_out[3]]    
			
    def conv_check(self,U_toler,J_toler):
        U_diff=abs(self.UJ_in[0]-self.UJ_out[0])
        J_diff=abs(self.UJ_in[1]-self.UJ_out[1])
        		
        #write scf log file
        print('\n=> Results of calculation')
        print('   U_in=%5.3f, U_out=%5.3f => diff=%5.3f ; U_toler= %5.3f'%\
              (self.UJ_in[0],self.UJ_out[0],U_diff,U_toler))
        print('   J_in=%5.3f, J_out=%5.3f => diff=%5.3f ; J_toler= %5.3f'%\
              (self.UJ_in[1],self.UJ_out[1],J_diff,J_toler)) 
        
        with open(prefix+'.in','r') as file:
            fin=file.readlines()
        
        nsym=int(fin[self.__grep(fin,'nsym','off')[0]].split()[1])
        
        if ((U_diff < U_toler) & (J_diff < J_toler) & (nsym==0)):
            print('\n   * symmetric calculation converged')                    
            print('     U_sym=%6.3f, J_sym=%6.3f' % \
                  ((self.UJ_out[0]+self.UJ_in[0])/2,\
                   (self.UJ_out[1]+self.UJ_in[1])/2)) 
            return 1 # sym converge
        elif ((U_diff < U_toler) & (J_diff < J_toler) & (nsym==1)):
            print('\n   * non-symmetric calculation converged')                       
            print('     U_nsym=%6.3f, J_nsym=%6.3f' % \
                  ((self.UJ_out[0]+self.UJ_in[0])/2,\
                   (self.UJ_out[1]+self.UJ_in[1])/2)) 
            return 2 # nosym converge
        else:
            return 0 # not converge
            
        
    def nosym_input(self):
        with open(prefix+'.in','r') as file:
            fin=file.readlines()
        
        ln_nsym=self.__grep(fin,'nsym','off')
        fin[ln_nsym[0]]='nsym 1\n'
       
        with open(prefix+'.in','w') as file:
          file.writelines(fin)
          
        print('\n=> *** reset input to non-symmetric calculation ***')

    def mixing_input(self,mixing=0.3):
        # remove old files
        os.system('rm *o_*')
        os.system('rm *.out*')
        
        # generate new input file
        U_new=[]; [U_new.append('  '+str(0.0)) for n in range(0,self.tot_spec)]
        J_new=[]; [J_new.append('  '+str(0.0)) for n in range(0,self.tot_spec)]
        U_new[self.corr_spec-1]='  '+str((1-mixing)*self.UJ_in[0]+mixing*self.UJ_out[0])
        J_new[self.corr_spec-1]='  '+str((1-mixing)*self.UJ_in[1]+mixing*self.UJ_out[1])
        U_new=''.join(U_new)
        J_new=''.join(J_new)
        
        # load input file
        with open(self.prefix+'.in','r') as file:
            fin=file.readlines()
        
        ln_u=self.__grep(fin,'upawu'+self.UJ_ds)
        ln_j=self.__grep(fin,'jpawu'+self.UJ_ds)
        
        # rewrite input file
        with open(self.prefix+'.in','w') as file:
            fin[ln_u[0]]='upawu'+self.UJ_ds+U_new+' eV\n'
            fin[ln_j[0]]='jpawu'+self.UJ_ds+J_new+' eV\n'  
            file.writelines(fin) 
            
        print('\n=> New input file generated, mixing=%4.2f'% mixing)
        print('   U_new=%5.3f, J_new=%5.3f' % \
              ((1-mixing)*self.UJ_in[0]+mixing*self.UJ_out[0],\
              (1-mixing)*self.UJ_in[1]+mixing*self.UJ_out[1]))
	
    def job_submit(self,nlabel,bash_comd,period=60,job_echo='off'):
        print('\n====== %d-th calculation ======\n' % nlabel)
        if os.path.isfile(self.prefix+'.out'): 
            os.system('rm *.out*')
            os.system('rm *o_*')

        os.system(bash_comd)  
        
        while True:
            if os.path.isfile(self.prefix+'.out'):
                break
            else:
                time.sleep(period)
                
        while True:
            with open(self.prefix+'.out','r') as file:
                fout=file.readlines()
     
            if self.__grep(fout,'error','off')!=[] :
                print('Error: job_check, job has error!')
                sys.exit()
            elif self.__grep(fout,'calculation completed','off')!=[]:
                print('\n=> calculation completed - '\
                      +time.strftime("%Y-%m-%d %H:%M:%S"\
                      ,time.gmtime()))
                break
            else:
                if job_echo=='on':
                    print('   job remains running - '\
                          +time.strftime("%Y-%m-%d %H:%M:%S"\
                         , time.gmtime()))

                time.sleep(period)   		
                
    def job_complete(self):
        print('\n------------ cRPA self-consistency reached ------------\n' )                
        print('U=%6.3f, J=%6.3f' % ((self.UJ_out[0]+self.UJ_in[0])/2,\
                                    (self.UJ_out[1]+self.UJ_in[1])/2)) 
        print('\nend time : '+time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime()))


        
                        
# Main =================================================
cRPA=cRPA_run(prefix,UJ_ds,tot_spec,corr_spec)
if reset_input=='on':
    cRPA.reset_input()

cRPA.job_submit(0,bash_comd,check_period,job_echo)
for n in range(1,nstep_max):
    cRPA.UJ_in_read()
    cRPA.UJ_out_read()
    conv=cRPA.conv_check(U_toler,J_toler)
    if (conv==2) | ((conv==1) & (auto_sym=='off')):
        cRPA.job_complete()
        break
    elif ((conv==1) & (auto_sym=='on')):
        cRPA.nosym_input()
                 
    cRPA.mixing_input(mixing)
    cRPA.job_submit(n,bash_comd,check_period,job_echo)


        

