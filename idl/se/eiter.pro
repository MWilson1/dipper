;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: eiter.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, September 25, 1995
;
; Last Modified: Mon Jul 24 14:10:31 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro eiter, elim, itmx=itmx, debug=debug, verbose = verbose
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       eiter
;
; PURPOSE: 
;     iterates between Net radiative brackets (through the line center 
;     optical depths) and number densities
;     until convergence is reached, in mean escape probability approxn.
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;     eiter,elim,  itmx=itmx, debug=debug, silent=silent, help=help
;
; INPUTS:
;       elim  - if changes in relative populations are less than this then stop
;               iterating and return   
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
;
; CALLS:
;       eqsyst, invert, netrb, stateq
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
;       Code & header cleaned up September 25, 1995, P. Judge
; VERSION:
;       Version 1, October 20, 1994
;       Version 1.1, September 25, 1995
;-
;
@cdiper
@cse
IF(N_params(0) EQ 0) THEN BEGIN
   doc_library,'eiter'
   RETURN
ENDIF
;
IF(atom.nrad EQ 0) THEN RETURN  ; no radiation to iterate!
emax=1.0
lammax=1 *(MAX(tauq) GT 1.e2)  ; max no of straight iterations (equiv. to lambda iteration)
lammax = -1
IF(N_ELEMENTS(itmx) EQ 0) THEN itmx=11 ;default number of iterations
iter=1
form='(A,2x,e9.1,2x,A,2x,i2)'
ilambd=0
dtime=systime(1)
restart:
while(abs(emax) gt elim AND iter LE itmx) do begin
;
;  lambda iterations
;
    while (ilambd lt lammax) do begin
      nold=n
      netrb,verbose = verbose
      stateq
      emaxx=max(abs((n-nold)))/ nold(!c)
      ilambd=ilambd+1
    endwhile
;
;  main iteration cycle of Newton-Raphson scheme
;
    nold=n
    netrb,verbose = verbose
    IF(abs(emax) GT 0.) THEN newmat=1 ELSE newmat = 0
    wmat,bmat,evec, newmat
    ww=bmat
    eqsyst,ww,evec
;
    n = nold*(1.+evec)
    emax=max(abs(evec))
    iter=iter+1
    if(iter gt itmx) then begin
       return
    endif
endwhile
return
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'eiter.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
