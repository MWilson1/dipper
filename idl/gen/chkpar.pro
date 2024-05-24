;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: chkpar.pro
; Created by:    Philip Judge, February 28, 2006
;
; Last Modified: Wed Aug  9 21:19:57 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO chkpar,par,name,limits,operator,warnonly = warnonly
;   
; check that a given parameter lies between two limits   
; if upper is set < lower, then 
inf = 1
IF(n_elements(warnonly) EQ 0) THEN inf = 0
w = ''
;IF(inf) THEN w = 'warning: '
form = '(e9.2)'
CASE (operator) OF
   '<': IF (par GE limits(0))THEN messdip,w+name +' is ge '+strn(limits(0),form = form),inf = inf
   'le': IF (par GT limits(0))THEN messdip,w+name +' is > '+strn(limits(0),form = form),inf = inf
   ':': IF (par LT limits(0) OR par GT limits(1) )THEN messdip,w+$
      name +' is outside range '+strn(limits(0),form = form) +' - '+strn(limits(1),form = form),inf = inf
   '>': IF (par lE limits(0))THEN messdip,w+name +' is le '+strn(limits(0),form = form),inf = inf
   'ge': IF (par lt limits(0))THEN messdip,w+name +' is < '+strn(limits(0),form = form),inf = inf
   'belongs': BEGIN
      FOR i = 0,n_elements(limits)-1 DO BEGIN
         IF(par EQ limits(i)) THEN GOTO, ok
      ENDFOR
      messdip,w+name+ ' does not belong to required group',inf = inf
      ok:
   end
   '=':IF(par NE limits(0))THEN messdip,w+name+ ' ne '+strn(limits(0),form = form),inf = inf
   ELSE: messdip,'operator '+ operator+ ' not known'
ENDCASE
;
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'chkpar.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
