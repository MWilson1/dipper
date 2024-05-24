;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: gtoj.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, October 9, 1995
;
; Last Modified: Mon Jun  3 03:52:08 1996 by judge (Philip G. Judge) on astpc10.uio.no
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION gtoj, g, str=str, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:	
;       gtoj()
;
; PURPOSE: Converts g value to J
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = gtoj(g)
;
; INPUTS:
;       g  = integer or floating point scalar or array, degeneracy of level
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       real or string variable containing J such that 2J+1=g
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       /str  return string value
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
;       Written October 9, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, October 9, 1995
;-
;

if(n_elements(help) gt 0) then begin
  doc_library,'gtoj'
  return,-999
endif
;
n = N_ELEMENTS(g)
IF(n EQ 1) then gg = [g] ELSE gg = g
j = (gg-1)/2.
jstr = STRARR(n)
FOR i = 0,n-1 DO BEGIN
   j0 = j(i)
   IF(gg(i)/2. - FIX(gg(i)/2.) NE 0.) THEN BEGIN
   ;
   ; even case
   ;
      jstr(i) = strn(FIX(j0))
   ENDIF ELSE BEGIN 
   ;
   ; odd  case
   ;
      jstr(i) = strn(FIX(2*j0))+'/2'
   ENDELSE
ENDFOR

IF(n EQ 1) THEN jstr = jstr(0)
IF (N_ELEMENTS(str) GT 0) THEN RETURN,jstr ELSE RETURN,j
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'gtoj.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
