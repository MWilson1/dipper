#!/usr/bin/env python

import os
import time
import numpy as np

def stateq 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       stateq 
    # 
    # PURPOSE: 
    #   stateq  solves statistical eqm equations for escape program 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       stateq, /help 
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
    #       eqsyst, invert 
    # 
    # COMMON BLOCKS: 
    #       catom, cesc 
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
    @cdiper 
    @cse 
    # 
    #  set up and solve statistical equilibrium matrix equation 
    # 
    bb=lvl.ev*0.D0 
    ratem 
    aa=matrix 
    k = INDGEN(atom.nk) 
    for i  in np.arange( 0,atom.nk): 
        diag , = np.where(k != i) 
        aa(i,i) = -np.sum(matrix(i,diag)) 
    # 
    #  fix isum 
    # 
    isum = atom.nk-1 
    zpeak = SQRT(temp/1.e4) 
    mini = (MIN(lvl.ion) >  int(np.round(zpeak)) <  MAX(lvl.ion) 
    j , = np.where(lvl.ion  == mini) 
    isum = j(0) 
    #messdip,'isum=0',/inf 
    isum = 0 
    sc = nstar >   1.d-100 
    sc = sc/np.sum(sc) 
    # 
    bb(isum)=totn 
    AA(*,isum)=1.D0 
    for i  in np.arange( 0,atom.nk): 
        aa(*,i) = aa(*,i)*sc 
    aa=transpose(aa) 
    aold = aa 
    eqsyst,aa,bb#,improve = 2 
    n=bb*sc 
    RETURN 
 
