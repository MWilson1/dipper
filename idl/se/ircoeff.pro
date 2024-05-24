;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: recoeff.pro
; Created by:    judge, August 2, 2006
;
; Last Modified: Sat Aug 26 15:05:55 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
PRO ircoeff,temp_in,nne_in,rcoeff,icoeff,depth = depth,ltep = ltep,$
          vturb_in = vturb_in,start=start,verbose=verbose,itmx=itmx,$
          incident = incident,extra = extra
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       ircoeff
;
; PURPOSE: 
;       returns ionization and recombination coefficients
;       
; CALLING SEQUENCE: 
;          recoeff,temp_in,nne_in,icoeff,rcoeff,populations,depth=depth,$
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
;       icoeff      /cm3/s ionization coefficient
;       rcoeff      /cm3/s recombination coefficient
;
; EXPLANATION:
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
; VERSION:
;       Version 1, June 28, 2006
;-
;
@cdiper
@cse
nozeror = 0
IF(N_PARAMS(0) EQ 0) THEN BEGIN
   chkarg,'recoeff'
   RETURN
ENDIF
;dipchk
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
verb = n_elements(verbose) NE 0
IF(N_ELEMENTS(elim) EQ 0)THEN elim =  1.e-12
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  get incident radiation
;
IF(n_elements(incident) EQ 0) then incfunc = 'ZERO' ELSE incfunc = incident
incident
;
k = where(trn.type EQ 'BF',count)
IF(count EQ 0) THEN messdip,'no BF transitions so stop. Is !regime=1?'
rcoeff = fltarr(count,ndata)
extra = fltarr(ndata)
icoeff=fltarr(count,ndata)  ; copy structure for simplicity
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; begin loop
for i=0l,ndata-1 do begin
   temp=temp_in(i)
   nne=nne_in(i)
   ionh = hion(temp)
   toth = 0.8*nne/ionh(1)
   totn=10.^(atom.abnd-12.0)*toth ; normalization
   lscale=depth(i)
   vturb=vturb_in(i)
   estart,0  ; just compute all rates, no iterations needed
   rcoeff(*,i) = (rji(k))/nne
   extra(i) = recx/nne
;
; ionization
;
   ir=trn(k).irad
   jr=trn(k).jrad
;
; error corrected in indexing n here March 8 2011
;
   icoeff(*,i)=c(ir,jr)/nne*n(ir)/n(0)*lvl(ir).meta; assumes just 1 ionization stage treated

;   rcoeff(*,i) += c(jr,ir)/nne   ;  3 body recombination
endfor
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'recoeff.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
