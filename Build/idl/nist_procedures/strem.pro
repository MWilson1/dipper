;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: strem.pro
; Created by:    judge, February 22, 2006
;
; Last Modified: Wed Feb 22 11:51:00 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO strem,str,a,b
pp = strpos(str,a)
WHILE(pp GE 0) DO BEGIN 
   first = strmid(str,0,pp)
   qq = strpos(str,b)
   second = strmid(str,qq+1,100+qq)
   str = first+second
   pp = strpos(str,a)
ENDWHILE
return
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'strem.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
