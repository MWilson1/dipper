;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: lifetime.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, May 4, 1995
;
; Last Modified: Thu Mar  9 13:14:02 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
function lifetime, j,help=help,nowarn=nowarn
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       lifetime
;
; PURPOSE: returns lifetime of a level in seconds
;	
; OUTPUT:
;       none
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;	lt=lifetime(j)
;
; INPUTS:
;       j - IDL level index of level in atomic model (starting from zero),
;       can be integer or longword, single variable or array
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Lifetime of level(s) j.  If level has infinite lifetime, a value of
;       zero is returned.  Units are seconds
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       /nowarn. Do not issue warning messdip of infinite lifetime
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       catom
;
; RESTRICTIONS: 
;       If level has an infinite lifetime, ZERO IS RETURNED and a warning
;       issued 
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written May 4, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, May 4, 1995
;-
;
@cdiper
IF(N_PARAMS(0) LT 1) THEN BEGIN
   PRINT,'lifetime,j,ltime, inverse=inverse,help=help'
   RETURN,0
ENDIF
;
;
jarr = j
len = N_ELEMENTS(j)
IF(len EQ 1) THEN BEGIN
   jarr =  [j]
ENDIF   
;
warn = N_ELEMENTS(nowarn) EQ 0
ltime = jarr*0.d0
lt0 = 0.d0
IF(N_ELEMENTS(atom.nrad) EQ 0 OR N_ELEMENTS(trn.jrad) EQ 0) THEN BEGIN
   IF(warn) THEN messdip,'no radiative transitions in atom'
   RETURN,lt0
ENDIF
IF(atom.nline EQ 0) THEN BEGIN 
   RETURN,lt0
ENDIF
FOR i = 0,N_ELEMENTS(jarr)-1 DO BEGIN
   k=WHERE(trn.jrad EQ jarr(i),count)
   IF(count EQ 0) THEN BEGIN
      IF(warn) THEN messdip,'No decay rates from upper level '+strn(jarr(i))+$ 
         '  '+lvl(jarr(i)).label,/inf
      ltime(i) = 1.d200
   ENDIF ELSE ltime(i) = 1./total(trn(k).a)
ENDFOR
IF(len EQ 1) THEN BEGIN
   ltime =  ltime(0)
ENDIF   
RETURN,ltime
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'lifetime.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
