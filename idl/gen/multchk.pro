;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: multchk.pro
; Created by:    Philip G. Judge, May 8, 1996
;
; Last Modified: Fri Apr 13 14:29:11 2007 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO multchk
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       multchk
;
; PURPOSE: checks if multiplets are complete
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       multchk
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
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
;       
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, March 6, 2006
;-
;
@cdiper
IF(atom.nrad EQ 0) THEN RETURN
kr = lindgen(atom.nrad)
m = trn.multnum
mx = max(trn.multnum)
term = nla(lvl.orb(2))+nla(lvl.orb(1))+slp(lvl.term(1))+$
          nla(lvl.orb(0))+slp(lvl.term(0))
misstrn = trndef
;
labcnv,/rev
FOR im=0, mx DO BEGIN
   k = where(m EQ im,nmiss)
   tr = kr(k) ; indices of lines belonging to multiplet
   if(im mod 500 eq 0) then begin 
                                ;print,'finding complete
                                ;multiplets... ',im,' out of ',mx
   endif
;
; first transition can be used
;
   use = tr(0)
   type = trn(use).type
   upper = where(term EQ term(trn(use).jrad)) 
   lower = where(term EQ term(trn(use).irad))
   FOR j = 0,n_elements(upper)-1 DO BEGIN 
      u = upper(j)
      FOR i = 0,n_elements(lower)-1 DO BEGIN 
         l = lower(i)
         IF(u EQ l) THEN GOTO, skip
         str = strcompress(lvl(u).label+'-'+lvl(l).label)
;
; now compute transitions allowed by dipole sel rules
; for lines (E1, M1) and continua   
;
         sum = lvl(u).g+lvl(l).g
         dif = abs(lvl(u).g-lvl(l).g)
         k = where(trn.jrad EQ u AND trn.irad EQ l,count)
         IF(count GT 0) THEN GOTO,skip
         signal = 0b
         CASE (type) OF
            'E1': signal =  sum gt 2 and dif le 2
            'IC': signal =  sum gt 2 and dif le 2
            'M1': signal =  sum gt 2 and dif le 2
            'E2': signal =  sum gt 4 and dif le 4
            'M1E2': signal = sum gt 4 and dif le 4
            'BF': BEGIN
               gu =  lvl(u).g*2  ; for outgoing electron
               sum = gu+lvl(l).g
               dif = abs(gu-lvl(l).g)
               signal = sum gt 2 and dif le 2
            end
            ELSE:
         ENDCASE
         IF(signal) THEN BEGIN 
;            messdip,/inf,'missing '+type+' trans. '+str
            new = trndef
            new.type = type
            new.irad = l
            new.jrad = u
            new.ref = 'Missing transition'
            new.f = 0.
            de = abs(lvl(u).ev-lvl(l).ev)
            new.alamb = hh*cc*1.e8/(ee*de)
            new.multnum = trn(use).multnum
            misstrn = [misstrn,new]
         endif
         skip:
      ENDFOR
   ENDFOR
ENDFOR
IF(n_elements(misstrn) GT 1) THEN BEGIN 
   misstrn = misstrn(1:*)
   nn = n_elements(misstrn) &  sn = strcompress(string(nn))
   mm = n_elements(trn) &  sm = strcompress(string(mm+nn))
   messdip,/inf,sn+' of '+sm+' transitions are MISSING, according to the selection rules'
   messdip,/inf,'... These are stored in the structure    misstrn'
ENDIF
labcnv
;
RETURN 
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'multchk.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

