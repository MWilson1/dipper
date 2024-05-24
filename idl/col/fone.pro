;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: fone.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, October 13, 1995
;
; Last Modified: Tue Aug 13 17:38:14 2002 by judge (Phil Judge) on pika
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION fone, x, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:	
;       fone()
;
; PURPOSE:
;       Calculates F1(x) tabulated by Arnaud and Rothenflug 1985. 
;       This is first exponential integral times exp(x).
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = fone()
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
;       Written October 13, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, October 13, 1995
;-
;
if(n_elements(help) gt 0) then begin
  doc_library,'fone'
  return,-999
endif
if(n_elements(x) eq 1) then x=[x]
ff = x*0.
;
j = where(x LT 20.,small)
IF(small NE 0) THEN ff(j) = expint(1,x(j))*exp(x(j))
j = where(x GE 20.,big)
IF(big GT 0) THEN BEGIN 
ff(j) = 1./x(j) -1./x(j)/x(j) + 2./x(j)/x(j)/x(j) -$
   6./x(j)/x(j)/x(j)/x(j) + 24./x(j)/x(j)/x(j)/x(j)/x(j)
endif
return,ff
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'fone.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
