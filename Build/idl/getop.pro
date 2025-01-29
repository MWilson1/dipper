;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: getop.pro
; Created by:    Philip Judge, February 26, 1999
;
; Last Modified: Wed Aug 16 19:16:26 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO getop,elem,en,islp,inlvl,lambda,sigma,lorig,sigorig,ok = ok,$
          npts = npts,lmin = lmin
;+
;  gets lambda and sigma for op data with element elem, no of elecs en, and
;  level index inlvl
;-    
@cdiper
COMMON top,pwd,tbdir
COMMON localop, elold,enold
IF(n_elements(npts) EQ 0) THEN npts = 100
;
f = '(i2)'
pfile = 'p'+string(elem,form = f)+'.'+string(en,form = f)
pfile = strep(pfile,' ','0',/all)
pfile = concat_dir(tbdir,pfile)
openr,lu,pfile,/get
;
term = slp(islp,ins,inl,inp)
str = ''
readf,lu,str
is = 0 &  il = 0 &  ip = 0 &  ilv = 0 &  np = 0 &  nq = 0
;
next:
ok = 0
readf,lu,is,il,ip,ilv
IF(is+il+ip+ilv EQ 0) THEN BEGIN
   free_lun,lu
   ok = 0
   return
ENDIF
readf,lu,np,nq
IF(ilv EQ inlvl AND is EQ ins AND inl EQ il AND inp EQ ip) THEN BEGIN ; matched level
   tab = fltarr(2,nq+1)
   readf,lu,tab
   ok = 1
   limit = hh*cc/(tab(0,0)*rydinf)*1.e8 ; Angstrom
   e = reform(tab(0,1:*))*rydinf  ; ergs
   sig = reform(tab(1,1:*))
   s = sort(e)
   e = e(s) &  sig = sig(s)
   IF(monotonic(e) EQ 0) THEN BEGIN 
      messdip,'editing data',/inf
      good = where((e - shift(e,1)) GT 0.)
      good = [0,good]
      e = e(good)
      sig = sig(good)
   ENDIF
   okk = where(e GT 0.)
   e = e(okk)
   lam = hh*cc*1.e8/e           ; Angstrom
;
;  try to bin this....
;
   norig = n_elements(lam)
   sl = sort(lam)
   l = lam(sl)
   sig = sig(sl)
;   
   lorig = l
   sigorig = sig
;
   IF(n_elements(lmin) EQ 0) THEN lmin = min(l)
   k = where(l GT lmin)
   sig = sig(k)
   l = l(k)
;
; opacity sampling 
;
; linear wavelength grid
;
;   dl=(max(l)-lmin)/(npts-1)
;   mid=lmin+dl*(0.5+findgen(npts-1))
;   lnew=lmin+dl*(findgen(npts))
;
; other functions
;
; original (Aug 3)
;   
;   pow=0.7
;
; new version
   charge = elem-en
   charge = charge+1
   IF(charge GT 3 AND charge LT 5) THEN charge = 2 ; photoionization case
   tt = 5.e3+3.e3*charge^1.5 
   thresk = (hh*cc*1.e8/max(l)/bk/tt)
   pow = .2+0.5*(.8+1.8*alog10(thresk))
   ;print,'tt,thresk,pow,charge',tt,thresk,pow,charge
; end new version
   dx=(max(l)^pow-lmin^pow)/(npts-1)
   x=lmin^pow+dx*(0.5+findgen(npts-1))
   mid=x^(1./pow)
   x=lmin^pow+dx*(findgen(npts))
   lnew=x^(1./pow)
;
   sigma=lnew*0.
   for jj=0,npts-1 do begin 
     case(jj) of
       0: lims=[lnew(jj),mid(jj)]
       (npts-1): lims=[mid(jj-1),lnew(jj)]
       else: lims= [mid(jj-1),mid(jj)] ; other
     endcase
     k=where(l gt lims(0) and l lt lims(1),c)
   ; end points
     linterp,l,sig,lims,slims
     if(c gt 0) then begin 
        w=[lims(0),l(k),lims(1)] 
        s=[slims(0),sig(k),slims(1)] 
      endif else begin 
          w=lims
          s=slims
      endelse
      bin=trapez(w,s)
      sigma(jj)=bin/(lims(1)-lims(0))
   endfor
      lambda = lnew
   ENDIF ELSE BEGIN 
      str = ' '
      FOR i = 0,nq DO readf,lu,str,form = '(A1)'
      GOTO, next
   ENDELSE
free_lun,lu
RETURN
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'getop.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
