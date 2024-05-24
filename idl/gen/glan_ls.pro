;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: glan_ls.pro
; Created by:    Philip Judge, September 16, 1998
;
; Last Modified: Mon Feb 27 16:00:26 2006 by judge (Philip Judge) on niwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION glan_ls,S,L,J
;
; Lande g-factor for LS coupling for term ^(2S+1)L_J
;  S= spin ang mom qn     
;  L= orbital ang mom qn   
;  J=total ang mom qn
ns = n_elements(s)
nl = n_elements(l)
nj = n_elements(j)
IF(nj NE ns OR nl NE ns)THEN messdip,'S,L,J must have the same dimensions'
IF(ns EQ 0) THEN BEGIN
   s = [s] 
   j = [j]
   l = [l]
ENDIF
g = s*0.
nok = where(j EQ 0 OR s EQ 0 ,cn)
ok = where(j NE 0 AND s ne 0,c)
IF(cn NE 0) THEN g(nok) = 1.
;
gs = 2.000*1.0011596389d0
ss = s*(s+1.)
ll = l*(l+1.)
jj = j*(j+1.)
IF(c NE 0) THEN g(ok) = ( jj(ok)+ll(ok)-ss(ok) + gs* (jj(ok)-ll(ok)+ss(ok)))/2./jj(ok)
IF(ns EQ 0) THEN return,g(0) ELSE return,g
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'glan_ls.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
