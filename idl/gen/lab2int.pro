;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: lab2int.pro
; Created by:    Philip G. Judge, June 5, 1996
;
; Last Modified: Wed Apr 25 19:36:48 2007 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO lab2int,label,j2p1,term,orb,coupling,ok = ok
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       lab2int
;
; PURPOSE: encodes atomic labels into integers which 
;          contain quantum numbers   
;
; EXPLANATION:
;       this works simply by looking for specific characters and words in the
;       string variable  label.  
;   
;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;   For LS coupling the label is usually of the form:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;       
;       ... 3P4 (3P) 3D  4DE 7/2'    
;           ___ ____ __  ___ [_]
;       1   n-4 n-3  n-2 n-1  n
;       where the underlined regions are treated as "words"
;       Word:
;       anything else other than closed sub-shells/shells     
;       n-4               parent's outermost orbital
;       n-3               (if present, with "(" or ")")  parent term
;       n-2               outermost orbital 
;       n-1               TERM
;       n                 J 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;       For jj coupling (non equivalent electrons) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;
;       3S2 3P (2PO) 6P (1/2,3/2)E 1
;       ___ __ _____ __ _________ [_]
;       ...             n-1        n 
;       here, the j=1/2 2PO term of Si II and j=3/2 of the 6p electron 
;       (contained in the (1/2,3/2) string) are coupled to give a 
;       total ang mom J=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;       For pair coupling   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;   
;       2S2 2P (2PO) 4F 2[5/2]E 3
;       ___ __ _____ __ _______ [_]
;        ...            n-1      n 
;       here, the J1=5/2 level of the (2PO) term of C II couples with a
;       4f electron (s2=1/2) to produce J=3.  This is encoded in the string 
;       (2*s2+1)[J1]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;   Lastly, the label can also take the form:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;
;      3P6 3D6 (3F) 4S 4P (3PO) 3FO 4
;      in which the two ``parent'' terms (3F) (3PO)in Fe I couple 
;      to form the final 3FO term. This type of coupling is common 
;      in the iron group.
;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CALLING SEQUENCE: 
;       lab2int,j2p1,term,orb,coupling,ok=ok
;
; INPUTS:
;            label         input string
;       
; OPTIONAL INPUTS: 
;
; OUTPUTS:
;            2JP1           I*2          2J+1
;            TERM           U*2          (2S+1)*100+L*10+P  ISLP (Term), array
;            ORB            U*2          100*n+10*l+nactive INLA (outer
;                                        orbital), array
;            coupling
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;  ok=ok  set to 1 if ok, 0 if not
; CALLS:
;
; COMMON BLOCKS:
;       None.
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
;       Original coding Mats Carlsson circa 1988
;
; MODIFICATION HISTORY:
;       Modified for June 5, 1996, by Philip G. Judge, use of getwrd
; VERSION:
;       Version 1, June 5, 1996
;       version 2, February 22, 2006, includes jj and pair coupling schemes
;-
;
@cdiper
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'lab2int'
   RETURN
ENDIF
;
if (n_params(0) lt 5) then begin
   print,'lab2int,'
  return
endif
;
;  define useful and output variables
;
digits='0123456789'
spec = designations
coupling = 'LS'
;
; work backwards from the end of the label, and assign all
; numbers along the way...
;
lab = fixlab(label)
term = 0u
orb = term*0
word = 'word'
ind = 0
labcnv,lab,/rev ; get standard not db format
;
; find J value
;
word = STRUPCASE(getwrd(lab,ind,/last))
;
;  can only contain numerals and "/"
;  therefore identify if it is bad
str='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
l=strlen(word)
count=0
for i=0,l-1 do begin
   k=strpos(strmid(word,i,1),str)
   if(k gt -1) then count+=1 
endfor
if(count ne 0) then begin
   j2p1 = 'bad'
   print,'lab2int: bad j value ', word, ' : ',lab
endif
bad: 
;
; special case of last but one word:
;
word = STRUPCASE(getwrd(lab,-1,/last))
;
; Find out if "term" contains "(" or ")", if so, it is jj coupling
;
IF(strpos(word,'(') GE 0 OR strpos(word,')') GE 0) THEN coupling = 'JJ'
;
; case of pair coupling
;
i = strpos(lab,'[')
IF(i(0) GE 0) THEN coupling = 'PAIR'
;
; Different coupling cases 
;
ok1 = 1
CASE (coupling) OF
   'LS': BEGIN 
      term = [term,labcode(word,'T',ok = ok)]
      ok1 = ok < ok1
   END
   'PAIR':BEGIN
      par = 0
      IF(strpos(word,'O') GE 0) THEN par = 1
      multip= getwrd(getwrd(word,del = '['))
      L = getwrd(getwrd(word,1,del = '['),del = ']')
      L = fix((jtog(l)))
      IF(l GT 9) THEN BEGIN 
         messdip,'L>9 for '+word,/inf
         ok1 = 0
      ENDIF
      new = 100*fix(multip)+10*L+par
      term = [term,new]
   END
   'JJ':BEGIN 
      par = 0
      IF(strpos(word,'O') GE 0) THEN par = 1
      str1 = strep(word,'(','')
      str1 = strep(str1,')','')
      str1 = getwrd(str1)
      L=getwrd(str1,1,del = ',')
      L = fix((jtog(l)))
      IF(l GT 9) THEN BEGIN 
         messdip,'L>9 for '+word,/inf
         ok1 = 0
      ENDIF
      multip=getwrd(str1,0,del = ',')
      multip = fix(jtog(multip))
      term = [term,100*multip+10*L+par]
   END
ENDCASE
;
; Now loop over all other words
;

ind = -2
word = 'word'
WHILE(word NE '') DO BEGIN 
   word = STRUPCASE(getwrd(lab,ind,/last))
   IF(word EQ '') THEN BEGIN
      xtra=getwrd(lab,-1,/last)
      orb=[orb,xtra]  ; read next word if blank
      GOTO, skip
   ENDIF
   type = wtype(word)
   CASE (type) OF
      'T': BEGIN
         word = strep(word,'(',' ')
         word = strep(word,')',' ')
         islp = labcode(word,type,ok = ok)
         term = [term,islp]
         ok1 = ok < ok1
      END
      'O': BEGIN
         inla = labcode(word,type,ok = ok)
         orb = [orb,inla]
         ok1 = ok < ok1
      END
   ENDCASE
   skipit:
   ind = ind-1
ENDWHILE
skip:
ok = ok1
orb = uint(orb(1:*))
term = uint(term(1:*))
; make arrays of size 3
t = uintarr(3) &  o = uintarr(3)
mxt = n_elements(term) <  3
mxo = n_elements(orb) <  3
FOR ii = 0,mxt-1 DO t(ii) = term(ii)
FOR ii = 0,mxo-1 DO o(ii) = orb(ii)
term = t
orb = o
;
; Having collected all data, now "fix" the parent parities 
; by examining the orbital parameters. This assumes closed shells
; beneath. 
;
IF(term(1) NE 0) THEN BEGIN 
   p3 = parit(orb(2))
   p2 = parit(orb(1))
   p1 = parit(orb(0))
   p = (p2+p3) MOD 2
   IF(term(2) NE 0) THEN p = p1+p2
   s = term(1)/100
   l = (term(1)-s*100)/10
   pp = term(1)-s*100-l*10
   term(1) = 100*s+10*l+p
END
IF(term(2) NE 0) THEN BEGIN 
   p3 = parit(orb(2))
   p = (p3) MOD 2
   s = term(2)/100
   l = (term(2)-s*100)/10
   pp = term(2)-s*100-l*10
   term(2) = 100*s+10*l+p
END
;
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'lab2int.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
