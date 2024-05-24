;
;************************************************************************
;
function escprob, tau, type,der=der
;
;+
;  P. Judge 19-Feb-1992
; derivative keyword added,returns Dp/Dtau
;-
con=where(type  eq   1,nc)   ; continuum
lin=where(type  eq   0,nl)   ; line
esc=tau*0.
der = esc
IF(nl GT 0) THEN   BEGIN
   esc(lin)= 1./(1.+tau(lin))
   der(lin) = -esc(lin)*esc(lin)
ENDIF
IF(nc GT 0) THEN BEGIN
   esc(con)= 1./(1.+tau(con))
   der(con) = -esc(con)*esc(con)
; orig
;   esc(con)= exp(-tau(con))
;   der(con) = -esc(con)
ENDIF
return,esc
end
