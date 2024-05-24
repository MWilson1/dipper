FUNCTION hion,te,caseb = caseb
;+
;  returns the neutral and ionized fractions of Hydrogen at a 
;    given electron temperature, in fltarr(2).
;  Simple, very approximate, but needed.
;   
;  CI parameter is 4.2e-11
;  Seaton's SEF from Jordan and rad recombination rate, from Allen
;  recombination rate is total - n=1 level (Ly-continuum in detailed balance)
;  note that expint(x)  approx exp(-x)/x has been implicitly used here.
;
;-
;
IF(n_elements(te) NE 1) THEN messdip,'te must be a scalar'
irat=2.0e-08 * sqrt(te) * 10.^(-5040* 13.598/te) / 13.598/13.598
;
; CI formulation (algebra to be checked)
; irat = 4.2e-11 * sqrt(te) * 10.^(-5040* 13.598/te) 
;
scale = n_elements(caseb) NE 0
rrat=(2.07e-11/sqrt(te)*2.3 - scale*3.262e-6/ sqrt(te) / 1.43882/ 109754.578  ) >  0.
return,[rrat,irat]/(rrat + irat)  ; ion fractions of H
end
