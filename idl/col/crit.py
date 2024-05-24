#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: crit.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 13, 1996 
# 
# Last Modified: Tue Dec 30 11:05:35 2003 by judge (Philip Judge) on niwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def crit,te=te,file=file, list=list ,help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIAPER 
    # 
    # NAME: 
    #       crit 
    # 
    # PURPOSE: 
    #       calculates "critical densities" for given levels- i.e. those 
    #       electron densities at which collisional de-excitation equals radiative 
    #       lifetime, and prints results to the screen. 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       crit 
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
    #       /help.  Will call doc_library and list header, and return 
    #       file=file  atomic file to be read.  If not set, use data stored in 
    #       common catom, cgencol 
    #       te=te  electron temperature in degrees K.  Default = 1.e5 
    # CALLS: 
    #       None. 
    # 
    # COMMON BLOCKS: 
    #       catom, cgencol 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       Produces text output to screen, updates common block variables c. 
    # 
    # CATEGORY: 
    # 
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
    @cse 
    # 
    IF(len(help) > 0): 
   :c_library,'crit' 
    RETURN 
IF(!regime == 2): 
MESSAGE,'!REGIME ='+strn(!regime)+' - it must be 0 or 1',/inf 
MESSAGE,'action: import pdb; pdb.set_trace()' 
# 
nozeror = 0 
# 
if(len(te) == 0): 
message,'Temperature of 10**5 K used to determine critical densities',/inf 
z=np.median(lvl.ion) 
temp=5.E3*z*z 
else: 
temp=te 
if(len(list) == 0) :# all of them 
list = ' INS' 
# 
# 
nne=1.E0 
nh=fltarr(6) 
nh(5)=nne 
ltepop 
crat 
# 
# 
print(' ******  CRITICAL ELECTRON DENSITIES  [cm-3] ******' 
print(' FOR ',atom.ATOMID,' AT TEMPERATURES OF ',temp,'K' 
head='Trans Lambda [A]  A        Upper lev    Lower lev  Ne(crit) Flag  Br Ratio ION' 
head1='Sensitivity Flags: I = interstellar, N=nebular, S= solar ' 
print(head 
print(head1 
form='(I3,1x,f12.3,1x,e9.2,1x 2(a12,1x),e9.2,A2,1x,e9.2,1x,A)' 
page=25# length of page to scroll 
count=0# number outputted 
for kr in range(atom.nline): 
ir=trn(kr).irad-1 
labi=lvl[ir].label 
jr=trn(kr).jrad-1 
labj=lvl[jr].label 
cout=np.sum(c(jr,*)) 
j, = np.where(trn.jrad-1 == jr) 
br= trn(kr).a / np.sum(trn(j).a) 
ncrit = np.sum(trn(j).a)/cout 
flag=' ' 
if(ncrit < 1.e13) : 
flag='S' 
if(ncrit < 1.e7) : 
flag='N' 
if(ncrit < 1.e2) : 
flag='I' 
ionn=roman(lvl(jr).ion) 
if(count != 0 and count/page -float(count)/float(page) == 0): 
print(head 
print(head1 
str='' & read,'enter return to continue or q to quit ',str 
if(strupcase(str) == 'Q') : 
return 
if(strpos(strupcase(list),flag) != -1): 
print(kr,convl(trn(kr).alamb),trn(kr).a,labj,labi,ncrit,flag,br,ionn,form=form 
count+=1 
return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'crit.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
