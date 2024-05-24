#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: lud.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 11, 1995 
# 
# Last Modified: Fri Aug 11 10:03:47 1995 by judge (Phil &) on pika 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def lud,a 
    #+ 
    #   lud,a 
    # 
    #            lu decomposition of a 
    #            based on EQSYST - variable band matrix solver 
    #- 
    common ceqsyst,n,lastn 
     
    # 
    # argument checks 
    # 
    if (n_params(0) == 0): 
        print('lud,a' 
        return 
    dum=size(a) 
    if (dum(0) != 2): 
        print('argument is not a two dimensional matrix' 
        return 
    if (dum(1) != dum(2)): 
        print('argument is not a square matrix' 
        return 
    n=dum(1) 
     
    lastn=intarr(n) 
    # 
    # find the last non-zero element in each row 
    # 
    for k in range(n): 
        iw, = np.where(a(*,k)) 
        lastn(k)=max(iw) 
    # 
    #  column loop: eliminate elements below the diagonal in column l. 
    # 
    for l in range(n-2+1): 
        # 
        #  row loop: add fraction -a(l,k)/a(l,l) of row l to row k 
        # 
        for k in np.arange(l+1,n): 
            if(a(l,k) != 0.0): 
            a(l,k)=-a(l,k)/a(l,l) 
            lastn(k)=lastn(k)>lastn(l) 
            if (l+1 <= lastn(l)): 
                a(l+1,k)=a(l+1:lastn(l),k)+a(l,k)*a(l+1:lastn(l),l) 
 
return 
 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'lud.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
