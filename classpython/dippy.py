
####################################################################################################
#
# Main subprograms for pydip package
#
####################################################################################################
import sqlite3
import numpy as np
from scipy.interpolate import CubicSpline
from matplotlib import pyplot as plt
from collections import defaultdict
from astropy.io import ascii
import scipy.special as sp
import time
import subprocess
import platform






class dippyClass:

    dippy_dbdir='../dbase/'


    ######
    # 
    #def abmass(name):      # nominal
    # 
    mass_data=[1.0080,4.0026,6.941,9.0122,10.811,12.0111,14.0067,15.9994,18.9984,20.179,
                   22.9898,24.305,26.9815,28.086,30.9738,32.06,35.453,39.948,
                   39.102,40.08,44.956,47.90,50.9414,51.996,54.9380,55.847,58.9332,58.71,
                   63.546,65.37] 

    ab_data=[12,10.93,0.7,1.1,3,8.52,7.96,8.82,4.6,7.92,
                 6.25,7.42,6.39,7.52,5.52,7.20,5.6,6.8,
                 4.95,6.30,3.22,5.13,4.40,5.85,5.40,7.60,5.1,6.30,4.5,4.2] 



    ######
    # 
    #def const():      # nominal
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



    ######
    # 
    #def atomname(x):   # nominal
    # 
    atomnames=['H','HE','LI','BE','B','C','N','O','F','NE',
            'NA','MG','AL','SI','P','S','CL','AR',
            'K','CA','SC','TI','V','CR','MN','FE','CO','NI','CU',
            'ZN','GA','GE','AS','SE','BR','KR','RB','SR','Y','ZR','NB',
            'MO','TC','RU','RH','PD','AG','CD','IN','SN','SB','TE','I',
            'XE','CS','BA','LA','CE','PR','ND','PM','SM','EU','GD','TB','DY',
            'HO','ER','TM','YB','LU','HF','TA','W','RE','OS','IR','PT','AU',
            'HG','TL','PB','BI','PO','AT','RN','FR','RA','AC','TH','PA','U']


    ######
    #
    #def roman(i):
    #
    z = ['','I','II','III','IV','V','VI','VII','VIII','IX'] 
    dec = ['','X','XX','XXX','XL','L','LX','LXX','LXXX','XC'] 
    lab = []
    for j in range(0,len(dec)): 
        for k in range(0,len(z)): 
            lab.append(dec[j]+z[k] )



    dippy_regime = 1
    dippy_approx = 0


    def __init__(self):
        pass




    ####################################################################################################
    def abmass(self, name):      # nominal
        #
        # use: print(abmass('fe'))
        # 
        nm = self.atomnum(name) 
        # 
        if(nm > len(self.mass_data)): 
            print('atomic number=',nm) 
            print('ABMASS: Elements up to Zn (atomic number 30) are only included')
            return None, None
        # 
        return  dippyClass.ab_data[nm-1], dippyClass.mass_data[nm-1] 

    ####################################################################################################
    @staticmethod
    def addon(d,e):    # nominal 
        #
        # append an array of dicts "e" onto d, merely a loop over d.append(e)
        #
        for j in range(0,len(e)): d.append(e[j])
        return d

    ####################################################################################################
    def ar85(self, te,nne):   # alpha (no charge transfer as yet)
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
        atom = self.atom


        ee=dippyClass.ee
        cc=dippyClass.cc
        hh=dippyClass.hh
        bk=dippyClass.bk
        ryd=dippyClass.c['rydinf']/dippyClass.hh/dippyClass.cc
        nstar=self.ltepop(te,nne)
        #
        # level attributes:
        #
        lvl=atom['lvl']
        nl=len(lvl)
        meta=self.dict2array(lvl,'meta',int)  # metastable levels
        nm=len(meta)
        met=[]
        for i in range(0,nm):
            if(meta[i] ==1): met.append(i)
        #
        # now have an array met of metastable level indices
        #
        ion=self.dict2array(lvl,'ion',int)  # ions in lvl
        rate=np.eye(nl)*0.  # output array of ionization and recombination rates
        #
        # cbf ollision attributes:
        #
        cbf=atom['cbf']
        nc=len(cbf)
        catom=self.dict2array(cbf,'atom',int)
        cion=self.dict2array(cbf,'ion',int)
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
        irow,icol = self.rowcol(iz)
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
                    #x=ip*const()['ee']/const()['bk']/te
                    x=ip*dippyClass.ee/dippyClass.bk/te
                    a=cbf[ic]['b']
                    b=cbf[ic]['c']
                    c=cbf[ic]['d']

                    d=cbf[ic]['e']
                    fx=np.exp(-x)*np.sqrt(x)*(a + b*(1.+x) +
                                              (c-x*(a+b*(2.+x)) ) * self.fone(x) + d*x*self.ftwo(x))
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
    @staticmethod
    def atomname(x):   # nominal
        #
        #  use: atomname(6) will yield 'C'

        return dippyClass.atomnames[x-1].capitalize()
        #return name[x-1].capitalize()
   
    ####################################################################################################
    @staticmethod
    def atomnum(x):    # nominal
        #
        # use: atomnm('c') will yield 6

        name = dippyClass.atomnames

        xup=x.upper()
        for i in range(0, len(name)):
            if xup == name[i]: return i+1
        return -1

    ####################################################################################################
    @staticmethod
    def bbcalc(gf,gu,gl,wl,typ):   # alpha
        #
        # use: 
        # calculate Einstein A and B parameters of transition from gf,g, etc.
        #  bbcalcgf,gu,gl,wl,typ) returns  A, Bji, Bij
        c=dippyClass.c
        hh = dippyClass.hh
        cc= dippyClass.cc
        #
        a=0.
        bji=0.
        bij=0.
        #
        #  type is dipole or quadrupole?
        #
        cc=dippyClass.cc
        em=dippyClass.em
        ee=dippyClass.eesu
        pi=dippyClass.pi
        wcm=wl/1.e8
        c=8.* (pi * ee )**2 / (em*cc)   # a=c/lambda^2
        if typ[1:2] == '1' or typ[0:2] == 'IC':
            a=c * (gf/gu) / wcm / wcm
            bji=wcm*wcm*wcm/(hh*cc*cc)
            bij=bji*gu/gl
        if typ[1:1] == 'F':
            print(typ[1:1], ' otherwise forbidden transition- SET TO ZERO')
            a=0.
            bij=0.
            bji=0.
        if typ[1:2] == '2':
            #print(typ[0:2], ' quadrupole transition- SET TO ZERO')
            a=0.
            bij=0.
            bji=0.
        return a, bji, bij

    ####################################################################################################
    def bbdata(self, ionnum):
        #
        #  
        # calculate an index for multiplets, get string variables for
        #   transition labels, jup, jlo.  
        # 
        # Append the new data to the bb array, 
        #
        atom = self.atom


        hh = dippyClass.hh
        cc= dippyClass.cc
        em=dippyClass.em
        ee=dippyClass.eesu
        pi=dippyClass.pi
        ############################################################
        lvl=atom['lvl']
        bb=atom['bb']
        wl=self.dict2array(bb,'wl',float)
        typ=self.dict2array(bb,'type',str)
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
    def bbrd(self, file, ionnum):   # nominal
        #
        # use: returns bb dict object from file for atom=6, ion=2 say (C II)
        #  bb dict contains data for bound-bound radiative transitions
        #
        conn=sqlite3.connect(file) 
        conn.row_factory = self.dict_factory
        cur=conn.cursor()
        res = cur.execute("SELECT * FROM bb where atom= "+str(self.atomN)+" and ion="+str(ionnum))
        #print('read bb transitions...')
        bb=res.fetchall() 
        #print('read bb transitions...done')
        conn.close()
        return bb
    
    ####################################################################################################
    def bfrd(self, file, ionnum):    # nominal
        #
        # use: returns bf dict object from file for atom=6, ion=2 say (C II)
        #  bf dict contains data for bound-free radiative transitions (photoionization)
        #
        #
        conn=sqlite3.connect(file) 
        conn.row_factory = self.dict_factory
        cur=conn.cursor()
        res = cur.execute("SELECT * FROM bf where atom= "+str(self.atomN)+" and ion="+str(ionnum))
        #print('read bf transitions...')
        bf=res.fetchall() 
        #print('read bf transitions... done')
        conn.close()
        return bf#


    ####################################################################################################
    @staticmethod
    def cea(iel,ionnum,te):
        #
        #  Include excitation-autoionization according to AR85
        #
        # identify the isoelectronic sequence of the impacted ion
        #
        ee=dippyClass.ee
        cc=dippyClass.cc
        hh=dippyClass.hh
        bk=dippyClass.bk
        ryd=dippyClass.rydinf/hh/cc
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
                fy=self.fone(y)
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
                cea=6.69e+7*a*iea/np.sqrt(bk*te/ee)*np.exp(-y)*(1.-y*self.fone(y))
            if(isoel == 11 and z >16):  # Sodium
                iea=11.*(z-10)**1.5
                a=1.e-14/(z-10.)**3.73
                y=iea*ee/bk/te
                cea=6.69e+7*a*iea/np.sqrt(bk*te/ee)*np.exp(-y)*(1.-0.5*(y-y*y)+y*y*y*self.fone(y))
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
    def cbbrd(self, file,lvl):    #   alpha 
        #
        # use: returns cbb dict object from file for atom=6, ion=2 say (C II)
        #  cbb dict contains data for bound-bound thermal collision rates 
        #
        t0=time.time()
        conn=sqlite3.connect(file) 
        conn.row_factory = self.dict_factory
        cur=conn.cursor()
        sb="SELECT * FROM cbb "
        n=len(lvl)

        minl=lvl[0]['entry']
        maxl=lvl[-1]['entry']
        #
        atom = int(lvl[0]['atom'])
        ion = int(lvl[0]['ion'])
        ions=self.dict2array(lvl,'ion',int)  # ions in lvl
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
            nx=len(x)
            count=0
            for jj in range(nx):
                if(x[jj]['i'] != x[jj]['j'] and
                   x[jj]['i'] >=  minl    and 
                   x[jj]['j'] <=  maxl ):cbb.append(x[jj])
                else:
                    count+=1
            #if(count > 0): print('WARNING cbb ',count, ' coefficients are outside range ',minl,maxl)
        conn.close()
        #print(time.time() - t0,' seconds to read bound-bound collisional data for ',n,' levels')
        #print(int(1000.*(time.time() - t0)/n),' milli-seconds to read one ')
        return cbb
    
    ####################################################################################################
    def cbfrd(self, dir,lvl):    # alpha
        #
        # use: returns cbfut dict object from file for atom=6, ion=2 say (C II)
        #  cbf dict contains data for bound-free thermal ionization collision rates 
        #  coefficients are given as listed by Arnaud+Rothenflug 1985, Arnaud+Raymond(?)
        #
        if(self.dippy_regime == 'lte'):
            print('cbfrd: regime is lte, return None')
            quit()
        n=len(lvl)
        atom = int(lvl[0]['atom'])
        ion = int(lvl[0]['ion'])
        ions=self.dict2array(lvl,'ion',int)  # ions in lvl
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
    @staticmethod
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
    @staticmethod
    def dict_factory(cursor, row):  # nominal
        fields = [column[0] for column in cursor.description]
        return {key: value for key, value in zip(fields, row)}

    ####################################################################################################
    @staticmethod
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
    def diplist(self, aname):
        print()
        print('Atom  Ion     NL    NBB    NBF   NCBB')
        iel = self.atomnum(aname)
        for ion in range(1,iel):
            atom=diprd(iel,ion,True).atom
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
    @staticmethod
    def fone(x):   
        #
        # function needed for AR85 rate coefficients
        # 
        return np.exp(x)*sp.exp1(x)

    ####################################################################################################
    @staticmethod
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
    def ipotl(self, ionnum):     # nominal, limited to Atomic numbers  < 29
        #
        # returns ionization potential, e.g. for H I use ipotl(1,1) (atomic number, spectrum number)
        #
        atomN = self.atomN
        ion = ionnum
        
        ip=np.nan
        if(atomN < 28): ip=self.iprd()[atomN,ion]
        return ip

    ####################################################################################################
    @staticmethod
    def iprd():   # nominal 
        # reads in array of ionization potentials.  returns None when there is no data
        text = open(dippyClass.dippy_dbdir + 'mooreip.dat')
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
    @staticmethod
    def keyzero(dict):   # nominal, just print out first key value pairs in a dict array
        for key, value in dict[0].items() :
            print (key, value)
        return

    ####################################################################################################
    def level(atom): # test
        lvl=atom['lvl']
        count=0
        print(lvl[0])
        print(" index         E cm-1            Label             g     Lifetime s")
        for l in lvl:

            print( "{0:4d} {1:16.3f}  {2:24s}  {3:5.1f}  {4:9.1e} ".
                   format(count,l['e'],l['label'],l['g'],l['lifetime'] ))
            #print("%10.3E" % (356.08977))   # print exponential value
            count+=1

    ####################################################################################################
    def ltepop(self, te,nne):
        #
        # Compute LTE populations for atom at electron temperature te
        # and electron density ne (cm/3)
        #
        atom = self.atom


        ee=dippyClass.ee
        em=dippyClass.em
        cc=dippyClass.cc
        hh=dippyClass.hh
        bk=dippyClass.bk
        pi=dippyClass.pi
        rydinf=dippyClass.c['rydinf']/hh/cc
        #
        lvl=atom['lvl']
        nk=len(lvl)
        nstar=np.zeros(nk)
        glog = np.log(self.dict2array(lvl,'g',float))
        #print(lvl)
        #print('GLOG',glog)
        e = self.dict2array(lvl,'e',float)
        ion = self.dict2array(lvl,'ion',int)
        #
        totn=1.
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
    #    print(' Ev ',ev)
    #    mn = np.min(ion)
    #    mx = np.max(ion)
    #    for i in range(mn,mx):
    #        for l in range(nk):
    #            if(ion[l] > i):
    #                nd = 1140.*i*(te/1.e4/(nne/1.e10))**0.25
    #                ev[l] = ev[l] - rydinf*i*i/nd/nd/ee
        #
        # LTE loop:
        #
        tnsl = glog-glog[0]- ee*ev/bk/te
        for k in range(1,nk):
            delta=ion[k] - ion[0]
            if(delta > 0): tnsl[k]-= delta * conl
            tns[k]=np.exp( tnsl[k] )
            sumn+= tns[k]
        #
        nstar[0]=totn/sumn
        for i in range(1,nk):
            nstar[i]=nstar[0]*tns[i]
        #print(nstar)
        return nstar

    ####################################################################################################
    def ltime(self):
        #
        # returns lifetime of each level in atom and stores in lvl[i]['lifetime']
        # and lvl is itself stored in atom
        #
        atom = self.atom


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

        self.atom = atom
        return atom
               
    ####################################################################################################
    def lvlrd(self, file, ionnum):   # beta, check addition of next ion stage
        #
        # read energy levels from database file and return in dict lvl
        #
        atomN = self.atomN
        #ions = self.ionnum
        ions = ionnum
        boundonly = self.boundonly

        
        if(boundonly ==None):boundonly=False
        conn=sqlite3.connect(file) 
        conn.row_factory = self.dict_factory
        cur=conn.cursor()
        res = cur.execute("SELECT * FROM lvl where atom= "+str(atomN)+" and ion="+str(ions))
        lvl=res.fetchall()
        if boundonly == False:
            sstr="SELECT * FROM lvl where atom= "+str(atomN)+" and ion="+str(ions+1)
            res = cur.execute(sstr)
            lvlnext=res.fetchone()
            if(lvlnext != None):
                ipot=self.ipotl(ionnum)
                lvlnext['e']+= ipot * dippyClass.ee / dippyClass.hh / dippyClass.cc
                lvlnext['meta']=1
                lvl.append(lvlnext) 
        conn.close()
        nl=len(lvl)
        if nl == 0:
            return lvl
        #print('lvlrd ',np.shape(lvl), ' atomn ions ',atomn,ions)
            
        lvl=self.qn(lvl)  # get quantum numbers
        return lvl


    #
    #
    def matchcol(self ,ilab,jlab):

        atom = self.atom


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
                lab,term =self.uniqlev(lvl,il)
                if(lab == ilab): llo=il
                if(lab == jlab): lup=il
            for kc in range(0,nc):
                up=cbb[kc]['j']
                lo=cbb[kc]['i']
                if(up == lup and lo == llo):
                    temp=np.frombuffer(cbb[kc]['t'])
                    omega=np.frombuffer(cbb[kc]['o'])
                    spl = CubicSpline(temp, omega, bc_type='natural')
                    o=spl(tl)
            return tl, o

#

    ######################################################################
    def matchf(self, ilab,jlab):

        atom = self.atom


        if(atom['ok'] == True):
            #print(atom.keys())
            lvl=atom['lvl']
            bb=atom['bb']
            nf=len(bb)
            o=np.nan
            lup=0
            llo=0
            for il in range(0,len(lvl)):
                lab,termlab=self.uniqlev(lvl,il)
                if(lab == ilab): llo=il
                if(lab == jlab): lup=il
            for kf in range(0,nf):
                up=bb[kf]['j']
                lo=bb[kf]['i']
                if(up == lup and lo == llo):
                    o=bb[kf]['f']
            return o


    ####################################################################################################
    @staticmethod
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
        sl = dippyClass.c['designations'][int(l)]
        #print(nla,n,l,a)
        sa=''
        if(a > 0): sa=str(a)
        return n,l,a, sn+sl+sa

    ####################################################################################################
    @staticmethod
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


    ####################################################################################################
    @staticmethod
    def planck(wm,t):  # beta
        cc=dippyClass.cc
        hh=dippyClass.hh
        bk=dippyClass.bk
        pi=dippyClass.pi
        nu=cc/wm
        return  (2.*(hh*nu)*(nu/cc)*(nu/cc)) / (np.exp(hh*nu/bk/t) -1.)

    ####################################################################################################
    def qn(self, lvl):  # beta
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
            S,L,P,string = self.slp(lvl[ij]['term1'])
            config0=lvl[ij]['label'].rsplit(' ', 2)[0]
            n,nactive=self.outerqn(config0)
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
                    #print('level ',ik,' with label ', configi,' ',lvl[ik]['label'], ' is metastable')
                #
                # define S L and P in all levels
                #
                # is there a space in the config? If so, edit it further
                # 
                yes= ' ' in configi
                if ' ' in configi: lastwd = (configi.split(' ',1))[1]
                #
                S,L,P,string = self.slp(lvl[ik]['term1'])
                #
                # find numbers in front of a non-numeric string
                #
                n,nactive=self.outerqn(configi)
                lvl[ik]['pqn']= n  # all up to but excluding the ang mom
                lvl[ik]['nactive']= nactive  # all up to but excluding the ang mom
                lvl[ik]['config']=configi
                lvl[ik]['meta']=meta[ik]
                lvl[ik]['S']=int(S)
                lvl[ik]['L']=int(L)
                lvl[ik]['P']=int(P)
            #if(count > 2): quit()
        #
        #for i in range(0,nl):
        #    if(lvl[i]['meta']==1): print('metastable ',i,lvl[i]['label'])

        return lvl

    ####################################################################################################
    def ratematrix(self, te,ne,nstar):   # beta
        #
        # get full (singular) rate matrix for atomic model in the atom dict,
        #
        # inputs are scalars te, ne, and array nstar of lte populations
        # output is a the rate matrix with dimensions sec^-1 (probability per unit time)
        #
        atom = self.atom


        hh=dippyClass.hh
        cc=dippyClass.cc
        em=dippyClass.em
        ee=dippyClass.ee
        pi=dippyClass.pi
        bk=dippyClass.bk

        lvl=atom['lvl']
        nl=len(lvl)
        lhs=np.eye(nl,dtype=float)*0.
        #
        # radiative rates, einstein A coefficients
        #
        bb=atom['bb']
        w=self.dict2array(bb,'wl',float)  # wavelength of transition
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
                a,bji,bij=self.bbcalc(gf,gu,gl,wl_ang,typ)
                lhs[up,lo] +=a
                lhs[lo,up]+=0.  # no incident radiation
                if(a < 0.): print('a ',a)
        #
        # collisional rates, bound-bound first 
        #
        cbb=atom['cbb']
        nt=len(cbb)
        tl=np.log10(te)
        cmn=8.63e-06 * ne * (1.e10) / np.sqrt(te)
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
                if(cdn < cmn): cmn=cdn  # needed to fill in missing collisions
                lhs[up,lo] +=cdn 
                cup= cdn*nstar[up]/nstar[lo]
                #cup= cdn*np.exp(-hh*cc*(lvl[up]['e']-lvl[lo]['e'])/bk/te)
                #print(up,lo,omega,cdn)
                lhs[lo,up] +=cup
        #
        c=self.ar85(te,ne)
        lhs+=c
        count=0
        for i in range(0,nl):
            lhs[i,i]=0.
            lhs[i,i] = - (lhs[i,:]).sum()
            #
            # fix for zero collision rates
            #
            if(lhs[i,i] == 0.):
                #print(' adding collisions for zero-rate level ',i,lvl[i]['label'],'    ',lvl[i]['ion'],lvl[i]['meta'])
                lhs[i,0]=cmn/1.e6
                lhs[0,i]=lhs[i,0]*nstar[i]/nstar[0]
                count+=1
                lhs[i,i] = - (lhs[i,:]).sum()
        #
        if(count > 0): print(count,' levels had zero rates')
        return lhs.T

    ####################################################################################################    
    def redatom(self, *args, **kwargs):   # alpha 
        # 
        # reduce atom size, according to keywords
        # examples:
        # atom = redatom(atom,lowestn=True):  keep all levels with principal QN = lowest in ion
        # atom = redatom(atom,lowestplus=True):   "             " <= lowest in ion + 1
        # atom = redatom(atom,meta=True):  keep all metastable levels only 
        #
        atom = self.atom



        name=atom['name']
        np.set_printoptions(precision=2)
        #
        lvl=atom['lvl']
        nl=len(lvl)
        inlabl=[]
        for i in range(0,len(lvl)):
            inlabl.append(lvl[i]['label'])
        #
        bb=atom['bb']
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
            ions=self.dict2array(lvl,'ion',int)  # ions in lvl
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
            ions=self.dict2array(lvl,'ion',int)  # ions in lvl
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
        atom=self.ltime()
        atom={'name':name, 'lvl':outlvl,'bb':outbb,'cbb':outcbb,'cbf':cbf}
        #
        print('atom reduced to ',len(outlvl),' levels ',len(outbb),' bb ',len(outcbb),' cbb')
        print('--------------------------------------------------------------------------------')
        self.atom = atom
        return atom

    ####################################################################################################
    def regime(self):   # nominal
        #
        # returns the string name of the regime from the global variable dippy_regime
        # 
        r=['coronal','nlte','lte']
        return r[self.dippy_regime] # global variable

    ####################################################################################################
    @staticmethod
    def roman(i):
        #
        # return roman equivalent of arabic numeral up to 99
        #

        #
        return dippyClass.lab[i] 

    ####################################################################################################
    @staticmethod
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
    def se(self, te,ne):   # beta
        #
        # solve statistical equilibrium equations for atom dict with te, ne plasma t and density
        #
        atom = self.atom

        hh=dippyClass.hh
        cc=dippyClass.cc
        pi=dippyClass.pi
        bk=dippyClass.bk
        #

        lvl=atom['lvl']
        nk=len(lvl)
        ion=self.dict2array(lvl,'ion',int)
        e  =self.dict2array(lvl,'e',float)
        g  =self.dict2array(lvl,'g',float)
        label  =self.dict2array(lvl,'label',str)
        #
        nstar=self.ltepop(te,ne)
        #
        #  build rate matrix and solution vector
        #
        lhs=self.ratematrix(te,ne,nstar)


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
        w=self.dict2array(bb,'wl',float)/1.e8  # cm
        a=self.dict2array(bb,'aji',float)
        up = np.array(self.dict2array(bb,'j',int))
        lo = np.array(self.dict2array(bb,'i',int))

        eps= hh*cc/w/4/pi * sol[up]*a
        w*=1.e8 # AA
        mx=np.max(eps)
        amx=np.max(a)
        return sol, nstar, w, eps, lhs

    ####################################################################################################
    @staticmethod
    def slp(islp):    # alpha
        #
        # return encoding for term so 311 --> 3,1,1,'3Po'
        #
        ispin = int(islp/100 )
        ill =int( (islp-ispin*100)/10 )
        ipar = int(islp-ispin*100 -ill*10) 
        # 
        strl = dippyClass.c['designations'][ill]
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
    def specid(self):
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
        atom = self.atom


        name=atom['name']
        bb=atom['bb']
        print('specid ', bb[100])
        lvl=atom['lvl']
        mindex=self.dict2array(bb,'mindex',int)
        uindex=np.unique(mindex)
        #
        # parameters for plotting ids
        #
        xmin,xmax,ymin,ymax=plt.axis()
        #
        # length of down ticks
        dy=(ymax-ymin)/90.
        # starting height for labels
        y0=ymin+0.93*(ymax-ymin)
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
                txt=atom['name'] + ' '+ self.roman(ion) + ' '+ bb[kr]['termu']+' -  '+bb[kr]['terml']

                for s in same:
                    warray.append(self.convl(bb[s]['wl']))
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
    @staticmethod
    def strwhere(s, a):
        matches = []
        i = 0
        while i < len(a):
            if s == a[i]:
                matches.append(i)
            i += 1
        return matches

    ####################################################################################################
    @staticmethod
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
    def trans(atom): # test
        trn=atom['bb']
        lvl=atom['lvl']
        count=0
        print(trn[0])
        print(" index      Lower            Upper            lambda A      f       Aji")
        for l in trn:
            i=l['i']
            j=l['j']
            il=lvl[i]['label']
            jl=lvl[j]['label']
            print( "{0:4d} {1:20s} -- {2:20s} {3:16.3f} {4:9.1e} {5:9.1e}".
                   format(count,il,jl,l['wl'],l['f'],l['aji']))
            count+=1


    ####################################################################################################
    @staticmethod
    def uniqlev(lvl,i):
    #
    #  returns unique string for the level i, and the term to which it belongs
    #    

        termstr=str(lvl[i]['orb1']) + str(lvl[i]['orb2']) + str(lvl[i]['orb3']) + str(lvl[i]['term1'])    +str(lvl[i]['term2'])+str(lvl[i]['term3']) + str(lvl[i]['S'])+str(lvl[i]['L'])+str(lvl[i]['P'])    +str(lvl[i]['pqn'])+str(lvl[i]['nactive']) + str(lvl[i]['isos'])

        levstr= termstr+ str(lvl[i]['g'])
        # print(i, termstr)
        return levstr, termstr



    ####################################################################################################
    def zindex(self):   # beta
        #
        # modifies an atom so that lvl('entry') starts with index of zero
        #
        atom = self.atom

        
        reg=self.regime()
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
        ########################
        #if(reg != 'coronal'):
        #    bf=atom['bf']
        #    #print('BF IS NONE !! regime is coronal')
        #    bf=None
        #
        cbf=atom['cbf']
        ok=atom['ok']
        if(reg == 'coronal'): atom= {'name':name,'lvl':lvl,'bb':bb,'cbb':cbb,'cbf':cbf, 'ok':ok}
        if(reg == 'lte'):
            bf=atom['bf']
            atom= {'name':name,'lvl':lvl,'bb':bb,'bf':bf,'ok':ok}
        if(reg == 'nlte'):
            bf=atom['bf']
            atom= {'name':name,'lvl':lvl,'bb':bb,'bf':bf,'cbb':cbb,'cbf':cbf,'ok':ok}
        self.atom = atom
        return atom




####################################################################################################
class diprd(dippyClass):

    def __init__(self, atomN,ionnum, boundonly=None, dippy_regime=1, dippy_approx=0):
        # reads atom dict from the sql database 
        # atom= diprd(6,2) returns atom dict for C II ion
        # atom={'name','lvl','bb','bf','cbb','cbf','ok']  - general case.
        #
        #  output depends on dippy_regime global
        #

        self.atomN = atomN
        self.boundonly = boundonly
        self.dippy_regime = dippy_regime
        self.dippy_approx = dippy_approx

        ok=True
        ion=ionnum
        if(boundonly ==None):boundonly=False
        reg=self.regime()
        name=self.atomname(atomN)
        dir=dippyClass.dippy_dbdir
        file='lvlsql.db'
        lvl=self.lvlrd(dir+file,ionnum)
        nl=len(lvl)
        if(nl == 0):
            #print('WARNING No atomic levels found ', atomname(atom))
            atom={'name':name,'ok':False}
            self.atom = atom
            #return atom
            return
    #
        ipot=self.ipotl(ion)
        file='bbsql.db'
        bb=self.bbrd(dir+file,ion)
        #
        w=self.dict2array(bb,'wl',float)  # wavelength of transition
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
            entry=self.dict2array(lvl,'entry',int)
            okay=np.asarray(entry == up).nonzero()
            okay=np.array(okay).squeeze()
            gu=lvl[okay]['g']
            #print('okay gu ', gu, type(gu))
            okay=np.asarray(entry == lo).nonzero()
            okay=(np.array(okay)).squeeze()
            gl=lvl[okay]['g']
            gf=gl*f
            a,bji,bij=self.bbcalc(gf,gu,gl,wl_ang,typ)
            bb[kr]['aji']=a
            #
        cbf=self.cbfrd(dir,lvl)
        #
        #  various regimes, to build full atom
        #
        if(reg == 'lte'):  # only levels and radiative data
            file='bfsql.db'
            bf=self.bfrd(dir+file,ion)
            atom= {'name':name,'lvl':lvl,'bb':bb,'bf':bf, 'ok':ok}
        if(reg == 'coronal'):   # no b-f transitions, use recombination coefficients
            file='cbbsql.db'
            cbb=self.cbbrd(dir+file,lvl)
            atom= {'name':name,'lvl':lvl,'bb':bb,'cbb':cbb,'cbf':cbf, 'ok':ok}
        if(reg == 'nlte'):   # read all data
            file='bfsql.db'
            bf=self.bfrd(dir+file,ion)
            file='cbbsql.db'
            cbb=self.cbbrd(dir+file,lvl)
            atom= {'name':name, 'lvl':lvl,  'bb':bb,'bf':bf,  'cbb':cbb,  'cbf':cbf, 'ok':ok}
        #
        self.atom = atom

        atom=self.zindex()
        atom=self.ltime()

        self.atom = atom
        #return atom



####################################################################################################
class diprd_multi(dippyClass):    # alpha

    def __init__(self, atomN,ions, boundonly=True, dippy_regime=1, dippy_approx=0):
        #
        #  read in  ions, such as diprd(6,[1,2,3,4]) which will read energy levels for
        #    element 6 (Carbon) for ionization stages I, II, III, IV PLUS the ground state
        #    of C V.
        #
        # is atomnum and ions sensible?
        #
        self.atomN = atomN
        self.boundonly = boundonly
        self.dippy_regime = dippy_regime
        self.dippy_approx = dippy_approx


        mn=min(ions)
        mx=max(ions)
        if(mn < 0 or mx > atomN):
            print('diprd_multi: ions out of range ',ions, ' for ', atomN, ' -- quit()')
            quit()
        dir=dippyClass.dippy_dbdir
        reg=self.regime()
        boundonly=True
        #
        #  get the first atom with only bound states to append later
        #
        atom0=diprd(atomN,ions[0],boundonly).atom
        name=atom0['name']
        lvl=atom0['lvl']
        bb=atom0['bb']
        ipot=self.ipotl(ions[0])
        print('First ion has ',len(lvl), 'levels and IP of ',ipot,' eV')
        if(reg  == 'coronal'):
            cbb=atom0['cbb']
            cbf=atom0['cbf']
        if(reg == 'lte'):
            bf=atom0['bf']   
        if(reg == 'nlte'):
            bf=atom0['bf']   
            cbb=atom0['cbb']
            cbf=atom0['cbf']
        # temporarily disable bf (photo-ionization)
        print('BF cases to be included later')
        bf=None
        #
        # loop over ions to be read
        #
        for ion in ions[1:]:
            lzero=len(lvl)  # needed to re-index bb and cbb only.
            atomq=diprd(atomN,ion,boundonly).atom
            ipot=self.ipotl(ion)
            lvlq=atomq['lvl']
            print('Next  ion has ',len(lvlq), 'levels and IP of ',ipot,' eV')
            for j in range(0,len(lvlq)):
                lvlq[j]['e'] += ipot * dippyClass.ee / dippyClass.hh / dippyClass.cc
                #print('MULRD ',lvl[j]['lifetime'])
            lvl=self.addon(lvl,lvlq)
            lvl=self.qn(lvl)  # get quantum numbers
            #
            # Now fix indices on bb and cbb arrays
            #
            #print('LEN MULTI ',len(lvl))
            bbq=atomq['bb']
            #
            for j in range(0,len(bbq)):
                bbq[j]['j'] += lzero
                bbq[j]['i'] += lzero
            bb=self.addon(bb,bbq)
            #
            if(reg == 'lte'):
                bf=None
                print('BF IS NONE regime lte')
                atom={'name':name,'lvl':lvl,'bb':bb,'bf':bf}
            else:
                bfq=None
                cbbq=atomq['cbb']
                #
                for j in range(0,len(cbbq)):
                    cbbq[j]['j'] += lzero
                    cbbq[j]['i'] += lzero
                cbb=self.addon(cbb,cbbq)
                bfq=None
                cbfq=atomq['cbf']
                cbf=self.addon(cbf,cbfq)
                atom={'name':name,'lvl':lvl,'bb':bb,'bf':bf,'cbb':cbb,'cbf':cbf}
            #

        self.atom = atom
        #return atom





if __name__ == '__main__':
    ####################################################################################################
    # main 
    # set up local variables regime, approx, dbdir
    #

    #dippy_regime=1
    #dippy_approx=0
    #dippy_dbdir='/Users/judge/pydiper/dbase/'
    #os=platform.system()
    #if(os == 'Linux'):
    #    print(os)
    #    dippy_dbdir='/home/judge/pydiper/dbase/'
    #np.set_printoptions(precision=2)
    #
    # here are global variables, i.e. with global scope
    #
    print("DIAGNOSTIC PACKAGE IN PYTHON (dippy)")
    print('Global scope variables all are of the kind dippy_XXX                                          ')
    print('       where  XXX is, e.g., regime, approx, dbdir')
    print()


