//----------------------------------------------------------------------------
//
// ALLEGTTF - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Utility clipping functions
//----------------------------------------------------------------------------
#include "internal.h"

int _antialiased_clip(int ct, int cb, int y, int *h)
{
	if (y + *h >= cb)
		*h = cb - y;

	if (y < ct)
		return ct - y;

	return 0;
}
