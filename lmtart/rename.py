import os, shutil
# Parameters ===========================
wkdir=os.path.dirname(os.path.realpath(__file__))+'/'
name_inp='test0'
name_out='test100'

# Main =================================
flist=os.listdir(wkdir)
print(wkdir)
for fname in flist:
    if fname.find(name_inp)!=-1:
        print('rename '+fname+' to '+name_out+fname[-4:])
        shutil.move(wkdir+fname,wkdir+name_out+fname[-4:])
