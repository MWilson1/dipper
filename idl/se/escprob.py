#!/usr/bin/env python

import os
import time
import numpy as np

# 
#************************************************************************ 
# 
def escprob, tau, type,der=der 
    # 
    #+ 
    #  P. Judge 19-Feb-1992 
    # derivative keyword added,returns Dp/Dtau 
    #- 
    con, = np.where(type  ==   1,nc)# continuum 
    lin, = np.where(type  ==   0,nl)# line 
    esc=tau*0. 
    der = esc 
    IF(nl > 0):  BEGIN 
    esc(lin)= 1./(1.+tau(lin)) 
    der(lin) = -esc(lin)*esc(lin) 
IF(nc > 0): 
esc(con)= 1./(1.+tau(con)) 
der(con) = -esc(con)*esc(con) 
# orig 
#   esc(con)= exp(-tau(con)) 
#   der(con) = -esc(con) 
return esc 
 
