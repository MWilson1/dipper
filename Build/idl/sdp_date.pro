pro sdp_date, date
;+
; NAME:
;	SDP_DATE
;
; PURPOSE:
;	
;
; CATEGORY:
;	[Part of the HAO Spectral Diagnostics Package (HAO-SDP)]
;
; CALLING SEQUENCE:
;	SDP_DATE,date
;
;	
;
; INPUTS:
;	
;
; KEYWORDS:
;	
;
; OUTPUTS:
;	date - string in format '10-JUN-1999'
;	
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	
;
;
; MODIFICATION HISTORY:
;	Written, P. Judge, HAO, NCAR June, 1994.
;-

on_error,2                        ;Return to caller if an error occurs
;
;
if(n_Params(0) lt 1) then begin
  print,'sdp_date,date'
endif
;
str=systime(0)
date = getwrd(str,2)+'-'+getwrd(str,1)+'-'+getwrd(str,4)


end

