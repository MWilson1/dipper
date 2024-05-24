;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: crat.pro
; Created by:    Philip G. Judge, June 21, 1996
;
; Last Modified: Thu Aug 17 13:05:57 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO crat
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       crat
;
; PURPOSE: computes collisional rates from data stored by gencom and gencolrd
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       crat
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Output is in C(I,J), stored in cse
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;
; CALLS:
;
; COMMON BLOCKS:
;       
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written June 21, 1996 by Phil Judge, HAO/NCAR, Boulder CO
;
; MODIFICATION HISTORY:
;   
; VERSION:
;       Version 1
;-
;
@cdiper
@cse
;
siz=SIZE(col)
if(siz(1) eq 1) then begin
  print,'% crat: No collisional data passed to crat'
  return
endif
;
approx = !approx
bits,approx,bit   
;
;  Re-calculate spline coefficients?
;
ispl = -1
IF(newcol NE 0) THEN BEGIN
   messdip,/inf,'computing new spline coefficients'
   spl = fltarr(siz(1),mcol)
   nspl = lonarr(siz(1))
   idata = nspl
   jspl = nspl
ENDIF
;
; This is where all density dependent keywords need to be added
;
recalc = intarr(N_ELEMENTS(col.key))+1
;
; Define variable c, set initially to zero
;
IF(n_elements(nozeror) EQ 0) THEN nozeror = 0
IF(nozeror EQ 0) THEN c=dblarr(atom.nk,atom.nk)*0.
;
IF(N_ELEMENTS(nstar) EQ 0) THEN ltepop,temp,nne
nhs=SIZE(nh)
;
ZZ=atomn(getwrd(atom.atomid,0))
;
; main loop over keywords
; invariants are here
;
ekt =  ee/bk/temp
roott = SQRT(temp)
t4 = temp/1.e4
;
;
FOR i=0,siz(1)-1 DO BEGIN
   key1 = getwrd(col(i).key)
   if(key1 eq 'TEMP') then goto, next
;
; identify those that have collisional data
; that do not depend on density  
; 
  IF(NOT recalc(i)) THEN GOTO, next
;  key1=strtrim(col(i).key,2)
  key1 = getwrd(col(i).key)
  key4=strmid(key1,0,4)
  hi = col(i).ihi
  lo = col(i).ilo
  ihi1= hi > lo
  ilo1= hi < lo
  nn=col(i).nt-1
  tt=REFORM(col(i).temp(0:nn))
  data=REFORM(col(i).data(0:nn))
  cup = 0.
  cdn = 0.
  delte = lvl(ihi1).ev-lvl(ilo1).ev   ;
  ; some special cases
  ;
  IF(strmid(key1,0,6) EQ 'SPLUPS') THEN key1 = 'SPLUPS'
  IF(key1 EQ 'SHULL82' OR key1 EQ 'LTDR' OR key4 EQ 'AR85' OR key1 EQ 'SPLUPS')$
      THEN GOTO, compute
  if(key1 eq 'CH+') then data = alog10(data)
  ;
  ;  extrapolation, interpolation, storage and use of spline coefficients 
  ; 
  ispl = ispl+1
  IF(newcol) THEN BEGIN
     nspl(ispl) = N_ELEMENTS(tt)
     idata(i) = i
     jspl(i) =  ispl
     IF(nspl(ispl) GT 2)   THEN  spl(ispl,0:nspl(ispl)-1) = nr_spline(tt,data)
  ENDIF
  IF(temp LT MIN(tt)) THEN BEGIN
     data = data(!c)
  ENDIF ELSE IF (temp GT MAX(tt)) THEN BEGIN
     data = data(!c)
  ENDIF ELSE IF (nn+1 EQ 1) THEN BEGIN
     data = data(0)
  ENDIF ELSE IF (nn+1 eq 2) THEN BEGIN
     linterp,tt,data,temp,ddd
     data = ddd
  ENDIF ELSE BEGIN
     iii = jspl(i)
     data=nr_splint(tt,data,spl(iii,0:nspl(iii)-1),temp)
  ENDELSE
  ;
  ;  Special case- logarithmic interpolation used
  ;
  IF(key1 EQ 'CH+') THEN data = 10.^(data)
  ;
  ; Computation of the rates
  ;
  compute:
  case key1 of
    'OHM':  begin
      cdn=8.63e-06*data/lvl(ihi1).g/roott       
      cup  = cdn*nstar(ihi1)/nstar(ilo1)
   end
    'CE': begin
       cdn = data*lvl(ilo1).g*Roott/lvl(ihi1).g
       cup = cdn*nstar(ihi1)/nstar(ilo1)
    end
     'SPLUPS':  BEGIN
        cdn=8.63e-06*ups_bt(temp,data)/lvl(ihi1).g/roott       
        cup  = cdn*nstar(ihi1)/nstar(ilo1)
   end
    'CI': BEGIN
       cup = data*Roott*exp(-delte*ekt)
       cdn = cup*nstar(ilo1)/nstar(ihi1)
    END
    'BURGESS': BEGIN
       cup = burgess(ilo1,ihi1,temp)*data
       cdn = cup*nstar(ilo1)/nstar(ihi1)
    END
    'CP': BEGIN
       IF(nhs(0) GT 0) THEN BEGIN
          cdn=nh(5)*data/nne
          cup  = cdn*nstar(ihi1)/nstar(ilo1)
    ENDIF ELSE BEGIN
          PRINT,'CRAT:  no h populations exist for keyword ',key1
          PRINT,'            setting these collisions to zero'
       ENDELSE
    END
    'CH0': BEGIN           ; Special case: direction matters here
       IF(nhs(0) GT 0) THEN BEGIN
          IF(ihi1 EQ hi) THEN cup=nh(0)*data/nne ELSE cdn=nh(0)*data/nne
       ENDIF ELSE BEGIN
          PRINT,'CRAT:  no h populations exist for keyword ',key1
          PRINT,'            setting these collisions to zero'
       ENDELSE
    END
    'CH+': BEGIN
       IF(nhs(0) GT 0) THEN BEGIN
          IF(ihi1 EQ hi) THEN cup=nh(5)*data/nne ELSE cdn=nh(5)*data/nne
       ENDIF ELSE BEGIN
          PRINT,'CRAT:  no h populations exist for keyword ',key1
          PRINT,'            setting these collisions to zero'
       ENDELSE
    END
    'SHULL82': BEGIN
       data=col(i).data(0:nn)
       acol=data(0) & tcol=data(1) & arad=data(2) & xrad=data(3)
       adi=data(4) & bdi=data(5) & t0=data(6) & t1=data(7)
;  
;  22-Jun-1994 changes begin P.G.Judge ***************************************
;
;  DENSITY SENSITIVE DIELECTRONIC RECOMBINATION
;
;  the term adi may be multiplied by a density-sensitive factor
;  if needed- this is crucial for Li and B-like ions colliding with
;  impacting electrons.
;  This simple formulation was derived from a study of the dependence of
;  the dielectronic "bump" in the figures of Summers 1974 
;  (Appleton Laboratory internal memo), and fitting according to the
;  parameter Ne / z^7
;  This should be accurate to typically +/- 0.1 in log in regions
;  where it matters.  Worse case is e.g. C like Neon where it underestimates
;  density factor by maybe 0.25 in log.
;
      ne_factor = 1.
      IF(adi NE 0. AND bit(3) EQ 0b) THEN BEGIN 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  June 24, 2006 changes begin P.G.Judge 
;  original (pre MAY 2006) code
;         ;  define rho = nne/ z^7 where z is charge on recombining ion
;         rho=10.^(alog10(nne) - 7.* alog10(charge))
;         rho0=2.e3
;         if(isos eq 'LI' or isos eq 'NA' or isos eq 'K') then rho0 = 3.e1      
;         ne_factor = 1./(1. + rho/rho0)^0.14
;         print,'ne_factor',ne_factor
;
; June 24, 2006, more accurate version. 
; get the row and column of the recombined ion's isoelectronic 
; sequence  in the periodic table
; the following parameters mimic the tables 1-19 of
; H. Summers' Appleton Lab Report 367, 1974
; 
         iel = atomn(atom.atomid,/num)
         iz = iel-lvl(ilo1).ion+1  ; isosequence of recombined ion
         rowcol,iz,irow,icol 
         zi = lvl(ilo1).ion   ; charge on recombining ion
         ro=nne/zi/zi/zi/zi/zi/zi/zi
         x = (zi/2. + (icol-1.))*irow/3.0
         beta = -0.2/alog(x+2.71828)
         ro0 = 30.+50.*x
         ne_factor = (1. + ro/ro0)^beta
;  June 24, 2006 changes end P.G.Judge 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      endif
      cdn=arad*(t4)^(-xrad)  +  ne_factor * $
         adi /temp/roott * exp(-t0/temp)* $ 
         (1.e0+bdi * (exp(- t1/temp)))
      cup=0.
;
;  22-Jun-1994 changes end P.G.Judge ****************************************
;
;
;  next statement needed for use of SHULL82 to define 
;  recombination rates but no collisional ionization rates
;
      IF(acol GT 0.) THEN $
         cup=acol * Roott * exp( -tcol / temp) $
         / (1.0 + 0.1 * temp / tcol) 
   END
   
   
   'AR85-RR':BEGIN
      arad=data(0) & xrad=data(1)      
      cdn=arad/(t4)^xrad
      cup = 0.
   END
   'AR85-CDI': BEGIN
      data=col(i).data(0:nn)
      nshell = col(i).nt/5
      cup=0.
      cdn=0.
      FOR ishell=0,nshell - 1 DO BEGIN
         indx=ishell*5
         cdi_ip= col(i).data(indx)
         cdi_a = col(i).data(indx+1)
         cdi_b = col(i).data(indx+2)
         cdi_c = col(i).data(indx+3)
         cdi_d = col(i).data(indx+4)
         x=cdi_ip*ekt
         if(x lt 0) then stop ; pgj 
         fx=exp(-x)*SQRT(x)*(cdi_a + cdi_b*(1.+x)+$
                   (cdi_c-x*(cdi_a+cdi_b*(2.+x)))*fone(x) + cdi_d*x*ftwo(x))
         cup=cup+6.69e-07/cdi_ip/SQRT(cdi_ip)*fx
      ENDFOR
      cdn=cup*nstar(ilo1)/nstar(ihi1)
   END
   'AR85-CEA': BEGIN
      ar85cea,zz,ilo1,temp,cup
         cup=col(i).data(0)*cup  
;
;  this is incorrect since population of upper level is the upper level
;  of the doubly excited state, **, i.e. this should be multiplied by 
;  g(**)/g(ihi1) exp(E(**) - E(ihi1)).  A better approximation would seem to
;  be 0. times this to avoid problems
;  
;       cdn=cup*nstar(ilo1)/nstar(ihi1)
;
      cdn=cup*nstar(ilo1)/nstar(ihi1)*0.
   END
   'AR85-CH': BEGIN
      IF(nhs(0) GT 0) THEN BEGIN
         ; direction matters
         cup=0.
         cdn=0.
         tlo=col(i).data(0) & thi=col(i).data(1)
         IF(temp GT tlo AND temp LT thi) THEN BEGIN
            ar85cha=col(i).data(2)
            ar85chb=col(i).data(3)
            ar85chc=col(i).data(4)
            ar85chd=col(i).data(5)
            data = ar85cha*1.e-9*t4^ar85chb * (1. + ar85chc * exp(ar85chd*t4))
            IF(ihi1 EQ hi) THEN cup=nh(0)*data/nne ELSE cdn=nh(0)*data/nne
         ENDIF
      ENDIF ELSE BEGIN
         PRINT,'CRAT:  no h populations exist for keyword ',key1
         PRINT,'            setting these collisions to zero'
      ENDELSE
   END
   'AR85-CH+': BEGIN
      IF(nhs(0) GT 0) THEN BEGIN   ; direction matters
         cup=0.
         cdn=0.
         tlo=col(i).data(0) & thi=col(i).data(1)
         IF(temp GT tlo AND temp LT thi) THEN BEGIN
            ar85cha=col(i).data(2)
            ar85chb=col(i).data(3)
            ar85chc=col(i).data(4)
            ar85chd=col(i).data(5)
            data = ar85cha * 1.e-9*t4^ar85chb * $ 
               exp(-ar85chc*t4 - ar85chd*ekt)
            IF(ihi1 EQ hi) THEN cup=nh(5)*data/nne ELSE cdn=nh(5)*data/nne
         ENDIF
      ENDIF ELSE BEGIN
         PRINT,'CRAT:  no h populations exist for keyword ',key1
         PRINT,'            setting these collisions to zero'
      ENDELSE
   END
   'AR85-CHE': BEGIN
      cup=0.
      cdn=0.
      IF(nhs(0) GT 0) THEN BEGIN    ; direction matters
         cup=0.
         cdn=0.
         tlo=col(i).data(0) & thi=col(i).data(1)
         IF(temp GT tlo AND temp LT thi) THEN BEGIN
            ar85cha=col(i).data(2)
            ar85chb=col(i).data(3)
            ar85chc=col(i).data(4)
            ar85chd=col(i).data(5)
            data = ar85cha*1.e-9*t4^ar85chb * (1. + ar85chc * exp(ar85chd*t4))
            data=data*nhe(0)/nne
            IF(ihi1 EQ hi) THEN cup=data ELSE cdn=data
         ENDIF
      ENDIF ELSE BEGIN
         PRINT,'CRAT:  no h populations exist for keyword ',key1
         PRINT,'            setting these collisions to zero'
      ENDELSE
   END
   'AR85-CHE+': BEGIN
      IF(nhs(0) GT 0) THEN BEGIN   ; direction matters
         cup=0.
         cdn=0.
         tlo=col(i).data(0) & thi=col(i).data(1)
         IF(temp GT tlo AND temp LT thi) THEN BEGIN
            ar85cha=col(i).data(2)
            ar85chb=col(i).data(3)
            ar85chc=col(i).data(4)
            ar85chd=col(i).data(5)
            data = ar85cha * 1.e-9*t4^ar85chb * exp(-ar85chc*t4-  $
               ar85chd*ekt)
            data=data*nhe(1)/nne
            IF(ihi1 EQ hi) THEN cup=data ELSE cdn=data
         ENDIF
      ENDIF ELSE BEGIN
         cup=0.
         cdn=0.
         PRINT,'CRAT:  no he populations exist for keyword ',key1
         PRINT,'            setting these collisions to zero'
      ENDELSE
   END
   'LTDR': BEGIN
      data=col(i).data(0:nn)
      altdr=data(0) & bltdr=data(1) & cltdr=data(2) & dltdr=data(3)
      fltdr=data(4)
      cdn = 1.e-12* (altdr/t4 + bltdr + $
                         cltdr*t4 +dltdr*t4*t4) * $
         exp(-fltdr/t4)/t4/SQRT(t4)
      cup=0.
   END
   ENDCASE
   c(ihi1,ilo1) = c(ihi1,ilo1) + cdn*nne
   c(ilo1,ihi1) = c(ilo1,ihi1) + cup*nne
; fudge   
   IF(c(ilo1,ihi1) LT 0. OR c(ihi1,ilo1) LT 0.) THEN BEGIN
      messdip,'colls < 0. for '+key1+ strn(ilo1)+' '+strn(ihi1)
   ENDIF
   next:
endfor
newcol = 0 ; procedure has been called and spline coefficients set
;
; final check
;
sumin = total(c,1)
zer = where(sumin EQ 0.,count)
IF(count GT 0) THEN BEGIN 
   print,sumin
   messdip,/inf, 'no collisions into the following levels:'
   FOR j = 0,count-1 DO BEGIN 
      str = string(zer(j))+' '+lvl(zer(j)).label
      messdip,/inf,str
   ENDFOR
   messdip,'I cannot continue- you must add collisional data'
ENDIF
;
RETURN
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'crat.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
