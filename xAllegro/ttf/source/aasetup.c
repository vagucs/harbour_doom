//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Basic text drawing functions
//----------------------------------------------------------------------------
#include "allegttf.h"
#include "internal.h"

/* Used for fast changing of the transparency map in 256 color aliasing */
/* color_map46 is used as a flag to see if the color maps have been initialized */
COLOR_MAP *_alias_color_map46 = NULL;
COLOR_MAP *_alias_color_map141 = NULL;

/*----------------------------------------------------------------------------
   8 bit mode palette setup function
*/
void antialias_palette(PALETTE pal)
{
	/* If NULL then clear the palette */
	if (pal == NULL) {
		free(_alias_color_map46);
		free(_alias_color_map141);

		_alias_color_map46 = _alias_color_map141 = NULL;
	}
	/* Otherwise use the user's palette */
	else {
		/* Allocate the color maps */
		if (_alias_color_map46 == NULL)
			_alias_color_map46 = (COLOR_MAP *) malloc(sizeof(COLOR_MAP));
		if (_alias_color_map141 == NULL)
			_alias_color_map141 = (COLOR_MAP *) malloc(sizeof(COLOR_MAP));

		/* Fill in the color maps */
		if (_alias_color_map46 != NULL)
			create_trans_table(_alias_color_map46, pal, 46, 46, 46, NULL);

		if (_alias_color_map141 != NULL)
			create_trans_table(_alias_color_map141, pal, 141, 141, 141, NULL);
	}
}

/*----------------------------------------------------------------------------*/
/*
   General antialiased textout routines

   Setup the color maps for 256 color mode
 */

/* Cleanup functions */
static void _antialias_cleanup(void)
{
	/* Cleanup the scratchpad */
	if (_scratchpad != NULL)
		destroy_bitmap(_scratchpad);
	_scratchpad = NULL;

	/* Cleanup the Palette */
	antialias_palette(NULL);
}

/* General init/exit functions */
void antialias_init(PALETTE pal)
{
	static int _exit_registered = 0;

	antialias_palette(pal);

	// Register the cleanup function, but only once
	if (_exit_registered == 0)
		atexit(_antialias_cleanup);
	_exit_registered = 1;
}

void antialias_exit(void)
{
	_antialias_cleanup();
}
