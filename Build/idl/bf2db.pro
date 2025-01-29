;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: bf2db.pro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO bf2db,doit = doit
;
@cdiper
COMMON top,pwd,tbdir
;
stim = systime(1)
yes = n_elements(doit) NE 0

pwd = concat_dir(getenv('PYDIPER'),'Build')
tbdir = concat_dir(pwd,'topbase')

file = concat_dir(tbdir,'all_op_levels.txt')
print,file
openr,lu,/get,file
str = ''
FOR i = 0,2 DO readf,lu,str
count = 0l
scount = 0l
baseref = 'OPACITY project; op. sampled to 60 wavelengths; vizier.u-strasbg.fr/topbase/topbase.html'
;
dbopen,'atom_bib'
rindx = dbfind('bib_ref='+baseref,count = count)
dbclose
;
; bib ref is not in database=> add
;
IF(count eq 0) THEN BEGIN 
   !priv = 2
   dbopen,'atom_bib',1
   dbbuild,baseref
   dbclose
   !priv = 0
   dbopen,'atom_bib'
   rindx = dbfind('bib_ref='+baseref,count = count)
   dbclose
ENDIF
;
;
IF(yes) THEN BEGIN 
   !priv = 2
;   dbcreate, 'atom_bf', 1, 1, /external
ENDIF
;
npts = 75
WHILE(NOT(eof(lu))) DO BEGIN 
   readf,lu,str
   count = count+1
   nz = fix(getwrd(str,1))
   en = fix(getwrd(str,2))
   nmax = 6 ; by default
   IF(en le 2) THEN nmax = 5  ; H, He-like
   ion = nz-en+1
   IF(ion EQ 1) THEN nmax = 9
   IF(ion GT 4) THEN nmax = 5
   islp = fix(getwrd(str,3))
   term = slp(islp,isp,il,ip)
   g = 1.*isp*(2.*il+1.)
   jstr = gtoj(g,/str)
   ilv = fix(getwrd(str,4))
   label = strupcase(strmid(str,23,16))
   label = strep(label,'()','')+' '+term+' '+jstr
   label = strcompress(label)
   label = strep(label,':',' ',/all) 
   dt = systime(1)-stim
   done = float(getwrd(str))/51410.*100.
   dpdt = done/dt*60.
   est = (100.-done)/dpdt
   if(count mod 100) eq 0 then print,done, '% done, elapsed = ',dt/60.,' remaining =  ',est,' minutes',$
      form = '(f4.1,1x,2(a,f7.1),a)'
   orig = label
   label = fixlab(label)
   lab2int,label,j2p1,term,orb,coupling
;   lv = lab2qn(e,g,label,ion,baseref)
;
   pqn = orb(0)/100
   IF(pqn GT nmax) THEN BEGIN 
      scount = scount+1
      str = string(scount)+', stored '+string(count-scount)
      messdip,'n > nmax, skipped '+str,/inf
      GOTO, skip
   ENDIF
   getop,nz,en,islp,ilv,lam,sig,lo,sigo,npts = npts,ok = ok
   IF(NOT ok) THEN BEGIN 
      scount = scount+1
      messdip,'no data',/inf
      GOTO, skip
   ENDIF
   nq = fix(n_elements(lam))
   time = sdptime()
   acc = 1000
   lam = float(lam)
   rindx = fix(rindx(0))
   IF(yes) THEN BEGIN
      dbopen,'atom_bf',1
         a1 = uint(term(0))
         a2 = uint(orb(0))
         a3 = uint(term(1))
         a4 = uint(orb(1))
         a4a = uint(term(2))
         a5 = uint(orb(2))
         ps = 0.5
         pl = 1.0
         picom,sig,s,mns,mxs,power = ps
         picom,lam,l,mnl,mxl,power = pl
         compdata= float([pl,mnl,mxl,ps,mns,mxs])
         edge = max(lam)
      dbbuild,nq,edge,l,s,compdata,nz,ion,en,a1,a2,a3,a4,a4a,a5,$
         uint(acc),rindx,/silent 
   ENDIF ELSE BEGIN 
      print,'------------------------------------------------------------'
      print,nq,lam(0),sig(0),nz,ion,en,label,acc,rindx,time 
;      IF(en eq 8 AND nz EQ 8) THEN BEGIN 
         ns = n_elements(lam)
         dekt = hh*cc*1.e8*(1./lam(ns-2)-1./lam(ns-1))/bk/1.e4
         print,dekt,trapez(lam,sig)/trapez(lo,sigo)-1.
         str = strn([dekt,trapez(lam,sig)/trapez(lo,sigo)-1.])
         plot_io,lo,sigo,ps = 3,titl = atomn(nz)+' '+roman(ion)+' '+str
         oplot,lam,sig,ps = 10
         str = '' &  read,str
;      endif
   endelse
   skip:
ENDWHILE
IF(yes) THEN BEGIN 
   dbclose
   !priv = 0
ENDIF
free_lun,lu
;
return
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'bf2db.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
