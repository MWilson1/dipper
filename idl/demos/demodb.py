#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: demodb.pro 
# Created by:    judge, June 15, 2006 
# 
# Last Modified: Fri Jun 30 18:53:31 2006 by judge (judge) on macniwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def demodb 
    # 
    messdip,'this demo introduces how certain data are handled',/inf 
    q = 'Enter <return> to continue..' 
     
    # 
    print('------------------------------ demodb ------------------------------' 
    print('The diper can take real advantage of D. Lindler''s IDL database software.' 
    print('Using dbhelp we can see which databases are available, the diper ones are ' 
    print('those beginning with atom_xxx  or abund' 
    print('  IDL> dbhelp' 
    print('  IDL> dbopen,''atom_lvl,atom_bib''# atom_bib is linked to lvl, trn, col' 
    print('  IDL> dbhelp,1#  the 1 gives a more detailed description' 
    print('  IDL> dbclose# a good idea when done' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    dbhelp 
    dbopen,'atom_lvl,atom_bib' 
    dbhelp,1 
    dbclose 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodb ------------------------------' 
    print('The diper can take real advantage of D. Lindler''s IDL database software.' 
    print('For example, let''s find all lines between two wavelengths' 
    print('  IDL> dbopen,''atom_bb,atom_bib'' ' 
    print('  IDL> lines=dbfind(''1200.<wl<1220.'')' 
    print('  IDL> help,lines' 
    print('-----------------------------------------------------------------------' 
    dbopen,'atom_bb,atom_bib' 
    lines=dbfind('1200.<wl<1220.') 
    help,lines 
    # 
    s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demodb ------------------------------' 
    print('Even better, we can restrict the atomic number and ion stages too!' 
    print('For example, let''s find all lines between two wavelengths' 
    print('dbopen,''atom_bb,atom_bib'' ' 
    print('  IDL> lines=dbfind(''atom>3, 2<ion<9,1540.<wl<1551.'')' 
    print('  IDL> help,lines' 
    print('  IDL> dbext,lines,''wl,f,atom,ion,isos'',w,f,atom,ion,isos' 
    print('def atomn() converts from,e.g., ''c'' to 6, roman converts e.g. 3 to III.' 
    print('So to print the first few lines found,:' 
    print('  IDL> n=len(w) < 20' 
    print('  IDL> for i=0,n-1: print(w(i),f(i),atomn(atom(i)),roman(ion(i)),atomn(isos(i))' 
    print('-----------------------------------------------------------------------' 
    dbopen,'atom_bb,atom_bib' 
    lines=dbfind('atom>3,3<ion<6,1540.<wl<1551.') 
    help,lines 
    dbext,lines,'wl,f,atom,ion,isos',w,f,atom,ion,isos 
    n=len(w) < 20 
    for i  in np.arange( 0,n): 
        print(w(i),f(i),' ',atomn(atom(i)),' ', roman(ion(i)),'  ',atomn(isos(i)) 
    # 
     
    print('------------------------------ demodb ------------------------------' 
    print('Lindler''s sorting routines can come in handy too:' 
    print('  IDL> lines=dbnp.argsort(lines,''wl,atom,f'')' 
    print('  IDL> dbext,lines,''wl,f,atom,ion,isos'',w,f,atom,ion,isos' 
    print('Now the lines are sorted by wavelength, atomic number, ' 
    print('and oscillator strength.  So again' 
    print('  IDL> for i=0,n-1: print(w(i),f(i),atomn(atom(i)),roman(ion(i)),atomn(isos(i))' 
    print('gives a result sorted first by wl, next by atom,:f:' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    lines=dbnp.argsort(lines,'wl,atom,f') 
    dbext,lines,'wl,f,atom,ion,isos',w,f,atom,ion,isos 
    for i in range(n): 
        print(w(i),f(i),' ', atomn(atom(i)),' ',roman(ion(i)),' ',atomn(isos(i)) 
     
    print('------------------------------ demodb ------------------------------' 
    messdip,/inf,'this is the end of the database demo' 
    print('Of course, to learn more about the procedures (e.g. level.pro) you can: ' 
    print('     IDL > chkarg,''level''# gets argument list' 
    print('and  IDL >:c_library,''level''# gets header information' 
    print('-----------------------------------------------------------------------' 
    return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'demdb.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
