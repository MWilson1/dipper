;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_plot_ij.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Thu Sep  5 23:18:06 1996 by judge (Philip G. Judge) on judgepc.hao.ucar.edu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro td_plot_ij,i,j ,color,linetype
   
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_plot_ij
;
; PURPOSE: plot line between levels i and j
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       td_plot_ij,i,j [,color,linetype]
;
; INPUTS:
;       i,j levels i and j
; OPTIONAL INPUTS: 
;       color, linetype
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
;       Draws line in termdiagram plot
;
; CATEGORY:
;       low level termdiagram plotting routine
; PREVIOUS HISTORY:
;       Written September 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, September 5, 1996
;-
@ctermdiag
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_plot_ij'
   RETURN
ENDIF
;   
IF (N_PARAMS(0) LT 2) THEN BEGIN
   PRINT,'td_plot_ij,i,j [,color,linetype]'
   RETURN
ENDIF
;
old_color=!color
old_linetype=!linetype
IF (N_ELEMENTS(color) NE 0) THEN !color=color
IF (N_ELEMENTS(linetype) NE 0) THEN !linetype=linetype
;
oplot,[positions(i)+0.5,positions(j)+0.5],[evplot(i),evplot(j)]
!color=old_color
!linetype=old_linetype

RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_plot_ij.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
