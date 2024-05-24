#!/usr/bin/env python

import os
import time
import numpy as np

def CONVL,alambda# converts vacuum lambda to air (>2000 A) 
    #+ 
    #   convl(lambda) 
    # 
    #            converts vacuum lambda to air (>2000 A). 
    # 
    #- 
    #  88-04-25  Mats Carlsson 
    # 
    ARRAY=SIZE(alambda) 
    IF ARRAY(0) == 0: 
        IF (alambda < 2000.): 
            alambda_UT = alambda 
        else: 
            alambda_UT = alambda/(1.0+2.735182E-4+131.4182/alambda/alambda+ 2.76249E8/alambda/alambda/alambda/alambda) 
        return alambda_UT 
    else: 
        alambda_UT=alambda 
        IF(MAX(alambda) > 2000.): 
        IW=WHERE (alambda > 2000.) 
        alambda_UT(IW) = alambda(IW)/(1.0+2.735182E-4+ 131.4182/alambda(IW)/alambda(IW)+ 2.76249E8/alambda(IW)/alambda(IW)/alambda(IW)/alambda(IW)) 
    return alambda_UT 
 
 
#******************************************************************************* 
 
