#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: burcalc.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, January 17, 1995 
# 
# Last Modified: Wed Aug  9 14:24:02 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def burcalc,new,all=all 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       burcalc 
    # 
    # PURPOSE: calculates rate coefficients for thermal electron impact ionization. 
    # 
    # EXPLANATION: 
    #       creates new structure coldata that contains keyword and data 
    #       for collisional ionization using Burgess and Chidichimo 
    #       (1983) MNRAS 203, 1269-1280, equation (6) and references to that. 
    #       If the species contains levels belonging to a neutral ion, the keyword 
    #       data are changed to Seaton's SEF as given by Allen, C.W., II (p42). 
    # 
    # CALLING SEQUENCE: 
    #       burcalc, coldata 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    # 
    # OUTPUTS: 
    #       coldata - the collisional keyword for use with HAO's DIPER package. 
    #                 this is completely over-written if defined on input. 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /all    Will compute data for all levels (not just those above the 
    #       ground term) 
    # CALLS: 
    #      colstrt, ground_terms,atomn,cicalc 
    # 
    # COMMON BLOCKS: 
    #       catom 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       Data for coldata is overwritten 
    # 
    # CATEGORY: 
    #       rate coefficients 
    # PREVIOUS HISTORY: 
    #       Written January 13, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    #       Bug fixed for neutral case April 23, 1996, P. Judge 
    # VERSION: 
    #       Version 1, January 13, 1995 
    #- 
    # 
    @cdiper 
    # 
    if (n_params(0) < 1): 
        print('burcalc,coldata,all=all' 
        return 
    new= coldef 
    colnew = new 
    # 
    # 
    #  get atomic number 
    # 
    ELEM= strupcase(str(getwrd(atom.atomid,0),2)) 
    IZ=atomn(ELEM)# 
    if(iz < 1 or iz > 92): 
    messdip,'element out of range, iz='+strn(iz) 
    return 
# 
#  get ground terms 
# 
index = gterms(gtot=gtot) 
includ=index*0+1 
if(len(all) == 0) : 
includ(where(index == 1))=0 
# 
ii=-1 
nk = atom.nk 
ion = lvl.ion 
g = lvl.g 
for i in range(nk-2+1): 
if(includ(i) == 1): 
for j in np.arange(i+1,nk): 
    if(index(j) == 1 and ion(j) == ion(i)+1): 
    ii=ii+1 
    nd= 1 
    colnew.key='BURGESS' 
    colnew.nt=1 
    colnew.ilo=i 
    colnew.ihi=j 
    # 
    # fix to preserve total ionization/recombination rates 
    # 
    ifix=g(j)/gtot(j)# ionization scaling, fine structure 
    colnew.data(0) = ifix 
    new = [new,colnew] 
if(ii < 1): 
messdip,'BURCALC: no collisional ionization data implemented',/inf 
return 
new=new(1:*) 
new.ref = 'Burgess A. and Chidichimo M. C. 1983: MNRAS 203, 1269-1280, equation (6)' 
# 
#  special case of neutrals 
# 
k , = np.where(ion(new.ilo) == 1, kount) 
IF(kount > 0): 
messdip,'neutral species- changing to Seaton''s SEF',/inf 
cicalc,neut 
new(k) =  neut(k+1) 
RETURN 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'burcalc.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
