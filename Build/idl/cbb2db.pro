;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: cbb2db.pro
; Created by:    judge, March 13, 2006
;
; Last Modified: Tue Aug  1 15:58:51 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO cbb2db
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       cbb2db     (procedure)
;
; PURPOSE:  To add atom file bound-bound collision rate coefficients to the UIT database.
;
;       The purpose of this procedure is to add atom file collision strengths
;       to the UIT database file, atom_cbb.
;
; CALLING SEQUENCE:
;
;       cbb2db
;
; INPUTS:
;       None.
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Places b-b collisional data into the UIT database.  Also places
;        references, comments, and accuracies into the
;        database 
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;
; CALLS:
;
; COMMON BLOCKS:
;       cdiper - standard HAOS-DIPER common block (see atomrd.pro)
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
;       Written August 20, 1996, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, August 20, 1996
;-
;
@cdiper
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine bound-bound entries in col.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if(!REGIME eq 2) then return


iohm = WHERE(strmid(col.key,0,3) EQ 'OHM' OR strmid(col.key,0,6) $
             EQ 'SPLUPS' OR col.key EQ 'CE',nohm)
;
IF(nohm EQ 0) THEN BEGIN
   print, 'No OHM or CE or SPLUPS entries in atom: skipping rest of this procedure'
   RETURN
ENDIF else begin
   print,nohm , ' entries to be removed from atom_cbb '
endelse
ato = atomn(getwrd(atom.atomid))
mc = 15
colrbn, mc  ;only affects CE and OHM 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the comment & reference indicies, and the accuracies.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
silent = 1
refs = bib_idx(hdr, 'ohm-ref', nohm,silent = silent)
acc = 100*atomuncs(hdr, 'ohm-err', nohm)
ohmlabel = lvl.label
oion = string(lvl(0).ion)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup database files.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dbopen, 'atom_lvl'
subsete = dbfind('atom=' + STRTRIM(STRING(ato), 2) + ',ion=' + oion ,silent = silent)

count = 0
build_db = intarr(nohm)+1
jlist_db = build_db*0
ilist_db = build_db*0
ilev = nla(lvl.orb(2))+nla(lvl.orb(1))+slp(lvl.term(1))+$
          nla(lvl.orb(0))+slp(lvl.term(0)) + string(lvl.tjp1)

FOR i = 0, nohm-1 DO BEGIN
                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                ; Initialize build database flag to true.
                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ohm_hi = col(iohm(i)).ihi
   ohm_lo = col(iohm(i)).ilo
;   
;  orig    
;   ohm_ilab = ohmlabel(ohm_lo)
;   ohm_jlab = ohmlabel(ohm_hi)
;                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                ; Search for the upper level and lower level
;                                ; labels in the energy database.
;                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   jlist = dbfind('label=' + ohm_jlab,subsete,silent=silent,/full)
;   ilist = dbfind('label=' + ohm_ilab,subsete,silent=silent,/full)
;
;   search on quantum numbers instead:
;
   strj = 'orb3='+string(lvl(ohm_hi).orb(2)) +$
                        ',orb2='+string(lvl(ohm_hi).orb(1))+$
                        ',orb1='+string(lvl(ohm_hi).orb(0))+$
                        ',term1='+string(lvl(ohm_hi).term(0))+$
                        ',term2='+string(lvl(ohm_hi).term(1))+$
                        ',tjp1='+string(lvl(ohm_hi).tjp1)
   stri = 'orb3='+string(lvl(ohm_lo).orb(2))+$
                        ',orb2='+string(lvl(ohm_lo).orb(1))+$
                        ',orb1='+string(lvl(ohm_lo).orb(0))+$
                        ',term1='+string(lvl(ohm_lo).term(0))+$
                        ',term2='+string(lvl(ohm_lo).term(1))+$
                        ',tjp1='+string(lvl(ohm_lo).tjp1) 
                                        
   jlist = dbfind(strj,subsete,silent=silent)
   ilist = dbfind(stri,subsete,silent=silent      )
   
   njl = n_elements(jlist)
   nil = n_elements(ilist)
   IF(njl GT 1 OR nil GT 1) THEN messdip,'Duplicate levels in atom_lvl database: stop'
   jlist_db(i) = jlist[0]
   ilist_db(i) = ilist[0]
   IF(jlist[0] LT 1) THEN BEGIN
      messdip,/inf,'associated upper level not in database- skipping'
      build_db(i) = 0
   ENDIF
   IF(ilist[0] LT 1) THEN BEGIN
      messdip,/inf,'associated lower level not in database- skipping'
      build_db(i) = 0
   ENDIF
ENDFOR
;
added = 0
skipped = 0
dbopen, 'atom_cbb'
FOR i = 0, nohm-1 DO BEGIN
   ii = iohm(i)
   ohm_temp = col(ii).temp
   ohm_ohm = col(ii).data
   ohm_key = strtrim(col(ii).key,2)
   ohm_nt = col(ii).nt
   ohm_hi = col(ii).ihi
   ohm_lo = col(ii).ilo
   ohm_ilab = ohmlabel(ohm_lo)
   ohm_jlab = ohmlabel(ohm_hi)
   IF(build_db(i)) THEN BEGIN
      c_labj = jlist_db(i)
      c_labi = ilist_db(i)
      build_db(i) = 1
      list = dbfind('key='+ohm_key+ ',ntemp=' + STRTRIM(STRING(ohm_nt), 2) + $
                    ', col_lab_j=' + STRTRIM(STRING(c_labj), 2) + $
                    ', col_lab_i=' + STRTRIM(STRING(c_labi), 2) + $
                    ', acc=' + STRTRIM(STRING(acc(i)), 2) + $
                    ', ref=' +STRTRIM(STRING(refs(i)), 2),silent=silent)
      IF(list[0] GE 1) THEN BEGIN
         FOR zz = 0, N_ELEMENTS(list)-1 DO BEGIN
            dbext, list[zz], 'temp,col', dtemp, dcol
            difft = dtemp-ohm_temp
            diffc = dcol-ohm_ohm
            wdifft = WHERE(difft NE 0.0)
            wdiffc = WHERE(diffc NE 0.0)
            IF((wdifft(0) EQ -1) AND (wdiffc(0) EQ -1)) THEN BEGIN
               build_db(i) = 0
               skipped = skipped+1
            ENDIF
         ENDFOR
      ENDIF
                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                ; If data not currently in the database, then
                                ; add it.
                                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      IF(count EQ 0) THEN BEGIN 
         b0 = ohm_key
         a1 =  ohm_temp(0:ohm_nt-1)
         a2 =  ohm_ohm(0:ohm_nt-1)
         a3 =  ohm_nt
         a4 =  c_labj
         a5 =  c_labi
         a7 =  acc(i)
         a8 =  refs(i)
         a10 = col(ii).approx
         count = count+1
         added = added+1
      ENDIF ELSE BEGIN 
         b0 = [b0 , ohm_key]
         a1 = [a1 , ohm_temp(0:ohm_nt-1)]
         a2 = [a2 , ohm_ohm(0:ohm_nt-1)]
         a3 = [a3 , ohm_nt]
         a4 = [a4 , c_labj]
         a5 = [a5 , c_labi]
         a7 = [a7 , acc(i)]
         a8 = [a8 , refs(i)]
         a10 = [a10 , col(ii).approx]
         added = added+1
      ENDELSE             
   ENDIF
ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Open, build, close database files and reset !priv.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF(count NE 0) THEN begin
   !priv = 2
   dbopen, 'atom_cbb', 1
   btime = sdptime()
   nn = n_elements(a3)
   a11 = fltarr(mc,nn)
   a22 = a11
   start = 0l
   FOR i = 0l,nn-1 DO BEGIN
      nt = a3(i)
      n1 = nt-1
      a11(0:n1,i) = a1(start:start+n1)
      a22(0:n1,i) = a2(start:start+n1)
      start = start+nt
   ENDFOR
   dbbuild, b0, a11,a22,a3,a10,a4,a5,a7,a8
   dbclose
   !priv = 0
endif
messdip,/inf,strn(added)+' col bb transitions added, '+strn(skipped)+' skipped'
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'cbb2db.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
