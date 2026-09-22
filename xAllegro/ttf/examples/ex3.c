//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// Simple loading of a TTF file in smoothed and not smoothed
//
// Written by Doug Eleveld
//
//----------------------------------------------------------------------------
#include <stdlib.h>
#include <stdio.h>
#include "allegro.h"
#include "allegttf.h"

//----------------------------------------------------------------------------
// General RGB map speeds up almost all 256 color stuff
RGB_MAP rgb_table;

//----------------------------------------------------------------------------
int main(void)
{
	FONT *thefont;
	FONT *ttsmoothedfont;
	FONT *realsmoothedfont;
	PALETTE pal;
	RGB black;

	black.r = 0;
	black.g = 0;
	black.b = 0;

	// Setup Allegro and some internal stuff
	allegro_init();
	install_keyboard();

	printf("Loading a ttf file in normal and smoothed\n");
	printf("Press any key to exit...\n");

	// Load the small font data in
	printf("Loading dejavusans.ttf [10 point]\n");
	thefont = load_ttf_font("dejavusans.ttf", 10, ALLEGTTF_NOSMOOTH);
	if (thefont == NULL) {
		printf("Could not load ttf dejavusans.ttf [10 point]\n");
		return 1;
	}
	// Load the smoothed font data in
	printf("Loading dejavusans.ttf [10 point, ttf smoothed]\n");
	ttsmoothedfont = load_ttf_font("dejavusans.ttf", 10, ALLEGTTF_TTFSMOOTH);
	if (ttsmoothedfont == NULL) {
		printf("Could not load ttf dejavusans.ttf [10 point, ttf smoothed]\n");
		return 1;
	}
	// Load the real smoothed font data in
	printf("Loading dejavusans.ttf [10 point, real smoothed]\n");
	realsmoothedfont = load_ttf_font("dejavusans.ttf", 10, ALLEGTTF_REALSMOOTH);
	if (realsmoothedfont == NULL) {
		printf("Could not load ttf dejavusans.ttf [10 point, real smoothed]\n");
		return 1;
	}
	// Try and set the graphic mode
	set_color_depth(8);
	if (set_gfx_mode(GFX_AUTODETECT, 320, 200, 0, 0) != 0) {
		// Warn that the mode did not work
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		printf("Could not set graphics mode.\n");
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
	//   antialias_init(pal);
	antialias_init(NULL);

	// Draw background
	clear_to_color(screen, makecol(0, 0, 0));
	text_mode(0);

	textout(screen, thefont, "This is 10 point arial...", 10, 10, makecol(255, 255, 255));
	aatextout(screen, ttsmoothedfont, "This is true type smoothed 10 point...", 10, 40, makecol(255, 255, 255));
	aatextout(screen, realsmoothedfont, "This is real smoothed 10 pointl...", 10, 70, makecol(255, 255, 255));

	while (!keypressed());

	// Close up shop and exit
	destroy_font(thefont);
	destroy_font(ttsmoothedfont);
	destroy_font(realsmoothedfont);

	antialias_exit();
	remove_keyboard();
	allegro_exit();

	return 0;
}

END_OF_MAIN();
//----------------------------------------------------------------------------
