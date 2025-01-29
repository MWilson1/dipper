  
name=['atom_lvl', 'atom_bb','atom_bf','atom_cbb']


odir = concat_dir(getenv('PYDIPER'),'temporary')


;for k=0, 3 do begin 
for k=2, 2 do begin 
   print,name[k]
   dbopen,name[k]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   if(k eq 0) then begin 
      str='ENTRY,ATOM,ION, ISOS,E,   G,   COUPLING,GLANDE,LABEL,TJP1,TERM1,ORB1'
      dbext,-1,str,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12
       str='TERM2,ORB2, TERM3,ORB3'      
      dbext,-1,str,v13,v14,v15,v16
      openw,lu,/get,concat_dir(odir,name[k]+'.ascii')
      sp=' '
      printf,lu,'entry atom ion isos e g glande tjp1 term1 orb1 term2 orb2 term3 orb3'
      print,n_elements(v1)
      for i=0,n_elements(v1)-1 do begin
         s=string(v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],$
                  sp,v8[i],v10[i],v11[i],v12[i],v13[i],v14[i],v15[i],v16[i])
         printf,lu,strcompress(s)
      endfor
      free_lun,lu
      ;
      openw,lu,/get,concat_dir(odir,name[k]+'str.ascii')
      sp=','
      print,n_elements(v1)
      printf,lu,'# , label , coupling'
      for i=0,n_elements(v1)-1 do begin
         s=string(v1[i],sp,v9[i],sp,v7[i])
         s=strep(s,'\','/',/all)
         printf,lu,strcompress(s)
      endfor
      free_lun,lu
   endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   if(k eq 1)  then begin
      str='ENTRY,F,WL, F_LAB_J,F_LAB_I,TYPE, F_ACC,ATOM, ION,ISOS'
      dbext,-1,str,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10
      openw,lu,/get,concat_dir(odir,name[k]+'.ascii')
      sp=' '
      print,n_elements(v1)
      for i=0,n_elements(v1)-1 do begin
         s=string(v1[i],v2[i],v3[i],v4[i],v5[i],v8[i],v9[i],v10[i])
         printf,lu,strcompress(s)
      endfor
      free_lun,lu
      openw,lu,/get,concat_dir(odir,name[k]+'str.ascii')
      sp=','
      for i=0,n_elements(v1)-1 do begin
         s=string(v6[i])
         printf,lu,strcompress(s)
      endfor
      free_lun,lu
;      for i=0,n_elements(v1)-1,1000 do print,v6[i]
   endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   if(k eq 2)  then begin
      str='ENTRY,NQ,EDGE,ATOM,ION,ISOS,TERM1,ORB1,TERM2,ORB2,TERM3,ORB3'    
      dbext,-1,str,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12
      str='COMPRESS,LAMBDA,SIGMA'    
      dbext,-1,str,v13,v14,v15
      openw,lu,/get,concat_dir(odir,name[k]+'.ascii')
      sp=' '
      minw=1.e6
      maxw=0.
      
      mins=1.e6
      maxs=0.
      
      print,n_elements(v1)
      for i=0,n_elements(v1)-1 do begin
         s=string(v1[i])+string(v2[i])+string(long(v3[i]*100))+string(v4[i])+string(v5[i])+ $
           string(v6[i])+string(v7[i])+string(v8[i])+string(v9[i])+string(v10[i])+$
           string(v11[i])+string(v12[i])
         compr=v13[*,i]
         picom,lam,v14[*,i],compr(1),compr(2),/rev,power = compr(0)
         picom,sig,v15[*,i],compr(4),compr(5),/rev,power = compr(3)
         minw=minw < min(lam)
         maxw=maxw > max(lam)
         mins=mins < min(sig)
         maxs=maxs > max(sig)
         form='(f6.3)'
         p=1./3
         lam=lam^p
         sig=sig^p
         for j=0,74 do s+=string(lam[j],form=form)+' '
         for j=0,74 do s+=string(sig[j],form=form)+ ' '
         printf,lu,strcompress(s)
;         print,minw,maxw,mins,maxs
;         plot,lam,sig,ps=10
;         stop
      endfor
      free_lun,lu
   endif
   if(k eq 3)  then begin
      str='ENTRY,TEMP,COL,NTEMP,APPROX,COL_LAB_J,COL_LAB_I'
      dbext,-1,str,v1,v2,v3,v4,v5,v6,v7
      openw,lu,/get,concat_dir(odir,name[k]+'.ascii')
      print,n_elements(v1)
      printf,lu,' entry nt type j  i temp(nt) omega(nt)' 
      sp=' '
      for i=0,n_elements(v1)-1 do begin
         s =string(v1[i],v4[i],v5[i],v6[i],v7[i])
         
         stemp=string(alog10(v2[0:v4[i]-1,i]),format='('+string(v4[i])+'(1x,f5.2))')
         if(i eq 10)then  print,stemp, (v3[0:v4[i]-1])
         s+=stemp
         s+=string(v3[0:v4[i]-1,i],        format='('+string(v4[i])+'(1x,e8.2))')
         printf,lu,strcompress(s)
      endfor
      free_lun,lu
   endif
endfor ;names
   
end
