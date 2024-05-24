#!/usr/bin/env python

import os
import time
import numpy as np

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# Document name: demose.pro 
# Created by:    judge, June 15, 2006 
# 
# Last Modified: Thu Jul 20 11:40:27 2006 by judge (judge) on macniwot.local 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# 
def demose 
    # 
    @cdiper 
    messdip,'this demo introduces some calculations in HAOS-DIPER',/inf 
    s = '' &  read,'Enter <return> to continue>',s 
    # 
    print('------------------------------ demose ------------------------------' 
    print('First, you can make a statistical equilibrium calculation' 
    print('let''s read in some data from the database files, for atomic hydrogen..' 
    print('                                     IDL> diprd,''h'',1' 
    print('define temperature and density cgs   IDL> te=10.**(3.7+findgen(31)/25) & ed=1.e15/te' 
    print('solve the equations                  IDL> sesolv,te,ed,pop,res' 
    print('plot n=1 and continuum populations   IDL> plot,te,/xlog,pop(0,*),xtitle=''Te'',/ylog ' 
    print(' (res contains emissivity data)      IDL> oplot,te,/xlog,pop(atom.nk-1,*),lines=1' 
    print('                                     IDL> legend,linestyle=[0,1],[''n=1'',''n=cont'']' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    diprd,'h',1 
    te=10.**(3.7+findgen(31)/25) & ed=1.e15/te 
    sesolv,te,ed,pop,res 
    plot,te,/xlog,pop(0,*),xtitle='Te',/ylog 
    oplot,te,pop(atom.nk-1,*),lines=1 
    legend,linestyle=[0,1],['n=1','n=cont'] 
    # 
    print('-----------------------------------------------------------------------' 
    print('Notice that the above calculation was:ne at constant electron pressure' 
    print(' - you can enter any combination of electron temperature and density' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
     
    print('------------------------------ demose ------------------------------' 
    print('to over-plot the n=2 levels:' 
    print('  IDL> n2, = np.where(lvl.n == 2)' 
    print('  IDL> oplot,te,np.sum(pop(n2,*),1),linestyle=2' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    n2, = np.where(lvl.n == 2) 
    oplot,te,np.sum(pop(n2,*),1),linestyle=2 
    # 
    print('------------------------------ demose ------------------------------' 
    print('Another statistical equilibrium calculation' 
    print('read in some data from the database files, for iron' 
    print('                                     IDL> diprd,''fe'',[8,15]' 
    print('define temperature and density cgs   IDL> te=10.**(5.7+findgen(31)/25) & ed=1.e12+te*0.' 
    print('solve the equations                  IDL> sesolv,te,ed,pop,res' 
    print(' ' 
    print('define temperature and lower density IDL> te=10.**(5.7+findgen(31)/25) & ed=1.e6+te*0.' 
    print('solve the equations                  IDL> sesolv,te,ed,poplo,reslo' 
    print('plot ion fractions                   IDL> ionp,te,pop,fion,yran=[1.e-4,1]' 
    print('overplot ion fractions (low density) IDL> ionp,te,poplo,fion,/noplot' 
    print('                                     IDL> for i=0,7: oplot,te,fion(i,*)' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    diprd,'fe',[8,15] 
    k , = np.where(lvl.meta == 0) 
    level,del = k 
     
    #te=10.^(5.7+findgen(31)/25) & ed=1.e12+te*0. 
    #sesolv,te,ed,pop,res 
    #te=10.^(5.7+findgen(31)/25) & ed=1.e6+te*0. 
    #sesolv,te,ed,poplo,reslo 
    #te = alog10(te) 
    #ionp,te,pop,fion,yran=[1.e-4,1] 
    #ionp,te,poplo,fion,/noplot 
    #s = '' &  read,'Enter <return> to continue>',s 
    #for i=0,7 do oplot,te,fion(i,*),lines = 3 
    #s = '' &  read,'Enter <return> to continue>',s 
    print('------------------------------ demose ------------------------------' 
    print('Time evolution ' 
    print('                            IDL> t=10.**(-11+findgen(60)/4.)' 
    print('                            IDL> ed=1.e8+t*0# constant density' 
    print('                            IDL> te=1.e7+t*0# constant temperature' 
    print('                            IDL> startp=fltarr(atom.nk)*0.' 
    print('initial state (cold)        IDL> startp(0)=1.' 
    print('integrate                   IDL> timeser,t,te,ed,startp=startp,nt,nse' 
    print('plot evolution of first lev IDL> plot_oo,t,nt(0,*),lines=0' 
    print('-----------------------------------------------------------------------' 
    s = '' &  read,'Enter <return> to continue>',s 
    t=10.**(-11+findgen(60)/4.) 
    ed=1.e8+t*0# constant density 
    te=1.e7+t*0# constant temperature 
    startp=fltarr(atom.nk)*0. 
    startp(0)=1. 
    timeser,t,te,ed,startp=startp,nt,nse 
     
    count = 0 
    for j  in np.arange( min(lvl.ion),max(lvl.ion)+1): 
        ok , = np.where(lvl.ion == j) 
        y = np.sum(nt(ok,*),1)# ion populations 
        IF(j == min(lvl.ion)): 
        plot_oo,t,y,lines=0,xtitle = 'time [s]' 
    else: 
        oplot,t,np.sum(nt(ok,*),1),lines=count 
    ym = max(y) 
    xyouts,t(!c),y(!c),roman(j) 
    count = count+1 
# 
# 
print('------------------------------ demose ------------------------------' 
messdip,/inf,'this is the end of the calculation  demo' 
print('Of course, for to learn more about the procedures (e.g. se.pro) you can: ' 
print('     IDL > chkarg,''se''# gets argument list' 
print('and  IDL >:c_library,''se''# gets header information' 
print('-----------------------------------------------------------------------' 
return 
 
 
 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
# End of 'demose.pro'. 
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
