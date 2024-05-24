#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: dipdef.pro 
# Created by:    Philip Judge, February 27, 2006 
# 
# Last Modified: Wed Aug 16 21:43:52 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def dipdef 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       dipdef 
    # 
    # PURPOSE: define common block structures used in atomic data 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       dipdef 
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
    #       Reads 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, February 24, 2006 
    #- 
    # 
    @cdiper 
    # 
    # define the structures to be carried together 
    # the first type 'level' belongs to the levels 
    # the second type 'trans' belongs to transitions. 
    # 
    #;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    # 
    # structure atom 
    # 
    atom = {atom,atomid:'',abnd:0.0,awgt:0.0,nk:0l,nline:0l,nrad:0l} 
    # 
    # structure 'levels': 
    # 
    lvl = {lvl,ev:0.d0,label:'',ion:0,g:0.0,coupling:'',glande:0.,       n:0, eff:0.0, smalll:0, active:0, tsp1:0, bigl:0,        parity:'', tjp1:0, term:intarr(3), orb:intarr(3), meta:0, ref:''} 
    # 
    # structure 'trn': 
    # 
    mq = 76# maximum number of allowed wavelengths for each transition 
    trn={trn,irad:0,jrad:0,alamb:0.d0,f:0.0,qmax:0,q0:0.,nq:0,     q:fltarr(mq),wq:fltarr(mq),frq:fltarr(mq),alfac:fltarr(mq),     ga:0.,gw:0.,gq:0.,a:0.,bij:0.,bji:0.,type:'',multnum:0,ref:''} 
    # 
    # structure 'col' 
    # 
    mcol = 40# maximum number of data temperatures for collisional tables 
    col={col,nt:0,     temp: fltarr(mcol),      key: '' ,      ihi: 0, ilo:0,      lab: '' ,     type:0,     approx:0,     data: fltarr(mcol),     ref:''} 
    # 
    # structure 'hdr': 
    # 
    key=['NAME','ISOSEQUENCE','LEVELS', 'ENERGIES','ENERGIES-ERR','ENERGIES-NOT','B-B_TRANSITIONS',      'GFS-REF','GFS-ERR','GFS-NOT','PHOTOIONIZATION', 'B-B_COLLISIONS',      'OHM-REF','OHM-ERR','OHM-NOT','B-F COLLISIONS', 'INPUT_BY', 'UPDATED', 'REGIME','WARNING'] 
    ndata = len(key) 
    hdr=replicate({hdr,key:'   ', text:' '}, ndata) 
    hdr.key=key 
    # 
    # default values 
    # 
    atomdef = atom 
    lvldef = lvl 
    trndef = trn 
    coldef = col 
    hdrdef = hdr 
    # 
    return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'dipdef.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
