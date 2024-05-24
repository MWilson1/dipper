;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: atomwr.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, October 28, 1994
;
; Last Modified: Thu Jul 27 13:06:41 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO atomwr,file,head, nocomm=nocomm,ohm = ohm, magnetic = magnetic, help=help

;+
; PROJECT: 
;       HAOS-DIPER
;
; NAME:
;       atomwr
;
; PURPOSE: 
;	Writes atomic data in standard MULTI format from
;	file, including collisional data and header information
;
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;      atomwr,file,coldata,head, nocomm=nocomm, help=help
;
; INPUTS:
;	file: name of output file to which atomic data are written
;
; OPTIONAL INPUTS:
;	coldata: structure containing collisional parameters
;	head: structure containing header information
;
; OUTPUTS:
;       None.  File file is written
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       /nocomm  No comments are written in file 
;
; CALLS:
;
; COMMON BLOCKS:
;	catom
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;	if head is included in argument list but was undefined
;       then headstrt is called and the default (minimal) header
;       is written.
;
; EXAMPLE:
;	To write data for the ion C IV in current directory:
;               !REGIME=0  ; coronal regime, 
;		ATOMWR,'atom.c4',head
;	To write same data but with no header, no collisional data
;               !REGIME=2  ; LTE regime
;		ATOMWR,'atom.c4'
;	To write same data with no header or collisional data,
;               !REGIME=2  ; LTE regime
;		ATOMWR,'atom.c4'
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       
;
; MODIFICATION HISTORY:
; 
; VERSION:
;       Version 1, February 27, 2006
;-
;
@cdiper
;
cmt = (N_ELEMENTS(nocomm) EQ 0)
openw,lu2,file,/get
;
if(n_elements(head) gt 0) then begin 
   sz=SIZE(head)
   IF(sz(0) EQ 0) THEN headstrt,head
   headwr,lu2,head
ENDIF
;
if(cmt) then printf,lu2,'* written by atomwr on ', systime()
printf,lu2, atom.atomid

if(cmt) then printf,lu2, "* abnd  awgt"
printf,lu2,atom.abnd,atom.awgt, format='(2(1x,f7.2))'

if(cmt) then printf,lu2, "* nk,nline,ncont,nrfix"
printf,lu2, atom.nk,atom.nline,(atom.nrad-atom.nline),0, format = $
   '(4(1x,i8))'

IF (n_elements(magnetic) EQ 0) THEN begin
   FOR I=0,atom.nk-1 DO BEGIN
      PRINTF,LU2, lvl(i).ev*EE/CC/HH,lvl(i).g, $  
         lvl(i).label, lvl(i).ion, FORMAT='(1x,f13.3,f6.2,2x,"''",a,"''",2x,i2)'
   ENDFOR
ENDIF ELSE BEGIN
   str = '*       E cm-1    g   label                        ion  S   L   J   P  Lande G'
   IF(cmt) THEN printf,lu2,str
   sss = 0.5*(lvl.tsp1-1.)
   lll = float(lvl.bigl)
   jjj = 0.5*(lvl.g-1.)
   par = fix(sss)*0+1
   k = where(strupcase(lvl.parity) EQ 'E',c)
   IF(c NE 0) THEN par(k) = 0
   FOR I=0,atom.NK-1 DO BEGIN
      PRINTF,LU2, lvl(i).ev*EE/CC/HH,lvl(i).g, $  
      lvl(i).label, lvl(i).ion, sss(i),lll(i),jjj(i),par(i),lvl(i).glande,$
      FORMAT='(1x,f13.3,f6.2,2x,"''",a25,"''",2x,i2,3(1x,f3.1),1x,i1,1x,e11.4)'
   ENDFOR
ENDELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

iwide = 0
FOR KR=0,atom.nline-1 DO BEGIN
   IF(cmt) THEN PRINTF,lu2,lvl(trn(kr).jrad).label,lvl(trn(kr).irad).label, $ 
      convl(trn(kr).alamb), FORMAT='("*  ", a,2x,a,2x,f15.3)'
   PRINTF,lu2, trn(kr).jrad+1,trn(kr).irad+1,trn(kr).f,trn(kr).nq > 30,trn(kr).qmax > 30,trn(kr).q0 > 10.0,$
      iwide,trn(kr).ga,trn(kr).gw,trn(kr).gq, FORMAT= $
      '(i4,i4,e10.3,1x,i3,1x,f5.1,1x,f5.1, 1x,i2,1x,3(1x,e9.2))'
   IF(trn(kr).qmax LT 0.0) OR (trn(kr).q0 LT 0.0) THEN BEGIN
      PRINTF,LU2, trn(kr).q
   ENDIF
ENDFOR
;
;  write photoionization data
;
m1=-1.
lab=lvl.label
q00=0.
for kr = atom.nline, atom.nrad-1 do begin
   hi=trn(kr).jrad+1
   lo=trn(kr).irad+1
   xl=cc*1.d8 / trn(kr).frq(1:trn(kr).nq)
   printf,lu2,'* ',lab(hi-1),' -- ', lab(lo-1),format='(a,a,a,a)'
   printf,lu2,'*  UP  LO  F        NQ   QMAX  Q0'
   printf,lu2,hi,lo,trn(kr).alfac(0),trn(kr).nq,m1,q00, $
     format='(2i4,e9.2,i4,1x,f4.1,f4.1)'
   for i=1,trn(kr).nq do printf,lu2,xl(i-1),trn(kr).alfac(i), format='(f13.2,2x,e8.2)'
endfor
;
;
colwr,lu=lu2,nocomm = nocomm,ohm = ohm
free_lun,lu2
;
RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'atomwr.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
