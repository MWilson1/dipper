;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: isostr.pro
; Created by:    judge, June 21, 2006
;
; Last Modified: Sat Aug  5 14:31:43 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION isostr, l = l, t = t, c = c, elem, ion, omega
;+
; PROJECT:
;       HAOS-DIPER
;
; NAME:
;       isostr
;
; PURPOSE: obtain a structure of data along an isoelectronic sequence
;       
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       out=isostr(l = l,t = t,c = c)
;
; INPUTS:
;       None.
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       out   a structure containing data values along the
;       isoelectronic sequence
;
; OPTIONAL OUTPUTS:
;       elem   atomic numbers of isosequence members
;       ion    ionic numbers of isosequence members (1=neutral, etc)
;       omega  collision strength at 1.e4 (z+1)^2 K, for c=nn cases.
; KEYWORD PARAMETERS: 
;       l=nn   return isoelectronic data for level number nn
;       t=nn   return isoelectronic data for transition number nn
;       c=nn   return isoelectronic data for collisional data number nn
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
@cdiper
;   
nl = n_elements(l)
nt = n_elements(t)
nc = n_elements(c)
IF(nc eq 0 and nl eq 0 AND nt EQ 0) THEN $
      messdip,'at least one of l, t, c must be set, l=3 for example, or c=2'

IF(nl EQ 1) THEN BEGIN
   IF(nc NE 0 OR nt NE 0) THEN $
      messdip,'only one of l, t, c must be set'
   index = l
   stype = 0
ENDIF
;
IF(nt EQ 1) THEN BEGIN
   IF(nc NE 0 OR nl NE 0) THEN $
      messdip,'only one of l, t, c must be set'
   index = t
   stype = 1
ENDIF
;
IF(nc EQ 1) THEN BEGIN
   IF(nl NE 0 OR nt NE 0) THEN $
      messdip,'only one of l, t, c must be set'
   index = c
   stype = 2
ENDIF
iatom = atomn(atom.atomid,/num)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
IF(stype EQ 0) THEN BEGIN 
   dbopen,'atom_lvl,atom_bib'
   iso = iatom-lvl(index).ion+1
   j2p1 = lvl(index).tjp1
   term = lvl(index).term
   orb = lvl(index).orb
   ok = dbfind('isos='+string(iso),/sil)
   dbext,ok,'tjp1,term1,term2,term3,orb1,orb2,orb3',tjp1,t1,t2,t3,o1,o2,o3 ; this is all levels of isosequence
   k = where(tjp1 EQ j2p1 AND t1 EQ term(0) AND t2 EQ term(1) AND t3 EQ term(2) AND $
               o1 EQ orb(0) AND o2 EQ orb(1) AND o3 EQ orb(2) )
   out = replicate(lvldef,n_elements(k))
   str = 'atom, ion, e,  g, coupling, glande, label' 
   dbext, ok(k), str,elem, ion,  ev, g, coupling,glande, label
   str = 'tjp1,term1,term2,term3,orb1,orb2,orb3,bib_ref'
   dbext, ok(k), str,tjp1,term1,term2,term3,orb1,orb2,orb3,ref
   dbclose
   out.ion =  ion
   out.ev =  ev*cc*hh/ee        ; cm-1 to eV
   out.g =  g
   out.coupling =  coupling
   out.glande =  glande
   out.label =  label
   out.tjp1 =  tjp1
   FOR k = 0,n_elements(out)-1 DO BEGIN 
      out(k).term = [term1(k),term2(k),term3(k)]
      out(k).orb = [orb1(k),orb2(k),orb3(k)]
   ENDFOR
; get eff. qn's
   out.n = orb1/100
   out.smalll = (orb1 -100*out.n)/10
   out.active = (orb1 -100*out.n-10*out.smalll)
   dbopen,'atom_ip'
   indx = dbget('atom',elem,/sil)
   dbext,indx,'atom,ion,ip',at,io,ip
   dbclose
   k = where(at-io+1 EQ iso)
   io = io(k) &  ip = ip(k)
   ip1 = out.eff*0.
   FOR i = 0,n_elements(out)-1 DO BEGIN 
      k = where(io EQ out(i).ion,count)
      IF(count EQ 1) then BEGIN 
         ip1(i) = ip(k)
         out(i).eff = out(i).ion*sqrt(rydinf/ee/(ip1(i)-out(i).ev))
      ENDIF
  ENDFOR
  out.ref = ref
  GOTO, end1
ENDIF
;
;
; get labi and labj for the input structure levels
;
ir = trn(index).irad
jr = trn(index).jrad
gi = lvl(ir).g
gj = lvl(jr).g
;
ji = lvl(ir).tjp1
termi = lvl(ir).term
orbi = lvl(ir).orb
jj = lvl(jr).tjp1
termj = lvl(jr).term
orbj = lvl(jr).orb
isos = iatom-lvl(ir).ion+1
;
; now find indices matching qn's
;   
dbopen,'atom_lvl,atom_bib'
lvlok = dbfind('isos='+string(isos),/sil) ; fast
dbext,lvlok,'tjp1,term1,term2,term3,orb1,orb2,orb3',tjp1,t1,t2,t3,o1,o2,o3 ; this is all levels of isosequence
imatch = where(tjp1 EQ ji AND t1 EQ termi(0) AND t2 EQ termi(1) AND t3 EQ termi(2) AND $
               o1 EQ orbi(0) AND o2 EQ orbi(1) AND o3 EQ orbi(2) )
jmatch = where(tjp1 EQ jj AND t1 EQ termj(0) AND t2 EQ termj(1) AND t3 EQ termj(2) AND $
               o1 EQ orbj(0) AND o2 EQ orbj(1) AND o3 EQ orbj(2) )
;jmatch = where(array EQ labj)
imatch = lvlok(imatch)          ; lvl index where lower array eq labi
jmatch = lvlok(jmatch)          ; lvl index where upper array eq labj
dbclose
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
IF(stype EQ 1) THEN BEGIN
;
;  now match these to the atom_bb database
;   
   dbopen,'atom_bb,atom_bib'
   fidx = dbget('f_lab_i', imatch, /silent) ; finds bb indices with lvl indices enidx
   fjdx = dbget('f_lab_j', jmatch, /silent)
   ok = 0l
   FOR i = 0,n_elements(fjdx)-1 DO BEGIN 
      k = where(fidx EQ fjdx(i),coun)
      IF(coun NE 0) THEN ok = [ok,k]
   ENDFOR
   ok = ok(1:*)
   fidx = fidx(ok)
;
;  get data and write output to structure out
;
   out = replicate(trndef,n_elements(fidx))
   dbext, fidx,'f,wl,f_lab_i, f_lab_j, type,f_acc, atom,ion,isos,bb_ref',$
      f,wl,f_lab_i, f_lab_j, type,f_acc, elem,ion,isos,bb_ref
;
   out.f = f
   out.alamb = wl
   w = float(out.alamb)
   gi = gi(0) &  gj = gj(0)
   out.a=out.f*6.671e15*gi/(gj*w*w)
   out.bji=w*w*w*out.a/hc2
   out.bij=out.bji*gj/gi
   out.type = type
   dbclose
ENDIF
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
IF(stype EQ 2) THEN BEGIN
;
;  now match these to the atom_cbb database
;   
   dbopen,'atom_cbb,atom_bib'
   fidx = dbget('col_lab_i', imatch, /silent) ; finds bb indices with lvl indices imatch
   fjdx = dbget('col_lab_j', jmatch, /silent)
   ok = 0l
   FOR i = 0,n_elements(fjdx)-1 DO BEGIN 
      k = where(fidx EQ fjdx(i),coun)
      IF(coun NE 0) THEN ok = [ok,k]
   ENDFOR
   ok = ok(1:*)
   fidx = fidx(ok)
;
;  get data and write output to structure out
;
   dbext, fidx,'key,temp,col,ntemp,approx,col_lab_j,col_lab_i,acc,bib_ref',$
                key,temp,coll,ntemp,approx,col_lab_j,col_lab_i,acc,ref
   dbclose
   dbopen,'atom_lvl'
   dbext,col_lab_i,'atom,ion',elem,ion
   dbclose
;
   out = replicate(coldef,n_elements(fidx))
   out.key = key
   out.nt = ntemp
; 
   tout = 1.e4*ion*ion
   omega = tout*0.
   out.approx = approx
   out.ihi = col_lab_j
   out.ilo = col_lab_i
   out.ref = ref
   FOR i = 0,n_elements(out.key)-1 DO BEGIN 
      j = indgen(out(i).nt)
      out(j).temp = temp(j,i)
      out(j).data(i) = coll(j,i)
      spline_data = reform(out(j).data(i))
      CASE (GETWRD(out(i).key)) OF
         'SPLUPS':   omega(i) = ups_bt(tout(i),spline_data)
         'SPLUPS9':   omega(i) = ups_bt(tout(i),spline_data)
         'OHM': linterp, out(i,0:ntemp(i)-1), out(i,0:ntemp(i)-1), tout(i), omega(i)
         'else': BEGIN 
            messdip,/inf,'keyword is not for collision strengths: '+out(i).key
            omega = 0.
         END
      ENDCASE
   ENDFOR
ENDIF
end1:
IF(n_elements(out) EQ 1) THEN messdip,'only one member of isoelectronic sequence',/inf
return,out
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'isostr.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
