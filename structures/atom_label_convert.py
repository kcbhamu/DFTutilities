'''
This code is to help find the relation between the atom number between
species-based and total-atom based labels. 
It is particular to use in combined with VESTA, where the atom labels
are species-based but in most ab initio codes are total-atom based. 
'''
# Parameters ===========================================
search_list=['Bi',4,'O',9,'Bi',3,'O',12,'Bi',2,'O',1,'Bi',1,'O',4]
at_label=\
' Sr \
 Sr \
 Sr \
 Sr \
 Ca \
 Ca \
 Cu \
 Cu \
 Cu \
 Cu \
 Bi \
 Bi \
 Bi \
 Bi \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O \
  O '
 
# Main ==================================================
at_label=at_label.split()
at_num=[]
tot_search=int(len(search_list)/2)
for n in range(0,tot_search):
    tmp_num=[]
    [tmp_num.append(m) for m, txt in enumerate(at_label) if txt==search_list[2*n]]
    at_num.append(tmp_num[search_list[2*n+1]-1])

for n in range(0,tot_search):
    print(search_list[2*n]+str(search_list[2*n+1])+'-'+str(at_num[n]+1))

