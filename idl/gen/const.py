#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: const.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, October 13, 1995 
# 
# Last Modified: Tue Aug  1 17:59:54 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def const 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       const 
    # 
    # PURPOSE: Stores atomic and physical constants in common cdiper 
    # 
    # EXPLANATION: 
    #       The following variables are set (cgs units throughout): 
    # 
    #       EE               electon charge cgs 
    #       HH=6.626176D-27  planck's constant 
    #       CC=2.99792458D10 speed of light 
    #       EM=9.109534D-28  electron mass 
    #       UU=1.6605655D-24 hydrogen mass 
    #       BK=1.380662D-16  Boltzmann constant 
    #       PI=3.14159265359 pi 
    #       following combinations are stored 
    #       HCE=HH*CC/EE*1.D8 
    #       HC2=2.*HH*CC *1.D24 
    #       HCK=HH*CC/BK*1.D8 
    #       EK=EE/BK 
    #       HNY4P=HH*CC/QNORM/4./PI*1.D-5 
    #       RYDBERG=2*PI*PI*EM*EE*(EE/HH)*(EE/HH)*(EE/HH)/CC 
    #       ALPHA=2*PI*ee*ee/HH/CC   fine structure constant 
    # CALLING SEQUENCE: 
    #       const 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       common block variables are filled 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       None. 
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
    #       Written October 13, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 2, April 26, 1996 
    #- 
    # 
    @cdiper 
    qnorm=10.0 
    ee=1.602189d-12 
    hh=6.626176d-27 
    cc=2.99792458d10 
    em=9.109534d-28 
    uu=1.6605655d-24 
    bk=1.380662d-16 
    pi=3.14159265359d0 
    hce=(hh/ee*cc)*1.d8 
    hc2=2.*hh*cc *1.d24 
    hck=hh*cc/bk*1.d8 
    ek=ee/bk 
    hny4p=hh*cc/qnorm/4./pi*1.d-5 
    es = 4.80288d-10 
    rydinf=2*pi*pi*em*es*(es/hh)*(es/hh)*(es) 
    alphafs=2*pi*es*es/hh/cc 
    eesu = ee*cc/1.e8 
    a0 = (hh/eesu)*(hh/eesu)/(4*pi*pi)/em 
    bohrm=hh*eesu/4/!dpi/em/cc 
     
    # 
    # Allen 1973, ch 4: 
    # 
    designations = 'SPDFGHIKLMNOQRTU' 
    return 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'const.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
