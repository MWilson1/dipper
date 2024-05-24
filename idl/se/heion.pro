;
;*********************************************************************
;
FUNCTION heion,t
;  
;  helium ion number densitues from table iv of arnaud and rothenflug
;
IF(n_elements(t) NE 1) THEN messdip,'t must be a scalar'
tt =[4.00, 4.10, 4.20, 4.30, 4.40, 4.50, 4.60, $
 4.70, 4.80, 4.90,$
 5.00, 5.10, 5.20, 5.30, 5.40, 5.50, 5.60, 5.70]
one =[0.0 ,0.0 ,0.0 ,0.0 ,-0.07,-0.51,-1.33,-2.07,$
 -2.63,-3.20,-3.94,-4.67,-5.32,-5.90,-6.42,$
 -6.90,-7.33,-7.73]
two= [-9.05,-6.10,-3.75,-2.12,-0.84,-0.16, $
 -0.02,-0.01,-0.05,-0.34,-0.96,-1.60,-2.16,-2.63, $
 -3.03,-3.38,-3.68,-3.94]
tlog=alog10(t)
nt=n_elements(t)
f1=t*0.
f2=t*0.
f3=t*0.
if(nt eq 1) then begin
  if(tlog lt min(tt)) then begin
     f1=1.0
     f2=0.0
     f3=0.0
  endif else if(tlog gt max(tt)) then begin
     f1=0.0
     f2=0.0
     f3=1.0
  endif else begin
    linterp,tt,one,tlog,f1
    linterp,tt,two,tlog,f2
    f1=10.^f1
    f2=10.^f2
  endelse
endif else if (nt gt 1) then begin
  j=where(tlog lt min(tt),k) 
  if(k gt 0) then begin
     f1(j)=1.0
     f2(j)=0.0
     f3(j)=0.0
  endif
  j=where(tlog gt max(tt),k) 
  if(k gt 0) then begin
     f1(j)=0.0
     f2(j)=0.0
     f3(j)=1.0
  endif
  j=where((tlog le max(tt)) and (tlog ge min(tt)),k) 
  if(k gt 0) then begin
    linterp,tt,one,tlog(j),f11
    linterp,tt,two,tlog(j),f12
    f1(j)=10.^f11
    f2(j)=10.^f12
  endif
endif
;
return,[f1,f2,1.-f1-f2]
end
