####################################################################################################
# MAIN 
####################################################################################################
import numpy as np
from matplotlib import pyplot as plt
import time
import subprocess
import platform
import dippy as dp

dippy_regime='coronal'

print()
print('**************************************************')
print('demo ionization equilibrium')
print(dippy_regime)
print('**************************************************')
print()

ions=np.arange(5,dtype=int)+2
#ions=np.arange(4,dtype=int)+3
atom=dp.diprd_multi(6,ions) 

atom=dp.redatom(atom,lowestn=True)
#atom=dp.redatom(atom,meta=True)
a=dp.check(atom)
a=dp.level(atom)
a=dp.trans(atom)
a=dp.col(atom)
lvl=atom['lvl']
nl=len(lvl)

tlog = np.arange(4.0,7.0,0.05)
ne=1.e10
m=len(tlog)

nout= np.zeros((m,nl))
count=-1

ne=1.e10
for tl in tlog:
    count+=1
    te=10.**tl
    n,nstar,w,e,lhs=dp.se(atom,te,ne)
    nout[count,:]=n
    emx=np.max(e)
    emn=np.min(e)
    #print('!!! ', emn,emx)

mx=np.nanmax(nout)
print(np.shape(nout))
emx=np.nanmax(e)
print(mx)

for i in range(len(lvl)):
    plt.plot(tlog,nout[:,i]/mx)
plt.yscale('log'),
plt.ylim(1.e-6,2.)
plt.xlim(np.min(tlog),np.max(tlog))
plt.xlabel('Log10 T')
plt.ylabel('Carbon ions: relative level populations')
plt.savefig('demo_ioneq.png')
print(' open demo_ioneq.png')
subprocess.run(["open", "demo_ioneq.png"]) 
print(' success')
####################################################################################################

    
