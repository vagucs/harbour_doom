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

#ifdef ALLEGRO_COLOR32

/* Used for fast blending for truecolor aliasing */
unsigned long _blender_trans24(unsigned long x, unsigned long y, unsigned long n);

/*----------------------------------------------------------------------------
   Very fast 6 level antialiased text blitting for true color modes
   and filled backgrounds.  I don't think it's possible to get
   it much faster than this...
*/
void _antialiased_32bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y)
{
	int i;

	/* Setup the internal scratchpad abd aliasmap to the correct color depth */
	_prepare_aliasmap(fg, bg, 32);

	/* Build each character */
	for (i = 0; i < b->h; i++) {
		unsigned char *input = b->line[i];
		unsigned int *output = (unsigned int *) _scratchpad->line[i];
		const unsigned char *inputend = &b->line[i][b->w];

		/* Super fast blit of a row to temp bitmap */
		while (input != inputend)
			*output++ = _aliasmap[*input++ >> 5];
	}
	/* Blit the character to the destination */
	blit(_scratchpad, bmp, 0, 0, x, y, b->w, b->h);
}

/*----------------------------------------------------------------------------
   Pretty fast antialiased text blitting for 32 bit modes and
   empty backgrounds. It fully supports 256 aliasing levels
*/
void _antialiased_32bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y)
{
	int xx, i, yy, xxend;
	unsigned char *input;

	/* Set the selector for the far poke in the inner loop */
	_farsetsel(bmp->seg);

	/* Plot the aliased pixels */
	for (i = 0; i < b->h; i++) {
		input = b->line[i];

		/* Find the line number and check if it's clipped */
		yy = y + i;

		/* Clipping under means we are done */
		if (yy >= bmp->cb)
			return;

		if (yy >= bmp->ct) {
			/* Adjust for any LHS clipping */
			int pix = 0;

			if (x < bmp->cl) {
				pix = bmp->cl - x;
				input += pix;
			}

			/* Calculate where the RHS is */
			xxend = x + b->w;

			/* Adjust the RHS for clipping */
			if (xxend >= bmp->cr)
				xxend = bmp->cr;

			for (xx = x + pix; xx < xxend; xx++) {
				/* Blend the color */
				unsigned int blendlevel = *input++;

				if (blendlevel) {
					/* Get the bacgground and blend it */
					unsigned int back = _farnspeekl(bmp_read_line(bmp, yy) + xx * 4);

					back = _blender_trans24(fg, back, blendlevel);

					/* Plot it to the screen */
					_farnspokel(bmp_write_line(bmp, yy) + xx * 4, back);
				}
			}
		}
	}
}

#endif							// ALLEGRO_COLOR32
