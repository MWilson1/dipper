#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: vreg.pro 
# Created by:    Philip Judge, March 12, 2006 
# 
# Last Modified: Thu Aug 10 12:41:19 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def vreg,temp = temp 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       impact 
    # 
    # PURPOSE:  add or replace existing collisional rate coeffs. by Van regemorter 
    #           values 
    # 
    # EXPLANATION: 
    #        Oscillator strength data in common block catom are used to compute 
    #        data for col 
    # 
    # CALLING SEQUENCE: 
    #        vreg 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       col 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    # 
    #       temp=temp  electron temperature grid for Maxwell averaged collision 
    #                   strengths. 
    # 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       rimpact 
    # 
    # COMMON BLOCKS: 
    #       catom, cqn 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    #       Calculation of approximate electron-atom collision rate coefficients. 
    # 
    # PREVIOUS HISTORY: 
    #       Written May 31, 1996, by Philip G. Judge 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, May 31, 1996 
    #- 
    # 
    @cdiper 
    # 
    ndata=atom.nline 
    IF(ndata == 0): 
    messdip,'VREG: no oscillator strengths in common catom, data unchanged',/inf 
    return 
# 
messdip,'VREG: Computing collisional data from Van Regemorter''s approx.',/inf 
nmax=40 >  len(temp) 
colnew=coldef 
# 
hi=col.ihi > col.ilo 
lo=col.ihi < col.ilo 
# 
for kr in range( atom.nline): 
    ihi = trn(kr).jrad 
    ilo = trn(kr).irad 
    ej = lvl(trn(kr).jrad).ev 
    ei = lvl(trn(kr).irad).ev 
    IF(ei > ej): 
    ilo = trn(kr).jrad 
    ihi = trn(kr).irad 
ty = trn(kr).type 
kk, = np.where(hi == ihi AND lo == ilo,kount) 
# 
# does collisional transition exist? if not, add data 
# 
IF(kount == 0 AND (ty == 'E1')): 
z = lvl(ilo).ion 
IF(len(temp) == 0): 
temp = 3.0+FINDGEN(8)*0.3 
temp=(10.**temp)*z*z# 
gf = trn(kr).f*lvl(ilo).g 
delte = lvl(ihi).ev-lvl(ilo).ev# 
beta = delte*ek/temp 
# Van regemorter gives 
#  cji = 20.60 lambda^3 pvr Aji /sqrt(T) 
# with lambda in cm, Aji lambda^3=0.6670 gf lambda / gu 
# and lambda = hh*CC/ee/deltae=1.240e-04/deltae,then 
#  cji = .6670 gf/gu  1.24e-04/deltae pvr /sqrt(T) 
#  so cji = 1.704e-03 gf/gu pvr /sqrt(T) 
# and omega = 197.5 gf pvr / delte 
# 
omega = temp*0. 
for ii  in np.arange( 0,len(omega)): 
omega(ii) = 197.5*gf*pvr(z,beta(ii))/delte 
# fill arrays 
str = str(STRING(trn(kr).f,form = '(e9.2)'),2)+', LAM= '+str(STRING(trn(kr).alamb),2) 
colnew.key='OHM    :VAN REG.('+ty+') F='+str 
colnew.ihi=ihi 
colnew.ilo=ilo 
colnew.data=omega 
colnew.temp=temp 
colnew.nt=len(temp) 
colnew.approx = 1 
colnew.ref = 'Van Regemorter, H.: 1962, Rate of Collisional Excitation in Stellar Atmospheres,  ApJ 136, 906' 
col=[col,colnew] 
RETURN 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'vreg.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
