;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: start_en.pro
; Created by:    Randy &, HAO/NCAR, Boulder, CO, August 16, 1996
;
; Last Modified: Mon Jul 31 11:53:45 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO start_db, force = force
;
IF(n_elements(force) eq 0) THEN messdip,'use /force  if you are serious...'
!priv = 2
str = '' 
;dbcreate, 'atom_bib', 1, 1, /external
dbcreate, 'atom_bb', 1, 1, /external
dbcreate, 'atom_bf', 1, 1, /external
dbcreate, 'atom_cbb', 1, 1, /external
dbcreate, 'atom_lvl', 1, 1, /external
dbclose
!priv = 0
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'start_ip.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
