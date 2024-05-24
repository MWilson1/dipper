;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_plot_rad.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Sun Jun  4 11:27:41 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro TD_PLOT_RAD,KR ,fixlamb=fixlamb,nm=nm,label_length=label_length ; Plots transitions
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_plot_rad
;
; PURPOSE: plots a radiative transition in a term diagram
;       
; EXPLANATION:
;            plots transition kr
;         
;            following variables are used and are in common ctermdiag:
;
;            c_label_space  color of label space, 0=no plot, <0 gives krcolor
;            c_label        color of label        0=no plot, <0 gives krcolor
;            c_arrow        color of arrow        0=no plot, <0 gives krcolor
;            krcolor        color of line
;       
; CALLING SEQUENCE: 
;       td_plot_rad,kr ,fixlamb=fixlamb,nm
;
; INPUTS:
;       KR index of line (starting from 0) to be plotted
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
;            /fixlamb  gives lambda in integer Angstrom,
;                      otherwise with 3 decimals
;            /nm       gives lambda in nm (/fixlamb,/nm gives one decimal)
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
   doc_library,'td_plot_rad'
   RETURN
ENDIF
;
; arrow marker:
;
IF(N_ELEMENTS(fixlamb) EQ 0) THEN fixlamb=0
IF(N_ELEMENTS(nm) EQ 0) THEN nm=0

IF (krcolor(kr) EQ 0) THEN RETURN
;pgj old_color=!color
triangle=fltarr(3)
triangle(0)=310.
triangle(1)=90.
triangle(2)=230.
triangle=triangle-90.
ang=triangle
;
lower=0
upper=0
IF(!p.charsize NE 0) THEN csize=0.6*!p.charsize ELSE csize=0.6
x=fltarr(4)
y=fltarr(4)
x11=fltarr(2)
y11=x11

; find line end point displacements. Width of level is 0.5
nline = atom.nline
irad = trn.irad
jrad = trn.jrad
corr0=-0.25
!c=0
!linetype=kr_linestyle(kr)
IF (kr GT nline-1) THEN BEGIN
   corri=corr0 + idx(kr)*0.5/max_dx_cont
   corrj=corr0 + jdx(kr)*0.5/max_dx_cont
ENDIF ELSE BEGIN
   corri=corr0 + idx(kr)*0.5/max_dx_line
   corrj=corr0 + jdx(kr)*0.5/max_dx_line
ENDELSE
lower=IRAD(kr) 
upper=JRAD(kr) 

;
; find positions. length is length in screen coordinates of space for
; label. x,y are data coordinates, xs, ys screen coordinates for:
; 0  left end-point of line
; 1  left starting-point for label space
; 2  right end-point for label space
; 3  right end-point of line
;
lab_pos=0.45
IF(fixlamb) AND (nm EQ 0) THEN length0=0.08 ELSE length0=0.11
IF(N_ELEMENTS(label_length) NE 0) THEN length0=label_length
length=length0*(!sc4-!sc3)*(csize/0.6)
x(0)= 0.5 + positions(lower) + corri
x(3)= 0.5 + positions(upper) + corrj
;

y(0)= EVPLOT(lower)
y(3)= EVPLOT(upper)
IF(x(3) LT x(0))THEN BEGIN      ; if lower-upper is right-left, switch
   xxx=x(3)
   x(3)=x(0)
   x(0)=xxx
   yyy=y(3)
   y(3)=y(0)
   y(0)=yyy
ENDIF

xs=!d.x_vsize*(!x.s(0)+!x.s(1)*x) ; screen coordinates for end points
ys=!d.y_vsize*(!y.s(0)+!y.s(1)*y)

; intermediate points:

dxs=xs(3)-xs(0)
dys=ys(3)-ys(0)
xs(1)=0.5*(xs(0)+xs(3)) - 0.5*length*(dxs)/SQRT( dxs*dxs + dys*dys)
xs(2)=0.5*(xs(0)+xs(3)) + 0.5*length*(dxs)/SQRT( dxs*dxs + dys*dys)
ys(1)=0.5*(ys(0)+ys(3)) - 0.5*length*(dys)/SQRT( dxs*dxs + dys*dys)
ys(2)=0.5*(ys(0)+ys(3)) + 0.5*length*(dys)/SQRT( dxs*dxs + dys*dys)

x=(xs/!d.x_vsize - !x.s(0))/!x.s(1)
y=(ys/!d.y_vsize - !y.s(0))/!y.s(1)
;
;pgj !color=krcolor(kr)
oplot,x(0:1),y(0:1)             ; plot from left level to label
oplot,x(2:3),y(2:3)             ; plot from label to right level

x11(0)= x(1) - 0.2*(x(2)-x(1))  ; set coordinates for arrows
y11(0)= y(1) - 0.2*(y(2)-y(1))
x11(1)= x11(0)
y11(1)= y11(0)

IF (c_label_space NE 0) THEN BEGIN
;pgj    IF (c_label_space GT 0) THEN !color=c_label_space ELSE !color=krcolor(kr)
   oplot,x(1:2),y(1:2)          ; plot label space
ENDIF

;pgj IF(!d.name NE 'PS') THEN !color=krcolor(kr)
;
; always plot short line closest to level
;
dxtick=0.2*length*(dxs)/SQRT( dxs*dxs + dys*dys)
dytick=0.2*length*(dys)/SQRT( dxs*dxs + dys*dys)
xs(1)=xs(0) + dxtick
ys(1)=ys(0) + dytick
xs(2)=xs(3) - dxtick
ys(2)=ys(3) - dytick
x=(xs/!d.x_vsize - !x.s(0))/!x.s(1)
y=(ys/!d.y_vsize - !y.s(0))/!y.s(1)
!linetype=0
oplot,x(0:1),y(0:1)
oplot,x(2:3),y(2:3)
;
; output transnames along the lines
;
alamb = trn.alamb
IF(fixlamb) THEN BEGIN
   IF(nm EQ 0) THEN $
      transname=STRTRIM(STRING(round(convl(alamb(kr)))),2) $
   ELSE $
      TRANSNAME=STRTRIM(STRING(CONVL(ALAMB(KR))/10.,'(F9.1)'),2)
ENDIF ELSE BEGIN
   IF(nm EQ 0) THEN $
      TRANSNAME=STRTRIM(STRING(CONVL(ALAMB(KR)),'(F11.3)'),2) $
   ELSE $
      TRANSNAME=STRTRIM(STRING(CONVL(ALAMB(KR)/10.),'(F11.3)'),2)
ENDELSE
dx=x(3)-x(0)
dy=y(3)-y(0)
screenx = !d.x_vsize*!x.s(1)*dx
screeny = !d.y_vsize*!y.s(1)*dy
;
IF(screenx EQ 0.) THEN BEGIN
   angle=90.
ENDIF ELSE BEGIN
   tanxy= (screeny/ screenx)
   angle=atan( tanxy )*180./3.141592
ENDELSE
;
XS1=0.5*(X(0)+x(3))
YS1=0.5*(y(0)+y(3))
IF (c_label NE 0) THEN BEGIN
   IF (c_label GT 0) THEN color=c_label ELSE color=krcolor(kr)
   xyouts_lim,!cxmin,!cxmax,!cymin,!cymax,XS1 ,YS1,transname,csize,angle,color,/center
ENDIF
;
arrowsize=1.
fill=0
IF (directions(kr) EQ 'D') THEN BEGIN
   angle= angle+180.
ENDIF
;
; put arrows left of label, half of label space distance
;
IF(positions(upper) LT positions(lower)) THEN angle=angle+180.
ang=(triangle+angle)*3.141592/180.
usersym,cos(ang)*arrowsize,sin(ang)*arrowsize,fill=fill
!psym=8
IF (c_arrow NE 0) THEN BEGIN
;pgj   IF (c_arrow GT 0) THEN !color=c_arrow ELSE !color=krcolor(kr)
   oplot ,x11,y11
ENDIF
!psym=0
;!color=old_color
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_plot_rad.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





