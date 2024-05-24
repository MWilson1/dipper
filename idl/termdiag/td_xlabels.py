#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_xlabels.pro.pro 
# Created by:    Philip G. Judge, September 5, 1996 
# 
# Last Modified: Thu Sep  5 23:28:31 1996 by judge (Philip G. Judge) on judgepc.hao.ucar.edu 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_xlabels,label,ion,nk,noreset=noreset, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_xlabels.pro 
    # 
    # PURPOSE:  find positions along the x axis to plot terms in a term diagram 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       td_xlabels, label, ion, nk [,noreset=noreset] 
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
    #       Written September 5, 1996, by Philip G. Judge 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, September 5, 1996 
    #- 
    # 
    @ctermdiag 
    IF(len(help) > 0): 
   :c_library,'td_xlabels.pro' 
    RETURN 
min_pos=intarr(MAX(ion))+nk 
for i in range(nk): 
    ii=ion(i)-1 
    positions(i)=iseries(i) 
    min_pos(ii)=min_pos(ii) < positions(i)# store min position of ionization stage 
# 
#  for each ionization stage, start from position zero: 
# 
IF(len(noreset) == 0): 
for i in range(nk): 
    ii=ion(i)-1 
    positions(i)=positions(i)-min_pos(ii) 
# 
RETURN 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_xlabels.pro.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
