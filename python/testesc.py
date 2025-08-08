def synspec(atom,n,powr,resolution):
    bb=atom['bb']
    hh=const()['hh']
    cc=const()['cc']
    pi=const()['pi']
    bk=const()['bk']
    em=const()['em']
    esu=const()['eesu']
    uu=const()['uu']
    #
    alpha = pi * esu*esu/em/cc
    lvl=atom['lvl']
    nk=len(lvl)
    e  = dict2array(lvl,'e',float)
    g  = dict2array(lvl,'g',float)
    label = dict2array(lvl,'label',str)
    bb=atom['bb']
    ntrans=len(bb)
    wmax=0.
    wmin=1.e2
    for kr in range(0,ntrans):
        f=bb[kr]['f']
        wl_ang=bb[kr]['wl']
        w_cm=wl_ang/1.e8
        if(w_cm < wmin): wmin=wcm
        if(w_cm > wmax): wmax=wcm
    wbin=0.
    wmean=(wmin+wmax)/2.
    dw=wmean/resolution/2/sqrt(np.log10(2.))
    wave = 1


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

dippy_regime=0

atom=dp.diprd(7,3,True)
atom=dp.redatom(atom,lowestplus=True)
atom=dp.redatom(atom,lowestn=True)
lvl=atom['lvl']
for i in range(0,len(lvl)):
    print(lvl[i]['label'])
te=.5e5
nne= 1.e9
length=1.e12
vturb=1.e6
#
n,powr=dp.nrescape(atom,te,nne,length,vturb)  # alpha
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
    
