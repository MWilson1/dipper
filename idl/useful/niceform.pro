;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: niceform.pro
; Created by:    Dr Phil Judge, June 9, 2000
;
; Last Modified: Fri Jun  9 17:34:50 2000 by judge (Dr Phil Judge) on hestia.maths.monash.edu.au
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION niceform,data,form = FORM,exponent = exponent

IF(n_elements(form) EQ 0) THEN form = '(E9.2)'
a = size(data)
nice = string(data)
IF(a(0) EQ 0) THEN nice = [nice]
Nr = n_elements(data)
extra = ''
;
;
; 
IF(n_elements(exponent) EQ 0) THEN begin 
   IF(strpos(strlowcase(form),'e') GE 0) THEN extra = ')'
   FOR i = 0,nr-1 DO BEGIN 
      nice(i) = string(data(i),form = form)+extra
      nice(i) = strep(nice(i),'E+0','(')
      nice(i) = strep(nice(i),'E-0','(-')
      nice(i) = strep(nice(i),'(0)','')
   ENDFOR
ENDIF ELSE BEGIN
   FOR i = 0,nr-1 DO BEGIN 
      nice(i) = string(data(i),form = form)+extra
      nice(i) = strep(nice(i),'E+0','$^{+') +'}$
      nice(i) = strep(nice(i),'E-0','$^{-')
      nice(i) = strep(nice(i),'(0)','{}')
   ENDFOR
ENDELSE

 
return,strcompress(nice,/remove)
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'niceform.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
