;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: bb2db.pro
; Created by:    Philip Judge, March 6, 2006
;
; Last Modified: Tue Aug  1 15:29:14 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
PRO bb2db
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       bb2db.pro     (procedure)
;
; PURPOSE: To add cdiper oscillator strengths to the UIT database.
;
;
; CALLING SEQUENCE:
;
;       bb2db
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Places atom file oscillator strengths into the UIT database files
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Part of the HAOS-DIPER.
;
; PREVIOUS HISTORY:
;       Written August 21, 1996, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;       March 13, 2006. Changed to use diper structures
; VERSION:
;       Version 1, March 13, 2006
;-
@cdiper
;
nline = atom.nline
IF(nline LE 0) THEN return
;
nk = atom.nk
jrad = trn.jrad
irad = trn.irad
g = FIX(lvl.g)
eion = lvl(0).ion
ato = atomn(getwrd(atom.atomid))
iso = ato-eion+1
labcnv
flabel = lvl.label
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the reference indicies, and the accuracies.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
refn = bib_idx(hdr, 'gfs-ref', nline,/silent)
acc = 100*atomuncs(hdr, 'gfs-err', nline)
;
!priv = 2
dbopen, 'atom_lvl'
subsete = dbfind('atom=' + STRTRIM(STRING(ato), 2),/silent)
count = 0
build_db = 1+intarr(nline)*0
jlist_db = build_db*0
ilist_db = build_db*0
;
FOR i = 0, nline-1 DO BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Search for the upper level and lower level
; labels in the energy database.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   subs = dbfind('ion='+string(lvl(irad(i)).ion),subsete,/silent)
   sj = flabel(jrad(i))
   jlist = dbfind('label=' + sj,subs,/silent)
   si = flabel(irad(i))
   ilist = dbfind('label=' + si,subs,/silent)
   jlist_db(i) = jlist[0]
   ilist_db(i) = ilist[0]
   IF(jlist[0] LT 1) THEN BEGIN
      messdip,/inf,'associated upper level not in database- skipping: '+flabel(jrad(i))
      stop
      build_db(i) = 0
   ENDIF
   IF(ilist[0] LT 1) THEN BEGIN
      print,flabel(irad(i))
      messdip,/inf,'associated lower level not in database- skipping'
      build_db(i) = 0
   ENDIF
ENDFOR
dbopen,'atom_bb,atom_bib'
;
f = trn.f
alamb = trn.alamb
added = 0
skipped = 0
subsetf = dbfind('atom=' + STRTRIM(STRING(ato), 2),/silent)
FOR i = 0, nline-1 DO BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If build_db = 1, then continue to build the
; database.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF(build_db(i)) THEN BEGIN
      f_lab_j = jlist_db(i)
      f_lab_i = ilist_db(i)
      f_acc = FIX(acc(i))
      bb_ref = FIX(refn(i))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check if the entry already exists in the database.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      fcen  = STRTRIM(STRING(f(i)), 2)
      fcirc = STRTRIM(STRING(f(i)*.005), 2)
      wcen  = STRTRIM(STRING(alamb(i)), 2)
      wcirc = STRTRIM(STRING(alamb(i)*.00005), 2)
      str_j = STRTRIM(STRING(f_lab_j), 2)
      str_i = STRTRIM(STRING(f_lab_i), 2)
      str_bib = STRTRIM(STRING(bb_ref), 2)
      flist = dbfind('ion='+string(lvl(irad(i)).ion),subsetf,/silent)
      str = 'f=' + fcen+'(' + fcirc+'),' + 'wl='+wcen+'('+wcirc+')'
      flist = dbfind(str,/silent,flist)
      IF(flist[0] EQ 0) THEN GOTO, cont
      str = 'f_lab_j=' + str_j + ',f_lab_i=' + str_i + ',bb_ref=' + str_bib
      flist = dbfind(str,/silent,flist,/full)

      cont:  ; fill databases 
      IF(flist[0] LE 0) THEN BEGIN
         IF(count EQ 0) THEN BEGIN 
            a2 =  f(i)
            a4 =  bb_ref
            a5 =  f_acc
            a6 =  f_lab_i
            a7 =  f_lab_j
            a8 =  alamb(i)
            a9 = trn(i).type
            a1a = ato
            a1b = lvl(trn(i).irad).ion
            a1c = ato-a1b+1
            count = count+1
            added = added+1
         ENDIF ELSE BEGIN 
            a2 = [a2 ,f(i)]
            a4 = [a4 , bb_ref]
            a5 = [a5 , f_acc]
            a6 = [a6 , f_lab_i]
            a7 = [a7 , f_lab_j]
            a8 = [a8 , alamb(i)]
            a9 = [a9 , trn(i).type]
            a1a = [a1a,ato]
            a1b = [a1b,lvl(trn(i).irad).ion]
            a1c = [a1c,ato-lvl(trn(i).irad).ion+1]
            added = added+1
         ENDELSE             
      ENDIF ELSE BEGIN
         skipped = skipped+1
      ENDELSE
   ENDIF
ENDFOR
IF(count NE 0) THEN BEGIN 
   !priv = 2
   dbopen, 'atom_bb',1
   dbbuild, a2,a8,a7,a6,a9,a5,a1a,a1b,a1c,a4
   !priv = 0
ENDIF
messdip,/inf,strn(added)+' bb transitions added, '+strn(skipped)+' skipped'
;
dbclose
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'bb2db.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
