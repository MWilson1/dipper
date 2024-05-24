;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: trans.pro
; Created by:    Philip Judge, February 28, 2006
;
; Last Modified: 11 Jan 2013, air=air keyword added to argument list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro trans,listt = listt, delete = delete, add = add,label_list = label_list,air=air,$
          _extra=_extra,branch=branch,nodesc=nodesc,lu=lu
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       trans
;
; PURPOSE: lists, deletes, adds, checks levels
;       
; EXPLANATION:
;
; CALLING SEQUENCE: 
;   trans,listt = listt, delete = delete,list = list, add = add
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       none
;
; OUTPUTS:
;       Modified atomic data in common block cdiper
;       listt = listt
;       delete = delete 
;       add = add
;       label_list=label_list  list the label_list instead of f, gf, etc.
;
; OPTIONAL OUTPUTS:
;
; KEYWORD PARAMETERS: 
;       
; CALLS:
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       
; SIDE EFFECTS:
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written 21-Jan-1993 P. Judge, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;  11 Jan 2013, air=air keyword added to argument list;
; VERSION:
;       Version 1.1, Jan 2013
;        Version 1.2, Nov 2017.  Addred branch keyword
;-
;
@cdiper
;
;  any data to output?
;
IF(atom.nrad EQ 0) THEN BEGIN 
   messdip,'no radiative transitions in atom',/inf
   RETURN
ENDIF
IF(n_elements(nadd) NE 0) THEN messdip,' /add keyword not included yet'
;
;
wave=convl(trn.alamb)
messdip,'Air wavelengths are given above 2000 Angstrom',/inf
;
nlist = n_elements(listt)
ndelete = n_elements(delete)
nadd = n_elements(add)
;
IF(nlist+ndelete+nadd EQ 0) THEN BEGIN ; list all levels for no input
   listt = lindgen(atom.nrad) 
   nlist = atom.nrad
ENDIF
;

ofile=0
if(n_elements(lu) ne 0) then ofile=1

IF(ndelete NE 0) THEN BEGIN 
   FOR j = 0,ndelete-1 DO BEGIN 
      i = delete(j)
      chkpar,i,' transition '+string(i),[-1,atom.nrad-1],':'
      n = lindgen(atom.nrad)
      ok = where(n NE i)
      trn = trn[ok]
      atom.nrad = atom.nrad-1
;
; take care of lines vs. continua      
;
      k = where(lvl(trn.irad).ion EQ lvl(trn.jrad).ion,nl)
      atom.nline = nl
;
;  take care of original delete array in this for loop
;
      higher = WHERE(delete GT i,c)
      IF(c GT 0) THEN delete(higher) = delete(higher)-1
   ENDFOR
;
;  re-compute consistent set of data
;   
   trndata
ENDIF
;
; finally list the transitions:
;
branch=dblarr(n_elements(trn))
plab = n_elements(label_list) NE 0
mn = min(lvl.ion) &  mx = max(lvl.ion)
str = '                     transition data for '$
   +atom.atomid+' '+roman(mn)+'-'+roman(mx)
str = [str,'Num  Type   Mult. Wavelength  UP  LO     A     ' + $
   '   GF         F          Branch  Lifetime  gbar   Gbar   BHanle ']
str = [str, '                    [A]                [S-1]       ' + $
      '                     ratio       [S]                    G']
if(n_elements(nodesc) ne 0) then str=''

;
; label_list instead of data
;
IF(plab) THEN BEGIN 
   str =      'Num  Type   Mult. Wavelength  UP  LO  Label(UP)'
   str = [str,'                    [A]               Label(LO)']
ENDIF

hbar=hh/2./pi

FOR kr = 0,nlist-1 DO BEGIN 
   k = listt[kr]
   ltim = 0.
   lo=trn[k].irad
   up=trn[k].jrad
   if(up eq 0) then print,'transition ',kr,' has same up lo:',lo,up
   bhanle = trn[k].a*hbar/lvl[up].glande/bohrm
;   bhanle=hbar/lifetime(up)/lvl[up].glande/bohrm
   bhanle=string(bhanle,form='(e8.1)')

   if(lvl[up].g lt 3) then bhanle = '' ; unpolarizable


   one=lvl[lo]
   two=lvl[up]

   gbar= geff(one,two,gtrans=gtrans)
   gbar=string(gbar,form='(f5.2)')
   gtrans=string(gtrans,form='(f6.2)')
   if(strcompress(trn[k].type,/remove_all) ne 'E1') then begin
      gbar=''
      gtrans=''
   endif
   

   IF(trn(k).type NE 'BF') THEN ltim = lifetime(trn(k).jrad,/nowarn)
   IF(plab) THEN BEGIN 
      sl = STRING(ltim,form = '(e9.2)')
      str1 =  string(kr,trn(k).type,trn(k).multnum,wave(k),trn(k).jrad,trn(k).irad,$
                     lvl(trn(k).jrad).label,lvl(trn(k).irad).label,trn(k).ref, $
                     FORMAT= '(I4,1x,a4,1x,i4,2x,f12.3,2(1x,i3),1x,a/37x,a,2x,a25)')
   ENDIF ELSE BEGIN
      sl = STRING(ltim,form = '(e9.2)')
      str1 =  string(kr,trn(k).type,trn(k).multnum,wave(k),trn(k).jrad,$
                     trn(k).irad,trn(k).a,lvl(trn(k).irad).g*trn(k).f,$
                     trn(k).f,trn(k).a*ltim, sl,gbar,gtrans,bhanle,$
                     FORMAT= '(I4,1x,a4,1x,i4,2x,f12.3,2(1x,i3),4(1x,e10.2),a,1x,a5,1x,a6,1x,a8)')
      branch[k]=trn[k].a*ltim
   endelse
   str = [str,str1]
ENDFOR

nlist=n_elements(str)
IF(nlist GT 0 and ofile eq 0) THEN for i=0,n_elements(str)-1 do print,str[i]
IF(nlist GT 0 and ofile eq 1) THEN for i=0,n_elements(str)-1 do printf,lu,str[i]
;
if(ofile) then free_lun,lu
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'trans.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
