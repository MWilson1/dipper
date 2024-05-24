;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: tsolv.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 29, 1994
;
; Last Modified: Thu Jun 29 21:37:10 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO tsolv, t1, t2, overs=overs, debug = debug,second = second
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       tsolv
;
; PURPOSE: 
;       Solves for number densities of atomic populations in time, from
;       time t1 to time t2 (seconds)
; EXPLANATION:
;       Uses fully implicit time evolution formalism from Numerical Recipies
;       In Fortran, 1st Edition. 
;       the number densities as given by variable n are updated as the
;       time advances from t1 to t2   
; CALLING SEQUENCE: 
;       tsolv, t1, t2
;
; INPUTS:
;       time t1 (seconds)- start time
;       time t2 (seconds)- end   time
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       variable n is updated in the cse common area.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       overs=overs   Over-sampling rate for time step, def=5. 
;       /second.  Use second order integration scheme. Not recommended   
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       Assumes thermal properties of the gas are constant between t1 and t2.
;       Assumes gas is optically thin
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written November 29, 1994, by Phil &, HAO/NCAR, Boulder CO
;
; MODIFICATION HISTORY:
;       December 3, 1995, P. Judge revised solution using updated eqn system
;       solver and rate_matrix including bf rates.
; VERSION:
;       Version 2, December 3, 1995
;-
;
@cdiper
@cse
dbg = 0
nozeror = 0
IF(n_elements(debug) NE 0) THEN dbg = 1
;
; over-sampling rate for calculations
;
IF(N_ELEMENTS(overs) EQ 0) THEN overs=3.0 
itmx=long(overs)*1000
;
; set up some needed matrices, etc.
;
unit=double(n*0.)+1.D0
t=0.d0
deltat = DOUBLE(t2)-DOUBLE(t1)
done = 0
unitm=matrix*0.
for k=0,atom.nk-1 do unitm(k,k) = 1.d0
;
; compute rates 
;
ratem,/diag
;eigen_matrix,matr
second = n_elements(second) NE 0
; 
CASE (second) OF
   0: BEGIN 
      wti = 1.0d0                 ; implicit weight
      wte = 1.d0-wti              ; explicit weight
   END
   1: BEGIN
      wti = 0.55                ; implicit weight
      wte = 1.-wti              ; explicit weight
;      IF (dbg) THEN messdip,'second order scheme',/inf
   END
ENDCASE
;
; main loop over time
;
for i=1L,itmx do begin
   relerr= transpose(n#matrix  - (matrix#unit)*n)/n
;   finit = WHERE(relerr NE 0.,kount)
   finit = where(finite(relerr),kount)
   IF(kount LE 0) THEN times = 1.e30 ELSE times=1./relerr(finit)
   mintime=min(abs(times))
   dt=mintime/overs
   tnew = t+dt
   IF(tnew GE deltat) THEN BEGIN
      done = 1
      dt = deltat - t           ;new dt is deltat - old timestep
   ENDIF 
   t = t+dt
;
;  OK. got timestep.  Now perform time integration, using eqs. 
;  15.6.23 (for vectors not scalar) with appropriate weights,
;   of Numerical Recipes in Fortran 1st edition
;
   mat=TRANSPOSE(unitm  - matrix*dt*wti)
   delt = dt*wte*n#matrix
   IF(max(abs(delt/n)) GT 0.5) THEN print,'change=',delt,n
   n = n +delt
   eqsyst,mat,n
   IF(done) THEN GOTO, conv
endfor
messdip,'Time integration not converged in '+strn(itmx)+' iterations'
conv:
return
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'tsolv.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
