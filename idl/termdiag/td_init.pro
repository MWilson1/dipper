;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_init.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 23, 1994
;
; Last Modified: Thu Aug 10 21:50:48 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO td_init,lsort=lsort,dxmethod=dxmethod, fskeep=fskeep, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_init
;
; PURPOSE: initializes termdiag common-block variables
;       
; EXPLANATION:
;            /lsort gives sorting according to multiplicity and L
;            dxmethod = 0   line_dx        algorithm
;                       1   line_dx_angle  sorting
;                       2   line_dx_center sorting
;   linestyles are set and, with td_plot, are plotted thus
;   permitted b-b transitions - linestyle=0   
;   permitted b-f transitions - linestyle=2
;   spin-forbidden bb transitions - linestyle=3
;   forbidden bb transitions - linestyle=1
;       
; CALLING SEQUENCE: 
;       td_init [,/lsort] [,dxmethod=dxmethod]
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
;       fskeep=fskeep  set this to keep the fine structure energies
;
; CALLS:
;       labtd, td_lsty, td_get_series, td_xlabels, td_split_series, td_fs_split
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
;       
; PREVIOUS HISTORY:
;       Written September 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
;       Added /fskeep keyword PGJ dec 13 2012
; VERSION:
;       Version 1, September 5, 1996
;-
;
@cdiper
@ctermdiag   
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_init'
   RETURN
ENDIF
; array declarations
IF(atom.nrad GT 0) THEN BEGIN
   idx=intarr(atom.nrad)             ; displacement of lower level
   jdx=idx                           ; displacement of upper level
ENDIF
; Default colors

c_label_space=0
c_label=-1
c_arrow=-1

;
; line styles various
;
td_lsty,sty
sty_perm = sty(0)
sty_bf = sty(1)
sty_forb = sty(3)
sty_ic = sty(2)

IF(N_ELEMENTS(lsort) EQ 0) THEN lsort=0
IF(N_ELEMENTS(top) EQ 0) THEN top = MAX(lvl.ev)
IF(N_ELEMENTS(bottom) EQ 0) THEN bottom = MIN(lvl.ev)


; split labels into config, term

td_get_series

; xlabels returns the positions of the terms etc in x-axis.

POSITIONS=FLTARR(atom.NK)
td_xlabels,lvl.label,lvl.ion,atom.nk

;
; fine structure splitting:
;
td_fs_split,fskeep=fskeep
;
; fill directions and krcolor with default
;
krcolor = 0
;
; set up for cases with radiative transitions 
; 
IF(atom.nrad GT 0) THEN BEGIN
   DIRECTIONS=STRARR(atom.NRAD)
   IF(!d.name NE 'PS') THEN $
      krcolor=intarr(atom.nrad)+!p.color $
   ELSE $
      krcolor=intarr(atom.nrad)+1
   kr_linestyle=intarr(atom.nrad)
   IF(atom.nrad GT atom.nline) THEN kr_linestyle(atom.nline:atom.nrad-1)=sty_bf
   FOR KR=0,atom.nrad-1 DO BEGIN
      DIRECTIONS(kr)='D'
   ENDFOR
;
;  get intercombination and forbidden transitions
;   
   jr = trn.jrad
   ir = trn.irad
   deltas = abs(lvl(jr).tsp1-lvl(ir).tsp1)
   FOR kr = 0, atom.nline-1 DO BEGIN
      IF(deltas(kr) NE 0) THEN kr_linestyle(kr)=sty_ic
      IF(lvl(ir(kr)).parity EQ lvl(jr(kr)).parity) THEN kr_linestyle(kr)=sty_forb
   ENDFOR
;
; get transition line end-point displacements
;   
   IF(N_ELEMENTS(dxmethod) EQ 0) THEN dxmethod=0
   CASE dxmethod OF
      0: td_line_dx
      1: td_line_dx_angle
      ELSE: td_line_dx_center
   ENDCASE
ENDIF ELSE BEGIN
   max_dx_line = 1
   max_dx_cont = 1
ENDELSE
;   
; set termdiag labels to atomic labels
;
term_label=STRARR(atom.nk)
;
;
FOR i=0,atom.nk-1 DO term_label(i) = labtd(i,/par,/conf,/term)
;
IF(lsort EQ 1) THEN BEGIN
   td_split_series,10-INDGEN(11),/noreset,fskeep=fskeep
   FOR i=0,atom.nk-1 DO term_label(i) = labtd(i,/par,/conf)
ENDIF ELSE IF(lsort EQ 2) THEN BEGIN
   td_split_series,INDGEN(11),/noreset,fskeep=fskeep
   FOR i=0,atom.nk-1 DO term_label(i) = labtd(i,/par,/conf)
ENDIF
;
tstring = ''                    ; default title string
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_init.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
