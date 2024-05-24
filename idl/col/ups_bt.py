#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: ups_bt.pro 
# Created by:    Phil Judge, HAO/NCAR, Boulder CO USA, August 7, 1998 
# 
# Last Modified: Wed Mar  1 22:20:59 2006 by judge (Philip Judge) on niwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
def ups_bt,temp,spldata 
    # 
    #   to scale the energies and upsilons 
    #   (thermal collision strengths) 
    # 
    #  modified from CHIANTI descale_ups.pro 
    # 
    @cdiper 
    t = fix(spldata(0)) 
    gf = spldata(1) 
    de = spldata(2)*rydinf 
    const = spldata(3) 
    spl = spldata(4:*) 
    # 
    xt = bk*temp/de 
    ns = len(spl) 
    xs=findgen(ns)/(ns-1) 
    # 
    CASE t OF 
        1:  begin 
        st=1.-alog(const)/alog(xt+const) 
        y2=nr_spline(xs,spl) 
        sups=nr_splint(xs,spl,y2,st) 
        ups=sups*alog(xt+exp(1.)) 
 
    # 
    2:  begin 
    st=xt/(xt+const) 
    y2=nr_spline(xs,spl) 
    sups=nr_splint(xs,spl,y2,st) 
    ups=sups 
 
# 
3:  begin 
st=xt/(xt+const) 
y2=nr_spline(xs,spl) 
sups=nr_splint(xs,spl,y2,st) 
ups=sups/(xt+1.) 
# 
 
# 
4:  begin 
st=1.-alog(const)/alog(xt+const) 
y2=nr_spline(xs,spl) 
sups=nr_splint(xs,spl,y2,st) 
ups=sups*alog(xt+const) 
 
# 
else:  messdip,'type != 1,2,3,4' 
# 
 
# 
 
ups=ups>0. 
# 
if((st > 1.) or (st < 0.)) : 
print(' st outside 0>1' 
return ups 
 
# 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'ups_bt.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
