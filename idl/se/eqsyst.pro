;
;******************************************************************
;
pro eqsyst,a,b,improve=improve
;+
; eqsyst: version 4 FULLY PORTABLE
; Uses Mats Carlsson's lu decomposition with iterative improvement
; P. Judge 2-December-1995
;-
IF (N_ELEMENTS(improve) EQ 0) THEN improve = 1
IF(improve NE 0) THEN BEGIN
   mstore = a
   bstore = b
ENDIF
;
; first transform to column format
a=transpose(a)
lud,a
lub,a,b
FOR i = 1,improve DO BEGIN
   resid = mstore#b - bstore
   lub,a,resid
   b = b-resid
ENDFOR

RETURN
end
