#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_label_nr.pro 
# Created by:    Philip G. Judge, September 5, 1996 
# 
# Last Modified: Sun Jun  4 11:09:21 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_label_nr, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_label_nr 
    # 
    # PURPOSE: sets labels for use with term diagram, to index of level, lowest = 1 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       td_label_nr, 
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
    #       cdiper, ctermdiag 
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
    @cdiper 
    @ctermdiag 
    IF(len(help) > 0): 
   :c_library,'td_label_nr' 
    RETURN 
for i in range(atom.nk): 
    term_label(i)=str(STRING(i+1),2) 
# 
RETURN 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_label_nr.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
