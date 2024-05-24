#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: db2ip.pro 
# Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, January 14, 1997 
# 
# Last Modified: Tue Mar  7 08:56:07 2006 by judge (Philip Judge) on niwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def db2ip, anum, ipnum, help=help 
    #+ 
    # 
    # PROJECT: 
    #       HAOS-DIPER 
    # 
    # NAME:  db2ip     (procedure) 
    # 
    # PURPOSE:  To get Moore's ionization potentials from the atomic database. 
    # 
    # CALLING SEQUENCE: 
    # 
    #       ip=db2ip(anum, ipnum) 
    # 
    # INPUTS: 
    #       anum - atomic number of the ion to be read from the database. 
    #      ipnum - spectrum number of the ionization stage to be read from 
    #              the database. 
    # 
    # OPTIONAL INPUTS: 
    #       None. 
    # 
    # OUTPUTS: 
    #       Adds the ionization potential to the common block catom variables of 
    #       nk, label, ion, g, and ev. 
    # 
    # OPTIONAL OUTPUTS: 
    #       None. 
    # 
    # KEYWORD PARAMETERS: 
    #       /help.  Will call doc_library and list header, and return 
    # 
    # CALLS: 
    #       dbopen.pro, dbclose.pro, dbext.pro, dbfind.pro, isoseq.pro, 
    #       getlwrd.pro, gtoj.pro, atomn.pro, roman.pro. 
    # 
    # COMMON BLOCKS: 
    #       Catom. 
    # 
    # RESTRICTIONS: 
    #       None. 
    # 
    # SIDE EFFECTS: 
    #       None. 
    # 
    # CATEGORY: 
    #       Part of the HAOS-DIPER database software. 
    # 
    # PREVIOUS HISTORY: 
    #       Written January 14, 1997, by Randy Meisner, HAO/NCAR, Boulder, CO 
    # 
    # MODIFICATION HISTORY: 
    # 
    # VERSION: 
    #       Version 1, January 14, 1997 
    #- 
    # 
    IF(N_PARAMS() != 2): 
    messdip,/inf, 'Usage:  ip=db2ip(anum, ipnum)' 
    return -1 
# 
# 
 
dbopen, 'atom_ip' 
# 
ipidx = dbfind('atom=' + str(STRING(anum), 2) +                ',ion=' + str(STRING(ipnum), 2), /silent) 
# 
IF((ipidx(0) == 0) OR (ipidx(0) == -1)): 
messdip,/inf, 'No ionization potential found in database.' 
dbclose 
return -1 
else: 
dbext, ipidx, 'atom, ion, ip, bib_ref, comment',       ipa, ipi, ip, ip_bib, ip_note 
ipa = ipa(0) 
ipi = ipi(0)+1 
ip = ip(0) 
dbclose 
return ip 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'db2ip.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
