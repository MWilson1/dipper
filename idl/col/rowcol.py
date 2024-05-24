#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: rowcol.pro 
# Created by:    judge, June 24, 2006 
# 
# Last Modified: Sat Jun 24 13:08:00 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def rowcol,i,irow,icol 
    # 
    # returns the row and column of the element in 
    # the periodic table- the row is the "period", but 
    # the column is just the order in which elements occur 
    # in the row.  it is not the "group" 
    # 
    istart = [0,2,10,18,36,54,86] 
    for  j in range(5+1): 
        if(i > istart(j) and i <= istart(j+1)):irow=j 
    icol=i-istart(irow) 
    irow = irow+1# 
    return 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'rowcol.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
