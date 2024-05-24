#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: gterms.pro 
# Created by:    Philip G. Judge, June 7, 1996 
# 
# Last Modified: Wed Aug  2 18:00:59 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def gterms,gtot=gtot 
    #+ 
    #    find levels belonging to ground terms 
    #    Modification History 
    #    Written by P. Judge 04-Mar-1994 
    #    Updated June 7, 1996, P. Judge, uses meta common block variable from qn 
    #- 
    # 
    @cdiper 
    # 
    gtot=lvl.g*0. 
    index = fix(gtot) 
    mn = min(lvl.ion) 
    mx = max(lvl.ion) 
    iterm = nla(lvl.orb(2))+nla(lvl.orb(1))+nla(lvl.orb(0))+   slp(lvl.term(2))+slp(lvl.term(1))+slp(lvl.term(0)) 
    for i  in np.arange( mn,mx+1): 
        same , = np.where(lvl.ion == i) 
        emn = min(lvl(same).ev) 
        ignd = same(!c) 
        ok , = np.where(iterm == iterm(ignd)) 
        index(ok) = 1 
        gtot(ok) = np.sum(lvl(ok).g) 
    # 
    return index 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'ground_terms.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
