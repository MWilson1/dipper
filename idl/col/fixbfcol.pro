;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: fixbfcol.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, January 13, 1995
;
; Last Modified: Wed Aug  2 17:32:11 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro fixbfcol
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       fixbfcol
;
; PURPOSE: 
;  gets collisional data which are consistent with the atomic model
;  and those data from Shull and van Steenberg 1982, and Arnaud and Rothenflug
;  1985. 
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       fixbfcol, coldata
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       coldata  new structure containing collisional data for b-f transitions
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /sef  use Seaton's SEF for excited levels (not ground term), otherwise
;       use Burgess+Chidichimo (MNRAS 1983)
;       /help.  Will call doc_library and list header, and return
;       maxarr   set maximum number of elements in collisional data to maxarr
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
;       Written January 13, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, January 13, 1995
;-
;
;
@cdiper
;   
; structure 'col' 
;
;
shull82,cshull
ar85ci,car
ar85ct,ctar
IF(N_ELEMENTS(sef) ne 0) THEN cicalc,ci else burcalc,ci   
;
;  cleanup old data
;
j=WHERE(col.key NE 'SHULL82',nj)
IF(nj NE 0) THEN col=col(j)
j=where(strmid(col.key,0,4) ne 'AR85',nj)
IF(nj NE 0) THEN col=col(j)
j=where(strmid(col.key,0,2) ne 'CH',nj)
IF(nj NE 0) THEN col=col(j)
j=where(strmid(col.key,0,2) ne 'CI',nj)
IF(nj NE 0) THEN col=col(j)
j=where(strmid(col.key,0,7) ne 'BURGESS',nj)
IF(nj NE 0) THEN col=col(j)
;
;  merge new data
;
if(strmid(cshull(0).key,0,1)  ne ' ') then col=[col,cshull]
if(strmid(car(0).key,0,1)     ne ' ') then col=[col,car]
if(strmid(ctar(0).key,0,1)    ne ' ') then col=[col,ctar]
IF(STRMID(ci(0).key,0,1)      NE ' ') THEN col=[col,ci]
j = WHERE(STRTRIM(col.key) NE '',cok)
IF(cok GT 0) THEN col = col(j)
;
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'fixbfcol.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
