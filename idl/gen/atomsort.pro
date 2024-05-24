;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: atomsort.pro
; Created by:    Philip Judge, May 29, 1998
;
; Last Modified: Tue Aug  1 14:52:28 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO atomsort,wsort = wsort,losort = losort,upsort = upsort,$
             ionsort = ionsort,sortindex = sortindex
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       atomsort
;
; PURPOSE: Reorders atomic levels and associated variables
;
; EXPLANATION:
;       sorts atomic energy levels by energies (def.) or ion stage (if /ion)
; CALLING SEQUENCE: 
;       atomsort
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       none
;   
; OUTPUTS:
;       Modified data are stored in common block catom (accessed via @catom)
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORD PARAMETERS: 
;       wsort  sort transitions by wavelength
;       losort  sort transitions by lower level 
;       upsort  sort transitions by upper level
; CALLS:
;       none
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       re-orders common block variables lvl,trn,col
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;   Written July 28, 1998 P. Judge
;
; MODIFICATION HISTORY:
;   February 26, 2006 PGJ
; VERSION: 1
;       
;       
;-
@cdiper    
sortindex = indgen(atom.nk)
IF(n_elements(ionsort) NE 0) THEN BEGIN 
   IF(monotonic(lvl.ion)) THEN GOTO, other
   messdip,'Re-ordering atomic data, sorted by ion stage',/inform
   sortindex = sort(lvl.ion)
ENDIF ELSE BEGIN 
   IF(monotonic(lvl.ev)) THEN GOTO, other
   messdip,'Re-ordering atomic data, sorted by energy',/inform
   sortindex = sort(lvl.ev)
ENDELSE
;
lvl = lvl(sortindex)
;
dumi = trn.irad
dumj = trn.jrad
;
;
FOR i = 0,atom.nk-1 DO BEGIN 
   k = where(dumi EQ sortindex(i),ki)
   IF(ki NE 0) THEN trn(k).irad = i
   k = where(dumj EQ sortindex(i),kj)
   IF(kj NE 0) THEN trn(k).jrad = i
ENDFOR
dumi = trn.irad
dumj = trn.jrad
trn.irad =  dumi <  dumj
trn.jrad =  dumi > dumj
;
;
IF(!regime NE 2) THEN BEGIN
   dumi = col.ilo
   dumj = col.ihi
   FOR i = 0,atom.nk-1 DO BEGIN
      k = where(dumi EQ sortindex(i),ki)
      IF(ki NE 0) THEN col(k).ilo = i
      k = where(dumj EQ sortindex(i),kj)
      IF(kj NE 0) THEN col(k).ihi = i
   ENDFOR
ENDIF
;
other:
sl = lindgen(n_elements(trn))
IF(n_elements(wsort) NE 0) THEN sl = sort(trn.alamb)
IF(n_elements(losort) NE 0) THEN sl = sort((trn.irad)+float(trn.jrad)/atom.nk)
IF(n_elements(upsort) NE 0) THEN sl = sort((trn.jrad)+float(trn.irad)/atom.nk)
trn = trn(sl)
;   
RETURN
END



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'atomsort.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
