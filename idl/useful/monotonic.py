#!/usr/bin/env python

import os
import time
import numpy as np

def monotonic,xarr 
    # + 
    # test for monotonicity 
    # output +1 for increasing 
    # output -1 for decreasing 
    # output  0 for non-monotonic 
    # - 
    aa=size(xarr) 
    if(aa(1) < 1) : 
    return 1 
npt=aa(1)-1 
ans=0 
i = xarr - shift(xarr,1) 
i = i(1:*) 
a , = np.where(i > 0,k) 
if (k == npt) : 
    return 1 
a , = np.where(i < 0,k) 
if (k == npt) : 
    return -1 
return  ans 
 
