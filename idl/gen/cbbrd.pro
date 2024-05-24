;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: cbbrd.pro
; Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, January 13, 1997
;
; Last Modified: Wed Aug  2 18:03:19 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO cbbrd, anum, inum, enidx=enidx, nocheck=nocheck, $
              status=status, help=help
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:  cbbrd     (procedure)
;       
;
; PURPOSE:  Reads collisional data from atomic database.
;
; CALLING SEQUENCE:
;
;       cbbrd, anum, inum, [enidx] (, help=help])
;
; INPUTS:
;       anum - atomic number of the ion to be read from the database.
;       inum - spectrum number of the ion to be read from the database.
;
;       (These inputs will over ride the optional enidx input.)
;
; OPTIONAL INPUTS: 
;       enidx - an array of indicies of the energy values of the atom from the
;               atomic energy database.  If given, inputs anum and
;               inum are not necessary.
;
; OUTPUTS:
;       Stores collision strength data in cgencol common block.
;
; OPTIONAL OUTPUTS:
;       status - error status of collisional data.  Returns 0 if no errors are
;                detected, 1 if errors are detected.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       dbopen.pro, dbclose.pro, dbget.pro, dbext.pro, dbfind.pro, gtoj.pro,
;       atomn.pro, roman.pro, xyouts_norm, sdpcolchk.pro,
;       comgen.pro, gencom.pro, clean_bfcol.pro.
;
; COMMON BLOCKS:
;       catom, cgencol.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Part of the HAOS-DIPER database software.
;
; PREVIOUS HISTORY:
;       Written January 13, 1997, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1, June 12, 2006 PGJ
;-
;
@cdiper
@cse
;
IF(N_PARAMS() NE 2 AND N_ELEMENTS(enidx) EQ 0) THEN BEGIN
  messdip,/inf, 'cbbrd, anum, inum, [enidx=enidx]'
  RETURN
ENDIF
;
IF(N_ELEMENTS(enidx) EQ 0) THEN BEGIN
   dbopen, 'atom_lvl'
   enidx = dbfind('atom=' + STRTRIM(STRING(anum), 2) + $
                  ',ion=' + STRTRIM(STRING(inum), 2), /silent)
   dbclose
   IF((enidx(0) EQ 0) OR (enidx(0) EQ -1)) THEN BEGIN
      PRINT, '% CBBRD:  Insufficient information in database.  Exiting...'
      RETURN
   ENDIF
ENDIF
;
dbopen, 'atom_cbb, atom_bib'
cidx = dbget('col_lab_i', enidx, /silent)
cjdx = dbget('col_lab_j', enidx, /silent)
;
ok = 0l
FOR i = 0,n_elements(cjdx)-1 DO BEGIN 
   k = where(cidx EQ cjdx(i),coun)
   IF(coun NE 0) THEN ok = [ok,k]
ENDFOR
ok = ok(1:*)
cidx = cidx(ok)
;
IF((cidx(0) EQ 0) OR (cidx(0) EQ -1)) THEN BEGIN
   messdip, 'No b-b collisional data found in database.',/inf
   dbclose
ENDIF ELSE BEGIN
   dbext, cidx, 'key, temp, col, ntemp, col_lab_i, col_lab_j, ' + $
      'bib_ref', sdpkey, sdptemp, sdpdata, nt, cilab, cjlab, col_bib
   dbclose
   dbopen,'atom_lvl'
   dbext,cilab,'label',ilab
   dbext,cjlab,'label',jlab
   dbclose
   scnt = n_elements(cilab)
   col = replicate(coldef,scnt)
   j = -1
   FOR i = 0, scnt-1 DO BEGIN
      ii = WHERE(lvl.label EQ ilab(i),coi)
      jj = WHERE(lvl.label EQ jlab(i),coj)
      IF(coi(0) EQ 1 AND coj(0) EQ 1) THEN BEGIN 
         j = j+1
         col(j).key = sdpkey(i)
         col(j).ilo = ii(0)
         col(j).ihi = jj(0)
         col(j).temp = sdptemp(*,i)
         col(j).data = sdpdata(*,i)
         col(j).nt = nt(i)
         col(j).ref = col_bib(i)
      ENDIF
   ENDFOR
ENDELSE
newcol = 1
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'cbbrd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
