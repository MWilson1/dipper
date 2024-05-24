;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_write.pro
; Created by:    Philip G. Judge, May 7, 1996
;
; Last Modified: Sun Jun  4 13:29:13 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td_read, file, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_read
;
; PURPOSE: reads parameters of term diagram plots from file written by td_write
;       
; EXPLANATION:
;       termdiag will, by default, almost certainly NOT produce a desired plot
;       style.  With td_read and td_write you can output to a file the plotted
;       parameters and easily manually adjust the figure as desired.
;
; CALLING SEQUENCE: 
;       td_read, filen
;
; INPUTS:
;       file  name of file to be written
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
;       Original version my Mats Carlsson
;
; MODIFICATION HISTORY:
;       modified May 7, 1996, by Philip G. Judge, header added.
; VERSION:
;       Version 1, May 7, 1996
;-
;
@cdiper
@ctermdiag
messdip,'NOT READY'
if (n_params(0) eq 0) then begin
   file=''
   READ,'file name?',file
ENDIF

messdip,'Reading files '+file+' and '+file+'_td.idlsave',/inf
OPENR,lu,file,/get_lun
OPENW,lu2,'dums',/get_lun
text=''
WHILE (NOT EOF(lu)) DO BEGIN
   READF,lu,text
   IF (STRMID(text,0,1) NE '*') THEN PRINTF,lu2,text
ENDWHILE
FREE_LUN,lu2
FREE_LUN,lu
OPENR,lu,'dums',/get_lun

nk=0
nline=0L
ncnt=0
nrfix=0
atomid = ''

restore,file+'_td.idlsave'

READF,lu,atomid
READF,lu,nk,nline,ncnt,nrfix
nrad=nline+ncnt
ev=fltarr(nk)
evplot=fltarr(nk)
ion=intarr(nk)
low_fine = ion
positions=fltarr(nk)
term_label=STRARR(nk)

tab=fltarr(6)
FOR i=0,nk-1 DO BEGIN
   READF,lu,tab
   low_fine(i)=tab(1)-1
   ev(i)=tab(2)
   evplot(i)=tab(3)
   ion(i)=tab(4)+0.1
   positions(i)=tab(5)
   READF,lu,text
   term_label(i)=text
ENDFOR

IF (nrad NE 0) THEN BEGIN
   jrad=intarr(nrad)
   irad=intarr(nrad)
   alamb=fltarr(nrad)
   jdx=intarr(nrad)
   idx=intarr(nrad)
   tab=fltarr(6)
   whichtrans = indgen(nrad,/long)
   FOR kr=0,nrad-1 DO BEGIN
      READF,lu,tab
      jrad(kr)=tab(1)+0.1
      irad(kr)=tab(2)+0.1
      alamb(kr)=tab(3)
      jdx(kr)=tab(4)+0.1
      idx(kr)=tab(5)+0.1
   ENDFOR
ENDIF

FREE_LUN,lu
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_read.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
