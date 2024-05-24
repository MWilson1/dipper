#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_set_krcol.pro 
# Created by:    Philip G. Judge, September 5, 1996 
# 
# Last Modified: Sun Jun  4 13:34:59 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_set_col, dummy, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_set_col 
    # 
    # PURPOSE: initializes termdiag common-block variables for color 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       td_set_col, 
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
    #       cdiper,ctermdiag 
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
   :c_library,'td_set_col' 
    RETURN 
# Default colors 
 
c_label_space=0 
c_label=-1 
c_arrow=-1 
 
IF(!d.name != 'PS'): 
krcolor=intarr(atom.nrad)+!p.color 
else: 
krcolor=intarr(atom.nrad)+1 
 
RETURN 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_set_krcol.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
 
