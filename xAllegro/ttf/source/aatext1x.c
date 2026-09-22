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
#include "internal.h"

/*----------------------------------------------------------------------------
   Internal function for 6 level filled background 15 and 16 bit textout
*/
void _antialiased_15_or_16bit_filled_render(struct BITMAP *b, struct BITMAP *bmp, int x, int y)
{
	int i;

	/* Build each character */
	for (i = 0; i < b->h; i++) {
		unsigned char *input = b->line[i];
		unsigned short *output = (unsigned short *) _scratchpad->line[i];
		const unsigned char *inputend = &b->line[i][b->w];

		/* Super fast blit of a row to temp bitmap */
		while (input != inputend)
			*output++ = _aliasmap[*input++ >> 5];
	}
	/* Blit the character to the destination */
	blit(_scratchpad, bmp, 0, 0, x, y, b->w, b->h);
}
