;
;**************************************************************************
;
PRO estart, istart, verbose=verbose
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       estart
;
; PURPOSE: 
;       provides a starting approximation for calculations of number densities
;       in escape probability program, and computes fixed collision rates
;       LTE populations, H populations
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       estart, istart, verbose=verbose
;
; INPUTS:
;       istart determines the starting approximation:
;       istart=-1 then use previous solution
;       istart= 0 optically thin (all net radiative brackets=1)   
;       istart= 1 then use LTE
;       istart= 2 then choose between LTE and optically thin, automatically
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
;
; CALLS:
;       ltepop, hpop, gencrat, small_colls, netrb, stateq
;
; COMMON BLOCKS:
;       None.
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
;       Written October 20, 1994, by Phil &, High Altitude Observatory/NCAR, Boulder CO
;
; MODIFICATION HISTORY:
;   P. Judge 8-June-1992
;   modified to include the GENCOLRD data- all collisional rates read from 
;   GENCOL formatted atom file are used including temperature dependent effects
;   P. Judge 14-Oct-1992
;   modified to permit incident radiation which is reduced by 
;   the factor NRB.  Thus, the "fixed" radiative rates are no
;   longer "fixed".  This means (1)  get_photo adds these
;   rates to the radiative part of the rate matrix in wmat,
;   and not to fixed rates.
;   P. Judge November 14, 1994, re-nromalize output to unity
;   P. Judge September 27, 1995, clean up 
; VERSION:
;       Version 2, October 20, 1994
;-
;
@cdiper
@cse
;
verb=(n_elements(verbose) ne 0)
;
; initialize variables 
;
nk = atom.nk
matrix=dblarr(nk,nk)
;
;  initialize variables
IF(istart NE -1) THEN BEGIN
   n=lvl.ev*0.0
   IF(atom.nrad NE 0) THEN begin
      tauq=trn.a*0.0 
      pesc = tauq*0.+1. 
      dpesc = 0.*pesc
      nrb=pesc
   ENDIF
endif
;
; compute lte populations
;
ltepop
;
; compute approximate H, He populations for collisional rates.
;
hpop
hepop
;
;  Compute collisional rates
;
crat
;
istrt=istart
swtch0=1.e2
IF(atom.nrad NE 0) THEN BEGIN 
   nrb=1.0+trn.a*0 & pesc = nrb & tauq = nrb*0.
ENDIF
choose:
CASE (istrt) OF
   -1:BEGIN
      GOTO,end1
   END
   0: stateq
   1:BEGIN 
      IF(atom.nrad NE 0) THEN nrb = trn.a*0.
      n = nstar
   END
   2:BEGIN
      IF(atom.nrad NE 0) THEN swtch=MAX(trn.A*NRB / total(C(trn.JRAD,*))) ELSE swtch = 1
      IF (swtch GT swtch0) THEN istrt=0 ELSE istrt=1
      GOTO, choose
   END
ENDCASE
;
end1:
return
end
;


