import matplotlib.pyplot as plt
import numpy as np
import scipy.special as sp
import subprocess
import math
import dippy as dp

ee=dp.dippyClass.ee
em=dp.dippyClass.em
cc=dp.dippyClass.cc
hh=dp.dippyClass.hh
bk=dp.dippyClass.bk
pi=dp.dippyClass.pi
rydinf=dp.dippyClass.c['rydinf']

plt.rcParams.update({'font.size': 13})
plt.rcParams.update({'lines.linewidth': 2.})

plt.rcParams['figure.figsize'] = [5,5.5 ]

isos=8
lab=['s','p','d','f','g','h','i','j']


for el in range(isos+1,22):

  z=el-isos+1
  #atom=dp.diprd(el,el-isos+1,True)
  diprd_init=dp.diprd(el,el-isos+1,True)
  atom = diprd_init.atom
  if(atom['ok'] == True):
    lvl=atom['lvl']
    ip=dp.dippyClass.iprd()
    ipj=ip[el,z]*ee
    
    e=dp.dippyClass.dict2array(lvl,'e',float)* hh*cc # erg
    pqn=dp.dippyClass.dict2array(lvl,'pqn',int)
    l=pqn*0.
    nstar=l*0.

    for i in range(0,len(lvl)):
        orb1= lvl[i]['orb1']
        p=math.floor(orb1/100)
        ll=orb1-p*100
        ll=math.floor(ll/10)
        l[i] = ll
        dej = (ipj-e[i]) 
        nstar[i]= z * np.sqrt( rydinf/ dej )

    delt=pqn-nstar
    n1=np.max(pqn)-1
    mx=-1
    mn=999
    for s in range(0,n1):
        ok = (l == s).nonzero()
        c=np.count_nonzero(ok)
        div=1
        xtra=''
        if(s < 0 ):
            div=2
            xtra=r'$\div$'+str(div)
        if(c > 0):
            x=pqn[ok]
            y=delt[ok]
            if(len(x) > 0):
                plt.plot(x,y/div,'.-',label=lab[s]+xtra)
                mx = max(np.max(x), mx)
                mn = min(np.min(x), mn)

    plt.xlabel(r'principal QN $n$')
    plt.ylabel(r'$\delta_{nl}$')
    #
    #
    xt=np.arange(mn,mx+1)
    plt.xticks(xt)
    plt.title('Quantum defects for '+dp.dippyClass.atomname(el)+ ' '+dp.dippyClass.roman(z))
    plt.legend()             
    plt.tight_layout()
    
    ofil='qdefect'+str(el)+str(isos)+'.png'
    plt.show()
    plt.savefig(ofil)
    plt.close()
    
    #subprocess.run(["open", ofil]) 



