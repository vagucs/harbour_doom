/* Fixed point math routines */

function itofix(numero)
if valtype(numero)=[N]
   return _itofix(numero)
end if
return 0

function fixtoi(numero)
if valtype(numero)=[N]
   return _fixtoi(numero)
end if
return 0

function fixfloor(numero)
if valtype(numero)=[N]
   return _fixfloor(numero)
end if
return 0

function fixceil(numero)
if valtype(numero)=[N]
   return _fixceil(numero)
end if
return 0



#pragma BEGINDUMP
#include <math.h>
#include <allegro.h>
#include <hbapi.h>

HB_FUNC(_ITOFIX){
	 hb_retnl((HB_ULONG)itofix(hb_parnl(1)));
}

HB_FUNC(_FIXTOI){
	 hb_retnl((HB_ULONG)fixtoi(hb_parnl(1)));
}

HB_FUNC(_FIXFLOOR){
	 hb_retnl((HB_ULONG)fixfloor(hb_parnl(1)));
}

HB_FUNC(_FIXCEIL){
	 hb_retnl((HB_ULONG)fixceil(hb_parnl(1)));
}

#pragma ENDDUMP

//fixed ftofix(double x)
//double fixtof(fixed x)
//fixed fixmul(fixed x, fixed y)
//fixed fixdiv(fixed x, fixed y)
//fixed fixadd(fixed x, fixed y)
//fixed fixsub(fixed x, fixed y)
//fixed fixsin(fixed x)
//fixed fixcos(fixed x)
//fixed fixtan(fixed x)
//fixed fixasin(fixed x)
//fixed fixacos(fixed x)
//fixed fixatan(fixed x)
//fixed fixatan2(fixed y,fixed x)
//fixed fixsqrt(fixed x)
//fixed fixhypot(fixed x, fixed y)
