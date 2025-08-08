####################################################################################################
#
# Main subprograms for pydip package
#
####################################################################################################
import sqlite3
import numpy as np
from scipy.interpolate import CubicSpline
from scipy import interpolate
from scipy import special 
from matplotlib import pyplot as plt
from collections import defaultdict
from astropy.io import ascii
import scipy.special as sp
import time
import copy
import subprocess
import platform
import sys
import math
####################################################################################################
def abmass(name):      # nominal
    #
    # use: print(abmass('fe'))
    # 
    nm = atomnum(name) 
    # 
    mass_data=[1.0080,4.0026,6.941,9.0122,10.811,12.0111,14.0067,15.9994,18.9984,20.179,
                   22.9898,24.305,26.9815,28.086,30.9738,32.06,35.453,39.948,
                   39.102,40.08,44.956,47.90,50.9414,51.996,54.9380,55.847,58.9332,58.71,
                   63.546,65.37] 
    # 
    ab_data=[12,10.93,0.7,1.1,3,8.52,7.96,8.82,4.6,7.92,
                 6.25,7.42,6.39,7.52,5.52,7.20,5.6,6.8,
                 4.95,6.30,3.22,5.13,4.40,5.85,5.40,7.60,5.1,6.30,4.5,4.2] 
    # 
    if(nm > len(mass_data)): 
        print('atomic number=',nm) 
        print('ABMASS: Elements up to Zn (atomic number 30) are only included')
        return None, None
    # 
    return  ab_data[nm-1], mass_data[nm-1] 

####################################################################################################
def addon(d,e):    # nominal 
    #
    # append an array of dicts "e" onto d, merely a loop over d.append(e)
    #
    for j in range(0,len(e)): d.append(e[j])
    return d

####################################################################################################
def ar85(atom,te,nne):   # alpha (no charge transfer as yet)
    #
    #  Bound-free collisions according to Arnaud and Rothenflug 1985 and Arnaud Raymond
    #
    # Compute bound-free collisional ionization rates for
    # electron temperature te and density nne
    #
    # The collisional rates can also be computed for
    # non-Maxwellians as the coefficients for cross sections
    # or e- impact ionization enter both the energy-dependent
    # and Maxwellian integrated forms similarly.
    # 
    # Includes a rough treatment of the reduction of dielectronic
    # recombination rates using a by-eye "fit" to calculations by
    # Summers 1974 for various isoelectronic series.
    #
    ee=const()['ee']
    cc=const()['cc']
    hh=const()['hh']
    bk=const()['bk']
    ryd=const()['rydinf']/hh/cc
    nstar=ltepop(atom,te,nne)
    #
    # level attributes:
    #
    lvl=atom['lvl']
    nl=len(lvl)
    meta=dict2array(lvl,'meta',int)  # metastable levels
    nm=len(meta)
    met=[]
    for i in range(0,nm):
        if(meta[i] ==1): met.append(i)
    #
    # now have an array met of metastable level indices
    #
    ion=dict2array(lvl,'ion',int)  # ions in lvl
    rate=np.eye(nl)*0.  # output array of ionization and recombination rates
    #
    # cbf ollision attributes:
    #
    cbf=atom['cbf']
    nc=len(cbf)
    catom=dict2array(cbf,'atom',int)
    cion=dict2array(cbf,'ion',int)
    #print(nc, 'CION ',cion)
    ############################################# 
    #
    # density dependent dielectronic recombination
    # rough treatment:
    # get the row and column of the recombined ion's isoelectronic 
    # sequence  in the periodic table
    # the following parameters mimic the tables 1-19 of
    # H. Summers' Appleton Lab Report 367, 1974
    #
    fdr=1.
    iel = lvl[0]['atom']   
    iz = iel-lvl[0]['ion']+1  
    irow,icol = rowcol(iz)
    zi =    lvl[0]['ion']  # -1. 
    ro=nne/zi/zi/zi/zi/zi/zi/zi
    x = (zi/2. + (icol-1.))*irow/3.0
    beta = -0.2/np.log(x+2.71828)
    ro0 = 30.+50.*x
    fdr= (1. + ro/ro0)**beta
    #
    ############################################# 
    t4=te/1.e4
    t=0.+te
    csource=[]
    for i in range(0,nc): csource.append(cbf[i]['source'])
    #
    # match the cbf data to the metastable levels present in the atomic model
    # and return the energy level indices im and jm
    #
    for im in met:
        ioni=ion[im]
        for ic in range(0,nc):    # loop over all coefficients cbf
            if csource[ic] == 'ar85ci' and cion[ic] == ioni:   # find direct collisional ionizatio
                ip= float(cbf[ic]['a'])
                x=ip*const()['ee']/const()['bk']/te
                a=cbf[ic]['b']
                b=cbf[ic]['c']
                c=cbf[ic]['d']

                d=cbf[ic]['e']
                fx=np.exp(-x)*np.sqrt(x)*(a + b*(1.+x) +
                                          (c-x*(a+b*(2.+x)) ) * fone(x) + d*x*ftwo(x))
                cup = 6.69e-07/ip/np.sqrt(ip)*fx
                #
                # get each  upper level  jm
                #
                for jm in range(0,nl):
                    if(ion[jm] == (ion[im]+1) and meta[jm]==1):
                        rate[im,jm]+=cup*nne
                        rate[jm,im]+=rate[im,jm] * nstar[im]/nstar[jm]   # three body recombination
            ##################################################
            if(csource[ic] == 'shull82' and cion[ic] == ioni):
                arad=float(cbf[ic]['arad'])
                xrad=float(cbf[ic]['xrad'])
                adi=float(cbf[ic]['adi'])
                bdi=float(cbf[ic]['bdi'])
                t0=float(cbf[ic]['t0'])
                t1=float(cbf[ic]['t1'])
                cdn=arad*t4**(-xrad) + fdr*adi/t**1.5/np.exp(t0/t) * (1.+bdi*np.exp(-t1/t))
                for jm in range(im,nl):
                    if(ion[jm] == (ion[im]+1) and meta[jm]==1):
                        rate[jm,im]+=cdn*nne
                        #print('SHU IM ',lvl[im]['label'], '      ',im, ' JM ',jm, 'UP ',rate[im,jm], 'DOWN',rate[jm,im])
                #
                # loop over non-metastable levels only
                # perhaps important at high densities only.
                #
                #                cbar=2.3 # mean scaled cross section
                #                for iim in range(0,len(lvl)):
                #                    if(lvl[iim]['meta'] == 0):
                #                        ilo=lvl[iim]['ion']
                #                        for jm in met:
                #                            iup=lvl[jm]['ion']
                #                            if(iup== (ilo+1) and iim < jm):
                #                                de=lvl[jm]['e']-lvl[iim]['e']
                #                                print('DE ',de)
                #                                z=ilo-1
                #                                beta = 0.25*(((100.*z +91)/(4.*z+3))**0.5 -5.)
                #                                x = de*hh*cc/bk/te
                #                                xx=1.+1./x
                #                                print('XX ',im,jm,x,xx)
                #                                w = np.log(xx)**(beta/xx)
                #                                q = 2.1715e-08*cbar*(ryd/de)**1.5 * np.sqrt(x) * sp.exp1(x)* w
                #                                q *= nne *lvl[ilo]['nactive']  # number of active electrons
                #                                rate[iim,jm] += q
                #                                print('q x w ryd ryd/de ',q,x,w,ryd , ryd/de)
                #                                rate[jm,iim] += rate[im,jm] * nstar[im]/nstar[jm]
    return rate
    
####################################################################################################
def atomname(x):   # nominal
    #
    #  use: atomname(6) will yield 'C'
    name=['H','HE','LI','BE','B','C','N','O','F','NE',
            'NA','MG','AL','SI','P','S','CL','AR',
            'K','CA','SC','TI','V','CR','MN','FE','CO','NI','CU',
            'ZN','GA','GE','AS','SE','BR','KR','RB','SR','Y','ZR','NB',
            'MO','TC','RU','RH','PD','AG','CD','IN','SN','SB','TE','I',
            'XE','CS','BA','LA','CE','PR','ND','PM','SM','EU','GD','TB','DY',
            'HO','ER','TM','YB','LU','HF','TA','W','RE','OS','IR','PT','AU',
            'HG','TL','PB','BI','PO','AT','RN','FR','RA','AC','TH','PA','U']
    return name[x-1].capitalize()
   
####################################################################################################
def atomnum(x):    # nominal
    #
    # use: atomnm('c') will yield 6
    name=['H','HE','LI','BE','B','C','N','O','F','NE',
            'NA','MG','AL','SI','P','S','CL','AR',
            'K','CA','SC','TI','V','CR','MN','FE','CO','NI','CU',
            'ZN','GA','GE','AS','SE','BR','KR','RB','SR','Y','ZR','NB',
            'MO','TC','RU','RH','PD','AG','CD','IN','SN','SB','TE','I',
            'XE','CS','BA','LA','CE','PR','ND','PM','SM','EU','GD','TB','DY',
            'HO','ER','TM','YB','LU','HF','TA','W','RE','OS','IR','PT','AU',
            'HG','TL','PB','BI','PO','AT','RN','FR','RA','AC','TH','PA','U']
    xup=x.upper()
    for i in range(0, len(name)):
        if xup == name[i]: return i+1
    return -1

####################################################################################################
def bbcalc(gf,gu,gl,wl,typ):   # alpha
    #
    # use: 
    # calculate Einstein A and B parameters of transition from gf,g, etc.
    #  bbcalcgf,gu,gl,wl,typ) returns  A, Bji, Bij
    c=const()
    hh = const()['hh']
    cc= const()['cc']
    #
    a=0.
    bji=0.
    bij=0.
    #
    #  type is dipole or quadrupole?
    #
    cc=const()['cc']
    em=const()['em']
    ee=const()['eesu']
    pi=const()['pi']
    wcm=wl/1.e8
    c=8.* (pi * ee )**2 / (em*cc)   # a=c/lambda^2
    a=0.
    bij=0.
    bji=0.
    type = typ.replace(' ','')
    if "1" in type or "IC" in type:
        a=c * (gf/gu) / wcm / wcm
        bji=wcm*wcm*wcm/(hh*cc*cc)
        bij=bji*gu/gl
    if "F" in type:
        small=1.e-20
        a=small
        bij=small
        bji=small
    return a, bji, bij

####################################################################################################
def bbdata(atom):
    #
    #  
    # calculate an index for multiplets, get string variables for
    #   transition labels, jup, jlo.  
    # 
    # Append the new data to the bb array, 
    #  
    hh = const()['hh']
    cc= const()['cc']
    em=const()['em']
    ee=const()['eesu']
    pi=const()['pi']
    ############################################################
    lvl=atom['lvl']
    bb=atom['bb']
    wl=dict2array(bb,'wl',float)
    typ=dict2array(bb,'type',str)
    wcm=wl/1.e8
    #
    #
    # multiplet index
    #
    lab=[]
    termu=[]
    terml=[]
    ju=[]
    jl=[]
    for i in range(len(bb)):
        jind=bb[i]['j']
        lj=lvl[jind]
        iind=bb[i]['i']
        li=lvl[iind]
        #
        # complete labels of upper and lower terms
        #

        u=lj['label'].rsplit(' ',2)
        termj=u[1]
        conj=u[0].lower()

        l=li['label'].rsplit(' ',2)
        termi=l[1]
        coni=l[0].lower()

        termj=conj + ' '+termj
        termi=coni + ' '+termi
        termu.append(termj)
        terml.append(termi)
        ju.append(u[2])
        jl.append(l[2])
        lab.append( termj+' : '+termi )
        #
    #
    mindex=np.array(0*wl,dtype=int)
    count=1
    for i in range(len(bb)):
        bb[i]['terml']=terml[i]
        bb[i]['termu']=termu[i]
        bb[i]['ju']=ju[i]
        bb[i]['jl']=jl[i]
        if(mindex[i] == 0):
           mindex[i]=count
           same = [ij for ij, value in enumerate(lab) if value == lab[i] ]
           mindex[same]=count
           for ij in same:
               bb[ij]['mindex']=count
           count+=1
    #
    return bb

####################################################################################################
def bbrd(file,atom,ions):   # nominal
    #
    # use: returns bb dict object from file for atom=6, ion=2 say (C II)
    #  bb dict contains data for bound-bound radiative transitions
    #
    print(file)
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()

    res = cur.execute("SELECT * FROM bb where atom= "+str(atom)+" and ion="+str(ions))

    print(res)
    bb=res.fetchall() 
    conn.close()
    return bb
    

####################################################################################################
def bfdata(atom):   # dev
    #
    # use: 
    # return distributed cross sections from LS-coupled
    # cross-sections to cross sections for individual levels
    #
    #
    lvl=atom['lvl']
    ions=dict2array(lvl,'ion',int)  # ions in lvl
    ground=dict2array(lvl,'ground',int)  # ions in lvl
    uion = np.unique(ions)
    nu=len(uion)
    if(nu < 2):
        print('bfdata: only one ion - no cross sections assigned to atom')
        return atom
    count=0
    #
    file=dippy_dbdir+'bfsql.db'
    #
    orgbf=bfrd(file,atomnum(atom['name']),ions[0])
    #
    for ion in range(1,len(uion)):
        new=bfrd(file,atomnum(atom['name']),uion[ion])
        orgbf+=new  # OK because these are list types
    #
    #
    #
    newbf=[orgbf[0]]
    tcount=0
    for ii in range(0,nu):
        i=uion[ii]
        lo = numwhere(i,  ions)
        nl=len(lo)
        hi = numwhere(i+2,ions+ground)
        nh=len(hi)
        for kr in range(0,len(orgbf)):  # loop over bf data
            for ll in range(0,nl):  # loop over all levels of ion i
                l=lo[ll]
                for hh in range(0,nh): # loop over levels of ion i+1
                    h=hi[hh]
                    if(lvl[l]['term1'] == orgbf[kr]['term1'] and
                       lvl[l]['orb1'] == orgbf[kr]['orb1'] and 
                       lvl[l]['term2'] == orgbf[kr]['term2'] and
                       lvl[l]['orb2'] == orgbf[kr]['orb2'] ): 
                        add=copy.deepcopy(orgbf[kr])
                        add['i']=l
                        add['j']=h
                        add=[add]
                        newbf=[*newbf,*add]
                        count+=1
    print('dp.bfdata: new number of bf transitions',count, len(newbf)-1)
    newbf=newbf[1:]
    atom['bf'] = newbf
    return atom


####################################################################################################
def bfrd(file,atom,ions):    # nominal
    #
    # use: returns bf dict object from file for atom=6, ion=2 say (C II)
    #  bf dict contains data for bound-free radiative transitions (photoionization)
    #  These are cross sections between TERMS and must be distributed
    # spectral across LEVELS to be used to get rate coefficients
    #
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()

    res = cur.execute("SELECT * FROM bf where atom= "+str(atom)+" and ion="+str(ions))

    bf=res.fetchall()
    n=len(bf)
    for i in range(0,n):
        bf[i]['lam'] = np.frombuffer(bf[i]['lam'])
        bf[i]['sigma'] = np.frombuffer(bf[i]['sigma'])
    conn.close()
    return bf


####################################################################################################
def cea(iel,ion,te):
    #
    #  Include excitation-autoionization according to AR85
    #
    # identify the isoelectronic sequence of the impacted ion
    #
    ee=const()['ee']
    cc=const()['cc']
    hh=const()['hh']
    bk=const()['bk']
    ryd=const()['rydinf']/hh/cc
    z=ion-1
    iea=0 # default
    isoel=iel-z
    cea=0.
    bkt=bk*te/ee
    if(isoel == 3):  # Lithium
        aa=0.25
        bb=0.835
        if(iel < 7):
            aa=0.
            bb/=1.208
            iea=13.6*( (z-bb)**2 - aa*(z-1.62)**2 )
            zeff=(z-0.43)
            b=1./(1.+0.0002*z*z*z)
            y=iea*ee/bk/te
            fy=fone(y)
            lam=hh*cc/((iea-64.5)*ee)*1.e8 
            g=2.22*fy +0.67*(1.-y*fy) + 0.49*y*fy + 1.2*y*(1-y*fy)
            cea=1.60e-07*b*1.2/zeff/zeff/np.sqrt(bk*te/ee)*np.exp(-y)*g
        if(iel == 6): cea*=0.6
        if(iel == 7): cea*=.8
        if(iel == 8): cea*=1.25
        if(isoel == 11 and z <=16):  # Sodium
            iea=26.*(z-10)
            a=2.8e-17/(z-11.)**0.7
            y=iea*ee/bk/te
            cea=6.69e+7*a*iea/np.sqrt(bk*te/ee)*np.exp(-y)*(1.-y*fone(y))
        if(isoel == 11 and z >16):  # Sodium
            iea=11.*(z-10)**1.5
            a=1.e-14/(z-10.)**3.73
            y=iea*ee/bk/te
            cea=6.69e+7*a*iea/np.sqrt(bk*te/ee)*np.exp(-y)*(1.-0.5*(y-y*y)+y*y*y*fone(y))
        if(isoel > 11 and isoel < 17 and z > 18): # others
            a=4.e-13/z/z
        if(isoel == 12): iea=10.3*(z-10)**1.52
        if(isoel == 13): iea=18.0*(z-11)**1.33
        if(isoel == 14): iea=18.4*(z-12)**1.36
        if(isoel == 15): iea=23.7*(z-13)**1.29
        if(isoel == 16): iea=40.1*(z-14)**1.10
        if(iea != 0):
            y=iea*ee/bk/te
            #cea=6.69e+7*a*iea/np.sqrt(bk*te/ee)*np.exp(-y)*(1.-0.5*(y-y*y)+y*y*y*fone(y))
        print(cea)
        return cea

####################################################################################################
def cbbrd(file,lvl):    #   alpha 
    #
    # use: returns cbb dict object from file for atom=6, ion=2 say (C II)
    #  cbb dict contains data for bound-bound thermal collision rates 
    #
    t0=time.time()
    if(dippy_regime == 2):
        print('cbbrd: regime is lte, return None')
        quit()

    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()
    sb="SELECT * FROM cbb "
    #
    # get minimum and maximum entries in the lvl array
    #
    minl=lvl[0]['entry']
    maxl=lvl[-1]['entry']
    n=len(lvl)
    #
    atom = int(lvl[0]['atom'])
    ion = int(lvl[0]['ion'])
    ions=dict2array(lvl,'ion',int)  # ions in lvl
    ions=np.unique(ions)   
    ni=len(ions) # -1
    cbb=[]
    #
    #  get atom and ion array ions
    #
    # loop over lower ion stages only
    #
    for ii in range(0,ni):   
        s=" WHERE atom= "+  str(atom) + ' and ion= ' + str(ions[ii])
        #
        res = cur.execute(sb +  s)
        x=res.fetchall()
        #print('dp.cbbrd:  ', sb+s)
        #print('dp.cbbrd: ',len(x), ' cbb coefficients in db ')
        nx=len(x)
        count=0
        for jj in range(nx):
            if(x[jj]['i'] != x[jj]['j'] and
               x[jj]['i'] >=  minl    and 
               x[jj]['j'] <=  maxl ): cbb.append(x[jj])
            else:
                count+=1
        #if(count > 0): print('WARNING cbb ',count, ' coefficients are outside range ',minl,maxl)
    #print('dp.cbbrd: number of cbb transitions ',len(cbb))
    conn.close()
    return cbb
    
####################################################################################################
def cbfrd(dir,lvl):    # alpha
    #
    # use: returns cbfut dict object from file for atom=6, ion=2 say (C II)
    #  cbf dict contains data for bound-free thermal ionization collision rates 
    #  coefficients are given as listed by Arnaud+Rothenflug 1985, Arnaud+Raymond(?)
    #
    if(dippy_regime == 2):
        print('cbfrd: regime is lte, return None')
        quit()
    n=len(lvl)
    atom = int(lvl[0]['atom'])
    ion = int(lvl[0]['ion'])
    ions=dict2array(lvl,'ion',int)  # ions in lvl
    ions=np.unique(ions)   
    ni=len(ions)-1
    #
    # electron collisional ionization
    # Arnaud and Rothenflug 1985.
    #
    filename= dir + 'ar85ci.dat'
    data=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
    #print('DATA',data)
    out=[]
    #
    # loop over lower ion stages only
    #print('NI  ',ni, ions)
    for ion in ions:
        #print('ATOM ION',ion)
        for j in range(0,len(data)):
            a=int(data['atom'][j])
            i= int(data['ion'][j])
            if (a == atom and i == ion):
                c=data[j]
                out.append({'atom':c['atom'],'ion':c['ion'],'source':'ar85ci','ishell':c['ishell'],
                        'a':c['a'],'b':c['b'],'c':c['c'],'d':c['d'],'e':c['e']})
    #
    # charge transfer collisional ionization and recombination
    # Arnaud and Rothenflug 1985.
    #
    # recombination rates are from Shull & Van Steenburg, ionization from them
    #  is inaccurate and should not be used. 
    #
    #print('OUT CI', out[-1])
    filename= dir + 'ar85ct.dat'
    data=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
    #print('DATA1',data)
    for ion in ions:   
        for j in range(0,len(data)):
            a=int(data['atom'][j])
            i= int(data['ion'][j])
            if a == atom and i == ion:
                c=data[j]
                out.append({'atom':c['atom'],'ion':c['ion'],'source':'ar85ct','projectile':c['projectile'],
                'a':c['a'],'b':c['b'],'c':c['c'],'d':c['d'],'e':c['e'],'f':c['f']})

    #
    #  Shull rate coefficients 
    filename= dir + 'shull82.dat'
    data=ascii.read(filename,delimiter=' ',guess=False,fast_reader=False)
    for ion in ions:   
        for j in range(0,len(data)):
            a=int(data['atom'][j])
            i= int(data['ion'][j])
            if a == atom and i == ion:
                c=data[j]
                out.append({'atom':c['atom'],'ion':c['ion'],'source':'shull82','acol':c['acol'],'tcol':c['tcol'],
                         'arad':c['arad'],'xrad':c['xrad'],'adi':c['adi'],'bdi':c['bdi'],'t0':c['t0'],'t1':c['t1']})
    return out
    
####################################################################################################
def check(atom):   # NOT READY
    lvl=atom['lvl']
    bb=atom['bb']
    cbb=atom['cbb']
    for ic in range(len(cbb)):
        if cbb[ic]['i'] >= len(lvl) :
            print('CHECK: STOP cbb j=',cbb[ic]['i'], '> # levels',len(lvl))
            quit()
        if cbb[ic]['j'] >= len(lvl) :
            print('CHECK: STOP cbb j=',cbb[ic]['j'], '> # levels',len(lvl))
            quit()
            

def col(atom): # nominal
    cbb=atom['cbb']
    l=len(cbb)
    count=0
    if(l <1): print('dp.col: no collisions !')
    else:
        print(cbb[0].keys())
        #print(" index         E cm-1            Label             g   Lifetime s ion")
        #for l in cbb:
        #    print( "{0:4d} {1:16.3f}  {2:24s}  {3:5.1f}  {4:9.1e} {5:s}".
        #           format(count,l['e'],l['label'],l['g'],l['lifetime'], roman(l['ion']) ))
        count+=1
    print()
    print('dp.col: listing of b-b collisions, number =',count)


####################################################################################################
def const():      # nominal
    # physical constans
    # use:  e= const()['ee']
    # 
    #       EE               electon charge in V = e^2/r
    #       HH=6.626176D-27  planck's constant 
    #       CC=2.99792458D10 speed of light 
    #       EM=9.109534D-28  electron mass 
    #       UU=1.6605655D-24 hydrogen mass 
    #       BK=1.380662D-16  Boltzmann constant 
    #       PI=3.14159265359 pi 
    #       GS=2.0*1.0011596389 electron spin
    #       following combinations are stored 
    #       HCE=HH*CC/EE*1.e8 
    #       HC2=2.*HH*CC *1.e24 
    #       HCK=HH*CC/BK*1.D8 
    #       EK=EE/BK 
    #       HNY4P=HH*CC/QNORM/4./PI*1.D-5 
    #       RYDBERG=2*PI*PI*EM*EE*(EE/HH)*(EE/HH)*(EE/HH)/CC 
    #       ALPHA=2*PI*ee*ee/HH/CC   fine structure constant 
    #
    ee=1.602189e-12
    hh=6.626176e-27
    cc=2.99792458e10
    eesu=ee*cc/1.e8
    es= eesu
    em=9.109534e-28
    gs=2.0*1.0011596389
    bk=1.380662e-16
    pi=3.14159265359e0
    bk=1.380662e-16
    uu=1.6605655e-24

    c = {"ee":ee,"hh":hh,"cc":cc,"em":em,"gs":gs,"uu":uu,"bk":bk,"pi":pi,"hce":(hh/ee*cc)*1.e8,"hc2":2.*hh*cc *1.e24,
    "hck":hh*cc/bk*1.e8,"ek":ee/bk,"es": es,"rydinf":2*pi*pi*em*es*(es/hh)*(es/hh)*(es),"alphafs":2*pi*es*es/hh/cc,"eesu": eesu,
    "a0 ": (hh/eesu)*(hh/eesu)/(4*pi*pi)/em,"bohrm":hh*eesu/4/pi/em/cc,"designations": 'SPDFGHIKLMNOQRTU'}
    return c


####################################################################################################
def convl(alambda):    # nominal 
    #   
    #   converts vacuum lambda to air (>2000 A). 
    #   lam_air=convl(lam)   lam is in Angstrom units
    # 
    #
    # refractive index from IUE 
    #
    w0=2000.0
    if hasattr(alambda, "__len__"):
        l=len(alambda)
        out=np.zeros(l)
        for i in range(0,l):
            out[i]=alambda[i]
            w=alambda[i]
            if(w > w0):
                out[i] = w/(1.0+2.735182E-4+131.4182/w/w+ 2.76249E8/w/w/w/w)
    else:
        out = alambda/(1.0+2.735182E-4+131.4182/alambda/alambda+ 2.76249E8/alambda/alambda/alambda/alambda)
    return out

####################################################################################################
def dict_factory(cursor, row):  # nominal
    fields = [column[0] for column in cursor.description]
    return {key: value for key, value in zip(fields, row)}

####################################################################################################
def dict2array(dict,key,dtype):   # nominal 
    #  gets an array from a dict
    # use: energy = dict2array(lvl,'e',float)
    #
    n=len(dict)
    out=np.empty(n,dtype=dtype)
    for l in range(0,n):
        out[l] = dict[l][key]

    return out
    
####################################################################################################
def diplist(aname):
    print()
    print('Atom  Ion     NL    NBB    NBF   NCBB')
    iel = atomnum(aname)
    for ion in range(1,iel):
        atom=diprd(iel,ion,True)
        if atom['ok'] == True:
            nlvl=len(atom['lvl'])
            nbb=len(atom['bb'])
            nbf=len(atom['bf'])
            ncbb=len(atom['cbb'])
            print('{:2s}'.format(atom['name']),'{:6s}'.format(roman(ion)),
                '{:6d}'.format(nlvl),
                  '{:6d}'.format(nbb),
                  '{:6d}'.format(nbf),
                  '{:6d}'.format(ncbb)
                  )
            list=1
    return list


####################################################################################################
def diprd(atom,ions, boundonly):    # beta
    # reads atom dict from the sql database 
    # atom= diprd(6,2) returns atom dict for C II ion
    # atom={'name','lvl','bb','bf','cbb','cbf','ok']  - general case.
    #
    #  output depends on dippy_regime global
    # 
    ok=True
    ion=ions
    if(boundonly ==None):boundonly=False
    name=atomname(atom)
    print('diprd: ', name, ' ', roman(ions))
    dir=dippy_dbdir
    file='lvlsql.db'
    lvl=lvlrd(dir+file,atom,ions,boundonly)
    nl=len(lvl)
    lvl=qn(lvl)
    if(nl == 0):
        #print('WARNING No atomic levels found ', atomname(atom))
        atomnew={'name':name,'ok':False}
        return atomnew
#
    ipot=ipotl(atom,ions)
    file='bbsql.db'
    bb=bbrd(dir+file,atom,ions)
    #
    w=dict2array(bb,'wl',float)  # wavelength of transition
    nt=len(bb)
    for kr in range(0,nt):
        f=bb[kr]['f']
        wl_ang=bb[kr]['wl']
        up=bb[kr]['j']
        lo=bb[kr]['i']
        #print('up ',type(up))
        typ=bb[kr]['type']
        #
        # find levels associated with the transition
        #
        entry=dict2array(lvl,'entry',int)
        okay=np.asarray(entry == up).nonzero()
        okay=(np.array(okay)).squeeze()
        gu=lvl[okay]['g']
        okay=np.asarray(entry == lo).nonzero()
        okay=(np.array(okay)).squeeze()
        gl=lvl[okay]['g']
        gf=gl*f
        a,bji,bij=bbcalc(gf,gu,gl,wl_ang,typ)
        bb[kr]['aji']=a
        #
    cbf=cbfrd(dir,lvl)
    #
    #  various regimes, to build full atom
    #
    if(dippy_regime != 2):  # only levels and radiative data
        file='bfsql.db'
        bf=bfrd(dir+file,atom,ions)
        atomnew= {'name':name,'lvl':lvl,'bb':bb,'bf':bf, 'ok':ok}
    if(dippy_regime == 0):   # no b-f transitions, use recombination coefficients
        file='cbbsql.db'
        cbb=cbbrd(dir+file,lvl)
        print('DIPRD: reading bb collisions, number = ', len(cbb))
        atomnew= {'name':name,'lvl':lvl,'bb':bb,'cbb':cbb,'cbf':cbf, 'ok':ok}
    if(dippy_regime == 1):   # read all data
        file='bfsql.db'
        bf=bfrd(dir+file,atom,ions)
        file='cbbsql.db'
        cbb=cbbrd(dir+file,lvl)
        atomnew= {'name':name, 'lvl':lvl,  'bb':bb,'bf':bf,  'cbb':cbb,  'cbf':cbf, 'ok':ok}
    #
    atomnew=zindex(atomnew)
    atomnew=ltime(atomnew)
    
    return atomnew

####################################################################################################
def diprd_multi(atomnum,ions):    # alpha 
    #
    #  read in  ions, such as diprd(6,[1,2,3,4]) which will read energy levels for
    #    element 6 (Carbon) for ionization stages I, II, III, IV PLUS the ground state
    #    of C V.
    #
    # is atomnum and ions sensible?
    #
    mn=min(ions)
    mx=max(ions)
    if(mn < 0 or mx > atomnum):
        print('diprd_multi: ions out of range ',ions, ' for ', atomnum, ' -- quit()')
        quit()
    dir=dippy_dbdir
    
    boundonly=True
    #
    #  get the first atom with only bound states to append later
    #
    atom0=diprd(atomnum,ions[0],boundonly)
    name=atom0['name']
    lvl=atom0['lvl']
    bb=atom0['bb']
    ipot=ipotl(atomnum,ions[0])
    #print('First ion has ',len(lvl), 'levels and IP of ',ipot,' eV')
    if(dippy_regime  == 0):
        cbb=atom0['cbb']
        cbf=atom0['cbf']
    if(dippy_regime == 2):
        bf=atom0['bf']   
    if(dippy_regime == 1):
        bf=atom0['bf']   
        cbb=atom0['cbb']
        cbf=atom0['cbf']
    #print('diprd_multi: number of collisions first ion ',len(cbb))
    # temporarily disable bf (photo-ionization)
    print('dpird_multi:  BF cases to be included later')
    bf=None
    #
    # loop over ions to be read
    #
    for ion in ions[1:]:
        lzero=len(lvl)  # needed to re-index bb and cbb only.
        atomq=diprd(atomnum,ion,boundonly)
        ipot=ipotl(atomnum,ion)
        lvlq=atomq['lvl']
        #print('Next  ion has ',len(lvlq), 'levels and IP of ',ipot,' eV')
        for j in range(0,len(lvlq)):
            lvlq[j]['e'] += ipot * const()['ee'] / const()['hh'] / const()['cc']        
            #print('MULRD ',lvl[j]['lifetime'])
        lvl=addon(lvl,lvlq)
        lvl=qn(lvl)  # get quantum numbers
        #
        # Now fix indices on bb and cbb arrays
        #
        #print('LEN MULTI ',len(lvl))
        bbq=atomq['bb']
        #
        for j in range(0,len(bbq)):
            bbq[j]['j'] += lzero
            bbq[j]['i'] += lzero
        bb=addon(bb,bbq)
        #
        if(dippy_regime == 0):
            bf=None
            print('BF IS NONE regime corona')
            atom={'name':name,'lvl':lvl,'bb':bb,'bf':bf}
        else:
            bfq=None
            cbbq=atomq['cbb']
            #print('diprd_multi: number of collisionsq: ',len(cbbq))
            #
            for j in range(0,len(cbbq)):
                cbbq[j]['j'] += lzero
                cbbq[j]['i'] += lzero
            cbb=addon(cbb,cbbq)
            bfq=None
            #print('diprd_multi: number of collisions: ',len(cbb))
            cbfq=atomq['cbf']
            cbf=addon(cbf,cbfq)
            atom={'name':name,'lvl':lvl,'bb':bb,'bf':bf,'cbb':cbb,'cbf':cbf,'ok':True}
        #
    return atom

####################################################################################################
def fone_ar85(x):   # not ready 
    #
    # function needed for AR85 rate coefficients
    # 
    quit()
    if(x >=10):
        f=(1. -1./x +2/x/x -6./x/x/x + 24./x/x/x/x)/x
    if(x > 0.02 and x < 10):
        a=-0.5
        if(x >= 1.5): a=0.5
        f=np.log( 1. +1./x) - (0.36 + 0.03*(x+0.01)**a)/(x-1.)/(x-1.)
    if(x <= 0.02):
        f=np.exp(x)* (- np.log(x) -0.2773 +x)
    return f

####################################################################################################
def fone(x):   
    #
    # function needed for AR85 rate coefficients
    # 
    return np.exp(x)*sp.exp1(x)

####################################################################################################
def ftwo(x):
    #
    #  appendix B.2 of Arnaud and Rothenflug
    #
    p=[1.e0,2.16577591e+02,2.03358710e+04,1.09106506e+06,3.71139958e+07,
           8.39632734e+08,1.28891814e+10,1.34485688e+11,9.40017194e+11,
           4.25707553e+12, 1.17430457e+13,1.75486750e+13,1.08063014e+13,
           4.97762010e+11]
    q =[1.e0,2.1958e+02,2.0984e+04,1.1517e+06,4.0349e+07,9.4900e+08,1.5345e+10,
        1.7182e+11,1.3249e+12,6.9071e+12,2.3531e+13,4.9432e+13,5.7760e+13,
        3.0225e+13,3.3641e+12]
    xi=1./x
    px = p[0]+xi*(p[1] + xi*(p[2]+ xi*(p[3]+ xi*(p[4]+ xi*(p[5]+ xi*(p[6]+ 
         xi*(p[7]+ xi*(p[8]+ xi*(p[9]+ xi*(p[10]+ xi*(p[11]+ xi*(p[12] 
         ))))))))))))
    qx = q[0]+xi*(q[1] + xi*(q[2]+ xi*(q[3]+ xi*(q[4]+ xi*(q[5]+ xi*(q[6]+ 
         xi*(q[7]+ xi*(q[8]+ xi*(q[9]+ xi*(q[10]+ xi*(q[11]+ xi*(q[12]+ 
         xi*(q[13])))))))))))))
    return xi*xi*px/qx

####################################################################################################
def geff(lv1,lv2):    # not ready, quit()
    #
    #  effective lande G factor in the small field limit 
    #  given lande g-factors and J values and energies in lvl objects 
    #  lvl1 and lvl2. 
    #  returns geff(longitudinal) and Geff(transverse)
    #
    print('geff not ready')
    quit()
    lo =  lv1 
    up =  lv2 
    if(lv1['e'] > lv2['e']): 
        lo = lv2 
        up = lv1 
# 
    jlo = (lo['g']-1.)/2. 
    jup = (up['g']-1.)/2. 
    gup=glande_ls(up)
    glo=glande_ls(up)
    
    g = (glo+gup)/2. + 0.25*(glo-gup)  *    ((jlo*(jlo+1.)) - jup*(jup+1.)) 
# 
#  gtrans is the second order Lande factor from Landi & Landini 
# 
# eq 9.77 9.78 of L&L2004 and table3.4 
# 
    s= jlo*(jlo+1.) + jup*(jup+1.) 
    d= jlo*(jlo+1.) - jup*(jup+1.) 
    gd=lo.glande-up.glande 
    delta= gd*gd/80. *(16.*s-7.*d*d-4.) 
    gtrans= g*g - delta 
 
    return g, gtrans 

####################################################################################################
def glan_ls(s,l,j):      # not ready
    #
    # lande g-factor for LS coupling for level ^(2S+1)L_J
    #  s= spin ang mom qn     
    #  l= orbital ang mom qn   
    #  j=total ang mom qn
    #
    print('glan_ls not ready')
    quit()
    if (j+s == 0): return 1.0
    gs = const()['gs']
    ss = s*(s+1.)
    ll = l*(l+1.)
    jj = j*(j+1.)
    return ( jj+ll-ss + gs* (jj-ll+ss)) /2. / jj
    
#################################################################################################### 
def ipotl(atomnum,ion):     # nominal, limited to Atomic numbers  < 29
    #
    # returns ionization potential, e.g. for H I use ipotl(1,1) (atomic number, spectrum number)
    #
    ip=np.nan
    if(atomnum < 28): ip=iprd()[atomnum,ion]
    return ip

####################################################################################################
def iprd():   # nominal 
    # reads in array of ionization potentials.  returns None when there is no data
    text = open(dippy_dbdir + 'mooreip.dat')
    data = text.read()
    text.close()    
    data=data.split()
    #
    ndata = int( data[0] )
    ip=np.eye(ndata+1,dtype=float)*0.
    count=1
    for elem in range(1,ndata+1):
        for i in range(1,elem+1):
            ip[elem,i]=data[count]
            if(ip[elem,i] < 0.): ip[elem,i]=None
            count+=1
    return ip

####################################################################################################
def keyzero(dict):   # nominal, just print out first key value pairs in a dict array
    for key, value in dict[0].items() :
        print (key, value)
    return

####################################################################################################
def level(atom): # nominal
    lvl=atom['lvl']
    count=0
    print(lvl[0].keys())
    print(" index         E cm-1            Label             g   Lifetime s ion")
    for l in lvl:

        print( "{0:4d} {1:16.3f}  {2:24s}  {3:5.1f}  {4:9.1e} {5:s}".
               format(count,l['e'],l['label'],l['g'],l['lifetime'], roman(l['ion']) ))
        #print("%10.3E" % (356.08977))   # print exponential value
        count+=1

####################################################################################################
def ltepop(atom,te,nne):
    #
    # Compute LTE populations for atom at electron temperature te
    # and electron density ne (cm/3)
    #
    ee=const()['ee']
    em=const()['em']
    cc=const()['cc']
    hh=const()['hh']
    bk=const()['bk']
    pi=const()['pi']
    rydinf=const()['rydinf']/hh/cc
    #
    lvl=atom['lvl']
    nk=len(lvl)
    nstar=np.zeros(nk)
    glog = np.log(dict2array(lvl,'g',float))
    #print(lvl)
    #print('GLOG',glog)
    e = dict2array(lvl,'e',float)
    ion = dict2array(lvl,'ion',int)
    #
    totn=1.e0
    sumn=0.
    #
    xxx = hh/np.sqrt(2.*pi*em)/np.sqrt(bk)
    ccon=xxx*xxx*xxx/2.
    conl=np.log(ccon*nne)-1.5*np.log(te)
    sumn=1.0
    tns=nstar
    #
    # reduction of ionization potential
    # Griem 1964 formula. 
    #
    ev = e*hh*cc/ee
    #
    # LTE loop:
    #
    tnsl = glog-glog[0]- ee*ev/bk/te
    smallflag='True'
    smallest=sys.float_info.min*1.e2
    for k in range(1,nk):
        delta=ion[k] - ion[0]
        if(delta > 0): tnsl[k]-= delta * conl
        tns[k]=np.exp( tnsl[k] )
        if math.isnan(tns[k]):
            tnl[k]=smallest
            smallflag='True'
        sumn+= tns[k]
    #
    nstar[0]=totn/sumn
    for i in range(1,nk):
        nstar[i]=nstar[0]*tns[i]
    return nstar

####################################################################################################
def ltime(atom):
    #
    # returns lifetime of each level in atom and stores in lvl[i]['lifetime']
    # and lvl is itself stored in atom
    #
    lvl=atom['lvl']
    bb=atom['bb']
    r=4
    for l in range(len(lvl)):
        lvl[l]['lifetime']= 0.
        for r in range(len(bb)):
            if(bb[r]['j']) == l:
                #print('LTIME ',r,bb[r]['aji'])
                lvl[l]['lifetime'] += bb[r]['aji']
        #
        #print('INV Lifetime of level ',l,' = ', lvl[l]['lifetime'])

        if lvl[l]['lifetime'] > 0: lvl[l]['lifetime']=1./ lvl[l]['lifetime'] 
        #
        # print('Lifetime of level ',lvl[l]['label'],' = ', lvl[l]['lifetime'])
    atom['lvl']=lvl
    return atom
               
####################################################################################################
def lvlrd(file,atomn,ions,boundonly):   # beta, check addition of next ion stage
    #
    # read energy levels from database file and return in dict lvl
    #
    if(boundonly ==None):boundonly=False
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()
    res = cur.execute("SELECT * FROM lvl where atom= "+str(atomn)+" and ion="+str(ions))
    lvl=res.fetchall()
    if boundonly == False:
        sstr="SELECT * FROM lvl where atom= "+str(atomn)+" and ion="+str(ions+1)
        res = cur.execute(sstr)
        lvlnext=res.fetchone()
        if(lvlnext != None):
            ipot=ipotl(atomn,ions)
            lvlnext['e']+= ipot * const()['ee'] / const()['hh'] / const()['cc']
            lvlnext['meta']=1
            lvl.append(lvlnext) 
    conn.close()
    nl=len(lvl)
    if nl == 0:
        return lvl
    #print('lvlrd ',np.shape(lvl), ' atomn ions ',atomn,ions)
        
    lvl=qn(lvl)  # get quantum numbers
    return lvl

#
#
def matchcol(atom,ilab,jlab):
#
#  matches input strings ilab and jlab to unique level strings
#  and returns corresponding tlog and omega arrays
#    
    if(atom['ok'] == True):
        #print(atom.keys())
        cbb=atom['cbb']
        lvl=atom['lvl']
        ion= lvl[0]['ion']
        nc=len(cbb)
        tl=   3.7 + 2.*np.log10(ion)
        o=np.nan
        lup=0
        llo=0
        for il in range(0,len(lvl)):
            lab,term =uniqlev(lvl,il)
            if(lab == ilab): llo=il
            if(lab == jlab): lup=il
        #print('matchcol ',ilab,jlab, ' : ',llo,lup)
        for kc in range(0,nc):
            up=cbb[kc]['j']
            lo=cbb[kc]['i']
            if(up == lup and lo == llo):
                temp=np.frombuffer(cbb[kc]['t'])
                omega=np.frombuffer(cbb[kc]['o'])
                #print('matchcol ', temp,omega)
                spl = CubicSpline(temp, omega, bc_type='natural')
                o=spl(tl)
        return tl, o

#

######################################################################
def matchf(atom,ilab,jlab):
#
    if(atom['ok'] == True):
        #print(atom.keys())
        lvl=atom['lvl']
        bb=atom['bb']
        nf=len(bb)
        o=np.nan
        lup=0
        llo=0
        for il in range(0,len(lvl)):
            lab,termlab=uniqlev(lvl,il)
            if(lab == ilab): llo=il
            if(lab == jlab): lup=il
        for kf in range(0,nf):
            up=bb[kf]['j']
            lo=bb[kf]['i']
            if(up == lup and lo == llo):
                o=bb[kf]['f']
        return o


####################################################################################################
#
def missing(atom):   # v1.0
#
#   get  missing transitions from bb and store in bbm
#    
    bb=atom['bb']
    nb=len(bb)
    nb0=nb
    if(nb == 0): return 0
    xbb = []  # part of output array
    print()
    print('dp.missing: filling bb and atom with missing transitions')
    #
    #   get unique string for term for each atomic level 
    #
    lvl = atom['lvl']
    nl=len(lvl)
    uniqterm=[]
    uniqlvl =[]
    for l in range(nl):
        levstr,termstr= uniqlev(lvl,l)
        uniqlvl.append(levstr)
        uniqterm.append(termstr)
    #
    #
    #
    uniqtrn=[]   # a unique identifier for all transitions between levels
    #
    count=0
    for k in range(1,nl):
        for l in range(k):
            str=uniqlvl[k]+uniqlvl[l]
            uniqtrn.append(str)
            count+=1
    #
    # get multiplet indices from bb array
    #
    m=   dict2array(bb,'mindex',int)  # index of transition
    um=np.unique(m)
    print(len(um) , ' unique multiplets and ', len(bb), ' transitions')
    jrad=dict2array(bb,'j',int)  # j of transition
    irad=dict2array(bb,'i',int)  # i of transition
    #
    #  find all levels belonging to a multiplet, using term string
    #
    kr=np.arange(len(bb))
    for im in um:    # loop over all multiplets in bb 
        #
        ok = numwhere(im, m)  # get all lines in bb for multiplet
        #
        #
        use = ok[0]  # use the first line to get the termu, terml
        #
        type = bb[use]['type']
        #
        # OK is index in bb of all transitions
        #
        # Next:
        # find the set of allowed transitions between
        # all levels in lvl for this multiplet
        #
        j= bb[use]['j']
        i= bb[use]['i']
        #  upper and lower are indices 
        upper=uniqterm[j]
        lower=uniqterm[i]
        count=0
        #
        #  here are the permitted lines of all multiplets
        #
        for iu in range(1,nl):
            upt=uniqterm[iu]
            if (upt == upper):           # possibly   belongs to the multiplet

                for il in range(nl):
                    lot=uniqterm[il]
                    #
                    if(lot == lower):    # definitely belongs to the multiplet
                        #
                        # is it in bb already?
                        #
                        absent = True
                        for kr in range(nb0):
                            if(absent & iu == jrad[kr] & il == irad[kr]): absent=False
                        if(absent):
                            sum = lvl[iu]['g']+lvl[il]['g']
                            dif = lvl[iu]['g']-lvl[il]['g']
                            dif=np.abs(dif) 
                            signal = False
                            if(type == 'E1'): signal =    (sum > 2) &  (dif <= 2)
                            if(type == 'IC'): signal =    (sum > 2) &  (dif <= 2)
                            if(type == 'M1'): signal =    (sum > 2) &  (dif <= 2)
                            if(type == 'E2'): signal =    (sum > 4) &  (dif <= 4)
                            if(type == 'M1E2'): signal =  (sum > 4) &  (dif <= 4)
                            if(signal):
                                new = bb[use]
                                nb+=1
                                new['type'] = type
                                new['i'] = il
                                new['j'] = iu
                                new['ref'] = 'Missing transition'
                                new['f'] = 0.
                                new['aji'] = 0.
                                new['entry'] = nb
                                de = abs( lvl[iu]['e'] - lvl[il]['e'] )*100.
                                if(de == 0.): de=1.e-10
                                wl= 1./de*1.e10
                                new['wl'] = wl
                                new['mindex'] = im
                                bb.append(new)
                                if((wl > 5240.) & (type == 'IC') & (wl < 5260.)):
                                    print(new)
    print('bb expanded from ',nb0,' to ',len(bb), ' in filling with missing transitions')
    return bb

                        
#######################################################################
def nla(inla):   # nominal
    #
    #  takes an integer number encoded as integer nla and decodes it into
    #  principal QN n, orbital ang mom l, and number of electrons a
    #  for example 301  is 3s^1 orbital, returns '3S1'
    #
    n = int(inla/100)
    l = int( (inla-n*100)/10)
    a = int(inla-n*100 -l*10)
    sn=str(n)
    sl = const()['designations'][int(l)]
    #print(nla,n,l,a)
    sa=''
    if(a > 0): sa=str(a)
    return n,l,a, sn+sl+sa

####################################################################################################
def outerqn(config):    # beta
    #
    # get principal QN for outer electrons, and number of outer electrons, from string config
    # 
    lastwd= config.replace("{","")
    lastwd= lastwd.replace("}","")
    while ' ' in  lastwd:
        lastwd = (lastwd.split(' ',1))[1]
    out=''
    for ii, c in enumerate(lastwd):
        #print('LASTWD', lastwd, ii, '   C    ', c)
        if c.isdigit():
            out+=c
            break
    #
    out=int(out)
    #print('LAST WD ',lastwd, ' OUT  ', out)
    lastwd=lastwd[::-1]  # reverse string
    outn=''
    for ii, c in enumerate(lastwd):
        if c.isdigit():
            outn+=c
        else: break
    if(len(outn)) !=0:
        outn=outn[::-1]  # reverse string
        outn=int(outn)
    else:
        outn=1
    return out,outn

######################################################################
def pvr(z,b):
    #
    #  thermal p-function for semic empirical collision rates
    #  reference: sobel'man - 'atomic physics ii.  '
    #  z (Scalar) is 1 for neutrals
    #  b (scalar) = energy / kT  (linear)
    #
    if(b > 10.):
        p = 0.200
        if(z == 0): p = 0.066 / np.sqrt(b) 
        return p
    #
    if(b < 0.01): 
        return 0.29*special.exp1(b)
    #
    #  intermediate temps (most important for eqm plasmas)
    #  linear interpolation onto logb grid:
    #
    if(b >= 0.01 and b <= 10.0):
        x = np.array([-2.0,-1.699,-1.398,-1.0,-0.699,-0.398,0.0,0.301,0.602,1.0])
        y0 = np.array([1.160,0.956,0.758,0.493,0.331,0.209,0.100,0.063,0.040,0.023])
        y1 =  np.array([1.160,0.977,0.788,0.554,0.403,0.290,0.214,0.201,0.200,0.200])
        p0=interpolate.interp1d(x, y0,kind='quadratic')
        p1=interpolate.interp1d(x, y1,kind='quadratic')
        blog=np.log10(b)
        p= p0(blog)
        if(z == 1): p=p1(blog)
        return p


####################################################################################################
def planck(wm,t):  # beta
    cc=const()['cc']
    hh=const()['hh']
    bk=const()['bk']
    pi=const()['pi']
    nu=cc/wm
    return  (2.*(hh*nu)*(nu/cc)*(nu/cc)) / (np.exp(hh*nu/bk/t) -1.)

    ####################################################################################################
def qn(lvl):  # beta
    #
    # get quantum numbers for levels and add to lvl dictionary
    # quantum numbers S, L, P, n, nactive and meta parameter are appended to lvl
    # n= principal qn, nactive = number of outer shell electrons
    # S = 2*spin+1 of term, L = orbital ang mom of term, P = parity of configuration
    #  meta= 1 (metstable level, i.e. all terms belonging to the ground configuration 
    #
    # find qn_meta (0 or 1 according to metastable or not),
    # a metastable level is one with the same configuration as the ground level
    # of each ion
    #
    nl=len(lvl)
    meta=np.zeros(nl,dtype=int)
    ground=np.zeros(nl,dtype=int)
    #
    # loop over all ions present
    #
    im=[]
    im.append(0)
    for i in range(1,len(lvl)):
        if (lvl[i]['ion'] == lvl[i-1]['ion']+1):
            im.append(i)
    #
    count=-1
    #
    # loop over metastables found and include all with same
    #  configuration
    #
    for ij in im:
        count+=1
        S,L,P,string = slp(lvl[ij]['term1'])
        config0=lvl[ij]['label'].rsplit(' ', 2)[0]
        term0=lvl[ij]['label'].rsplit(' ', 3)[0]
        n,nactive=outerqn(config0)
        lvl[ij]['meta']=1
        lvl[ij]['pqn']= n  # all up to but excluding the ang mom
        lvl[ij]['nactive']= nactive  # all up to but excluding the ang mom
        lvl[ij]['S']=int(S)
        lvl[ij]['L']=int(L)
        lvl[ij]['P']=int(P)
        for ik in range(0,nl):
            configi=lvl[ik]['label'].rsplit(' ', 2)[0]
            if(configi == config0):
                meta[ik]=1
                termi=lvl[ik]['label'].rsplit(' ', 3)[0]
                if(termi == term0):
                    ground[ik]=1
                #print('level ',ik,' with label ', configi,' ',lvl[ik]['label'], ' is metastable')
            #
            # define S L and P in all levels
            #
            # is there a space in the config? If so, edit it further
            # 
            yes= ' ' in configi
            if ' ' in configi: lastwd = (configi.split(' ',1))[1]
            #
            S,L,P,string = slp(lvl[ik]['term1'])
            #
            # find numbers in front of a non-numeric string
            #
            n,nactive=outerqn(configi)
            lvl[ik]['pqn']= n  # all up to but excluding the ang mom
            lvl[ik]['nactive']= nactive  # all up to but excluding the ang mom
            lvl[ik]['config']=configi
            lvl[ik]['meta']=meta[ik]
            lvl[ik]['ground']=ground[ik]
            lvl[ik]['S']=int(S)
            lvl[ik]['L']=int(L)
            lvl[ik]['P']=int(P)
        #if(count > 2): quit()
    #
    #for i in range(0,nl):
    #    if(lvl[i]['meta']==1): print('metastable ',i,lvl[i]['label'])

    return lvl

####################################################################################################
def ratematrix(atom,te,ne,nstar):   # beta
    #
    # get full (singular) rate matrix for atomic model in the atom dict,
    #
    # inputs are scalars te, ne, and array nstar of lte populations
    # output is a the rate matrix with dimensions sec^-1 (probability per unit time)
    #
    hh=const()['hh']
    cc=const()['cc']
    em=const()['em']
    ee=const()['ee']
    pi=const()['pi']
    bk=const()['bk']
    lvl=atom['lvl']
    nl=len(lvl)
    lhs=np.eye(nl,dtype=float)*0.
    #
    # radiative rates, einstein A coefficients
    #
    bb=atom['bb']
    w=dict2array(bb,'wl',float)  # wavelength of transition
    #
    nt=len(bb)
    for kr in range(0,nt):
        f=bb[kr]['f']
        wl_ang=bb[kr]['wl']
        up=bb[kr]['j']
        lo=bb[kr]['i']
        typ=bb[kr]['type']
        if(up < nl and lo < nl and lo < up):
            #
            # find levels associated with the transition
            #
            gu=lvl[up]['g']
            gl=lvl[lo]['g']
            gf=gl*f
            a,bji,bij=bbcalc(gf,gu,gl,wl_ang,typ)
            lhs[up,lo] +=a
            lhs[lo,up]+=0.  # no incident radiation
            if(a < 0.): print('a ',a)
    #
    # collisional rates, bound-bound first 
    #
    cbb=atom['cbb']
    nt=len(cbb)
    tl=np.log10(te)
    cmn=8.63e-06 * ne * (1.e0) / np.sqrt(te)
    for kc in range(0,nt):
        if(kc !=0 and kc % 1000 ==0): print(kc,'/',nt)
        up=cbb[kc]['j']
        lo=cbb[kc]['i']
        if(up < nl and lo < nl):
            # decode 
            temp=np.frombuffer(cbb[kc]['t'])
            omega=np.frombuffer(cbb[kc]['o'])
            
            spl = CubicSpline(temp, omega, bc_type='natural')
            omega=spl(tl)
            gu=lvl[up]['g']
            cdn= 8.63e-06 * ne * (omega/gu) / np.sqrt(te)
            lhs[up,lo] +=cdn 
            cup= cdn*nstar[up]/nstar[lo]
            if(cup < cmn): cmn=cup  # needed to fill in missing collisions
            #print(up,lo,omega,cdn)
            lhs[lo,up] +=cup
    #
    c=ar85(atom,te,ne)
    lhs+=c
    count=0
    for i in range(0,nl):
        lhs[i,i]=0.
        lhs[i,i] = - (lhs[i,:]).sum()
        #
        # fix for zero collision rates
        #
        # find closest level to i
        if(lhs[i,i] == 0.): 
            elev=dict2array(lvl,'e',float)  # ions in lvl
            elev[i]=-999
            dif = np.absolute(lvl[i]['e'] - elev)
            j=dif.argmin()
            # 
            lhs[i,j]=cmn/1.e8
            lhs[j,i]=lhs[i,j]*nstar[i]/nstar[j]
            count+=1
            lhs[i,i] = - (lhs[i,:]).sum()
            #print(' adding collisions for zero-rate level ',i,lvl[i]['label'],'  to    ',j,lvl[j]['label'])
    #
    #if(count > 0):
        #print('dp.ratematrix', count,' levels had zero rates')

    return lhs.T

####################################################################################################    
def redatom(atom, *args, **kwargs):   # alpha 
    # 
    # reduce atom size, according to keywords
    # examples:
    # atom = redatom(atom,lowestn=True):  keep all levels with principal QN = lowest in ion
    # atom = redatom(atom,lowestplus=True):   "             " <= lowest in ion + 1
    # atom = redatom(atom,meta=True):  keep all metastable levels only 
    #
    name=atom['name']
    np.set_printoptions(precision=2)
    print()
    print('--------------------------------------------------------------------------------')
    print('dp.redatom:  reducing atom...')
    #
    lvl=atom['lvl']
    nl=len(lvl)
    inlabl=[]
    for i in range(0,len(lvl)):
        inlabl.append(lvl[i]['label'])
    #
    bb=atom['bb']
    bf=atom['bf']
    cbf=atom['cbf']
    cbb=atom['cbb']
    #
    # define outputs outlvl, outbb etc
    #
    outlvl=[]
    ##########################################################################################
    # this is where we specify which levels to keep.
    # lowestn means keep each level of each ion
    # with the same principal qn as ground state
    #
    lowestn = kwargs.get('lowestn', None)
    lowestplus = kwargs.get('lowestplus', None)
    meta = kwargs.get('meta', None)
    #
    if lowestn != None and lowestplus == None and meta == None:
        print('keeping LOWESTN')
        ion = int(lvl[0]['ion'])
        ions=dict2array(lvl,'ion',int)  # ions in lvl
        ions,indx = np.unique(ions,return_index=True)   
        counti=-1
        countl=-1
        for ion in ions:
            counti+=1
            ipqn = lvl[indx[counti]]['pqn']
            for i in range(0,len(lvl)):
                new=lvl[i]['pqn']
                if(lvl[i]['ion'] ==ion and new == ipqn):
                    countl+=1
                    outlvl.append(lvl[i])
    #
    if meta != None and lowestn == None and lowestplus == None:
        print('keeping META')
        countl=-1
        for i in range(0,len(lvl)):
            if(lvl[i]['meta'] ==1):
                outlvl.append(lvl[i])
                countl+=1
    if lowestplus != None and lowestn == None and meta == None:
        print('keeping LOWESTPLUS')
        countl=-1
        ion = int(lvl[0]['ion'])
        ions=dict2array(lvl,'ion',int)  # ions in lvl
        ions,indx = np.unique(ions,return_index=True)   
        counti=-1
        for ion in ions:
            counti+=1
            pqp1 = lvl[indx[counti]]['pqn']+1
            for i in range(0,len(lvl)):
                new=int(lvl[i]['pqn'])
                if(lvl[i]['ion'] == ion and new <= pqp1):
                    outlvl.append(lvl[i])
                    countl+=1
    #                print('adding lowestplus', ion, lvl[i]['label'],' : ', new, ' is <= ', pqp1 )
    #
    print(countl ,' levels kept')
    #
    #
    #   add more options for reducing atomic levels here
    #   such as redatom(atom, level=level)...
    #
    #
    outlab=[]
    for i in range(0,len(outlvl)):
        outlab.append(outlvl[i]['label'])
        #print(i, outlvl[i]['label'])
    ##########################################################################################
    # Levels are now all set, next:
    # other atomic parameters, bb,cbb etc.
    # 
    nbb=len(bb) # bb, nbb are original arrays/ length
    outbb=[]  # output array
    count=0
    #print(bb[0])
    print('--------------------------------------------------------------------------------')
    print('REDATOM original # of levels  ', nl, ', new # levels = ',len(outlvl))
    for l in range(0,nbb):
        j=bb[l]['j']  # original energy level index
        i=bb[l]['i']  # original energy level index
        #
        # if i and j are among the new levels, then include it
        #
        temporary=bb[l]
        if inlabl[j] in outlab and inlabl[i] in outlab:
            temporary['i']=outlab.index(inlabl[i])
            temporary['j']=outlab.index(inlabl[j])
            outbb.append(temporary) 
            count+=1
    print('REDATOM original # of bb ', len(bb), ' new # bb = ',len(outbb))
    #
    # bound-free
    nbf=len(bf) # bb, nbb are original arrays/ length
    outbf=[]  # output array
    count=0
    for l in range(0,nbf):
        j=bf[l]['j']  # original energy level index
        i=bf[l]['i']  # original energy level index
        #
        # if i and j are among the new levels, then include it
        #
        temporary=bf[l]
        if inlabl[j] in outlab and inlabl[i] in outlab:
            temporary['i']=outlab.index(inlabl[i])
            temporary['j']=outlab.index(inlabl[j])
            outbf.append(temporary) 
            count+=1
    print('REDATOM original # of bf ', len(bf), ' new # bf = ',len(outbf))
    #
    # bound-free
    nbf=len(bf) # bb, nbb are original arrays/ length
    outbf=[]  # output array
    count=0








    ncbb=len(cbb)
    outcbb=[]
    count=0
    count=0
    for l in range(0,ncbb):
        j=cbb[l]['j']  # original energy level index
        i=cbb[l]['i']  # original energy level index
        #
        # if i and j are among the new levels, then include it
        #
        temporary=cbb[l]
        if inlabl[j] in outlab and inlabl[i] in outlab:
            temporary['i']=outlab.index(inlabl[i])
            temporary['j']=outlab.index(inlabl[j])
            outcbb.append(temporary) 
            count+=1
    print('REDATOM orig # of cbb ', ncbb, ' new # cbb = ',len(outcbb))
    #
    # output
    #
    atom=ltime(atom)
    atom={'name':name, 'lvl':outlvl,'bb':outbb,'cbb':outcbb,'cbf':cbf}
    #
    print('atom reduced to ',len(outlvl),' levels ',len(outbb),' bb ',len(outcbb),' cbb')
    print('--------------------------------------------------------------------------------')
    return atom

####################################################################################################
def roman(i):
    #
    # return roman equivalent of arabic numeral up to 99
    #
    z = ['','I','II','III','IV','V','VI','VII','VIII','IX'] 
    dec = ['','X','XX','XXX','XL','L','LX','LXX','LXXX','XC'] 
    lab = []
    for j in range(0,len(dec)): 
        for k in range(0,len(z)): 
            lab.append(dec[j]+z[k] )
    #
    return lab[i] 

####################################################################################################
def rowcol(i): 
    # 
    # returns the row and column of the element in 
    # the periodic table- the row is the "period", but 
    # the column is just the order in which elements occur 
    # in the row.  it is not the "group" 
    # 
    istart = [0,2,10,18,36,54,86] 
    for  j in range(len(istart)): 
        if(i > istart[j] and i <= istart[j+1]):irow=j 
    icol=i-istart[irow]
    irow = irow+1
    return irow,icol

####################################################################################################
def se(atom,te,ne):   # beta
    #
    # solve statistical equilibrium equations for atom dict with te, ne plasma t and density
    #
    hh=const()['hh']
    cc=const()['cc']
    pi=const()['pi']
    bk=const()['bk']
    #

    lvl=atom['lvl']
    nk=len(lvl)
    ion=dict2array(lvl,'ion',int)
    e  =dict2array(lvl,'e',float)
    g  =dict2array(lvl,'g',float)
    label  =dict2array(lvl,'label',str)
    #
    nstar=ltepop(atom,te,ne)
    #
    #  build rate matrix and solution vector
    #
    lhs=ratematrix(atom,te,ne,nstar)


    therme=bk*te
    atome = e*hh*cc
    e2kt=atome/therme
    idx = np.argmin(np.abs(e2kt - 0.5))

    isum=idx
    lhs[isum,:]=1.
    rhs = np.arange(0,nk)*0.
    rhs[isum]=1.
    sol = np.linalg.solve(lhs,rhs)
    #
    # emission line cooefficients
    #
    bb=atom['bb']
    #
    #  output upper level indices and emission line coefficients
    #
    nbb=len(bb)
    w=dict2array(bb,'wl',float)/1.e8  # cm
    a=dict2array(bb,'aji',float)
    up = np.array(dict2array(bb,'j',int))
    lo = np.array(dict2array(bb,'i',int))

    eps= hh*cc/w/4/pi * sol[up]*a
    w*=1.e8 # AA
    mx=np.max(eps)
    amx=np.max(a)
    return sol, nstar, w, eps, lhs

####################################################################################################
def slp(islp):    # alpha
    #
    # return encoding for term so 311 --> 3,1,1,'3Po'
    #
    ispin = int(islp/100 )
    ill =int( (islp-ispin*100)/10 )
    ipar = int(islp-ispin*100 -ill*10) 
    # 
    strl = const()['designations'][ill]
    sspin = str(ispin) 
    par = ['E','O'] 
    spar = par[ipar]
    return ispin,ill,ipar,sspin+strl+spar

####################################################################################################
def slpr(islp):    # not ready
    #
    # return reverse encoding from slp, for term 3P1 --> S=1 L=1 1 J=1
    #
    print('slpr not ready')
    quit()
    ispin = int(islp/100 )
    ill =int( (islp-ispin*100)/10 )
    ipar = int(islp-ispin*100 -ill*10) 
    # 
    strl = const()['designations'][ill]
    sspin = str(ispin) 
    par = ['E','O'] 
    spar = par[ipar]
    return sspin+strl+spar

####################################################################################################
def specid(atom):
    #
    # plot line ids on a spectrum
    #
    # The dict atom is the result of loading atomic name, energy levels,
    # bound-bound atomic transitions using atom=diprd(atomic_number, ion)
    # or diprd_multi(atomic_number, ions)
    #
    # The current plot, whose x-axis is assumed to be in ANgstrom units,
    # is over-plotted with tick marks and labels showing atomic transitions
    #
    name=atom['name']
    bb=atom['bb']
    lvl=atom['lvl']
    mindex=dict2array(bb,'mindex',int)
    uindex=np.unique(mindex)
    #
    # parameters for plotting ids
    #
    xmin,xmax,ymin,ymax=plt.axis()
    #
    # length of down ticks
    dy=(ymax-ymin)/120.
    # starting height for labels
    y0=ymin+0.9*(ymax-ymin)
    done = np.zeros(len(bb),int)
    for kr in range(0,len(bb)):
        ion=lvl[bb[kr]['i']]['ion']
        if(done[kr] == 0):
            same = [i for i, value in enumerate(mindex) if value == mindex[kr] ]
            #
            # find indices use, that match this mindex and are in the right wavelength range
            #
            warray=[]
            farray=[]
            juarray=[]
            jlarray=[]
            yes=False
            txt=atom['name'] + ' '+ roman(ion) + ' '+ bb[kr]['termu']+' -  '+bb[kr]['terml']

            for s in same:
                warray.append(convl(bb[s]['wl']))
                farray.append(np.sqrt(bb[s]['f']))
                juarray.append(bb[s]['ju'])
                jlarray.append(bb[s]['jl'])
            #
            warray=np.array(warray)
            for i in range(len(warray)):
                w=warray[i]
                if(w > xmin and w < xmax): yes=True
            if(yes):
                for i in range(len(warray)):
                    xtra=''
                    if(farray[i] == 0.): xtra='*'
                    w=warray[i]
                    f=max(farray[i],.1)
                    plt.plot([w,w], [y0,y0-dy*2],'k')
                    if(xtra != '*'):
                        t=plt.text(w+.009*(xmax-xmin),y0-dy*2.5,juarray[i]
                                   + "-"+ jlarray[i]+xtra,fontsize=6)
                        t.set_bbox(dict(facecolor='white', alpha=0.2,linewidth=0))
                #
                # horizontal line and text
                #
                plt.plot(warray,y0+ warray*0.,'k')
                txt=atom['name'] + ' '+ roman(ion) + ' '+ bb[kr]['termu']+' -  '+bb[kr]['terml']
                x0=max(min(warray),xmin+0.008*(xmax-xmin))
                t=plt.text(x0,y0+dy*1.8,txt,fontsize=7)
                t.set_bbox(dict(facecolor='white', alpha=0.8,linewidth=0))
                y0-=5*dy
                for i in same:
                    done[same]=1
    return
        

####################################################################################################
def strwhere(s, a):
    matches = []
    i = 0
    while i < len(a):
        if s == a[i]:
            matches.append(i)
        i += 1
    return matches

####################################################################################################

def numwhere(a,lst):
    return [i for i, x in enumerate(lst) if x==a ]


####################################################################################################
def tophysics(atom):   # not ready
    # NOT READY
    quit()
    bcc=atom['cbb']
    n=len(cbb)
    for i in range(0,n):
        t=ccb[i]['t']
        o=ccb[i]['o']
        t=np.frombuffer(t)
        o=np.frombuffer(o)
    return

####################################################################################################
def trans(atom): # nominal 
    trn=atom['bb']
    lvl=atom['lvl']
    count=0
    print(trn[0])
    print()
    print('dp.trans: transitions listing')
    print(" index      Lower            Upper            lambda A      f       Aji")
    for l in trn:
        i=l['i']
        j=l['j']
        il=lvl[i]['label']
        jl=lvl[j]['label']
        print( "{0:4d} {1:18s} - {2:18s} {3:9.2f} {4:9.1e} {5:9.1e}".
               format(count,il,jl,l['wl'],l['f'],l['aji']))
        count+=1


####################################################################################################
def uniqlev(lvl,i):
#
#  returns unique string for the level i, and the term to which it belongs
#    

    termstr=str(lvl[i]['orb1']) + str(lvl[i]['orb2']) + str(lvl[i]['orb3']) + str(lvl[i]['term1'])    +str(lvl[i]['term2'])+str(lvl[i]['term3']) + str(lvl[i]['S'])+str(lvl[i]['L'])+str(lvl[i]['P'])    +str(lvl[i]['pqn'])+str(lvl[i]['nactive']) + str(lvl[i]['isos'])

    levstr= termstr+ str(lvl[i]['g'])
    # print(i, termstr)
    return levstr, termstr



####################################################################################################
def zindex(atom):   # beta
    #
    # modifies an atom so that lvl('entry') starts with index of zero
    #
    #
    name=atom['name']
    ########################
    lvl=atom['lvl']
    izero=lvl[0]['entry']
    for l in range(len(lvl)): lvl[l]['entry'] -= izero
    #
    ########################
    bb=atom['bb']
    for l in range(len(bb)):
        bb[l]['j'] -= izero
        bb[l]['i'] -= izero
    #
    ########################
    cbb=atom['cbb']
    for l in range(len(cbb)):
        cbb[l]['j'] -= izero
        cbb[l]['i'] -= izero
    #
    cbf=atom['cbf']
    ok=atom['ok']
    bf=atom['bf']
    atom= {'name':name,'lvl':lvl,'bb':bb,'bf':bf,'cbb':cbb,'cbf':cbf,'ok':ok}
    return atom

####################################################################################################
def nrescape(atom,te,ne,length,vturb):   # alpha
    #
    # solve statistical equilibrium equations for atom dict with te,
    #  ne plasma electron density, length L, turbulent broadening,
    #  all in cgs units
    #  The entire plasma is replaced by a one-point quadrature in
    #  space, and a Newton-Raphson (NR) )scheme is used to converge the 
    #  statistical equilibrium equations.
    #
    #  This merely gives estimates of radiative transport in which
    #  single-flight escape dominates the transport
    #
    #  The plasma can be irradiated by a flux of radiation from
    #  the outside, specified using a user-provided routine 
    #  specified by variable incident (string)
    #  
    # inputs are atom, scalars te, ne, vturb, incident
    #
    # output is a set of number densities and emission coefficients
    #  n, e = nrscape
    #
    np.set_printoptions(precision=1)
    hh=const()['hh']
    cc=const()['cc']
    pi=const()['pi']
    bk=const()['bk']
    em=const()['em']
    esu=const()['eesu']
    uu=const()['uu']
    #
    alpha = pi * esu*esu/em/cc
    ab,mass = abmass(atom['name'])
    lvl=atom['lvl']
    nk=len(lvl)
    e  = dict2array(lvl,'e',float)
    g  = dict2array(lvl,'g',float)
    label = dict2array(lvl,'label',str)
    bb=atom['bb']
    ntrans=len(bb)
    powr= np.zeros(ntrans,dtype=float)

    w=dict2array(bb,'wl',float)  # wavelength of transition
    #
    # optically thin startup
    #
    nstart, nstar, w, eps, lhss = se(atom,te,ne)
    nstart = 10.**(ab-12) * ne  *(nstart/nstart.sum())
    nstar  = 10.**(ab-12) * ne  *(nstar/nstar.sum())
    print('nstart is thin')
    #
    #  LTE startup
    #nstart=nstar
    #
    #print('n start is LTE',nstart)
    #print(nstart)
    n = nstart*1.
    elim=1.e-4
    emax=1
    taumax=0.
    iteration=0
    cbb=atom['cbb']
    nc=len(cbb)
    tl=np.log10(te)
    #
    # Newton-Raphson loop to solve transfer in
    # mean escape probability approximation
    # get line center optical depths
    # set n(new) = n(old)=n + x
    #
    itmax=2
    csave=np.eye(nk)*0. + 1.e-18
    #
    # radiative rates, einstein A coefficients
    # build radiative part of NR lhs
    #
    rte=np.sqrt(te)
    for kc in range(0,nc):
        up=cbb[kc]['j']
        lo=cbb[kc]['i']
        # decode
        temp=np.frombuffer(cbb[kc]['t'])
        omega=np.frombuffer(cbb[kc]['o'])
        spl = CubicSpline(temp, omega, bc_type='natural')
        omega=spl(tl)
        gu=lvl[up]['g']
        csave[up,lo] += 8.63e-06 * ne * (omega/gu) / rte
        csave[lo,up] += csave[up,lo]*nstar[up]/nstar[lo]
    ############################################################
    #
    # add b-f collisioons
    #
    ##
    ##  Main NR iteration loop
    ##
    while emax > elim and iteration < itmax:
        t=csave*1.
        lhs=np.eye(nk,dtype=float)*0.
        rhs=np.zeros(nk,dtype=float)*0.
        type=0  # line transition.
        for kr in range(0,ntrans):
            f=bb[kr]['f']
            wl_ang=bb[kr]['wl']
            w_cm=wl_ang/1.e8
            up=bb[kr]['j']
            lo=bb[kr]['i']
            dopplerw = np.sqrt(bk*te/uu/mass + vturb*vturb)
            dnud = dopplerw/w_cm
            gu=lvl[up]['g']
            gl=lvl[lo]['g']
            typ=bb[kr]['type']
            gf=gl*f
            a,bji,bij=bbcalc(gf,gu,gl,wl_ang,typ)
            dtdn=alpha*length/dnud
            tau = n[lo]*dtdn
            taumax = max(tau, taumax)
            pesc,dpdt= escape(tau,type)
            #
            # add in the n[up]*a*pderiv*[dtaudn*x(lo)]
            #
            #pesc=1
            #dpdt=0.
            t[up,lo] += a *pesc 
            t[lo,lo] += a*dpdt*dtdn
            #
            # radiative powr for output
            #
            powr[kr] =  (n[up] * a * pesc) * (hh*cc/w_cm)/4./pi
        #
        # build lhs and rhs from total  t[i,j]
        #
        for j in range(0,nk):
            sout=(t[j,:]).sum()
            lhs[j,j] += sout
            lhs[:,j] -= t[:,j]
            rhs[j]   = (n * t[:,j]).sum() - n[j] * sout
        #print('r')
        #print(rhs)
        lhs=lhs.T 
        isum=0
        lhs[isum,:]=1.
        rhs[isum]=0.
        # x is the linear correction in the NR scheme
        x = np.linalg.solve(lhs,rhs)
        n +=  x
        emax = np.max(np.abs(x/n))
        #print(' n/nstart',n.sum()/nstart.sum())
        print('iter', iteration,
              'lg emax error ',"{:.2f}".format(np.log10(emax)), 
              'lg tmax       ',"{:.2f}".format(np.log10(taumax)))
        iteration+=1
    #
    return n,powr

####################################################################################################
def escape(tau,type):    # alpha
    if(type == 0):
        # Line
        p=1./(1.+tau)
        dp= -p*p
    else:
        # continuum
        p=np.exp(-tau)
        dp=-p
    return p,dp

####################################################################################################
def synspec(atom,n,powr,resolution):
    bb=atom['bb']
    hh=const()['hh']
    cc=const()['cc']
    pi=const()['pi']
    bk=const()['bk']
    em=const()['em']
    esu=const()['eesu']
    uu=const()['uu']
    rpi=np.sqrt(pi)
    #
    alpha = pi * esu*esu/em/cc
    lvl=atom['lvl']
    nk=len(lvl)
    e  = dict2array(lvl,'e',float)
    g  = dict2array(lvl,'g',float)
    label = dict2array(lvl,'label',str)
    bb=atom['bb']
    ntrans=len(bb)
    wmax=0.
    wmin=3.e3
    wl_ang=np.zeros(ntrans)
    for kr in range(0,ntrans):
        f=bb[kr]['f']
        wl_ang[kr]=bb[kr]['wl']
        if(wl_ang[kr] < wmin): wmin=wl_ang[kr]
        if(wl_ang[kr] > wmax): wmax=wl_ang[kr]
    wmax=min(wmax,3000.)
    wmean=(wmin+wmax)/2.
    wmean=2600.
    dw=wmean/resolution/2/np.sqrt(np.log(2.))
    wave = np.arange(wmin,wmax,dw/2)
    s=wave*0.
    for kr in range(0,ntrans):
        w0=wl_ang[kr]
        x=np.abs(w0-wave)/dw
        ind=(np.abs(x)< 4).nonzero()
        y=x[ind]
        s[ind] += powr[kr]*np.exp(-y*y)/rpi
    return wave,s

####################################################################################################
####################################################################################################
# main 
# set up local variables regime, approx, dbdir
#

dippy_regime=1
dippy_approx=0
dippy_dbdir='/Users/judge/pydiper/dbase/'
os=platform.system()
if(os == 'Linux'):
    print(os)
    dippy_dbdir='/home/judge/pydiper/dbase/'

np.set_printoptions(precision=2)
#
# here are global variables, i.e. with global scope
#
print("DIAGNOSTIC PACKAGE IN PYTHON (dippy)")
print('Global scope variables all are of the kind dippy_XXX                                          ')
print('       where  XXX is, e.g., regime, approx, dbdir')
print()


