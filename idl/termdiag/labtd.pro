;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: labtd.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, September 11, 1996
;
; Last Modified: Thu Aug 10 22:04:04 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION labtd,i,parent=parent,conf=conf,term=term,$ 
                    level=level,tex=tex,txt=txt,full=full,help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:	
;       labtd()
;
; PURPOSE: gives a nice label string from quantum numbers for level i
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = labtd(i)
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       None.
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
;       Written September 11, 1996, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, September 11, 1996
;-
;
@cdiper
if(n_elements(help) gt 0) then begin
  doc_library,'labtd'
  return,-999
endif
IF(i LT 0 OR i GT atom.nk-1) THEN BEGIN 
   messdip,'i='+strn(i)+', must be in range 0 to '+strn(atom.nk-1),/inf
   messdip,'execution stopped'
ENDIF
;
;
ltex = N_ELEMENTS(tex) NE 0
ltxt = N_ELEMENTS(txt) NE 0
IF(ltxt AND ltex) THEN messdip,'you can''t have BOTH /tex and /txt'
lc = n_elements(conf) ne 0
lterm = n_elements(term) ne 0
ll = N_ELEMENTS(level) NE 0
lp = N_ELEMENTS(parent) NE 0
prefix = ''
str = ''
IF(lc+ll+lp+lterm EQ 0) THEN full = 1
IF(N_ELEMENTS(full) NE 0) THEN BEGIN
   lc = 1
   lterm = 1
   ll = 1
   lp = 1
   prefix = getwrd(atomid,0,0)+' '+roman(ion(i))+' '
ENDIF
;
; angular momentum notation, and strings from all quantum numbers
; 
specl = designations 
nstr = STRTRIM(STRING(lvl(i).n),2)
astr = ''
IF(lvl(i).active GT 1) THEN astr = STRTRIM(STRING(lvl(i).active),2)
bigstr = strmid(specl,lvl(i).bigl,1)
smallstr = strlowcase(strmid(specl,lvl(i).smalll,1))
strtsp1 = STRTRIM(STRING(lvl(i).tsp1),2)
jstr = gtoj(lvl(i).tjp1,/str)
spar = STRLOWCASE(lvl(i).parity)
IF(spar EQ 'e') THEN spar = ''
parstr = ''
;
;  return IDL form, 
;
up = '!U'
norm = '!N'
down = '!D'
space = ' '
bang=''

;
; text form only
;
IF(ltxt) THEN BEGIN
   up = ''
   norm = ''
   down = ''
   bang=''
ENDIF
;
; tex form
;
IF(ltex) THEN BEGIN
   up = '^{'
   norm = '}'
   down = '_{'
   space = '\ '
   bang='\!'
ENDIF
;
sspar = 'eo'
IF lvl(i).term(1) EQ 0 THEN parnt = '' ELSE parnt = nla(lvl(i).term(1))
IF(parnt NE '') THEN BEGIN
                                ;
   im = lvl(i).term(1)/100
   multip = strtrim(string(im),2)
   L = (lvl(i).term(1)-multip*100)/10
   ipar = lvl(i).term(1)-100*im-10*L
   L = strmid(designations,L,1)
   parity = strmid(sspar,ipar,1)
   parstr = '('+up+multip+norm+bang+L+up+parity+norm+')' 
ENDIF   
;
;
;
IF(lp) THEN str = str+parstr
IF(lc) THEN str = str+nstr+smallstr+up+astr+norm+space
IF(lterm) THEN str = str+up+strtsp1+norm+bang+bigstr+up+spar+norm
IF(ll) THEN str = str+down+jstr+norm
;stop
;
; all done
;
RETURN,STRtrim(prefix+str,2)
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'labtd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
