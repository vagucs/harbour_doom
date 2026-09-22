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

#include <stdio.h>

/*----------------------------------------------------------------------------
   Very fast 6 level antialiased text blitting for 8 bit modes
   and filled backgrounds.  I don't think it's possible to get
   it much faster than this...
*/
void _antialiased_8bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y)
{
	int i;

	/* Setup the internal scratchpad and aliasmap to the correct color depth */
	_prepare_aliasmap(fg, bg, 8);

	/* Build each character */
	for (i = 0; i < b->h; i++) {
		unsigned char *input = b->line[i];
		unsigned char *output = _scratchpad->line[i];
		const unsigned char *inputend = &b->line[i][b->w];

		/* Super fast blit of a row to temp bitmap */
		while (input != inputend)
			*output++ = _aliasmap[*input++ >> 5];
	}
	/* Blit the character to the destination */
	blit(_scratchpad, bmp, 0, 0, x, y, b->w, b->h);
}

/*----------------------------------------------------------------------------
   Pretty fast 6 level antialiased text blitting for empty backgrounds.
   It works 8 bit color depth.
*/
void _antialiased_8bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y)
{
	int xx, i, yy;
	unsigned char *input;

#ifdef __GNUC__
	/* Using address of labels for jump table for 256 color mode for use when drawing a filled background */
	static void *jumptable_256[] = {
		&&done,
		&&label_256_1,
		&&label_256_2,
		&&label_256_3,
		&&label_256_4,
		&&label_256_5,
		&&label_256_6,
		&&label_256_6
	};
#endif

	/* Figure out the clipping */
	int h = b->h;
	int w = b->w;
	int startline = _antialiased_clip(bmp->ct, bmp->cb, y, &h);
	int startpixel = _antialiased_clip(bmp->cl, bmp->cr, x, &w);

	/* Ignore if we have no good width or height */
	if ((startline >= h) || (startpixel >= w))
		return;

	/* Make sure the palette is properly setup before we use it */
	if (_alias_color_map46 == NULL) {
		PALETTE pal;

		get_palette(pal);
		antialias_palette(pal);
	}

	/* Set the selector for the far poke in the inner loop */
	_farsetsel(bmp->seg);

	/* Plot the aliased pixels */
	for (i = startline; i < h; i++) {
		input = b->line[i] + startpixel;

		yy = y + i;

		/* Calculate where the RHS is */
		for (xx = x + startpixel; xx < x + w; xx++) {

			/* Gnu compilers can use a fast jump table */
#ifdef __GNUC__
			/* Use of the jump table */
			goto *jumptable_256[(*input++) >> 5];

			/* Plot once with a light color */
		  label_256_1:
			{
				/* Get the background color */
				/* Transform it with the color table */
				int peek = _alias_color_map46->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

				/* Plot the resulting color */
				_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);

				goto done;
			}

			/* Plot twice with a light color */
		  label_256_2:
			{
				/* Get the background color */
				/* Transform it with the color table */
				int peek = _alias_color_map46->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

				peek = _alias_color_map46->data[fg][peek];

				/* Plot the resulting color */
				_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);

				goto done;
			}

			/* Plot once with a dark color */
		  label_256_3:
			{
				/* Get the background color */
				/* Transform it with the color table */
				int peek = _alias_color_map141->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

				/* Plot the resulting color */
				_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);

				goto done;
			}

			/* Plot once with a dark color and then once with a light color */
		  label_256_4:
			{
				/* Get the background color */
				/* Transform it with the color table */
				int peek = _alias_color_map141->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

				peek = _alias_color_map46->data[fg][peek];

				/* Plot the resulting color */
				_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);

				goto done;
			}

			/* Plot twice with a dark color */
		  label_256_5:
			{
				/* Get the background color */
				/* Transform it with the color table */
				int peek = _alias_color_map141->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

				peek = _alias_color_map141->data[fg][peek];

				/* Plot the resulting color */
				_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);

				goto done;
			}

			/* Plot the full foreground color */
		  label_256_6:
			_farnspokeb(bmp_write_line(bmp, yy) + xx, fg);

		  done:
			/* GCC doesnt like labels at the en of a block, so some dummy code here */
			x = x;

			/* Use switch instead of a jump table for non-gnu compilers */
#else
			switch ((*input++) >> 5) {
				/* Plot once with a light color */
			case 1:
				{
					/* Get the background color */
					/* Transform it with the color table */
					int peek = _alias_color_map46->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

					/* Plot the resulting color */
					_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);
					break;
				}

				/* Plot twice with a light color */
			case 2:
				{
					/* Get the background color */
					/* Transform it with the color table */
					int peek = _alias_color_map46->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

					peek = _alias_color_map46->data[fg][peek];

					/* Plot the resulting color */
					_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);
					break;
				}

				/* Plot once with a dark color */
			case 3:
				{
					/* Get the background color */
					/* Transform it with the color table */
					int peek = _alias_color_map141->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

					/* Plot the resulting color */
					_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);
					break;
				}

				/* Plot once with a dark color and then once with a light color */
			case 4:
				{
					/* Get the background color */
					/* Transform it with the color table */
					int peek = _alias_color_map141->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

					peek = _alias_color_map46->data[fg][peek];

					/* Plot the resulting color */
					_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);
					break;
				}

				/* Plot twice with a dark color */
			case 5:
				{
					/* Get the background color */
					/* Transform it with the color table */
					int peek = _alias_color_map141->data[fg][_farnspeekb(bmp_read_line(bmp, yy) + xx)];

					peek = _alias_color_map141->data[fg][peek];

					/* Plot the resulting color */
					_farnspokeb(bmp_write_line(bmp, yy) + xx, peek);
					break;
				}

				/* Plot the full foreground color */
			case 6:
			case 7:
				_farnspokeb(bmp_write_line(bmp, yy) + xx, fg);
				break;
			}
#endif
		}
	}
}
