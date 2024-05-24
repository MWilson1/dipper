;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: level.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 21, 1994
;
; Last Modified: Fri Aug 25 11:53:47 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro level,list = list, delete = delete, add = add,$
          eunit = eunit,ionzero = ionzero,_extra=_extra
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       level
;
; PURPOSE: lists, deletes, adds, checks levels
;       
; EXPLANATION:
;
; CALLING SEQUENCE: 
;   level,list = list, delete = delete,list = list, add = add,eunit=eunit
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       list = list
;       delete = delete 
;       add = add
;       eunit=eunit
;       ionzero=ionzero  set energies to those for each ionization stage
;                        instead of those relative to lowest level   
; OUTPUTS:
;       Modified atomic data in common block cdiper
;
; OPTIONAL OUTPUTS:
;
; KEYWORD PARAMETERS: 
;       
; CALLS:
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       
; SIDE EFFECTS:
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written 21-Jan-1993 P. Judge, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1.0, February 27, 2006
;-
;
@cdiper
;
nlist = n_elements(list)
ndelete = n_elements(delete)
nadd = n_elements(add)
;
IF(nlist+ndelete+nadd EQ 0) THEN BEGIN ; list all levels for no input
   list = lindgen(atom.nk) 
   nlist = atom.nk
ENDIF
IF(nadd NE 0) THEN messdip,' /add keyword not included yet'
IF(ndelete NE 0) THEN BEGIN 

   FOR j = 0,ndelete-1 DO BEGIN 
      i = delete(j)

      IF(i LT 0 OR i GT atom.nk-1) THEN BEGIN
         messdip,'Index of level ='+strn(i)+', out of range [0,'+strn(atom.nk-1)+']'
      ENDIF
;
      n = lindgen(atom.nk)
      ok = where(n NE i)
      lvl = lvl(ok)
      atom.nk = atom.nk-1
;
      ok = where(trn.irad ne i,c)
      IF(c NE 0) THEN trn = trn(ok)
      ok = where(trn.jrad ne i,c)
      IF(c NE 0) THEN trn = trn(ok)
;
      k = where(trn.irad GT i,c) &  IF(c NE 0) then  trn(k).irad = trn(k).irad-1
      k = where(trn.jrad GT i,c) &  IF(c NE 0) then  trn(k).jrad = trn(k).jrad-1
;
      atom.nrad = n_elements(trn)
      k = where(lvl(trn.irad).ion EQ lvl(trn.jrad).ion,c)
      atom.nline = c
;
      IF(!regime NE 2) THEN BEGIN 
         ok = where(col.ilo ne i, c)
         IF(c NE 0) THEN col = col(ok)
         ok = where(col.ihi NE i,c)
         IF(c NE 0) THEN col = col(ok)
         k = where(col.ilo GT i,c) &  IF(c NE 0) then  col(k).ilo = col(k).ilo-1
         k = where(col.ihi GT i,c) &  IF(c NE 0) then  col(k).ihi = col(k).ihi-1

      ENDIF
;
;  take care of original delete array
;
      higher = WHERE(delete GT i,c)
      IF(c GT 0) THEN delete(higher) = delete(higher)-1
   ENDFOR
   qn                           ; reset qn's
   trndata                      ; reset values of transition parameters
ENDIF
;
; energy unit
; 
IF(n_elements(eunit) NE 0) THEN BEGIN
   eok = strlowcase(['cm-1','erg','eV','Rydberg'])
   FOR ii = 0,n_elements(eok)-1 DO BEGIN
      IF(strlowcase(eunit) EQ eok(ii)) THEN GOTO, oke
   ENDFOR
   messdip,'eunit is: '+eunit+', but it must be one of:   '+strn(eok)
ENDIF ELSE BEGIN
   eunit = 'cm-1'
ENDELSE
oke:
;
; list the levels:
;
seunit = '                           '
seunit = eunit+seunit
seunit = strmid(seunit,0,7)
CASE (strlowcase(eunit)) OF
   'rydberg':efact = ee/rydinf
   'cm-1':efact = ee/hh/cc
   'erg:':efact = ee
   'ev': efact = 1.d0
ENDCASE
mn = min(lvl.ion) &  mx = max(lvl.ion)
str = '                         Level data for '$
   +atom.atomid+' '+roman(mn)+'-'+roman(mx)
str = [str,'Level       Label                  G        '+seunit+ $
   ' ION n N l 2S+1 L P 2J+1 Coupl.  Lifetime   Glande']
FOR j = 0,nlist-1 DO BEGIN 
   k = list[j]
   continue = 1
   ltim = lifetime(k,/nowarn)
   IF(ltim EQ 0.) THEN sl = ' Infinity' ELSE sl = STRING(ltim,form = '(e9.2)')
   smlab = lvl(k).label
   labcnv,smlab,/rev
   ezero = 0.
   smlab = getwrd(smlab,-4,10,/last)
   IF(n_elements(ionzero) NE 0) THEN BEGIN 
      same = where(lvl(k).ion EQ lvl.ion)
      ezero = min(lvl(same).ev)*efact
   ENDIF
   str1 = string(k,smlab, lvl(k).g, lvl(k).eV*efact-ezero, lvl(k).ion,$
                 lvl(k).n,lvl(k).active,lvl(k).smalll,lvl(k).tsp1,$
                 lvl(k).bigl,lvl(k).parity,$
; orig                  lvl(k).tjp1, lvl(k).coupling,sl, strmid(lvl(k).ref,0,25),$
                 lvl(k).tjp1, lvl(k).coupling,sl, lvl[k].glande,$
                 form = '(I4,1x,a26,1x,f5.1,1x,f12.3,1x,i3,1x'+$
                 ',3(I2),1x,I2,2x,I2,1x,A,1x,I2,1x,a4,5x,a,2x,e10.3)')
   str = [str,str1]


ENDFOR

lvl.ev -=lvl[0].ev
IF(nlist GT 0) THEN for i=0,n_elements(str)-1 do print,str[i]
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'level.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
