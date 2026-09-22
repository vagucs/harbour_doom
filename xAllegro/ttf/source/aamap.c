//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Basic aliasmap functions
//----------------------------------------------------------------------------
#include <allegro.h>
#include "internal.h"

/* Used for scratchpad for blitting the characters */
BITMAP *_scratchpad = NULL;

/* Used for fast aliasing for filled background modes */
int _aliasmap_foreground = -1;
int _aliasmap_background = -1;
int _aliasmap_depth = -1;
int _aliasmap[8];

/*----------------------------------------------------------------------------
   Setup the global aliasmap for fast aliasing of text with
   filled backgrounds.
*/
void _setup_aliasmap(int fg, int bg, int depth)
{
	int cr, cg, cb, tr, tg, tb;
	int (*colmaker) (int, int, int);

	int darkness, index;

	switch (depth) {
	case (15):
		cr = getr15(fg);
		cg = getg15(fg);
		cb = getb15(fg);

		tr = getr15(bg);
		tg = getg15(bg);
		tb = getb15(bg);

		colmaker = makecol15;
		break;
	case (16):
		cr = getr16(fg);
		cg = getg16(fg);
		cb = getb16(fg);

		tr = getr16(bg);
		tg = getg16(bg);
		tb = getb16(bg);

		colmaker = makecol16;
		break;
	case (24):
		cr = getr24(fg);
		cg = getg24(fg);
		cb = getb24(fg);

		tr = getr24(bg);
		tg = getg24(bg);
		tb = getb24(bg);

		colmaker = makecol24;
		break;
	case (32):
		cr = getr32(fg);
		cg = getg32(fg);
		cb = getb32(fg);

		tr = getr32(bg);
		tg = getg32(bg);
		tb = getb32(bg);

		colmaker = makecol32;
		break;
	default:
		cr = getr8(fg);
		cg = getg8(fg);
		cb = getb8(fg);

		tr = getr8(bg);
		tg = getg8(bg);
		tb = getb8(bg);

		colmaker = makecol8;
		break;
	}

	/* Build the color map */
	darkness = 37;
	for (index = 1; index < 7; index++) {
		_aliasmap[index] =
			colmaker((cr * darkness + (255 - darkness) * tr) >> 8, (cg * darkness + (255 - darkness) * tg) >> 8,
					 (cb * darkness + (255 - darkness) * tb) >> 8);
		darkness += 37;
	}
	_aliasmap[0] = bg;
	_aliasmap[7] = fg;

	/* Confirm that the aliasmap has been built */
	_aliasmap_foreground = fg;
	_aliasmap_background = bg;
	_aliasmap_depth = depth;
}

/*----------------------------------------------------------------------------
   Make sure the aliasmap has the correct foreground and background colors
   and also prepare the scratchpad
*/
void _prepare_aliasmap(int fg, int bg, int depth)
{
	/* Possible setup the quick color alias map */
	if ((fg != _aliasmap_foreground) || (bg != _aliasmap_background) || (_aliasmap_depth != depth)) {
		_setup_aliasmap(fg, bg, depth);
	}

	/* Possible setup for internal scratchpad bitmap */
	if ((_scratchpad == NULL) || (bitmap_color_depth(_scratchpad) != depth)) {
		if (_scratchpad != NULL)
			destroy_bitmap(_scratchpad);
		_scratchpad = create_bitmap_ex(depth, _SCRATCHPAD_WIDTH, _SCRATCHPAD_HEIGHT);
	}
}
