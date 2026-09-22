//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// Minimum example of Allegttf use
//
// Written by Doug Eleveld
//
//----------------------------------------------------------------------------
#include <stdlib.h>
#include <stdio.h>
#include "allegro.h"
#include "allegttf.h"

//----------------------------------------------------------------------------
int main(void)
{
	FONT *thefont;

	// Setup Allegro and some internal stuff
	allegro_init();
	install_keyboard();

	printf("Absolute minimum program for antialiased text output.\n");
	printf("Press any key to exit...\n");

	// Try and set the graphic mode
	set_color_depth(8);
	if (set_gfx_mode(GFX_AUTODETECT, 320, 200, 0, 0) != 0)
		//   if(set_gfx_mode(GFX_AUTODETECT,640,480,0,0)!=0)
	{
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

	set_palette(desktop_palette);

	// Draw background
	clear_to_color(screen, makecol(0, 0, 0));
	text_mode(makecol(16, 16, 16));
	//    text_mode(-1);

	//   set_clip(screen,15,15,53,25);
	aatextout(screen, thefont, "Antialiased text... Allegttf", 10, 10, makecol(255, 255, 255));

	//   set_clip(screen,0,0,319,199);
	//   rect(screen,13,13,55,27,makecol(0,255,0));

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
