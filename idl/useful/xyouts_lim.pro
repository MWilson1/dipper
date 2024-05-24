pro xyouts_lim,x1,x2,y1,y2,x,y,string,csize,angle,color,center=center
; output restricted if outside box
;
if(n_elements(csize) eq 0) then csize=1.0
if(n_elements(angle) eq 0) then angle=0.0
if(n_elements(center) eq 0) then align=0 else align=0.5
XHI = X1 > X2
XLO=X1 < X2
YHI= Y1 > Y2
YLO=Y1 < Y2
IF(X Ge XLO) AND (X Le XHI) AND (Y Ge YLO) AND (Y Le YHI)THEN $
XYOUTS,X,Y,STRING,size=csize,orientation=angle,color=color,alignment=align
return
end

