#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: ratem.pro 
# Created by:    Philip Judge, March 2, 2006 
# 
# Last Modified: Tue Aug 15 11:12:21 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
# 
def ratem, diag = diag 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       ratem 
    # 
    # PURPOSE: 
    #       Returns rate matrix from values of collision a radiative rates 
    #       in the atomic rate equations.  Output is stored in common cesc 
    #       variable MATRIX 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       ratem 
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
    #       /diag  fill diagonal components with - column sums. 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       None. 
    # 
    # COMMON BLOCKS: 
    #       None. 
    # 
    # RESTRICTIONS: 
    #       Lines only, so far 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    #       Written September 27, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, September 27, 1995 
    #- 
    # 
    @cdiper 
    @cse 
    # 
    # 
    #  matrix is the rate matrix 
    # 
    #  Note that two approaches are possible.  In the present 
    #  version 1, the net radiative bracket is not used directly in the rate matrix 
    #  but instead the incident radiation is simply iterated, through 
    #  the use of separation of rates into self-generated and incident for 
    #  both lines and continua (continua treated in bfrat.pro). 
    # 
    #  The alternative approach is to use the NRB computed in netrb.pro 
    #  directly here.  Then the Jacobian matrix computed in WMAT must 
    #  be modified to include derivatives of the net radiative bracket 
    #  with respect to incident radiation. 
    # 
    # VERSION 1************************************************************ 
    # 
    MATRIX=C 
    IF(atom.nline > 0): 
    IR=trn.irad 
    JR=trn.jrad 
    matrix(jr,ir)=matrix(jr,ir)+trn.a*pesc 
# 
# add incident radn rates to matrix through common block 
# 
# computation of incident radiation depleted by escape probabilities 
# Note: the effect of escape/attenuation is taken care of in bfrat 
# for continua 
# 
IF(atom.nline != 0)  : 
lines = indgen(atom.nline,/long) 
jbarinc = jinc(lines) * pesc(lines) 
ir = trn(lines).irad 
jr = trn(lines).jrad 
#   ok=where(jr eq 1) 
#   print,'ok' 
#   print,ok 
#   print,ir[ok],jr[ok],matrix(ir[ok],jr[ok]),jbarinc[ok]*trn(lines[ok]).bij 
#   print 
matrix(ir,jr) = matrix(ir,jr)+jbarinc*trn(lines).bij 
matrix(jr,ir) = matrix(jr,ir)+jbarinc*trn(lines).bji 
# 
# VERSION 2************************************************************ 
# 
#MATRIX=C 
#IF(nline GT 0) THEN BEGIN 
#   lines = indgen(atom.nline,/long) 
#   IR=trn.irad 
#   JR=trn.jrad 
#   matrix(jr,ir)=matrix(jr,ir)+a(lines)*nrb(lines) 
#ENDIF 
# 
# 
#  add bound-free rates 
# 
bfrat 
# 
#  add effects of missing high n levels (singly excited) 
# 
highn 
IF(len(diag) != 0): 
ii = indgen(atom.nk) 
for i  in np.arange( 0,atom.nk): 
k , = np.where(ii != i) 
matrix(i,i) =  - np.sum(matrix(i,ii)) 
# 
return 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'ratem.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
