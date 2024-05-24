;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: wmat.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, September 25, 1995
;
; Last Modified: Mon Aug  7 21:49:22 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO wmat,w,evec,newmat
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       wmat
;
; PURPOSE: 
;   wmat  calculates error vector evec and grand matrix 
;         w for linearized esc. probs.
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       wmat, w, evec, newmat
;
; INPUTS:
;       newmat is a switch, if set to 1, new matrix is computed, if 0, just
;       evec 
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       w
;       evec
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
;       Written October 20, 1994, by Phil &, High Altitude Observatory/NCAR, Boulder CO
;
; MODIFICATION HISTORY:
;   P. Judge 14-Oct-1992
;   modified to permit incident radiation which is reduced by 
;   the factor NRB.  Thus, the "fixed" radiative rates are no
;   longer "fixed".  This means (1)  get_photo adds these
;   rates to the radiative part of the rate matrix in wmat,
;   and not to fixed rates.
;       
; VERSION:
;       Version 2, September 27, 1995
;-
;
@cdiper
@cse
COMMON wmat, wold
unit=lonarr(atom.nk)+1.
evec=n*0.
;
;  set isum to maximum of levels with rad transitions
;
IF(atom.nrad EQ 0) THEN BEGIN 
   ismax = MAX(n) 
   isum=ismax
ENDIF ELSE BEGIN 
   ir=trn.irad
   jr=trn.jrad
   ismax=max(n(ir))
   isum=trn(!c).irad
ENDELSE
;messdip,'isum=0',/inf
isum = 0
;
;  Note that two approaches are possible.  In the present
;  version 1, the net radiative bracket is not used directly in the rate matrix
;  but instead the incident radiation is simply iterated, through
;  the use of separation of rates into self-generated and incident for
;  both lines and continua (continua treated in bfrat.pro).
;  Thus, derivatives are computed here ONLY for the
;  self-generated or "diffuse" component.
;  
;  The alternative approach is to use the NRB computed in netrb.pro
;  directly here.  Then the Jacobian matrix computed in WMAT must
;  be modified to include derivatives of the net radiative bracket
;  with respect to incident radiation.
;
IF (newmat NE 0) THEN BEGIN	
   trace=indgen(atom.nk,/long)
;
;  get rate matrix
;
   ratem
;
;
; radiation part
;
;
; fixed part of w:
;
   w=matrix*0.
   FOR i=0,atom.nk-1 DO BEGIN
      w(trace,i)= -n(trace)/n(i)*matrix(trace,i) ;OK
   ENDFOR
   w(trace,trace) =MATRIX#unit  ;OK
;
; radiative transitions:
;   
;  (If the full incident radiation needs to be added
;  then you must add derivative terms here (version 2))
;   
   IF(atom.nrad LT 1) THEN GOTO,cons
   FOR kr=0,atom.nrad-1 DO BEGIN
      i=ir(kr) & j=jr(kr)
      ax=trn(kr).a*(tauq(kr))*dpesc(kr)
      w(i,j) = w(i,j) +  ax
      w(i,i) = w(i,i)-ax*n(j)/n(i)
   ENDFOR
; particle conservation
   cons:
   w(*,isum)=n
   w=TRANSPOSE(w)
ENDIF ELSE BEGIN
   W = wold
ENDELSE
;
;  are diagonals non-zero
;
diag=transpose(w(unit,unit))
j=where(diag eq 0.,kount)
if(kount gt 0) then messdip,/inf,'diagonal elements are zero at '+string(j)
;
;  error vector
;
evec =  transpose(n#MATRIX /n  - matrix#unit)
evec(isum) = totn - total(n)
;debug = 0
;if(debug eq 1) then begin
;   IF(N_ELEMENTS(wold) NE 0) THEN PRINT,MAX(abs(w/wold-1.))
;   PRINT,'wmat: EVEC'
;  print,evec
;  PRINT,'lambda, tau, nj ni'
;  FOR kr = 0,nline-1 DO PRINT,alamb(kr),tauq(kr),n(jrad(kr)),n(irad(kr))
;  surface,w,charsize=2
;  str = '' &  READ,str
;endif
;  
wold = w
RETURN
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'wmat.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
