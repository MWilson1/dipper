;
els=['al','ar','c','ca','cl','co','cr','fe','h','he','k','mg','mn',$
        'n','na','ne','ni','o','p','s','si','ti','zn']
;
pwd = concat_dir(getenv('DIPER'),'build')
for i=0,n_elements(els)-1 do begin
  cd,!xuvtop+'/'+els(i)
  file=pwd+'/tmp'
  spawn,'ls > '+file
  str=''
  openr,lu,/get,file
  while not eof(lu) do begin
    readf,lu,str  
    print,str
; 
; read in and convert data
;     
    cd,pwd(0)
    IF(strpos(str,'d') GE 0) THEN GOTO, skip 
    ;IF(str EQ 'fe_2' OR str EQ 'fe_6') THEN GOTO,skip ; problematic labels
    ch2dip,str
    skip:
  endwhile
  free_lun,lu
endfor
;
cd,pwd
;
end
