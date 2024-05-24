#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: dembasic.pro 
# Created by:    judge, June 15, 2006 
# 
# Last Modified: Thu Jul 20 13:13:28 2006 by judge (judge) on edlen.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def demobasic 
    # 
    messdip,'this demo introduces some data used in HAOS-DIPER',/inf 
    q = 'Enter <return> to continue..' 
    s = '' &  read,'Enter <return> to continue>',s 
    # 
    print('------------------------------ demobasic ------------------------------' 
    print('after pressing <return> this will execute IDL> @cdiper' 
    print('this makes available the data structures used:' 
    print('  atom, e.g.  atom.nk = number of stored levels' 
    print('  lvl,  e.g.  lvl.tsp1 = 2S+1 of LS coupled term' 
    print('  trn,  e.g.  trn.alamb = wavelength of transition in Angstrom' 
    print('  col,  e.g.  col.key = keyword describing type of collisional data' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    @cdiper 
    print('------------------------------ demobasic ------------------------------' 
    print('Now:' 
    print('  IDL> help,/structure,atom' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    help,/structure,atom 
    print('next      IDL> help,/structure,lvl' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    help,/structure,lvl 
    print('------------------------------ demobasic ------------------------------' 
    print('let''s read in some data from the database files, for atomic hydrogen..' 
    print('  IDL> diprd,''h'',1' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    diprd,'h',1 
    print('the atomic data structures are now filled with data for hydrogen' 
    print('for example, we can again say' 
    print('  IDL> help,/structure,lvl' 
    print('  IDL> print(lvl.label' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    help,/structure,lvl 
    print(lvl.label 
    print('------------------------------ demobasic ------------------------------' 
    print('a more powerful way of looking and manipulating the atomic levels ' 
    print('is to say' 
    print('  IDL> level' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    level 
    print('------------------------------ demobasic ------------------------------' 
    print('The procedure called level.def:es more than just list the data' 
    print('For example, let''s remove all levels with principal quantum numbers > 3' 
    print('To: this we say  IDL> ng3, = np.where(lvl.n > 3)' 
    print('and:          IDL> level, del=ng3' 
    print('followed by        IDL> level# lists all the levels stored' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    ng3, = np.where(lvl.n > 3) 
    level, del=ng3 
    level 
    print('------------------------------ demobasic ------------------------------' 
    print('to list just those levels with principal QN =2:' 
    print('  IDL> ne2, = np.where(lvl.n == 2)' 
    print('  IDL> level,list=ne2' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    ne2, = np.where(lvl.n == 2) 
    level,list=ne2 
    print('------------------------------ demobasic ------------------------------' 
    print('When levels are removed this way, all the atomic structures are also changed' 
    print('The trn structure contains data relevant to atomic radiative transitions' 
    print('and it can be examined using' 
    print('  IDL> trans' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    trans 
    print('------------------------------ demobasic ------------------------------' 
    print('Here you will see that no transitions exist with levels with n>3' 
    print('Like level.pro, trans.def allows some manipulation' 
    print('for example, we can list only electric dipole (E1) transitions, by:ing' 
    print('  IDL> e1, = np.where(trn.type == ''E1'')' 
    print('  IDL> trans,list=e1' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    e1, = np.where(trn.type == 'E1') 
    trans,list=e1 
    # 
    print('------------------------------ demobasic ------------------------------' 
    print('To: something with these data, we can plot a Grotrian (term) diagram:' 
    print('  IDL> td,wmax=1220.,/contlong' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    td,wmax=1220.,/contlong 
    # 
    print('------------------------------ demobasic ------------------------------' 
    print('You can also make a statistical equilibrium calculation' 
    print('(for more calculations use diper,demo=4)' 
    print('define temperature and density cgs   IDL> te=10.**(3.7+findgen(31)/25) & ed=1.e10+te*0.' 
    print('solve the equations                  IDL> sesolv,te,ed,pop,elc' 
    print('plot n=1 and continuum populations   IDL> plot,te,/xlog,pop(0,*),xtitle=''Te'',/ylog ' 
    print(' (res contains emissivity data)      IDL> oplot,te,/xlog,pop(atom.nk-1,*),lines=1' 
    print('                                     IDL> legend,linestyle=[0,1],[''n=1'',''n=cont'']' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    te=10.**(3.7+findgen(31)/25) & ed=1.e10+te*0. 
    sesolv,te,ed,pop,elc 
    plot,te,/xlog,pop(0,*),xtitle='Te',/ylog 
    oplot,te,pop(atom.nk-1,*),lines=1 
    legend,linestyle=[0,1],['n=1','n=cont'] 
    print('------------------------------ demobasic ------------------------------' 
    print('to over-plot the n=2 levels:' 
    print('  IDL> n2, = np.where(lvl.n == 2)' 
    print('  IDL> oplot,te,np.sum(pop(n2,*),1),linestyle=2' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    n2, = np.where(lvl.n == 2) 
    oplot,te,np.sum(pop(n2,*),1),linestyle=2 
    # 
    print('------------------------------ demobasic ------------------------------' 
    messdip,/inf,'this is the end of the basic demo' 
    print('Of course, for to learn more about the procedures (e.g. level.pro) you can: ' 
    print('     IDL > chkarg,''level''# gets argument list' 
    print('and  IDL >:c_library,''level''# gets header information' 
    print('-----------------------------------------------------------------------' 
    #print,'the IDL> diprd,atom command does other things.' 
    #print,'suppose you want to store data 
    return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'dembasic.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
