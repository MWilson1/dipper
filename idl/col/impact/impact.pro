;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: impact.pro
; Created by:    Philip G. Judge, May 31, 1996
;
; Last Modified: Thu Aug 10 13:00:31 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro impact, temp=temp, phimin=phimin, debug = debug
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       impact
;
; PURPOSE:  add or replace existing collisional rate coeffs. by impact values
;       
; EXPLANATION:
;        Replace bound-bound collisional data with impact approx.
;        data, provided phi = 13.6*f(abs)/(ev(hi)-ev(lo)) > phimin.  For
;        allowed transitions only.
;
;        Oscillator strength data in common block catom are used to compute
;        data for col
;   
;        Formalism: Seaton, M.J,. 1962.  Proc. Phys. Soc. 79, 1105.
;        Formalism uses the oscillator strength & quantum
;        numbers.  phimin > 1 is recommended. Seaton (private communication circa 1990)
;        says that he "does not vouch for the impact approximation".  It is
;        included here because, for neutral species, accurate collision cross
;        sections are essentially unavailable and this approximation provides
;        a possibly better alternative to the Van Regemorter approximation.
;
;        Comparisons between impact values and close coupling results from the
;        Belfast group (Berrington et al. 1987) show that sometimes the impact
;        values are within 20% or the detailed computations (themselves of
;        "10%" accuracy), for neutral helium delta-n=0 allowed transitions,
;        but other times it can be off by factors of several...   unpleasant
;        situation. 
;        
;       
; CALLING SEQUENCE: 
;       impact, temp=temp,phimin=phimin, debug=debug
;
; INPUTS:
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       colnew   Output collisional data structure (see gencolrd.pro)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;
;       phimin=phimin default=1. Values of > 0.1 strongly recommended. Default 1.0
;
;       temp=temp  electron temperature grid for Maxwell averaged collision
;                   strengths. 
;
;       /debug  verbose output
;
; CALLS:
;       rimpact
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Calculation of approximate electron-atom collision rate coefficients.
;
; PREVIOUS HISTORY:
;       Written May 31, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, May 31, 1996
;-
;
@cdiper
;
ndata=atom.nline
IF(ndata EQ 0) THEN BEGIN 
   messdip,'IMPACT: no oscillator strengths in common catom, data unchanged',/inf
   return
ENDIF
;
IF(N_ELEMENTS(phimin) EQ 0) THEN phimin=1.
;
;
; Rydberg for finite mass
;
rydberg = rydinf/(1.0 + em/uu/atom.awgt)
;
messdip,'IMPACT: Computing collisional data from Seaton''s IMPACT approx.',/inf
nmax=40 >  N_ELEMENTS(temp)
colnew=coldef
;
IF(N_ELEMENTS(temp) EQ 0) THEN BEGIN
   temp = 3.3+FINDGEN(7)*0.3
   temp=10.^temp
ENDIF
;
;  charge per unit mass of collider- it's an electron.
;
mp=em/uu
mp=mp*uu              ; mass of perturber in cgs
mp=atom.awgt/em*mp/(atom.awgt+mp)    ; reduced mass of system in units of electron mass
;
hi=col.ihi > col.ilo
lo=col.ihi < col.ilo
count = -1
z = 1. ; charge on perturber
;
;charged =  where(lvl.ion NE 1,nc)
;IF(nc NE 0) THEN messdip,'Ion core charge ='+strn(lvl.ion(ilo))+$
;   ': but IMPACT is coded for neutrals',/inf
;
FOR kr=0, atom.nline-1 DO BEGIN
   ihi = trn(kr).jrad
   ilo = trn(kr).irad
   ej = lvl(trn(kr).jrad).ev
   ei = lvl(trn(kr).irad).ev
   IF(ei GT ei) THEN BEGIN 
      ilo = trn(kr).jrad
      ihi = trn(kr).irad
   ENDIF
   iz = lvl(ilo).ion
   phi = rydberg/ee * trn(kr).f /(lvl(ihi).ev-lvl(ilo).ev)
   str=STRING(phi,FORMAT='(e9.2)')
;
   IF(phi GT phimin AND trn(kr).type EQ 'E1' AND iz EQ 1) THEN BEGIN
      count = count+1
      cjip = rimpact(kr,temp,mp,z,debug = debug)
      cji = cjip*lvl(ilo).g/lvl(ihi).g
      omega = cji/(8.63e-6/SQRT(temp)/lvl(ihi).g)
;
; does collisional transition exist?
;
      kk=WHERE(hi EQ ihi AND lo EQ ilo,kount)
;
; no: add an impact approx. calculation
;
      IF(kount EQ 0) THEN BEGIN 
         colnew.key='OHM    :IMPACT, PHI= '+str+', LAMBDA = '+STRTRIM(STRING(trn(kr).alamb),2)
         colnew.ihi=ihi
         colnew.ilo=ilo
         colnew.data=omega
         colnew.temp=temp
         colnew.nt=N_ELEMENTS(temp)
         colnew.approx = 1
         colnew.ref = 'Seaton, M.J.: 1962, Proc. Phys. Soc. 79, 1105. Impact approximation'
         col=[col,colnew]
      ENDIF 
   ENDIF
ENDFOR
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'impact.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
