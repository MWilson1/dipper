;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: shull82.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, August 13, 1996
;
; Last Modified: Tue Aug 15 11:41:49 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro shull82,new,usei=usei
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       shull82
;
; PURPOSE: Get collisional keyword data from Shull and Van Steenburg 1982
;       Looks up and computes collisional ionization and radiative and
;       dielectronic recombination keyword data for collisional ionization rate
;       calculations.
;       
; EXPLANATION:
;       This procedure uses a zdbase database file 
;       
; CALLING SEQUENCE: 
;       shull82, coldata
;
; INPUTS:
;       
; OPTIONAL INPUTS: 
;       usei=usei   use Shull&VanSteenburg ionization coeffs (not recommended).
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       /usei   Will use Shull's collisional ionization coefficients, these
;       are inferior to those from Arnaud and Rothenflug and 
;       ar85ci, burgess, cicalc
;
; CALLS:
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
;       Written August 13, 1996, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, August 13, 1996
;-
;
@cdiper
if (n_params(0) lt 1) then begin
  print,'shull82,coldata,usei=usei'
  return
endif
;
new=coldef
colnew = new
;
;  get atomic number 
;
IZ=atomn(getwrd(atom.atomid,0))
if(iz lt 1 or iz gt 92) then begin
  print,'shull82: element out of range, iz=',iz
  return
endif  
;
;  find if there are b-f transitions in detail
;  if so, then use detailed treatment for radiative rates and set
;  radiative recombination coefficients to zero
;  this is done using array keeprec which is multiplicative factor for
;  the radiative recombination coefficient
;
ion = lvl.ion
keeprec=1+intarr(max(ion))
for kr=atom.nline,atom.nrad-1 do BEGIN 
   keeprec(lvl(trn(kr).irad).ion-1)=0.
ENDFOR
str = ''
FOR i = min(ion),max(ion)-1 DO BEGIN 
   j = i-1
   IF(keeprec(j) EQ 1) THEN str = str+roman(i)+' '
ENDFOR
IF(str ne '') THEN $
   messdip,/inf,'SHULL82: Using radiative recombination coefficients for ions '+str ELSE $
   messdip,/inf,'SHULL82: No radiative recombination coefficients used'
;IF(str ne '') THEN $
;   print,'SHULL82: Using recombination coefficients for ions '+str ELSE $
;   print,'SHULL82: No radiative recombination coefficients used'
;
;  get ground terms
;
index = gterms(gtot=gtot)
;
; now loop over levels with index=1 to obtain levels for which SHULL82
; keyword should be computed.
;
dbopen,'shull82'
ii=-1
nk = atom.nk
for i=0,nk-2 do begin
   if(index(i) eq 1) then begin
      for j=i+1,nk-1 do begin
         if(index(j) eq 1 and ion(j) eq ion(i)+1) then begin
            strng = 'atom='+string(iz)+',ion='+string(ion(i))
            found = dbfind(strng,/silent)
            IF(found(0) EQ 0) THEN BEGIN
               strng = 'atom='+atom.atomid
               messdip,'No data exist for '+strng+' in shull82 dataset',/inf
            ENDIF ELSE BEGIN 
               ii=ii+1
               nd= 8
               colnew.key='SHULL82'
               colnew.nt=nd
;
; fix to preserve total ionization/recombination rates
;
               ifix=fltarr(8)+1.0
               ifix(0)=lvl(j).g/gtot(j) ; ionization scaling
               ifix(2)=lvl(i).g/gtot(i)
               ifix(4)=lvl(i).g/gtot(i)
               dbext,found,'acol,tcol,arad,xrad,adi,bdi,t0,t1',$
               acol,tcol,arad,xrad,adi,bdi,t0,t1
               dum=[acol,tcol,arad,xrad,adi,bdi,t0,t1]
;               dum([2,4])=dum([2,4])*keeprec(ion(i)-1)
               dum([2])=dum([2])*keeprec(ion(i)-1)
               colnew.data=dum*ifix
               colnew.temp=0.*findgen(nd)
               colnew.ilo=i
               colnew.ihi=j
               if(n_elements(usei) eq 0) THEN colnew.data(0)=0.
               new = [new,colnew]
            endelse
         endif
      endfor
   endif
endfor
if(ii lt 0) then begin 
   messdip,/inf,'SHULL82: No collisional data implemented'
  return
endif
new = new(1:*)
new.ref = 'Shull & Van Steenburg 1982, The ionization equilibrium of astrophysically abundant elements, ApJ Suppl.48, 95'
;
dbclose
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'shull82.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
