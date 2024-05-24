;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: picom.pro
; Created by:    judge, August 2, 2006
;
; Last Modified: Thu Aug  3 12:06:22 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO picom,x,u,mn,mx,rev = rev,power = power
;+
; compress/decompress photoionization data   
;-
IF(n_elements(power) EQ 0) THEN power = 0.5 ; use 1 for linear. 0.5 good for huge ranges (e.g. sigmas).
IF(n_elements(rev) EQ 0) THEN BEGIN 
   y = x^power
   mn = (min(y))
   mx = (max(y))
   u1 = findgen(65535u)*(mx-mn)/65534.+mn
   tabinv,u1,y,u,/fast
   u = uint(round(u))
ENDIF ELSE BEGIN 
   y = mn + (mx-mn)*u/65534.
   x = y^(1./power)
endelse
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'picom.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
