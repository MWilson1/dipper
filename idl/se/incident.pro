;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: incident.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, October 18, 1995
;
; Last Modified: Fri Aug 11 02:20:31 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO incident
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       incident
;
; PURPOSE: 
;       calls procedure  for incident radiation  intensity if undefined, and
;       then computes  photo-excitation and de-excitation rates with current
;       values of the escape  probabilities.
;   
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       incident, 
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
;
; CALLS:
;       None.
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
;       Written October 18, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       PGJ Commented out "zero radiation" message Feb 2013.
; VERSION:
;       Version 1, October 18, 1995
;-
;
@cdiper
@cse
;
IF(atom.nrad EQ 0) THEN return
waves = 0.
IF(atom.nrad NE n_elements(trn)) THEN messdip,$
   'INCIDENT: inconsistent atom and trn structures (lines and continua)'
k = where(trn.type NE 'BF',nline)
IF(atom.nline NE nline) THEN messdip,$
   'INCIDENT: inconsistent atom and trn structures (lines)'
;
IF(atom.nline  GT 0)  THEN waves = [waves,trn(0:atom.nline-1).alamb]
IF(atom.nrad-atom.nline GT 0) THEN BEGIN 
   FOR kr = atom.nline,atom.nrad-1 DO BEGIN
      ny = 1+INDGEN(trn(kr).nq)
      bfwav =  cc/trn(kr).frq(ny)*1.e8
      waves = [waves,bfwav]
   ENDFOR
ENDIF
waves = waves(1:*)
IF(strupcase(incfunc) EQ 'ZERO') THEN jinc = 0.*waves ELSE $
   jinc = call_function(incfunc,waves)
m = minmax(jinc)
;
IF(m(0) LT 0.) THEN messdip,'INCIDENT:negative incident radiation input'
;
RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'incident.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
