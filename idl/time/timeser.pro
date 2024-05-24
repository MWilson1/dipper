;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: timeser.pro
; Created by:    Phil &, High Altitude Observatory/NCAR, Boulder CO, November 29, 1994
;
; Last Modified: Thu Jun 29 21:36:12 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO timeser,time,tempt,nnet,nt,nse,overs=overs,startp = startp
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       timeser
;
; PURPOSE: control program for solving number densities vs time t given Te(t), Ne(t)
;       
; EXPLANATION: 
;       From a starting solution, atomic populations are integrated in time
;       and are stored in variable nt as a function of the input time variable
;       time in seconds.   The summed populations remain at the value given at
;       input, at all times. If no starting solution is given, a statistical 
;       equilibrium calculation is done at the first time step, and this used
;       to start the integration.  
;   
; CALLING SEQUENCE: 
;       timeser,time,tempt,nnet,overs=overs
;
; INPUTS:
;       time - time (seconds) array of times for timeseries calculation
;       tempt - temperature at time, any desired behavior 
;       nnet - electron density at time, "
;   
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       nt number densities as a function of level and time:
;                           nt(level index, time index)
;       nse statistical equilibrium calculations in the same format
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       overs=overs  over sampling rate for integration in tsolv
;       startp=startp starting solution for integration
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       cdiper, cse
;
; RESTRICTIONS: 
;       Column density is assumed to be negligible and Vturb is set to
;       10 km/s.  Not implemented for optically thick cases
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Original November 29, 1994, by Phil Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1. June 29, 2006
;-
;
@cdiper
@cse
IF (N_PARAMS(0) LT 3) THEN BEGIN
   doc_library,'timeser'
   RETURN
ENDIF
;
elim =  1.e-10
;
; Output variables
;
ndata = N_ELEMENTS(time)
nk = atom.nk
nt = dblarr(nk,ndata)
nse = nt
vturb=10.
hcol = 1.E-10
IF(n_elements(incfunc) EQ 0) THEN incfunc = 'ZERO'
incident
temp = tempt(0)
nne = nnet(0)
;
;  Initial starting solution- 
;
istart = 0
itmx = 3
estart,istart
eiter,elim,itmx = itmx
nse(*,0) = n
IF(n_elements(startp) EQ 0) THEN BEGIN 
   nt(*,0) = n
ENDIF ELSE BEGIN 
   nt(*,0) = startp
   n = startp
ENDELSE
;
;
for i=1,ndata-1 do BEGIN  ;  MAIN LOOP OVER TIME- BEGIN ***************
;   str = strcompress("timestep: "+string(i)+"/"+string(ndata-1),/rem)
;   print,str
   temp=tempt(i)
   nne=nnet(i)
   tsolv,time(i-1),time(i),overs = overs
   nt(*,i) = n
   nsave = n
   estart,istart
   eiter,elim,itmx=itmx
   nse(*,i) = n
   n = nsave
ENDFOR                          ;  MAIN LOOP OVER TIME - END   ***************
;
RETURN
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'timeser.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

