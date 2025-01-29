pro rd_head,file,head,dir=dir
;+
; NAME:
;	RD_HEAD
;
; PURPOSE: Extracts header information from DIAPER ascii atomic files
;
; CATEGORY: HAOs DIAPER documentation
;
; CALLING SEQUENCE:
;	RD_HEAD,FILE,HEAD
;	
; INPUTS:
;	FILE: file input
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
;	To obtain header in structure variable head,
;		RD_HEAD,file,head
;
;
; MODIFICATION HISTORY:
;	Written, P. Judge, HAO, NCAR June, 1994. 
;	Bug corrected, P. Judge, HAO, NCAR Aug, 1994: head(0:i) returned
;-

if(n_params(0) lt 2) then begin
  print,'rd_head,file,head'
  return
endif
spawn,'if (-e dums) rm dums'
fil = file
IF(N_ELEMENTS(dir) NE 0) THEN BEGIN
   j = STRLEN(file)
   FOR i = j-1,0,-1 DO BEGIN
      IF(STRMID(file,i,1) EQ '/') THEN BEGIN
         di = STRMID(file,0,i)
         fil = STRMID(file,i+1,j-i-1)
         GOTO,found
      ENDIF
   ENDFOR
   found:
   atom_info,fil,PRINT="cat > dums",di = di
ENDIF ELSE atom_info,fil,PRINT="cat > dums"
;spawn,'more dums'
def_head,head
;
str=' '
i=-1
openr,readu,'dums',/get
while not eof(readu) do begin
  readf,readu,str
  j=strpos(str,':')
  if(j gt 0) then begin
    i=i+1
    head(i).key =strtrim(strcompress(strmid(str,0,j)),2)
    n=strlen(str)
    head(i).text=strcompress(strmid(str,j+1,n-j+1))
  endif
endwhile
free_lun,readu
if(i ge 0) then begin
  head=head(0:i)
endif else begin
  print,'rd_head: no header data in file ', file
  i=0
  head=head(0:i)
endelse
return
spawn,'if (-e dums) rm dums'
end

