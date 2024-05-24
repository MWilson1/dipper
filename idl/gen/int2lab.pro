;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: int2lab.pro
; Created by:    judge, August 2, 2006
;
; Last Modified: Wed Apr 25 20:01:15 2007 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
PRO int2lab,label,j2p1,term,orb,coupling,idl = idl
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       int2lab
;
; PURPOSE: makes  atomic labels from  integers which 
;          contain quantum numbers   
;
; EXPLANATION:
;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CALLING SEQUENCE: 
;       int2lab,label,j2p1,term,orb,coupling
;
; INPUTS:
;            2JP1           I*2          2J+1
;            TERM           U*2          (2S+1)*100+L*10+P  ISLP (Term), array
;            ORB            U*2          100*n+10*l+nactive INLA (outer
;                                        orbital), array
;            coupling
;       
; OPTIONAL INPUTS: 
;
; OUTPUTS:
;            label         string
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;    /idl  make label with IDL sub and super script commands embedded
; CALLS:
;
; COMMON BLOCKS:
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;
; VERSION:
;-
;
@cdiper
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'int2lab'
   RETURN
ENDIF
;
if (n_params(0) lt 5) then begin
   print,'int2lab,label,j2p1,term,orb,coupling'
  return
endif
;
label = ''
IF(orb(2) ge 100) THEN label = label+nla(orb(2),idl = idl)+' '
;
IF(term(2) NE 0) THEN BEGIN  ; there are 3 terms listed
   label = label+'('+slp(term(2),idl = idl)+') '
   IF(orb(1) GE 100) THEN label = label+nla(orb(1),idl = idl)+' '
   label = label+nla(orb(0),idl = idl)+' '
   label = label+'('+slp(term(1),idl = idl)+') '
ENDIF ELSE BEGIN                ; two or less terms
   IF(orb(1) GE 100) THEN label = label+nla(orb(1),idl = idl)+' '
   if(term(1) NE 0) THEN label = label+'('+slp(term(1),idl = idl)+') '
   label = label+nla(orb(0),idl = idl)+' '   
ENDELSE
;
CASE (coupling) OF
   'LS':label = label+slp(term(0),idl = idl)+' '
   'JJ':BEGIN
      s = term(0)/100
      l = (term(0)-100*s)/10
      par = term(0)-10*l-100*s
      par = strmid('EO',par,1)
      str = '('+gtoj(s,/str)+','+gtoj(l,/str)+')'+par+' '
      label = label+str
   END
   'PAIR':BEGIN
      s = term(0)/100
      l = (term(0)-100*s)/10
      par = term(0)-10*l-100*s
      par = strmid('EO',par,1)
      str = string(s)+'['+gtoj(l,/str)+']'+par+' '
      label = label+str
   END
ENDCASE
jstr = gtoj(j2p1,/str)
IF(n_elements(idl) NE 0) THEN jstr = '!d'+jstr+'!n'
label = strcompress(label+jstr)
;
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'int2lab.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
