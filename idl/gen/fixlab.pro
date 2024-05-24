;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: fixlab.pro
; Created by:    judge, July 28, 2006
;
; Last Modified: Fri Aug  4 11:49:48 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION fixlab,lab
;   
; gets configuration properly
;
@cdiper
l = strupcase(lab)
k = strpos(l,'(')
IF(k GT 0) THEN    l = strmid(l,0,k)+' '+strmid(l,k,100)
k = strpos(l,')')
IF(k GT 0) THEN    l = strmid(l,0,k+1)+' '+strmid(l,k+1,100)
w1 = getwrd(l)
w2 = getwrd(l,1)
w3 = getwrd(l,2,100)
s = designations
ls = strlen(s)
wout = ''
FOR iw = 0,1 DO BEGIN 
   w = w1
   IF(iw EQ 1) THEN w = w2
   IF(wtype(w) EQ 'T') THEN BEGIN 
      wout = wout+' '+w
      GOTO, next
   ENDIF
;
; find positions of spectral spd...
;
   ln = strlen(w)
   pos = -1
   FOR i = 0,ln-1 DO BEGIN 
      char = strmid(w,i,1)
      FOR j = 0,ls-1 DO BEGIN
         schar = strmid(s,j,1)
         IF(char EQ schar) THEN pos = [pos,i]
      ENDFOR
   ENDFOR
   pos = pos(1:*)
   n = n_elements(pos)
   IF(n LE 1) THEN BEGIN 
      wout = wout+' '+w
      GOTO, next
   ENDIF
;
; place spaces in correct places...
;
   d = pos(1)-pos(0)
   bl=1
   IF(d EQ 2) THEN bl = 2
   IF(d GE 3) THEN bl = 3
   IF(strmid(w,pos(0)+1,1) EQ '1') THEN bl = bl-1
   bl = bl
   w = strmid(w,0,bl)+' '+strmid(w,bl,strlen(w)-bl+1)
   wout = wout+' '+w
next:
ENDFOR

l = wout + ' '+ w3
;
; fix up odd occurrences 
;
l = str_replace(l,'(',' (')
l = str_replace(l,')',') ')
l = str_replace(l,'(A ','(')
l = str_replace(l,'(B ','(')
l = str_replace(l,'(C ','(')
l = str_replace(l,'(D ','(')
l = str_replace(l,'(E ','(')
l = str_replace(l,'(F ','(')
l = str_replace(l,'(G ','(')
l = str_replace(l,'(H ','(')
l = str_replace(l,'(I ','(')
l = str_replace(l,'(J ','(')
l = str_replace(l,'(K ','(')
l = str_replace(l,'(I ','(')
l = str_replace(l,'(L ','(')
l = str_replace(l,'(M ','(')
l = str_replace(l,'(N ','(')
l = str_replace(l,'(O ','(')
l = str_replace(l,'(P ','(')
l = str_replace(l,'(Q ','(')
l = str_replace(l,'(R ','(')
l = str_replace(l,'(T ','(')
l = str_replace(l,'(U ','(')
l = str_replace(l,'(V ','(')
l = str_replace(l,'(W ','(')
l = str_replace(l,'(X ','(')
l = str_replace(l,'(Y ','(')
l = str_replace(l,'(Z ','(')
l = str_replace(l,'(0)','')
l = str_replace(l,'(1)','')
l = str_replace(l,'(2)','')
l = str_replace(l,'(3)','')
l = str_replace(l,'(4)','')
l = str_replace(l,'(5)','')
l = str_replace(l,'(6)','')
l = str_replace(l,'(7)','')
l = str_replace(l,'(8)','')
l = str_replace(l,'(9)','')
l = strcompress(l)
return,l
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'fixlab.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
