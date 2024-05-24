#!/usr/bin/env python

import os
import time
import numpy as np

# 
#************************************************************** 
# 
def cstrip,filen,nosignal=nosignal,comment=comment,noblanks=noblanks 
    #+ 
    # cstrip,filen,nosignal=nosignal,comment=comment,noblanks=noblanks 
    # strip comment lines from input file 
    #- 
    text=' ' 
    if(len(nosignal) == 0) : 
    $  print('stripping comments from ', filen 
openr,lu1,filen,/get 
openw,lu2,'dums.dat',/get 
if(len(comment) == 0): 
comment='*' 
else: 
print('stripping lines starting with ', comment 
while not eof(lu1): 
readf,lu1,text 
if(len(noblanks) > 0) : 
text=str(text,2) 
if (strmid(text,0,1) != comment): 
printf,lu2,text,format = '(a)' 
free_lun,lu1 
free_lun,lu2 
return 
 
# 
#***************************************** 
# 
