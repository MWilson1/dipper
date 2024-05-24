#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: geff.pro 
# Created by:    judge, August 4, 2006 
# 
# Last Modified: Fri Aug  4 18:07:19 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def geff,lv1,lv2,gtrans=gtrans 
    #+ 
    #  effective lande G factor in the small field limit 
    #  given lande g-factors and J values and energies in structures 
    #  lvl1 and lvl2. 
    #  CORRECTED ERROR in first term of geff 2016 June 30 
    #  keyword gtrans added 18 mar 2022 PGJ. 
    #- 
    lo =  lv1 
    up =  lv2 
    IF(lv1.ev > lv2.ev): 
    lo = lv2 
    up = lv1 
# 
jlo = (lo.g-1.)/2. 
jup = (up.g-1.)/2. 
g = (lo.glande+up.glande)/2. + 0.25*(lo.glande-up.glande)*    ((jlo*(jlo+1.)) - jup*(jup+1.)) 
# 
#  gtrans is the second order Lande factor from Landi & Landini 
# 
# eq 9.77 9.78 of L&L2004 and table3.4 
# 
s= jlo*(jlo+1.) + jup*(jup+1.) 
d= jlo*(jlo+1.) - jup*(jup+1.) 
gd=lo.glande-up.glande 
 
 
delta= gd*gd/80. *(16.*s-7.*d*d-4.) 
gtrans= g*g - delta 
 
return g 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'geff.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
