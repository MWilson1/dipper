#!/usr/bin/env python

import os
import time
import numpy as np

# 
#************************************************************************ 
# 
def colcnv,ohm = ohm,ppd=ppd 
    # 
    #+ 
    # NAME: 
    # COLCNV 
    # PURPOSE: 
    # Converts CE data to OHM data, and SPLUPS to OHM 
    # CALLING SEQUENCE: 
    # colcnv, coldata,ohm=ohm,ppd=ppd 
    # INPUTS: 
    # none. 
    # OPTIONAL INPUT PARAMETERS: 
    # None. 
    # OUTPUTS: 
    # structure called coldata 
    # COMMON BLOCKS: 
    # MULTI atomic blocks 
    # SIDE EFFECTS: 
    # None. 
    # METHOD: 
    # REVISION HISTORY: 
    #  Written by P.G. Judge May 1993 
    #- 
    # 
    @cdiper 
    # 
    if(len(ppd) == 0) :# points per decade 
    ppd = 1. 
 
IF(len(ohm) == 0): 
j, = np.where(str(col.key,2) == 'CE', kount) 
if(kount <= 0) : 
return 
col(j).key='OHM' 
for i in range(kount): 
nt=col(j(i)).nt-1 
col(j(i)).data =   col(j(i)).data           *col(j(i)).temp*lvl(col(j(i)).ilo).g/(8.63e-06) 
else: 
messdip,/inf,'changing from SPLUPS -> OHM' 
j, = np.where(strmid(col.key,0,6) == 'SPLUPS', kount) 
if(kount <= 0) : 
return 
col(j).key='OHM' 
for i in range(kount): 
nt_old = col(j(i)).nt 
spline_data = col(j(i)).data(0:nt_old-1) 
z = float(lvl(col(j(i)).ilo).ion) 
tmid = 4 +2*alog10(z) 
tmin = tmid-1.5 < 3.0 
tmax = tmid+1.5 > 7.0 
nt = int(np.round((tmax-tmin)*ppd) +1 
tempt = tmin + findgen(nt)/ppd 
tempt = 10.**tempt 
col(j(i)).temp = 0.*col(j(i)).temp 
col(j(i)).temp(0:nt-1) =  tempt 
col(j(i)).nt =   nt 
for k  in np.arange( 0,nt): 
col(j(i)).data(k) = ups_bt(tempt(k),spline_data) 
# 
return 
 
 
