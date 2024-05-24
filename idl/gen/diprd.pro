;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: diprd.pro
; Created by:    Randy Meisner, HAO/NCAR, Boulder, CO, February 21, 1997
;
; Last Modified: Thu Aug 17 13:13:31 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO diprd, elem, ions, nocheck = nocheck, enidx = enidx, nofill = nofill
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:  diprd     (procedure)
;       
;
; PURPOSE:  To extract data for atomic ions from the database, to be
;          stored in the cdiper common block structures.
;       
;
; CALLING SEQUENCE:
;
;       diprd, elem, ions, nocheck = nocheck, enidx=enidx, nofill = nofill
;
; INPUTS:
;       elem  'O' or 8
;       ions  smallest and largest ions to read (ions=charge +1), for
;       example  ions=[2,6] will try to store ions O II through O VI
;       or ions=2 will store just O II
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
;       nocheck   if set do not check the data 
;       enidx   if set read these entries from the energy level database
;       nfill   if set do not add extra ion stages   
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       cdiper
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
;       Written February 21, 1997, by Randy Meisner, HAO/NCAR, Boulder, CO
;       re-written June 9, 2006 PGJ
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, February 21, 1997
;-
;
@cdiper
IF(N_PARAMS() LT 1) THEN BEGIN
  messdip, 'Usage:  diprd, elem [, ions]',/inf
  RETURN
ENDIF
zparcheck,'diprd',elem,1,[1,2,3,7,13,14,15],0
fill = n_elements(nofill) EQ  0
eleml = atomn(elem,/number)  ; make it an integer
atomid = atomn(elem,/string)
atom.atomid = atomid
;
IF(eleml LT 1) THEN messdip,'DIPRD: atomic number must be >0'
IF(eleml GT mxpqn) THEN messdip,'DIPRD: atomic number must be le '+string(mxpqn)
;
ni = n_elements(ions)
IF(ni EQ 0) THEN BEGIN 
   ionsl = 1+indgen(eleml+1)
ENDIF ELSE IF (ni EQ 1) THEN begin
   ionsl = [ions,ions+1]

ENDIF ELSE BEGIN 
   ionsl = ions(0)+indgen(ions(1)-ions(0)+2)
ENDELSE
;
ionsl = ionsl(sort(ionsl))
;
imin = min(ionsl)
imax = max(ionsl)
IF(imin LT 1) THEN messdip,'DIPRD: ion number (core charge) must be >0'
IF(imin GT eleml) THEN messdip,'DIPRD: ion number (core charge) must be le '+$
   string(eleml)

ni = n_elements(ionsl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SEARCH FOR ENERGY DATA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dbopen, 'atom_lvl,atom_bib'
IF(n_elements(enidx) eq 0) THEN BEGIN 
   str = 'atom=' + STRING(eleml) + ',' + $
   strtrim(string(imin), 2) + '<ion<' + $
   strtrim(string(imax), 2)
   enidx = dbfind(str,/silent)
   
ENDIF
;
IF(enidx(0) le 0) THEN BEGIN
   messdip, 'No energy levels in database. Loading ion stages only.',/inf
   dbclose
   dipdef
   atom.atomid = atomid
   GOTO, skip1
ENDIF
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; level data 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
enidx = dbsort(enidx,'ion,e')
dipdef
atom.nk = n_elements(enidx)
atom.atomid = atomid
lvl = replicate(lvldef,atom.nk)
;
str = 'atom, ion, e, g, coupling, glande, label' 
dbext, enidx, str,ato, ion,  ev, g, coupling,glande, label
str = 'tjp1,term1,orb1,term2,orb2,term3,orb3,bib_ref'
dbext,enidx,str, tjp1,term1,orb1,term2,orb2,term3,orb3,ref
dbclose
;
lvl.ion =  ion
lvl.ev =  ev*cc*hh/ee ; cm-1 to eV
lvl.g =  g
lvl.coupling =  coupling
lvl.glande =  glande
lvl.label =  label
lvl.tjp1 =  fix(g)
lvl.term(0) = term1
lvl.orb(0) = orb1
lvl.term(1) = term2
lvl.orb(1) = orb2
lvl.term(2) = term3
lvl.orb(2) = orb3
;
lvl.tsp1 = lvl.term(0)/100
lvl.bigl = (lvl.term(0)-lvl.tsp1*100)/10
lvl.n = lvl.orb(0)/100
lvl.smalll = (lvl.orb(0)-lvl.n*100)/10
lvl.active = lvl.orb(0) -lvl.n*100 -lvl.smalll/10
pa = ['E','O']
lvl.parity = pa(lvl.term(0)-lvl.tsp1*100-lvl.bigl*10)
lvl.ref = ref
;
;
; add missing ion stages
;
skip1:
IF(fill) THEN fillvl,eleml,imin,imax 
;
lvl = lvl(sort(lvl.ev))
;
; atomic weight and abundance.
;
aa = abmass(eleml)
atom.abnd = aa(0)
atom.awgt = aa(1)
;
; B-B radiative transitions
;
trnrd, enidx = enidx
;
; set quantum numbers- must do this before bfrd
;
qn
;
; B-F radiative transitions
;
bfrd
;
; check completeness of transition data
;
multchk
;
; collisional data.
;
IF(!regime NE 2) THEN BEGIN 
   cbbrd, enidx = enidx
   fixbfcol
ENDIF
;
; remove non-metastable levels from highest ion stage
;
k = where(lvl.ion EQ imax AND lvl.meta*fill EQ 0,kount)
;
IF(kount GT 0) THEN level,del = k
;
labcnv,/rev  ; get nice labels back into lvl
IF(n_elements(nocheck) EQ 0) THEN dipchk
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'diprd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
