;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: wtype.pro
; Created by:    judge, July 27, 2006
;
; Last Modified: Sat Jul 29 17:50:05 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION wtype,str
;
;
; returns type of a word in an atomic label.
;    
sup = strupcase(str)
type = 'O'                  ; it's an orbital, e.g. '2s2'
k = strpos(sup,')')
IF(k GE 0) THEN type = 'T'     ; a term '(2PO)'
k = strpos(sup,'(')
IF(k GE 0) THEN type = 'T'     ; a term '(2PO)'
k = strpos(sup,'E')
IF(k GE 0) THEN type = 'T'     ; a term '(3PE)'
k = strpos(sup,'O')
IF(k GE 0) THEN type = 'T'     ; a term '(2PO)'
return, type
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'wtype.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
