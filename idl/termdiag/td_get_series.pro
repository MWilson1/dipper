;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_get_series.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Thu Aug 10 21:49:39 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td_get_series, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_get_series
;
; PURPOSE: calculates, sets series variables for use with term diagram procedures
;       
; EXPLANATION:
;               gets arrays TERM, CONFIG from the individual
;               levels which are assumed to be in LABEL.  ICONFIG and ITERM
;               contain the index of each term and array.
;  New version using quantum numbers, common blocks September 11, 1996
;       
; CALLING SEQUENCE: 
;       td_get_series
;
; INPUTS:
;       none.
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       some variables are set in common termdiag
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
;       cdiper, ctermdiag
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
;       Written September 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, September 5, 1996
;-
;
@cdiper
@ctermdiag   
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_get_series'
   RETURN
ENDIF
config=lvl.label
term=lvl.label
iconfig=intarr(atom.nk)
iterm=iconfig
iseries=iconfig
;
; for LABEL= 'O I 2P4 3PE 2'
; then adopt 'O I 2P4' as the underlying configuration and '3PE' as the term.
; or
; for LABEL= 'O I 2P4 3PE' then also adopt 'O I 2P4' as the underlying
; configuration and '3PE' as the term.
;
iconfig(0)=0
iterm(0)=0
nconfig=1
nterm=1
nseries=1
FOR ii=0,atom.nk-1 DO BEGIN
   term(ii) = labtd(ii,/parent,/conf,/term,/txt)
   config(ii) = labtd(ii,/parent,/conf,/txt)
;
;
; get the indices ICONFIG and ITERM labelling which config and term the
; level belongs to:
;
   FOR jj=0,ii-1 DO BEGIN
      IF(config(ii) EQ config(jj))THEN GOTO, same_config
   ENDFOR
; new config:
   iconfig(ii)= nconfig
   nconfig=nconfig+1
   GOTO, term
same_config:
   iconfig(ii)=iconfig(jj)
term:
   FOR jj=0,ii-1 DO BEGIN
      IF(term(ii) EQ term(jj))THEN GOTO, same_term
   ENDFOR
; new term:
   iterm(ii)= nterm
   nterm=nterm+1
   GOTO, series
same_term:
   iterm(ii)=iterm(jj)
;
;  look for terms with the same series in the configuration.
;  for example,
;  O I 2P3 3S 3SO 1
;  O I 2P3 4S 3SO 1
;  then these will be plotted on the same X-value because
;  the last word of the configurations:
;          3S
;          4S
; are the same in their last character (in this case 'S')
;
series:
   conf=config(ii)
   str2 = getwrd(conf,loc = loc,/last)
   str1 = strmid(conf,0,loc-1)
;   getlwrd,conf,str1,str2
   str2=STRTRIM(str2)
   lenst2=STRLEN(str2)
   str4=STRMID(str2,lenst2-1,1)
   FOR jj=0,ii-1 DO BEGIN
      conf=config(jj)
      str3 = getwrd(conf,loc = loc,/last)
      str0 = strmid(conf,0,loc-1)
;      getlwrd,conf,str0,str3
      IF(str0 EQ str1)THEN BEGIN
         str3=STRTRIM(str3)
         lenst3=STRLEN(str3)
         str5=STRMID(str3,lenst3-1,1)
         IF(str4 EQ str5) THEN GOTO,same_series
      ENDIF
   ENDFOR
   iseries(ii)= nseries
   nseries=nseries+1
   GOTO, end_loop
same_series:
   iseries(ii)=iseries(jj)
end_loop:
ENDFOR

RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_get_series.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
