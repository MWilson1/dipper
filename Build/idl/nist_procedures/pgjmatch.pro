;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: match.pro
; Created by:    Philip Judge, February 19, 2006
;
; Last Modified: Sun Jul 30 14:31:25 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO pgjmatch,newlab,label,indx,new
new = 0
FOR i = 0,n_elements(label)-1 DO BEGIN 
   IF(newlab eq label(i)) THEN BEGIN
      indx = i
      return
   ENDIF
ENDFOR
new = 1
indx = n_elements(label)
;print,newlab
;print,label
;print,indx
;stop
return
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'match.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
