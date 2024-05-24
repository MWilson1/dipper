;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: findlvs.pro
; Created by:    Philip Judge, March 21, 2006
;
; Last Modified: Fri Aug  4 18:15:37 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO findlvs,lambda,tol = tol
@cdiper   
;+
; finds levels corresponding to a given wavelength and tolerance,
; subject to parity changes and the Delta-J <=1, Sum J >=1 rules.   
;-   
l = lambda
airtovac,l
ev = hh*cc/(l/1.e8)/ee
IF(n_elements(tol) EQ 0) THEN tol = 1.e-6
form = '(5x,i5,1x,a35,1x,f11.5,1x,f5.2)'
form1 = '("Matched lambda ",f12.3,1x,"Fractional error ",e9.2," Geff =",f6.2)'
print,' Search for lambda =',lambda,' Angstrom'
FOR i = 1,atom.nk-1 DO BEGIN
   FOR j = 0,i-1 DO BEGIN 
      de = abs(lvl(j).ev-lvl(i).ev) 
      frerr = abs((de-ev)/ev) 
      jj = (lvl(j).g-1.)/2.
      ji = (lvl(i).g-1.)/2.
      dj = abs(jj-ji)
      sj = jj+ji
      parch = lvl(j).parity NE lvl(i).parity
      IF(frerr LT tol AND dj LE 1 AND sj GE 1 AND parch) THEN BEGIN 
         wnear = (hh*cc*1.e8)/(de*ee)
         vactoair,wnear
         gef = geff(lvl(i),lvl(j))
         print,wnear,frerr,gef,form = form1
         print,i,lvl(i).label,lvl(i).ev,lvl(i).glande,form = form
         print,j,lvl(j).label,lvl(j).ev,lvl(j).glande,form = form
      ENDIF
   ENDFOR
ENDFOR
;
return
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'findlvs.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
