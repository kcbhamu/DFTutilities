# this code renames all the project name of w2k files.
import os
cwd=os.getcwd()+'/'
print('work folder='+cwd)
# parameter ==============================================
old_name=input('old name? ')
new_name=input('new name? ')

# main ===================================================
flist=os.listdir(cwd)
print('\n')
for fname in flist:
    if (fname.find(old_name)==0):
        ext=fname[len(old_name):]
        os.system('mv '+fname+' '+new_name+ext)
        print('mv '+fname+' '+new_name+ext)
