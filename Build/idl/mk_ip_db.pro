;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: mk_ip_db.pro
; Created by:    Randy &, HAO/NCAR, Boulder, CO, January 8, 1997
;
; Last Modified: Sat Jul 29 18:21:10 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO mk_ip_db, help=help
@cdiper
IF(N_PARAMS() NE 0) THEN BEGIN
  PRINT, ''
  PRINT, 'Usage:  mk_ip_db'
  PRINT, ''
  RETURN
ENDIF
;
!priv=2
dbcreate,'atom_ip',1,1


file = concat_dir(getenv('DIPER'),'data') ; use ssw multi-platform way.
file = concat_dir(file,'moore.ip')
OPENR, in, /get,file
;
text = ''
ip_units = 'eV'
bib = 'Moore C.E.; NSRDS-NBS 34; 1972'
bib1 = 'Sugar J. and Corliss C.; 1985 J. Phys. Chem. Ref. Data 14; suppl. 2.'
;
!priv = 2
dbopen, 'atom_bib', 1
jbib = dbfind('bib_ref='+bib, /silent)
IF((jbib(0) EQ 0) OR (jbib(0) EQ -1)) THEN dbbuild, bib
dbopen, 'atom_bib', 1
jbib1 = dbfind('bib_ref='+bib1, /silent)
IF((jbib1(0) EQ 0) OR (jbib1(0) EQ -1)) THEN dbbuild, bib1
dbclose
;
dbopen, 'atom_bib'
jbib = dbfind('bib_ref='+bib, /silent)
jbib1 = dbfind('bib_ref='+bib1, /silent)
dbclose
jbib = FIX(jbib(0))
jbib1 = FIX(jbib1(0))
;
;
;
a1 = 0
a2 = 0
a3 = 0.d0
a4 = 0
a5 = ''
btime = sdptime()
;
FOR i = 0, 4 DO READF, in, text
nd = 0
readf,in,nd
nd = 28
;
FOR i = 1, nd DO BEGIN
   READF, in, text
   iparr = dblarr(i)
   READF, in, iparr
   atom = i
   FOR j = 0, i-1 DO BEGIN
      ion = j+1
      jb = jbib
      IF(ion GE 16) THEN jb = jbib1
      ip = iparr(j)
      a1 = [a1,atom]
      a2 = [a2,ion]
      a3 = [a3,ip]
      a4 = [a4,jb]
      a5 = [a5,btime]
   ENDFOR
ENDFOR
CLOSE, in
;
a1 = a1(1:*) &  a2 = a2(1:*) &  a3 = a3(1:*) & a4 = a4(1:*) & a5 = a5(1:*) 
;
dbopen, 'atom_ip', 1
dbbuild, a1,a2,a3,a4
dbclose
!priv = 0
FREE_LUN, in
RETURN

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'mk_ip_db.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

