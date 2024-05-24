;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: colchk.pro
; Created by:    Philip Judge, March 3, 2006
;
; Last Modified: Thu Aug 10 12:54:23 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO colchk
;   
;
@cdiper   
IF(!regime eq 2) THEN return
bad = 0
nk = atom.nk
badlabel = ''
FOR i = 0l,nk-1 DO BEGIN 
   si = strn(i)
   ok = where(col.ihi EQ i OR col.ilo EQ i,count)
   IF(count EQ 0) THEN BEGIN 
      bad = bad+1
      badlabel = [badlabel,lvl(i).label]
   ENDIF
ENDFOR
bits,!approx,bit
IF(bad NE 0 AND bit(0) EQ 0) THEN BEGIN 
   messdip,'collisional coefficients are missing for '+string(bad)+' levels:',/inf
   FOR ibad = 1,n_elements(badlabel)-1  DO messdip,badlabel(ibad),/inf
   messdip,'can''t continue- try diper,approx=1+... '
ENDIF

IF(bad NE 0 AND bit(0) ne 0) THEN messdip,'COLCHK: adding approximate collisional data',/inf
;
;  some data are certainly missing. Let''s try to fill them
;
IF(bit(0) EQ 0) THEN GOTO, skip
impact,phimin = 0.5
;
;  Van Regemorter for B-B E1 transitions
;
vreg
;
;  smaller for B-B forbidden
;
new = col(0)
temp0 = 3.3+FINDGEN(7)*0.3
FOR kr = 0,atom.nline-1 DO BEGIN 
   ir = trn(kr).irad
   jr = trn(kr).jrad
   ej = lvl(jr).ev
   ei = lvl(ir).ev
   IF(ei GT ej) THEN BEGIN 
      ir = trn(kr).jrad
      jr = trn(kr).irad
   ENDIF
   ty = trn(kr).type
   z = lvl(ir).ion
   k = where(col.ihi EQ jr and col.ilo EQ ir,count)
   IF(trn(kr).type NE 'E1' AND count eq 0) THEN BEGIN 
      new.ihi = jr &  new.ilo = ir
      new.approx = 1
      new.temp=(10.^temp0)*z*z               ; 
      new.nt = n_elements(temp0)
      str = 'F='+STRTRIM(STRING(trn(kr).f,form = '(e9.2)'),2)+$
         ', LAM= '+STRTRIM(STRING(trn(kr).alamb),2)
      new.key='OHM    : GUESS of .1/Z^2 FOR NON-E1 TRANSITIONS '+str
      omega = .1/z/z
      new.data = new.temp*0.+omega
      col = [col,new]
   endif
ENDFOR
;
; fully forbidden transitions, make 10x smaller than above forbidden transitions
;
;FOR i = 0l,nk-1 DO BEGIN 
;   si = strn(i)
;   ok = where(col.ihi EQ i OR col.ilo EQ i,count)
;   k = where(lvl.ion EQ lvl(i).ion,nion)
;   IF(count EQ 0) THEN BEGIN 
;      FOR j = 0l,nk-1 DO begin 
;         IF(j EQ i OR lvl(j).ion NE lvl(i).ion) THEN GOTO, skip
;         new.key = 'OHM'
;         new.nt = 2
;         new.temp = [1.e-2,1.e2]*1.e4*z*z
;         omega = 0.01/nion/z/z
;         new.data = [0,0]+omega
;         new.ihi = j &  new.ilo = i
;         new.approx = 1
;      col = [col,new]
;      skip:
;   ENDFOR
;   ENDIF
;ENDFOR
;
;  Bound-free collisions
;
skip:
;fixbfcol
return
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'colchk.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
