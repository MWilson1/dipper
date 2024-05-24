;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: trnrd.pro
; Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, January 14, 1997
;
; Last Modified: Fri Apr 13 13:35:09 2007 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO trnrd, anum, inum, enidx=enidx
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:  trnrd     (procedure)
;
; PURPOSE:  To read transition data (oscillator strengths etc) 
;           from the atomic database.
;
; CALLING SEQUENCE:
;
;       trnrd, anum, inum, [enidx=enidx] ([,help=help])
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
;       Stores radiative data in catom common block variables.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       dbopen.pro, dbfind.pro, dbext.pro, dbclose.pro, dbget.pro.
;
; COMMON BLOCKS:
;       Catom.
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
;       Written January 14, 1997, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, January 14, 1997
;-
;
@cdiper
IF(N_PARAMS() NE 2 AND N_ELEMENTS(enidx) EQ 0) THEN BEGIN
  PRINT, 'Usage:  trnrd, anum, inum, [enidx=enidx] ([,help=help])'
  RETURN
ENDIF
;
oldnline = atom.nline
;
dbopen, 'atom_lvl'
IF(N_ELEMENTS(enidx) EQ 0) THEN $
   enidx = dbfind('atom=' + STRING(anum) + ',ion=' + STRING(inum), /silent)
;
IF(enidx(0) LE 0) THEN BEGIN
   messdip, 'data for atom and ion are not in the lvl database.',/inf
   trn = trndef
   return
ENDIF
;
;dbext,enidx,'label,g',label,g
label = lvl.label
g = lvl.g
;
dbopen, 'atom_bb,atom_bib'
fidx = dbget('f_lab_i', enidx, /silent) ; finds bb indices with lvl indices enidx
fjdx = dbget('f_lab_j', enidx, /silent)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; check following..
usr = get_user() &  usr = strlowcase(usr)
IF(usr EQ 'judge') THEN BEGIN 
   messdip,/inf,'User judge: MUST CHECK the matching code here & in isostr.pro'
   messdip,/inf,'User judge: does this work in general???'
ENDIF
;
ok = 0l
FOR i = 0,n_elements(fjdx)-1 DO BEGIN 
   k = where(fidx EQ fjdx(i),coun)
   IF(coun NE 0) THEN ok = [ok,k]
ENDFOR
ok = ok(1:*)
fidx = fidx(ok)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
atom.nline = n_elements(fidx)
;ok = where(fidx EQ fjdx,count)
;fidx = fidx(ok)
;
IF(fidx(0) LE 0) THEN BEGIN
   messdip,/inf, ' No oscillator strengths found in bb database'
ENDIF ELSE BEGIN
   dbext, fidx, 'f_lab_i, f_lab_j, f, wl, bib_ref',filab, fjlab, f, alamb, ref
   dbclose
   dbopen,'atom_lvl'
   dbext,filab,'label',ilab
   dbext,fjlab,'label',jlab
   dbclose
   ;
   ; get TRN.* variables 
   ;
   trn = replicate(trn(0),atom.nline)
   trn.f = f
   trn.ref = ref
   trn.alamb = alamb
   FOR i = 0L, atom.nline-1 DO BEGIN
      ii = WHERE(lvl.label EQ ilab(i),coi)
      jj = WHERE(lvl.label EQ jlab(i),coj)
      IF(coi eq 1 AND coj eq 1) THEN BEGIN
         trn(i).irad = ii(0)
         trn(i).jrad = jj(0)
         trn(i).a=trn(i).f*6.6702e15*g(ii(0))/(g(jj(0))*trn(i).alamb*trn(i).alamb)
         trn(i).bji=(trn(i).alamb)*(trn(i).alamb)*(trn(i).alamb)*trn(i).a/hc2
         trn(i).bij=trn(i).bji*g(jj(0))/g(ii(0))
      ENDIF ELSE messdip,'>1 f value in lvl database, case not treated'
   ENDFOR
ENDELSE
atom.nrad = atom.nrad+(atom.nline-oldnline)
;
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'trnrd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
