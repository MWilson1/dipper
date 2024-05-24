#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_lsty.pro 
# Created by:    Philip G. Judge, May 8, 1996 
# 
# Last Modified: Wed May  8 02:03:11 1996 by judge (Philip G. Judge) on astpc10.uio.no 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_lsty, sty, leg, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_lsty 
    # 
    # PURPOSE: give default linestyles for various kinds of transitions for termdiag 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       td_lsty, sty,leg 
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
    #       Written May 8, 1996, by Philip G. Judge 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, May 8, 1996 
    #- 
    # 
    IF(len(help) > 0): 
   :c_library,'td_lsty' 
    RETURN 
sty = [0,2,3,1] 
leg = ['B-B permitted','B-F','B-B spin forb.','B-B parity forb.'] 
 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_lsty.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
