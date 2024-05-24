;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: idspec.pro
; Created by:    Phil Judge, High Altitude Observatory/NCAR, Boulder CO, August 24, 1998
;
; Last Modified: Fri Aug 25 20:15:24 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO idspec, subset = subset, order = order, ystart = ystart,lsubset=lsubset,$
            delta = delta,xshift_label = xshift_label,vac = vac,lo=lo,hi=hi,e1=e1
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       idspec
;
; PURPOSE:
;       to add atomic transition identifications to spectral plots
;       the procedure assumes that the values of !x.crange specify the
;       wavelength limits in Angstroms of a plotted spectrum
;
; CALLING SEQUENCE:
;       idspec,subset = subset, order = order, ystart = ystart,help=help,$
;            delta = delta,xshift_label = xshift_label,vac=vac
;
; INPUTS:
;       
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
;      subset=subset, e.g. subset='ion=13,atom=26', restrict search
;      in atom_bb
;      lsubset=subset, e.g. lsubset='e<2', restrict search
;      in atom_lvl
;      order=order  spectral order to plot (def=1). 
;      ystart=ystart  position along ordinate to start placing ids 
;                     (between 0 and 1)
;      delta=delta  difference in y for subsequent multiplets (def=0.07)
;      xshift_label=xshift_label  position label of multiplet
;      vac=vac   use vacuum wavelengths for all transitions (def=no)
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
;
; PREVIOUS HISTORY:
;       Written August 24, 1998, by Phil Judge, High Altitude Observatory/NCAR, Boulder CO
;
; MODIFICATION HISTORY:
;       
;
; VERSION:
;       Version 1, August 24, 1998
;-
;
@cdiper
IF(n_elements(order) EQ 0) THEN order = 1
regold = !regime
air = n_elements(vac) EQ 0
dbopen,'atom_bb'
if(n_elements(lo) eq 0) then lo=min(!x.crange)
if(n_elements(hi) eq 0) then hi=max(!x.crange)
lo/=order
hi/=order
;if(air) then print,'air wavelengths assumed' else print,'vacuum wavelengths used'
;
; 
IF(air) THEN airtovac,lo
IF(air) THEN airtovac,hi
lo=string(lo)
hi=string(hi)
j=dbfind(lo+'<wl<'+hi,/sil)
;
IF(n_elements(subset) NE 0) THEN BEGIN 
   IF(subset NE '') THEN j = dbfind(subset,j)
ENDIF 
if(n_elements(j) eq 1 and j[0] eq 0) then begin
   ;message,/inf,'no lines in range'
   goto, none
endif
;
j = dbsort(j,'atom,ion,wl')
dbext,j,'wl,atom,ion,f_lab_j,f_lab_i',w,a,i,u,l
dbclose
!regime=2 ; this procedure does not need collisional data
IF(n_elements(delta) EQ 0) THEN delta = 0.07
IF(n_elements(ystart) eq 0) THEN ystart = 0.9

IF(n_elements(lsubset) EQ 0) THEN lsubs='' else lsubs=','+lsubset
print,'lsubs:   ',lsubs
FOR j = 0,n_elements(a)-1 DO BEGIN 
   lo = j-1 > 0
   IF(j EQ 0 OR a(j) ne a(lo) OR  i(j) NE i(lo)) THEN BEGIN
;      print,atomn(a(j)),' '+roman(i(j)),w(j)
      dbopen,'atom_lvl'
      str = 'atom=' + STRTRIM(STRING(a(j)), 2) + ',' + $
            'ion='+strtrim(string(i(j)),2)+lsubs
      jj = dbfind(str,/sil)
      if(jj[0] eq 0) then goto, next
      same = where(a EQ a(j) AND i EQ i(j))
      jju = dbget('entry',u(same),jj,/sil)
      jjl = dbget('entry',l(same),jj,/sil)
      jjj = [jju,jjl]
      dbext,jjj,'label',lab
      if(lab[0] eq '') then goto, next
      jj = dbget('label',lab,jj,/full,/sil)
      diprd,a(j),i(j), enidx = jj, /noch,/nofill
      id_atom,/mult,order = order,ystart = ystart,xshift_label = xshift_label,air=air,e1=e1
      ystart = ystart-delta
      next:
      dbclose
   ENDIF
ENDFOR
none:
dbclose
!regime = regold
RETURN

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'idspec.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
