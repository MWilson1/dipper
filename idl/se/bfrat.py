#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: bfrat.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, October 6, 1995 
# 
# Last Modified: Sat Aug 26 18:07:39 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def bfrat 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       bfrat 
    # 
    # PURPOSE: 
    #     computes bound-free rates(photoionization, recombination) 
    #     also computes the continuum emission spectrum on a fixed 
    #     logarithmically-spaced wavelength grid 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       bfrat 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       rij, rji in common catom 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       planck 
    # 
    # COMMON BLOCKS: 
    #       CATOM, CESC 
    # 
    # RESTRICTIONS: 
    # 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    # 
    # PREVIOUS HISTORY: 
    #       Written October 6, 1995, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, October 6, 1995 
    #- 
    # 
    @cdiper 
    @cse 
    COMMON bfat1,messg 
    messg = 0l 
    # 
    IF(nozeror == 0 AND atom.nrad > 0): 
    rij = 0.*trn.a 
    rji = rij 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
#  Define output grid for emission spectrum 
#  get erg/cm2/s/sr/hz at a wavelength grid logarithmic 
# 
econt=wcont*0. 
# 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
ibeg = atom.nline 
minp = 1. 
for kr in np.arange(atom.nline,atom.nrad-1 +1):  begin 
    ny=1+indgen(trn(kr).nq)# original, ignoring threshold 
    i=trn(kr).irad 
    j=trn(kr).jrad 
    nu = trn(kr).frq(ny) 
    threshold = trn(kr).frq(0) 
    nu = threshold + nu - nu(0)# fix threshold to be compatible with nstar 
    hn3c2=2.*hh*nu*nu/cc*nu/cc 
    alfa=trn(kr).alfac(ny) 
    IF(len(jinc) == 0): 
    jbar=0. 
else: 
    # 
    # consistent with lines, attenuate jbar in the entire continuum 
    # by pesc(kr).  Very rough, frequency-independent  approximation 
    # 
    jbar = jinc(ibeg:ibeg+trn(kr).nq-1)*pesc(kr) 
    minp =  minp <  pesc(kr) 
ibeg = ibeg+trn(kr).nq 
# 
# 1. simple trapezoidal rule 
# 
# linearly interpolate data onto a grid if temp is low 
# 
delt = hh*(nu(2)-nu(1))/bk/temp 
IF(delt > 0.1): 
newnu = nu(0)+findgen(40)*0.1*bk*temp/hh 
linterp,nu,alfa,newnu,newalfa 
linterp,nu,jbar,newnu,newj 
hn3c2new = 2.*hh*newnu*newnu/cc*newnu/cc 
k , = np.where(nu > max(newnu)) 
nu = [newnu,nu(k)] 
jbar = [newj,jbar(k)] 
alfa = [newalfa,alfa(k)] 
hn3c2 = [hn3c2new,hn3c2(k)] 
#  gijold=nstar(i)/nstar(j)*exp(-hh*nu/bk/temp) 
beta = hh/bk/temp*(nu-nu(0)) 
ok =  where(beta < 50.) 
gij = nne/2.*((hh/em)*(hh/bk)/2./!pi/temp(ok))**1.5*     lvl(i).g/lvl(j).g*exp(-beta(ok)) 
# 
eup = 4.*!pi*alfa(ok)*jbar(ok) 
edn = 4.*!pi*alfa(ok)*(hn3c2(ok)+jbar(ok))*gij 
# 
#  energy in erg/cm3/s/hz/sr emitted by the continuum: 
net=(edn*n(j)-eup*n(i))/4/!pi# per steradian per cm3 
# convert to per angstrom and add to the losses. 
# 
out= net * nu(ok) *nu(ok) / cc / 1.e8 
# 
linterp,  nu(ok),out,cc*1.e8/wcont,out2,missing=0. 
econt += out2 
# 
up = trapez(nu(ok),eup/hh/nu(ok)) 
dn = trapez(nu(ok),edn/hh/nu(ok)) 
 
rij(kr)=up +rij(kr) 
rji(kr)=dn + rji(kr) 
matrix(j,i) = matrix(j,i) + rji(kr) 
matrix(i,j) = matrix(i,j) + rij(kr) 
# 
#  print,trapez(wcont,econt) 
# 
# output message if continuum radiation is attenuated a bit. 
IF(minp < 0.8 AND strupcase(incfunc) != 'ZERO'): 
messdip,      'BFRAT: warning, crude (iterated) treatment of attenuated incident radiation',/inf 
# 
return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'bfrat.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
