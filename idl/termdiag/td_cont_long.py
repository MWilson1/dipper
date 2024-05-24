#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_cont_long.pro 
# Created by:    Philip G. Judge, September 5, 1996 
# 
# Last Modified: Sat Jun  3 11:30:41 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_cont_long, dummy, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_cont_long 
    # 
    # PURPOSE: sets the "long continuum state bar" option, before making a term diagram 
    # 
    # EXPLANATION: 
    #       a long shaded bar is plotted to identify continuum states in atomic 
    #       model term diagrams 
    # CALLING SEQUENCE: 
    #       td_cont_long 
    # 
    # INPUTS: 
    #       none. 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       idx, jdx are modified in ctermdiag 
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
    #       cdiper, ctermdiag 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    #       term diagram procedure, low level 
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
    @cdiper 
    @ctermdiag 
    IF(len(help) > 0): 
   :c_library,'td_cont_long' 
    RETURN 
max_dx_cont=100 
npos=FIX(MAX(positions)) 
for nion in np.arange(MIN(lvl.ion),MAX(lvl.ion)):# loop through ionization stages 
    jcont=MIN(WHERE(lvl.ion == nion+1))# continuum level 
    for i in range(npos+1): 
        ikr, = np.where((positions(trn.irad) == i) AND (lvl.ion(trn.irad) == nion)                 AND (trn.jrad == jcont),count) 
        IF(count > 0): 
        IF(count == 1): 
        idx(ikr)=-50 
    else: 
        idx(ikr)=FINDGEN(count)/(count-1)*100 
    jdx(ikr)=idx(ikr)+2.*max_dx_cont*positions(trn(ikr).irad) 
 
RETURN 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_cont_long.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
