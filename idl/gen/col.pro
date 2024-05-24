;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: col.pro
; Created by:    Philip Judge, February 28, 2006
;
; Last Modified: Thu Aug 17 12:59:28 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro col,listc = listc, delete = delete, add = add,label_list = label_list
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       col
;
; PURPOSE: lists, deletes, adds, checks levels
;       
; EXPLANATION:
;
; CALLING SEQUENCE: 
;   col,list = list, delete = delete,list = list, add = add
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       none
;
; OUTPUTS:
;       Modified atomic data in common block cdiper
;       listc = listc
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
;
; VERSION:
;       Version 1.0, February 27, 2006
;-
;
@cdiper
IF(!regime EQ 2) THEN return
;
;  any data to output?
;
ncol = n_elements(col)
IF(ncol EQ 0) THEN BEGIN 
   messdip,'no collisional transitions in atom',/inf
   RETURN
ENDIF
IF(n_elements(nadd) NE 0) THEN messdip,' /add keyword not included yet'
;
;
;
nlist = n_elements(listc)
ndelete = n_elements(delete)
nadd = n_elements(add)
;
IF(nlist+ndelete+nadd EQ 0) THEN BEGIN ; list all collisions for no input
   listc = lindgen(ncol) 
   nlist = ncol
ENDIF
;
IF(ndelete NE 0) THEN BEGIN 
   FOR j = 0,ndelete-1 DO BEGIN 
      i = delete(j)
      chkpar,i,' transition '+string(i),[0,ncol-1],':'
      n = lindgen(ncol)
      ok = where(n NE i)
      col = col(ok)
      ncol = ncol-1
;
;  take care of original delete array in this for loop
;
      higher = WHERE(delete GT i,c)
      IF(c GT 0) THEN delete(higher) = delete(higher)-1
   ENDFOR
;
;  re-compute consistent set of data
;   
;   trndata
ENDIF
;
; finally list the transitions:
;
plab = n_elements(label_list) NE 0
mn = min(lvl.ion) &  mx = max(lvl.ion)
str = '                    collisional data for '$
   +atom.atomid+' '+roman(mn)+'-'+roman(mx)
str = [str,'*   Num  Up - Lo  Key (*=Approximated) source']
;
; label_list instead of data
;
told = [-1.e9]
nold = 1
sa = ['  ','* ']
FOR kr = 0,nlist-1 DO BEGIN 
   k = listc[kr]
   ltim = 0.
;   IF(col(k).key EQ 'TEMP') THEN GOTO, skip
   ckey = col(k).key+'                    '
   IF(plab) THEN BEGIN 
      str1 =  sa(col(k).approx)+string(k,form = '(i4)')+$
         lvl(col(k).ihi).label+lvl(col(k).ilo).label + strmid(ckey,0,8)
   ENDIF ELSE BEGIN
      str1 =  sa(col(k).approx)+string(k,form = '(i4)')+$
         string([col(k).ihi,col(k).ilo],form = '(1x,i4,"-",i4)')+$
         ' '+strmid(ckey,0,8)
   ENDELSE
   nt = col(k).nt
   str3 = ''
   IF(nold EQ nt AND strtrim(col(k).key) EQ 'OHM') THEN BEGIN 
      dt = abs(col(k).temp(0:nt-1)-told(0:nt-1))/abs(told(0:nt-1))
      IF(max(dt) GT 1.e-4) THEN BEGIN 
         str3 = '                 TEMP   '
         FOR it = 0,nt-1 DO str3 = str3+string(col(k).temp(it),form = '(1x,e8.1)')
      ENDIF
   ENDIF ELSE IF (strtrim(col(k).key) EQ 'OHM') THEN BEGIN 
      str3 =    '                 TEMP   '
      FOR it = 0,nt-1 DO str3 = str3+string(col(k).temp(it),form = '(1x,e8.1)')
   ENDIF
   str1 = str1+string(col(k).data(0:3),form = '(4(1x,e8.1))')
   str1 = str1+'...    '+strmid(col(k).ref,0,50)
   IF(str3 EQ '') THEN str = [str,str1] ELSE str = [str,str3,str1]
   told = col(k).temp
   nold = col(k).nt
   skip:
ENDFOR
print_str,str
;
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'col.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
