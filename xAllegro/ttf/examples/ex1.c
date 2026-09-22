//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// Simple comparison between antialiased and non-antialiased text output
//
// Written by Doug Eleveld
//
//----------------------------------------------------------------------------
#include <stdlib.h>
#include <stdio.h>
#include "allegro.h"
#include "allegttf.h"

// General RGB map speeds up almost all 256 color stuff
RGB_MAP rgb_table;

//----------------------------------------------------------------------------
int main(void)
{
	FONT *thefont;
	PALETTE pal;
	RGB black;

	black.r = 0;
	black.g = 0;
	black.b = 0;

	// Setup Allegro and some internal stuff
	allegro_init();
	install_keyboard();

	printf("Simple example of antialiased text output.\n");
	printf("Press any key to exit...\n");

	// Try and set the graphic mode
	set_color_depth(8);
	if (set_gfx_mode(GFX_AUTODETECT, 320, 200, 0, 0) != 0) {
		// Warn that the mode did not work
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		printf("Could not set graphics mode.\n");
		return 1;
	}
	// Load the font data in
	set_color_conversion(COLORCONV_NONE);
	thefont = load_font_2("font.pcx");
	if (thefont == NULL) {
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		printf("Could not load font data from font.pcx\n");
		return 1;
	}
	// Create the color maps and RGB table for the antialiased fonts
	generate_332_palette(pal);
	set_palette(pal);

	// Make sure that we have black as colour zero
	set_color(0, &black);

	// Make the super speed RGB table for fast 8 bit mode color searches
	create_rgb_table(&rgb_table, pal, NULL);
	rgb_map = &rgb_table;

	// Initialise the antialiased palette
	antialias_init(pal);

	// Draw background
	clear_to_color(screen, makecol(0, 0, 0));
	text_mode(0);

	textout(screen, thefont, "This text IS NOT antialiased...", 10, 10, makecol(255, 255, 255));
	aatextout(screen, thefont, "This text IS antialiased...", 10, 40, makecol(255, 255, 255));

	aatextout(screen, thefont, "Press any key to exit.", 10, 100, makecol(255, 255, 255));

	while (!keypressed());

	// Close up shop and exit
	destroy_font(thefont);

	antialias_exit();
	remove_keyboard();
	allegro_exit();

	return 0;
}

END_OF_MAIN();
//----------------------------------------------------------------------------
