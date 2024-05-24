#!/usr/bin/env python

import os
import time
import numpy as np

def hpop 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       hpop 
    # 
    # PURPOSE: 
    #   To give approx h populations, for a given electron temperature and density 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       hpop 
    # 
    # INPUTS: 
    #       None. 
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
    #       Variable NH is computed and is stored in common cesc. 
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
    #       Written October 20, 1994, by Phil &, High Altitude Observatory/NCAR, Boulder CO 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, October 20, 1994 
    #- 
    # 
    @cse 
    nh=dblarr(6)*0 
    nh(5)=nne*0.8 
    t = temp 
    p=hion(t,/caseb) 
    nh(0) = p(0)/p(1)*nh(5) 
    return 
 
# 
 
 
