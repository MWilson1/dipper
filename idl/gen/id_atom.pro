;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: id_atom.pro
; Created by:    Philip G. Judge, June 5, 1996
;
; Last Modified: Thu Aug 10 16:37:04 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO id_atom, multiplet=multiplet, ystart=ystart, config=config, size=size,$
             last = last, dy=dy, flag=flag, linestyle=linestyle,air=air,$
             order=order,xshift_label=xshift_label,help=help,lab=lab,$
             include_missing=include_missing,e1=e1,_extra=_extra,jupper=jupper
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       id_atom
;
; PURPOSE: marks line identifications onto the current graphics output
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       id_atom, 
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
;       catom, cqn
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
;       Written June 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, June 5, 1996
;-
;
@cdiper
COMMON id_atom, ylast
;   
debug=0
;
if(n_elements(xshift_label) eq 0) then xshift_label=0.
if(n_elements(lab) eq 0) then lab=''
IF(N_ELEMENTS(dy) EQ 0) THEN dy = 0.03
IF(N_ELEMENTS(ystart) EQ 0) THEN BEGIN
   IF(N_ELEMENTS(last) EQ 0) THEN BEGIN
      ystart = 0.9
   ENDIF ELSE BEGIN
      IF(N_ELEMENTS(last) NE 0) THEN BEGIN 
         IF(N_ELEMENTS(ylast) EQ 0) THEN BEGIN 
            ystart = 0.9 
         ENDIF ELSE BEGIN 
            ystart = ylast
            IF(ystart LT 5*dy) THEN ystart = 0.95
         ENDELSE
      ENDIF
   ENDELSE
ENDIF
IF(N_ELEMENTS(flag) EQ 0) THEN flag = ''
IF(N_ELEMENTS(order) EQ 0) THEN order = 1
orderstr = ''
IF(order ne 1) THEN orderstr = 'x'+strtrim(string(order),2)+': '
;
;  Work in normal coordinates
;
datay = ystart
IF(!y.type EQ 0) THEN BEGIN
   ay = !y.s(0) 
   by = !y.s(1)*(!cymax-!cymin)
ENDIF ELSE BEGIN
   ay = !y.s(0)+!y.s(1)*!cymin
   by = !y.s(1)*(!cymax-!cymin)
ENDELSE

yplot = ay+ by*ystart
if(debug) then print,'yplot = ay+ by*ystart',yplot,ay,by,ystart
;
plotit:
;
if(n_elements(include_missing) ne 0) then $
   IF(misstrn(0).alamb NE 0.) THEN trn = [trn,misstrn] ; include missing mult. members
alamb_use = trn.alamb*order
if(n_elements(air) ne 0) then begin
   vactoair,alamb_use,www
   alamb_use=www
endif
k = WHERE(alamb_use GE !cxmin AND alamb_use LE !cxmax,count)
IF(count EQ 0) THEN RETURN
;
;  Now step through to get all members of same multiplet
;
knew = 0
IF(N_ELEMENTS(multiplet) NE 0) THEN BEGIN 
   done = trn.multnum*0
   FOR i = 0,count -1 DO BEGIN
      j = WHERE(trn.multnum EQ trn(k(i)).multnum AND done(i) EQ 0)
      knew = [knew,j]
      done(j) = 0
   ENDFOR
   k = knew(1:*)
   count = N_ELEMENTS(k)
ENDIF
;
;
;
x = !x.s(0)+ !x.s(1)*alamb_use(k)
IF(N_ELEMENTS(SIZE) EQ 0) THEN SIZE = !p.charsize
;
dy1=dy/1.4
shift=0.

IF(N_ELEMENTS(multiplet) NE 0) THEN BEGIN 
   m = trn(k).multnum
   done = m*0
   FOR i = 0,count-1 Do BEGIN
      kk = WHERE(m EQ m(i) AND done EQ 0,nnn)
      IF(nnn GT 0) THEN BEGIN 
         done(kk) = 1
         jup = trn(k(kk(0))).jrad
         tup = lvl(jup).term &  oup = lvl(jup).orb &  j2up = lvl(jup).tjp1
         cup = lvl(jup).coupling
         jlo = trn(k(kk(0))).irad
         tlo = lvl(jlo).term &  olo = lvl(jlo).orb &  j2lo = lvl(jlo).tjp1
         clo = lvl(jlo).coupling
         int2lab,up_idl,j2up,tup,oup,cup,/idl
         int2lab,lo_idl,j2lo,tlo,olo,clo,/idl
         lastup = getwrd(up_idl,-1,/last)
         begup = getwrd(up_idl,-30,-2,/last)
         lastlo = getwrd(lo_idl,-1,/last)
         beglo = getwrd(lo_idl,-30,-2,/last)
         up_idl = strcompress(begup,/rem)+' '+lastup
         lo_idl = strcompress(beglo,/rem)+' '+lastlo
;
         strn = strcapitalize(atom.atomid)+' '+roman(lvl(jlo).ion) +' '+ up_idl +' - '+ lo_idl

         IF(n_elements(e1) ne 0 and trn(k(kk(0))).type NE 'E1') THEN goto, next ;
         lines=1
         ; just need one of them to be E1
         for p=0,nnn-1 do IF(trn(k(kk(p))).type EQ 'E1') THEN lines = 0
         IF(N_ELEMENTS(linestyle) NE 0) THEN lines = linestyle
         yplot = yplot-dy*1.1
         IF(yplot LT 1*dy) THEN yplot = ystart
         xmin = MIN(alamb_use(k(kk))) > !cxmin 
         xmax = MAX(alamb_use(k(kk))) < !cxmax 
         xmax = !x.s(0)+ !x.s(1)*xmax
         xmin = !x.s(0)+ !x.s(1)*xmin
         shift=!x.s(1)*xshift_label
         FOR j = 0,nnn-1 DO BEGIN
            IF(x(kk(j)) LE xmax AND x(kk(j)) GE xmin) THEN  begin
               CGPLOTS,[x(kk(j)),x(kk(j))],[yplot,yplot+dy/3],$ 
                     lines = 0, /norm,$
                  _extra=_extra
               if(n_elements(jupper) ne 0) then begin ; label J upper
                  j2u=trn(k(kk(j))).jrad
                  j2u=lvl(j2u).tjp1
                  justr = strtrim(gtoj(j2u,/str),2)
                  cgtext,x[kk[j]],yplot-dy/12,' '+justr,/norm,size=0.75,$
                  _extra=_extra
               endif
            endif
         ENDFOR
         CGPLOTS,[xmin,xmax],yplot+dy/3,lines = lines,/norm,$
                  _extra=_extra
            outstring=flag+strn
            if(lab ne '') then outstring=lab
            outstring =  orderstr+outstring
            cgtext,xmin+shift,yplot+dy1/1.1,outstring,/norm,SIZE = SIZE,$
                  _extra=_extra
         next:
         if(debug) then begin 
            print,'ay, by, ystart',ay,by, ystart
            print,'yplot =',yplot
            pr
         endif
      ENDIF
   ENDFOR
ENDIF ELSE BEGIN
   FOR i = 0,count-1 DO BEGIN 
      yplot = yplot-dy
      IF(yplot LT 1*dy) THEN yplot = ystart
      CGPLOTS,[x(i),x(i)],[yplot,yplot+0.1],/norm,$
                  _extra=_extra
         outstring=flag+atom.atomid
         if(lab ne '') then outstring=lab
         outstring =  orderstr+outstring
      cgtext,x(i)+shift,yplot+0.12,orient = 90.,outstring,/norm,SIZE = size,$
                  _extra=_extra
   ENDFOR
ENDELSE
;
ylast = yplot
ylast = (ylast-ay)/by

;
RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'id_atom.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
