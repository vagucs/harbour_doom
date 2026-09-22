/* Rotinas para trabalhar com formas primitivas */

function clear_bitmap(imagem)
if valtype(imagem)=[O] .and. imagem:nHandle>0
   _clear_bitmap(imagem:nHandle)
end if
return nil

function clear_to_color(imagem,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(cor)=[N]
   _clear_to_color(imagem:nHandle,cor)
end if
return nil

function putpixel(imagem,linha,coluna,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N] .and. valtype(cor)=[N]
   _putpixel_(imagem:nHandle,linha,coluna,cor)
end if
return nil

function _putpixel(imagem,linha,coluna,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N] .and. valtype(cor)=[N]
   __putpixel(imagem:nHandle,linha,coluna,cor)
end if
return nil

function _putpixel15(imagem,linha,coluna,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N] .and. valtype(cor)=[N]
   __putpixel15(imagem:nHandle,linha,coluna,cor)
end if
return nil

function _putpixel16(imagem,linha,coluna,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N] .and. valtype(cor)=[N]
   __putpixel16(imagem:nHandle,linha,coluna,cor)
end if
return nil

function _putpixel24(imagem,linha,coluna,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N] .and. valtype(cor)=[N]
   __putpixel24(imagem:nHandle,linha,coluna,cor)
end if
return nil

function _putpixel32(imagem,linha,coluna,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N] .and. valtype(cor)=[N]
   __putpixel32(imagem:nHandle,linha,coluna,cor)
end if
return nil

function getpixel(imagem,linha,coluna)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N]
   _getpixel_(imagem:nHandle,linha,coluna)
end if
return nil

function _getpixel(imagem,linha,coluna)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N]
   __getpixel(imagem:nHandle,linha,coluna)
end if
return nil

function _getpixel15(imagem,linha,coluna)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N]
   __getpixel15(imagem:nHandle,linha,coluna)
end if
return nil

function _getpixel16(imagem,linha,coluna)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N]
   __getpixel16(imagem:nHandle,linha,coluna)
end if
return nil

function _getpixel24(imagem,linha,coluna)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N]
   __getpixel24(imagem:nHandle,linha,coluna)
end if
return nil

function _getpixel32(imagem,linha,coluna)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(linha)=[N] .and.;
   valtype(coluna)=[N]
   __getpixel32(imagem:nHandle,linha,coluna)
end if
return nil

function vline(imagem,coluna,linhai,linhaf,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linhai)=[N] .and. valtype(linhaf)=[N] .and. valtype(cor)=[N]
   _vline(imagem:nHandle,coluna,linhai,linhaf,cor)
end if
return nil

function hline(imagem,colunai,linha,colunaf,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(colunai)=[N] .and.;
   valtype(linha)=[N] .and. valtype(colunaf)=[N] .and. valtype(cor)=[N]
   _hline(imagem:nHandle,colunai,linha,colunaf,cor)
end if
return nil

function line(imagem,colunai,linhai,colunaf,linhaf,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(colunai)=[N] .and.;
   valtype(linhai)=[N] .and. valtype(colunaf)=[N] .and. valtype(linhaf)=[N] .and.;
   valtype(cor)=[N]
   _line(imagem:nHandle,colunai,linhai,colunaf,linhaf,cor)
end if
return nil

function fastline(imagem,colunai,linhai,colunaf,linhaf,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(colunai)=[N] .and.;
   valtype(linhai)=[N] .and. valtype(colunaf)=[N] .and. valtype(linhaf)=[N] .and.;
   valtype(cor)=[N]
   _fastline(imagem:nHandle,colunai,linhai,colunaf,linhaf,cor)
end if
return nil

function triangle(imagem,colp1,linp1,colp2,linp2,colp3,linp3,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(colp1)=[N] .and.;
   valtype(linp1)=[N] .and. valtype(colp2)=[N] .and. valtype(linp2)=[N] .and.;
   valtype(colp3)=[N] .and. valtype(linp3)=[N] .and. valtype(cor)=[N]
   _triangle(imagem:nHandle,colp1,linp1,colp2,linp2,colp3,linp3,cor)
end if
return nil

function rect(imagem,colunai,linhai,colunaf,linhaf,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(colunai)=[N] .and.;
   valtype(linhai)=[N] .and. valtype(colunaf)=[N] .and. valtype(linhaf)=[N] .and.;
   valtype(cor)=[N]
   _rect(imagem:nHandle,colunai,linhai,colunaf,linhaf,cor)
end if
return nil

function rectfill(imagem,colunai,linhai,colunaf,linhaf,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(colunai)=[N] .and.;
   valtype(linhai)=[N] .and. valtype(colunaf)=[N] .and. valtype(linhaf)=[N] .and.;
   valtype(cor)=[N]
   _rectfill(imagem:nHandle,colunai,linhai,colunaf,linhaf,cor)
end if
return nil

function circle(imagem,coluna,linha,radius,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linha)=[N] .and. valtype(radius)=[N] .and. valtype(cor)=[N]
   _circle(imagem:nHandle,coluna,linha,radius,cor)
end if
return nil

function circlefill(imagem,coluna,linha,radius,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linha)=[N] .and. valtype(radius)=[N] .and. valtype(cor)=[N]
   _circlefill(imagem:nHandle,coluna,linha,radius,cor)
end if
return nil

function ellipse(imagem,coluna,linha,radiusc,radiusl,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linha)=[N] .and. valtype(radiusc)=[N] .and. valtype(radiusl)=[N] .and.;
   valtype(cor)=[N]
   _ellipse(imagem:nHandle,coluna,linha,radiusc,radiusl,cor)
end if
return nil

function ellipsefill(imagem,coluna,linha,radiusc,radiusl,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linha)=[N] .and. valtype(radiusc)=[N] .and. valtype(radiusl)=[N] .and.;
   valtype(cor)=[N]
   _ellipsefill(imagem:nHandle,coluna,linha,radiusc,radiusl,cor)
end if
return nil

function arc(imagem,coluna,linha,fixedang1,fixedang2,radius,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linha)=[N] .and. valtype(fixedang1)=[N] .and. valtype(fixedang2)=[N] .and.;
   valtype(radius)=[N] .and. valtype(cor)=[N]
   _arc(imagem:nHandle,coluna,linha,fixedang1,fixedang2,radius,cor)
end if
return nil

function floodfill(imagem,coluna,linha,cor)
if valtype(imagem)=[O] .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and.;
   valtype(linha)=[N] .and. valtype(cor)=[N]
   _floodfill(imagem:nHandle,coluna,linha,cor)
end if
return nil

#pragma BEGINDUMP
#include <math.h>
#include <allegro.h>
#include <hbapi.h>

HB_FUNC(_CLEAR_BITMAP){
   clear_bitmap((BITMAP *)hb_parnl(1));
}

HB_FUNC(_CLEAR_TO_COLOR){
   clear_to_color((BITMAP *)hb_parnl(1),hb_parnl(2));
}

HB_FUNC(_PUTPIXEL_){
   putpixel((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

HB_FUNC(__PUTPIXEL){
   _putpixel((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

HB_FUNC(__PUTPIXEL15){
   _putpixel15((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

HB_FUNC(__PUTPIXEL16){
   _putpixel16((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

HB_FUNC(__PUTPIXEL24){
   _putpixel24((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

HB_FUNC(__PUTPIXEL32){
   _putpixel32((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

HB_FUNC(_GETPIXEL_){
   hb_retnl((HB_ULONG)getpixel((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(__GETPIXEL){
   hb_retnl((HB_ULONG)_getpixel((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(__GETPIXEL15){
   hb_retnl((HB_ULONG)_getpixel15((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(__GETPIXEL16){
   hb_retnl((HB_ULONG)_getpixel16((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(__GETPIXEL24){
   hb_retnl((HB_ULONG)_getpixel24((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(__GETPIXEL32){
   hb_retnl((HB_ULONG)_getpixel32((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_VLINE){
   vline((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5));
}

HB_FUNC(_HLINE){
   hline((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5));
}

HB_FUNC(_LINE){
   line((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6));
}

HB_FUNC(_FASTLINE){
   fastline((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6));
}

HB_FUNC(_TRIANGLE){
   triangle((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6),hb_parnl(7),hb_parnl(8));
}

HB_FUNC(_RECT){
   rect((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6));
}

HB_FUNC(_RECTFILL){
   rectfill((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6));
}

HB_FUNC(_CIRCLE){
   circle((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5));
}

HB_FUNC(_CIRCLEFILL){
   circlefill((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5));
}

HB_FUNC(_ELLIPSE){
   ellipse((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6));
}

HB_FUNC(_ELLIPSEFILL){
   ellipsefill((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6));
}

HB_FUNC(_ARC){
   arc((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5),hb_parnl(6),hb_parnl(7));
}

HB_FUNC(_FLOODFILL){
	floodfill((BITMAP *)hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4));
}

// do_line
// polygon
// do_circle
// do_ellipse
// do_arc
// calc_spline
// spline

#pragma ENDDUMP