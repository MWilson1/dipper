#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_line_dx_center.pro 
# Created by:    Philip G. Judge, September 5, 1996 
# 
# Last Modified: Thu Sep  5 23:18:04 1996 by judge (Philip G. Judge) on judgepc.hao.ucar.edu 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_line_dx_center, dummy, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_line_dx_center 
    # 
    # PURPOSE: set end-point displacements of lines in term diagram at central level 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       td_line_dx_center, 
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
    #       ctermdiag 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    #       low level term diagram routine 
    # PREVIOUS HISTORY: 
    #       Original coding Mats Carlsson circa 1988 
    #       Updated headers September 5, 1996, by Philip G. Judge 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, September 5, 1996 
    #- 
    # 
    @ctermdiag 
    IF(len(help) > 0): 
   :c_library,'td_line_dx_center' 
    RETURN 
# 
max_dx_line=2 
max_dx_cont=2 
idx(*)=1 
jdx(*)=1 
# 
# 
return 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_line_dx_center.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
 
