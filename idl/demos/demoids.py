#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: demoids.pro 
# Created by:    judge, June 30, 2006 
# 
# Last Modified: Fri Jun 30 18:31:03 2006 by judge (judge) on macniwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
# 
def demoids 
    # 
    messdip,'this demo shows how to annotate spectra with multiplets/lines',/inf 
    s = '' &  read,'Enter <return> to continue>',s 
    # 
    print('------------------------------ demoids ------------------------------' 
    print('first, read a spectrum, here''s one from HRTS: ' 
    print('  IDL> fil = concat_dir(getenv(''DIPER''),''data'')' 
    print('  IDL> fil = concat_dir(fil,''spectra'')' 
    print('  IDL> fil = concat_dir(fil,''qr.xdr'')' 
    print('  IDL> restore,fil' 
    print('Plot the data' 
    print('  IDL> plot,lambda,10.**intval,xtitle = ''Wavelength [A]'',$' 
    print('  IDL>    ytitle = ''Intensity erg cm!u-2!nsr!u-1!ns!u-1!n'',$' 
    print('  IDL>    xran = [1300,1310],title = ''HRTS quiet sun''# plot a spectrum ' 
    print('  IDL> subset=''ion<4,atom>7,type=E1''# find E1 transitions in the desired range of ions' 
    print('  IDL> idspec,subset=subset# mark identification on the spectrum' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    fil = concat_dir(getenv('DIPER'),'data') 
    fil = concat_dir(fil,'spectra') 
    fil = concat_dir(fil,'qr.xdr') 
    restore,fil 
    plot,lambda,10.**intval,xtitle = 'Wavelength [A]',   ytitle = 'Intensity erg cm!u-2!nsr!u-1!ns!u-1!n',   xran = [1300,1310],title = 'HRTS quiet sun'# plot a spectrum 
    subset='ion<4,atom>7,type=E1'# find E1 transitions in the desired range of ions 
    idspec,subset=subset# mark identification on the spectrum 
    # 
    # 
    print('------------------------------ demoids ------------------------------' 
    print('the character string subset used above tells diper which' 
    print('type of transition to include in the plot. ' 
    print(' ' 
    print('The syntax is that used in Lindlers'' database system,' 
    print('applied to the atom_bb database.  ' 
    print('' 
    print('So, we can search on any of the atom_bb variables, but search' 
    print('using the indexed variables first for speed! First, list variables:' 
    print('' 
    print('  IDL> dbopen,''atom_bb''# open database' 
    print('  IDL> dbhelp,1# list the variables' 
    print('  IDL> dbclose# ' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    dbopen,'atom_bb' 
    dbhelp,1 
    dbclose 
     
    print('------------------------------ demoids ------------------------------' 
    print('Now we''ll be a bit more picky, putting IDs only where emission is..' 
    print('  IDL> plot,lambda,10.**intval,xtitle = ''Wavelength [A]'',$' 
    print('  IDL>    ytitle = ''Intensity erg cm!u-2!nsr!u-1!ns!u-1!n'',$' 
    print('  IDL>    xran = [1300,1310],title = ''HRTS quiet sun''# plot a spectrum ' 
    print(' ' 
    print(' make a different subset' 
    print('  IDL> subset1=''ion = 1,atom = 8'' lines of O I only' 
    print('  IDL> idspec,subset=subset1# mark identification on the spectrum' 
    print('' 
    print(' get Si II data only, and plot at a different starting ordinate' 
    print('  IDL> subset1=''ion = 2,atom = 14'' lines of Si II only' 
    print('  IDL> idspec,subset=subset1,ystart=0.7# mark identification on the spectrum' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    plot,lambda,10.**intval,xtitle = 'Wavelength [A]',   ytitle = 'Intensity erg cm!u-2!nsr!u-1!ns!u-1!n',   xran = [1300,1310],title = 'HRTS quiet sun'# plot a spectrum 
    subset1='ion = 1,atom = 8'#lines of O I only 
    idspec,subset=subset1# mark identification on the spectrum 
    subset1='ion = 2,atom = 14'# lines of Si II only 
    idspec,subset=subset1,ystart=0.7# mark identification on the spectrum 
     
     
    print('------------------------------ demoids ------------------------------' 
    print('What about that emission feature near 1300.9 Angstrom?' 
    print('  IDL> dbopen,''atom_bb''# open database' 
    print('  IDL> ok=dbfind(''wl=1300.9(0.5)'')# find anything within 0.5A' 
    print('  IDL> ok=dbnp.argsort(ok,''wl,f,atom,ion'')# sort by wl,f, atom, ion' 
    print('  IDL> dbprint(ok,''atom,ion,wl,f'' ' 
    print('  IDL> dbclose# ' 
    print(' You get to decide if this belongs to the list of elements found' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    dbopen,'atom_bb'# open database 
    ok=dbfind('wl=1300.9(0.5)') 
    ok=dbnp.argsort(ok,'wl,f,atom,ion')# sort by wl,f, atom, ion' 
    dbprint(ok,'atom,ion,wl,f' 
    dbclose# 
     
    print('------------------------------ demoids ------------------------------' 
    messdip,/inf,'this is the end of the idspec demo' 
    print('Of course, for to learn more about the procedures (e.g. idspec.pro) you can: ' 
    print('     IDL > chkarg,''idspec''# gets argument list' 
    print('and  IDL >:c_library,''idspec''# gets header information' 
    print('-----------------------------------------------------------------------' 
    #print,'the IDL> diprd,atom command does other things.' 
    #print,'suppose you want to store data 
    return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'demoids.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
