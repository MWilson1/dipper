;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: netrb.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 14, 1994
;
; Last Modified: Mon Aug 14 22:30:05 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO netrb,verbose = verbose
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       netrb
;
; PURPOSE: 
;
;   Gets net radiative brackets of lines using mean escape probability
;   formalism, and escape  probabilties and derivativesof escape probabilities
;   wrt optical  depth,   NRB,PESC,DPESC
;   No derivatives for incident radiation - this is iterated. Should be 
;   improved but then one should do real radiative transfer instead anyway.   
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       netrb 
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       cesc, catom
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; VERSION:
;       March 2, 2006
;-
@cdiper
@cse
IF(N_ELEMENTS(verbose) eq 0) then verbose=0  
IF(N_ELEMENTS(atom.nrad) EQ 0) THEN RETURN ELSE IF (atom.nrad EQ 0) THEN RETURN 
;
;  compute net radiative brackets using escape probs.
;  and update rates in the matrix
;
cm=lvl.ev*ee/hh/cc
tauqold=tauq
jrr=trn.jrad & irr=trn.irad
;
; Line opacity data from Mihalas p. 279:
;
e_esu = ee*cc/1.e8
pie2mc = pi*e_esu*e_esu/em/cc   ; pie2mc = 2.6543068e-02  ; pi e^2 / m c
;
; deltnud is Doppler width in Hz
deltnud = sqrt(vturb^2 + 2.*bk*temp/atom.awgt/uu)*1.e8/trn.alamb
;deltnud = sqrt(vturb^2 + 2.*bk*temp/atom.awgt/uu)*(cm(jrr)-cm(irr))
;print,'vturb deltanud',vturb,deltnud[0]
alph=trn.f*pie2mc/deltnud/sqrt(pi)
;
ttype = 1+intarr(atom.nrad)
IF(atom.nline  NE 0) THEN ttype(0:atom.nline-1) = 0
cont = WHERE(trn.type EQ 'BF', kount)
if(kount gt 0) then alph(cont)=trn(cont).f
;
; fill common block variables  tauq, pesc,  dpesc, nrb
;
tauq=n(irr) * alph * lscale
;if(verbose) then begin 
;   ss=sort(trn.alamb)
;   for ii=0,n_elements(trn)-1 do begin
;      jj=ss(ii)
;      print,trn[jj].alamb,tauq[jj]
;   endfor
;endif
pesc = escprob(tauq,ttype,der = der)
dpesc = der
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; no linearized correction for incident radiation, 
; it is just iterated instead..August 14, 2006
;
;; Add incident radiation on to the NRB
;; lines only so far. 
;;incfact = 1.0+nrb*0.
;;IF(atom.nline GT 0) THEN BEGIN
;;   ir = trn(0:atom.nline-1).irad
;;   jr = trn(0:atom.nline-1).jrad
;;   sl = n(jr)*trn.A/(n(ir)*trn.bij-n(jr)*trn.bji)
;;   incfact(0:atom.nline-1) = 1.-(jinc(0:atom.nline-1)/sl)
;;ENDIF
nrb = pesc ;;*incfact
;
IF(n_elements(verbose) NE 0) THEN BEGIN
   IF(verbose) THEN BEGIN 
      tmax = MAX(abs((tauq -tauqold)/tauqold))
      form='(A,2x,e9.1,A,2x,f7.2,A,2x,e9.1,2x,a)'
      im=!c
      print, 'max(tau) = ',max(tauq), ' at ',trn[!c].alamb,', max dtau=',$
             tmax, ' in transition  '+STRING(im, FORMAT='(I3)'),form=form
   endif
ENDIF
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'netrb.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
