#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: colrd.pro 
# Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 13, 1996 
# 
# Last Modified: Wed Jun 21 09:41:46 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def colrd, debug=debug, filen=filen, lu=lu,           nocheck=nocheck, status=status,indexadd=indexadd 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       colrd 
    # 
    # PURPOSE: Reads collisional data from atomic data file 
    # 
    # EXPLANATION: 
    # 
    # CALLING SEQUENCE: 
    #       colrd, gendata, plot=plot, debug=debug, filen=filen, lu=lu 
    # 
    # INPUTS: 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       None. 
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
    #       Written August 13, 1996, by Phil &, HAO/NCAR, Boulder CO USA 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, February 25, 2006 
    #- 
    # 
    @cdiper 
    @cse 
    if(len(filen) == 0 and len(lu) == 0): 
    messdip,'colrd:  you must specify only one of filen or lu (unit number)' 
if(len(filen) > 0 and len(lu) > 0): 
messdip,'colrd:  you must specify only one of filen or lu (unit number)' 
if(len(indexadd) == 0) : 
indexadd=0 
 
ix=0 
 
valid_keys=['GENCOL','CE','CI','OHM','SPLUPS','TEMP','SEMI','BURGESS','SHULL82',           'LTDR','AR85-RR','AR85-CEA','AR85-CH','AR85-CHE','AR85-CH+',           'AR85-CHE+','SPLUPS5','SPLUPS9','AR85-CDI','AR85-CDI','END'] 
# 
# in common block cgencol- new data entered each time 
# 
col=coldef 
newcol = 1 
# 
if(len(filen) > 0 and len(lu) == 0): 
if(len(debug) > 0) : 
print('colrd:  reading file ',filen 
cstrip,filen,/nosig 
openr,lu,'dums.dat',/get 
 
# 
#on_ioerror, err_read 
 
readkey='' 
ix=-1 
 
while not eof(lu): 
loop: 
coll = coldef 
readf,lu,readkey 
readkey=strupcase(str(readkey,2)) 
p, = np.where(readkey == valid_keys,n) 
if p[0] < 0: 
print('readkey error:  ',readkey 
if(readkey == 'END'): 
goto,loop 
# 
# here means we have one key matched 
# 
ii=0l 
nnt=2 
tmp=fltarr(nnt) 
coll.key=readkey 
text='' 
ix=ix+1 
# 
#  temperature special case 
# 
if(coll.key == 'TEMP'): 
rpt: 
readf,lu,text# read next line of data 
if(strlen(str(text,2)) == 0) :# skip blank lines 
goto, rpt 
nnt=0 
nnt=fix(getwrd(text,0)) 
tmp=fltarr(nnt) 
for ii in range(nnt): 
tmp(ii)=float(getwrd(text,ii+1)) 
# 
#  loop reads until all temperatures are filled 
# 
loop3: 
ji, = np.where(tmp != 0.,kount) 
nj=len(ji)-1 
if(kount != nnt): 
readf,lu,text 
for ii in np.arange(ji(nj)+1,nnt): 
tmp(ii)=float(getwrd(text,ii-ji(nj)-1)) 
goto,loop3 
# 
#  end loop 
# 
coll.temp=tmp & coll.data=tmp & coll.nt=nnt & coll.ihi=-1 & coll.ilo=-1 
save=coll 
ix-=1 
goto, loop# read next key 
# 
# now read other special cases 
 
i=0 & j=0 
nomore=0 
case coll.key of 
'GENCOL': begin 
ix-=1 
goto, loop 
 
'SEMI': begin 
coll.nt=1 
readf,lu,i,j, dum 
coll.data=dum 
 
'BURGESS': begin 
coll.nt=1 
dum=fltarr(coll.nt) 
readf,lu,i,j, dum 
coll.data=dum 
 
'SHULL82': begin 
coll.nt=8 
dum=fltarr(coll.nt) 
readf,lu,i,j, dum 
print(i,j,dum 
coll.data=dum 
 
'LTDR': begin 
coll.nt=5 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'AR85-RR': begin 
coll.nt=2 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'AR85-CH': begin 
coll.nt=6 
readf,lu,i,j,dum 
coll.data=dum 
 
'AR85-CHE': begin 
coll.nt=6 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'AR85-CH+': begin 
coll.nt=6 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'AR85-CHE+': begin 
coll.nt=6 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'SPLUPS': begin 
coll.nt=9 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'SPLUPS5': begin 
coll.nt=9 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'SPLUPS9': begin 
coll.nt=13 
readf,lu,i,j,dum 
coll.data=dum 
 
'AR85-CDI':  begin 
nshell=1 
readf,lu,i,j,nshell 
coll.nt=5*nshell 
dum=fltarr(coll.nt) 
readf,lu,dum 
nomore=1 
coll.data=dum 
 
'AR85-CEA': begin 
coll.nt=1 
fcea=0. 
readf,lu,i,j 
readf,lu,fcea 
dum=fltarr(coll.nt) 
dum[0]=fcea 
coll.data=dum 
 
'OHM': begin 
coll.temp=save.temp 
coll.nt=save.nt 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'CE': begin 
coll.temp=save.temp 
coll.nt=save.nt 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'CI': begin 
coll.temp=save.temp 
coll.nt=save.nt 
dum=fltarr(coll.nt) 
readf,lu,i,j,dum 
coll.data=dum 
 
'END': begin 
ix-=1 
goto, end_read 
 
 
 
# 
j=j-1 
i=i-1 
j+=indexadd 
i+=indexadd 
coll.ihi= j 
coll.ilo= i 
if(coll.key == 'OHM' or coll.key == 'CE' or coll.key == 'CI'         or coll.key == 'SHULL82' or coll.key == 'LTDR' OR coll.key == 'BURGESS'        or coll.key == 'AR85-CDI' or coll.key == 'AR85-CEA' ): 
coll.ihi= j>i 
coll.ilo= i<j 
 
IF(ix == 0): 
col = coll 
else: 
col = [col,coll] 
# 
if(len(debug) == 1): 
x=col(ix).temp(0:col(ix).nt-1) 
y=col(ix).data(0:col(ix).nt-1) 
print( 'key ',col(ix).key 
print(' upper ',col(ix).ihi,' lower ',col(ix).ilo 
print('data' 
print(x,y 
strr='' 
read,'press return to print out next collision parameter (Q to import pdb; pdb.set_trace())',strr 
if(strupcase(strr) == 'Q') : 
debug=[0,0] 
goto,loop 
# 
# 
err_read: 
print('Error reading collisional data in file (may be ok)' 
print('This occurred during reading of keyword number: '+strn(ix) 
 
 
 
FREE_LUN,lu 
if(ix == 0): 
print('Colrd: no gencol data in file' 
col=coldef 
return 
if(ix > 0) : 
col=col(1:ix) 
if(len(debug) > 0) : 
print(' number of collisional transition keys read: ',ix+1 
if(len(filen) > 0) : 
free_lun,lu 
return 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'colrd.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
