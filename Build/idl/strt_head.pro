pro strt_head,header,filen=filen, chianti=chianti, kurucz = kurucz,question = question
;+
; NAME:
;	STRT_HEAD
;
; PURPOSE:
;	For a non HAO-SPD this will create the start of a header file 
;       needed for the atom file
;
; CATEGORY:
;	[Part of the HAO Spectral Diagnostics Package (HAO-SDP)]
;
; CALLING SEQUENCE:
;	STRT_HEAD,header, filen=filen
;	
;
; INPUTS:
;
; KEYWORDS:
;	name of file to read if you want to read new atom file
;
; OUTPUTS:
;	HEADER: header information
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None
;
; EXAMPLE:
;	To obtain a starting header for a file 
;		STRT_HEAD, filen='atom.test', testhead
;
;
; MODIFICATION HISTORY:
;	Written, P. Judge, HAO, NCAR June, 1994.
;-
@cdiper
;
if(n_params(0) lt 1) then begin
  print,'strt_head,header, filen=filen'
  return
endif
;
;
if(n_elements(filen) ne 0) then atomrd,filen
;
; get header keywords
;
header = hdrdef
keys=header.key
;
;  define name and isosequence
;
vname=!xuvtop+'/VERSION'
openr,lu,/get,vname
ver = ''
readf,lu,ver
free_lun,lu
sdp_date,date
for i=0,n_elements(keys)-1 do begin
  if(keys(i) eq 'NAME') then $
    header(i).text=atom.atomid+' '+ roman(lvl(0).ion)
  if(keys(i) eq 'ISOSEQUENCE') then $
    header(i).text=' '
  if(keys(i) eq 'LEVELS') then $
    header(i).text=strtrim(string(atom.nk-1),2)+ ' levels plus continuum'
  if(keys(i) eq 'B-B_TRANSITIONS') then $
    header(i).text=strtrim(string(atom.nline),2)+ ' lines'
  if(keys(i) eq 'PHOTOIONIZATION') then begin 
     if(atom.nrad eq atom.nline) then header(i).text=' NONE'
  endif
  if(keys(i) eq 'UPDATED') then $
    header(i).text='Written by str_head on '+date
  if(keys(i) eq 'WARNING') then $
    header(i).text='!! MORE HEADER INFORMATION MUST BE ADDED'
if(n_elements(chianti) ne 0) then begin
  sdp_date,date
  if(keys(i) eq 'ENERGIES') then begin
    header(i).text='CHIANTI_'+ver+'  [*]'
    for k=0,n_elements(e)-1 do header(i).text=header(i).text+ ' '+e(k)
    IF(n_elements(question) NE 0) THEN BEGIN
       header(i).text='CHIANTI_'+ver+' Uncertain designation ['
       FOR kk = 0,n_elements(question)-2 DO BEGIN 
          header(i).text = header(i).text+ strtrim(string(question(kk)),2)+' '
       ENDFOR
       header(i).text = header(i).text+ strtrim(string(question(n_elements(question)-1)),2)+'], CHIANTI_4.2 [*]'
    ENDIF
 endif
  if(keys(i) eq 'ENERGIES-ERR') then $
    header(i).text='-1 [*]'
  if(keys(i) eq 'ENERGIES-NOT') then $
    header(i).text='-1 [*]'
  if(keys(i) eq 'OHM-REF') then $
    header(i).text='CHIANTI_4.2 [*]'
  if(keys(i) eq 'OHM-ERR') then $
    header(i).text='10 [*]'
  if(keys(i) eq 'OHM-NOT') then $
    header(i).text='generic_error [*]'
;
  if(keys(i) eq 'GFS-REF') then $
    header(i).text='CHIANTI_'+ver+' [*]'
  if(keys(i) eq 'GFS-ERR') then $
    header(i).text='10 [*]'
  if(keys(i) eq 'GFS-NOT') then $
    header(i).text='generic_error [*]'
  if(keys(i) eq 'WARNING') then $
    header(i).text=''
  if(keys(i) eq 'INPUT_BY') then $
    header(i).text='conv.pro '+date
ENDIF

;
if(n_elements(kurucz) ne 0) then begin
  sdp_date,date
  if(keys(i) eq 'ENERGIES') then begin
    header(i).text='Kurucz_CD_data  [*]'
    for k=0,n_elements(e)-1 do header(i).text=header(i).text+ ' '+e(k)
  endif
  if(keys(i) eq 'ENERGIES-ERR') then $
    header(i).text='-1 [*]'
  if(keys(i) eq 'ENERGIES-NOT') then $
    header(i).text='Kurucz_CD_data_generic_error [*]'
  if(keys(i) eq 'OHM-REF') then $
    header(i).text='Kurucz_CD_data [*]'
  if(keys(i) eq 'OHM-ERR') then $
    header(i).text='100 [*]'
  if(keys(i) eq 'OHM-NOT') then $
    header(i).text='Kurucz_CD_data_generic_error [*]'
;
  if(keys(i) eq 'GFS-REF') then $
    header(i).text='Kurucz_CD_data [*]'
  if(keys(i) eq 'GFS-ERR') then $
    header(i).text='100 [*]'
  if(keys(i) eq 'GFS-NOT') then $
    header(i).text='Kurucz_CD_data_generic_error [*]'
  if(keys(i) eq 'WARNING') then $
    header(i).text=''
  if(keys(i) eq 'INPUT_BY') then $
    header(i).text=' '+date
endif

;  
endfor
k=where(strtrim(header.key,2) ne '')
header = header(k)
return
end




