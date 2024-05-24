#!/usr/bin/env python

import os
import time
import numpy as np

def ltepop, plot=plot, print=print 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       ltepop 
    # 
    # PURPOSE: 
    #       Calculates LTE populations for the atom 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       ltepop,t,en,plot=plot,print=print 
    # 
    # INPUTS: 
    #       t  - electron temperature in kelvin, cannot be an array 
    #       en -electron density in /cm3, cannot be an array 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       Variable NSTAR is computed and is stored in common catom. 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    # 
    # CALLS: 
    #       None. 
    # 
    # COMMON BLOCKS: 
    #       catom 
    # 
    # RESTRICTIONS: 
    #       t, en must be scalar quantities 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    #       Written October 20, 1994, by Phil &, HAO/NCAR, Boulder CO 
    # 
    # MODIFICATION HISTORY: 
    #   Originally coded by P. Judge 1992 
    #   checked against Allen (1973)  30-Jun-1992 
    # 
    # VERSION: 
    #       Version 1, October 20, 1994 
    #- 
    # 
    @cdiper 
    @cse 
    # 
    en = len(nne) & tn = len(temp) 
    chkpar,en,'LTEPOP number of elements of nne',1,'=' 
    chkpar,tn,'LTEPOP number of elements of t',1,'=' 
    # 
    # normalization 
    # 
    nstar=dblarr(atom.nk) 
    st=size(totn) 
     
    if(st(0) == 0 or st(1) > 1): 
    ionh = hion(temp) 
    toth = 0.8*nne/ionh(1) 
    totn=10.**(atom.abnd-12.0)*toth 
 
# 
xxx = (hh/sqrt(2.d0*pi*em)/sqrt(bk)) 
ccon=0.5d0*xxx*xxx*xxx 
conl=alog(ccon*nne)-1.5*alog(temp) 
sumn=1.d0 
tns=lvl.ev*0.d0 & nstar=tns 
glog =:UBLE(alog(lvl.g)) 
# 
# reduction of ionization potential 
#  Griem 1964 formula. 
ev = lvl.ev 
mn = min(lvl.ion) 
mx = max(lvl.ion) 
for i  in np.arange( mn,mx): 
    k , = np.where(lvl.ion > i) 
    nd = 1140.*i*(temp/1.e4/(nne/1.e10))**0.25 
    ev(k) = ev(k) - rydinf*i*i/nd/nd/ee 
#stop 
# 
tnsl = glog-glog(0)-ek/temp*ev 
nk = atom.nk 
for i in np.arange(1,nk): 
    if(lvl(i).ion <= lvl(0).ion) : 
    goto, hundred 
l=lvl(i).ion-lvl(0).ion 
tnsl(i)=tnsl(i)-float(l)*conl 
hundred: 
tns(i)=exp(tnsl(i)) 
sumn=sumn+tns(i) 
# 
# 
nstar(0)=totn/sumn 
nstar(1:nk-1)=tns(1:nk-1)*nstar(0) 
pr=0 
if(keyword_set(print)) : 
pr=1 
if(pr == 1) : 
print('       ION    POPN(LTE)' 
for i in range(nk): 
k, = np.where(lvl.ion == lvl.ion(0)+i,kount) 
if(kount < 1) : 
goto, end1 
if(pr == 1) : 
print(lvl.ion(0)+i, np.sum(nstar(k)) 
 
if(pr == 1): 
print('LTEPOP: nstar' 
print(nstar 
if(keyword_set(plot)) : 
plot_io,nstar,psym=10 
 
#print,'ltepop totn ',totn 
 
return 
 
