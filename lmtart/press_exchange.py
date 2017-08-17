# this code is to perform series calculation of lmtart 
import os, sys, time 

# class ================================================================
class press_Jmat:
    def __init__(self,wkdir,prefix,lmt_command,a_range,a_int):
        # chek wkdir format
        if (wkdir[-1]!='/') | (wkdir[-1]!='\\'):
            wkdir+='/'
            
        # fetch a0 and tot_q 
        with open(wkdir+'template/'+prefix+'.ini','r') as file:
            for line in file:
                if line.find('Par0')!=-1:
                    self.a0=float(line[line.find('=')+1:line.find('!')])

        with open(wkdir+'template/'+prefix+'.pnt','r') as file:
            for line in file:
                if line.find('Nqpnt')!=-1:
                    self.tot_q=int(line[line.find('=')+1:line.find('!')])            

        self.wkdir=wkdir
        self.prefix=prefix
        self.a_range=a_range
        self.a_int=a_int
        self.lmt_command=lmt_command
        print('class initialized:')
        print('a0=%8.5f, tot_q=%3i' % (self.a0,self.tot_q))
        print('lmt_command={0}',format(self.lmt_command))
        print('-------------------')
    def __grep__(self,txtlines,kws):
        # search for text line numbers where keywords appear
        ln=[ n for n, line_n in enumerate(txtlines) if line_n.find(kws)!=-1]
        
        return ln     
        
    def __submit_write__(self,task,a_n,q_point=None,node_exclude='',priority='high'):
        # generate template of submit
        subtext=[]
        subtext.append('#!/bin/bash -l\n')
        subtext.append('\n')
        subtext.append('#SBATCH --job-name='+self.prefix+'-'+str(a_n)+'/'+task+'\n')
        subtext.append('#SBATCH --partition='+priority+'\n')
        subtext.append('#SBATCH --time=48:00:00\n')
        subtext.append('#SBATCH --ntasks=1\n')        
        if node_exclude!='':
            subtext.append('#SBATCH --exclude='+node_exclude+'\n')
        
        subtext.append('\n')
        subtext.append('hostname > hostname.dat\n')
        #subtext.append('rm -f /tmp/*.scr* \n')
        subtext.append(self.lmt_command+' << Go! > log\n')
        subtext.append(self.prefix+'-'+str(a_n)+'\n')
        if task=='scf':
            subtext.append('ini+str+scs+hub\n')
            subtext.append('scf+hbr+out\n')
        elif task=='fat':
            subtext.append('ini+str+scs+hub\n')
            subtext.append('fat\n')
        elif task=='dos':
            subtext.append('ini+str+scs+hub\n')
            subtext.append('dos\n')
        elif task=='frs':
            subtext.append('ini+str+scs+hub\n')
            subtext.append('frs\n')            
        elif (task=='jey'):
            if q_point==None :
                print('Error: q_point not given!\n')
                sys.exit()
            else:
                subtext.append('ini+str+scs+hub+ihi+pnt\n')
                subtext.append('getjey+ '+str(q_point)+' to '+str(q_point)\
                +' from '+str(self.tot_q)+'\n')
        else:
            print('Error: __submit_write__, taks not regonized!')
            sys.exit()
        subtext.append('Go!\n')
        
        return subtext
        
    def __exclude_node__(self,check_a_n,max_job_per_node):
        # check nodes to exclude
        # check_a_n, subfolder to check their node, e.g. [80,82,84]
        # max_job_per_node, e.g. 3
        nodelist=[]
        for a_n in check_a_n:
            subdir=self.wkdir+self.prefix+'-'+str(a_n)+'/'
            while True:
                try:
                    file=open(subdir+'hostname.dat','r')
                except IOError:
                    time.sleep(0.5)
                else:
                    if (a_n==check_a_n[-1]):
                        print('     '+subdir+'hostname.dat located !')
                    nodelist.append(file.readline()[0:-1])
                    file.close()
                    break
        
        
        exclude_node=[node_set_n for node_set_n in set(nodelist)\
        if (nodelist.count(node_set_n)>=max_job_per_node)]
        
        # convert exclude_node to standard string format
        exclude_node_str=''
        for ex_node_n in exclude_node:
            exclude_node_str+=ex_node_n+',' 
                
        return exclude_node_str[0:-1]
        
    def dos_gen(self,E_range=[-10,10,200]):
        # E_range in eV around Ef, e.g. [-10,+5]
        a=list(range(self.a_range[0],self.a_range[1]+1,self.a_int))
        for n, a_n in enumerate(a):
            subdir=self.wkdir+self.prefix+'-'+str(a_n)+'/'
            subprefix=self.prefix+'-'+str(a_n)
            with open(subdir+subprefix+'.scs') as file:
                flines=file.readlines()
                Ef=float(flines[-1].split()[0])
                
            with open(subdir+subprefix+'.dos','w') as file:
                file.write(' <FILE=DOSFILE,INPUT=MODERN>\n')
                file.write(' ****************************************************\n')
                file.write(' <SECTION=CTRL> \n')
                file.write(' EminDos = %8.5f\n' % (Ef+E_range[0]/13.6))
                file.write(' EmaxDos = %8.5f\n' % (Ef+E_range[1]/13.6))
                file.write(' nEnrDos = %i\n' % E_range[2])
                file.write(' nDiv(:) = 12 12 12 \n')
            print(subprefix+' Ef=%8.5f (Ry), DOS range=%8.5f ~ %8.5f (Ry)' % \
            (Ef,Ef+E_range[0]/13.6,Ef+E_range[1]/13.6))

    def reconstruct(self):
        check=input('Are you sure you want to delete all folders (y/n)? ')
        if check!='y':
            sys.exit()
        
        print('Begin reconstructing all subdirectories')    
        a=list(range(a_range[0],a_range[1]+1,a_int))
        for n, a_n in enumerate(a):        
            subdir=self.wkdir+self.prefix+'-'+str(a_n)+'/'
            print(' => reconstruct '+subdir)
            os.system('rm -rf '+subdir)
            os.system('mkdir '+subdir)
            os.system('cp '+self.wkdir+'template/* '+subdir)
            
            # rename all files
            flist=os.listdir(subdir)
            for fname in flist:
                if fname.find(self.prefix)!=-1:
                    os.system('mv '+subdir+fname+' '\
                    +subdir+self.prefix+'-'+str(a_n)+fname[-4:]) 
            
            # change lattice constant
            with open(subdir+self.prefix+'-'+str(a_n)+'.ini','r') as file:
                flines=file.readlines()
                for n, line_n in enumerate(flines): 
                    if line_n.find('Par0')!=-1:
                        flines[n]=' Par0 = '+('%7.4f' % (self.a0*a_n/100))\
                        +'          ! lattice parameter in a.u.\n'
                        break
                        
            with open(subdir+self.prefix+'-'+str(a_n)+'.ini','w') as file:
                file.writelines(flines)        

    def submit_task(self,task,q_point=None,max_job_per_node=None,ex_node_0=None,priority='high'):
        a=list(range(a_range[0],a_range[1]+1,a_int))
        if ex_node_0==None:
           ex_node_0=''
        else:
            ex_node_0+=','
            
        for n, a_n in enumerate(a):
            print('***** preparing '+self.prefix+'-'+str(a_n)+' for submit *****')
            print(' => check whether to rename hbr and scf')
            os.chdir(self.wkdir+self.prefix+'-'+str(a_n)+'/')
            if os.path.isfile('hostname.dat'):                 
                os.system('rm hostname.dat')
            if os.path.isfile(prefix+'-'+str(a_n)+'.hbr'):                 
                os.system('mv '+prefix+'-'+str(a_n)+'.hbr '+prefix+'-'+str(a_n)+'.hub ')
                print('    hbr file renamed')
            if os.path.isfile(prefix+'-'+str(a_n)+'.scf'):
                os.system('mv '+prefix+'-'+str(a_n)+'.scf '+prefix+'-'+str(a_n)+'.scs ')
                print('    scf file renamed')
            
            print(' => check exclude nodes')            
            if (n!=0) & (max_job_per_node!=None):
                ex_node=ex_node_0+self.__exclude_node__(a[0:n],max_job_per_node)
            else:
                ex_node=ex_node_0
                
            if (ex_node==''):
                print('    no node exclude!')
            else:
                print('    '+ex_node+' exclude!')
                
            print(' => rewriting submit file of '+self.prefix+'-%3i' % a_n)
            with open('submit','w') as file:
                file.writelines(\
                self.__submit_write__(task,a_n,q_point,ex_node,priority))
            os.system('sbatch submit')   


# Main ===============================
if __name__=='__main__':
    # parameters =====================
    task='dos' # reconstruct / scf / fat / dos / jey / frs
    wkdir='/home/pipidog/work/lmtart/Eu/pnma-afm/U5-LDA/'
    prefix='Eu'
    lmt_command='srun /home/savrasov/main.exe'
    a_range=[80,120]
    a_int=2
    q_point=1
    ex_node_0=None  # default=None
    priority='high'
    dos_range=[-0.5,0.5,200] # only for dos_gen, [E_max,E_mix,E_div]
    max_job_per_node=None
    # run ============================
    Eu=press_Jmat(wkdir,prefix,lmt_command,a_range,a_int)
    if task=='reconstruct':
        Eu.reconstruct()
    elif task=='dos':
        Eu.dos_gen(dos_range)
        Eu.submit_task(task,q_point,max_job_per_node,ex_node_0,priority)
    else:
        Eu.submit_task(task,q_point,max_job_per_node,ex_node_0,priority)
