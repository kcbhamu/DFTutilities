import DFTtoolbox.structure as structure
# this code convert the atom label shown in VESTA to the 
# conventional label number used in abinit or QE
# Parameters ===============================
search_list=[['Te',1],['Po',2],['O',1],['O',5],['O',18],['O',21],\
['Ba',1],['Ba',5],['O',10],['O',13]]
#search_list=[['Ba',4],['Ba',8],['O',11],['O',16],['Te',4],['Po',3],\
#['O',4],['O',8],['O',19],['O',24]]
wkdir='D:\\Work\\A2TePoO6\\'
prefix='Ba2TePoO6_slab'
# Main =====================================
mystr=structure.structure()
atom, a_vec, sublat=mystr.getxsf(wkdir,prefix)
atom=mystr.atom_name(atom)


at_num=[]
tot_search=len(search_list)
for n in range(0,tot_search):
    tmp_num=[i for i, at_i in enumerate(atom) if at_i==search_list[n][0]]
    at_num.append(tmp_num[search_list[n][1]-1]+1)
    print(at_num[-1],end=' ')
    
print()