#!/usr/bin/env python

import os
import time
import numpy as np

def roman,i 
    # 
    z9 = ['','I','II','III','IV','V','VI','VII','VIII','IX'] 
    decades = ['','X','XX','XXX','XL','L','LX','LXX','LXXX','XC'] 
    lab = strarr(len(z9)*len(decades)) 
    for ij  in np.arange( 0,len(decades)): 
        for j  in np.arange( 0,len(z9)): 
            k = ij*10+j 
            lab(k) = decades(ij)+z9(j) 
    n=len(lab) 
    ii=i 
    a=size(ii) 
    if(a(1) == 0) : 
    return ' ' 
if(a(1) == 1) : 
ii=[ii] 
ni=len(ii) 
str=strarr(ni) 
j, = np.where(ii <= n,kount) 
if(kount > 0) : 
str(j)=lab(i(j)) 
k, = np.where(ii > n,kount) 
if(kount > 0) : 
str(k)='>'+lab(n-1) 
if(ni == 1) : 
str=str(0) 
return str 
 
