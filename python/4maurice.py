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
    print(nstart)
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
        print('r')
        print(rhs)
        lhs=lhs.T
        isum=0
        lhs[isum,:]=1.
        rhs[isum]=0.
        # x is the linear correction in the NR scheme
        x = np.linalg.solve(lhs,rhs)
        n +=  x
        emax = np.max(np.abs(x/n))
        print(' n/nstart',n.sum()/nstart.sum())
        print('iter', iteration,
              'lg emax error ',"{:.2f}".format(np.log10(emax)),
              'lg tmax       ',"{:.2f}".format(np.log10(taumax)))
        iteration+=1
    #
    return n,powr

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
