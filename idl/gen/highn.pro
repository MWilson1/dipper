;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: highn.pro
; Created by:    judge, July 18, 2006
;
; Last Modified: Sat Aug 26 14:55:14 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO highn
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       highn
;
; PURPOSE: 
;     attempts to plug the dominant effects of missing high-n levels 
;     on level populations.  Necessarily, these treatments are
;     approximate but probably better than neglect. 
;       
; EXPLANATION:
;       Missing levels of high n  can affect level populations of
;       lower n levels of interest.  This procedure attempts to "plug"
;       the gaps using hydrogenic approximations (including 
;       multiply charged ions) by 
;       1.  filling any explicitly included levels without
;           photoionization data with 
;           (!regime=1 only)
;       2.  adding in estimates of bound-bound collision rates to
;           higher n to the highest levels explicitly included, as
;           collisions directly to the continuum states.    
;       3.  including any additional recombination rates needed.
;   
; CALLING SEQUENCE: 
;       highn
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       modifies rate matrix matrix(i,j)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;
; CALLS:
;
; RESTRICTIONS: 
;       
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written October 6, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, October 6, 1995
;-
;
@cdiper
@cse
COMMON highn, regold
;
;
; Radiative recombination components from missing hydrogenic high-n states
;
;  Cowan (1981, eq. (18.99):
;
; alpha_n = 5.2e-14 n eps_n^2 (3kT)^(-3/2) exp(eps_n/kT) E_1(eps_n/kT)
; alpha_n = 5.2e-14 n eps_n^2 (3kT)^(-3/2) F1(eps_n/kT) 
; eps_n = Z_c^2/n^2, kT measured in Rydbergs.
;
; so then if n is such that eps_n/kT <<1, we need a small argument
; approx. Abramowitz+Stegun give 
; E1(x) + ln(x) = sum_i=0^5 a_ix^i
; a=[-.57721566,.9999193,-.24991055,.05519968,-0.00976004,.00107857]
; so for small arguments, could use 
;
;   E1(x) approx - ln(x) -.5771..., exp(x) approx 1, then integral
;   from n0 to infinity is
;
;  sum_n approx int_n0 Z_c^4/n^3 (kT)^(-3/2) (- ln(Z_c^2) + 2ln(n/kT) -.5771) dn
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; first, we must find the ionic ground terms and the 
; bound states connected to them.   
;
approx = !approx
reg = 'no modifications for high n levels'
recx = 0.
IF(n_elements(regold) EQ 0) THEN regold = ''
bits,approx,bit   
IF(!regime eq 2 OR !approx eq 0) THEN return
mn = min(lvl.ion)
mx = max(lvl.ion)
IF(mn EQ mx) THEN return ; no overlying continuum, nothing to be done.
;
omatrix = matrix
n10 = nne/1.e10 &  t4 = temp/1.e4
FOR i = mn,mx-1 DO BEGIN 
   this = where(lvl.ion EQ i)
   that = where(lvl.ion EQ i+1)
   lothat = min(lvl(that).ev) 
   labterm = lvl(that).label
   FOR j = 0,n_elements(that)-1 DO labterm(j) = getwrd(lvl(that).label,-30,-1,/last)
   ithat = where(labterm EQ labterm(0))
   gtthat = total(lvl(that(ithat)).g) ; total g of continuum levels 
   mxn = max(lvl(this).n)
   mnn = min(lvl(this).n)
   imx = where(lvl(this).n EQ mxn)
   gtthis = total(lvl(this(imx)).g) ; total g of levels with n=nmx
   amxn = float(mxn)
   ncol = 8.4*(1./n10/n10*(bk*temp/rydinf)*i^12.)^(1./17.) ;where collisions up dominate
   IF(ncol LT mnn+3) THEN GOTO,skip ; don't do anything if not "high-n"
;
; several cases must be treated   
;
   IF(ncol GT amxn AND !regime NE 0 AND bit(1)) THEN BEGIN 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; max qn is below LTE point- add recomb. data to levels with mxn
; 
      reg = 'Recombinations via missing high-n levels added to rate matrix'
      sum = 0.
      FOR j = mxn,round(ncol) DO BEGIN 
         eps = float(i)*float(i)/float(j)/float(j)
         beta = eps*rydinf/bk/temp
         sum = sum+ j*eps*eps/(3*bk*temp/rydinf)^(1.5)*fone(beta)
      ENDFOR
;
; tot. rec. rate to levels decaying radiatively which are also missing from the atomic model      
;
      rate = 5.4e-14*sum*nne 
      rate = rate(0) ; make a scalar
;
; distribute according to g and add to rate matrix      
;
      FOR j = 0,n_elements(ithat)-1 DO BEGIN 
         matrix(that(ithat(j)),imx) = $
            rate*lvl(this(imx)).g/gtthis + matrix(that(ithat(j)),imx)
         recx = recx+total(rate*lvl(this(imx)).g/gtthis )
      endfor
   ENDIF ELSE IF(ncol LT amxn AND bit(2)) THEN BEGIN 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; mx qn above lte point- add upward collisions 
;
; compute n-> n+1 upward rates.   these are effectively treated as
; ionizations here. 
;
      reg = 'Collisions via missing high-n levels added to rate matrix'
      beta = rydinf/i/i/bk/temp*((2*amxn+1)/amxn/amxn/(amxn+1)/amxn+1) 
      cnnp1 = 2.4e4/i/i*pvr(i,beta)*n10/sqrt(t4)*exp(-beta)$ 
         *amxn^3*(amxn+1.)^5/(2.*amxn+1)^4*nne ; collisions from mxn to mxn+1
      FOR j = 0,n_elements(ithat)-1 DO BEGIN 
         matrix(imx,that(ithat(j))) = cnnp1*lvl(that(ithat(j))).g/gtthat + $
            matrix(imx,that(ithat(j)))
;
;  OK here's the "fudge".           This ensures LTE between next ion
;  and levels with n = amxn, which is what is needed. 
;  
         matrix(that(ithat(j)),imx) = cnnp1*nstar(imx)/nstar(that(ithat(j))) + $
                     matrix(that(ithat(j)),imx)
      ENDFOR
   ENDIF 
   skip:
ENDFOR
; message only when regime of high n states changes
IF(newcol OR regold NE reg) THEN messdip,/inf,'HIGHN: '+reg
regold = reg

return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'highn.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
