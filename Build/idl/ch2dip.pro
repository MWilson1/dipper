;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: ch2dip.pro
; Created by:    Phil Judge, High Altitude Observatory/NCAR, Boulder CO, August 7, 1998
;
; Last Modified: Mon Jul 31 16:37:06 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro ch2dip, elem,outdir = outdir
;
;
@cdiper
;common elvl,mult,ecm
;common wgfa, wvl,gf,a_value
;common upsilon,t_type,c_ups,splups
;
IF(n_elements(outdir) EQ 0) THEN outdir = 'atoms_latest/'

print,'Doing '+elem
el_diap=getwrd(elem,0,0,delim='_')
ion_diap=getwrd(elem,1,1,delim='_')
fname=!xuvtop+'/'+el_diap+'/'+elem+'/'+elem
wname=fname+'.wgfa'
;elvlname=fname+'.elvl'
elvlcname=fname+'.elvlc'
upsname=fname+'.scups'
;ok = findfile(elvlcname)
;IF(ok EQ '') THEN return
ok = findfile(wname)
IF(ok EQ '') THEN return
ok = findfile(elvlcname)
IF(ok EQ '') THEN return
;
;  read in level information, wavelengths, gf and A values from .wgfa files
;
read_elvlc,elvlcname,l1a,term,conf,ss,lla,jj,ecm,eryd,ecmth,erydth,eref
print,'no theoretical energy levels are included from CHIANTI...'
;
; fix term array to 1D
;
term1 = term
;
;  select only those energy levels that are not the ground state and
;  that are experimentally available.
;
good = where(conf NE 0 AND ecm NE 0.)
; add ground level back
good = [0,good]
l1a = l1a(good)
conf = conf(good)
ss = ss(good)
term = term1(good)
lla = lla(good)
jj = jj(good)
mult=2.*jj+1.
ecm = ecm(good)
ery = eryd(good)
ecmth = ecmth(good)
eryfth = erydth(good)
n_elvl=n_elements(ecm)
;
;  wavelengths, gf and A values from .wgfa files
;
read_wgfa2,wname,lvl1,lvl2,wvl1,gf1,a_value1,wgfaref;
ntrans=n_elements(lvl1)
nlvls=max([lvl1,lvl2])
wvl=fltarr(nlvls,nlvls)
gf=fltarr(nlvls,nlvls)
a_value=fltarr(nlvls,nlvls)
for itrans=0,ntrans-1 do begin
  wl1=lvl1(itrans)
  wl2=lvl2(itrans)
  wvl(wl1-1,wl2-1)=wvl1(itrans)
  gf(wl1-1,wl2-1)=gf1(itrans)
  a_value(wl1-1,wl2-1)=a_value(wl1-1,wl2-1)+a_value1(itrans)
endfor
irad = lvl1
jrad = lvl2
;
; collision strengths
; new for version 4.0
;
ok = findfile(upsname)
IF(ok ne '') THEN begin 
;
; new format after 2014 
;   
   read_scups,upsname,splstr,/fits
;
endif
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  DIPER FORMAT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Energy levels, NK, etc.
; first restrict to maximum of levels
;
;n_levels=min([n_elvl,n_wgfa1,n_wgfa2,n_ups1,n_ups2])
n_levels = n_elvl
iel=atomn(el_diap)
atom.atomid=strupcase(el_diap)
atom.nk=n_levels+1 ; 1 added for next ion stage
dbopen,'abund'
dbext,1,'abund',ab
dbclose
atom.abnd=ab(iel-1)
atom.awgt = (abmass(el_diap))(1)
nk = atom.nk
;
; energies, degeneracies, labels.
; 
lvl = replicate(lvldef,nk)
lvl.ev=[ecm*hh*cc/ee,0.]
lvl.g=[mult,0.]
lvl.label=strarr(nk)
lvl.ion=fix(ion_diap)+intarr(nk)
for i=0,nk-2 do begin
  dia_term=term(i)
  slen=strlen(dia_term)
  kk = strpos(dia_term,'/')
  IF(kk GT 0) THEN dd = 3 ELSE dd = 1
  dia_term=strmid(dia_term,0,slen-dd)
  pp = strpos(dia_term,'.')
  WHILE(pp GT 0) DO BEGIN 
     dia_term=strep(dia_term,'.',' ')
     pp = strpos(dia_term,'.')
  ENDWHILE
  dia_term=strupcase(strcompress(dia_term))
  par=par_config(getwrd(dia_term,/last,-20,-1))
  lvl(i).label=dia_term+par+' '+gtoj(lvl(i).g,/str)
endfor
;
;  Transitions.
;
ncont=0
nrfix=0
atom.nline=n_elements(lvl1)
atom.nrad=atom.nline
trndef.nq = 30 &  trndef.qmax = 30. &  trndef.q0 = 10. 
trn = replicate(trndef,atom.nrad)
trn.irad=lvl1
trn.jrad=lvl2
;
;
mq = 100
IF (atom.nrad GT 0) THEN trn = replicate(trndef,atom.nrad)
;
;
;  restrict to those levels actually in ecm variable
;
irad1 = trn.irad*0
jrad1 = trn.jrad*0
f = float(trn.irad)
;
kr = 0
FOR ii = 0, nk-3 DO BEGIN
   i = good(ii)
   FOR jj = i+1,nk-2 DO BEGIN
      j = good(jj)
      k = where(jrad-1 EQ j AND irad-1 EQ i,count)
      IF(count ge 1) THEN BEGIN 
         decm=abs(ecm(ii) -ecm(jj))
         al=1.d8/decm
         IF(count GT 1) THEN BEGIN 
            readit:
            print,'    i   A(i)'
            FOR iii = 0,count-1 DO print, k(iii),a_value1(k(iii))
         ENDIF
         F(kr) = total(a_value1(k(k)))/(6.671E15*lvl(ii).g/lvl(jj).g/al/al)
         IF(f(kr) EQ 0) THEN BEGIN
            print,'Zero f for levels (chianti indices)',jrad(k),' - ',irad(k)
         ENDIF
         irad1(kr) = ii
         jrad1(kr) = jj
         kr = kr+1
      ENDIF
   ENDFOR
ENDFOR
;
atom.nline = kr
atom.nrad = kr
nline = atom.nline
nrad = nline
trn = replicate(trndef,atom.nrad)
trn.irad = irad1(0:nline-1)
trn.jrad = jrad1(0:nline-1)
trn.f = f(0:nline-1)
;
; Spline upsilon coeffs
; 
z=splstr.info.ion_n
tmed = 3.7 + 2* alog10(z)
nt=9
temp= tmed - 2.5 + [0, 2, 3.5, 4.5, 5, 5.5, 6.5, 8, 10.]/2
coldata = coldef
ok = findfile(upsname)
IF(ok ne '') THEN begin 
   print,' COLLISIONS '
   coldata = coldef
   new = coldef
   done =  lonarr(n_elements(splstr.data))
;
; temperature grid narrowed towards the IE temperature.
;
   temp=10.^temp
   ndata = n_elements(splstr.data)
   count = 0
   for mmm=0,ndata-1 do begin
      n=splstr.data[mmm].lvl2
      m=splstr.data[mmm].lvl1
      t_type=splstr.data[mmm].t_type
;
; skip levels that are not good, for t_type ne 5 (dr lines)
;
      if((n GT n_levels-1 OR m GT n_levels-1)) THEN GOTO, skip 
;
;  convert to ups(temp)
;
      descale_scups, temp, splstr, mmm, ups
; upper and lower levels
      decm=ecm(n)-ecm(m)
      jr=n
      ir=m
      if(decm gt 0.) then begin 
         jr=n
         ir=m
      ENDIF ELSE BEGIN
         jr=m
         ir=n
      endelse
      nn = good(n)
      mm = good(m)
      if(t_type gt 0 AND done(mmm) EQ 0) then begin
         coldata.key = 'OHM'
         coldata.ihi = jr
         coldata.ilo = ir
         coldata.temp=temp
         coldata.nt = n_elements(temp) 
         count=count+1
         coldata.data=ups
         new = [new,coldata]
         done(mmm) = 1
      endif
      skip:
   endfor                       ;mmm
   coldata= new
endif
;
;
; add ionization stage
;
ion = lvl.ion
lvl(nk-1).ion = max(ion)+1
isos = isoseq(el_diap,ion(0),config = config1,term = term1,g0 = g1)
j1 = gtoj(g1,/str)
ionr=roman(ion(0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add in ionization potential
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
dbopen,'atom_ip'
str = 'atom=' + string(atomn(el_diap)) + ',ion='+string(ion(0))
j = dbfind(str,/sil)
dbext,j,'ip',y
dbclose
;
lvl(nk-1).ev = y 
y1 = getwrd(config1,-1,0,/last)    ; last word
y1 = STRUPCASE(y1)
uelem=strupcase(el_diap)
lvl(nk-1).label =  y1+' '+term1+' '+j1
lvl(nk-1).g = g1
;
; clean up labels (remove questionmarks)
;
question = 0
count = 0
FOR i = 0,nk-1 DO BEGIN 
   kk = strpos(lvl(i).label,'?')
   IF(kk GE 0) THEN BEGIN 
      question = [question,i]
      count = count+1
   ENDIF
   lvl(i).label = strep(lvl(i).label,'?','')
;
; individual cases 
   if(iel EQ 26 AND ion(0) EQ 6) THEN BEGIN 
      lvl(i).label = strep(lvl(i).label,'3D3(A)','3D2 (1SE) 3D')
      lvl(i).label = strep(lvl(i).label,'3D3(B)','3D2 (1DE) 3D')
   endif
ENDFOR
IF(count GT 0) THEN question = question(1:*)
;
;  Finish up!
;
IF(n_elements(coldata) LE 1) THEN BEGIN
   print,str+ '  no collisions '
   GOTO, skip2
ENDIF
;
skip2:
col = coldata
IF(!regime NE 2) THEN BEGIN
   fixbfcol
   j = WHERE(STRTRIM(col.key ) NE '')
   col = col(j)
ENDIF
strt_head,head,/chianti
chi_head,head,eref,wgfaref,splref
print,'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  writing    ', outdir+'atom.'+el_diap+ion_diap
atomwr,outdir+'atom.'+el_diap+ion_diap ,head
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'ch2dip.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
