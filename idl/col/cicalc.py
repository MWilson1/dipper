#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: cicalc.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, January 13, 1995 
# 
# Last Modified: Wed Aug  9 14:24:50 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def cicalc,new,all=all 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       cicalc 
    # 
    # PURPOSE: 
    #       computes collision ionization rate coefficient data, outputs keyword data 
    #       using the semi-empirical formula of seaton (1962) 
    #       as given by allen ii (p42), in structure coldata 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       cicalc, coldata 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       coldata - the collisional keyword for use with HAO's DIPER package. 
    #                 this is completely over-written if defined on input. 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    #       /all    Will compute data for all levels (not just those above the 
    #       ground term) 
    #       /burgess Will compute using Burgess+Chidichimo1983 (MNRAS 203,1269) 
    #       equation (6) 
    # CALLS: 
    #      colstrt, ground_terms,atomn 
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
    # 
    # PREVIOUS HISTORY: 
    #       Written January 13, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    #  Written  by P. Judge 8-June-1992 
    #  Modified by P. Judge 8-Mar-1994. Takes into account fs levels 
    #  Modified by P. Judge 14-Jun-1994: Indexing bugs corrected 
    # 
    # VERSION: 
    #       Version 1, January 13, 1995 
    #- 
    @cdiper 
    if (n_params(0) < 1): 
        print('cicalc,coldata,all=all' 
        return 
     
    # 
    new=coldef 
    colnew = new 
    # 
    #  get atomic number 
    # 
    ELEM= strupcase(str(getwrd(atom.atomid,0),2)) 
    IZ=atomn(ELEM)# 
    if(iz < 1 or iz > 92): 
    print('cicalc: element out of range, iz=',iz 
    return 
# 
#  get ground terms 
# 
index = gterms(gtot=gtot) 
includ=index*0+1 
if(len(all) == 0) : 
includ(where(index == 1))=0 
t=[1.e2,1.e9] 
ntt=len(t) 
c1=1.1e-08 
c2=2.3e-08 
# 
#  ii=0 : temp case 
# 
colnew.key='TEMP' 
colnew.nt=ntt 
colnew.temp=t 
colnew.data = t 
colnew.ilo=-1 
colnew.ihi=-1 
new = colnew 
# 
ev = lvl.ev 
g = lvl.g 
ion = lvl.ion 
nk = atom.nk 
ii = 0 
for i in range(nk-2+1): 
if(includ(i) == 1): 
for j in np.arange(i+1,nk): 
    if(index(j) == 1 and ion(j) == ion(i)+1): 
    ii=ii+1 
    nd= 2 
    colnew.key='CI' 
    colnew.temp=t 
    colnew.nt=ntt 
    # 
    # fix to preserve total ionization/recombination rates 
    # 
    ifix=fltarr(2)+1.0 
    ifix(0)=g(j)/gtot(j)# ionization scaling, fine structure 
    ifix(1)=g(j)/gtot(j)# ionization scaling, fine structure 
    colnew.ilo=i 
    colnew.ihi=j 
    if(ion(i)  == 1): 
    const=c1 
else: 
    const=c2 
colnew.data(0:ntt-1) = const / (ev(j)-ev(i))**2*ifix*lvl(i).active 
new = [new,colnew] 
new = new(1:*) 
if(ii < 1): 
messdip,/inf,'CICALC: no collisional ionization data implemented' 
else: 
new.ref = 'Seaton''s semi empirical formula for neutrals, section 18 of  Allen, C.~W.: 1973, Astrophysical Quantities, Athlone Press, Univ. London.' 
# 
return 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'cicalc.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
