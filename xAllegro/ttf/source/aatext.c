//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

#include <stdio.h>
#include <stdarg.h>
#include <allegro.h>
#include "allegttf.h"
#include "internal.h"

#include <allegro/internal/aintern.h>

//----------------------------------------------------------------------------
// Basic text drawing functions
//----------------------------------------------------------------------------

/* find_glyph:
 *  Searches a font for a specific character.
 */
static BITMAP *find_glyph(AL_CONST FONT * f, int ch)
{
	FONT_COLOR_DATA *fcd = (FONT_COLOR_DATA *) (f->data);

	while (fcd) {
		if (ch >= fcd->begin && ch < fcd->end)
			return fcd->bitmaps[ch - fcd->begin];
		fcd = fcd->next;
	}

	if (ch != ' ')
		return find_glyph(f, ' ');

	return NULL;
}

/*----------------------------------------------------------------------------
   Actual textout routine
*/
void aatextout(BITMAP * bmp, AL_CONST FONT * font, AL_CONST char *string, int x, int y, int colour)
{
	int ch;

	/* Make sure that we haven't been called with a fixed width font by accident */
	/* Also make sure that the bitmap isn't so big as to overflow the internal scratchpad */
	if ((font->vtable == font_vtable_mono) || (text_height(font) > _SCRATCHPAD_HEIGHT)) {
		textout(bmp, font, string, x, y, colour);
		return;
	}

	acquire_bitmap(bmp);

	/* Blit each character */
	while ((ch = *string) != 0) {

		/* Render the character */
		x += _antialiased_render(font, ch, colour, _textmode, bmp, x, y);

		if (x >= bmp->cr) {
			release_bitmap(bmp);
			return;
		}

		++string;
	}

	release_bitmap(bmp);
}

/*----------------------------------------------------------------------------
   Centered textout routine
*/
void aatextout_center(BITMAP * bmp, AL_CONST FONT * font, AL_CONST char *string, int x, int y, int colour)
{
	aatextout(bmp, font, string, x - (text_length(font, string) / 2), y, colour);
}

/*----------------------------------------------------------------------------
   Right aligned textout routine
*/
void aatextout_right(BITMAP * bmp, AL_CONST FONT * font, AL_CONST char *string, int x, int y, int colour)
{
	aatextout(bmp, font, string, x - (text_length(font, string)), y, colour);
}

/*----------------------------------------------------------------------------
   Internal character rendering function
*/
int _antialiased_render(AL_CONST FONT * f, int ch, int fg, int bg, struct BITMAP *bmp, int x, int y)
{
	BITMAP *b = find_glyph(f, ch);

	if (!b)
		return 0;

	if (fg < 0) {
		bmp->vtable->draw_256_sprite(bmp, b, x, y);
	} else {
		switch (bitmap_color_depth(bmp)) {
#ifdef ALLEGRO_COLOR8
		case (8):
			if (bg >= 0)
				_antialiased_8bit_filled_render(b, fg, bg, bmp, x, y);
			else
				_antialiased_8bit_empty_render(b, fg, bmp, x, y);
			break;
#endif							// ALLEGRO_COLOR8

#ifdef ALLEGRO_COLOR16
		case (15):
			if (bg >= 0)
				_antialiased_15bit_filled_render(b, fg, bg, bmp, x, y);
			else
				_antialiased_15bit_empty_render(b, fg, bmp, x, y);
			break;

		case (16):
			if (bg >= 0)
				_antialiased_16bit_filled_render(b, fg, bg, bmp, x, y);
			else
				_antialiased_16bit_empty_render(b, fg, bmp, x, y);
			break;
#endif							// ALLEGRO_COLOR16

#ifdef ALLEGRO_COLOR24
		case (24):
			if (bg >= 0)
				_antialiased_24bit_filled_render(b, fg, bg, bmp, x, y);
			else
				_antialiased_24bit_empty_render(b, fg, bmp, x, y);
			break;
#endif							// ALLEGRO_COLOR24

#ifdef ALLEGRO_COLOR32
		case (32):
			if (bg >= 0)
				_antialiased_32bit_filled_render(b, fg, bg, bmp, x, y);
			else
				_antialiased_32bit_empty_render(b, fg, bmp, x, y);
			break;
#endif							// ALLEGRO_COLOR24
		}
	}

	return b->w;
}

//----------------------------------------------------------------------------
// these printf-like routines come almost directly from Allegro
//----------------------------------------------------------------------------
/* aatextprintf:
 *  Formatted text output, using a printf() style format string.
 */
void aatextprintf(BITMAP * bmp, AL_CONST FONT * f, int x, int y, int color, AL_CONST char *format, ...)
{
	char buf[256];

	va_list ap;

	va_start(ap, format);
	vsprintf(buf, format, ap);
	va_end(ap);

	aatextout(bmp, f, buf, x, y, color);
}

/* aatextprintf_center:
 *  Like aatextprintf(), but uses the x coordinate as the centre rather than
 *  the left of the string.
 */
void aatextprintf_center(BITMAP * bmp, AL_CONST FONT * f, int x, int y, int color, AL_CONST char *format, ...)
{
	char buf[256];

	va_list ap;

	va_start(ap, format);
	vsprintf(buf, format, ap);
	va_end(ap);

	aatextout_center(bmp, f, buf, x, y, color);
}

/* aatextprintf_right:
 *  Like aatextprintf(), but uses the x coordinate as the rightmost
 *  coordinate, rather than the left of the string.
 */
void aatextprintf_right(BITMAP * bmp, AL_CONST FONT * f, int x, int y, int color, AL_CONST char *format, ...)
{
	char buf[256];

	va_list ap;

	va_start(ap, format);
	vsprintf(buf, format, ap);
	va_end(ap);

	aatextout_right(bmp, f, buf, x, y, color);
}
