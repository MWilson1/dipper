#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: ar85ci.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 13, 1996 
# 
# Last Modified: Tue Jul 25 13:32:46 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def ar85ci,new, all=all 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       ar85ci 
    # 
    # PURPOSE: Gets collisional ionization data from Arnaud and Rothenflug 1985. 
    #       Looks up and computes collisional ionization (direct 
    #       ionization and collisional excitation followed by 
    #       auto-ionization) keyword data for collisional ionization rate 
    #       calculations. 
    # 
    # EXPLANATION: 
    #       This procedure opens an ASCII database file (on first call 
    #       only- 
    #       and matches the correct data there to those stored in catom. 
    # 
    # CALLING SEQUENCE: 
    #       ar85ci, coldata 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       coldata.  The collisional structure defined by colstrt. Any 
    #       existing data are completely over-written. 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    #       debug=debug 
    #       all=all Will find data for all levels 
    # CALLS: 
    #       colstrt, atomn, terms, ground_terms 
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
    #       Calculation of atomic rate coefficients 
    # PREVIOUS HISTORY: 
    #       Written August 13, 1996, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, August 13, 1996 
    #- 
    # 
    @cdiper 
    COMMON CAR85, AR85TAB 
    # 
    IF (N_PARAMS(0) < 1): 
        print('ar85ci,coldata,debug=debug' 
        RETURN 
    # 
    # 
    new=coldef 
    colnew = new 
    # 
    IF(len(ar85tab) == 0): 
    fil = concat_dir(getenv('DIPER'),'data') 
    fil= concat_dir(fil,'ar85ci.dat') 
    messdip,/inf,'Reading file '+fil 
    OPENR,lu,/get,fil 
    nci=0 
    READF,lu,nci 
    ar85tab=fltarr(8,nci) 
    READF,lu,ar85tab 
    FREE_LUN,lu 
# 
#  get atomic number 
# 
iz = atomn(getwrd(atom.atomid,0)) 
IF(iz < 1 OR iz > 92): 
print('ar85cdi: element out of range, iz=',iz 
RETURN 
# 
index = gterms(gtot=gtot) 
IF(len(all) != 0): 
messdip,'case /all not coded ' 
index = 1 + intarr(nk) 
#   term = terms(label,glev = g,gterm = gterm) 
#   gtot = gterm 
 
# 
# define stuff from ar85tab 
# 
jtab=REFORM(FIX(ar85tab(0,*))) 
itab=REFORM(FIX(ar85tab(1,*))) 
# 
# now loop over levels with index=1 to obtain levels for which AR85 
# keyword should be computed. 
# 
ii=-1 
nk = atom.nk 
ev = lvl.ev 
ion = lvl.ion 
g = lvl.g 
for i in range(nk-2+1): 
IF(index(i) == 1): 
for j in np.arange(i+1,nk): 
IF(index(j) == 1 AND ion(j) == ion(i)+1): 
yes, = np.where(jtab == iz AND itab == ion(i),kount) 
IF(kount > 0): 
ii=ii+1 
nd= kount*5 
grnd , = np.where(ion == ion(i)) 
minev = MIN(ev(grnd)) 
grnd = grnd(!c) 
colnew.key='AR85-CDI' 
colnew.nt=nd 
# 
# fix to preserve total ionization rates 
# 
ifix=fltarr(nd) 
ifix(0)=1. 
ifix(1:*)=g(j)/gtot(j) 
colnew.temp=0.*FINDGEN(nd) 
colnew.ilo=i 
colnew.ihi=j 
delt = ev(i)-ev(grnd) 
for o in range(kount): 
    colnew.data(o*5:o*5+4)=ar85tab(3:*,yes(o))*ifix 
for o in range(kount): 
    colnew.data(o*5) = colnew.data(o*5)-delt 
new = [new,colnew] 
# 
# CEA keyword 
# 
ii=ii+1 
nd= 2# dummy 
colnew.key='AR85-CEA' 
colnew.nt=nd 
colnew.temp=0.*FINDGEN(nd) 
colnew.data=colnew.temp 
colnew.data(0)=g(j)/gtot(j) 
colnew.ilo=i 
colnew.ihi=j 
new = [new,colnew] 
IF(ii <= 0): 
messdip,/inf,'No collisional data implemented' 
RETURN 
new = new(1:*) 
new.ref = 'Arnaud, M. and Rothenflug, R.: 1985, An updated evaluation of recombination and ionization rates'', AA Suppl. Ser. 60, 425# Arnaud, M. and Raymond, J.: 1992, Iron ionization and recombination rates and ionization equilibrium, Ap. J. 398, 394' 
# 
# 
RETURN 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'ar85ci.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
