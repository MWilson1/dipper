;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_line_dx_angle.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Sun Jun  4 11:19:20 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td_line_dx_angle, dummy, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_line_dx_angle
;
; PURPOSE: sort end-point displacements of lines in term diagram according to angle
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       td_line_dx_angle, 
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
;       cdiper, ctermdiag
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       low level term diagram routine
; PREVIOUS HISTORY:
;       Written September 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, September 5, 1996
;-
;
@diper
@ctermdiag   
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_line_dx_angle'
   RETURN
ENDIF
;
;  find angles for transitions counting from vertical up from lower level
;  positive clockwise
;
nrad = atom.nrad
nk = atom.nk
irad = atom.irad
jrad = atom.jrad

angle=fltarr(nrad)
dxs=(positions(jrad)-positions(irad))*!d.x_vsize*!x.s(1)
dys=(evplot(jrad)-evplot(irad))*!d.y_vsize*!y.s(1)
iw=WHERE(dxs NE 0.0,count)
IF(count NE 0) THEN angle(iw)=90.-atan(dys(iw)/dxs(iw))*180./!pi
iw=WHERE(angle GT 90.,count)
IF(count NE 0) THEN angle(iw)=angle(iw)-180.

; go through each level and sort idx and jdx separately

FOR ii=0,nk-1 DO BEGIN
   ikr=WHERE(irad EQ ii,count)
   IF(count GT 0) THEN BEGIN
      order=SORT(angle(ikr))
      idx(ikr(order))=INDGEN(N_ELEMENTS(order))
   ENDIF
   jkr=WHERE(jrad EQ ii,count)
   IF(count GT 0) THEN BEGIN
      order=SORT(-angle(jkr))
      jdx(jkr(order))=INDGEN(N_ELEMENTS(order))
   ENDIF
ENDFOR

idx = idx > jdx
jdx = idx > jdx

max_dx_line=MAX(idx)
max_dx_cont=max_dx_line

RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_line_dx_angle.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
