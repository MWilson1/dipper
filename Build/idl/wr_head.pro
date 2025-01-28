pro wr_head,unit,head
;+
; NAME:
;	WR_HEAD
;
; PURPOSE:
;	Write header information to the Spectral Diagnostics 
;	atom files on logical unit unit
;	
;
; CATEGORY:
;	[Part of the HAO Spectral Diagnostics Package (HAO-SDP)]
;
; CALLING SEQUENCE:
;	WR_HEAD,UNIT,HEAD
;
;	
; INPUTS:
;	FILE: file output
;
; KEYWORDS:
;	none.
;
; OUTPUTS:
;	HEAD: header output, consisting of a structure HEAD.KEY, HEAD.TEXT
;	
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	none
;
; EXAMPLE:
;	To obtain header 
;		WR_HEAD,
;
;
; MODIFICATION HISTORY:
;	Written, P. Judge, HAO, NCAR June, 1994. PART
;-

on_error,2                        ;Return to caller if an error occurs

if(n_params(0) lt 2) then begin
  print,'wr_head,unit,head'
  return
endif

printf,unit,'*'
printf,unit,'*+'
for i=0,n_elements(head)-1 do begin
  if(strtrim(head(i).key,2) ne '') then $
  printf,unit,'* '+head(i).key+': '+strtrim(head(i).text,2)
endfor
printf,unit,'*-'
printf,unit,'*'
;
return
end
