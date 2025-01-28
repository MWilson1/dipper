;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: ions2zdbase.pro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
@cdiper
dipdef
!priv=2
dbcreate, 'atom_bb', 1, 1, /external
dbcreate, 'atom_cbb', 1, 1, /external
dbcreate, 'atom_lvl', 1, 1, /external;
dbcreate, 'atom_bib', 1, 1, /external;
;
;  backup current zdbase directory
;
ddir = getenv('DIPER')
spawn,' tar cf '+ddir+'/zdbase.tar '+ddir+'/zdbase' 
print, "' tar cf '+ddir+'/zdbase.tar '+ddir+'/zdbase' "
diper,reg = 2 ; no collisional data 
;
;   All elements up to Z=30
;
z=30
n = 1+indgen(z)
names = strlowcase(atomn(n))
;
pwd = concat_dir(getenv('PYDIPER'),'Build')
iondir = concat_dir(pwd,'Ions')
fil = concat_dir(pwd,'/levels_removed.txt')
openw,lu,/get,fil
;
;  neutral atoms, no collisional data
;
j = 1
FOR i = 0,n_elements(names)-1 DO BEGIN 
   fil = 'atom.'+names(i)+strtrim(string(j),2)
   fil = concat_dir(iondir,fil)
   file = findfile(fil)
   IF file NE '' THEN BEGIN
      print,'doing ',fil
      atomrd,file,/nocheck,ok = ok
      k = where(hdr.key EQ 'ENERGIES' OR hdr.key EQ 'GFS-REF',c)
      hdr(k).text = 'NIST levels'
      bad = where(ok EQ 0,nbad)
      IF(nbad GT 0) THEN BEGIN
         FOR ib = 0,nbad-1 DO BEGIN
            ibad = bad(ib)
            printf,lu,atom.atomid,' ',lvl(ibad).ion,' ',lvl(ibad).label
         endfor
         level,del = bad
      ENDIF
      atom2db
   ENDIF ELSE BEGIN 
      print,'skipping ',fil
   ENDELSE
ENDFOR
;
;  ions
;
diper,reg = 0,app = 0
;
; loop over ions, with collisional data
;
FOR i = n_elements(names)-1,0,-1 DO BEGIN 
   FOR j = 2,n(i) DO BEGIN 
      fil = 'atom.'+names(i)+strtrim(string(j),2)
      fil = concat_dir(iondir,fil)
      file = findfile(fil)
      IF file NE ''  THEN BEGIN
         print,'doing ',fil
         atomrd,file,/nocheck,ok = ok
         bad = where(ok EQ 0,nbad)
         IF(nbad GT 0) THEN BEGIN
            FOR ib = 0,nbad-1 DO BEGIN
               ibad = bad(ib)
               printf,lu,atom.atomid,' ',lvl(ibad).ion,' ',lvl(ibad).label
               print,atom.atomid,' ',lvl(ibad).ion,' ',lvl(ibad).label
            endfor
            level,del = bad
         ENDIF
         atom2db
      ENDIF ELSE BEGIN 
         print,'skipping ',fil
      ENDELSE
   ENDFOR
ENDFOR
free_lun,lu
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'ions2zdbase.pro'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
