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



atom=dp.diprd(26,2,False) 
lvl=atom['lvl']
for i in range(0,len(lvl),1000):
    print(i,lvl[i]['label'])
print('LEN ',len(lvl))

lvl=atom['lvl']
nl=len(lvl)

bb=atom['bb']
print(dp.keyzero(bb))
print(bb[3]['wl'])
k=38
count=0
for i in range(0,len(bb)):
    w=bb[i]['wl']
    if(bb[i]['j'] == k):
        count+=1
        j=bb[i]['j']
        if(count ==1): print(lvl[j]['label'])
        print(j, ' ',w, ' ',bb[i]['f'],' ', bb[i]['aji']*lvl[j]['lifetime'])



    
