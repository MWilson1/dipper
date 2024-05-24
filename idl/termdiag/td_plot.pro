;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_plot.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Tue Jun  6 09:03:53 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
PRO td_plot,EMIN=emin,EMAX=emax,lsort=lsort,fixlamb=fixlamb,nm=nm,help=help,title=title,$ 
     label_length=label_length, legend=legend,multiplicity=multiplicity,_extra=_extra
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_plot
;
; PURPOSE: plots a term diagram, to be used after td_init or td_read. 
;       
; EXPLANATION:
;     plot termdiag. all variables in common-block termdiag should have
;     been assigned values. This can be done by calling td_init
;     or by reading a termdiag file with td_read
;
;     Novices should use  
;       IDL> termdiag   
;     instead.
;
; CALLING SEQUENCE: 
;       td_plot, emin=emin,emax=emax,lsort=lsort,fixlamb=fixlamb,nm=nm,$ 
;         label_length=label_length, legend=legend,multiplicity=multiplicity
;
; INPUTS:
;       None.
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
;       ** for other keywords see  procedure termdiag **
;   
; CALLS:
;       None.
;
; COMMON BLOCKS:
;      cdiper, ctermdiag
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
;       plots a term diagram: MULTI VERSION  25-MAR-1989.  P. Judge.
;       modified 11-apr-1989  M. Carlsson
;
; MODIFICATION HISTORY:
;       Header updated September 5, 1996, by Philip G. Judge
;       
; VERSION:
;       Version 1, September 5, 1996
;-
;
@cdiper
@ctermdiag   
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_plot'
   RETURN
ENDIF

if(n_elements(lsort) eq 0) then lsort=1
if(n_elements(fixlamb) eq 0) then fixlamb=0
if(n_elements(nm) eq 0) then nm=0
;
;
;
ev = lvl.ev
nk = atom.nk
ion = lvl.ion
;
; limits:
;  find the maximum and minimum of the EV:
;
IF (N_ELEMENTS(emin) EQ 0)THEN BEGIN
   emin=MIN(EV(0:NK-1))
   bottom = 0.0                 ; emin -0.1 *(emax-emin)
ENDIF ELSE BEGIN
   BOTTOM=EMIN
ENDELSE
;
IF (N_ELEMENTS(emax) EQ 0)THEN BEGIN
   emax=MAX(EV(0:NK-1))
   top = FIX(emax + 0.1*(emax-emin))+1.0
ENDIF ELSE BEGIN
   TOP=EMAX
ENDELSE
;
pmax=MAX(positions(0:NK-1)) +1.0
;
; set viewport
;
xmin=0.0
xmax=pmax+0.5
IF(MAX(abs(!x.range)) EQ 0.0) THEN xrange=[xmin,xmax] ELSE xrange=!x.range
;
; draw the energy levels as horizontal lines, 0.5 wide and separated by
; 0.5
;
; ground level:
;
x=fltarr(2)
y=fltarr(2)
ii=0
x(0)= 0.25 + positions(ii)
x(1)= 0.75 + positions(ii)
y(0)= EVPLOT(ii)
y(1)= EVPLOT(ii)
;
ymargin=!y.margin
xmargin=!x.margin
ymargin(0) =  ymargin(0) >  5
IF(!y.style EQ 0) THEN ystyle=1+8 ELSE ystyle=!y.style
IF(!x.style EQ 0) THEN xstyle=4 ELSE xstyle=!x.style
IF(STRLEN(STRTRIM(!y.title,2)) EQ 0) THEN ytitle='Energy (eV) ' ELSE $
   ytitle=!y.title
IF(!p.charsize EQ 0) THEN pcsize=1.0 ELSE pcsize=!p.charsize
IF(N_ELEMENTS(title) EQ 0) THEN title = ''
plot,x,y, xrange=xrange, yrange=[bottom,top], linestyle=0,$
   font=-1,charsize=pcsize, xstyle=xstyle,ystyle=ystyle, title=title,$
   xtitle='Partial term diagram showing transitions', ytitle=ytitle,$
   xmargin=xmargin,ymargin=ymargin,_extra=_extra
csize=0.7*pcsize
xyouts_lim,xmin,xmax,bottom,top,x(1)+0.1,y(1),term_label(ii),csize
lab1=STRTRIM(term_label(0))
;
;  include only certain multiplicities?
;
include = 0* intarr(nk)
include(0) = 1 ; always include the ground state
mn = N_ELEMENTS(multiplicity)
IF(mn EQ 0) THEN BEGIN
   include(1:*) = 1 + include(1:*)
ENDIF ELSE BEGIN 
   mult = multiplicity
   IF(mn EQ 1) THEN mult = [multiplicity]
   FOR ii = 0,N_ELEMENTS(mult)-1 DO BEGIN
      kk = WHERE(lvl.tsp1 EQ mult(ii),count)
      IF(count GT 0) THEN include(kk) = 1
   ENDFOR
ENDELSE
;
;
FOR ii=1,nk-1 DO BEGIN
   IF(include(ii)) THEN begin
      y(0)= EVPLOT(ii)
      y(1)= EVPLOT(ii)
      IF(max_dx_cont NE 100) OR (ii NE MIN(WHERE(ion EQ ion(ii)))) THEN BEGIN
         x(0)= 0.25 + positions(ii)
         x(1)= 0.75 + positions(ii)
      ENDIF ELSE BEGIN          ; long continuum
         x(0)= 0.25 + MIN(positions)
         x(1)= 0.75 + MAX(positions)
         xfill=[x(0),x(1),x(1),x(0),x(0)]
         dy=0.01*(top-bottom)
         yfill=[y(0),y(0),y(0)+dy,y(0)+dy,y(0)]
         polyfill,xfill,yfill,orientation=45.,spacing=0.1
      ENDELSE
      oplot,x,y
      lab=STRTRIM(term_label(ii))
      st2=' '
      IF(low_fine(ii) NE ii)THEN BEGIN
         ylow=evplot(low_fine(ii))
         oplot,[x(0),x(0)-0.1,x(0)],[y(0),ylow,ylow]
         st2 = getwrd(lab,/last)
         k = STRPOS(lab1,st2)
         IF(k EQ -1) THEN lab1=lab1+','+st2
         xyouts_lim,xmin,xmax,bottom,top,x(1)+0.1,evplot(low_fine(ii)),lab1,csize
      ENDIF ELSE BEGIN
         xyouts_lim,xmin,xmax,bottom,top,x(1)+0.1,evplot(ii),lab,csize
         lab1=lab
      ENDELSE
   ENDIF
ENDFOR
;
; transitions
; lines and continua in detail:
;
ntr = N_ELEMENTS(whichtrans)
IF(ntr EQ 0) THEN whichtrans = indgen(nrad,/long)
ntr = N_ELEMENTS(whichtrans)
IF(ntr NE 0 AND whichtrans(0) GE 0) THEN BEGIN 
   FOR kr=0,Ntr-1 DO BEGIN 
      tr = whichtrans(kr)
      IF(include(trn(tr).irad) AND include(trn(tr).jrad)) THEN $
         td_plot_rad,tr,fixlamb=fixlamb,nm=nm,label_length=label_length
   ENDFOR
ENDIF
;
IF(!p.charsize NE 0) THEN csize=0.7*!p.charsize ELSE csize=0.7

IF(lsort NE 0) THEN td_plot_l

IF(N_ELEMENTS(legend) NE 0) THEN BEGIN
   psize = !p.charsize < 1.
   IF(psize EQ 0) THEN psize = 1
   td_lsty,sty,leg
   IF(legend LT 2) THEN legend,leg,lines = sty,/top,/left,chars = psize/1.2
   IF(legend eq 2) THEN legend,leg,lines = sty,/top,/right,chars = psize/1.2
   IF(legend eq 3) THEN legend,leg,lines = sty,/bottom,/right,chars = psize/1.2
   IF(legend eq 4) THEN legend,leg,lines = sty,/bottom,/left,chars = psize/1.2
ENDIF
RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_plot.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
