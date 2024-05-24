#!/usr/bin/env python

import os
import time
import numpy as np

def isplit, filen 
    #+ 
    # NAME: 
    #	ISPLIT 
    # 
    # PURPOSE: 
    #	To split a file containing many idl procedures into individual files 
    # 
    # CATEGORY: 
    #	[Part of the HAO Spectral Diagnostics Package (HAO-SDP)] 
    # 
    # CALLING SEQUENCE: 
    #	ISPLIT,FILEN 
    # 
    # INPUTS: 
    #	FILEN: string variable, example input file (e.g. 'myproc.pro') 
    # 
    # KEYWORDS: 
    #	NONE 
    # 
    # OUTPUTS: 
    #	set of new files (e.g proc1.pro, proc2.pro, ...) containing 
    #	idl source code of these procedures and functions 
    # 
    # COMMON BLOCKS: 
    #	None. 
    # 
    # SIDE EFFECTS: 
    #	All output is in current directory 
    # 
    # EXAMPLE: 
    #	isplit,'myprogs.pro' 
    # 
    # 
    # MODIFICATION HISTORY: 
    #	Written, P. Judge, HAO, NCAR June, 1994. 
    #	Modified 9-June-1994 P. Judge: case of output file eq input file 
    #       addressed, and full header dialogue added 
    #- 
     
    on_error,2#Return to caller if an error occurs 
     
    if (n_params(0) < 1): 
        print('isplit, filen' 
        return 
     
    openr,lu,filen,/get_lun 
    str1='' 
    input: 
    while not eof(lu): 
        readf,lu,str1 
        str2=str(str1,2) 
        str2 = repstr(str2,',',' ') 
        first=getwrd(str2,0) 
        if(strupcase(first) == 'PRO' or  strupcase(first) == 'FUNCTION'): 
        if(len(lo) != 0) : 
        free_lun,lo 
    fileo=strlowcase(getwrd(str2,1))+'.pro' 
    if(fileo == filen): 
    print('isplit: error! - you must rename your input file since' 
    print('        one of the procedures has an identical name' 
    return 
openw,lo,/get_lun,fileo 
print('Writing file ',fileo 
if(len(lo) == 0) : 
goto, next 
printf,lo,str(str1,2) 
next: 
free_lun,lo 
free_lun,lu 
return 
 
