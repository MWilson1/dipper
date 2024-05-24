#!/usr/bin/env python

import os
import time
import numpy as np

def arab,inp 
    z9 = ['','I','II','III','IV','V','VI','VII','VIII','IX'] 
    decades = ['','X','XX','XXX','XL','L','LX','LXX','LXXX','XC'] 
    lab = strarr(len(z9)*len(decades)) 
    for ij  in np.arange( 0,len(decades)): 
        for j  in np.arange( 0,len(z9)): 
            k = ij*10+j 
            lab(k) = decades(ij)+z9(j) 
    # 
    n=len(lab) 
    a=len(inp) 
    ii=strupcase(inp) 
    if(a < 1) : 
    return 0 
if(a == 1) : 
ii=[ii] 
ni=len(ii) 
int=intarr(ni)-1 
for i in range(ni): 
j, = np.where(ii(i) == lab,kount) 
if(kount == 1): 
int(i)=j 
else: 
int(i)=0 
if(a == 1) : 
return int(0) 
return int 
 
