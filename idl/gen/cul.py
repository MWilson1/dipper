#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: cul.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 13, 1996 
# 
# Last Modified: Tue Dec 30 11:05:35 2003 by judge (Philip Judge) on niwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def cul,kr,wran=wran,waves=waves, help=help,_extra=_extra 
    #+ 
    # PROJECT: 
    #       HAOS-DIAPER 
    # 
    # NAME: 
    #       cul 
    # 
    # PURPOSE: 
    #       lists transitions with a common upper level 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       cul 
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
    #       common catom 
    # 
    # CALLS: 
    #       None. 
    # 
    # COMMON BLOCKS: 
    #       catom, cgencol 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       Produces text output to screen, updates common block variables c. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    #       Written August 13, 1996, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, August 13, 1996 
    #- 
    # 
    @cdiper 
    @cse 
    # 
    IF(len(help) > 0): 
   :c_library,'cul' 
    RETURN 
if(len(wran) == 0) : 
wran=[0,1.e37] 
# 
# 
print(' ******  Lines with common upper levels' 
print(' FOR ',atom.ATOMID 
head='Trans Lambda [A]  A        Upper level    Lower level  Br Ratio ION' 
print(head 
form='(I3,1x,f12.3,1x,e9.2,1x 2(a20,1x),1x,e9.2,1x,A)' 
page=25# length of page to scroll 
jr=trn.jrad 
ir=trn.irad 
 
count=0 
waves=0. 
allall=[0] 
for k in np.arange(1,atom.nk): 
all, = np.where(jr == k,ncul) 
w=convl(trn[all].alamb) 
ok, = np.where(w > wran[0] and  w < wran[1],nok) 
if(nok < 2) : 
goto, pass 
trans,list=all[ok],_extra=_extra 
waves=[waves,w[ok] ] 
allall=[allall,all[ok],-1] 
pass: 
waves=waves[1::] 
kr=allall[1::] 
return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'cul.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
