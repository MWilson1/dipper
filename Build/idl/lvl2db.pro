;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: lvl2db.pro
; Created by:    Philip Judge, March 6, 2006
;
; Last Modified: Tue Aug  1 19:48:18 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO lvl2db,levstr = levstr, head = head,replace=replace
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       lvl2db     (procedure)
;
; PURPOSE: To add lvl.xxx variables to the UIT lvl database.
;
; CALLING SEQUENCE:
;
;       lvl2db
;
; INPUTS:
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Places atom file energies (labels, quantum number, etc.) into the UIT
;       database files.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       levstr=levstr if given lstr is the lvl.xxx structure 
;       head=head if given lstr is the lvl.xxx structure 
; CALLS:
;
; COMMON BLOCKS:
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
;
; MODIFICATION HISTORY:
;       Changed for diper structures, PGJ March 6, 2006
; VERSION:
;       Version 1, March 6, 2006
;-
;
@cdiper
IF(n_elements(levstr) EQ 0) THEN BEGIN
   levstr = lvl                 ; use diper common lvl structure
   head = hdr
ENDIF ELSE BEGIN 
   IF(n_elements(head) EQ 0) THEN head = hdr(0)
   messdip,'using data passed to routine ',/inf
ENDELSE
;
;
nk = n_elements(levstr)
g = FIX(levstr.g)
eion = min(levstr.ion)
ato = atomn(getwrd(atom.atomid))
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the comment & reference indicies, and the accuracies.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
head = hdr
refn = bib_idx(head, 'energies', nk,/silent)
ecm = DOUBLE(levstr.ev*EE/(HH*CC))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize bulild database flag to true.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
build_db = 1
dbopen, 'atom_lvl'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loop over all energy levels in the atom file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
subsetl = dbfind('atom=' + STRTRIM(STRING(ato), 2) + $
                ',ion=' + STRTRIM(STRING(eion), 2),/silent )

saved=subsetl                   ; required for the atom_cbb deletion'


if(n_elements(subsetl) gt 0 and n_elements(replace) ne 0) then begin

   privold=!priv
   ;print,'Full replacement of database for ', ato, eion
   ;print,'Are you sure? enter .continue if you are...'
   !priv=3
   dbopen,'atom_lvl',1
   ;print,n_elements(subsetl), ' entries deleted from atom_lvl'
   dbdelete,subsetl
   dbclose

   dbopen,'atom_bb',1
   subset = dbfind('atom=' + STRTRIM(STRING(ato), 2) + $
                   ',ion=' + STRTRIM(STRING(eion), 2),/silent )
   ;print,n_elements(subset), ' entries deleted from atom_bb'
   dbdelete,subset
   dbclose

   dbopen,'atom_bf',1
   subset = dbfind('atom=' + STRTRIM(STRING(ato), 2) + $
                   ',ion=' + STRTRIM(STRING(eion), 2),/silent )
   ;print,n_elements(subset), ' entries deleted from atom_bf'
   dbdelete,subset
   dbclose

   dbopen,'atom_cbb',1
   dbhelp,text=text,sort=sort
   ok=n_elements(sort)
   if(ok gt 0) then begin 
      dbext,-1,'entry,col_lab_j,col_lab_i',entry,cj,ci
   ;
   ; get list of collisional values to remove
   ;
   ; saved array contains pointers to energy levels.
   ;
      delete=0
   ;
      for ii=0,n_elements(ci)-1 do begin
         
         k=where(saved eq ci[ii],n) ; 
         if(n ne 0) then  begin 
            d=entry[k]
            delete=[delete,d]
         endif
         
         k=where(saved eq cj[ii],n) ; 
         if(n ne 0) then  begin 
            d=entry[k]
            delete=[delete,d]
         endif
         
      endfor
      if(n_elements(delete) gt 1) then begin 
         delete=delete[1:*]
         delete=delete(uniq(delete))
         ;print,n_elements(delete), ' entries deleted from atom_cbb'
         if(n_elements(delete) gt 1) then begin
            dbdelete,delete[1:*]
         endif
      endif
      dbclose
   endif
   
   !priv=privold
endif
   
subset=subsetl
;
count = 0
jj = where(levstr.ion EQ min(levstr.ion),nsame)
added = 0
skipped = 0
;
; remove atom and ion from label.
;

dbopen,'atom_lvl',1

FOR kk = 0, nsame-1 DO BEGIN
   i = jj(kk)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check if the entry already exists.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   eplus = STRTRIM(STRING(DOUBLE(ecm(i))+0.01, FORMAT = '(f13.3)'), 2)
   eminus = STRTRIM(STRING(DOUBLE(ecm(i))-0.01, FORMAT = '(f13.3)'), 2)
;   str = eminus + '<e<' + eplus + ',g=' + STRTRIM(STRING(g(i)), 2) + $
   str = eminus + '<e<' + eplus +  $
                 ',label=' + levstr(i).label + ',en_bib_ref=' + STRTRIM(STRING(refn(i)), 2)
   ;print,i,'    ',str
   list = dbfind(str,subsetl,/silent)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If the entry does not exist, add it to the
; database.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF((list[0] EQ -1) OR (list[0] EQ 0)) THEN BEGIN
      tmp = levstr(i).label
      lab2int,tmp,j,t,o,coupling
      IF(count EQ 0) THEN BEGIN 
         a1 = ato
         a2 = eion
         a3 = ato-eion+1
         a4 =  ecm(i)
         a5 =  fix(levstr(i).g)
         a6 = levstr(i).coupling
         a7 = levstr(i).glande
         a8 =  levstr(i).label
         a9 = levstr(i).tjp1
         a10 = t(0)
         a11 =  o(0)
         a12 =  t(1)
         a13 =  o(1)
         a13a = t(2)
         a14 =  o(2)
         a15 =  refn(i)
         count = count+1
         added = added+1
      ENDIF ELSE BEGIN 
         a1 = [a1,ato]
         a2 = [a2,eion]
         a3 = [a3,ato-eion+1]
         a4 =  [a4,ecm(i)]
         a5 =  [a5,fix(levstr(i).g)]
         a6 = [a6,levstr(i).coupling]
         a7 = [a7,levstr(i).glande]
         a8 =  [a8,levstr(i).label]
         a9 = [a9,levstr(i).tjp1]
         a10 = [a10,t(0)]
         a11 =  [a11,o(0)]
         a12 =  [a12,t(1)]
         a13 =  [a13,o(1)]
         a13a =  [a13a,t(2)]
         a14 =  [a14,o(2)]
         a15 =  [a15,refn(i)]
         added = added+1
      ENDELSE
   ENDIF ELSE BEGIN
         skipped = skipped+1
   ENDELSE
ENDFOR
IF(count NE 0) THEN BEGIN 
   !priv = 2
   dbopen, 'atom_lvl',1
   a9 = uint(a9)
   a10 = uint(a10)
   a11 = uint(a11)
   a12 = uint(a12)
   a13 = uint(a13)
   a13a = uint(a13a)
   a14 = uint(a14)
   dbbuild, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a13a,a14,a15
ENDIF
messdip,/inf,strn(added)+' levels added, '+strn(skipped)+' skipped'
dbclose
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'lvl2db.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
