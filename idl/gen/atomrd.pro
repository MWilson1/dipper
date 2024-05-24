;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: atomrd.pro
; Created by:    Phil Judge HAO/NCAR, Boulder CO, November 23, 1994
;
; Last Modified: Wed Aug  9 21:50:22 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO atomrd,file,info=info, nocheck=nocheck, $
   nosort = nosort, nocalc = nocalc, $
   fatal = fatal,ok = ok, indexadd=indexadd,notrfill=notrfill
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       atomrd
;
; PURPOSE: Reads, stores atomic data in ASCII (MULTI) format from file
;          includes collisional data and header information
;
; CATEGORY: HAOS-DIPER input routine
;   
; EXPLANATION:
;       Stores atomic data in structures
;   
;       This form for handling atomic parameters is taken from the program 
;       MULTI  written by Mats Carlsson:
;       "A Computer Program for Solving Multi-Level Non-LTE Radiative
;       Transfer Problems in Moving or Static Atmospheres", Uppsala
;       Astronomical Observatory Report No. 33, 1986. (Contact:
;       mats.carlsson@astro.uio.no) 
;
;       Atomic parameters are stored in common catom as follows:
;       ATOMID : string containing atomic ID (usually just 'HE', 'FE', 'O')
;       ABUND  : real containing abundance relative to hydrogen (Log scale, H=12)
;       AWGT   : atomic mass in atomic units (12C=12.0)
;       NK     : number of levels, continuum levels included
;       NRAD   : number of radiative transitions
;       NLINE  : number of bound-bound transitions
;       NCONT  : number of bound-free transitions i detail
;       LABEL  : e.g., ''N IV 1S2 2S2 1SE 0'' 
;       G      : statistical weight of level
;       EV     : energy in ev  (input in cm-1)
;       F      : for lines   : *absorption* oscillator strength
;                for continua: cross-section at limit
;                the wavelength dependence of the cross-section is
;                assumed to be A=A0*(NY0/NY)**3 if not given explicitly
;       A      : einstein A coefficient
;       B      :          B
;       
;       IRAD(K): lower level for radiative transition k
;       JRAD(K): upper             "
;       ALAMB  : vacuum wavelength in angstrom
;                in printout routines it is printed as either vacuum or air
;                depending on the value (.lt.2000 vacuum, .gt.2000 air)
;       HNY4P  : h*ny/4pi, ny in units of a typical doppler width
;       
; CALLING SEQUENCE: 
;       atomrd,file 
;
; INPUTS:
;       file   name of file containing atomic data
; OPTIONAL INPUTS: 
;       none
;   
; OUTPUTS:
;       Data are stored in common block cdiper (accessed via @cdiper)
;
; OPTIONAL OUTPUTS:
;	head: structure containing header information
;
; KEYWORD PARAMETERS: 
;       /help.      Will call doc_library and list header, and return
;       plot=plot   plot a term diagram
;       info=info   lists header info
;       make=make   make the file if it does not exist with ground + next ion
;                   stage only
;       /nocheck    do not perform simple checks
; CALLS:
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       System variable !REGIME is used to determine if collisional
;       data are to be read and stored in common block.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;   M. Carlsson circa 1988: original coding
;
; MODIFICATION HISTORY:
;   P. Judge 1990-1996 various additions, checks
; VERSION:
;       Version 1.0 February 27, 2006
;       
;-
@cdiper
;
;j=findfile(file)
;IF(j(0) EQ '') THEN BEGIN 
;   messdip,'error- file does not exist in current directory'
;endif    
;headrd,file
;
; strip comment lines from input file- can't use cstrip.pro because
; of quotes needed for free-format fortran string reading.
;
text=''
openr,lu1,/get_lun,file
openw,lu2,/get_lun,'dums.dat'
form = '(a)'

if(n_elements(indexadd) eq 0) then indexadd=0

while not eof(lu1) do begin
  readf,lu1,text
  if (strmid(text,0,1) ne '*') then begin
    k0=strpos(text,"'")
    if (k0 ne -1) then begin
      k1=strpos(text,"'",k0+1)
      k2=strlen(text)
      printf,lu2,strmid(text,0,k0),form = form; text up to label
      printf,lu2,strmid(text,k0+1,k1-k0-1),form = form   ; label
      printf,lu2,strmid(text,k1+1,k2-k1),form = form     ; text after label
    endif else begin
      printf,lu2,text,form = form
    endelse
  endif
endwhile
free_lun,lu1
free_lun,lu2
;
; read the data:
;
str = ''
openr,lu2,'dums.dat',/get
atomid=''
readf,lu2, atomid
atom.atomid=strtrim(atomid,2)
if(n_elements(mq) eq 0) then mq=200
abnd = 0.0 & awgt = 0.0
readf,lu2, abnd,awgt
awgt=awgt
atom.abnd = abnd & atom.awgt = awgt
nk = 0l & nline = 0l & ncont = 0l &  nrfix = 0l
readf,lu2, nk,nline,ncont,nrfix
nrad=nline+ncont

if(nline gt 1000) then print,'Atom is large, this will take time'

atom.nk = nk &  atom.nline = nline &  atom.nrad = nrad 
IF(nrfix NE 0) THEN messdip,'No fixed transitions allowed'
;
; now read the data
;
if(float(nk)*float(nrad>1) gt 1.e5) then begin
  messdip,'This is a big atom- please be patient...',/inf
endif
lab=''
g2 = 0.
ev2 = 0.d0
ion2 = 0
lvl = replicate(lvldef,atom.nk)
for i=0,nk-1 do begin
   readf,lu2, ev2,g2 
   ev2=ev2*cc *hh/ee
   readf,lu2, lab ,form = '(a)'
   lab = strcompress(lab)
   badstr=strpos(lab,'<')
   if (badstr ne -1) then begin
      tmp=lab
      lab = getwrd(tmp,delim='<') + getwrd(tmp,delim='>',/last)
   endif
   lab = strep(lab,'<',' ',/all)
   lab = strep(lab,'>',' ',/all)
   readf,lu2, ion2

   lvl[i].ev = ev2 &  lvl[i].g = g2 &  lvl[i].label = lab & lvl[i].ion = ion2 
   lvl[i].tjp1=fix(g2)

endfor
;
; remove, e.g., 'C III' from labels, if present, and other "trash"
FOR ii = 0,atom.nk-1 DO BEGIN 
   IF(strupcase(getwrd(lvl[ii].label) ) EQ strupcase(atom.atomid)) THEN $
   lvl[ii].label = getwrd(lvl[ii].label,2,30)
   lvl[ii].label = fixlab(lvl[ii].label)
ENDFOR
;
;  bound-bound transitions in detail
;  calculate lambda, a and b
;  if qmax or q0.lt.0 frequency points in doppler units are read
;
KT=0
nrad1 = nrad ; >  1
trn = replicate(trn(0),nrad)
;
IF (nline GT 0) THEN BEGIN
   j = 0 &  i = 0 &  f2 = 0. &  nq2 = 0 &  qmax2 = 0. 
   q02 = 0. &  io2 = 0 &  ga2 = 0. &  gw2 = 0. &  gq2 = 0.
   for KR=0L,NLINE-1 do begin 
      if(kr gt 0 and kr mod 1000 eq 0) then print,'transition ',kr, ' of ',nline-1
      readf,lu2, j,i,f2,nq2,qmax2,q02,io2,ga2,gw2,gq2
      j+=indexadd
      i+=indexadd
      IF(nq2 GT mq) THEN messdip,'INPUT NQ2='+strn(nq2)+$
       '> MQ='+strn(mq)+',  try IDL> @cdiper & mq=<big integer>)'
      dn = i &  up = j
      IF(lvl(j-1).ev LT lvl(i-1).ev) THEN BEGIN 
         dn = j &  up = i
      ENDIF
; subtract 1 from indices.
      i=dn-1
      j=up-1
      trn(kr).f=f2
      trn(kr).nq=nq2 
      trn(kr).qmax=qmax2
      trn(kr).q0=q02
      trn(kr).ga=ga2   
      trn(kr).gw=gw2
      trn(kr).gq=gq2
      IF(trn(KR).QMAX LT 0.0) OR (trn(KR).Q0 LT 0.0) THEN begin
         dum=fltarr(nq2)
         READF,LU2, dum
         trn(kr).q=dum
      ENDIF
      trn(KR).IRAD=I
      trn(KR).JRAD=J
      trn(KR).ALAMB=HCE/(lvl(J).EV-lvl[i].EV)
      trn(KR).A=trn(KR).F*6.6702E15*lvl[i].G/(lvl(J).G*trn(KR).ALAMB*trn(KR).ALAMB)
      trn(KR).BJI=(trn(KR).ALAMB)*(trn(KR).ALAMB)*(trn(KR).ALAMB)*trn(KR).A/HC2
      trn(KR).BIJ=(lvl(J).G/lvl[i].G)*trn(KR).BJI
   endfor
endif

for l=0,atom.nline-1 do begin
   lfu=lifetime(trn[l].jrad,/nowarn)
   lfl=lifetime(trn[l].irad,/nowarn)
   trn[l].ga= 1./lfl + 1./lfu
endfor
;
;
;  bound-free transitions in detail
;  if qmax.lt.0.0 frequency points in angstrom (starting with
;  threshold and decreasing) and crossections in cm2 are read.
;  unit conversion in  routine  freqc
;
IF(!regime EQ 0 AND nrad NE nline) THEN BEGIN 
   messdip,'!regime=0 but BF radiative transitions exist- removing them',/inf
   nrad = nline
   atom.nrad = nline
   trn = trn(0:nline-1)
ENDIF
;
IF (nrad GT nline) THEN BEGIN
  for KR=NLINE,NRAD-1 do begin
   j = 0 &  i = 0 &  f2 = 0. &  nq2 = 0 &  qmax2 = 0. 
    READF,LU2, J,I,f2,nq2,qmax2
    j+=indexadd
    i+=indexadd
    IF(nq2 GT mq) THEN messdip,'INPUT NQ2='+strn(nq2)+$
       '> MQ='+strn(mq)+',  try IDL> @cdiper & mq=<big integer>)'
    up = j > i
    dn = j < i
    i=dn-1
    j=up-1
    trn(KR).F=f2
    trn(kr).alfac(0)=f2
    trn(KR).NQ=nq2
    trn(KR).QMAX=qmax2
    IF(trn(KR).QMAX LT 0.0) THEN begin
      tab=fltarr(2,nq2)
      READF,LU2, tab
      tab=transpose(tab)
      trn(kr).q(0)=hce/(lvl(j).ev-lvl[i].ev)      ; wavelength at edge
      trn(kr).q(1:trn(kr).nq)=tab(*,0)       ; wavelength table
      trn(kr).alfac(1:trn(kr).nq)=tab(*,1)
    ENDIF else begin
      trn(kr).q(0)=hce/(lvl(j).ev-lvl[i].ev)       ; wavelength at edge
    endelse
    trn(kr).irad=i
    trn(kr).jrad=j
    trn(kr).ga=0.
    trn(kr).gw=0.
    trn(kr).gq=0.
    trn(kr).alamb=hce/(lvl(j).ev-lvl[i].ev)
  endfor
endif
;
; get frequencies in continua, quadrature points and weights
;

freqc
;
;  get quantum numbers
;
qn,ok = ok
;
; Perform checks on data
;
;
; check completeness of transition data
;
if(n_elements(notrfill) eq 0) then begin 
   multchk
endif
;
;  get collisional data
;
IF(!regime NE 2) THEN colrd,lu = lu2,indexadd=indexadd
free_lun,lu2
spawn,'rm dums.dat'
;
IF(n_elements(nocheck) EQ 0) THEN dipchk
;
; final thing, sort according to energy and reorder
;
IF(n_elements(nosort) EQ 0) THEN BEGIN 
   atomsort,sortindex = sortindex
   IF(n_elements(ok) NE 0) THEN ok = ok(sortindex)
ENDIF
;
RETURN
END



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'atomrd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
