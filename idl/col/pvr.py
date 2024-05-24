#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: pvr.pro 
# Created by:    Philip Judge, March 3, 2006 
# 
# Last Modified: Sun Mar 12 12:28:09 2006 by judge (Philip Judge) on niwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def pvr,z,b 
    # 
    #  thermal p-function for semic empirical collision rates 
    #  reference: sobel'man - 'atomic physics ii.  ' 
    #  z (Scalar) is 1 for neutrals 
    #  b (scalar) = energy / kT 
    # 
    # 
    IF(b <= 0.01): 
    # wrong   p = 0.27566 * (0.577 + alog(b)) 
    p = 0.29*expint(1,b) 
    return p 
# 
#  intermediate temps (most important for eqm plasmas) 
#  linear interpolation onto logb grid: 
# 
IF(b > 0.01 and b < 10.0): 
betref = [-2.0,-1.699,-1.398,-1.0,-0.699,-0.398,0.0,0.301,0.602,1.0] 
pnref = [1.160,0.956,0.758,0.493,0.331,0.209,0.100,0.063,0.040,0.023] 
pcref =  [1.160,0.977,0.788,0.554,0.403,0.290,0.214,0.201,0.200,0.200] 
IF(z == 1): 
linterp,betref,pnref,alog10(b),p 
else: 
linterp,betref,pcref,alog10(b),p 
return p 
# 
IF(b >= 10.): 
IF(z == 1): 
p = 0.066 / sqrt(b) 
else: 
p = 0.200 
return p 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# end of 'pvr.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
