//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// Useing the low memory method to load a TTF file
// **** The low memory routines are hopelessly broken on linux, reverting to standard method ***
// 
// Written by Doug Eleveld
//
//----------------------------------------------------------------------------
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "allegro.h"
#include "allegttf.h"

//----------------------------------------------------------------------------
int main(void)
{
	FONT *thefont;
	PALETTE palette;

	// Setup Allegro and some internal stuff
	allegro_init();
	install_keyboard();

	printf("Loading a ttf file from temp PCX file\n");
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
	thefont = load_ttf_font_mem("dejavusans.ttf", 10, ALLEGTTF_REALSMOOTH);
	if (thefont == NULL) {
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		printf("Could not load font data from temp PCX file\n");
		return 2;
	}

	generate_332_palette(palette);
	set_palette(palette);

	// Draw background
	clear_to_color(screen, makecol(0, 0, 0));
	text_mode(makecol(16, 16, 16));

	//   set_clip(screen,15,15,53,25);
	aatextout(screen, thefont, "Low memory (slow loading)", 10, 10, makecol(255, 255, 255));
	aatextout(screen, thefont, "Antialiased text... Allegttf", 10, 30, makecol(255, 255, 255));

	//   set_clip(screen,0,0,319,199);
	//   rect(screen,13,13,55,27,makecol(0,255,0));

	while (!keypressed());
	clear_keybuf();

	// Close up shop and exit
	destroy_font(thefont);

	antialias_exit();
	remove_keyboard();
	allegro_exit();

	return 0;
}

END_OF_MAIN();
//----------------------------------------------------------------------------
