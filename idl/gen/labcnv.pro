;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: labcnv.pro
; Created by:    judge, June 14, 2006
;
; Last Modified: Thu Jul 27 19:15:46 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO labcnv,label,reverse = reverse
@cdiper
;
used = 0
IF(n_elements(label) EQ 0) THEN BEGIN 
   label = lvl.label                  ; use diper common lvl structure
   used = 1
ENDIF
   
;
IF(n_elements(reverse) NE 0) THEN BEGIN
   FOR k = 0,n_elements(label)-1 DO BEGIN 
      label(k) = strep(label(k),'+',',',/all) ; JJ coupling, remove comma
      label(k) = strep(label(k),'\','/',/all) ; see dbfparse, can't use /
      label(k) = strep(label(k),'{','(',/all)
      label(k) = strep(label(k),'}',')',/all)
      label(k) = strep(label(k),'|','[',/all)
      label(k) = strep(label(k),'!',']',/all)
   ENDFOR
ENDIF ELSE BEGIN 
   FOR k = 0,n_elements(label)-1 DO BEGIN 
      label(k) = strep(label(k),',','+',/all) ; JJ coupling, remove comma
      label(k) = strep(label(k),'/','\',/all) ; see dbfparse, can't use /
      label(k) = strep(label(k),'(','{',/all)
      label(k) = strep(label(k),')','}',/all)
      label(k) = strep(label(k),'[','|',/all)
      label(k) = strep(label(k),']','!',/all)
   ENDFOR
endelse
IF(used) THEN lvl.label = label
return
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'labcnv.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
