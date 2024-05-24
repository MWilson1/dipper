#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: demodiprd.pro 
# Created by:    judge, June 15, 2006 
# 
# Last Modified: Thu Jul 20 14:35:35 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def demodiprd 
    # 
    @cdiper 
    messdip,'this demo introduces how certain data are handled',/inf 
    q = 'Enter <return> to continue..' 
    s = '' &  read,'Enter <return> to continue>',s 
    # 
    print('------------------------------ demodiprd ------------------------------' 
    print('The diprd.def procedure:es other things.' 
    print('Let us suppose !regime = 0 (coronal) or 1 (nLTE), and ' 
    print('               !approx=0  (do not approximate missing collisions' 
    print(' (these diper system variables are reset with IDL> diper,regime =nn,approx=mm)' 
    print('Then, by default, using ' 
    print('    IDL> diprd,''he''   or ' 
    print('    IDL> diprd,2  (atomic symbols and numbers can be interchanged in all procedures)' 
    print('the data to stored will include ALL levels of ALL ions of carbon, as is seen with' 
    print('    IDL> level' 
    print('    IDL> td,/contlong,/main,wmax=1650.# plot a term diagram' 
    print('-----------------------------------------------------------------------' 
    diprd,2 
    level 
    td,/contlong,/main,wmax=1600. 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodiprd ------------------------------' 
    print('To read in only certain ions, use' 
    print('  IDL> diprd,6,[2,4]# reads C II to C IV levels' 
    print('  IDL> levels' 
    print('Note that there is a level of C V in these data.' 
    print('To force diprd to read ONLY C II, C III, C IV, use' 
    print('  IDL> diprd,6,[2,4], /nofill' 
    print('  IDL>  levels' 
    print('Thus, to read ONLY the levels of ONE ion (no continuum) use, e.g., for C IV' 
    print('  IDL> diprd,6,4,/nofill' 
    print('-----------------------------------------------------------------------' 
    diprd,6,[2,4] 
    level 
    diprd,6,[2,4] 
    level 
    diprd,6,4,/nofill 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodiprd ------------------------------' 
    print('Even where NO data are stored in the atom_xxx databases, diprd' 
    print('still fills missing ion stages with their ground levels, enabling' 
    print('approximate treatments of the effects of ion populations on levels' 
    print('interest.  This behavior only occurs when keyword /nofill is not set' 
    print('-----------------------------------------------------------------------' 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodiprd ------------------------------' 
    print('Collisional data can be seen by typing  IDL> col' 
    print('Now let us suppose !approx=1, because we set it with' 
    print('  IDL> diper,approx=1' 
    print('In this case, diprd computes collisional data where they are missing' 
    print('  IDL> diprd,2' 
    print('  IDL> app, = np.where(col.approx == 1)' 
    print('  IDL> col,list=app# list collisional data which were approximated' 
    print('-----------------------------------------------------------------------' 
    diper,approx = 1 
    diprd,2 
    app, = np.where(col.approx == 1) 
    col,list = app 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodiprd ------------------------------' 
    print('Lastly, when !regime=0 or 1, diprd will fill the collisional data with' 
    print('bound-free rate coefficients (ionization and, if !regime=0, recombination),' 
    print('because the atom_col database and col.xxx structure filled from atom_col' 
    print('contains just bound-bound collisional data.  To see these data, we can:' 
    print('  IDL> notu, = np.where(str(col.key,2) != ''SPLUPS'')' 
    print('  IDL> col,list=notu' 
    print('-----------------------------------------------------------------------' 
    notu, = np.where(str(col.key,2) != 'SPLUPS') 
    col,list=notu 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodiprd ------------------------------' 
    messdip,/inf,'this is the end of the diprd demo' 
    print('Of course, to learn more about the procedures (e.g. level.pro) you can: ' 
    print('     IDL > chkarg,''level''# gets argument list' 
    print('and  IDL >:c_library,''level''# gets header information' 
    print('I am now re-setting !approx to 0' 
    print('-----------------------------------------------------------------------' 
    diper,approx = 0 
    return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'dembasic.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
