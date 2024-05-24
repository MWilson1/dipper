;
;**********************************************************************
;
function ftwo,x,break=break
;+
;  y=ftwo(x)
; new routine 24-jan-1994
; calculates ftwo(x) needed for collisional rates of arnaud and rothenflug 
; if argument x is < break, then use the eqns 5 and 6 of Hummer (1983, jqsrt, 30 281)
; break given by hummer as 4.0
;-
pi=3.141592654d0
a=size(x)
if(a(0) eq 0) then xx=[x] else xx=x
xx = DOUBLE(xx)
f2=xx*0.
;
IF(N_ELEMENTS(break) EQ 0) THEN break=4.0 ; From Hummer 
;
j=where(xx gt break,kount)
k=where(xx le break,kount1)
;
; large argument x > break
;
IF(kount GT 0) THEN BEGIN
   p=[1.d0,2.16577591d+02,2.03358710d+04,1.09106506d+06,3.71139958d+07,$
      8.39632734d+08,1.28891814d+10,1.34485688d+11,9.40017194d+11,$
      4.25707553d+12, 1.17430457d+13,1.75486750d+13,1.08063014d+13,$
      4.97762010d+11]
   q =[1.d0,2.1958d+02,2.0984d+04,1.1517d+06,4.0349d+07,9.4900d+08,1.5345d+10,$
       1.7182d+11,1.3249d+12,6.9071d+12,2.3531d+13,4.9432d+13,5.7760d+13,$
       3.0225d+13,3.3641d+12]
   xi=1./xx(j)
   px = p(0)+xi*(p(1) + xi*(p(2)+ xi*(p(3)+ xi*(p(4)+ xi*(p(5)+ xi*(p(6)+ $
         xi*(p(7)+ xi*(p(8)+ xi*(p(9)+ xi*(p(10)+ xi*(p(11)+ xi*(p(12) $ 
         ))))))))))))
   qx = q(0)+xi*(q(1) + xi*(q(2)+ xi*(q(3)+ xi*(q(4)+ xi*(q(5)+ xi*(q(6)+ $
         xi*(q(7)+ xi*(q(8)+ xi*(q(9)+ xi*(q(10)+ xi*(q(11)+ xi*(q(12)+ $ 
         xi*(q(13))))))))))))))
   f2(j)=xi*xi*px/qx
ENDIF 
;
; small argument x < break
;I
IF(kount1 GT 0) THEN BEGIN
;
;  hummer's equns 5 and 6
;  gmma is euler's constant (abramovicz+stegun)
   gmma=0.5772156649d0
   y = alog(xx(k))+gmma
   ff = xx(k)*0.
   f0arr = ff
   FOR i=0,kount1-1 DO BEGIN
      f0x = pi*pi/12.d0
      sum=0.d0
      term=1.d0
      count=1.d0
      fact=1.0d0
      xfact=-xx(k(i))
      xfact0=xfact
      term = xfact /count/count/fact
      sum=sum+term
      WHILE (abs(term/sum) GT 1.e-8) DO BEGIN
         count=count+1.0d0
         fact = fact*count
         xfact= xfact*xfact0
         term = xfact /count/count/fact
         sum=sum+term
         IF(count GT 100.d0) THEN messdip,'ftwo: too many iterations',/con
      ENDWHILE
      f0arr(i)=f0x+sum
   ENDFOR
   ff=y*y*0.5d0 + f0arr
   f2(k)=ff*exp(x(k))
ENDIF
if(n_elements(x) eq 1) then f2=f2(0)
RETURN,f2
end

