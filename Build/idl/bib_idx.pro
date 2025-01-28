;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: bib_idx.pro
; Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, August 16, 1996
;
; Last Modified: Mon Jul 31 12:29:02 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION bib_idx, head, kwd, nidx, silent = silent
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       bib_idx     (function)
;
; PURPOSE:  To place atom file references into the UIT database (atom_bib).
;
;       The purpose of this function is to place atom file references into the
;       UIT database (atom_bib) files and return the bib database indicies of
;       the references.
;
; CALLING SEQUENCE:
;
;       result = bib_idx(head, kwd, nidx [,help=help])
;
; INPUTS:
;       head - atom file header structure obtained from headrd.pro.
;        kwd - the header keyword containing the references to be input.
;       nidx - the number of references to be entered.
;
;       For example, if entering energy references, the call would be:
;
;       result = bib_idx(head, 'energies', nk)
;
;       where 'energies' is the keyword to search for in the header structure,
;       and nk is the number of energies in the atom file.  The returned
;       result is an integer array with nk elements, containing the database
;       indicies of the atom_bib file where the references are stored.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Returns an integer array with nidx elements containing the database
;       indicies of the atom_bib file where the references are stored.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       dbopen.pro, dbfind.pro, dbbuild.pro.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       The atom_bib database files must exist (.dbh, .dbf, & .dbx).
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written August 16, 1996, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, June 2, 2006
;-
;
IF(N_PARAMS() NE 3) THEN BEGIN
  PRINT, 'Usage:  result = bib_idx(head, kwd, nidx [,help=help])'
  RETURN, -99
ENDIF
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define output array to be returned.
;
!priv = 2
idx = intarr(nidx)
kwd = STRUPCASE(kwd)
;
hidx = WHERE(head.key EQ kwd)
IF(hidx(0) LT 0) THEN BEGIN
   messdip,/inf,'Keyword not available in header - ' + kwd
   RETURN, -99 +idx ; idx
ENDIF
;
htxt = STRTRIM(head(hidx(0)).text, 2)
htxt = strep(htxt,' ','_',/all)
IF(STRLEN(htxt) EQ 0) THEN BEGIN
   messdip,/inf,'No references for input keyword - ' + kwd
   RETURN, -99 +idx;idx
ENDIF
;
;keys = str_sep(htxt, ',')
;keys = STRTRIM(keys, 2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loop over each reference in the keys array and check if it is in
; the database.  If it is not, then add it.  Also maintain a record of
; reference indicies.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count = 0
FOR i = 0, N_ELEMENTS(htxt)-1 DO BEGIN
   ref = strep(htxt,'_',' ',/all)
   ref = strep(ref,',','',/all)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check if the reference exists in the database.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   dbopen, 'atom_bib', 1
   list = dbfind('bib_ref=' + ref,silent = silent)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If the reference does not already exist,
; then add it and get its index number.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF(list[0] LE 0) THEN BEGIN
      dbopen, 'atom_bib', 1
      dbbuild, ref
      dbclose
      dbopen, 'atom_bib'
      list = dbfind('bib_ref=' + ref,/full,silent = silent)
   ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine the range of the reference.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   range = getwrd(htxt(i),/last)
   IF(strpos(range,'[') LT 0) THEN range = '*' ELSE $
      range = STRMID(range, 1, STRLEN(range)-2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If the reference range includes all values,
; then do the following (i.e., '*'):
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF(range EQ '*') THEN BEGIN
      FOR j = count, nidx-1 DO idx(j) = FIX(list[0])
   ENDIF ELSE BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If the reference range only covers some of
; the values, then determine the range and
; fill in the index array values with the
; proper index number.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      dash = STRPOS(range, '-')
      IF(dash GE 0) THEN BEGIN
         first = FIX(STRMID(range, 0, dash))
         last = FIX(STRMID(range, dash+1, 10))
         FOR j = first, last DO BEGIN
            idx(j) = FIX(list[0])
            count = j+1
         ENDFOR
      ENDIF ELSE BEGIN
         temparr = str_sep(range, ' ')
         FOR ii = 0, N_ELEMENTS(temparr)-1 DO BEGIN
            idx(FIX(temparr(ii))) = FIX(list[0])
            count = ii+1
         ENDFOR
      ENDELSE
   ENDELSE
ENDFOR
RETURN, idx
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'bib_idx.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
