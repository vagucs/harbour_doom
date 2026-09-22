#ifdef WIN32
#include "windows.h"
#include "hbapi.h"


HB_FUNC(WIN_SHOWCURSOR)
{
   ShowCursor(TRUE);
}

#elif defined LINUX
#include "hbapi.h"
HB_FUNC(WIN_SHOWCURSOR)
{
   // Apenas para compatiblidade
}
#endif