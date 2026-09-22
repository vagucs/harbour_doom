//----------------------------------------------------------------------------
//
// ALLEGTTF - True type font loader for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// User TTF loading functions
//
//----------------------------------------------------------------------------
#include <allegro.h>
#include <allegro/internal/aintern.h>
#include "allegttf.h"
#include "internal.h"
#include <string.h>

//----------------------------------------------------------------------------
/* Smooth-scale a bitmap by some scaling factor */
struct BITMAP *_smooth_font_scale(struct BITMAP *bit)
{
	int i, j;

	int sum;

	int xoffset;
	int yoffset;

	unsigned char *ptr;

	struct BITMAP *ret;

	/* Find the size of the final bitmap */
	int w = bit->w / 4;
	int h = bit->h / 4;

	/* Try to create a smaller bitmap */
	ret = create_bitmap_ex(8, w + 1, h);
	if (ret == NULL)
		return bit;
	clear_to_color(ret, 0);

	/* Loops around the destination character */
	for (i = 0; i < w; i++) {
		for (j = 0; j < h; j++) {
			sum = 0;

			xoffset = i * 4;
			yoffset = j * 4;

			/* (should be) fast unrolled downsampling inner loop */
			ptr = bit->line[yoffset++] + xoffset;

			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr;

			ptr = bit->line[yoffset++] + xoffset;

			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr;

			ptr = bit->line[yoffset++] + xoffset;

			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr;

			ptr = bit->line[yoffset] + xoffset;

			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr++;
			sum += *ptr;

			/* Put the average pixel value into the smoothed font */
			ret->line[j][i] = sum / 16;
		}
	}
	return ret;
}

//----------------------------------------------------------------------------
/* Load a ttf font from a file */
FONT *load_ttf_font_ex2(AL_CONST char *filename, AL_CONST int pw, AL_CONST int ph, AL_CONST int begin, AL_CONST int end,
						AL_CONST int smooth)
{
	int c;
	int glyphindex;
	TT_Error error;

	AL_CONST int num = end - begin + 1;

	struct FONT *f;
	struct FONT_COLOR_DATA *fcd;
	struct FONT_VTABLE *fvt;

	struct BITMAP *thechar;
	struct BITMAP *smoothchar;

	/* Allocate the main engine */
	_allegttf allegttf;

	/* Do some basic setup */
	allegttf.Bit.bitmap = NULL;
	allegttf.points_w = pw;
	allegttf.points_h = ph;
	allegttf.gray_render = 0;

	/* expand the size if we are doing real smoothing */
	if (smooth == ALLEGTTF_REALSMOOTH) {
		allegttf.points_w = pw * 4;
		allegttf.points_h = ph * 4;
	}
	/* Figure out if we are going to ask freetype to smooth for us */
	if (smooth == ALLEGTTF_TTFSMOOTH)
		allegttf.gray_render = 1;

	/* The palette for TTF font smoothing */
	allegttf.gray_palette[0] = 0;
	allegttf.gray_palette[1] = 64;
	allegttf.gray_palette[2] = 128;
	allegttf.gray_palette[3] = 192;
	allegttf.gray_palette[4] = 254;

	/* Initialize engine */
	error = TT_Init_FreeType(&allegttf.engine);
	if (error)
		return NULL;

	/* Load face */
	error = TT_Open_Face(allegttf.engine, filename, &allegttf.face);
	if (error) {
		cleanup_allegttf(&allegttf, 0);
		return NULL;
	}

	/* get face properties */
	TT_Get_Face_Properties(allegttf.face, &allegttf.properties);

	/* Create glyph */
	error = TT_New_Glyph(allegttf.face, &allegttf.glyph);
	if (error) {
		cleanup_allegttf(&allegttf, 1);
		return NULL;
	}

	/* Create instance */
	error = TT_New_Instance(allegttf.face, &allegttf.instance);
	if (error) {
		cleanup_allegttf(&allegttf, 1);
		return NULL;
	}

	/* Set point sizes */
	error = TT_Set_Instance_CharSizes(allegttf.instance, allegttf.points_w * 64, allegttf.points_h * 64);
	if (error) {
		cleanup_allegttf(&allegttf, 1);
		return NULL;
	}

	TT_Get_Instance_Metrics(allegttf.instance, &allegttf.imetrics);

	/* Allocate the internal raster map */
	error =
		_Init_TT_Raster_Map(&allegttf.Bit, allegttf.imetrics.x_ppem * 2, allegttf.imetrics.y_ppem * HEIGHT_RATIO,
							allegttf.gray_render);
	if (error) {
		cleanup_allegttf(&allegttf, 1);
		return NULL;
	}

	/* Setup the gradient palette */
	TT_Set_Raster_Gray_Palette(allegttf.engine, allegttf.gray_palette);

	/* Allocate and setup the Allegro font */
	f = (struct FONT *) calloc(1, sizeof(struct FONT));
	fcd = (struct FONT_COLOR_DATA *) calloc(1, sizeof(struct FONT_COLOR_DATA));
	fcd->begin = begin;
	fcd->end = end;
	fcd->bitmaps = (BITMAP **) calloc(num, sizeof(BITMAP *));
	fcd->next = NULL;
	f->data = (void *) fcd;
	fvt = (struct FONT_VTABLE *) malloc(sizeof(struct FONT_VTABLE));
	memcpy(fvt, font_vtable_color, sizeof(struct FONT_VTABLE));
	f->vtable = fvt;

	/* Put in the font bitmaps */
	for (c = begin; c <= end; c++) {
		glyphindex = _UnicodeToGlyphIndex(c, &allegttf.face, &allegttf.char_map);

		/* Make the font character */
		thechar = _ttf_char(&allegttf, glyphindex, allegttf.gray_render);

		/* Possibly do our own smoothing */
		if ((smooth == ALLEGTTF_REALSMOOTH) && (thechar != NULL)) {
			/* Smooth be downscaling */
			smoothchar = _smooth_font_scale(thechar);

			/* Replace the char's bitmap */
			destroy_bitmap(thechar);
			thechar = smoothchar;
		}

		/* Put the character into the font */
		fcd->bitmaps[c - begin] = thechar;
	}

	/* Set the font height */
	f->height = fcd->bitmaps[0]->h;

	/* Cleanup and go home */
	cleanup_allegttf(&allegttf, 1);

	/* Put in the font rendering hook */
	if ((smooth != ALLEGTTF_NOSMOOTH) && (text_height(f) < _SCRATCHPAD_HEIGHT)
		&& (text_length(f, "W") < _SCRATCHPAD_HEIGHT))
		fvt->render_char = _antialiased_render;

	return f;
}

//----------------------------------------------------------------------------
/* Load a ttf font from a file */
FONT *load_ttf_font_ex(AL_CONST char *filename, AL_CONST int pw, AL_CONST int ph, AL_CONST int smooth)
{
	return load_ttf_font_ex2(filename, pw, ph, 32, 128, smooth);
}

//----------------------------------------------------------------------------
/* Load a ttf font from a file */
FONT *load_ttf_font(AL_CONST char *filename, AL_CONST int points, AL_CONST int smooth)
{
	return load_ttf_font_ex2(filename, points, points, 32, 128, smooth);
}

//----------------------------------------------------------------------------
