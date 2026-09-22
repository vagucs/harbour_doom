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

#ifdef ALLEGRO_COLOR16

/* Used for fast blending for truecolor aliasing */
unsigned long _blender_trans15(unsigned long x, unsigned long y, unsigned long n);

/*----------------------------------------------------------------------------
   Very fast 6 level antialiased text blitting for true color modes
   and filled backgrounds.  I don't think it's possible to get
   it much faster than this...
*/
void _antialiased_15bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y)
{
	/* Setup the internal scratchpad and aliasmap to the correct color depth */
	_prepare_aliasmap(fg, bg, 15);

	/* do the common 15 or 16 bit character drawing */
	_antialiased_15_or_16bit_filled_render(b, bmp, x, y);
}

/*----------------------------------------------------------------------------
   Pretty fast antialiased text blitting for 15 bit modes and
   empty backgrounds. It fully supports 256 aliasing levels
*/
void _antialiased_15bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y)
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

			xxend *= 2;

			for (xx = (x + pix) * 2; xx < xxend; xx += 2) {
				/* Blend the color */
				const unsigned int blendlevel = *input++;

				if (blendlevel) {
					/* Get the bacgground and blend it */
					unsigned int back = _farnspeekw(bmp_read_line(bmp, yy) + xx);

					back = _blender_trans15(fg, back, blendlevel);

					/* Plot it to the screen */
					_farnspokew(bmp_write_line(bmp, yy) + xx, back);
				}
			}
		}
	}
}

#endif							// ALLEGRO_COLOR16
