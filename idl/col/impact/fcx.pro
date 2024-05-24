;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: fcx.pro
; Created by:    Philip G. Judge, May 31, 1996
;
; Last Modified: Sun Mar 12 12:36:42 2006 by judge (Philip Judge) on niwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
function fcx,kr,x,t,u,zpert,debug=debug
;+
;   fcx(kr,x,t,u,zpert [,/debug])
;
;            computes collision rates between levels ilo and ihi
;            in the impact parameter approximation
;            based upon the function  fcx from peter storey.
;
;-
@cdiper
;
IF(N_PARAMS(0) LT 5) THEN BEGIN
   PRINT,'fcx(kr,x,t,u,zpert [,/debug])'
   RETURN,0
ENDIF

IF(N_ELEMENTS(debug) EQ 0) THEN debug=0
;
; Rydberg for finite mass
;
rydberg = rydinf/(1.0 + em/uu/atom.awgt)
;
ilo=trn(kr).irad
ihi=trn(kr).jrad
zed=FLOAT(lvl(ilo).ion)
;
;
; temp1 is energy difference in Rydbergs
;
temp1 = (lvl(ihi).ev - lvl(ilo).ev)*ee/(rydberg)
;
ryd =  rydberg /hh/cc ; units inverse centimeters
;
; wi is initial energy of perturber in Rydbergs. 
aconst = bk/cc/hh
wi= x*t*aconst/ryd + (temp1+abs(temp1))/2.
wf= wi-temp1
temp1= abs(temp1)

IF(debug NE 0) THEN PRINT,'wi,wf,temp1=',wi,wf,temp1
;
;  pre-amble has now been set up.  we can now use the oscillator strength
;  instead of computing it from the various approximations as in the original
;  code
;
;  from seaton's original paper we see that the oscillator strength and
;  phi(ji) are related such that f(j,i)=deltae/ryd*phi(j,i)  (equation 19)
;  from seaton's paper  table 3 we see that chi corresponds to phi(ji)
;
chi1 = 1.0d0/temp1 * trn(kr).f
IF(debug NE 0) THEN PRINT,'Phi =',chi1
chi3 = chi1
iii=1
;
;  this is the strong coupling part
;
;  bb is (w/deltae)^2 / (2 phi) = 1/beta^2 * zeta(beta) from eqn 33
;

bb=((wi+wf)/temp1)^2/(8.*chi3*u*u*zpert*zpert)

IF(debug NE 0) THEN PRINT,'bb =',bb
;
;  this is a limit of small phi, i.e. high energy, and/or weak transitions
;  bb gt 6 hence beta is << 1 and zeta is about 1.0
;
IF (bb GT 6.0) THEN BEGIN
   beta2 = 1.0/SQRT(bb)         ; beta in IP
   az = alog(1.122900/beta2)    ;
   func = az + 0.2500*beta2*beta2*(1.00 - 2.00*az*az) ; phi(beta) in IP
   stronq = 8.00*chi3*(0.500 + func) ; Q*wi (zeta=1)
   IF(debug NE 0) THEN BEGIN
      PRINT,'beta2 =',beta2
      PRINT,'az    =',az
      PRINT,'func  =',func
      PRINT,'stronq=',stronq
   ENDIF
ENDIF ELSE BEGIN
;
;  bb lt 0.2  hence beta is > 1 and zeta is < 1.  start from beta0
;  bb intermediate-- hence adopt starting approxn for the betas
;
   IF (bb GT 0.2) THEN beta0 = 0.4 ELSE beta0 = -1.05*alog10(bb) + 0.182
   
   FOR i=1,100 DO BEGIN
      ff03a,vi0,vk0,beta0,iii
      ff04a,vi1,vk1,beta0,iii
      sf = vk0*vk0 + vk1*vk1 - bb
      sg = -4.00*vk0*vk1 - 2.00*vk1*vk1/beta0
      beta2   = beta0 - sf/sg
      IF (abs((beta2  -beta0)/beta0) LT 1.e-3) THEN GOTO,beta_conv
      beta0 = beta2
   ENDFOR
   PRINT,'divergence in eqn. (33) occurring'
   RETURN,0
beta_conv:
;
;  have now arrived at self-consistent value of beta-- beta2
;
;  func is phi(beta2), 0.500*beta2**2*(vk0*vk0 + vk1*vk1) is zeta(beta2)
;  hence, stronq is indeed equation (35) (but without factor of wi):
;
   func = beta2  *vk0*vk1
   stronq = 8.00*chi3*(0.500*beta2^2*(vk0*vk0 + vk1*vk1) +func)
;
ENDELSE

stronq = stronq/wi

IF(debug NE 0) THEN PRINT,'Q(i->j)/(!pi*a0*a0) =',stronq
;
; this next expression is the mean of the smaller radii.
; the storey code assumed that this was anu1, but here
; i take the smaller of the two quantum numbers
; original code:
;      b1=0.25*(5.*anu1*anu1+1.)/zed
; new code:
;
small=(lvl(ilo).eff < lvl(ilo).eff)
IF(debug NE 0) THEN PRINT,'small =',  small
b1=0.25*(5.*small*small+1.)/zed
IF(debug NE 0) THEN PRINT,' inner radius = ', b1

IF (atom.atomid EQ 'H') THEN BEGIN
   b01=b1
   IF(ilo+1 EQ 3 AND ihi+1 EQ 4) THEN BEGIN
      b1=10.60
      IF(debug NE 0) THEN PRINT,'changing b1 for 4f-3d from ',b01,' to ', b1
   ENDIF
   IF(ilo+1 EQ 4 AND ihi+1 EQ 5) THEN BEGIN
      b1=16.80
      IF(debug NE 0) THEN PRINT,'changing b1 for 4f-3d from ',b01,' to ', b1
   ENDIF
   IF(ilo+1 EQ 1 AND ihi+1 EQ 2) THEN BEGIN
      b1=2.345
      IF(debug NE 0) THEN PRINT,'changing b1 for 4f-3d from ',b01,' to ', b1
   ENDIF
ENDIF
beta1=SQRT(wi*u)*temp1*b1/(wi+wf)
IF (beta1 LT 0.40) THEN GOTO,label4
iii=1
ff03a,vi0,vk0,beta1,iii
ff04a,vi1,vk1,beta1,iii
func = beta1*vk0*vk1
IF(debug NE 0) THEN BEGIN
   PRINT,'weak beta',wi,wi+wf,temp1,b1,beta1
ENDIF
;
;  beta >> 1 weak coupling approximation
;  use seaton's expansion after table 1 instead of the value of func.
;
IF (beta1 GT 10.) THEN BEGIN
   func1=pi/2.*exp(-2.*beta1)*(1. + 1./4./beta1 - 3./32./beta1/beta1)
   IF(debug NE 0) THEN PRINT,'ratio new/old funcs =',func1/func
   func=func1
ENDIF
;
;  end changes
;
GOTO,label5
label4:
az = alog(1.1229/beta1)
func = az + 0.25*beta1*beta1*(1.0 - 2.0*az*az)
;
;  the weakq approximation and functions appear to be working fine
;
label5:
weakq = func*8.0*chi1/wi
xn = (stronq < weakq)*0.8797182e-16*wi
IF(debug NE 0) THEN BEGIN
   PRINT,' log wi=', alog10(wi*hh*cc*ryd/ee), $
      ' log wf=', alog10(wf*hh*cc*ryd/ee), $
      ' strong, weak=',stronq, weakq
ENDIF
;
;  xn is now the cross-section of collisional excitation from lower
;  to upper levels multiplied by the incident energy in ryd.
;
;  fcx is then sigma(i->j)*1/2mv^2/kt
;

fcxx=ryd*xn/t*u*zpert*zpert/aconst

RETURN,fcxx
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'fcx.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
