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
    nstart[2]*=1.
    nstart = 10.**(ab-12) *ne  *(nstart/nstart.sum())
    nstar = 10.**(ab-12) *ne  *(nstar/nstar.sum())
    #
    #  LTE startup
    #nstart=nstar
    #
    n = nstart+0.
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
    itmax=51
    csave=np.eye(nk)*0.
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
    ##
    ##  Main NR iteration loop
    ##
    while emax > elim and iteration < itmax:
        t=csave*1.
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
            t[up,lo] += a*pesc
            t[lo,up] += a*dpdt*dtdn
            #
            # radiative powr for output
            #
            powr[kr] =  (n[up] * a * pesc) * (hh*cc/w_cm)/4./pi
        #
        # build lhs and rhs from total  t[i,j]
        #
        lhs=np.eye(nk,dtype=float)*0.
        rhs=np.zeros(nk,dtype=float)*0.
        for j in range(0,nk):
            lhs[j,j] += (t[j,:]).sum()
            lhs[:,j] -= t[:,j]
            rhs[j]   -=n[j] * lhs[j,j]
            rhs[j]   +=(n * t[:,j]).sum()
        isum=0
        lhs[isum,:]=1.
        rhs[isum]=0.
        lhs=lhs.T +0.
        lhsold=lhs*1.
        # x is the linear correction in the NR scheme
        x = np.linalg.solve(lhs.T,rhs)
        n +=  x
        emax = np.max(np.abs(x/n))
        print('iter', iteration,
              'lg emax error ',"{:.2f}".format(np.log10(emax)),
              'lg tmax       ',"{:.2f}".format(np.log10(taumax)))
        #print(' ', ' x/n ',x/n)
        #print(' ',  ' n ',n,' ratio ',n.sum()/nstart.sum())
        #print(' n ',n,' , n/n* ',n/nstar)
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
