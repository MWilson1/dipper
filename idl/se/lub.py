#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: lub.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 11, 1995 
# 
# Last Modified: Fri Aug 11 10:04:29 1995 by judge (Phil &) on pika 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def lub,a,b 
    #+ 
    #   lub,a,b 
    # 
    #            lu back substitution 
    #            a is lu decomposition of matrix, b is rhs 
    #            based on EQSYST - variable band matrix solver 
    #- 
    common ceqsyst,n,lastn 
    # 
    # argument checks 
    # 
    if (n_params(0) == 0): 
        print('lub,a,b' 
        return 
    dum=size(a) 
    if (dum(0) != 2): 
        print('argument 1 is not a two dimensional matrix' 
        return 
    if (dum(1) != dum(2)): 
        print('argument 1 is not a square matrix' 
        return 
    n=dum(1) 
    dum=size(b) 
    if (dum(0) != 1): 
        print('argument 2 is not an array' 
        return 
    if (dum(1) != n): 
        print('matrix and rhs have different dimensions' 
        return 
     
    for l in range(n-2+1): 
        b(l+1)=b(l+1:n-1)+a(l,l+1:n-1)*b(l) 
    # 
    # backsubstitute 
    # 
    for k in np.arange(n-1,0,): 
        if((k <= n-2) and (k+1 <= lastn(k))): 
        b(k)=b(k)-np.sum(a(k+1:lastn(k),k)*b(k+1:lastn(k))) 
    b(k)=b(k)/a(k,k) 
 
return 
 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'lub.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
