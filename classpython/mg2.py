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

plt.rcParams.update({'font.size': 14})
plt.rcParams.update({'lines.linewidth': 2.})


el=8
isos=3
z=el-isos+1
#atom=dp.diprd(el,el-isos+1,True)
diprd_init=dp.diprd(el,el-isos+1,True)
atom = diprd_init.atom
lvl=atom['lvl']
ip=dp.dippyClass.iprd()
ipj=ip[el,z]*ee
print(ip[el,z])
print(ee)

e=dp.dippyClass.dict2array(lvl,'e',float)* hh*cc # erg
pqn=dp.dippyClass.dict2array(lvl,'pqn',int)
l=pqn*0.
nstar=l*0.

for i in range(0,len(lvl)):
    orb1= lvl[i]['orb1']
    p=math.floor(orb1/100)
    pqn[i]=p
    #pqn[i]= lvl[i]['pqn']
    ll=orb1-p*100
    ll=math.floor(ll/10)
    l[i] = ll
    # from ip-E = ryd*z*z / nstar^2
    dej = (ipj-e[i]) 
    nstar[i]= z * np.sqrt( rydinf/ dej )
    print(i, pqn[i]-nstar[i],lvl[i]['label'],'PQN  =  ', pqn[i], '  L  = ',l[i])

delt=pqn-nstar



lab=['S','P','D','F']
for s in range(0,3):
    ok= (l == s).nonzero()
    plt.plot(pqn[ok],0*pqn[ok]+delt[ok],'.-',label=lab[s])



plt.xlabel(r'principal QN $n$')
plt.ylabel(r'$\delta_n$')

plt.title('Quantum defects for '+dp.dippyClass.atomname(el)+ ' '+dp.dippyClass.roman(z))
plt.legend()             
plt.tight_layout()
plt.savefig('mg2.png')
plt.show()
plt.close()

#subprocess.run(["open", "mg2.png"]) 



