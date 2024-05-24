;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: mainline.pro
; Created by:    Philip G. Judge, May 8, 1996
;
; Last Modified: Mon Mar  6 12:02:02 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO mainline, main 
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       mainline
;
; PURPOSE: returns array containing the indices of strongest lines of multiplets
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       mainline, lines
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
;       
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, March 6, 2006
;-
;
@cdiper
main=-1l
IF(atom.nrad EQ 0) THEN RETURN
kr = lindgen(atom.nrad-1)
m = trn.multnum
mx = max(trn.multnum)
FOR im=0, mx-1 DO BEGIN
   k = where(m EQ im)
   tr = kr(k) ; indices of lines belonging to multiplet
   strongest = max(lvl(trn(tr).irad).g*trn(tr).f)
   main=[main,tr(!c)]
ENDFOR
main=main(1:*)
RETURN 
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'mainline.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

