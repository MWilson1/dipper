;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: bfrd.pro
; Created by:    judge, July 10, 2006
;
; Last Modified: Tue Aug 15 13:38:58 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO bfrd
;+
;
; PROJECT:
;       HAOS-DIPER
;
; NAME:  bfrd     (procedure)
;
; PURPOSE:  To read transition data (photoionization cross sections)
;           from the atomic database.
;
; CALLING SEQUENCE:
;
;       bfrd
;
; INPUTS:
;
; OPTIONAL INPUTS: 
;
; OUTPUTS:
;       Stores radiative data in cdiper common block variables.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; COMMON BLOCKS:
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Part of the HAOS-DIPER database software.
;
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, July 10, 2006 PGJ
;-
;
@cdiper
;
IF(!regime EQ 0) THEN BEGIN
   messdip,/inf,'BFRD: !regime=0 so no photoionization data stored'
   return
endif
;
atm = string(atomn(atom.atomid,/num))
;
imx = max(lvl.ion)
dbopen, 'atom_bf,atom_bib'
;
; loop over all levels and assign photoionization data
;
oldion = -1

iterm = nla(lvl.orb(2))+nla(lvl.orb(1))+nla(lvl.orb(0))+$
   slp(lvl.term(2))+slp(lvl.term(1))+slp(lvl.term(0))

FOR i = 0,n_elements(lvl)-1 DO BEGIN 
   IF(lvl(i).ion EQ imx) THEN GOTO, skip   ; level belongs to highest ion stage-skip it
;
; identify final levels- ground levels of next ion stage
;
   next = where(lvl.ion EQ lvl(i).ion+1,num)
   emin = min(lvl(next).ev) & gnd = next(!c) ; ground level
   ok = where(iterm(next) EQ iterm(gnd),kount)
   IF(kount NE 0) THEN BEGIN 
      indx = next(ok)
      gtot = total(lvl(indx).g) 
   ENDIF
   IF(lvl(i).ion NE oldion) THEN $
   bfindx = dbfind('atom='+atm+',ion='+string(lvl(i).ion),/silent)
   oldion = lvl(i).ion
;
; loop starting with orb1 and term1, stop when just one is found or
; when end of loop is found   
;   
   isear = 0 &  count = 0
   searches = [',term2='+string(lvl(i).term(1)), $
               ',orb2='+string(lvl(i).orb(1)), $
               ',term3='+string(lvl(i).orb(2)), $
               ',orb3='+string(lvl(i).orb(2))]
   nsear = n_elements(searches)
   search_string = 'term1='+string(lvl(i).term(0))+$
      ',orb1='+string(lvl(i).orb(0))
   WHILE(count NE 1 AND isear LT nsear) DO BEGIN 
      ind = dbfind(search_string,bfindx,count = count,/silent)
      search_string =  search_string + searches(isear)
      isear = isear+1
   ENDWHILE
   labl = lvl(i).label
   labcnv,labl,/rev
   CASE (count) OF
      0: messdip,'no photoionization data for '+labl,/inform
      1: BEGIN
;         dbext,ind(0),'nq,lambda,sigma,bib_ref',nq,lam,sig,ref
         dbext,ind(0),'nq,lambda,sigma,compress,bib_ref',nq,l,s,compr,ref
         picom,lam,l,compr(1),compr(2),/rev,power = compr(0)
         picom,sig,s,compr(4),compr(5),/rev,power = compr(3)
         is = sort(1./lam(0:nq-1))
         lam = lam(is) &  sig = sig(is)
         new = trndef
         new.type = 'BF'
         new.ref = ref
         new.nq = nq
         new.irad = i
         FOR j = 0,kount-1 DO BEGIN ; loop over upper levels
            new.jrad = indx(j)
            sig1 = sig*lvl(indx(j)).g/gtot 
            de = lvl(new.jrad).ev-lvl(i).ev
            IF(de LT 0.) THEN GOTO, skipj
            edge = hh*cc*1.e8/ee/de
            linterp,lam,sig1,edge,sedge
            ok = where(lam LT edge,nq)
            lam = lam(ok) & sig1 = sig1(ok)
;
            new.alamb = edge
            new.qmax = -1    ; a table of values is always given, not lambda^3
            new.frq = cc*1.e8/[edge,lam]
            nq = n_elements(lam) 
            new.alfac = [sedge,sig1]*1.e-18 ; set edge 
            new.f = sedge*1.e-18
            new.q(0:nq) = cc*1.e8/new.frq(0:nq)
            new.nq = nq
            trn = [trn,new]
            atom.nrad = atom.nrad+1
            skipj:
         ENDFOR
      END
      ELSE: messdip,'>1 photoionization dataset for '+labl
   ENDCASE
   skip:
ENDFOR
;
dbclose
;
; assign weights wq 
;
freqc
;
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'bfrd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
