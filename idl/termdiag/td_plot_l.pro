;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_plot_l.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Thu Sep  5 19:54:26 1996 by judge (Philip G. Judge) on judgepc.hao.ucar.edu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td_plot_l, ypos=ypos,dxpos=dxpos, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_plot_l
;
; PURPOSE: Plots the names of the term series on the bottom of the term diagram
;          for lsort ne 0
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       td_plot_l, 
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
;       ctermdiag
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
;       Written September 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, September 5, 1996
;-
;
@ctermdiag
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_plot_l'
   RETURN
ENDIF
dy = 0.05*(top-bottom)
if(n_elements(ypos)  eq 0) then  yplot=bottom-dy ELSE yplot = ypos
IF(N_ELEMENTS(dxpos) EQ 0) THEN dxpos=0.30
;
; put odd parity below even
;
ns = N_ELEMENTS(lstring)
yplot = yplot+fltarr(ns)*0.
FOR i = 0,ns-1 DO BEGIN
   k = STRPOS(STRUPCASE(lstring(i)),'!UO')
   IF(k GT 0) THEN yplot(i) = yplot(i)-dy
ENDFOR


IF(!p.charsize NE 0) THEN csize=!p.charsize*0.8 ELSE csize=0.8
FOR i=0,ns-1 DO xyouts,i+dxpos,yplot(i),lstring(i),SIZE=csize

RETURN
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_plot_l.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

