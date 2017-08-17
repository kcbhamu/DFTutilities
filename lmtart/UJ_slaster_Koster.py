# This code is a quick calculator to Slaster-Koster integral 
# from U and J

# Parameters ================================
U=5  # must be eV (Gd:6.7)
J=U/7  # must be eV (Gd:0.7)
orb='d' # 'd' / 'f'
unit_out='Ry'  # 'eV', 'Ry', 'Ha'
# Main ======================================

F=[0]*4
if orb=='d':
    F[0]=U
    F[1]=((1+5/8)/14)**(-1)*J
    F[2]=5/8*F[1]
elif orb=='f':
    F[0]=U
    F[1]=((286+195*451/675+250*1001/2025)/6435)**(-1)*J
    F[2]=451/675*F[1]
    F[3]=1001/2025*F[1]

    
if unit_out=='Ry':
    F_Ry=lambda F: F/13.6
    F=tuple(map(F_Ry,F))
elif unit_out=='Ha':
    F_Ry=lambda F: F/27.2
    F=tuple(map(F_Ry,F))

print('Slaster-Koster integrals:')
if orb=='f':
    print('F0=%f, F2=%f, F4=%f, F6=%f' % F )
elif orb=='d':
    print('F0=%f, F2=%f, F4=%f' % F[0:-1] )