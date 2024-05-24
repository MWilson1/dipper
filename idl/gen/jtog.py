#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: jtog.pro 
# Created by:    Philip G. Judge, May 6, 1996 
# 
# Last Modified: Wed Jun  5 01:07:23 1996 by judge (Philip G. Judge) on astpc10.uio.no 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def jtog, j, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       jtog() 
    # 
    # PURPOSE: converts a j to a g (total ang momentum to degeneracy) 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       Result = jtog() 
    # 
    # INPUTS: 
    #       j  string or integer or real array or scalar, e.g. '5/2','5',[5,2] 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       None. 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       None. 
    # 
    # COMMON BLOCKS: 
    #       None. 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    #       Written May 6, 1996, by Philip G. Judge 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, May 6, 1996 
    #- 
    # 
    if(len(help) > 0): 
   :c_library,'jtog' 
    return -999 
# 
jj = j 
aa = SIZE(j) 
ac = len(aa) 
IF(aa(ac-2) == 1): 
jj = [jj] 
gg = fltarr(aa(ac-1)) 
# 
# type of variable 
# 
IF(aa(ac-2) == 7):#string variable 
for i  in np.arange( 0,len(jj)): 
k = STRPOS(jj(i),'/') 
IF(k != -1): 
first = Float(getwrd(jj(i),0,0,delim = '/')) 
second = Float(getwrd(jj(i),1,1,delim = '/')) 
aj = first/second 
else: 
aj =  Float(jj(i)) 
 
gg(i) = 2.*aj+1. 
else: 
gg = 2*JJ+1. 
return gg 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'jtog.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
