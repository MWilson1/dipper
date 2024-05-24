;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: ground.pro
; Created by:    judge, June 12, 2006
;
; Last Modified: Fri Apr 13 13:37:24 2007 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION ground,iatom,ion
;
@cdiper
;
; 0S0 needed for bare nuclei- same as closed shell qn
;   
i = iatom-ion+1
;print,iatom,ion
sa = atomn(iatom) +' '+ roman(ion)
IF(i GT 20 AND ion GT 1) THEN $
   messdip,/inf,'GROUND: warning- potentially inaccurate ground config/term for '+sa
IF(i GT 30) THEN messdip,'GROUND: this atom has too many electrons, max is 30'
CONF=['0S0','1S','1S2','1S2 2S','1S2 2S2','1S2 2S2 2P',$
'1S2 2S2 2P2', $
'1S2 2S2 2P3', $
'1S2 2S2 2P4', $
'1S2 2S2 2P5', $
'1S2 2S2 2P6', $
'2S2 2P6 3S', $
'2S2 2P6 3S2', $
'2P6 3S2 3P', $
'2P6 3S2 3P2', $
'2P6 3S2 3P3', $
'2P6 3S2 3P4', $
'2P6 3S2 3P5', $
'2P6 3S2 3P6', $
'2P6 3S2 3P6 4S', $
'2P6 3S2 3P6 4S2', $
'3S2 3P6 3D 4S2', $
'3S2 3P6 3D2 4S2', $
'3S2 3P6 3D3 4S2', $
'3S2 3P6 3D5 4S', $
'3S2 3P6 3D5 4S2', $
'3S2 3P6 3D6 4S2', $
'3S2 3P6 3D7 4S2 ', $
'3S2 3P6 3D8 4S2',$
'3S2 3P6 3D10 4S',$
'3S2 3P6 3D10 4S2']
n = n_elements(conf)
term = strarr(n)
pens = ''
;
FOR i = 0,n-1 DO BEGIN
   opens = strmid(getwrd(conf(i),0,/last),1,3)
   opens = strtrim(opens,2)
   CASE (opens) OF
      'S' : term(i) =  '2SE'
      'S0': term(i) =  '1SE'
      'S2': term(i) =  '1SE'
      'P' : term(i) =  '2PO'
      'P2': term(i) =  '3PE'
      'P3': term(i) =  '4SO'
      'P4': term(i) =  '3PE'
      'P5': term(i) =  '2PO'
      'P6': term(i) =  '1SE'
      ELSE:
   ENDCASE
ENDFOR
;
; special cases, iron group- approximate for ionized species
;
term(20:27) = ['2DE','3FE','4FE','7SE','6SE','5DE','4FE','3FE']
g0 = fltarr(n)
FOR i = 0,n-1 DO BEGIN
   tsp1 = STRMID(term(i),0,1)
   l = STRMID(term(i),1,1)
   l = STRPOS(designations,l)
   g0(i) = (2*l+1)*tsp1
ENDFOR
;
i = iatom-ion+1
label =  conf(i)+' '+term(i)+' '+gtoj(g0(i),/str)+'                                             '
energy = 0.d0 &  g = g0(i) 
ref = 'source: ground.pro'
lv = lab2qn(energy,g,label,ion,ref)
lv.meta = 1
return,lv
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'ground.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
