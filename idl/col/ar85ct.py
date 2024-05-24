#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: ar85ct.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 13, 1996 
# 
# Last Modified: Wed Aug  9 12:31:04 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def ar85ct,new,read=read 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       ar85ct 
    # 
    # PURPOSE: Gets charge transfer data from Arnaud and Rothenflug 1985. 
    #       Looks up and computes collisional ionization and recombination by 
    #      (charge transfer) for  rate calculations. 
    # 
    # EXPLANATION: 
    #       This procedure opens an ASCII database file (on first call 
    #       only- the file is getenv('SDP_ATOM')+'/data/'+'ar85ct.dat') 
    #       and matches the correct data there to those stored in catom. 
    # 
    # CALLING SEQUENCE: 
    #       ar85ct, coldata 
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
    #       read=read Will force reading of data 
    # CALLS: 
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
    COMMON CAR85CT, TABHR, TABHER, TABHI, TABHEI 
    # 
    if (n_params(0) < 1): 
        chkarg,'ar85ct' 
        return 
    # 
    # 
    new=coldef 
    colnew = new 
    IF(len(tabhr) == 0 OR len(READ) > 0): 
    fil = concat_dir(getenv('DIPER'),'data') 
    fil= concat_dir(fil,'ar85ct.dat') 
    messdip,/inf,'Reading file '+fil 
    OPENR,lu,/get,fil 
    nci=0 
    READF,lu,nci 
    IF(nci > 0): 
    tabhr=fltarr(8,nci) 
    READF,lu,tabhr 
READF,lu,nci 
IF(nci > 0): 
tabher=fltarr(8,nci) 
READF,lu,tabher 
READF,lu,nci 
IF(nci > 0): 
tabhi=fltarr(8,nci) 
READF,lu,tabhi 
READF,lu,nci 
IF(nci > 0): 
tabhei=fltarr(8,nci) 
READF,lu,tabhei 
FREE_LUN,lu 
# 
#  get atomic number 
# 
ELEM= strupcase(str(getwrd(atom.atomid,0),2)) 
IZ=atomn(ELEM)# 
if(iz < 1 or iz > 92): 
print('ar85ct: element out of range, iz=',iz 
return 
index = gterms(gtot=gtot) 
# 
#  loop over different keywords 
# 
key=['AR85-CH','AR85-CHE','AR85-CH+','AR85-CHE+'] 
ii=-1 
nk = atom.nk 
g = lvl.g 
ion = lvl.ion 
for kk in range(3+1): 
if(kk == 0 and len(tabhr) > 0): 
tab=tabhr 
recom = 1 
 else if(kk == 1 and len(tabher) > 0): 
tab=tabher 
recom=1 
 else if(kk == 2 and len(tabhi) > 0): 
tab=tabhi 
recom=0 
 else if(kk == 3 and len(tabhei) > 0): 
tab=tabhei 
recom=0 
 else goto, end1 
# 
# define stuff from tab 
# 
jtab=reform(fix(tab(0,*))) 
itab=reform(fix(tab(1,*))) 
# 
# now loop over levels with index=1 to obtain levels for which AR85 
# keyword should be computed. 
# 
for i in range(nk-2+1): 
if(index(i) == 1): 
out=i# collisions from this level, default is up 
for j in np.arange(i+1,nk): 
if(recom) :# collisions are down 
out=j 
if(index(j) == 1 and ion(j) == ion(i)+1): 
yes, = np.where(jtab == iz and itab == ion(out),kount) 
if(kount > 0): 
ii=ii+1 
nd= 6 
colnew.key=key(kk) 
colnew.nt=nd 
# 
# fix to preserve total ionization rates 
# 
ifix=fltarr(nd)+1.0 
ifix(2)=g(j)/gtot(j) 
colnew.temp=0.*findgen(nd) 
colnew.data=tab(2:*,yes(0))*ifix 
ihi=j 
ilo=i 
# 
#  change direction for recombination 
# 
if (recom): 
ihi=i 
ilo=j 
colnew.ilo=ilo 
colnew.ihi=ihi 
new = [new,colnew] 
 
if(ii < 0) : 
return 
messdip,/inf,'AR85CT: charge transfer data implemented' 
new = new(1:*) 
new.ref = 'Arnaud, M. and Rothenflug, R.: 1985, An updated evaluation of recombination and ionization rates'', AA Suppl. Ser. 60, 425# Arnaud, M. and Raymond, J.: 1992, Iron ionization and recombination rates and ionization equilibrium, Ap. J. 398, 394' 
# 
return 
 
 
