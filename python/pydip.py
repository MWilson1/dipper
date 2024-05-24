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

####################################################################################################
def const():
    # NAME: 
    #       const 
    # 
    # PURPOSE: Stores atomic and physical constants in pydip dict
    # 
    # EXPLANATION: 
    #       The following variables are set (cgs units throughout): 
    # 
    #       EE               electon charge in V = e^2/r
    #       HH=6.626176D-27  planck's constant 
    #       CC=2.99792458D10 speed of light 
    #       EM=9.109534D-28  electron mass 
    #       UU=1.6605655D-24 hydrogen mass 
    #       BK=1.380662D-16  Boltzmann constant 
    #       PI=3.14159265359 pi 
    #       following combinations are stored 
    #       HCE=HH*CC/EE*1.D8 
    #       HC2=2.*HH*CC *1.D24 
    #       HCK=HH*CC/BK*1.D8 
    #       EK=EE/BK 
    #       HNY4P=HH*CC/QNORM/4./PI*1.D-5 
    #       RYDBERG=2*PI*PI*EM*EE*(EE/HH)*(EE/HH)*(EE/HH)/CC 
    #       ALPHA=2*PI*ee*ee/HH/CC   fine structure constant 
    ee=1.602189e-12
    hh=6.626176e-27
    cc=2.99792458e10
    eesu=ee*cc/1.e8
    es= eesu
    em=9.109534e-28
    bk=1.380662e-16
    pi=3.14159265359e0
    bk=1.380662e-16
    uu=1.6605655e-24

    c = {"ee":ee,"hh":hh,"cc":cc,"em":em,"uu":uu,"bk":bk,"pi":pi,"hce":(hh/ee*cc)*1.e8,"hc2":2.*hh*cc *1.e24,
    "hck":hh*cc/bk*1.e8,"ek":ee/bk,"es": es,"rydinf":2*pi*pi*em*es*(es/hh)*(es/hh)*(es),"alphafs":2*pi*es*es/hh/cc,"eesu": eesu,
    "a0 ": (hh/eesu)*(hh/eesu)/(4*pi*pi)/em,"bohrm":hh*eesu/4/pi/em/cc,"designations": 'SPDFGHIKLMNOQRTU'}
    return c

####################################################################################################
def nla(inla):

    """ takes an integer number encoded as integer nla and decodes it into
    principal QN n, orbital ang mom l, and number of electrons a
    for example 301  is 3s^1 orbital, returns '3S1'
    """
    n = int(inla/100)
    l = int( (inla-n*100)/10)
    a = int(inla-n*100 -l*10)
    sn=str(n)
    sl = const()['designations'][int(l)]
    #print(nla,n,l,a)
    sa=''
    if(a > 0): sa=str(a)
    return sn+sl+sa

####################################################################################################
def slp(islp):
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
def diprd(atom,ions):
    #dir='/Users/judge/pydiper/dbase/'
    dir='../../pydiper/dbase/'
    file='lvlsql.db'
    lvl=lvlrd(dir+file,atom,ions)
    #ok=keyzero(lvl)
    file='bbsql.db'
    bb=bbrd(dir+file,atom,ions)
    #ok=keyzero(bb)
    #
    w=get_array_dict(bb,'wl',float)  # wavelength of transition
    nt=len(bb)
    for kr in range(0,nt):
        f=bb[kr]['f']
        wl_ang=bb[kr]['wl']
        up=bb[kr]['j']
        lo=bb[kr]['i']
        typ=bb[kr]['type']
        #
        # find levels associated with the transition
        #
        entry=get_array_dict(lvl,'entry',int)
        ok=np.asarray(entry == up).nonzero()
        ok=(np.array(ok)).squeeze()
        gu=lvl[ok]['g']
        ok=np.asarray(entry == lo).nonzero()
        ok=(np.array(ok)).squeeze()
        gl=lvl[ok]['g']
        gf=gl*f
        a,bji,bij=bbcalc(gf,gu,gl,wl_ang,typ)
        bb[kr]['aji']=a
    file='cbbsql.db'
    cbb=cbbrd(dir+file,lvl)
    file='bfsql.db'
    print('bf file db is ',file)
    bf=bfrd(dir+file,atom,ions)
    ok=keyzero(bf)
    atom={'lvl':lvl,'bb':bb,'bf':bf,'cbb':cbb}
    atom=zindex(atom)
    return atom

####################################################################################################
def keyzero(dict):
    for key, value in dict[0].items() :
        print (key, value)
    return

####################################################################################################
def zindex(atom):
    lvl=atom['lvl']
    izero=lvl[0]['entry']
    for l in range(0,len(lvl)): lvl[l]['entry'] -= izero
    #
    ########################
    bb=atom['bb']
    for l in range(0,len(bb)):
        bb[l]['j'] -= izero
        bb[l]['i'] -= izero
    ########################

    ########################
    bf=atom['bf']
    #for l in range(0,len(bb)):
    #    bf[l]['j'] -= izero
    #    bf[l]['i'] -= izero
    ########################

    cbb=atom['cbb']
    for l in range(0,len(cbb)):
        cbb[l]['j'] -= izero
        cbb[l]['i'] -= izero
    ########################

    #
    #
    atom= {'lvl':lvl,'bb':bb,'bf':bf,'cbb':cbb}
    return atom


####################################################################################################
def dict_factory(cursor, row):
    fields = [column[0] for column in cursor.description]
    return {key: value for key, value in zip(fields, row)}

####################################################################################################
def lvlrd(file,atom,ions):
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()
    res = cur.execute("SELECT * FROM lvl where atom= "+str(atom)+" and ion="+str(ions))
    lvl=res.fetchall()
    conn.close()
    return lvl
    
####################################################################################################
def bbrd(file,atom,ions):
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()
    res = cur.execute("SELECT * FROM bb where atom= "+str(atom)+" and ion="+str(ions))
    bb=res.fetchall() 
    conn.close()
    return bb
    
####################################################################################################
def cbbrd(file,lvl):
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()

    sb="SELECT * FROM cbb "
    n=len(lvl)
    for i in range(0,n):
        ind=str(lvl[i]['entry'])
        s=" WHERE j= "+  ind + ' OR i= ' + ind
        res = cur.execute(sb +  s)
        if i == 0:
            cbb=res.fetchall()
        if i > 0:
            cbb1=res.fetchall()
            nl=len(cbb1)
            for l in range(0,nl):
                cbb.append(cbb1[l]) 
                
    conn.close()
    return cbb
    
####################################################################################################
def bfrd(file,atom,ions):
    conn=sqlite3.connect(file) 
    conn.row_factory = dict_factory
    cur=conn.cursor()
    res = cur.execute("SELECT * FROM bf where atom= "+str(atom)+" and ion="+str(ions))
    bf=res.fetchall() 
    conn.close()
    return bf

####################################################################################################
def tophysics(atom):
    # NOT READY
    bcc=atom['cbb']
    n=len(cbb)
    for i in range(0,n):
        t=ccb[i]['t']
        o=ccb[i]['o']
        t=np.frombuffer(t)
        o=np.frombuffer(o)

####################################################################################################
def ltepop(e,g,ion,temp,nne):
    #+ 
    # 
    # NAME: 
    #       ltepop 
    # 
    # PURPOSE: 
    #       Calculates LTE populations for the atom 
    #-
    nstar=e*0.; 
    # 
    hh=const()['hh']
    em=const()['em']
    ee=const()['ee']
    cc=const()['cc']
    pi=const()['pi']
    bk=const()['bk']
    rydinf=const()['rydinf']
    #    
    ev=(hh*cc*e)/ee
    xxx = hh/np.sqrt(2.*pi*em/bk)
    ccon=xxx*xxx*xxx/2.
    conl=np.log(ccon*nne)-1.5*np.log(temp) 
    sumn=1.0 
    tns=ev*0.
    glog = np.log(g) 
    # 
    # reduction of ionization potential 
    #  Griem 1964 formula.
    #
    mn = min(ion) 
    mx = max(ion) 
    nk = len(ev)
    for i in range(mn,mx): 
        k = np.where(ion > i) 
        nd = 1140.*i*(temp/1.e4/(nne/1.e10))**0.25 
        ev[k] -= rydinf*i*i/nd/nd/ee 
    tnsl = glog-glog[0]-ee/bk/temp*ev 
    #
    # now compute saha-boltzmann
    #
    for i in range(1,nk): 
        if(ion[i] > ion[0]) : 
            l=ion[i]-ion[0]
            tnsl[i]=tnsl[i]-float(l)*conl 
        tns[i]=np.exp(tnsl[i]) 
        sumn=sumn+tns[i] 
    # 
    #
    totn=1.
    nstar[0]=totn/sumn 
    nstar[1:nk]=tns[1:nk]*nstar[0] 
    return  nstar
        
####################################################################################################
def se(atom,te,ne):
    hh=const()['hh']
    cc=const()['cc']
    pi=const()['pi']
    #
    lvl=atom['lvl']
    nk=len(lvl)
    ion=get_array_dict(lvl,'ion',int)
    e  =get_array_dict(lvl,'e',float)
    g  =get_array_dict(lvl,'g',float)
    label  =get_array_dict(lvl,'label',)
    #
    nstar=ltepop(e,g,ion,te,ne)
    #
    #  build rate matrix and solution vector
    #
    lhs=ratematrix(atom,te,ne,nstar)
    isum=0
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
    w=get_array_dict(bb,'wl',float)/1.e8  # cm
    a=get_array_dict(bb,'aji',float)
    up = np.array(get_array_dict(bb,'j',int))
    lo = np.array(get_array_dict(bb,'i',int))
    eps= hh*cc/w/4/pi * sol[up]*a
    w*=1.e8 # AA
    mx=np.max(eps)
    amx=np.max(a)
    return sol, nstar, w, eps

####################################################################################################
def get_array_dict(dict,key,type=type):
    n=len(dict)
    dict[0]
    out=np.zeros(n,dtype=type)
    for l in range(0,n): out[l] = dict[l][key]
    return out
    
####################################################################################################
def ratematrix(atom,te,ne,nstar):
    hh=const()['hh']
    cc=const()['cc']
    em=const()['em']
    ee=const()['ee']
    pi=const()['pi']
    bk=const()['bk']
    lvl=atom['lvl']
    nl=len(lvl)
    print(nl ,' level atom ')
    lhs=np.eye(nl,dtype=float)*0.
    #
    # radiative rates, einstein A coefficients
    #
    bb=atom['bb']
    w=get_array_dict(bb,'wl',float)  # wavelength of transition
    #
    nt=len(bb)
    print('Radiation...')
    for kr in range(0,nt):
        f=bb[kr]['f']
        wl_ang=bb[kr]['wl']
        up=bb[kr]['j']
        lo=bb[kr]['i']
        typ=bb[kr]['type']
        if(up < nl and lo < nl):
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
    print('Radiation done')
    #
    # collisional rates, bound-bound first 
    #
    print('Collisions...')
    cbb=atom['cbb']
    nt=len(cbb)
    tl=np.log10(te)
    cmn=8.63e-06 * ne * (1.e10) / np.sqrt(te)
    for kc in range(0,nt):
        if(kc !=0 and kc % 1000 ==0): print(kc,'/',nt)
        up=cbb[kc]['j']
        lo=cbb[kc]['i']
        if(up < nl and lo < nl):
            temp=np.frombuffer(cbb[kc]['t'])
            omega=np.frombuffer(cbb[kc]['o'])
            spl = CubicSpline(temp, omega, bc_type='natural')
            omega=spl(tl)
            # linear
            #omega=np.interp(temp,omega,tl)
            #
            gu=lvl[up]['g']
            cdn= 8.63e-06 * ne * (omega/gu) / np.sqrt(te)
            if(cdn < cmn): cmn=cdn  # needed to fill in missing collisions
            lhs[up,lo] +=cdn 
            cup= cdn*nstar[up]/nstar[lo]
            lhs[lo,up] +=cup
    print('Collisions done')
    #
    count=0
    for i in range(0,nl):
        lhs[i,i] = - (lhs[i,:]).sum()
        #
        # fix for zero collision rates
        #
        if(lhs[i,i] == 0.):
            print(' adding collisions for zero-rate level ',i)
            lhs[i,0]=cmn/1.e1
            lhs[0,i]=lhs[i,0]*nstar[i]/nstar[0]
            lhs[i,i] = - (lhs[i,:]).sum()
            count+=1
    #
    if(count > 0): print(count,' levels had zero rates')

    return lhs.T

####################################################################################################
def bbcalc(gf,gu,gl,wl,typ):
    #
    # calculate parameters of transition from gf,g, etc.
    #
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

def redatom(atom):
    # reduce atom size
    lvl=atom['lvl']
    lvl=lvl[0:3]
    bb=atom['bb']
    cbb=atom['cbb']
    atom={'lvl':lvl,'bb':bb,'cbb':cbb}
    nk=len(lvl)
    nbb=len(bb)
    # remove all transitions with i > nk
    keyzero(bb)
    outbb=[bb[0]]
    print('before')
    keyzero(outbb)
    for l in range(1,nbb):
        j=bb[l]['j']
        if(j < nk): outbb.append(bb[l]) 
    print('after')
    keyzero(outbb)
    outcbb=[cbb[0]]
    ncbb=len(cbb)
    for l in range(1,ncbb):
        j=cbb[l]['j']
        if(j < nk): outcbb.append(cbb[l]) 
    #    
    print('atom reduced to ',nk,' levels ',len(outbb),' bb ',len(outcbb),' cbb')
    return {'lvl':lvl,'bb':outbb,'cbb':outcbb}

####################################################################################################

    
