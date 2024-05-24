#!/usr/bin/env python

import os
import time
import numpy as np

def atmosread,file,plot=plot,xran=xran,tran=tran 
    #+ 
    #   atmosrd,file 
    # 
    #            reads a multi atmos file 
    # 
    #   Modified 14-Dec-1992 by P. Judge 
    #   dptype is examined: 
    #   dptype= 'height'  then variable height is set 
    #   dptype= 'cmass'  then variable cmass is set 
    #   Modifications:  P. Judge Aug 5 1993 
    #     approximate calculations of height scale added. 
    #   Modifications:  P. Judge Aug 24 1993 
    #     plot keyword parameter added 
    #     plot keyword parameter added 
    #     plot keyword parameter added 
    # 
    #- 
    @cdiper 
    @cse 
     
    if(n_params(0) < 1): 
    print('atmosrd,file' 
    return 
# 
const 
# 
text='' 
openr,lu,file,/get_lun 
openw,lu2,'dums',/get_lun 
while (not eof(lu)): 
    readf,lu,text,format='(a)' 
    if(strmid(text,0,1) != '*') : 
    printf,lu2,text,format='(a)' 
free_lun,lu 
close,lu2 
openr,lu2,'dums' 
atmoid='' 
dptype='' 
readf,lu2,atmoid 
print(atmoid 
readf,lu2,dptype 
dptype=str(dptype,2) 
readf,lu2,gravlg 
grav=10.**gravlg 
ndep=0L 
readf,lu2,ndep 
tab=dblarr(5,ndep) 
readf,lu2,tab 
tab=transpose(tab) 
temp=tab(*,1) 
nne=tab(*,2) 
vel=tab(*,3) 
vturb=tab(*,4) 
case strupcase(strmid(dptype,0,1)) of 
'M': begin 
cmasslg=tab(*,0) 
cmass=10.**cmasslg 
 
'H': height=tab(*,0) 
else: print(' Depth scale type ', dptype, '  unknown' 
 
on_ioerror,end_read 
nh=dblarr(6,ndep) 
readf,lu2,nh 
# 
xx=dblarr(6)*0.+1. 
rho=xx#nh*1.3625*UU 
if (strupcase(strmid(dptype,0,1)) == 'H'): 
#  trapezoidal integration of height for cmass 
print('atmosrd:  computing cmass scale from height ' 
cmass=height*0. 
heightt=height 
cmass(0)= ((nh(0)+nh(5))*1.103+nne)*bk*temp(0)/grav#hse top point 
for k in np.arange(1,len(height)):# *1.e5 
cmass(k) = cmass(k-1)+ 0.5*(height(k-1)-height(k))*(rho(k)+rho(k-1)) 
 else if (strupcase(strmid(dptype,0,1)) == 'M'): 
#  dz = dm / rho 
print('atmosrd:  computing height scale from cmass ' 
dz=cmass*0. 
height=dz 
for i in np.arange(ndep-2,0,): 
height=cmass*0. 
heightt=cmass*0. 
dm = cmass-shift(cmass,1) 
rho = (nh(0,*)+nh(5,*))*1.4225*uu 
# trapez 
rhom=(rho+shift(rho,1))/2. 
dz=dm/rhom 
dz(0)=dz(1)# fudge for last point 
for i in np.arange(ndep -2,0,): 
    heightt(i) = heightt(i+1)+dz(i) 
#simpson 
rhom=(4.*rho+shift(rho,1)+shift(rho,-1))/3. 
dz=dm/rhom 
dz(0)=dz(1)# fudge for last point 
dz(ndep-1)=dz(ndep-2)# fudge for first point 
for i in np.arange(ndep -2,0,): 
    height(i) = height(i+1)+dz(i) 
#simpson 
height=height/1.e5 
heightt=heightt/1.e5 
height=heightt 
 
free_lun,lu2 
 
 
if(len(plot) != 0): 
!p.multi=[0,0,2,0,0] 
if(len(xran) == 0) : 
xran=[0,0] 
if(len(tran) == 0) : 
tran=[0,0] 
plot_oi,cmass,temp,xtit='cmass',ytit='Temp [K]',xran=xran,yran=tran,ysty=1,   titl=atmoid 
plot_oo,cmass,nne,xtit='cmass',ytit='N!Le!N [cm!U-3!N]',xran=xran 
oplot,cmass,nh(0,*),lines=1 
oplot,cmass,nh(5,*),lines=2 
legend,lines = indgen(3),['Ne','NH(n=1)','Np'] 
 
 
 
return 
 
 
