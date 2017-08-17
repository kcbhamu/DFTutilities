'''
This code is submit quantum espresso jobs in NERSC cluster using debug mode.
Debug mode can only run for 30 mins. This code will autmomatically submit 
new jobs using debug mode.
'''
import sys
import os, os.path 
import time

# class ================================================
class qe_submit:
    def __init__(self,in_file):        
        # check input file
        self.in_file=in_file
        with open(self.in_file,'r') as file:
            fin=file.readlines()          
        if self.__grep(fin,'restart_mode','off')==[]:
            print('Error: input file must have: restart_mode=\'from_scratch\' !')
            sys.exit()
            
        if self.__grep(fin,'wf_collect','off')==[]:
            print('Error: input file must have: wf_collect=.true. !')
            sys.exit()
        
        if self.__grep(fin,'max_seconds','off')==[]:
            print('Error: input file must have: max_seconds=1500 !')
            sys.exit()       
            
        if os.path.isfile('CRASH'):
            os.system('rm CRASH')
			
        print('quantum espresso calculation begins (hostname='\
        +os.uname()[1], ', PID='+str(os.getpid())+')')
        
        print('\n=> start time: '\
              +time.strftime("%Y-%m-%d %H:%M:%S",time.gmtime()))

    def __grep(self,file_line,key_str,case='on'):
        ln=[] 
        if case=='on': # case sensitive
            [ln.append(n) for n, txt in enumerate(file_line)\
            if txt.find(key_str)!=-1]
        elif case=='off': # case sensitive
            [ln.append(n) for n, txt in enumerate(file_line)\
            if txt.lower().find(key_str.lower())!=-1]
        else:
            print('Error: grep, case option is not recognized!')
            sys.exit()
    
        return ln
                 
    def auto_run(self,out_file,task,period,bash_comd,userID):
        if task=='scf':
            kword='Fermi'
        elif task=='bands':
            kword='End of band'
        
        
        if os.path.isfile(out_file):
            os.system('rm '+out_file)
        os.system(bash_comd) 
        
        while True:
            while True:
                if os.path.isfile(out_file):
                    with open(out_file,'r') as file:
                        fin=file.readlines()
                    break
                else:
                    time.sleep(period)
                    
            if os.path.isfile('CRASH'):
                print('Error: job crashed!')
                sys.exit()
            
            job_conv=self.__grep(fin,kword,'on')
            job_done=self.__grep(fin,'JOB DONE','on')
            
            if (job_conv!=[]) & (job_done!=[]): # all finished
                print('\n=> calculation completed - '\
                      +time.strftime("%Y-%m-%d %H:%M:%S"\
                      ,time.gmtime()))
                break 
            elif (job_conv==[]) & (job_done!=[]): # need resubmit
                # rewrite the input file
                with open(self.in_file,'r') as file:
                    fin=file.readlines()
                
                fin[self.__grep(fin,'restart_mode','off')[0]]=\
                '                restart_mode = \'restart\' ,\n'
                
                with open(self.in_file,'w') as file:
                    file.writelines(fin)

                # submit new job
                os.system('rm '+out_file)  
                while True:
                    sbatch_msg=os.popen(bash_comd).read() 
                    print('\n=> job resubmitted - '\
                    +time.strftime("%Y-%m-%d %H:%M:%S"\
                    ,time.gmtime()))
                    print(sbatch_msg)                    
                    
                    # check if submitted successfully
                    sbatch_ID=str(int(sbatch_msg[19:-1]))
                    time.sleep(60)
                    sbatch_que=os.popen('squeue -u '+userID).read()
                    if sbatch_que.find(sbatch_ID)!=-1:
                        print('   job submission succssed')
                        break
                    else:
                        print('   job submission failed, resubmit.')
                
            
            elif (job_conv==[]) & (job_done==[]): # still running
                print('   job remains running - '\
                      +time.strftime("%Y-%m-%d %H:%M:%S"\
                     , time.gmtime()))
                time.sleep(period) 
            
# Main ============================================
if __name__=='__main__':

    # parameters ==========================
    bash_comd='sbatch submit'
    in_file='pw.scf.in'
    out_file='pw.scf.out'
    userID='stpi'
    task='bands'  # 'scf' / 'bands'
    period=60
    
    # Main =================================
    qe_job=qe_submit(in_file)
    qe_job.auto_run(out_file,task,period,bash_comd,userID)
            
