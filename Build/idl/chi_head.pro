;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: chi_head.pro
; Created by:    Philip Judge, November 13, 2004
;
; Last Modified: Mon Jul 31 16:55:46 2006 by judge (judge) on edlen.local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO chi_head,header,e,w,u
;   
;  use headers from references from CHIANTI
;
keys=header.key
for i=0,n_elements(keys)-1 do begin
   if(keys(i) eq 'ENERGIES') then begin
      header(i).text=''
      for k=0,n_elements(e)-1 do BEGIN 
;
; corrections
;           
         e(k) = strep(e(k),'observed energies','observed energy levels')
;
         dum=strpos(strcompress(strlowcase(e(k)),/remove_all),'energylev')       
         dum1=strpos(strcompress(strlowcase(e(k)),/remove_all),'theoretical')       
         if(dum ne -1 AND dum1 EQ -1) then begin 
            wrd = getwrd(e(k),/last,delim = ':')
            header(i).text=header(i).text+wrd+' '
            j = k+1
            IF(j EQ n_elements(e)) THEN GOTO, nexte
            dum=strpos(e(j),'%')
            WHILE(dum EQ -1) DO BEGIN 
               header(i).text=header(i).text+e(j)+' '
               j = j+1
               k = j
               IF(j EQ n_elements(e)) THEN GOTO, nexte
               dum=strpos(e(j),'%')
            endwhile
         ENDIF
         nexte:
      ENDFOR
   ENDIF 
;
; Oscillator strengths
;
   if(keys(i) eq 'GFS-REF') then begin
      header(i).text=''
      for k=0,n_elements(w)-1 do BEGIN 
         dum=strpos(strcompress(strlowcase(w(k)),/remove_all),'oscillatorstreng')       
         dum1=strpos(strcompress(strlowcase(w(k)),/remove_all),'avalue')       
         dum2=strpos(strcompress(strlowcase(w(k)),/remove_all),'gfval')       
         dum3=strpos(strcompress(strlowcase(w(k)),/remove_all),'transitionprob')       
         if(dum NE -1 OR dum1 NE -1 OR dum2 NE -1 OR dum3 NE -1) then begin 
            wrd = getwrd(w(k),/last,delim = ':')
            header(i).text=header(i).text+wrd+' '
            j = k+1
            IF(j EQ n_elements(w)) THEN GOTO, nextw
            dum1=strpos(w(j),'%')
            WHILE(dum1 EQ -1) DO BEGIN 
               header(i).text=header(i).text+w(j)+' '
               j = j+1
               k = j
               IF(j EQ n_elements(w)) THEN GOTO, nextw
               dum1=strpos(w(j),'%')
            endwhile
         ENDIF
         nextw:
      ENDFOR
   ENDIF 
;
; Collision strengths
;
   if(keys(i) eq 'OHM-REF') then begin
      header(i).text=''
      for k=0,n_elements(u)-1 do BEGIN 
;
; corrections
;           
         u(k) = strep(u(k),'%upsilons:','%collision strengths:')
         dum=strpos(strcompress(strlowcase(u(k)),/remove_all),'collisionstreng')       
         dum1=strpos(strcompress(strlowcase(u(k)),/remove_all),'collisonstreng')       
         if(dum NE -1 OR dum1 NE -1) then begin 
            wrd = getwrd(u(k),/last,delim = ':')
            header(i).text=header(i).text+wrd+' '
            j = k+1
            IF(j EQ n_elements(u)) THEN GOTO, nextu
            dum1=strpos(u(j),'%')
            IF(dum1 EQ 0) THEN GOTO, nextu 
               header(i).text=header(i).text+u(j)+' '
               j = j+1
               k = j
               IF(j EQ n_elements(u)) THEN GOTO, nextu
               dum1=strpos(u(j),'%')
         ENDIF
         nextu:
      ENDFOR
   ENDIF 
ENDFOR
header.text=strcompress(header.text)
print,transpose(header.text)
; 
;
return
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'chi_head.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
