#!/usr/bin/env python

import os
import time
import numpy as np

def trapez,x0,y0 
    #+ 
    #   trapez(x,y) 
    # 
    #            performs trapezoidal integration. 
    # 
    #- 
    if(n_params(0) < 2): 
    print('trapez(x,y)' 
    return 0 
 
nx=len(x0) 
ny=len(y0) 
if(nx != ny): 
print('trapez: different number of elements in x and y array' 
return 0 
x=reform(x0) 
y=reform(y0) 
integrand=(y(0:ny-2)+y(1:ny-1))*(x(1:nx-1)-x(0:nx-2))*0.5 
return np.sum(integrand) 
 
 
