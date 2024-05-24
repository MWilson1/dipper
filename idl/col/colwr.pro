;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: colwr.pro
; Created by:    Philip G. Judge, August 12, 1996
;
; Last Modified: Sun Mar 12 12:47:53 2006 by judge (Philip Judge) on niwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO colwr, filen=filen,lu=lu,nocomm=nocomm, ohm = ohm, help=help, rh=rh
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       colwr
;
; PURPOSE: 
;       writes collisional data to standard atomic model ascii file.
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       colwr, filen=filen, lu=lu
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       none
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       /nocomm. Will not write comment lines to file
;       filen=fien  name of file to be written, -OR-
;       lu=lu       unit number of previously opened file to be written to.
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
;       Written August 12, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, August 12, 1996
;-
;
@cdiper
;
IF(!REGIME EQ 2) THEN BEGIN
   messdip,'!REGIME = 2, LTE, no collisional data written to file',/inf
   RETURN
ENDIF
;
IF(N_ELEMENTS(filen) EQ 0 AND N_ELEMENTS(lu) EQ 0) THEN BEGIN
   PRINT,'colwr:  you must specify only one of filen or lu (unit number)'
   RETURN
ENDIF
IF(N_ELEMENTS(filen) GT 0 AND N_ELEMENTS(lu) GT 0) THEN BEGIN
   PRINT,'colwr:  you must specify only one of filen or lu (unit number)'
   RETURN
ENDIF
;
IF(N_ELEMENTS(filen) GT 0 AND N_ELEMENTS(lu) EQ 0) THEN BEGIN
   GET_LUN,lu
   OPENW,lu,filen
   PRINT,'writing file ', filen
ENDIF
;
r=0
if(n_elements(rh) ne 0) then r=1
cstr='*'
if(r) then cstr='#'



comment = N_ELEMENTS(nocomm) EQ 0
IF(comment) THEN PRINTF,lu,cstr+' WRITTEN BY COLWR ON ', systime()
IF(comment) THEN printf,lu,cstr+' ATOM IS    ', atom.atomid
colcnv,ohm = ohm,ppd=1
if(r eq 0) then begin 
   printf,lu,'GENCOL'
;
   formt='(I2,5e12.5,6(/5e12.5))'
   countt = 0l
   tempold=col(0).temp*0.
   FOR i=0,N_ELEMENTS(col)-1 DO BEGIN
      form='(2(i4), 2x, 7e9.2, 4(/7e9.2))'
      str = STRTRIM(col(i).key,2) 
      IF(str EQ 'TEMP') THEN BEGIN
         printf,lu,col(i).key,form='(A)'
         printf,lu,col(i).nt,col(i).temp(0:col(i).nt-1) 
         tempold=col(i).temp
      endif else BEGIN
         dft = total(abs(col(i).temp-tempold))
         tprint = dft NE 0. OR countt EQ 0
         IF(tprint AND (strmid(str,0,2) EQ 'CE' OR strmid(str,0,3) EQ 'OHM' OR $
                        strmid(str,0,2) EQ 'CI')) THEN BEGIN

            PRINTF,lu,'TEMP'
            PRINTF,lu,col(i).nt,col(i).temp(0:col(i).nt-1)
            tempold=col(i).temp
            countt = countt+1
         ENDIF
         PRINTF,lu,str,form='(A)'
         IF(str EQ 'LTDR') THEN form='(2(i4),2x,5f11.4)'
         IF(str EQ 'AR85-RR') THEN form='(e9.2,2x,f9.3)'
         IF(str EQ 'SPLUPS') THEN form='(2(i4),1x,I2,8(1x,e10.3))'
         IF(str EQ 'SPLUPS9') THEN form='(2(i4),1x,I2,12(1x,e10.3))'
         keyct=STRMID(str,0,7)
         IF(str EQ 'AR85-CDI') THEN BEGIN 
            form='(2(i4)/i4)'
            PRINTF,lu,FORMAT=form,col(i).ilo+1,col(i).ihi+1,$
                   col(i).nt/5
            form='(5f9.2)'
                                ;print,form=form,col(i).data(0:col(i).nt-1)
            PRINTF,lu,FORMAT=form, col(i).data(0:col(i).nt-1)
         ENDIF ELSE IF(str EQ 'AR85-CEA') THEN BEGIN 
            form='(2(i4))'
            PRINTF,lu,FORMAT=form,col(i).ilo+1,col(i).ihi+1
            printf,lu,format='(e9.3)',col(i).data(0)
         endif else if(keyct eq 'AR85-CH') then begin 
            form='(2(i4))'
            printf,lu,format=form,col(i).ilo+1,col(i).ihi+1
            form='(3(e9.2,2x),3(f7.2,1x))'
            printf,lu,format=form, col(i).data(0:col(i).nt-1)
         endif else begin
            printf,lu,col(i).ilo+1,col(i).ihi+1,$
                   col(i).data(0:col(i).nt-1)
         endelse
      endelse
   endfor
   printf,lu,'END'
endif else begin 
   formt='(A,1x,I2,8e10.3)'
   countt = 0l
   tempold=col(0).temp*0.
   FOR i=0,N_ELEMENTS(col)-1 DO BEGIN
      form='(A,1x,2(i4), 2x, 8(1x,e9.2))'
      str = STRTRIM(getwrd(col(i).key,del=' '),2) 
      print,str
      if(str eq 'OHM') then str='OMEGA'
      IF(str EQ 'TEMP') THEN BEGIN
         printf,lu,col(i).key,col(i).nt,col(i).temp(0:col(i).nt-1),form=form
         tempold=col(i).temp
      endif else BEGIN
         dft = total(abs(col(i).temp-tempold))
         tprint = dft NE 0. OR countt EQ 0
         IF(tprint AND (strmid(str,0,2) EQ 'CE' OR strmid(str,0,5) EQ 'OMEGA' OR $
                        strmid(str,0,2) EQ 'CI')) THEN BEGIN
            PRINTF,lu,'TEMP',col(i).nt,col(i).temp(0:col(i).nt-1),form=formt
            tempold=col(i).temp
            countt = countt+1
         ENDIF
         IF(str EQ 'LTDR') THEN form='(A,1x,2(i4),2x,5f11.4)'
         IF(str EQ 'AR85-RR') THEN form='(A,1x,e9.2,2x,f9.3)'
         IF(str EQ 'SPLUPS') THEN form='(A,1x,2(i4),1x,I2,8(1x,e10.3))'
         IF(str EQ 'SPLUPS9') THEN form='(A,1x,2(i4),1x,I2,12(1x,e10.3))'
         IF(str EQ 'SHULL82') THEN form='(A,1x,2(1x,i4),8(1x,e10.3))'
         keyct=STRMID(str,0,7)
         IF(str EQ 'AR85-CDI') THEN BEGIN 
            form='(A,2x,3(1x,i4))'
            PRINTF,lu,FORMAT=form,str,col(i).ilo,col(i).ihi,$
                   col(i).nt/5
            form='(5f9.2)'
                                ;print,form=form,col(i).data(0:col(i).nt-1)
            PRINTF,lu,FORMAT=form, col(i).data(0:col(i).nt-1)
         ENDIF ELSE IF(str EQ 'AR85-CEA') THEN BEGIN 
            form='(A,2x,2(2x,i4),2x,e10.3)'
            PRINTF,lu,FORMAT=form,str,col(i).ilo,col(i).ihi,col(i).data(0)
         endif else if(keyct eq 'AR85-CH') then begin 
            form='(A,2x,2(i4))'
            printf,lu,format=form,cstr+' '+str,col(i).ilo,col(i).ihi
            form='(A,2x,3(e9.2,2x),3(f7.2,1x))'
            printf,lu,format=form, cstr+' '+str,col(i).data(0:col(i).nt-1)
         endif else begin
            printf,lu,format=form,str,col(i).ilo,col(i).ihi,$
                   col(i).data(0:col(i).nt-1)
         endelse
      endelse
   endfor
   printf,lu,'END'


endelse

if(n_elements(filen) gt 0 and n_elements(lu) eq 0) then free_lun,lu
return
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'colwr.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
