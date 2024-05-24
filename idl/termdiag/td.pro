;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: termdiag.pro
; Created by:    Philip G. Judge, May 7, 1996
;
; Last Modified: Tue Jun  6 09:07:08 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO td,emin=emin,emax=emax,lsort=lsort,trans=trans,bb=bb,bf=bf,$
       wmin=wmin,wmax=wmax,legend=legend,contlong=contlong,$ 
       fixlamb=fixlamb,nm=nm,permitted=permitted, forbidden=forbidden,$ 
       main=main,brmin=brmin,multiplicity=multiplicity, $
       label_trans=label_trans, help=help,title=title,fskeep=fskeep,_extra=_extra
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       td
;
; PURPOSE: to plot term (Grotrian) diagrams for atom models
;       
; EXPLANATION:
;            plots a term diagram within energies [emin,emax]
;            default is whole term diagram with all transitions drawn
;            /lsort gives sorting according to multiplicity and L. (Default is
;            lsort=1, set lsort=0 to get no sorting by multiplicity and L)
;            transition drawing switched off
;
;            By default, use of this procedure will usually (except for the
;            simplest atomic systems) make a plot that almost
;            certainly will be unreadable, but will show everything looking
;            rather confused.  Some manual manipulation is necessary to make a
;            nicer plot.  
;
;
; CALLING SEQUENCE: 
;   td 
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
;       emin=emin  minimum energy level to be plotted in ev
;       emax=emax  maximum energy level to be plotted in ev
;       legend=legend  plots a legend for line styles, 
;            legend=1:  top left
;            legend=2:  top right
;            legend=3:  bottom right
;            legend=4:  bottom left
;       contlong=contlong long continuum bar, shaded, at top
;       fixlamb=fixlamb  rounding of wavelengths to nearest integer
;       nm=nm  nanometer units for wavelengths
;       multiplicity=multiplicity  select certain multiplicities (e.g., [3,1])
;       trans=trans choose which transitions to plot- THIS OVERRIDES 
;       following keywords:
;           wmin = wmin minimum wavelength of transitions to plot
;           wmax = wmax maximum wavelength of transitions to plot
;           permitted=permitted   plot permitted transitions only
;           forbidden=forbidden   plot forbidden & spin forbidden transitions only
;           main=main   plot strongest lines of multiplets only
;           bb=bb   bound-bound transitions only
;           bf=bf   bound-free transitions only
;           label_trans=label_trans   binary switch for labels on transitions,
;                                     0=no, 1=yes, default=1
;   
; CALLS:
;       td_init,td_plot
;
; COMMON BLOCKS:
;       ctermdiag, cdiper
;
; RESTRICTIONS: 
;      None
;
; SIDE EFFECTS:
;       Graphical output to output device
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Original coding Mats Carlsson and Philip Judge circa 1989
;
; MODIFICATION HISTORY:
;       
;   added /fskeep keyword PGJ 13 Dec 2012
; VERSION:
;       Version 1, May 7, 1996
;-
;
@cdiper
@ctermdiag   
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'termdiag'
   RETURN
ENDIF
;
; make sure common block data are set.
;
;dipchk
;
; initializations
;
IF(N_ELEMENTS(emax) EQ 0) THEN emax = MAX(lvl.ev)
IF(N_ELEMENTS(emin) EQ 0) THEN emin = MIN(lvl.ev)
IF(N_ELEMENTS(lsort) EQ 0) THEN lsort=1
top = emax
bottom = emin
td_init,lsort=lsort,fskeep=fskeep
;
tstring = 'Selected transitions'
IF(N_ELEMENTS(trans) NE 0) THEN whichtrans = trans
IF(N_ELEMENTS(trans) EQ 0) THEN BEGIN
   whichtrans = indgen(atom.nrad,/long)
   tstring = 'All transitions'
   IF(N_ELEMENTS(bb) NE 0) THEN BEGIN
      j = WHERE(whichtrans Lt atom.nline,count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
   tstring = 'All b-b transitions'
   ENDIF
   IF(N_ELEMENTS(bf) NE 0) THEN BEGIN
      j = WHERE(whichtrans ge atom.nline,count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
      tstring = 'All b-f transitions'
   ENDIF
;
; forbidden and permitted keywords set
;
;
;  Now look if wmin and wmax are set
;   
   IF(N_ELEMENTS(permitted) NE 0) THEN BEGIN
      j = WHERE(trn(whichtrans).type EQ 'E1',count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
      tstring = 'All permitted transitions'
   ENDIF
   IF(N_ELEMENTS(forbidden) NE 0) THEN BEGIN
      j = WHERE(trn(whichtrans).type NE 'E1',count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
      tstring = 'All non-permitted transitions'
   ENDIF
   IF(N_ELEMENTS(main) NE 0) THEN BEGIN
      mainline,main
      trold = whichtrans
      whichtrans = 0
      FOR i = 0,N_ELEMENTS(main)-1 DO BEGIN
         k = WHERE(trold EQ main(i),count)
         IF(count EQ 1) THEN whichtrans = [whichtrans,trold(k)]
      ENDFOR
      IF(N_ELEMENTS(whichtrans) GT 1) THEN whichtrans = whichtrans(1:*)  ELSE whichtrans = [-1]
      tstring = 'Main lines only'
   ENDIF
   IF(N_ELEMENTS(wmin) NE 0) THEN BEGIN
      j = WHERE(trn(whichtrans).alamb ge wmin,count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
      tstring = 'wavelengths > '+STRTRIM(STRING(wmin),2)+'A'
   ENDIF
   IF(N_ELEMENTS(brmin) NE 0) THEN BEGIN
      br = trn(whichtrans).a*0.
      FOR kr = 0,N_ELEMENTS(whichtrans)-1 DO begin
         pos = WHERE(trn.jrad EQ trn(whichtrans(kr)).jrad)
         br(kr) = trn(whichtrans(kr)).a/total(trn(pos).a)
      ENDFOR
      j = WHERE(br ge brmin,count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
      tstring = 'branch rat. > '+STRTRIM(STRING(brmin),2)
   ENDIF
   IF(N_ELEMENTS(wmax) NE 0) THEN BEGIN
      j = WHERE(trn(whichtrans).alamb le wmax,count)
      IF(count GT 0) THEN whichtrans = whichtrans(j) ELSE whichtrans = [-1]
      tstring = 'wavelengths < '+STRTRIM(STRING(wmax),2)+'A'
   ENDIF
ENDIF
IF(N_ELEMENTS(label_trans) NE 0) THEN $
   IF(label_trans EQ 0) THEN BEGIN
   c_label = 0
   c_label_space = -1
   c_arrow = 0
ENDIF
;
; are whichtrans in (0,nrad-1) range?
;
bad = WHERE(whichtrans LT 0 OR whichtrans GT atom.nrad-1,count)
IF(count GT 0) THEN BEGIN 
   messdip,'you asked to plot transitions ' + strn(whichtrans(bad)),/inf
   messdip,'which is outside the range of 0 and NRAD-1='+strn(atom.nrad-1),/inf
   messdip,'execution halted'
ENDIF
;
;
IF(N_ELEMENTS(contlong) NE 0) THEN td_cont_long
if(n_elements(title) eq 0) then title = atom.atomid+' '+tstring
td_plot,emin = emin,emax = emax,lsort=lsort,nm = nm,multiplicity = multiplicity, $
   fixlamb = fixlamb,legend = legend, title = title
RETURN
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'termdiag.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

