;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: start_en.pro
; Created by:    Randy &, HAO/NCAR, Boulder, CO, August 16, 1996
;
; Last Modified: Fri Jun  2 13:21:32 2006 by judge (judge) on macniwot.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO start_ip, help=help, force = force
;
IF(n_elements(force) eq 0) THEN messdip,'use /force  if you are serious...'
!priv = 2
dbcreate, 'atom_ip', 1, 1, /external
dbclose
!priv = 0
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'start_ip.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
