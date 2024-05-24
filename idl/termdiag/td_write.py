#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: td_write.pro 
# Created by:    Philip G. Judge, May 7, 1996 
# 
# Last Modified: Wed Aug  9 13:42:53 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def td_write, file, help=help 
    #+ 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME: 
    #       td_write 
    # 
    # PURPOSE: writes parameters of term diagram plots to a file for later editing 
    # 
    # EXPLANATION: 
    #       termdiag will, by default, almost certainly NOT produce a desired plot 
    #       style.  With td_read and td_write you can output to a file the plotted 
    #       parameters and easily manually adjust the figure as desired. 
    #       td_write will write comments to the file that give instructions on how 
    #       to edit the file. 
    # CALLING SEQUENCE: 
    #       td_write, filen 
    # 
    # INPUTS: 
    #       file  name of file to be written 
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
    #       cdiper, ctermdiag 
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
    #       Written May 7, 1996, by Philip G. Judge 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, May 7, 1996 
    #- 
    # 
    @cdiper 
    @ctermdiag 
    messdip,'NOT READY' 
    IF(len(help) > 0): 
   :c_library,'td_write' 
    RETURN 
if (n_params(0) == 0): 
    file='' 
    READ,'output file name? ',file 
# 
GET_LUN,lu 
OPENW,lu,file,/get 
messdip,'Writing files '+file+' and '+file+'_td.idlsave',/inf 
messdip,'try editing '+file+', but leave '+   file+'_td.idlsave',/inf 
# 
nw = len(whichtrans) 
# 
# 
# 
pfix = nrfix 
IF(nw == 0 OR nw == nrad): 
pline =  nline 
pcnt = nrad-nline 
else: 
lines , = np.where(whichtrans <= nline-1,pline) 
cont , = np.where(whichtrans > nline-1,pcnt) 
 
save,file = file+'_td.idlsave',   config,term,iconfig,iterm,iseries,evplot,positions,    low_fine,low_group,idx,jdx,max_dx_line,max_dx_cont,directions,krcolor,    top,bottom,term_label,kr_linestyle,lstring,tstring,whichtrans,   c_label_space,c_label,c_arrow 
 
PRINTF,lu,atomid 
PRINTF,lu,'*     nk   nline    ncnt   nrfix' 
PRINTF,lu,nk,pline,pcnt,nrfix 
PRINTF,lu,'* energy levels:' 
PRINTF,lu,'* NOTE: LEVELS' 
PRINTF,lu,'* To change the appearance OF LEVEL placements in the termdiagram figure, ' 
PRINTF,lu,'* simply edit the following lines.  For TRANSITIONS see ' +    '"TRANSITIONS" below' 
PRINTF,lu,'* lowfine   -- this determines ' 
PRINTF,lu,'* eV        -- actual energy of level in eV (NOT used by termdiag)' 
PRINTF,lu,'* evplot    -- plotted energy (i.e. y-coordinate) OF level' 
PRINTF,lu,'* pos       -- the plotted X position OF the level' 
PRINTF,lu,'* label     -- the label appearing to the right OF the level.' 
PRINTF,lu,'*' 
PRINTF,lu,'* i lowfine         ev      evplot ion pos      label' 
for i in range(nk): 
PRINTF,lu,'$(i3,i7,2f12.5,i3,f5.1,1x)',i+1,low_fine(i)+1,       ev(i),evplot(i),ion(i),positions(i) 
PRINTF,lu,term_label(i) 
PRINTF,lu,' ' 
PRINTF,lu,'* NOTE: TRANSITIONS 
PRINTF,lu,'* simply edit the following lines: 
PRINTF,lu,'* kr        -- index of transition (1= first, 2 = second...) 
PRINTF,lu,'* j         -- upper level of transition' 
PRINTF,lu,'* i         -- lower level of transition' 
PRINTF,lu,'* alamb     -- plotted wavelength of transition' 
PRINTF,lu,'* jdx       -- displacement (in x) of line on upper level 
PRINTF,lu,'* idx       -- displacement (in x) of line on lower level 
PRINTF,lu,'*' 
PRINTF,lu,'*kr    j  i                    alamb jdx idx' 
for i in range(len(whichtrans)): 
kr = whichtrans(i) 
PRINTF,lu,'$(i3,2x,2i3,f25.3,2i4)',kr+1,jrad(kr),irad(kr),alamb(kr),      jdx(kr),idx(kr) 
 
FREE_LUN,lu 
RETURN 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'td_write.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
