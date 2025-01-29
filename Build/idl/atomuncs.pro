;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: atomuncs.pro
; Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, August 20, 1996
;
; Last Modified: Fri Jun  2 15:23:19 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION atomuncs, head, kwd, nidx
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       atomuncs     (function)
;
; PURPOSE:  To extract data accuracies from atom file headers.
;
;       The purpose of this function is to extract data accuracies from the
;       atom file headers, based on the input keyword.
;
; CALLING SEQUENCE:
;
;       result = atomuncs(head, kwd, nidx [,help=help])
;
; INPUTS:
;       head - atom file header structure obtained from headrd.pro.
;        kwd - the header keyword containing the accuracies to be extracted.
;       nidx - the number of accuracies to be extracted.
;
;       For example, if extracting oscillator strength accruacies, the call
;       would be:
;
;       result = atomuncs(head, 'gfs-err', nline)
;
;       where 'gfs' is the keyword to search for in the header structure,
;       and nline is the number of oscillator strengths in the atom file.
;       The returned result is an integer array with nline elements,
;       containing the accuracy of each data value.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Returns an integer array with nidx elements containing the accuracy
;       of each data value.  A default value of -1 is entered where there is
;       no accuracy information available.
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
;       Part of the HAOS-DIPER.
;
; PREVIOUS HISTORY:
;       Written August 20, 1996, by Randy Meisner, HAO/NCAR, Boulder, CO
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, August 20, 1996
;-
;
IF(N_PARAMS() NE 3) THEN BEGIN
  PRINT, ''
  PRINT, 'Usage:  result = atomuncs(head, kwd, nidx [,help=help])'
  PRINT, ''
  RETURN, -1
ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define output array to be returned.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!priv = 2
idx = intarr(nidx)
kwd = STRUPCASE(kwd)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine header keyword text.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hidx = WHERE(head.key EQ kwd)
IF(hidx(0) LT 0) THEN BEGIN
   PRINT, '% GET_ERR: Keyword not available in header - ' + kwd
   RETURN, idx-99
ENDIF
htxt = STRTRIM(head(hidx(0)).text, 2)
IF(STRLEN(htxt) EQ 0) THEN BEGIN
   PRINT, '% GET_ERR: No accuracies for input keyword - ' + kwd
   RETURN, idx-99
ENDIF
keyarr = str_sep(htxt, ',')
keyarr = STRTRIM(keyarr, 2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loop over each accuracy in the keyarr array.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count = 0
FOR i = 0, N_ELEMENTS(keyarr)-1 DO BEGIN
   acc = getwrd(keyarr(i), 0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine the range of the accuracy.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   blank = STRPOS(keyarr(i), ' ')
   range = STRMID(keyarr(i), blank+1, 10)
   range = STRMID(range, 1, STRLEN(range)-2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If the accuracy range includes all values,
; then do the following (i.e., '*'):
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   IF(range EQ '*') THEN BEGIN
; Fill in the remaining values of the accuracy
; array with this value.
      FOR j = count, nidx-1 DO idx(j) = FIX(acc)
   ENDIF ELSE BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If the reference range only covers some of
; the values, then determine the range and
; fill in the accuracy array values with the
; proper value.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      dash = STRPOS(range, '-')
      IF(dash GE 0) THEN BEGIN
         first = FIX(STRMID(range, 0, dash))
         last = FIX(STRMID(range, dash+1, 10))
         FOR j = first, last DO BEGIN
            idx(j) = FIX(acc)
            count = j+1
         ENDFOR
      ENDIF ELSE BEGIN
         temparr = str_sep(range, ' ')
         FOR ii = 0, N_ELEMENTS(temparr)-1 DO BEGIN
            idx(FIX(temparr(ii))) = FIX(acc)
            count = ii+1
         ENDFOR
      ENDELSE
   ENDELSE
ENDFOR
RETURN, idx
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'atomuncs.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
