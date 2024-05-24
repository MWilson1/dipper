#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: clockit.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, September 28, 1995 
# 
# Last Modified: Thu Sep 28 21:21:33 1995 by judge (Phil &) on pika 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def clockit,procname,i,ndata,percent, help=help,reset=reset 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       clockit 
    # 
    # PURPOSE: 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       clockit, 
    # 
    # INPUTS: 
    # 
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
    #       Written September 28, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, September 28, 1995 
    #- 
    # 
    COMMON clockit, t0,iper 
    IF(len(help) > 0): 
   :c_library,'clockit' 
    RETURN 
# 
IF(len(t0)   == 0  OR len(reset) != 0): 
t0 = time.time() 
iper = 1 
RETURN 
# 
perc=FLOAT(percent * ndata)/100. 
sofar = iper*perc 
#str = '' &  READ,str 
iii=i-sofar 
if(iii >= 0.): 
x=time.time() 
per = iper*(perc*100/ndata) 
tleft =   (100-per)/percent*(x-t0) 
mleft = FIX(tleft)/60 
sleft = tleft-60*mleft 
print(procname+' calculation ',per, '%:ne, time remaining ',      mleft,' min  ',sleft,' sec',      form =  '(a,i3,a,i4,a,f5.1,a)' 
iper=iper+1 
t0 = x 
 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'clockit.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
