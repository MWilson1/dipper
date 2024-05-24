;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: parit.pro
; Created by:    judge, July 31, 2006
;
; Last Modified: Mon Jul 31 11:36:58 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION parit,nla
;
;+
; returns the parity of a given orbital specified by integer nla
;-
n = nla/100
l = (nla-n*100)/10
a = nla-n*100-l*10
IF(a MOD 2) EQ 0 THEN return,0  ; even number of electrons
;
; odd number
;
IF(l MOD 2) EQ 1 THEN return,1
END
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'parit.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
