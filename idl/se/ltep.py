#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: ltep.pro 
# Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 15, 1994 
# 
# Last Modified: Thu Jul 20 11:59:17 2006 by judge (judge) on macniwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def ltep,temp_in,nne_in,ltep 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       ltep 
    # 
    # PURPOSE: 
    #       To give LTE populations in the same format array as sesolv 
    # 
    # CALLING SEQUENCE: 
    #          ltep,temp_in,nne_in,lte 
    # 
    # INPUTS: 
    #       temp_in floating point scalar or array of electron temperatures 
    #       nne_in  floating point scalar or array of electron densities, 
    #         (temp_in and nne_in must have the same number of elements, 
    #         nt say) 
    # 
    # OPTIONAL INPUTS: 
    # 
    # OUTPUTS: 
    #       lte  n_j floating array of dimensions (nk,nt), nk=atom.nk 
    # 
    # EXPLANATION: 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    # 
    # COMMON BLOCKS: 
    #       cdiper cse 
    # 
    # RESTRICTIONS: 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    # 
    # MODIFICATION HISTORY: 
    #   June 28, 2006, P. Judge 
    # VERSION: 
    #       Version 1, June 28, 2006 
    #- 
    # 
    @cdiper 
    @cse 
    nozeror = 0 
    IF(N_PARAMS(0) == 0): 
    chkarg,'ltep' 
    RETURN 
#dipchk 
# 
ndata = len(temp_in) 
n_ne = len(nne_in) 
if(ndata != n_ne) : 
messdip,'temp_in must be the same size as nne_in' 
ltep = dblarr(atom.nk,ndata) 
# 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# begin loop 
for i in np.arange(0l,ndata): 
temp=temp_in(i) 
nne=nne_in(i) 
ltepop 
ltep(*,i) = nstar 
return 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'ltep.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
