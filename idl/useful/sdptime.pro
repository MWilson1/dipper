;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: sdptime.pro
; Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, October 11, 1996
;
; Last Modified: Fri Jun  2 14:48:20 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION sdptime,  alpha = alpha
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       sdptime     (function)
;
; PURPOSE:
;       The purpose of this function is to obtain the current system time,
;       convert it to a condensed format, and return the condensed value in a
;       single string variable.
;
; CALLING SEQUENCE:
;
;       result = sdptime()
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Returns a string variable containing the current system time in a
;       condensed format.
;
;       e.g.  Fri Oct 11 15:20:09 1996 is returned as 961011 152009
;                                                    (yymmdd hhmmss)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
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
;       Part of the HAOS-DIPER.
;
; PREVIOUS HISTORY:
;       Written October 11, 1996, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, October 11, 1996
;-
;
IF(N_PARAMS() NE 0) THEN BEGIN
  PRINT, ''
  PRINT, 'Usage:  result = sdptime()'
  PRINT, ''
  RETURN, -999
ENDIF
IF(n_elements(alpha) NE 0) THEN BEGIN
   str=systime(0)
   return, getwrd(str,2)+'-'+getwrd(str,1)+'-'+getwrd(str,4)
ENDIF
;
time = STRCOMPRESS(systime())   ; System time.
timearr = str_sep(time, ' ')
day = timearr(2)                ; Day of month.
IF(fix(day) LT 10) THEN day = '0'+day
year = timearr(4)               ; Full year.
year = STRMID(year,2,2)         ; Two digit year (i.e., 96 for 1996).
amo = timearr(1)                ; Name of month.
CASE amo OF                     ; Determine month number.
   'Jan' : mo = '01'
   'Feb' : mo = '02'
   'Mar' : mo = '03'
   'Apr' : mo = '04'
   'May' : mo = '05'
   'Jun' : mo = '06'
   'Jul' : mo = '07'
   'Aug' : mo = '08'
   'Sep' : mo = '09'
   'Oct' : mo = '10'
   'Nov' : mo = '11'
   'Dec' : mo = '12'
ENDCASE
clock = timearr(3)
clockarr = str_sep(clock, ':')
hr = clockarr(0)                ; Hour.
mn =clockarr(1)                 ; Minutes.
sec = clockarr(2)               ; Seconds.
time = year+mo+day+' '+hr+mn+sec
RETURN, time
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'sdptime.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
