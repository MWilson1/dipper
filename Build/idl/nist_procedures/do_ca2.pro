;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: dothem.pro
; Created by:    Philip Judge, February 19, 2006
;
; Last Modified: Mon Aug  7 12:15:26 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
@cdiper
!regime = 2
atoms = atomn([6,7,8,10,11,12,13,14,15,16,17,18,20,22,24,25,26,28])
;atoms = atomn([13,14])
atoms = atomn([20]);
;loop over elements
;
FOR j = 0,n_elements(atoms)-1 DO BEGIN 
   atomid = atoms(j)
   xx = abmass(atomid)
   abnd = xx(0) & awgt = xx(1)
   atom.abnd = abnd &  atom.awgt = awgt
   file = strlowcase('nistgf.'+atomid+'2')
   print,'doing ',file
   openr,lu,file,/get
   skips = ['OBSERVED','WAVELENGTH','AIR','------','QUERY']
   ns = n_elements(skips)
   f = 0.
   energ = 0.d0
   g = f
   label = ''
   fa = label
   indxu = 0
   indxl = 0
;
   ion = 2
   WHILE NOT eof(lu) DO BEGIN
      str = ''
      upper = '' &  lower = ''
      lowc = '' &  uppc = ''
      lowt = '' &  uppt = ''
      lowj = '' &  uppj = ''
      lablow = '' &  labupp = ''
      readf,lu,str
      str = strupcase(str)
      FOR i = 0,ns-1 DO BEGIN 
         IF(strpos(str,skips(i)) GE 0) THEN GOTO,skip
      ENDFOR
      IF(strpos(str,'.') LE 0) THEN GOTO,skip
;
      str = strep(str,'*','O',/all)
; oscillator strength
      Einsta = getwrd(str,3,delim = '|') 
      fabs = getwrd(str,4,delim = '|') 
      facc = getwrd(str,5,delim = '|') 
;      print,fabs,' ',facc
; level energies
      dum = getwrd(str,6,delim = '|') 
      lower = getwrd(dum,0,delim = '-')
      upper = getwrd(dum,1,delim = '-')
      lower = strep(lower,'[','',/all)
      lower = strep(lower,']','',/all)
      upper = strep(upper,'[','',/all)
      upper = strep(upper,']','',/all)
;      print,upper,lower
; configurations
      dum = getwrd(str,7,delim = '|') 
      dum = strep(dum,'.','',/all)
      lowc = getwrd(dum,0,delim = '-')
      uppc = getwrd(dum,1,delim = '-')
; terms
      dum = getwrd(str,8,delim = '|') 
      lowt = getwrd(dum,0,delim = '-')
      uppt = getwrd(dum,1,delim = '-')
      uppt = getwrd(uppt,/last) ; remove e.g. a from "a 4DE"
      uppt = strcompress(uppt,/rem)
      lowt = getwrd(lowt,/last)
      lowt = strcompress(lowt,/rem)
;
; single character terms present but not allowed
      IF(strlen(uppt) LE 1) THEN GOTO,skip
      IF(strlen(lowt) LE 1) THEN GOTO,skip
; Fe I problematic levels
      IF(uppt EQ '3P2' OR lowt EQ '3P2') THEN GOTO, skip
      IF(uppt EQ '3F2' OR lowt EQ '3F2') THEN GOTO, skip
      IF(uppt EQ '1D2' OR lowt EQ '1D2') THEN GOTO, skip
      IF(uppt EQ '1G2' OR lowt EQ '1G2') THEN GOTO, skip
;      
;
; parity
      IF(strpos(uppt,'E') LT 0 AND strpos(uppt,'O') LT 0 ) THEN uppt = uppt+'E' ; even parity
      IF(strpos(lowt,'E') LT 0 AND strpos(lowt,'O') LT 0 ) THEN lowt = lowt+'E' ; even parity
; J values
      dum = getwrd(str,9,delim = '|') 
      lowj = getwrd(dum,0,delim = '-')
      uppj = getwrd(dum,1,delim = '-')
;      
; things to skip:     
;
; 1. missing term designation      
      IF(strcompress(lowt,/rem) EQ '' OR strcompress(uppt,/rem) EQ '' OR $
         strcompress(lowt,/rem) EQ 'O' OR strcompress(uppt,/rem) EQ 'O') THEN BEGIN 
;         message,/inf,' skipping '+uppt+' - '+lowt
         GOTO, skip
      endif
;
; 2. missing configurations
;
      IF(strcompress(lowc,/rem) EQ '' OR strcompress(uppc,/rem) EQ '' OR $
         strcompress(lowc,/rem) EQ 'O' OR strcompress(uppc,/rem) EQ 'O') THEN BEGIN 
;         message,/inf,' skipping '+uppc+' - '+lowc
         GOTO,skip
      endif
;
; 3. missing j values
;
      IF(strcompress(lowj,/rem) EQ '' OR strcompress(uppj,/rem) EQ '' OR $
         strcompress(lowj,/rem) EQ 'O' OR strcompress(uppj,/rem) EQ 'O') THEN BEGIN 
;         message,/inf,' skipping '+uppj+' - '+lowj
         GOTO, skip
      endif
; labels      
      lablow = strcompress(lowc+' '+lowt+' '+lowj)
      labupp = strcompress(uppc+' '+uppt+' '+uppj)
      IF(strpos(lablow,'?') GE 0 OR strpos(lablow,'N') ge 0) THEN GOTO,skip
      IF(strpos(labupp,'?') GE 0  OR strpos(labupp,'N') ge 0) THEN GOTO,skip
;      
;
; remove redundant < > data from labels
;       
      strem,lablow,'<','>'
      strem,labupp,'<','>'
;
; match up
;      
      pgjmatch,lablow,label,l,newl
      IF(newl) THEN BEGIN 
         label = [label,lablow]
         g = [g,jtog(lowj)]
         energ = [energ,double(lower)]
;         print,lablow
;         print,label
;         str1 = '' &  read,str1
      ENDIF
      pgjmatch,labupp,label,u,newu
      IF(newu) THEN BEGIN 
         label = [label,labupp]
         g = [g,jtog(uppj)]
         energ = [energ,double(upper)]
;         print,labupp
;         print,label
;         str1 = '' &  read,str1
      ENDIF
;
; transition data
;
      indxu = [indxu,u]
      indxl = [indxl,l]
; transition type
      dum = strcompress(getwrd(str,11,delim = '|'))
      IF(dum ne '') THEN BEGIN 
         alam =  1.d8/(double(upper)-double(lower))
         fabs = float(einsta)/(6.671e15*g(l)/g(u)/alam/alam)
      ENDIF
      f = [f,float(fabs)]
      fa = [fa,facc]
      skip:
   ENDWHILE
   free_lun,lu
; level data
   label = label(1:*) &  g = g(1:*) &  energ = energ(1:*)
;   more,label
   indx = indgen(n_elements(energ))
   ev = energ*(hh*cc)/ee
   nk = n_elements(ev)
   ion = intarr(nk)*0+ion
   nline = n_elements(f) &  nrad = 0
   label = strcompress(atomid+' '+roman(ion)+' '+label)
   lvl = replicate(lvldef,nk)
   lvl.label = label
   lvl.ev = ev
   lvl.g = g
   lvl.ion = ion
   atom.atomid = atomid
   atom.nk = nk
   

; transition data
   indxu = indxu(1:*) & indxl = indxl(1:*) & f = f(1:*) &  fa = fa(1:*)
   irad = indxl &  jrad = indxu
   qmax = 30.+0.*f
   q0 = 5.0+0.*f
   nq = 30+0*irad
   nrad = n_elements(f) &  nline = nrad &  ncont = nrad-nline
   atom.nline = nline &  atom.nrad = nline
   trn = replicate(trndef(0),atom.nrad)
;   acalc
;   gacalc
   trn.irad = irad-1 &  trn.jrad = jrad-1
   iwide = irad*0+1
   nrfix = 0
   ga = 0.*iwide
   gw = ga*0.
   gq = gw
   trn.f = f
   trn.nq = nq
   trn.q0 = q0
   trn.qmax = qmax
   de = (lvl(trn.jrad).ev - lvl(trn.irad).ev)
   w = hh*1.e8*cc/ee/de
   trn.alamb = w
;   colstrt,coldata
;   colnew = coldata
;   impact,coldata,colnew,phimin = 0.05
;   gencom,colnew
   atomsort
;   atomsort,/wsort
   atomwr,'atom.'+strlowcase(atomid)+'2'
endfor
END
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'dothem.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
