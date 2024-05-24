#!/usr/bin/env python

import os
import time
import numpy as np

 
def bfwgrid,dummy,verbose=verbose 
    #  + 
    #  returns wavelength grid for the Bound Free continua 
    #  into a structure cont 
    # 
    #          cont.desc = 'w: wavelength in Angstrom, i=intensity erg/cm3/s/A' 
    #          cont.w= wavelength grid determined from database 
    #          cont.i=in  erg/cm3 /s/Angstrom, set to zero 
    # 
    #  A grid logarithmic in wavelength but with important 
    #  abundant edges included.   On first call only the 
    #  data files from DIPER are accessed and the array wcont returned. 
    #  - 
    # 
    @cdiper 
    @cse 
    if(len(wcont) != 0): 
    cont={desc:'',w:wcont,i:wcont*0.} 
    cont.desc = 'w: wavelength in Angstrom, i=intensity erg/cm3/s/A' 
    return cont 
 
# 
lmn=0.# min log wavelength in Angstrom 
lmx=5. 
ppd=50# number of points per decade 
wl=lmn+ findgen((lmx-lmn)*ppd)/ppd 
wl=10.**wl 
print(minmax(wl) 
# 
# 
delta=1.0001 
# 
dbopen,'abund' 
dbext,1,'abund',abund 
k, = np.where(abund > 6.)+1 
dbclose 
dbopen,'atom_ip' 
xtra=wl(0)*.9 
if(len(verbose) == 0) : 
verbose=0 
if(verbose) : 
print('Photoionization edge wavelengths:' 
for ii in range(len(k)): 
str= 'atom = '+string(k(ii))+' , ion < 2' 
j=dbfind(str,/sil) 
dbext,j,'ip',ip 
w= hce/ip 
if(verbose) : 
print(atomn(k(ii)),w,form='(a2,2x,2(f11.2))' 
wl=[wl,w*delta,w/delta] 
dbclose 
# 
# Add in a few important ones from excited levels 
# 
# H balmer k 
for nc in np.arange(2,5+1): 
print('H n =',nc 
w=hce/13.595*nc*nc 
wl=[wl,w*delta,w/delta] 
# 
# C I  1D 
w=1240.31 
wl=[wl,w*delta,w/delta] 
# C I  1S 
w=1445.73 
wl=[wl,w*delta,w/delta] 
wcont=wl(np.argsort(wl)) 
cont={desc:'',w:wcont,i:wcont*0.} 
cont.desc = 'w: wavelength in Angstrom, i=intensity erg/cm3/s/A' 
return cont 
 
