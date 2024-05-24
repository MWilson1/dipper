#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: abmass.pro 
# Created by:    Randy Meisner, HAO/NCAR, Boulder CO, August 7, 1995 
# 
# Last Modified: Thu Aug 10 13:27:24 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
#+ 
# NAME:  abmass     (function) 
# 
# PURPOSE:  returns abundance and atomic weight of input atom name. 
# 
# CALLING SEQUENCE: 
#       Result = abmass(name) 
# 
# INPUTS: 
#       name - name of atom for which data should be acquired 
#       e.g. 'C' or 6 
# 
# OPTIONAL INPUTS: 
#       None. 
# 
# OUTPUTS: 
#       A two-dimensional floating point array with the first element being 
#       the cosmic abundance, and the second element being the atomic weight. 
#       Data are from section 14 of Allen 1973. 
# 
# OPTIONAL OUTPUTS: 
#       None. 
# 
# KEYWORD PARAMETERS: 
#       /help.  Will call doc_library and list header, and return 
# 
# CALLS: 
#       none 
# 
# COMMON BLOCKS: 
#       None. 
# 
# RESTRICTIONS: 
#       Elements up to Zn only are included. 
# 
# SIDE EFFECTS: 
#       None. 
# 
# CATEGORY: 
#       Part of the HAOS-DIPER. 
# 
# PREVIOUS HISTORY: 
#       Written August 7, 1995, by Randy Meisner, HAO/NCAR, Boulder CO 
# 
# MODIFICATION HISTORY: 
#       April 15, 2004 Modified by P. Judge- simpler 
# 
# VERSION: 
#       Version 1, August 7, 1995 
#- 
# 
def abmass, name 
    # 
    # 
    IF(N_PARAMS() != 1): 
    print('  Usage:  Result = abmass(name [,help=help])' 
    return  [-1,-1] 
# 
nm = atomn(name,/num) 
# 
mass_data=[1.0080,4.0026,6.941,9.0122,10.811,12.0111,14.0067,15.9994,18.9984,20.179,      22.9898,24.305,26.9815,28.086,30.9738,32.06,35.453,39.948,            39.102,40.08,44.956,47.90,50.9414,51.996,54.9380,55.847,58.9332,58.71,          63.546,65.37] 
# 
ab_data=[12,10.93,0.7,1.1,3,8.52,7.96,8.82,4.6,7.92,         6.25,7.42,6.39,7.52,5.52,7.20,5.6,6.8,         4.95,6.30,3.22,5.13,4.40,5.85,5.40,7.60,5.1,6.30,4.5,4.2] 
# 
IF(nm > len(mass_data)): 
print('atomic number=',nm 
messdip,'ABMASS: Elements up to Zn (atomic number 30) are only included' 
# 
return  [ab_data(nm-1),mass_data(nm-1)] 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'abmass.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
