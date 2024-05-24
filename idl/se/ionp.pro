;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: ionp.pro
; Created by:    judge, June 28, 2006
;
; Last Modified: Wed Aug  9 14:11:23 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO ionp, x,populations,fion, noplot = noplot,_extra = _extra
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       ionp.pro
;
; PURPOSE: 
;       Plots ion balance as a function of x, x=electron temperature, for
;       example, or time, as another example.
;
;       IDL> sesolv,t,n,pop,r ; calculate stat. eqm.
;       IDL> ionp,alog10(t),pop,xran=[4.0,6.0],yran=[1.e-4,1],/ylog
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       ionp, x, populations, _extra = _extra
;
; INPUTS:
;       x            fltarr or intarr with nx elements
;       populations  fltarr or intarr with (atom.nk, nx) elements
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       fion     fltarr ion fractions, (nion,nx), nion = number of different ions
;
; KEYWORD PARAMETERS: 
;       noplot   do not plot (routine called just to return fion)
;       _extra   plotting keywords (xrange=... etc.)
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
;       Written June 30, 2006
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, June 30, 2006
;-
;
@cdiper
;
IF(n_params(0) LT 2) THEN BEGIN 
   print,'ionp, x,populations,fion, noplot = noplot,_extra = _extra'
   return
ENDIF

i=min(lvl.ion) & j=max(lvl.ion)
ni=j-i+1  
IF(ni LT 2) THEN messdip,'< 2 ions in the atomic model- no plot needed'
fion=fltarr(ni,n_elements(x))
;
tot = total(populations,1)
for k=i,j do begin 
   m = where(lvl.ion EQ k)
   fion(k-i,*)=total(populations(m,*),1)/tot
endfor
;
IF(n_elements(noplot) NE 0) THEN return
;
print,'plotting'
styplot=0
plot_io,x,fion(0,*), linestyle=styplot,title=atom.atomid+' ion fractions',$
   _extra = _extra 
fm = max(fion(0,*))
xyouts,x(!c),fm,roman(i),size=1.4
for k=i+1,j do begin 
   styplot = 0
   IF(((k-i) MOD 2) EQ 1) THEN styplot = 1
   oplot,x,fion(k-i,*), linestyle=styplot
   fm = max(fion(k-i,*))
   xyouts,x(!c),fm,roman(k),size=1.4
endfor
;
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'ionp.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
