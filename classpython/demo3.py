####################################################################################################
# MAIN 
####################################################################################################
import numpy as np
from matplotlib import pyplot as plt
import time
import subprocess
import platform
import dippy as dp
from astropy.io import ascii


#plt.rc('text', usetex=True)
#plt.rc('font', family='serif')



diprd_init=dp.diprd(1,1,False) 
lvl=diprd_init.atom['lvl']
for i in range(0,len(lvl),1000):
    print(i,lvl[i]['label'])
print('LEN ',len(lvl))

lvl=diprd_init.atom['lvl']
nl=len(lvl)

ne=1.e11
te=70000.
lhs=np.zeros((nl,nl),float)
n,nstar,w,e,lhs,cmatrix=diprd_init.se(te,ne)


lhs=np.loadtxt('ctab.dat')
for i in range(0,10):  lhs[i,i]=-lhs[i,i]


im=plt.imshow(np.log10(np.clip(lhs,1.e-2,1.e9)),interpolation='nearest',cmap='Blues')

x=np.arange(0,11,dtype=float)
plt.plot(x,'k')
plt.colorbar(im)
plt.xlabel('Level index')
plt.ylabel('Level index')
plt.title(r"C+ to C4+ log rate matrix sec$^{-1}$")
plt.savefig('demo3c.png')
plt.show()
plt.close()

lhs=np.loadtxt('htab.dat')
for i in range(0,10):  lhs[i,i]=-lhs[i,i]

im=plt.imshow(np.log10(np.clip(lhs,1.e-2,1.e9)),interpolation='nearest',cmap='Blues')

plt.plot(x,'k')
plt.colorbar(im)
plt.xlabel('Level index')
plt.ylabel('Level index')
plt.title("Hydrogen log rate matrix sec$^{-1}$")
plt.savefig('demo3h.png')
plt.show()

#subprocess.run(["open", "demo3h.png"]) 
#subprocess.run(["open", "demo3c.png"]) 


####################################################################################################

    
