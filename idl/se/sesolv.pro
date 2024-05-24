;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: sesolv.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 15, 1994
;
; Last Modified: Tue Apr 24 12:51:13 2007 by judge (judge) on client85-n229.wireless.ucar.edu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO sesolv,temp_in,nne_in,populations,elc,depth = depth,ltep = ltep,$
          vturb_in = vturb_in,start=start,verbose=verbose,itmx=itmx,$
          incident = incident
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       sesolv
;
; PURPOSE: 
;       To solve equations of statistical equilibrium in optically
;       thin plasmas for a given stored atomic model and set of
;       electron temperatures and densities.
;
;       Mean escape probabilities are treated for optically
;       thick plasmas
;       
; CALLING SEQUENCE: 
;          sesolv,temp_in,nne_in,elc,populations,depth=depth,$
;              vturb_in = vturb_in,start=start,verbose=verbose,itmx=itmx,$
;              incident = incident
;         
;
; INPUTS:
;       temp_in floating point scalar or array of electron temperatures 
;       nne_in  floating point scalar or array of electron densities,
;         (temp_in and nne_in must have the same number of elements,
;         nt say)
;               
; OPTIONAL INPUTS: 
;
; OUTPUTS:
;       elc      floating array of  emission line coefficients:
;                 1        hc  
;                ---   ---------    n_j A_ji    erg cm^-3 s^-1  sr^-1
;                4pi   lambda_ij
;  
;                 of dimension (atom.nline,nt)
;   
;       populations n_j floating array of dimensions (nk,nt), nk=atom.nk 
;
; EXPLANATION:
;       When optically thin, escape probabilities are 1 and the above
;       expression for elc holds.
;       When the optical depths are > 1, elc is multiplied by the
;       escape probability, and the populations are divided by escape 
;       probabilities.
;      
;       populations n_j are normalized so that the sum over j equals
;       10.^(atom.abnd-12.0) nh, nh=number density of hydrogen nuclei
;       nh=0.8nne/f, nne=electron number density, f=ionized H fraction
;       f is computed assuming very approximate ionization equilibrium 
;       (function  hion)
;
;       Use of incident radiation option may not work when optically thick.
;       In this case use a real radiative transfer program instead!
;   
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       depth      "slab depth" (length scale in cm) to evaluate optical depths
;       vturb_in  additional "microturbulence" to be added to line profile widths
;                  written (def='out')
;       start     Options for start are-
;                  unspecified:  automatic startup (recommended)
;                            0:  optically thin startup populations
;                            1:  LTE startup populations
;       /verbose  Will run verbosely
;       itmx    Set itmx to limit number of iterations for solution
;       ltep    lte populations (output)
;       incident=incident  Name of IDL function defining the incident
;                          radiation 
;
;
; COMMON BLOCKS:
;       cdiper cse
;
; RESTRICTIONS: 
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;   June 28, 2006, P. Judge
;   BFWGRID added 2013, modified 19 Jul 2013, PGJ
; VERSION:
;       Version 1, June 28, 2006
;-
;
@cdiper
@cse
nozeror = 0
IF(N_PARAMS(0) EQ 0) THEN BEGIN
   chkarg,'sesolv'
   RETURN
ENDIF
;dipchk
;
dummy=bfwgrid() ; define the wavelength grid for continuum emission calculations
;
IF(!regime GT 1) THEN messdip,'variable !regime MUST be 0 or 1, current value is '+strn(!regime)
;
ndata = n_elements(temp_in)
n_ne = n_elements(nne_in)
if(ndata ne n_ne) then messdip,'temp_in must be the same size as nne_in'
if(n_elements(depth) eq 0) then depth = temp_in*0.
if(n_elements(vturb_in) eq 0) then vturb_in = 0.*temp_in
ndepth = n_elements(depth)
nvt = n_elements(vturb_in)
if(ndata ne n_ne) then messdip,'temp_in must be the same size as nne_in'
if(ndepth ne n_ne) then messdip,'depth must be the same size as nne_in'
if(nvt ne n_ne) then messdip,'vturb_in must be the same size as nne_in'
;
;
;
dektmx = max(lvl.ev)*ee/bk/min(temp_in)
sdek = string(dektmx,form = '(f6.1)')
IF(dektmx GT 308.) THEN BEGIN 
   messdip,/inf,'sesolv:'
   messdip,$ 
      'E/kT='+sdek+': must be < 308, try higher T''s or restrict levels'
ENDIF

verb = n_elements(verbose) NE 0
IF(N_ELEMENTS(elim) EQ 0)THEN elim =  1.e-12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  get incident radiation
;
IF(n_elements(incident) EQ 0) then incfunc = 'ZERO' ELSE incfunc = incident
incident
if(verb) then print,'ELIM =',elim
if(n_elements(start) ne 0) then istart=start else istart=0
nl = atom.nline
IF(nl GT 0) THEN elc = dblarr(nl,ndata) ELSE elc = 0.
lines = indgen(nl,/long)
populations = dblarr(atom.nk,ndata)
ltep = populations
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; begin loop
IF(verb) THEN clockit,/reset
for i=0l,ndata-1 do begin
   temp=temp_in(i)
   nne=nne_in(i)
   ionh = hion(temp)
   toth = 0.8*nne/ionh(1)
   totn=10.^(atom.abnd-12.0)*toth ; normalization
   lscale=depth(i)
   vturb=vturb_in(i)
   if(verb) then print,'  depth   toth    Ne        Te        Pe           Vt'
   IF(verb) THEN PRINT,lscale,toth,nne,temp,nne*temp,vturb,$ 
      form='(5(1x,e9.2),1x,f9.1)'
   estart,istart,verb=verb
   eiter,elim,verb=verb,itmx=itmx
   IF(nl GT 0) THEN elc(*,i) =  $
      n(trn(lines).jrad)*(hh*cc*1.d8/4./!pi/trn(lines).alamb)*trn(lines).a*nrb(lines)
   populations(*,i) = n
   ltep(*,i) = nstar
   IF(verb) THEN clockit,'sesolv',i,ndata,10
endfor
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'sesolv.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
