;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_fs_split.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Wed Aug  2 11:55:04 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td_fs_split, dummy, help=help,fskeep=fskeep
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_fs_split
;
; PURPOSE: evaluate new energies EVPLOT to make term diagrams look pretty
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       td_fs_split, 
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       evplot and low_fine in common block ctermdiag
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
;      cdiper, ctermdiag   
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       term diagram procedure, low level
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
   doc_library,'td_fs_split'
   RETURN
ENDIF
;
;            consider levels with same position + delta(e) < delta to
;            be finestructure
;
EVPLOT=lvl.EV
low_fine=INDGEN(atom.nk)
if(keyword_set(fskeep)) then begin 
   return
endif
;

delta=(top-bottom)/200.

;
iterm = nla(lvl.orb(2))+nla(lvl.orb(1))+nla(lvl.orb(0))+$
   slp(lvl.term(2))+slp(lvl.term(1))+slp(lvl.term(0))

FOR ii=1,atom.nk-1 DO BEGIN
   FOR jj=ii-1,0,-1 DO BEGIN
      IF (positions(ii) EQ positions(jj)) AND (iterm(jj) EQ iterm(ii)) $
         THEN GOTO,same_group
   ENDFOR
   GOTO, end_loop
same_group:
   evplot(ii)=evplot(jj)+ delta
   low_fine(ii)=low_fine(jj)
end_loop:
ENDFOR

RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_fs_split.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
