pro  ar85cea,zz,ilo,temp,cup
@cdiper
elem = atomn(zz)
charge=lvl(ilo).ion-1
isoseq=zz-charge
isoseq=atomn(isoseq)  
bkt=bk*temp/ee
;
IF(isoseq NE  'LI' AND isoseq  NE 'NA'  AND  isoseq NE 'MG'  $
   AND isoseq ne 'AL' AND isoseq  NE 'SI' AND isoseq NE 'P'AND isoseq NE 'S')$
   THEN GOTO, oddones
CASE isoseq OF
   'LI': BEGIN
      cea_b=1. / (1. + 2.e-4*zz*zz*zz)
      cea_zeff=(zz-0.43)
      cea_iea=13.6*((zz-0.835)*(zz-0.835) - 0.25*(zz-1.62)*(zz-1.62))
      y=cea_iea/bkt
      f1y=fone(y)
      cup= 1.60e-07 * 1.2* cea_b /cea_zeff/cea_zeff/SQRT(bkt) $
   * exp(-y)*(2.22*f1y+0.67*(1.-y*f1y)+0.49*y*f1y+1.2*y*(1.-y*f1y))
      IF(elem EQ 'C') THEN cup = cup*0.6 ; C IV - App A AR85
      IF(elem EQ 'N') THEN cup = cup*0.8 ; N  V - App A AR85
      IF(elem EQ 'O') THEN cup = cup*1.25 ; O VI - App A AR85
   END
   'NA': BEGIN
      IF (zz LE 16) THEN BEGIN
         cea_a=2.8e-17*(zz-11.)^(-0.7)
         cea_iea=26.*(zz-10.)
         y=cea_iea/bkt
         f1y=fone(y)
         cup= 6.69e+7 * cea_a *cea_iea/SQRT(bkt) * exp(-y)*(1. - y*f1y)
      ENDIF ELSE IF (zz GE 18 AND zz LE 28) THEN BEGIN
         cea_a=1.3e-14*(zz-10.)^(-3.73)
         cea_iea=11.*(zz-10.)*SQRT(zz-10.)
         y=cea_iea/bkt
         f1y=fone(y)
         cup= 6.69e+7 * cea_a *cea_iea/SQRT(bkt) * exp(-y) $ 
            *(1. - 0.5*(y -y*y + y*y*y*f1y))
      ENDIF ELSE BEGIN
         cup=0.
         return
      ENDELSE
   END
   ELSE: 
ENDCASE
IF(isoseq EQ 'MG' OR isoseq EQ 'AL' OR isoseq EQ 'SI' OR $
   isoseq EQ 'P' OR isoseq EQ 'S') THEN BEGIN
   CASE isoseq OF
      'MG': cea_iea=10.3*(zz-10.)^1.52
      'AL': cea_iea=18.0*(zz-11.)^1.33
      'SI': cea_iea=18.4*(zz-12.)^1.36
      'P' : cea_iea=23.7*(zz-13.)^1.29
      'S' : cea_iea=40.1*(zz-14.)^1.1
   ENDCASE
   cea_a=4.0e-13/zz/zz/cea_iea
   y=cea_iea/bkt
   f1y=fone(y)
   cup= 6.69e+7 * cea_a *cea_iea/SQRT(bkt) * exp(-y) $ 
      *(1. - 0.5*(y -y*y + y*y*y*f1y))
ENDIF
;
;  special cases
;
oddones:
IF(elem NE  'CA' AND elem NE 'FE') THEN RETURN
;      
IF(ELEM EQ 'CA' AND (charge EQ 0)) THEN BEGIN
   cea_a = 9.8e-17
   cea_iea= 25.
   cea_b=1.12         
   y=cea_iea/bkt
   f1y=fone(y)
   cup= 6.69e+7 * cea_a *cea_iea/sqrt(bkt) * exp(-y)*(1. + cea_b*f1y)
   print,'AR85-CEA special case ',ELEM, roman(charge+1)
ENDIF ELSE IF(ELEM EQ 'CA' AND (charge EQ 1)) THEN BEGIN
   cea_a = 6.0e-17
   cea_iea= 25.
   cea_b=1.12         
   y=cea_iea/bkt
   f1y=fone(y)
   cup= 6.69e+7 * cea_a *cea_iea/sqrt(bkt) * exp(-y)*(1. + cea_b*f1y)
ENDIF ELSE IF(ELEM EQ 'FE' AND (charge EQ 3)) THEN BEGIN
   cea_a = 1.8e-17
   cea_iea= 60.
   cea_b=1.0         
   y=cea_iea/bkt
   f1y=fone(y)
   cup= 6.69e+7 * cea_a *cea_iea/sqrt(bkt) * exp(-y)*(1. + cea_b*f1y)
ENDIF ELSE IF(ELEM EQ 'FE' AND (charge EQ 4)) THEN BEGIN
   cea_a = 5.0e-17
   cea_iea= 73.
   cea_b=1.0         
   y=cea_iea/bkt
   f1y=fone(y)
   cup= 6.69e+7 * cea_a *cea_iea/sqrt(bkt) * exp(-y)*(1. + cea_b*f1y)
ENDIF
return
end

