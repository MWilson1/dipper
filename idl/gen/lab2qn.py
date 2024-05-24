#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: lab2qn.pro 
# Created by:    Philip Judge, March 8, 2006 
# 
# Last Modified: Wed Aug  2 09:45:29 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def lab2qn,energy,g,label,ion,ref,ok = ok 
    #+ 
    # NAME:  lab2qn     (function) 
    # 
    # PURPOSE:  fills quantum numbers in lvl structure from label 
    # 
    # CALLING SEQUENCE: 
    #       Result = lab2qn(energy,g,label,ion,ref) 
    # 
    # INPUTS: 
    #       name - name of atom for which data should be acquired 
    #       e.g. 'C' or 6 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       result is the same type of structure as lvl in diper 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       none 
    # 
    # COMMON BLOCKS: 
    #       None. 
    # 
    # RESTRICTIONS: 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    #       Part of the HAOS-DIPER. 
    # 
    # VERSION: 
    #       Version 1, August 7, 1995 
    #- 
    # 
    @cdiper 
    ok = 0 
    up = 'SPDFGHIJKLMNOPQRSTUVXYZ' 
    nup = STRLEN(up) 
    lo = STRLOWCASE(up) 
    level = lvldef 
    level.ev = energy 
    level.g = g 
    level.tjp1 = g 
    level.label = label 
    #print,'lab2qn', level.g,g,level.tjp1 
    level.ion = ion 
    level.ref = ref 
    # 
    lab2int,label,g,term,orb,coupling,ok = ok 
    # 
    level.coupling = coupling 
    level.term = term 
    level.orb = orb 
    # 
    level.n = orb(0)/100# principal qn 
    level.smalll = (orb(0) - level.n*100)/10# small l of outer electron 
    level.active = orb(0)-level.n*100-level.smalll*10# number of outer electrons 
    # 
    level.tsp1 = term(0)/100 
    level.bigl = (term(0)-level.tsp1*100)/10 
    par = term(0)-level.tsp1*100 - level.bigl*10 
    pp = ['E','O'] 
    if(par == 0 or par == 1): 
    level.parity = pp(par) 
else: 
    print('No parity in label :',label 
# 
level.glande = 0. 
level.eff = -1. 
# 
IF level.coupling == 'LS': 
    sss = 0.5*(level.tsp1-1.) 
    lll = float(level.bigl) 
    jjj = 0.5*(level.g-1.) 
    level.glande = glan_ls(sss,lll,jjj) 
 
return level 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'lab2qn.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
