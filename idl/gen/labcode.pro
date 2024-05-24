;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: labcode.pro
; Created by:    judge, July 27, 2006
;
; Last Modified: Tue Aug  1 18:04:44 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION labcode,str,type,rev = rev,ok = ok
;
; returns a numeric code corresponding to str, e.g. 
;     2PO (2*100+10*1+1=211) type='T', a term
;     3d7 (3*100+10*2+7=327) type='O', an orbital
;
@cdiper
ok = 0
j = 0u
;
spec = designations
utype = strupcase(type)
ustr = strupcase(str)
ustr = strep(ustr,'(','',/all)
ustr = strep(ustr,')','',/all)
par = 0
ln = strlen(ustr)
;
FOR i = 0,ln-1 DO BEGIN
   k = strpos(spec,strmid(ustr,i,1))
   IF(k GE 0) THEN GOTO, ok1
ENDFOR
messdip,'cannot decode'+str
ok1:
p = i ; position of any of spdf...
;
pen = strmid(ustr,ln-2,1)
rest = strmid(ustr,0,p)
ok = 1
CASE (type) OF
   'T': BEGIN
      IF(strpos(ustr,'O') GE 0) THEN par = 1
      l = strpos(spec,strmid(ustr,p,1))
      tsp1 = fix(rest)
      j = 100*tsp1+10*l+par
   END
   'O': BEGIN
      l = strpos(spec,strmid(ustr,p,1))
      a = fix(strmid(ustr,i+1,ln-p-1)) >  1
      IF(a GT 9) THEN OK = 0
      n = fix(strmid(ustr,0,p))
      j = 100*n+10*l+a
   END
ENDCASE
;
return,j
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'labcode.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
