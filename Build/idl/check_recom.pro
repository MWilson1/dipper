PRO check_recom,el,ion,corr = corr,_extra = _extra
@cdiper
diper,reg = 1
sion = string(ion)
diprd,el,ion
chg = el-ion+1
IF(el EQ 12) THEN level,del = [117,118,119]
sel = atomn(el)
t=10.^(3.2+chg/10+findgen(45)/15)
e=1.e15/t
;
dbopen,'shull82'
;
j=dbfind('atom='+string(el)+',ion='+sion)
dbprint,j,'atom,ion,arad,xrad,adi,bdi,t0,t1'
dbext,j,'arad,xrad,adi,bdi,t0,t1',arad,xrad,adi,bdi,t0,t1
c=arad(0)/(t/1.e4)^(xrad(0))
d=adi(0)/t/sqrt(t)*exp(-t0(0)/t)*(1.+bdi(0)*exp(-t1(0)/t))
;
NE_factor = 1.
IF(n_elements(corr) NE 0) THEN BEGIN 
   ilo1 = 0
   iel = atomn(atom.atomid,/num)
   iz = iel-lvl(ilo1).ion+1     ; isosequence of recombined ion
   rowcol,iz,irow,icol 
   zi = lvl(ilo1).ion           ; charge on recombining ion
   ro=e/zi/zi/zi/zi/zi/zi/zi
   x = (zi/2. + (icol-1.))*irow/3.0
   beta = -0.2/alog(x+2.71828)
   ro0 = 30.+50.*x
   ne_factor = (1. + ro/ro0)^beta
endif
print,NE_factor
d = d*NE_factor
;
IF(n_elements(ytitle) EQ 0) THEN ytitle = 'log!d10!n !4a!3!n cm!u-3!n s!u-1!n'
;
t = alog10(t)
plot,t,alog10(c+d),lines=2,title = sel+' '+roman(ion+1)+' -> '+sel+' '+roman(ion),xtit = 'log!d10!n Temperature K',ytitle = $
   ytitle,_extra = _extra
oplot,t,alog10(d),lines = 1
oplot,t,alog10(c),lines = 2
;
recoeff,10.^t,e,r,extra = extra
tot = total(r,1)+extra
oplot,t,alog10(tot)
oplot,t,alog10(tot+d)
legstr = ['detailed OP. proj. + !4a!3!dd!n','!4a!3!dd!n (Burgess)','!4a!3!dr!n, !4a!3!dr!n+!4a!3!dd!n','Nahar & Pradhan 1992']
legstr = legstr([3,0,1,2])
legend,/top,/left,legstr,lines = [0,0,1,2],psym = [-1,0,0,0],num = 3,pspac = 1
;
; special check cases,  Nahar+Pradhan 1992
;
;stop
IF(el GE 6 AND el LE 8) THEN BEGIN 
;   t = 3.6+findgen(11)*0.2
;   np = -10.5-[.42,.39,.40,.44,.49,.38,.14,.08,.18,.3,.55]
   ext = strlowcase(atomn(el))
   tabrd,'~/diper/doc/pradhan'+ext,tab
   t = tab(0,*)
   np = alog10(tab(ion,*))
   oplot,t,np,lines = 0,ps = -1
   k = where(t GT 4 AND t LT 5)
endif
IF(el EQ 10 AND ion EQ 5) THEN BEGIN 
   t = 4.0+findgen(11)*0.2
   np = -10.-[.08, .2,.40,.48,.5 ,.45,.45,.54,.73,.9    ]
   oplot,t,np,lines = 0,ps = -1
endif
return
END
