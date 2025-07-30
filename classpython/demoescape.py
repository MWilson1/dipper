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

#dippy_regime=0

diprd_init = dp.diprd(7,3,True)

atom = diprd_init.redatom( lowestplus=True )
atom = diprd_init.redatom( lowestn=True )
lvl = atom['lvl']
for i in range(0,len(lvl)):
    print(lvl[i]['label'])
te=.5e5
nne= 1.e9
length=1.e12
vturb=1.e6
#
n,powr=diprd_init.nrescape(te,nne,length,vturb)  # alpha
#
print('populations')
print(n)
print('power')
bb=atom['bb']
w=np.zeros(len(bb))
for kr in range(0,len(bb)):
    w[kr]=bb[kr]['wl']
    print('powr ',kr, ' ',w[kr],' ',powr[kr])


plt.xlim([500.,2000.])
plt.ylim([1.e-11,1.e-7])

s=np.argsort(w)
plt.plot(w[s],powr[s],'.')
plt.yscale('log')
plt.show()



