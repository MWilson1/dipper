function concat_ref,ref
;
ref=strtrim(ref)  ; remove trailing, leading blanks
k=n_elements(ref)
;
if(k eq 1) then return,strcompress(ref)
refnew=strarr(k)
count=-1
for i=0,k-1 do begin 
  newi=strpos(ref(i),'%')
  if(newi eq 0) then begin 
    count=count+1
    refnew(count)=ref(i)
  endif else begin 
   if(count ge 0) then refnew(count)=refnew(count)+' '+ ref(i)
  endelse
end
return,strcompress(refnew(0:count))
end
