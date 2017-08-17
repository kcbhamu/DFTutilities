import os
# parameter ========
prefix='Eu'
wkdir='/home/pipidog/work/lmtart/Eu/pnma-afm/'
file_ext='dos'
lat_range=[80,120]
lat_int=2
# Main =============
for lat in range(lat_range[0],lat_range[1]+1,2):
    subdir=wkdir+prefix+'-'+str(lat)+'/'
    os.system('cp '+wkdir+'template/'+prefix+'.'+file_ext+' '+subdir+prefix+'-'+str(lat)+'.'+file_ext)
