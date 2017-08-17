# This code is written by python
# input the file name
fid1=open('C:/Users/pipidog/Desktop/New folder/incubator/referrals.csv','r')
fid2=open('C:/Users/pipidog/Desktop/New folder/incubator/fellows.csv','r')

# read referral list
fid1.seek(0); fid1.readline(); user_read=[]
while 1==1:
	ID1=fid1.read(12)
	if len(ID1) ==0 :
		break
	ID2=fid1.readline()
	if len(ID2) == 2:
		ID2='blank'
	else :
		ID2=ID2[1:len(ID2)-1]
	user_read=user_read+[[ID1,ID2]]
	
# read fellow list
fid2.seek(0); fid2.readline(); fel_read=[]
while 1==1:
	ID1=fid2.read(13)
	ID1=ID1[0:12]
	if len(ID1) ==0 :
		break
	fel_read=fel_read+[ID1]

# searching the index of an input name in applicant pool
def user_index(inp_name):
	for n in range(len(user_read)):
		if user_read[n][0] == inp_name :
			return n

# convert from random names to integers
user_list=[]; ref_list=[]
for n in range(len(user_read)):
	if user_read[n][1] != 'blank' :
		tmp=user_index(user_read[n][1])
		user_list=user_list+[[n,tmp]]
		ref_list=ref_list+[tmp]
	else :
		user_list=user_list+[[n,'blank']]
fel_list=[]
for n in range(len(fel_read)):
	fel_list=fel_list+[user_index(fel_read[n])]

# check fellows who are through referral  (Problem Q4.1)
referred_fellow=0
for n in range(len(fel_list)):
	if 	fel_list[n] in ref_list :
		referred_fellow=referred_fellow+1
print('Rate of fellows through referral=',referred_fellow/len(fel_list))

# searching for applicants who referred any one of input indices
def ref_search(inp_indices):
	referee=[]
	for n in range(len(user_list)):
		if user_list[n][1] in inp_indices :
			referee=referee+[n]
	return referee

# calculate viral coefficient (Problem Q4.2)
viral_coff=0
for n in range(len(user_list)):
	viral_coff=viral_coff+len(ref_search([user_list[n][0]]))
viral_coff=viral_coff/len(user_list)
print('Viral_coff=',viral_coff)

# calculate ultimate referred (Problem Q4.3)
# Not very sure what does this problem mean. So, calculate
# (all the nodes in the referral tree)/(people who referred anyone)
# tot_layer should be large enough until len(referee) = 0 
tree_layer=10; referee=range(0,len(user_list)); tot_node=0
for n in range(tree_layer):
	referee=ref_search(referee[:])
	tot_node=tot_node+len(referee)
avg_node=tot_node/len(ref_list)
print('ultimate referral=', avg_node)
	
# calculate reward money (Problem Q4.4)
tot_layer=10; tot_reward=0; ref_layer=[]
referee=fel_list[:]
for n in range(tot_layer):
	referee=ref_search(referee[:])
	tot_reward=tot_reward+2**(11-n)*len(referee)
	ref_layer=ref_layer+[referee]
print('tot_reward=',tot_reward)