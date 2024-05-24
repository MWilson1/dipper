#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: slp.pro 
# Created by:    Phil Judge, High Altitude Observatory/NCAR, Boulder CO, March 25, 2002 
# 
# Last Modified: Thu Aug  3 17:14:14 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def slp,islp,ispin,ill,ipar,idl = idl 
    @cdiper 
    ispin = islp/100 
    ill = (islp-ispin*100)/10 
    ipar = (islp-ispin*100 -ill*10) 
    # 
    strl = strmid(designations,ill,1) 
    sspin = string(ispin) 
    par = ['E','O'] 
    spar = par(ipar) 
    IF(len(idl) != 0): 
    sspin = '!u'+sspin+'!n' 
    strl = strupcase(strl) 
    IF(spar == 'O'): 
    spar = '!u'+strlowcase(spar)+'!n' 
else: 
    spar = '' 
return strcompress(sspin+strl+spar,/remove_all) 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'slp.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
