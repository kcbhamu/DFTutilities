blah_val=7
pass_val=[]
for n1 in range(0,10):
	for n2 in range(n1,10):
		for n3 in range(n2,10):
			for n4 in range(n3,10):
				test_val=n4*1000+n3*100+n2*10+n1
				if (n4**2+n3**2+n2**2+n1**2)%59 == blah_val:
					pass_val.extend([test_val])
pass_val.sort()
print(pass_val)					