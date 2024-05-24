def nla,inla,n,l,a,idl = idl
""" takes a number encoded as integer nla and decodes it into
    principal QN n, orbital ang mom l, and number of electrons a
    for example 301  is 3s^1 orbital
"""
    
    n = jnla/100
    l = (jnla-n*100)/10
    a = (jnla-n*100 -l*10)
;
    strl = strmid(const.designations,l,1)
    sa = string(a)
    one = where(a EQ 1,k)
    IF(k GT 0) THEN sa(one) = ''
    IF(n_elements(idl) NE 0) THEN BEGIN 
   sa = '!u'+sa+'!n'
   strl = strlowcase(strl)
ENDIF
;
str = strcompress(string(n)+strl+sa,/remove_all)
IF(n_elements(jnla) EQ 1) THEN return,str(0) ELSE return,str
return,str
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'nla.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
