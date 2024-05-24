#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: bhanleav.pro 
# Created by:    judge, May 20 2022 
# 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def bhanleav,wmin,wmax,verbose=verbose 
    #+ 
    # gives average multiple Hanle B for transitions in wavelength range 
    # wmin, wmax 
    #- 
    @cdiper 
    lo =  wmin < wmax 
    up =  wmax > wmin 
    w=convl(trn.alamb) 
    k, = np.where(w > wmin and w < wmax) 
    u=trn[k].jrad 
     
    glande=lvl[u].glande 
    bhanle=trn[k].a*hh/2/pi/bohrm/glande 
    bad, = np.where(lvl[u].g < 3,count) 
    if(bad[0] != -1 and count > 0 )  :# unpolarizable 
    bhanle[bad] = !values.f_nan 
print('bhanle[bad]',bhanle[bad] 
 
list=k 
list = where (bhanle == bhanle) 
 
den = lvl[u[list]].g 
num= bhanle[list] * den 
av=np.sum(num)/np.sum(den)# bhanle*lvl[u].g,/nan)/total(lvl[u].g,/nan) 
 
 
if(len(verbose) != 0): 
trans,list=k(list) 
print('average =',av,form='(82x,a,  e9.2)' 
import pdb; pdb.set_trace() 
return  av 
 
#;;;;;;s;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'bhanleav'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
