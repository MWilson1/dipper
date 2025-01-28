function par_config, label
par='E'
lab=label
j=strpos(lab,'(')
;
if(j ne -1) then begin 
  first=getwrd(lab,0,0,delim='(')
  last=getwrd(lab,1,1,delim=')')
  lab=first+' '+last
endif

;
;
lab=strlowcase(lab)
last='dummy'
par=0
i=0
while last ne '' do begin
  last=getwrd(lab,i,i)
  p=strpos(last,'p')
  if(p ne -1) then begin
    nelec = strmid(last,p+1,1)
    if(nelec eq '1' or nelec eq ' ' or nelec eq '' or nelec eq '3' or nelec eq '5') then par=par+1
  endif
  f=strpos(last,'f')
  if(f ne -1) then begin
    nelec = strmid(last,f+1,1)
    if(nelec eq '1' or nelec eq ' ' or nelec eq '' or nelec eq '3' or nelec eq '5' or nelec eq '7') then par=par+1
  endif
  h=strpos(last,'h')
  if(h ne -1) then begin
    nelec = strmid(last,h+1,1)
    if(nelec eq '1' or nelec eq ' ' or nelec eq '' or nelec eq '3' or nelec eq '5' or nelec eq '7') then par=par+1
  endif
  i=i+1
endwhile
spar=['E','O','E','O','E','O','E','O','E','O','E','O','E','O','E','O','E','O','E','O','E','O']
return,spar(par)
end
