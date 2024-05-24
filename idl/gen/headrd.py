#!/usr/bin/env python

import os
import time
import numpy as np

def headrd,file 
    #+ 
    # NAME: 
    #	headrd 
    # 
    # PURPOSE: Extracts header information from DIPER ascii atomic files 
    # 
    # CATEGORY: HAOs DIPER documentation 
    # 
    # CALLING SEQUENCE: 
    #	headrd,file 
    # 
    # INPUTS: 
    #	FILE: file input 
    # 
    # KEYWORDS: 
    #	none. 
    # 
    # OUTPUTS: 
    #	HEAD: header output, consisting of a structure HEAD.KEY, HEAD.TEXT 
    # 
    # 
    # COMMON BLOCKS: 
    #       cdiper, structure hdr filled. 
    # 
    # SIDE EFFECTS: 
    #	none 
    # 
    # EXAMPLE: 
    # 
    # MODIFICATION HISTORY: 
    #	Written, P. Judge, HAO, NCAR June, 1994. 
    #	Bug corrected, P. Judge, HAO, NCAR Aug, 1994: head(0:i) returned 
    #       re-written P. Judge February 27, 2006 
    #- 
    @cdiper 
    # 
    str=' ' 
    i=-1 
    openr,readu,file,/get 
    while not eof(readu): 
        readf,readu,str 
        k = strpos(str,'*')# if a comment 
        IF(k == 0): 
        firstw = getwrd(str,1) 
        jj=strpos(firstw,':')# colon belonging to second word 
        if(jj > 0): 
        j=strpos(str,':') 
        i=i+1 
        hdr(i).key =str(strcompress(strmid(str,1,j-1)),2) 
        n=strlen(str) 
        hdr(i).text=strcompress(strmid(str,j+1,n-j+1)) 
free_lun,readu 
if(i >= 0): 
hdr=hdr(0:i) 
else: 
messdip,/inf,'hdrrd: no header data in file '+file 
i=0 
return 
 
 
