//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// Antialiased font profiling program for different video modes
//
// Written by Doug Eleveld
//
//----------------------------------------------------------------------------
#include <stdlib.h>
#include <stdio.h>
#include "allegro.h"
#include "allegttf.h"
#include "penttime.h"

// General RGB map speeds up almost all 256 color stuff
RGB_MAP rgb_table;

#define FONT_NAME    "dejavusans.ttf"
#define POINT_SIZE  20

static char message[256];

//----------------------------------------------------------------------------
// Profile the video mode by plotting random text on the screen and
// time each of the routines
//----------------------------------------------------------------------------
void do_profile(int mode, int x, int y, int depth, int textmode)
{
	int u;
	FILE *out = NULL;
	PALETTE pal;
	FONT *thefont;
	FONT *theaafont;
	int color;
	RGB black;

	c_pentium_profiler alleg_profile;
	c_pentium_profiler dougs_profile;

	black.r = 0;
	black.g = 0;
	black.g = 0;

	sprintf(message, "Mode: %ix%ix%i %s\n", x, y, depth, (textmode == -1) ? "empty" : "filled");

	// Try and set the requested mode
	set_color_depth(depth);
	if (set_gfx_mode(mode, x, y, 0, 0) != 0) {
		// Warn that the mode did not work
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		printf("Could not set graphics mode (%ix%ix%i)\n", x, y, depth);

		// Print the stuff to the profiling file
		out = fopen("profile.out", "a");
		fprintf(out, "Could not set %ix%i in %i bit mode\n\n", x, y, depth);
		fclose(out);

		return;
	}
	// Load the font data in
	thefont = load_ttf_font_ex(FONT_NAME, POINT_SIZE, POINT_SIZE, ALLEGTTF_NOSMOOTH);
	if (thefont == NULL) {
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		fprintf(stderr, "Could not load TTF font\n");
		exit(0);
	}
	theaafont = load_ttf_font_ex(FONT_NAME, POINT_SIZE, POINT_SIZE, ALLEGTTF_REALSMOOTH);
	if (theaafont == NULL) {
		set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
		fprintf(stderr, "Could not load TTF font\n");
		exit(0);
	}
	// Create the color maps and RGB table for the antialiased fonts
	if (depth == 8) {
		generate_332_palette(pal);
		set_palette(pal);
	}
	// Make sure that we have black as colour zero
	set_color(0, &black);

	create_rgb_table(&rgb_table, pal, NULL);
	rgb_map = &rgb_table;

	// Initialise the antialiased palette
	antialias_init(pal);

	// Draw background
	clear_to_color(screen, makecol(0, 0, 0));
	text_mode(textmode);

	// Setup the profilers
	PROFILER_RESET(alleg_profile);
	PROFILER_RESET(dougs_profile);

	// Randomly plot stuff to the screen
	color = makecol(255, 255, 255);

	for (u = 0; u < 1000; u++) {
		color = rand() % (1 << depth);

		// Do the normal Allegro stuff
		textout_centre(screen, thefont, message, rand() % x, rand() % y, color);
		PROFILER_START(alleg_profile);
		textout_centre(screen, thefont, message, rand() % x, rand() % y, color);
		PROFILER_STOP(alleg_profile);

		// Do the antialiased stuff
		aatextout_center(screen, theaafont, message, rand() % x, rand() % y, color);
		PROFILER_START(dougs_profile);
		aatextout_center(screen, theaafont, message, rand() % x, rand() % y, color);
		PROFILER_STOP(dougs_profile);
	}

	// Print the stuff to the profiling file
	out = fopen("profile.out", "a");
	fprintf(out, "Profiling results for %ix%i in %i bit mode with ", x, y, depth);
	if (textmode < 0)
		fprintf(out, "empty");
	else
		fprintf(out, "filled");
	fprintf(out, " background\n");

	fprintf(out, "Allegro's textout average number of clock cycles: %f\n", PROFILER_CYCLES(alleg_profile));
	fprintf(out, "aatextout  is %f times slower\n", PROFILER_CYCLES(dougs_profile) / PROFILER_CYCLES(alleg_profile));
	fclose(out);

	// Close up shop and exit
	antialias_exit();
	destroy_font(thefont);
	destroy_font(theaafont);
}

//----------------------------------------------------------------------------
// Profile the video mode by in some different video modes
//----------------------------------------------------------------------------
int main(void)
{
	FILE *out;

	// Setup Allegro and some internal stuff
	allegro_init();

	// Make sure we have a pentium
	check_cpu();
	if (cpu_family < 5) {
		fprintf(stderr, "Sorry, you need a pentium computer to run this program.\n");
		exit(0);
	}
	// Open the profiling file as a new file thus deleting the old one
	out = fopen("profile.out", "w");
	fprintf(out, "ALLEGTTF profiling program: %s\n\n", ALLEGTTF_VERSION_STR);
	fclose(out);

	// Profile the basic 8 bit mode filled background
	do_profile(GFX_AUTODETECT, 320, 200, 8, 0);

	// Profile the basic 8 bit mode empty background
	do_profile(GFX_AUTODETECT, 320, 200, 8, -1);

	// Profile the basic 8 bit mode filled background
	do_profile(GFX_AUTODETECT, 640, 480, 8, 0);

	// Profile the basic 8 bit mode empty background
	do_profile(GFX_AUTODETECT, 640, 480, 8, -1);

	// Profile the basic 15 bit mode filled background
	do_profile(GFX_AUTODETECT, 640, 480, 15, 0);

	// Profile the basic 15 bit mode empty background
	do_profile(GFX_AUTODETECT, 640, 480, 15, -1);

	// Profile the basic 16 bit mode filled background
	do_profile(GFX_AUTODETECT, 640, 480, 16, 0);

	// Profile the basic 16 bit mode empty background
	do_profile(GFX_AUTODETECT, 640, 480, 16, -1);

	// Profile the basic 24 bit mode filled background
	do_profile(GFX_AUTODETECT, 640, 480, 24, 0);

	// Profile the basic 24 bit mode empty background
	do_profile(GFX_AUTODETECT, 640, 480, 24, -1);

	// Profile the basic 32 bit mode filled background
	do_profile(GFX_AUTODETECT, 640, 480, 32, 0);

	// Profile the basic 32 bit mode empty background
	do_profile(GFX_AUTODETECT, 640, 480, 32, -1);

	set_gfx_mode(GFX_TEXT, 80, 25, 0, 0);
	allegro_exit();

	return 0;
}

END_OF_MAIN();
