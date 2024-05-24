;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: gencolrbn.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, October 16, 1995
;
; Last Modified: Fri Jun  2 14:07:51 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro colrbn, maxarr, mint=mint, maxt=maxt, plot=plot
;
;+
; NAME:
; GENCOLRBN
; PURPOSE:
;     Re-bins b-b collisional data arrays so that the 
;     maximum array length is toads collisional data from the atom file, 
;     only changes keywords 'CE','OHM','TEMP'
; CALLING SEQUENCE:
; gencolrbn, coll, maxarr, plot=plot,mint=mint,maxt=maxt
; INPUTS:
; coll- collisional structure (see gencolrd)
; maxarr-  integer gt 1 which is the new length of the  arrays
; OPTIONAL INPUT PARAMETERS:
; plot
; OUTPUTS:
;  modifies diper structure col
; SIDE EFFECTS:
;  
; METHOD:
; REVISION HISTORY:
;  Written by P.G. Judge 23-Mar-1994
;  Changed for cdiper structures March 13, 2006 PGJ
;-
@cdiper
if (n_params(0) lt 1) then begin
  print,'gencolrbn, coll, maxarr'
  return
endif
;
; find parts of arrays which have temp and data arrays
;
j=where(strmid(col.key,0,6) eq 'OHM' or col.key eq 'CE' OR  col.key EQ 'TEMP',kount)
if(kount le 0) then return
n=0

for i=0,kount -1 do begin
  if(col(j(i)).nt le maxarr) then goto, next
  n=n+1
  tin=col(j(i)).temp(0:col(j(i)).nt-1)
  maxt0 = MAX(tin)
  mint0 = MIN(tin)
  IF(N_ELEMENTS(maxt) NE 0) THEN maxt0=maxt0 < maxt
  IF(N_ELEMENTS(mint) NE 0) THEN mint0=mint0 > mint
  tin = alog10(tin)
  maxtl = alog10(maxt0)
  mintl = alog10(mint0)
  tout = mintl + (maxtl-mintl)/(maxarr-1)*findgen(maxarr)
  din=col(j(i)).data(0:col(j(i)).nt-1)
  dout=spline(tin,din,tout)
  neg = WHERE(dout LT 0,kkk)
  IF(kkk NE 0) THEN BEGIN
     messdip,strn(kkk)+' points were interpolated to -ve values- set to ' + $
        'zero',/cont 
     dout =  dout >  0.
  ENDIF     
;  dout(maxarr-1)=col(j(i)).data(col(j(i)).nt-1)
;  dout(0)=col(j(i)).data(0)
  col(j(i)).data(0:maxarr-1)=dout
  nl=n_elements(col(j(i)).data)
  col(j(i)).data(maxarr:nl-1)=0.
  col(j(i)).temp=10.^tout
  col(j(i)).temp(maxarr:nl-1)=0.
  col(j(i)).nt=maxarr
  if(n_elements(plot) gt 0) then begin
    plot,tin,din,psym=1,titl=col(j(i)).key+string(col(j(i)).ihi)+$
     string(col(j(i)).ilo)
    oplot,tout,dout,psym=-2
    pr
  endif
  next:
endfor
messdip,/inf,strn(n)+' data keywords have been re-binned'
return
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'gencolrbn.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
