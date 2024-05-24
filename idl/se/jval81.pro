;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: jval81.pro
; Created by:    Philip Judge, February 19, 2003
;
; Last Modified: Thu Mar  2 20:27:05 2006 by judge (Philip Judge) on niwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
FUNCTION jval81, waves, tr=tr,help=help,nodark = nodark
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:	
;       jsun()
;
; PURPOSE:
;       Returns values  of mean intensity incident upon a  slab low in the solar
;       corona.  Extracted from VAL81 paper.
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = jsun()
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
;       Written October 18, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, October 18, 1995
;-
;
if(n_elements(help) gt 0) then begin
  doc_library,'jsun'
  return,-999
endif
;
;
jbar = waves*0.
;
; ir wavelengths
;
kir = WHERE(waves GE  10000.,ir)
IF(ir GT 0) THEN BEGIN
   tir = 6000.
   jbar(kir) =  iplanck(waves(kir),tir)
ENDIF
;
; optical wavelengths
;
kopt = WHERE(waves GT  4000. AND waves LT  10000.,opt)
IF(opt GT 0) THEN BEGIN
   topt = 5500.
   jbar(kopt) =  iplanck(waves(kopt),topt)
ENDIF
;
; UV wavelengths >  1400
;
lo = 1400 &  hi = 4000.
tl = 4600. &  th = 5500.
k = WHERE(waves GE lo AND waves LT hi,n)
;
IF(n GT 0) THEN BEGIN
   t = tl+(th-tl)*(waves(k)-lo)/(hi-lo)
   jbar(k) =  iplanck(waves(k),t)
   tr=t
ENDIF
;
; Si I/C I UV continuum
;
lo = 1240 &  hi = 1400.
tl = 4700. &  th = 4650. 
k = WHERE(waves GE lo AND waves LT hi,n)
;
IF(n GT 0) THEN BEGIN
   t = tl+(th-tl)*(waves(k)-lo)/(hi-lo)
   jbar(k) =  iplanck(waves(k),t)
; ly alpha
   dw = (1215.-waves(k))/(40)
   t = 6200.*voigt(0.1,dw)
   jbar(k) = jbar(k)+ iplanck(waves(k),t)
ENDIF
lo = 1100 &  hi = 1240.
tl = 5100. &  th = 4900. 
k = WHERE(waves GE lo AND waves LT hi,n)
;
IF(n GT 0) THEN BEGIN
   t = tl+(th-tl)*(waves(k)-lo)/(hi-lo)
   jbar(k) =  iplanck(waves(k),t)
; ly alpha
   dw = (1215.-waves(k))/(40)
   t = 6200.*voigt(0.1,dw)
   jbar(k) = jbar(k)+ iplanck(waves(k),t)
ENDIF
;
;
; C I UV 
;
lo = 911. &  hi = 1100.
tl = 5950. &  th = 5400. 
k = WHERE(waves GE lo AND waves LT hi,n)
;
IF(n GT 0) THEN BEGIN
   t = tl+(th-tl)*(waves(k)-lo)/(hi-lo)
   jbar(k) =  iplanck(waves(k),t)
ENDIF
;
; XUV wavelengths in Ly continuum
;
;  From val81 figure 31
;
;keuv = WHERE(waves lt 912. AND waves GT 504.,euv)
;IF(euv GT 0) THEN BEGIN
;   teuv = 9000.
;   jbar(keuv) =  0.5*iplanck(waves(keuv),teuv)/814.
;ENDIF
;
;above does not fit fig 15 so try the following:
;
lo = 504. &  hi = 911.
tl = 10200. &  th = 9000.
k = WHERE(waves GE lo AND waves LT hi,n)
;
IF(n GT 0) THEN BEGIN
   t = tl+(th-tl)*(waves(k)-lo)/(hi-lo)
   jbar(k) =  iplanck(waves(k),t)/800.
endif
;
;
;
; XUV He I continuum
;
;  From val81 figure 31, read from J - limb brightened
;
;kxuv = WHERE(waves lt 504.,xuv)
;IF(xuv GT 0) THEN BEGIN
;   txuv = 10000.
;   jbar(kxuv) =  iplanck(waves(kxuv),txuv)
;ENDIF
;
lo = 200. &  hi = 504.
tl = 12000. &  th = 1.e4
k = WHERE(waves GE lo AND waves LT hi,n)
;
IF(n GT 0) THEN BEGIN
   t = tl+(th-tl)*(waves(k)-lo)/(hi-lo)
   jbar(k) =  iplanck(waves(k),t)
endif
;
; limb darkening. Very very approximate: basically
; just scale up or down disk center intensity very approximately
; the following numbers are for I = a + b*mu for b=-a/2 and b=a
;
IF(n_elements(nodark) EQ 0) THEN BEGIN 
   messdip,/inf,'very approximate center-limb treatment'
   dark =   where(waves GT 1500.,n)
   IF(n GT 0) THEN jbar(dark) = jbar(dark)*3./8.
   bright = where(waves lT 1500.,n)
   IF(n GT 0) THEN jbar(bright) = jbar(bright)*3./4.
ENDIF ELSE BEGIN
;   jbar = jbar/2.
ENDELSE

;
RETURN,jbar/2.  ; for 2pi sr irradiation.
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'jval81.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
