# this code convert the kpf file into standard formt of 
# different codes
# Parameters ======================================
wkdir='C:\\MyDrive\\Work\\Li2OsO3\\str\\doc'
fname='Li2OsO3.kpf'
# Main =============================================
if (wkdir[-1]!='\\') & (wkdir[-1]!='/'):
    wkdir+='/'
    
with open(wkdir+fname,'r') as file:
    flines=file.readlines()
    
k_path=[line.split() for n,line in enumerate(flines) if (line.find('0.')!=-1)]

print(len(k_path)-1)
for n in range(0,len(k_path)-1):
        print('%s-%s' % (k_path[n][-1], k_path[n+1][-1]))
        print('%s, %s, %s, %s, %s, %s' % tuple(k_path[n][0:3]+k_path[n+1][0:3]))
        
