;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: fillvl.pro
; Created by:    judge, June 12, 2006
;
; Last Modified: Thu Aug 10 12:45:19 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
pro fillvl,iatom,imin,imax
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       fillvl
;
; PURPOSE: 
;  
;  fills/fixes energy level structure to include ion stages, ionization energies
;  
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       fillvl
;
; INPUTS:
;       iatom  atomic number (integer)
;       imin minimum ion spectrum to be included 
;       imax maximum "
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
;       None
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       cdiper.  structures atom and lvl are updated.
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
;       Written June 12, 2006 by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, June 12, 2006
;-
;
;
@cdiper
;
nol = 0
IF(n_elements(lvl) EQ 1 AND lvl(0).label EQ '') THEN nol = 1 ; no earlier data
FOR i = imin,imax DO BEGIN 
   k = where(lvl.ion EQ i,c)
   IF(c EQ 0) THEN BEGIN
      new = ground(iatom,i)
      lvl = [lvl,new]
   ENDIF
ENDFOR
IF(nol) THEN lvl = lvl(1:*)  ; all we have are data here
atom.nk = n_elements(lvl)
atomsort,/ionsort
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add in ionization potentials
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
dbopen,'atom_ip'
FOR i = imin+1,imax DO BEGIN
   str = 'atom=' + STRTRIM(STRING(iatom), 2) + ',ion='+strtrim(string(i-1), 2)
   j = dbfind(str,/sil,count = count)
   IF(count EQ 0) THEN messdip,'FILLVL: no ionization potential data'
   dbext,j,'ip',ip
   k = where(lvl.ion ge i)
   lvl(k).ev = lvl(k).ev+ip(0)
ENDFOR
dbclose
;
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'fillvl.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
