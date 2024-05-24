;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: td_line_dx.pro
; Created by:    Philip G. Judge, September 5, 1996
;
; Last Modified: Mon Aug  7 21:51:53 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td_line_dx, debug=debug, help=help
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td_line_dx
;
; PURPOSE: attempts to find end points for line transitions in term diagram
;       
; EXPLANATION:
;             finds end-point displacements for transition lines
;             algorithm:
;             1. levels are grouped such that levels in same configuration
;                close in energy are considered to form a group
;             2. transitions are ordered:
;                original order
;                  all lines starting or ending on same group,
;                    upper level energy in decreasing order
;                      lower level energy in decreasing order
;                reverse order if lower-upper is right-left
;             3. within bound-bound groups, increment index by 2 to
;                increase clarity
;
; CALLING SEQUENCE: 
;       td_line_dx, 
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
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
;       
; PREVIOUS HISTORY:
;       This was implemented by Mats Carlsson circa 1988
;       Header updated September 5, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;  Error found by P. Judge, 10-Jan-1994:  when the lowest
;  ionization stage is not neutral, then the procedure
;  crashed.  Fix to subtract MINION from idx and jdx.
;       
; VERSION:
;       Version 1, September 5, 1996
;-
;
@cdiper
@ctermdiag
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'td_line_dx'
   RETURN
ENDIF
IF (N_ELEMENTS(debug) EQ 0) THEN debug=0
   
text=''
lindex=intarr(atom.nrad)-1           ; order variable

low_group=INDGEN(atom.nk)            ; like low_fine but grouping together
; all levels with same configuration and
; close in energy
delta_e=(top-bottom)/10.
FOR ii=1,atom.nk-1 DO BEGIN
   FOR jj=ii-1,0,-1 DO BEGIN
      IF (config(ii) EQ config(jj)) AND (abs(lvl(jj).ev-lvl(ii).ev) LT delta_e) $
         THEN GOTO,same_group
   ENDFOR
   GOTO, end_loop
same_group:
   low_group(ii)=low_group(jj)
end_loop:
ENDFOR

igroup=intarr(atom.nk)               ; flag=1 if level is group-structure
iw=WHERE(low_group NE INDGEN(atom.nk),count)
IF(count NE 0) THEN BEGIN
   igroup(iw)=1
   igroup(low_group(iw))=1
ENDIF

IF (debug EQ 1) THEN BEGIN
   PRINT,'igroup:'
   PRINT,igroup
   PRINT,'low_group:'
   PRINT,low_group
ENDIF

;
; sort transitions in order of
; 1. bb,bf
; 2. angle
; 3. irad
;
angle=fltarr(atom.nrad)
dxs=(positions(trn.jrad)-positions(trn.irad))*!d.x_vsize*!x.s(1)
dys=(evplot(trn.jrad)-evplot(trn.irad))*!d.y_vsize*!y.s(1)
iw=WHERE(dxs NE 0.0,count)
IF(count NE 0) THEN angle(iw)=90.-abs(atan(dys(iw)/dxs(iw))*180./!pi)
sort_y=10.*angle+(trn.irad)
IF (atom.nline LT atom.nrad) THEN sort_y(atom.nline)=sort_y(atom.nline:atom.nrad-1)+1000.
kr_order=SORT(sort_y)
IF (debug EQ 1) THEN BEGIN
   PRINT,'angles:'
   PRINT,angle
   PRINT,'kr_order:'
   PRINT,kr_order
ENDIF

; go through transitions one by one and check if group-structure is
; involved

placed=intarr(atom.nrad)             ; placed=1 if transition has been indexed
FOR kr3=0,atom.nrad-1 DO BEGIN
   kr=kr_order(kr3)
   ii=0
   IF (kr LT atom.nline) THEN nmax=atom.nrad ELSE nmax=0
   IF (placed(kr) NE 1) THEN BEGIN
      WHILE (lindex(ii) NE -1) DO ii=ii+1 ; find first free number
      i=trn(kr).irad
      j=trn(kr).jrad
      IF (igroup(i) EQ 0) AND (igroup(j) EQ 0) THEN BEGIN
         lindex(ii)=kr          ; no group-structure involved
         placed(kr)=1           ; index transition
      ENDIF ELSE BEGIN          ; group-structure involved
         ngroup=1               ;  number of transitions of ensamble
kr_group=intarr(atom.nrad)                  ;  indices of ensamble
kr_group(0)=kr
IF (kr LT atom.nrad-1) THEN BEGIN
   FOR kr2=0,atom.nrad-1 DO BEGIN    ;  find all other lines involving
      IF (placed(kr2) NE 1) AND (kr2 NE kr) THEN BEGIN ;  same groups
         i2=trn(kr2).irad
         j2=trn(kr2).jrad
         IF ( (low_group(i2) EQ low_group(i)) AND $
              (low_group(j2) EQ low_group(j)) ) THEN BEGIN
            kr_group(ngroup)=kr2
            ngroup=ngroup+1
         ENDIF                  ;else begin
;              if ( (low_group(i2) eq low_group(i)) or $
;                   (low_group(j2) eq low_group(j)) ) then begin
;                if (kr2 lt nline) then begin
;                  kr_group(ngroup)=kr2
;                  ngroup=ngroup+1
;                endif
;              endif
;            endelse
      ENDIF
   ENDFOR
ENDIF
IF (debug NE 0) THEN BEGIN
   PRINT,'ngroup:',ngroup
   PRINT,'kr,low_group(i),low_group(j):'
   FOR kr3=0,ngroup-1 DO BEGIN
      kr2=kr_group(kr3)
      PRINT,kr2,low_group(trn(kr2).irad),low_group(trn(kr2).jrad)
   ENDFOR
ENDIF
IF (ngroup EQ 1) THEN BEGIN     ; no other lines
   lindex(ii)=kr
   placed(kr)=1
ENDIF ELSE BEGIN
   sort_y=trn(kr_group(0:ngroup-1)).jrad*atom.nrad+trn(kr_group(0:ngroup-1)).irad
   order=SORT(sort_y)           ; sort on irad,jrad
   IF (positions(i) LT positions(j)) THEN order=reverse(order)
   IF (ngroup-1 LT (nmax-ii)/2) THEN BEGIN ; if enough space,
      FOR kr2=0,ngroup-1 DO BEGIN ; increment with 2
         lindex(ii)=kr_group(order(kr2)) ; to increase clarity
         ii=ii+2                ; increment 1 for continua
      ENDFOR
   ENDIF ELSE BEGIN
      FOR kr2=0,ngroup-1 DO BEGIN ; minimum increment
         WHILE (lindex(ii) NE -1) DO ii=ii+1
         lindex(ii)=kr_group(order(kr2))
      ENDFOR
   ENDELSE
   placed(kr_group(0:ngroup-1))=1
ENDELSE
ENDELSE
IF (debug NE 0) THEN BEGIN
   PRINT,'lindex:'
   PRINT,lindex
   READ,'<cr> to continue',text
   IF (STRLEN(text) NE 0) THEN BEGIN
      IF (STRUPCASE(STRMID(text,0,1)) NE 'C') THEN stop
      debug=0
   ENDIF
ENDIF
ENDIF
ENDFOR
;
;
; 10-Jan-1994 original code
;
;maxion=max(ion)
;!c=0
;ic=intarr(maxion)+1
;il=intarr(maxion)+1
;
;new code
maxion=MAX(lvl.ion)
minion=MIN(lvl.ion)
!c=0
ic=intarr(maxion-minion+1)+1
il=intarr(maxion-minion+1)+1
; end change 10-jan-1994

FOR ii=0,atom.nrad-1 DO BEGIN
; calculate displacement
; consider bb and bf separately
; independent series of displacements
; within each ionization stage
;
   kr=lindex(ii)
   i=lvl(trn(kr).irad).ion-minion
   IF (kr LT atom.nline) THEN BEGIN
      idx(kr)=il(i)
      jdx(kr)=il(i)
      il(i)=il(i)+1
   ENDIF ELSE BEGIN
      idx(kr)=ic(i)
      jdx(kr)=ic(i)
      ic(i)=ic(i)+1
   ENDELSE
ENDFOR
max_dx_line=1
IF (atom.nline GT 0) THEN BEGIN
   max_dx_line=MAX(idx(0:atom.nline-1)) > MAX(jdx(0:atom.nline-1))
ENDIF
IF (atom.nrad GT atom.nline) THEN BEGIN
   max_dx_cont=MAX(idx(atom.nline:atom.nrad-1)) > MAX(jdx(atom.nline:atom.nrad-1))
ENDIF ELSE BEGIN
   max_dx_cont=max_dx_line
ENDELSE

!c=0

RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'td_line_dx.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
