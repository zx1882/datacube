;
;by Zhou, Xin; v1.0; 20080312
;; Purpose     : 
;       Extract a smaller 3-D datacube with .fits type from a larger one
;
; Input: indexrange: [xmin,xmax,ymin,ymax], in ds9

;restriction: just first 2 axises considered

;pro extract_3d,input,output,xmin,xmax,ymin,ymax
pro extract_3d,input,output,indexrange=indexrange,vrange=vrange


if (n_params() ne 2) then message,'USAGE:   extracter,input,output,indexrange=indexrange,vrange=vrange ;index in the one in ds9'
 
;input: xmin etc. are the index in ds9 (with 1 the first)

;output:

; PROCEDURE CALLS:
;       fits_read,writefits 

;--ini
fits_read,input,data,head
if keyword_set(indexrange) then begin
 xmin=indexrange[0]-1 & xmax=indexrange[1]-1
 ymin=indexrange[2]-1 & ymax=indexrange[3]-1
endif else begin
 xmin=0 & xmax=sxpar(head,'naxis1')-1
 ymin=0 & ymax=sxpar(head,'naxis2')-1
endelse

v=(findgen(sxpar(head,'naxis3'))+1-sxpar(head,'crpix3'))*sxpar(head,'cdelt3')+sxpar(head,'crval3')
if abs(sxpar(head,'cdelt3')) gt 10 then v=v/1000.
if keyword_set(vrange) then begin
 tvindmin=where(abs(vrange[0]-v) eq min(abs(vrange[0]-v))) & tvindmin=tvindmin[0]
 tvindmax=where(abs(vrange[1]-v) eq min(abs(vrange[1]-v))) & tvindmax=tvindmax[0]
 if sxpar(head,'cdelt3') le 0 then begin
  t=tvindmin
  tvindmin=tvindmax & tvindmax=t
 endif
endif else begin
 tvindmin=0 & tvindmax=sxpar(head,'naxis3')-1
endelse

;--
;d=fltarr(1+xmax-xmin,1+ymax-ymin,(size(data))[3])
d=fltarr(1+xmax-xmin,1+ymax-ymin,1+tvindmax-tvindmin)
;d[0:xmax-xmin,0:ymax-ymin,*]=data[xmin-1:xmax-1,ymin-1:ymax-1,*]
d=data[xmin:xmax,ymin:ymax,tvindmin:tvindmax]
;for i=xmin-1,xmax-1 do begin
;	for j=ymin-1,ymax-1 do begin
;		for k=0,(size(data))[3]-1 do begin
;			d[i-xmin+1,j-ymin+1,k]=data[i,j,k]
;		endfor
;	endfor
;endfor

naxis1=1+xmax-xmin
naxis2=1+ymax-ymin
naxis3=1+tvindmax-tvindmin
crpix1=sxpar(head,'crpix1')-xmin
crpix2=sxpar(head,'crpix2')-ymin
crpix3=sxpar(head,'crpix3')-tvindmin

writefits,output,d,head

fxhmodify,output,'naxis1',naxis1
fxhmodify,output,'naxis2',naxis2
fxhmodify,output,'naxis3',naxis3
fxhmodify,output,'crpix1',crpix1
fxhmodify,output,'crpix2',crpix2
fxhmodify,output,'crpix3',crpix3


end
