;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: meta_eff.pro
; Created by:    Philip Judge, March 8, 2006
;
; Last Modified: Thu Aug 10 12:53:34 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO meta_eff
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       meta_eff
;
; PURPOSE: gets metastable and effective quantum numbers for levels
;
; CATEGORY: HAOS-DIPER input routine
;   
; EXPLANATION:
;       Modifies atomic data in structures
;   
;       
; CALLING SEQUENCE: 
;       meta_eff
;
; INPUTS:
;       none
; OPTIONAL INPUTS: 
;       none
;   
; OUTPUTS:
;       Data are stored in common block cdiper (accessed via @cdiper)
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORD PARAMETERS: 
;       none
; CALLS:
;
; COMMON BLOCKS:
;       cdiper
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       System variable !REGIME is used to determine if levels are metastable
;
; CATEGORY:
;       
; VERSION:
;       Version 1.0 February 27, 2006
;       
;-
@cdiper
;
; Rydberg for finite mass
;
rydberg = rydinf/(1.0 + em/uu/atom.awgt)
;
;  metastable levels (same configuration as ground state of ions)
;
minev = min(lvl.ev)
lowest=!c
lvl.meta = 0
lvl.eff = 0.
lvl(lowest).meta=1
dbopen,'atom_ip'
icount = 0l
;
FOR k=0,atom.nk-1 DO BEGIN
   IF(lvl(k).ion NE lvl(lowest).ion) THEN lowest=k ;  lowest level of ion stage
   metac = lvl(k).orb(0) EQ lvl(lowest).orb(0) AND $
      lvl(k).orb(1) EQ lvl(lowest).orb(1) AND $
      lvl(k).orb(2) EQ lvl(lowest).orb(2)
   metat = lvl(k).term(0) EQ lvl(lowest).term(0)
   IF(!regime NE 0) THEN metat = 1  ; for regime=1 or 2, all levels of ground config are metastable
   IF(metac AND metat) THEN lvl(k).meta=1
;
; effective qn's
;
   nexti = WHERE(lvl.ion EQ lvl(k).ion+1,count)
   IF(count GT 0) THEN BEGIN 
      ground = MIN(lvl(nexti).ev)
      dev = ground-lvl(k).ev
      IF(dev GT 0. AND (lvl(k).term(1) eq 0 OR $
         lvl(k).term(1) EQ lvl(nexti(0)).term(0))) THEN $
         lvl(k).eff = lvl(k).ion*SQRT(rydberg/ee/dev)  
   ENDIF ELSE BEGIN 
      icount = icount+1
      str = 'atom='+string(atomn(atom.atomid))+',ion='+string(lvl(k).ion)
      str = strcompress(str,/rem)
      j = dbfind(str,/silent)
      dbext,j,'ip',ground
      dev = ground-lvl(k).ev
      IF(dev GT 0. AND lvl(k).term(1) eq 0) THEN $
         lvl(k).eff = lvl(k).ion*SQRT(rydberg/ee/dev)  
   ENDELSE
ENDFOR
dbclose,'atom.ip'
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'meta_eff.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
