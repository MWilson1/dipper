;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_split_series.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Thu Aug 10 21:50:20 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro td_split_series,order,noreset=noreset,fskeep=fskeep
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_split_series
;
; PURPOSE:  splits different multiplet systems in x, for termdiagram plotting
;       
; EXPLANATION:
;            within each multiplicity levels are sorted in ascending L
;            multiplicity and L stored in string lstring
; CALLING SEQUENCE: 
;       td_split_series, 
;
; INPUTS:
;            order   input array giving the order from left to right
;            order=[3,1] plots triplet levels to the left of singlet ones
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
;       td_fs_split,td_xlabels,labtd
;
; COMMON BLOCKS:
;       cdiper,ctermdiag
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
@cdiper
@ctermdiag   
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_split_series'
   RETURN
ENDIF

IF(N_PARAMS(0) NE 1) THEN BEGIN
   PRINT,'td_split_series,order'
   RETURN
ENDIF
;
IF(N_ELEMENTS(order) LE 1) THEN BEGIN
   PRINT,'td_split_series,order   order should be an array'
   RETURN
ENDIF
;
; find multiplicity and L
;
L=intarr(atom.nk)
mult = L
par = L
istring=STRARR(atom.nk)              ; store multiplicity,L,parity
FOR i=0,atom.nk-1 DO BEGIN
   istring(i) = labtd(i,/term)
   L(i)=lvl(i).bigl
   mult(i)=lvl(i).tsp1
   par(i) = lvl(i).parity EQ 'O'
ENDFOR

n_order=N_ELEMENTS(order)
iseries=iseries-iseries-1       ; set iseries to -1
max_iseries=-1
FOR i=0,n_order-1 DO BEGIN      ; loop through systems
   FOR ll = 0,MAX(l) DO BEGIN 
      iw=WHERE(mult EQ order(i) AND l EQ ll,count)
      IF(count GT 0) THEN BEGIN
         iseries(iw)=max_iseries+1+par(iw) ; set iseries to
                                ; ascending L and par
         
         max_iseries=MAX(iseries)
      ENDIF
   ENDFOR
ENDFOR
iw=WHERE(iseries EQ -1,count)
IF(count GT 0) THEN BEGIN
   PRINT,'td_split_series: multiplicities not accounted for:',mult(iw)
   RETURN
ENDIF
iseries = iseries-MIN(iseries)
lstring=STRARR(max_iseries+1)
FOR i=0,atom.nk-1 DO BEGIN
   is=iseries(i)
   lstring(is)=istring(i)
ENDFOR
IF(STRLOWCASE(STRTRIM(lstring(0),2)) EQ '!u!n') THEN lstring(*)=[lstring(1:*),lstring(0)]

; calculate new positions

td_xlabels,lvl.label,lvl.ion,atom.nk,noreset = noreset

; calculate new fine structure

td_fs_split,fskeep=fskeep

RETURN
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_split_series.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
