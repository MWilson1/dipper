;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: dipchk.pro
; Created by:    Philip Judge, February 27, 2006
;
; Last Modified: Wed Aug 16 10:08:08 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO dipchk
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       dipchk
;
; PURPOSE: checks data stored in cdiper common block
;
; EXPLANATION:
;       Checks data in the structures atom,lvl,trn,col for
;       "reasonable" values.  If "unreasonable", then a messdip is
;       issued and the execution stopped.
;
; CALLING SEQUENCE: 
;       dipchk
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, February 28, 2006
;-
;
@cdiper
status=0
var = ''
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Quantitative checks on the data.
;
j=atomn(getwrd(atom.atomid))
chkpar,j,'atomic number ', [1,92],':'
chkpar,atom.abnd,'atom.abnd',[-12,12],':' 
chkpar,atom.awgt,'atom.awgt',[1,235],':'
chkpar,atom.nk,'atom.nk',1,'ge'
chkpar,atom.nrad,'atom.nrad',0,'ge'
IF(atom.nrad lt 0) THEN  messdip,'nrad ='+strn(atom.nrad)
IF(atom.nrad gt 0) THEN  BEGIN 
   chkpar,atom.nline,'atom.nline',0,'ge'
   chkpar,atom.nrad-atom.nline,'ncont',0,'ge'
ENDIF
;
;  ***** CHECK ENERGIES, DEGENERACY, LABEL, ION, PARITY, J *****
;
for i=0,atom.nk-1 do begin
   IF(atomn(atom.atomid)-lvl(i).ion LT 0) THEN GOTO,SKIP ; bare nuclei, skip
   ii = '('+strtrim(string(i),2)+')'
   chkpar,lvl(i).ev,'lvl'+ii+'.ev',0.0,'ge'
   chkpar,lvl(i).ev/lvl(i).ion/lvl(i).ion,'eV/ion^2', 100.0,'<' 
   chkpar,lvl(i).g, 'lvl'+ii+'.g', 1.,'ge'
   chkpar,lvl(i).coupling,'lvl'+ii+'.coupling',['LS','JJ','PAIR'],'belongs'
;
;  ***** CHECK FOR DUPLICATE LEVELS WITH Very similar EV  *****
;
   dup = where(lvl.ion EQ lvl[i].ion AND strtrim(lvl.label) EQ strtrim(lvl[i].label) AND $
               lvl.g EQ lvl[i].g and lvl.ev gt (lvl[i].ev-0.001) and lvl.ev lt (lvl[i].ev+0.001) )

   IF(n_elements(dup) gt 1) THEN BEGIN 
      print,'WARNING duplicate levels ', dup
      print,lvl[i]
      print,lvl[dup[1:*]]
      str = string(dup,form = '(10(I6))')
   endif
;
;  ***** CHECK quantum numbers *****
   
;
   chkpar,lvl(i).n,'lvl'+ii+'.n',1,'ge'
   chkpar,lvl(i).eff,'lvl'+ii+'.eff',-1.,'ge' ; eff is -1 if no upper ion stage exists
   qdefect = lvl(i).n-lvl(i).eff
   k = where(lvl.ion EQ lvl(i).ion)
   minn = min(lvl(k).n)
   sdef = string(qdefect,form = '(f5.2)')
   IF(i NE atom.nk-1 AND lvl(i).eff NE 0. AND (lvl(i).n-minn) GT 1) THEN $
      chkpar,qdefect,'quantum defect '+ii+' = '+sdef,[-1.,2],':',/warn
   chkpar,lvl(i).active,'lvl'+ii+'.active',1,'ge'
   chkpar,lvl(i).tsp1,'lvl'+ii+'.tsp1',1,'ge'
   chkpar,lvl(i).bigl,'lvl'+ii+'.bigl',0,'ge'
   chkpar,lvl(i).parity,'lvl'+ii+'.parity',['E','O'],'belongs'
   chkpar,lvl(i).tjp1,'lvl'+ii+'.tjp1',0,'ge'
   chkpar,lvl(i).meta,'lvl'+ii+'.meta',[0,1],'belongs'
   skip:
ENDFOR
;
; transitions
;
IF(atom.nrad EQ 0) THEN GOTO,skip2
same = WHERE(trn.irad EQ trn.jrad,bad)
IF(bad NE 0) THEN messdip,'transition(s) have the same upper and lower levels: '+ strn(same)
;
; check that BF transitions and BB transitions are in the correct places
;
ir = trn.irad &  jr = trn.jrad
l = lindgen(atom.nrad)
bf = where(l GT atom.nline-1,c)
IF(c GT 0) THEN BEGIN 
   FOR kr = atom.nline,atom.nrad-1 DO BEGIN 
      IF(lvl(jr(kr)).ion NE lvl(ir(kr)).ion+1) THEN $
         messdip,'BF transition '+string(kr)+' is not between adjacent ion stages'
   ENDFOR
ENDIF
bb = where(l GT atom.nline-1,c)
IF(c GT 0) THEN BEGIN 
   FOR kr = 0,atom.nline-1 DO BEGIN 
      IF(lvl(jr(kr)).ion NE lvl(ir(kr)).ion) THEN $
         messdip,'BB transition '+string(kr)+' is between different ion stages'
   ENDFOR
ENDIF
;
; check some parameters- oscillator strengths (if OK then so are A, B).
; these are rough estimates of magnitudes expected. 
;
done = ir*0
nj = lvl(trn.jrad).n
ni = lvl(trn.irad).n
dn = nj-ni
nj = float(nj) &  ni =  float(ni)
;
counte2c = 0
FOR kr = 0,atom.nrad-1 DO BEGIN
   krout = '('+strn(kr)+')'
   j = trn(kr).jrad
   i = trn(kr).irad
   sout = '('+strn(j)+','+strn(i)+')'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; E1 delta n=0 
;   
   IF(dn(kr) EQ 0 AND trn(kr).type EQ 'E1') then begin 
      scl = 1./lvl(trn(kr).irad).ion
      sf = string(trn(kr).f*scl,format = '(e9.2)')
      chkpar,trn(kr).f*scl,trn(kr).type+' trn'+krout+'.f/Z ='+sf,[.1e-4,2.],':',/warn
   ENDIF 
;
;E1 delta n ne 0 E1
;
   IF(dn(kr) NE 0 AND trn(kr).type EQ 'E1') then begin 
; Cowan (14.99) typical value
      aj = float(nj(kr)) &  ai = float(ni(kr))
      xx = (1./ai/ai-1./aj/aj)
       hydrogenic = abs(1.96/aj/aj/aj/ai/ai/ai/ai/ai/xx/xx/xx)
      sf = string(trn(kr).f,format = '(e9.2)')
      chkpar,trn(kr).f,trn(kr).type+' trn'+krout+'.f ='+sf,[.1e-4,10.]*hydrogenic,':',/warn
   ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M1
;   
   IF(trn(kr).type EQ 'M1') then begin 
; M1 matrix element is comparable to that for neutrals so f is on the
; order of (alpha/2)^2 f (permitted) in dn=0 E1 transitions
;  use 8th power of core charge - very rough indeed (see comments p 444 Cowan)
      scl = alphafs*alphafs/4.   
      zscl = float(lvl(i).ion)^8.
      sf = string(trn(kr).f*scl,format = '(e9.2)')
      chkpar,trn(kr).f/zscl,trn(kr).type+' trn'+krout+'.f/Z^8 ='+sf,[.5e-4,5.]*scl,':',/warn
   ENDIF 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; E2 delta n=0 
;   
   IF(dn(kr) EQ 0 AND trn(kr).type EQ 'E2') then begin 
      wcm = trn(kr).alamb*1.e-8
      scl = pi*a0*pi*a0/5/wcm/wcm
      zscl = 1./lvl(i).ion
      sf = string(trn(kr).f*zscl,format = '(e9.2)')
      chkpar,trn(kr).f*zscl,trn(kr).type+' trn'+krout+'.f/Z ='+sf,[1.e-4,1.]*scl,':',/warn
   ENDIF 
;
;E2 delta n ne 0 E2
;
   IF(dn(kr) NE 0 AND trn(kr).type EQ 'E2' AND counte2c EQ 0) then begin 
;      messdip,/inf,'E2 transitions w/ delta n ne 0 not checked'
      counte2c = counte2c+1
   ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDFOR
;
; continua
;
FOR kr = atom.nline,atom.nrad-1 DO BEGIN 
   krout = '('+strn(kr)+')'
   j = trn(kr).jrad &  i =  trn(kr).irad
;
; duplicate transitions for BF, not allowed (OK for BF). 
;
   k = where(trn.jrad EQ j AND trn.irad EQ i,count)
   IF(count GT 1) THEN messdip,'repeated BF transitions '+strn(k)
   nnq = trn(kr).nq
   avsig = total(trn(kr).alfac(1:nnq))/nnq
   sa = string(avsig,format = '(e9.2)')
   scl = 7.906e-18 *lvl(i).n/lvl(i).ion/lvl(i).ion ; Allen 1973 p 96
   chkpar,avsig,trn(kr).type+' trn'+krout+'.alfac ='+sa,[1.e-3,100.]*scl,':',/warn
ENDFOR
;
skip2:
;
; Collisions
;
colchk
;
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'dipchk.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
