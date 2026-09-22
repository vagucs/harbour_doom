/* Rotinas para Formatos Truecolor Pixel */

function makecol8(r,g,b)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol8(r,g,b)
end if
return 0

function makecol15(r,g,b)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol15(r,g,b)
end if
return 0

function makecol16(r,g,b)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol16(r,g,b)
end if
return 0

function makecol24(r,g,b)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol24(r,g,b)
end if
return 0

function makecol32(r,g,b)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol32(r,g,b)
end if
return 0

function makeacol32(r,g,b,a)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N] .and. valtype(a)=[N]
   return _makeacol32(r,g,b,a)
end if
return 0

function makecol(r,g,b)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol(r,g,b)
end if
return 0

function makecol_depth(depth,r,g,b)
if valtype(depth)=[N] .and. valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N]
   return _makecol_depth(depth,r,g,b)
end if
return 0

function makeacol(r,g,b,a)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N] .and. valtype(a)=[N]
   return _makeacol(r,g,b,a)
end if
return 0

function makeacol_depth(depth,r,g,b,a)
if valtype(depth)=[N] .and. valtype(r)=[N] .and. valtype(g)=[N] .and.;
   valtype(b)=[N] .and. valtype(a)=[N]
   return _makeacol_depth(depth,r,g,b,a)
end if
return 0

function makecol15_dither(r,g,b,x,y)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N] .and.;
   valtype(x)=[N] .and. valtype(y)=[N]
   return _makecol15_dither(r,g,b,x,y)
end if
return 0

function makecol16_dither(r,g,b,x,y)
if valtype(r)=[N] .and. valtype(g)=[N] .and. valtype(b)=[N] .and.;
   valtype(x)=[N] .and. valtype(y)=[N]
   return _makecol16_dither(r,g,b,x,y)
end if
return 0

function getr8(c)
if valtype(c)=[N]
   return _getr8(c)
end if
return 0

function getg8(c)
if valtype(c)=[N]
   return _getg8(c)
end if
return 0

function getb8(c)
if valtype(c)=[N]
   return _getb8(c)
end if
return 0

function getr15(c)
if valtype(c)=[N]
   return _getr15(c)
end if
return 0

function getg15(c)
if valtype(c)=[N]
   return _getg15(c)
end if
return 0

function getb15(c)
if valtype(c)=[N]
   return _getb15(c)
end if
return 0

function getr16(c)
if valtype(c)=[N]
   return _getr16(c)
end if
return 0

function getg16(c)
if valtype(c)=[N]
   return _getg16(c)
end if
return 0

function getb16(c)
if valtype(c)=[N]
   return _getb16(c)
end if
return 0

function getr24(c)
if valtype(c)=[N]
   return _getr24(c)
end if
return 0

function getg24(c)
if valtype(c)=[N]
   return _getg24(c)
end if
return 0

function getb24(c)
if valtype(c)=[N]
   return _getb24(c)
end if
return 0

function getr32(c)
if valtype(c)=[N]
   return _getr32(c)
end if
return 0

function getg32(c)
if valtype(c)=[N]
   return _getg32(c)
end if
return 0

function getb32(c)
if valtype(c)=[N]
   return _getb32(c)
end if
return 0

function geta32(c)
if valtype(c)=[N]
   return _geta32(c)
end if
return 0

function getr(c)
if valtype(c)=[N]
   return _getr(c)
end if
return 0

function getg(c)
if valtype(c)=[N]
   return _getg(c)
end if
return 0

function getb(c)
if valtype(c)=[N]
   return _getb(c)
end if
return 0

function geta(c)
if valtype(c)=[N]
   return _geta(c)
end if
return 0

function getr_depth(color_depth,c)
if valtype(color_depth)=[N] .and. valtype(c)=[N]
   return _getr_depth(color_depth,c)
end if
return 0

function getg_depth(color_depth,c)
if valtype(color_depth)=[N] .and. valtype(c)=[N]
   return _getg_depth(color_depth,c)
end if
return 0

function getb_depth(color_depth,c)
if valtype(color_depth)=[N] .and. valtype(c)=[N]
   return _getb_depth(color_depth,c)
end if
return 0

function geta_depth(color_depth,c)
if valtype(color_depth)=[N] .and. valtype(c)=[N]
   return _geta_depth(color_depth,c)
end if
return 0

#pragma BEGINDUMP
#include <math.h>
#include <allegro.h>
#include <hbapi.h>

HB_FUNC(_MAKECOL8){
   hb_retnl((HB_ULONG)makecol8(hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_MAKECOL15){
   hb_retnl((HB_ULONG)makecol15(hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_MAKECOL16){
   hb_retnl((HB_ULONG)makecol16(hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_MAKECOL24){
   hb_retnl((HB_ULONG)makecol24(hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_MAKECOL32){
   hb_retnl((HB_ULONG)makecol32(hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_MAKEACOL32){
   hb_retnl((HB_ULONG)makeacol32(hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4)));
}

HB_FUNC(_MAKECOL){
   hb_retnl((HB_ULONG)makecol(hb_parnl(1),hb_parnl(2),hb_parnl(3)));
}

HB_FUNC(_MAKECOL_DEPTH){
   hb_retnl((HB_ULONG)makecol_depth(hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4)));
}

HB_FUNC(_MAKEACOL){
	 hb_retnl((HB_ULONG)makeacol(hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4)));
}

HB_FUNC(_MAKEACOL_DEPTH){
   hb_retnl((HB_ULONG)makeacol_depth(hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5)));
}

HB_FUNC(_MAKECOL15_DITHER){
	 hb_retnl((HB_ULONG)makecol15_dither(hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5)));
}

HB_FUNC(_MAKECOL16_DITHER){
	 hb_retnl((HB_ULONG)makecol16_dither(hb_parnl(1),hb_parnl(2),hb_parnl(3),hb_parnl(4),hb_parnl(5)));
}

HB_FUNC(_GETR8){
	 hb_retnl((HB_ULONG)getr8(hb_parnl(1)));
}

HB_FUNC(_GETG8){
	 hb_retnl((HB_ULONG)getg8(hb_parnl(1)));
}

HB_FUNC(_GETB8){
	 hb_retnl((HB_ULONG)getb8(hb_parnl(1)));
}

HB_FUNC(_GETR15){
	 hb_retnl((HB_ULONG)getr15(hb_parnl(1)));
}

HB_FUNC(_GETG15){
	 hb_retnl((HB_ULONG)getg15(hb_parnl(1)));
}

HB_FUNC(_GETB15){
	 hb_retnl((HB_ULONG)getb15(hb_parnl(1)));
}

HB_FUNC(_GETR16){
	 hb_retnl((HB_ULONG)getr16(hb_parnl(1)));
}

HB_FUNC(_GETG16){
	 hb_retnl((HB_ULONG)getg16(hb_parnl(1)));
}

HB_FUNC(_GETB16){
	 hb_retnl((HB_ULONG)getb16(hb_parnl(1)));
}

HB_FUNC(_GETR24){
	 hb_retnl((HB_ULONG)getr24(hb_parnl(1)));
}

HB_FUNC(_GETG24){
	 hb_retnl((HB_ULONG)getg24(hb_parnl(1)));
}

HB_FUNC(_GETB24){
	 hb_retnl((HB_ULONG)getb24(hb_parnl(1)));
}

HB_FUNC(_GETR32){
	 hb_retnl((HB_ULONG)getr32(hb_parnl(1)));
}

HB_FUNC(_GETG32){
	 hb_retnl((HB_ULONG)getg32(hb_parnl(1)));
}

HB_FUNC(_GETB32){
	 hb_retnl((HB_ULONG)getb32(hb_parnl(1)));
}

HB_FUNC(_GETA32){
	 hb_retnl((HB_ULONG)geta32(hb_parnl(1)));
}

HB_FUNC(_GETR){
	 hb_retnl((HB_ULONG)getr(hb_parnl(1)));
}

HB_FUNC(_GETG){
	 hb_retnl((HB_ULONG)getg(hb_parnl(1)));
}

HB_FUNC(_GETB){
	 hb_retnl((HB_ULONG)getb(hb_parnl(1)));
}

HB_FUNC(_GETA){
	 hb_retnl((HB_ULONG)geta(hb_parnl(1)));
}

HB_FUNC(_GETR_DEPTH){
	 hb_retnl((HB_ULONG)getr_depth(hb_parnl(1),hb_parnl(2)));
}

HB_FUNC(_GETG_DEPTH){
	 hb_retnl((HB_ULONG)getg_depth(hb_parnl(1),hb_parnl(2)));
}

HB_FUNC(_GETB_DEPTH){
	 hb_retnl((HB_ULONG)getb_depth(hb_parnl(1),hb_parnl(2)));
}

HB_FUNC(_GETA_DEPTH){
	 hb_retnl((HB_ULONG)geta_depth(hb_parnl(1),hb_parnl(2)));
}

#pragma ENDDUMP