;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: trndata.pro
; Created by:    Philip Judge, March 1, 2006
;
; Last Modified: Wed Aug  9 21:49:31 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro trndata
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       trndata
;
; PURPOSE: adds transition type, multiplet number and checks radiative transitions
;       
; EXPLANATION:
;
; CALLING SEQUENCE: 
;   trndata
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       none
;
; OUTPUTS:
;       Arrays trn.type and trn.multnum are filled in cdiper common area
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
;       Written March 1, 2006 P. Judge, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;
; VERSION:
;       Version 1.0, March 1, 2006
;-
;
@cdiper
ir = trn.irad
jr = trn.jrad
;
;  check for same levels
;
bad=where(ir eq jr,nbad)
if nbad gt 0 then print,'following transitions have same level', trn[bad].alamb

iterm = nla(lvl(ir).orb(2))+nla(lvl(ir).orb(1))+nla(lvl(ir).orb(0))+$
   slp(lvl(ir).term(2))+slp(lvl(ir).term(1))+slp(lvl(ir).term(0))

jterm = nla(lvl(jr).orb(2))+nla(lvl(jr).orb(1))+nla(lvl(jr).orb(0))+$
   slp(lvl(jr).term(2))+slp(lvl(jr).term(1))+slp(lvl(jr).term(0))

; assume completely forbidden unless selection rules allow
;
trn.type = 'F '
;
; check and set continuum data 
;
IF(atom.nrad LT 1) THEN BEGIN 
   messdip,'no data to be checked',/inf
   return
ENDIF
;
l = indgen(atom.nrad,/long)
cont = where(l GT atom.nline-1,c)
IF(c GT 0) THEN BEGIN 
   trn(cont).type = 'BF'
   FOR kr = atom.nline,atom.nrad-1 DO BEGIN 
      IF(lvl(jr(kr)).ion NE lvl(ir(kr)).ion+1) THEN $
         messdip,'BF transition '+string(kr)+' is not between adjacent ion stages'
   ENDFOR
ENDIF
;
; get  multiplet numbers for lines and continua 
;
trn.multnum = -1
count = 0
FOR kr = 0,atom.nrad-1 DO BEGIN 
   same = WHERE(iterm EQ iterm(kr) AND jterm EQ jterm(kr) AND trn.multnum EQ -1,kount)
   IF(kount GT 0) THEN BEGIN
      trn(same).multnum = count
      count = count+1
   ENDIF
ENDFOR 
;
; check and set line data
;
samec = lvl(jr).coupling EQ lvl(ir).coupling
ls = lvl(ir).coupling EQ 'LS' AND samec
samep = lvl(jr).parity EQ lvl(ir).parity
dtsp1 = abs(lvl(jr).tsp1-lvl(ir).tsp1)
dl = abs(lvl(jr).bigl-lvl(ir).bigl)
suml = lvl(jr).bigl+lvl(ir).bigl
dj = abs(lvl(jr).tjp1-lvl(ir).tjp1)/2.
sumj = lvl(jr).tjp1/2+lvl(ir).tjp1 -1
jzz = (lvl(jr).tjp1 EQ 1) AND (lvl(ir).tjp1 EQ 1)
lzz = (lvl(jr).bigl EQ 0) AND (lvl(ir).bigl EQ 0)
bb = lvl(jr).ion EQ lvl(ir).ion
;
;mult = lvl(jr).tjp1 EQ lvl(jr).tsp1*(2*lvl(jr).bigl+1) AND lvl(jr).tsp1 NE 1 AND $
;   lvl(ir).tjp1 EQ lvl(ir).tsp1*(2*lvl(ir).bigl+1) AND lvl(ir).tsp1 NE 1 
;
; Both levels are LS coupled
;
;   fully allowed, here are the electric dipole selection rules 
;
e1 = where(ls AND (NOT samep) AND (dtsp1 EQ 0) AND (dl LE 1) $
           AND (NOT jzz) AND (NOT lzz) AND (dj LE 1),count)
IF(count GT 0) THEN trn(e1).type = 'E1'
;
; Spin forbidden intercombination transitions, otherwise allowed
;
ic = where(bb AND ls AND (NOT samep) AND (dtsp1 ne 0) AND (dl LE 1) $
           AND (NOT jzz) AND (NOT lzz) AND (dj LE 1),count)
IF(count GT 0) THEN trn(ic).type = 'IC'
;
;   Electric quadrupole selection rules 
;
e2 = where(bb AND ls AND samep AND dtsp1 EQ 0 AND suml GE 2 AND dl LE 2 $
           AND (dj LE 2) AND sumj GE 2,count)
IF(count GT 0) THEN trn(e2).type = 'E2'
;
;   magnetic dipole selection rules 
;
m1 = where(bb AND ls AND samep AND (dtsp1 EQ 0) AND (dl eq 0) AND (NOT jzz) $
           AND (dj LE 1) AND trn.type NE 'E2',count)
IF(count GT 0) THEN trn(m1).type = 'M1'
m1 = where(bb AND ls AND samep AND (dtsp1 EQ 0) AND (dl eq 0) AND (NOT jzz) $
           AND (dj LE 1) AND trn.type EQ 'E2',count)
IF(count GT 0) THEN trn(m1).type = 'M1E2'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Non-LS coupling transitions
;   
; apply parity and J selection rules only
;
e1 = where(bb AND (NOT ls) AND (NOT samep) AND (NOT jzz) AND (dj LE 1),count)
IF(count GT 0) THEN trn(e1).type = 'E1'
return
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'trndata.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
