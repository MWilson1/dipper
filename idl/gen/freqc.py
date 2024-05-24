#!/usr/bin/env python

import os
import time
import numpy as np

def FREQC 
    #+ 
    #  GIVES QUADRATURE POINTS AND WEIGHTS FOR CONTINUA 
    #  THE POINTS ARE EQUIDISTANT IN FREQUENCY, THE WEIGHTS ARE 
    #  TRAPEZOIDAL 
    #  CALCULATES CROSSECTIONS FROM NY**-3 DEPENDENCE IF NOT GIVEN 
    #  EXPLICITLY 
    # 
    #  QMAX .LT. 0 : Q AND ALFAC GIVEN (FROM ATOM INPUT). ONLY 
    #  WEIGHTS CALCULATED AND Q TRANSFORMED FROM ANGSTROM TO DOPPLER 
    #  UNITS. 
    # 
    #  NQ      TOTAL NUMBER OF QUADRATURE POINTS       (IN) 
    #  QMAX    MINIMUM VALUE OF WAVELENGTH (ANGSTROM)  (IN) 
    #  FRQ     QUADRATURE POINTS (S-1)                 (OUT) 
    #  Q       QUADRATURE POINTS (DOPPLER UNITS)       (OUT) 
    #  WQ      QUADRATURE WEIGHTS                      (OUT) 
    #   Based upon fortran  subroutine freqc of MULTI 
    #- 
    @cdiper 
    # 
    for kr in np.arange(atom.nline,atom.nrad): 
        ny=indgen(trn(kr).nq)+1 
        #   ny=indgen(trn(kr).nq+1) ; includes threshold 
        trn(kr).frq(0)=cc/trn(kr).alamb*1.e8 
        if(trn(kr).qmax >= 0.0): 
        trn(kr).frq(trn(kr).nq)=cc/trn(kr).qmax*1.e8 
        dfrq=(trn(kr).frq(trn(kr).nq)-trn(kr).frq(0))/(trn(kr).nq-1) 
        trn(kr).frq(ny)=trn(kr).frq(0)+ny*dfrq 
        xx = (frq(0,kr)/frq(ny,kr)) 
        trn(kr-atom.nline).alfac(ny)=f(kr)*xx*xx*xx 
      else  begin 
        trn(kr).frq(ny)=cc/trn(kr).q(ny)*1.0e8 
    trn(kr).q(ny)=cc*1.e-5/qnorm*(trn(kr).frq(ny)/trn(kr).frq(0)-1.0) 
    nny=2+indgen(trn(kr).nq-2) 
    trn(kr).wq(1)=0.5*(trn(kr).q(2)-trn(kr).q(1)) 
    trn(kr).wq(trn(kr).nq)=0.5*(trn(kr).q(trn(kr).nq)-trn(kr).q(trn(kr).nq-1)) 
    trn(kr).wq(nny)=0.5*(trn(kr).q(nny+1)-trn(kr).q(nny-1)) 
# 
return 
 
