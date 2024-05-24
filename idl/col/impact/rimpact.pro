;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: rimpact.pro
; Created by:    Philip G. Judge, May 31, 1996
;
; Last Modified: Sat Mar 11 18:19:15 2006 by judge (Philip Judge) on niwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
function rimpact,kr,t,mp,zpert,debug=debug
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       rimpact
;
; PURPOSE: calculates collisional rate coefficients using rimpact approximation
;       
; EXPLANATION:
;       For neutral species, this procedure calculates collision rate
;       coefficients from the rimpact approximation of Seaton 1964. 
; CALLING SEQUENCE: 
;       rimpact,kr,t,mp,zpert,cij,omega,ce [,/debug]
;
; INPUTS:
;            kr     transition number                (in)
;            t      temperature array                (in)
;            mp     mass of perturber (atomic units) (in)
;            zpert  charge of perturber              (in)
;       
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;            cij    collision rate 
;            omega  collision strength
;            ce     ce rate coefficient (see gencolrat for explanation)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       /help.  Will call doc_library and list header, and return
;
; CALLS:
;       fcx
;
; COMMON BLOCKS:
;       catom, cqn
;
; RESTRICTIONS: 
;       Should be used for neutrals only. 
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Fortran coding by P. Judge 1991 from original code from Peter Storey
;       Converted to IDL by Mats Carlsson circa 1992-1993
;       DIPER version written May 31, 1996, by Philip G. Judge
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, May 31, 1996
;-
;
@cdiper
if(n_params(0) lt 4) then begin
   messdip,'rimpact,kr,t,mp,zpert[,/debug]'
   RETURN,-1
ENDIF
if(n_elements(debug) eq 0) then debug=0
;
;
; integration over Maxwellian
;
nt=n_elements(t)
IF(nt LE 1) THEN messdip,'temperature must be an array of 2 or more elements'
cij=dblarr(nt)
omega=dblarr(nt)
ce=dblarr(nt)
;
for i=0,nt-1 do begin
   cij(i) = 0.
   dum=SIZE(t)
   IF(dum(0) EQ 1) THEN tt=t(i) ELSE tt=t
   xx = 0.349221327302d1
   y = 0.317609125092d-1*fcx(kr,xx,tt,mp,zpert,debug=debug)
   xx = 0.252833670642d1
   y = y + 0.705786238657d-1*fcx(kr,xx,tt,mp,zpert,debug=debug)
   xx = 0.1722408776444d1
   y = y + 0.129983786286d00*fcx(kr,xx,tt,mp,zpert,debug=debug)
   xx = 0.1072448753818d1
   y = y + 0.195903335973d00*fcx(kr,xx,tt,mp,zpert,debug=debug)
   xx = 0.5768846293019d0
   y = y + 0.235213229670d00*fcx(kr,xx,tt,mp,zpert,debug=debug)
   xx = 0.2345261095196d0
   y = y + 0.210443107939d00*fcx(kr,xx,tt,mp,zpert,debug=debug)
   xx = 0.4448936583327d-1
   y = y + 0.109218341952d00*fcx(kr,xx,tt,mp,zpert,debug=debug)
;
;  previous version
;  this is supposed to give the collision rate down in cm3 s-1.
;  ccc gives rate up except that the factor exp(-de/kt) is missing
;  hence rate down = ccc*g(ilo)/g(ihi)
;  behavior/ constant  is given by
;  8.63e-06 / sqrt(t) /sqrt(d) / 0.8798182e-16/1.43882/ryd*t
;
   ccc = y*6.21241d5*SQRT(tt)/SQRT(mp)
   cij(i) = cij(i) + ccc
;   omega(i)=cij(i)/(8.63e-6/SQRT(tt)/g(ihi))
;   ce(i)=cij(i)/(SQRT(tt)*g(ilo)/g(ihi))
ENDFOR
RETURN,cij
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'rimpact.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
