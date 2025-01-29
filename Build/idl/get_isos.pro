pro get_isos,elem,charge,isos,config=config,term=term,g0=g0
;+
; NAME:
;	GET_ISOS
;
; PURPOSE:
;	
;
; CATEGORY:
;	[Part of the HAO Spectral Diagnostics Package (HAO-SDP)]
;
; CALLING SEQUENCE:
;	GET_ISOS,ELEM,CHARGE,ISOS,config=config,term=term,g0=g0
;
;	
;
; INPUTS:
;	elem: string containing name of element in first word
;	charge: charge of the ion of this element
; KEYWORDS:
;	config - string output containing configuration (e.g. 1s2)
;       
; OUTPUTS:
;	isos - isosequence element name (e.g. 'He')
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; EXAMPLE:
;	To obtain isosequence name 
;		GET_ISOS,'FE',10,isos,conf=conf
;
;
; MODIFICATION HISTORY:
;	Written, P. Judge, HAO, NCAR June, 1994.
;       modified to include term and g0 keywords   
;-
@cdiper
;
; 
if(n_params(0) lt 2) then begin
  print,'get_isos,elem,charge,isos,config=config'
  return
endif
;
;  get atomic number 
;
isos=atomn(atomn(elem)-charge)
IZ=atomn(ISOS)  ; 
if(iz lt 1) then begin
   messdip,/inf,'WARNING: IZ LT 1, using default values'
   isos = 'Proton'
   config = '0s'
   g0 = 1.0
   term = '1SE'
   RETURN
endif

IF(iz GT 92) THEN BEGIN
  print,'get_isos: isosequence out of range, iz=',iz
  isos='NO-ID'
  return
endif  
conf=['1s','1s2','1s2 2s','1s2 2s2','1s2 2s2 2p',$
'1s2 2s2 2p2', $
'1s2 2s2 2p3', $
'1s2 2s2 2p4', $
'1s2 2s2 2p5', $
'1s2 2s2 2p6', $
'1s2 2s2 2p6 3s', $
'1s2 2s2 2p6 3s2', $
'1s2 2s2 2p6 3s2 3p', $
'1s2 2s2 2p6 3s2 3p2', $
'1s2 2s2 2p6 3s2 3p3', $
'1s2 2s2 2p6 3s2 3p4', $
'1s2 2s2 2p6 3s2 3p5', $
'1s2 2s2 2p6 3s2 3p6', $
'1s2 2s2 2p6 3s2 3p6 4s', $
'1s2 2s2 2p6 3s2 3p6 4s2', $
'1s2 2s2 2p6 3s2 3p6 3d 4s2', $
'1s2 2s2 2p6 3s2 3p6 3d2 4s2', $
'1s2 2s2 2p6 3s2 3p6 3d3 4s2', $
'1s2 2s2 2p6 3s2 3p6 3d5 4s', $
'1s2 2s2 2p6 3s2 3p6 3d5 4s2', $
'1s2 2s2 2p6 3s2 3p6 3d6 4s2', $
'1s2 2s2 2p6 3s2 3p6 3d7 4s2 ', $
'1s2 2s2 2p6 3s2 3p6 3d8 4s2']

opens = STRARR(N_ELEMENTS(conf))
term = STRARR(N_ELEMENTS(conf))
FOR i = 0,N_ELEMENTS(conf)-1 DO BEGIN
   opens(i) = getwrd(conf(i),0,/last)
   CASE (opens(i)) OF
      '1s': term(i) = '2SE'
      '2s': term(i) = '2SE'
      '3s': term(i) = '2SE'
      '4s': term(i) = '2SE'
      '1s2': term(i) =  '1SE'
      '2s2': term(i) =  '1SE'
      '3s2': term(i) =  '1SE'
      '4s2': term(i) =  '1SE'
      '2p': term(i) =  '2PO'
      '3p': term(i) =  '2PO'
      '4p': term(i) =  '2PO'
      '2p2': term(i) =  '3PE'
      '3p2': term(i) =  '3PE'
      '4p2': term(i) =  '3PE'
      '2p3': term(i) = '4SO'
      '3p3': term(i) = '4SO'
      '4p3': term(i) = '4SO'
      '2p4': term(i) =  '3PE'
      '3p4': term(i) =  '3PE'
      '4p4': term(i) =  '3PE'
      '2p5': term(i) =  '2PO'
      '3p5': term(i) =  '2PO'
      '4p5': term(i) =  '2PO'
      '2p6': term(i) =  '1SE'
      '3p6': term(i) =  '1SE'
      ELSE:
   ENDCASE
ENDFOR
;
; special cases, iron group- approximate for ionized species
;
term(20:27) = ['2DE','3FE','4FE','7SE','6SE','5DE','4FE','3FE']
g0 = fltarr(N_ELEMENTS(term))
FOR i = 0,N_ELEMENTS(term)-1 DO BEGIN
   tsp1 = STRMID(term(i),0,1)
   l = STRMID(term(i),1,1)
   l = STRPOS(designations,l)
   g0(i) = (2*l+1)*tsp1
ENDFOR

n=N_ELEMENTS(conf)
IF(iz LE n) THEN BEGIN
   config=conf(iz-1) 
   term = term(iz-1)
   g0 = g0(iz-1)
ENDIF ELSE BEGIN
   config=conf(n-1)+'...'
   term=term(n-1)+'...'
   g0=1.
ENDELSE
   
return
end

