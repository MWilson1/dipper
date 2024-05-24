;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: diper.pro
; Created by:    Philip G. Judge, February 24, 2006
;
; Last Modified: Thu Aug 24 15:22:12 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO diper,info = info,regime = regime,approx = approx, recalc=recalc,$
           demo = demo,units = units,summary = summary
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       diper
;
; PURPOSE: Set up/print information
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       diper
;
; INPUTS:
;       
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
;       /info         print information
;       regime=nn     regime change (0,1,2)
;       approx=nn     approx - uses bits (base 2). Default is 0
;                     approx=  1  +  2  +  4  +  8  +  16 
;                             (1)   (2)   (3)   (4)    (5)   bit number
;       if bit 1 is set (i.e. approx=1 + 2^n), make approximate collisional calcs
;       if bit 2 is set (approx=2+2^n, n ne 2) add rates for missing high n
;                       Rydberg states
;       if bit 3 is set (approx=4+2^n, n ne 3), ... 
;                     
;       demo=nn       run the demo number 1, 2 or 3
;       1  basic things
;       2  database things
;       3  using diprd
;       4  doing calculations   
;       5  marking lines / multiplets on spectra
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
;       Reads 
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, February 24, 2006
;-
;
;
; Are diper variables set up yet?
; if not, set them up
;
@cdiper
defsysv,'!diperv',exists = ok
vfile = concat_dir(getenv('DIPER'),'VERSION') ; use ssw multi-platform way.

IF(ok EQ 0) THEN begin   
   IF(n_elements(info) eq 0) THEN info = 1
   openr,lu,vfile,/get_lun
   version = ''
   date = ''
   readf,lu,version
   readf,lu,date
   free_lun,lu
   defsysv, '!diperv',[version,date]
   defsysv, '!regime', 0   
   defsysv, '!approx',0
   const
;
   dipdef  ; set up initial values for common block structures
   messdip,'system variables !diperv, !regime, !approx have been added',/INF
;
   dbopen,'atom_lvl'
   dbext,-1,'atom',a
   mxpqn = max(a)
   dbclose
ENDIF
;
; case of no keywords set- list the data
;
IF(n_elements(info) eq 0 AND n_elements(units) eq 0 AND $
   n_elements(regime) eq 0 AND n_elements(approx) eq 0 AND $
   n_elements(demo) eq 0 AND n_elements(summary) eq 0) THEN BEGIN
   info = 1
   units = 1
   regime = !regime
   approx = !approx
ENDIF
;
IF(n_elements(info) NE 0) THEN BEGIN 
   print,'   =============================================================='
   print,'   |HAO Spectral DIagnostic Package for Emitted Radiation       |'
   print,'   | (HAOS-DIPER Version ',!DIPERV(0),', ',!diperv(1),')','|',form = $
      '(a,a,a,a24,a,9x,a)'
   print,'   |                                                            |'
   print,'   |Bugs: report to judge@ucar.edu                              |'
   print,'   |                                                            |'
   print,'   |!regime determines how DIPER manipulates atomic data:       |'
   print,'   |                                                            |'
   print,'   |     0: Collisional-radiative, no photoionization,          |'
   print,'   |        recombination using rate coefficients               |'
   print,'   |     1: Collisional-radiative, photoionization/recombination|'
   print,'   |        calculated by the procedures                        |' 
   print,'   |     2: LTE: Radiative data only, no collisional data needed|'
   print,'   |                                                            |'
   print,'   |!approx determines if approximations should be used to fill |'
   print,'   |         missing collisional data (0:no, 1,1+2...:yes)      |'
   print,'   |                                                            |'
   print,'   |Use IDL> diper,regime=nn,approx=mm      to change regimes   |'
   print,'   --------------------------------------------------------------'
ENDIF

IF(n_elements(units) NE 0) THEN BEGIN 
   print,'   =============================================================='
   print,'   |Units for HAOS-DIPER Version '+!DIPERV(0)+'                            |'
   print,'   |CGS units are used throughout, except                       |'
   print,'   |  Atomic weights in atomic units (12C=12)                   |'
   print,'   |  Wavelengths are in Angstrom (10^-8 cm) *IN VACUO*         |'
   print,'   |    (use vactoair.pro to convert to air)                    |'
   print,'   --------------------------------------------------------------'
ENDIF



IF(n_elements(regime) NE 0) THEN BEGIN
   !regime = regime
   creg = ['CORONAL','NON-LTE','LTE    ']
   IF(regime lt 0 OR regime GT 2) THEN messdip,'regime must be 0,1 or 2: stop'
   print,'   =============================================================='
   print,'   |DIPER: !regime is now '+strn(!regime)+' = '+creg(!regime)+'                           |'
   print,'   |!regime: 0 is "coronal", 1 is "NON-LTE", 2 is "LTE"         |'
   print,'   --------------------------------------------------------------'
   messdip,/inf,'   =============================================================='
   messdip,/inf,'   |DIPER: !regime is now '+strn(!regime)+' = '+creg(!regime)+'                           |'
   messdip,/inf,'   |!regime: 0 is "coronal", 1 is "NON-LTE", 2 is "LTE"         |'
   messdip,/inf,'   --------------------------------------------------------------'
ENDIF
;
IF(n_elements(approx) NE 0) THEN BEGIN
   IF(approx lt 0 OR approx GT 31) THEN messdip,'approx must be 0 to 31: stop'
   !approx = approx
   print,'   =============================================================='
   messdip,/inf,'   =============================================================='
   print,'   |DIPER: !approx is now '+strn(!approx)+' (* bit is set below)                |'
   messdip,/inf,'   |DIPER: !approx is now '+strn(!approx)+' (* bit is set below)                |'
   bits,approx,bit
   IF bit(0) THEN $ 
      print,'   |*b-b collisional data will be approximated when needed      |' ELSE $
      print,'   | collisional data will not be approximated when needed      |' 
   IF bit(1) THEN BEGIN  
      print,'   |*recombination to high-n levels will be approximated        |' 
      print,'   | when needed  (and if !regime=1)                            |' 
   ENDIF ELSE $
      print,'   | recombination will not be added to missing high-n levels   |' 
   IF bit(2) THEN BEGIN  
      print,'   |*collisions involving missing high-n levels will be         |'
      print,'   | approximated when needed                                   |'
   ENDIF  ELSE $
      print,'   | collisions involving missing high-n levels omitted         |' 
   IF bit(3) THEN BEGIN  
      print,'   |*No density dependence on Burgess DR rates. 
   ENDIF  ELSE $
      print,'   | Density dependent effects on Burgess DR rates are included |' 
   print,'   --------------------------------------------------------------'
;
; log file
;
   IF bit(0) THEN $ 
      messdip,/inf,'   |*b-b collisional data will be approximated when needed      |' ELSE $
      messdip,/inf,'   | collisional data will not be approximated when needed      |' 
   IF bit(1) THEN BEGIN  
      messdip,/inf,'   |*recombination to high-n levels will be approximated        |' 
      messdip,/inf,'   | when needed  (and if !regime=1)                            |' 
   ENDIF ELSE $
      messdip,/inf,'   | recombination will not be added to missing high-n levels   |' 
   IF bit(2) THEN BEGIN  
      messdip,/inf,'   |*collisions involving missing high-n levels will be         |'
      messdip,/inf,'   | approximated when needed                                   |'
   ENDIF  ELSE $
      messdip,/inf,'   | collisions involving missing high-n levels omitted         |' 
   IF bit(3) THEN BEGIN  
      messdip,/inf,'   |*No density dependence on Burgess DR rates. 
   ENDIF  ELSE $
      messdip,/inf,'   | Density dependent effects on Burgess DR rates are included |' 
   messdip,/inf,'   --------------------------------------------------------------'
ENDIF
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; summary listing of entire database
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF(n_elements(summary) NE 0) THEN BEGIN 
   sfile = concat_dir(getenv('DIPER'),'SUMMARY') ; use ssw multi-platform way.
   j = findfile(sfile)
   IF(j(0) EQ '' or n_elements(recalc) ne 0) THEN BEGIN 
      dbopen, 'atom_lvl'
      dbext, -1,'atom', ato
      dbclose
      mx = max(ato)
      print,'Elements are present up to '+atomn(mx), ' z= ',mx
      str = 'Summary of data in HAOS-DIPER'
      str = [str,'NK=number of levels','MAX QN=maximum principal quantum number',$
             'NLINE=number of line transitions','NCOL=number of collisional transitions',$
             'NBF=number of bound-free radiative transitions (photoionization cross secns)']
      str = [str,'ION           NK  MAX QN  NLINE   NCOL    NBF']
      messdip,'searching database...',/inf
      FOR j = 1,mx DO BEGIN 
         dbopen,'atom_lvl'
         at = dbfind('atom='+string(j),/silent)
         dbclose
         IF(at(0) EQ 0) THEN GOTO, skip1
         print,atomn(j)
         dbopen,'atom_bb'
         bb = dbfind('atom='+string(j),/silent)
         FOR i = 1,j DO BEGIN 
            dbopen,'atom_lvl'
            k = dbfind('ion='+string(i),at,count = nk,/silent)
            dbext,k,'entry,orb1',entry,orb1
            n = orb1/100
            IF(k(0) LT 1) THEN GOTO, skip
            mxqn = max(n)
            dbopen,'atom_bb'
            st = 'ion='+string(i)
            ff = dbfind(st,bb,count = nline,/silent)
            dbopen, 'atom_cbb'
            ccol = dbget('col_lab_i', entry, count = ncol,/silent)
            dbopen,'atom_bf'
            k = dbfind('atom='+string(j)+',ion='+string(i),count = nbf,/silent)
            str1 = atomn(j)+' '+ roman(i)+' '
            str1 = str1+'                                       '
            str1 = strmid(str1,0,12)
            str = [str,str1+string(nk,form = '(I4)') $
                   +' '+string(mxqn,form = '(I4)') $
                   +' '+string(nline,form = '(I7)') $
                   +' '+string(ncol,form = '(I7)') $
                   +' '+string(nbf,form = '(I7)')]
            skip:
         ENDFOR
         skip1:
      ENDFOR
      dbclose
      messdip,'search done',/inf
      print_str,str,file = sfile
;      print_str,str
   ENDIF ELSE BEGIN 
      openr,lu,/get,sfile
      str = ''
      s = ''
      WHILE NOT(eof(lu)) DO BEGIN 
         readf,lu,s
         str = [str,s]
      ENDWHILE
      free_lun,lu
      print_str,str
   ENDELSE
;
ENDIF
;
IF(n_elements(demo) NE 0) THEN BEGIN 
   print,'        *******************************************************'
   print,'        *  these demos all list diper commands, in the form   *'
   print,'        *    IDL> command                                     *'
   print,'        *  and after you are prompted and press return,       *'
   print,'        *  these same commands are executed                   *'
   print,'        *******************************************************'
   CASE (demo) OF
      1: demobasic
      2: demodb
      3: demodiprd
      4: demose
      5: demoids
      ELSE: messdip,'demo must lie between 1 and 5'
   ENDCASE
ENDIF

return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'diper.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

