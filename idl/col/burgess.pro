;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: burgess.pro
; Created by:    Phil &, HAO/NCAR, Boulder CO USA, January 17, 1995
;
; Last Modified: Thu Mar  2 17:05:39 2006 by judge (Philip Judge) on niwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION burgess,i,j,temp, const=const
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       burgess
;
; PURPOSE: 
;       
; EXPLANATION:
;       Computes Collisional ionization rates following Burgess and Chidichimo
;       (1983) MNRAS 203, 1269-1280, equation (6) and references to that.
;       This is essentially the formula of W. Lotz (1968) Z. Phys. 216, 241
;       so it has the correct asymptotic behavior at low and high temperatures
;       but it is almost exactly 20% lower. 
;   
; CALLING SEQUENCE: 
;       rat=burgess(i,j,temp)
;
; INPUTS:
;       i  lower level of transition
;       j  upper level of transition  (can have 
;       temp temperature at which rate coefficient is desired   
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       rate from lower to upper level
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;       const  Value of the scaleable constant to be used (default = mean=2.3)
; CALLS:
;       nr_expint
;
; COMMON BLOCKS:
;       catom, cqn
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
;       Written January 17, 1995, by Phil &, HAO/NCAR, Boulder CO USA
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, January 17, 1995
;-
;
@cdiper
IF(N_ELEMENTS(help) GT 0) THEN BEGIN
   doc_library,'burgess'
   RETURN,0.0*t
ENDIF
;
up =  j >  i
lo =  j <  i
IF(lvl(up).ion LE lvl(lo).ion) THEN BEGIN
   print,i,j
   print,lvl(lo).label,lvl(up).label
   PRINT,'% burgess: ionization rates set =0 between levels ',up,lo, $
      ' ions ', lvl(up).ion, lvl(lo).ion
   RETURN,0.0*temp
ENDIF
;
de=lvl(up).ev-lvl(lo).ev
z=lvl(lo).ion-1
beta = 0.25*(((100.*z +91)/(4.*z+3))^0.5 -5.)
w = (alog(1. + bk*temp/de/ee))^(beta/(1.+bk*temp/de/ee))
alpha = de*ee/bk/temp
cbar=2.3                        ; mean scaled cross section
IF(N_ELEMENTS(const) EQ 0) THEN const = cbar
;
q = 2.1715e-08*const*(13.6/de)^1.5 * alpha^0.5 * $ 
   nr_expint(1,alpha,/double)*w
q = q*lvl(lo).active ; number of active electrons
RETURN,q
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'burgess.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
