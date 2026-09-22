//----------------------------------------------------------------------------
//
// ALLEGTTF - True type font loader for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//
// Internal TTF loading functions
//
//----------------------------------------------------------------------------
#include <string.h>

#include "internal.h"

//----------------------------------------------------------------------------
/* Allocate a raster map */
TT_Error _Init_TT_Raster_Map(TT_Raster_Map * Bit, const int w, const int h, const int gray_render)
{
	Bit->rows = h;
	Bit->width = w;

	if (gray_render) {
		Bit->cols = Bit->width;
		Bit->size = Bit->rows * Bit->width;
	} else {
		Bit->cols = (Bit->width + 7) / 8;	/* convert to # of bytes */
		Bit->size = Bit->rows * Bit->cols;	/* number of bytes in buffer */
	}

	Bit->flow = TT_Flow_Up;
	Bit->bitmap = (void *) malloc(Bit->size);
	if (Bit->bitmap == NULL)
		return 1;

	return 0;
}

//----------------------------------------------------------------------------
/* Blit a rastermap to an Allegro bitmap */
void _TT_Raster_Map_To_BITMAP(TT_Raster_Map * Bit, struct BITMAP *allegbit, const int gray_render)
{
	int x, y;
	char *scanline;

	int lastline = (Bit->rows - 1) * (Bit->cols);

	char *buffer = Bit->bitmap;

	if (gray_render) {
		for (y = 0; y < Bit->rows; y++) {
			scanline = &buffer[lastline - y * (Bit->cols)];

			for (x = 0; x < Bit->cols; x++)
				putpixel(allegbit, x, y, scanline[x]);
		}
	} else {
		for (y = 0; y < Bit->rows; y++) {
			int pixelcnt = 0;

			scanline = &buffer[lastline - y * (Bit->cols)];

			for (x = 0; x < Bit->cols; x++) {
				char data = scanline[x];

				if (data & 0x80)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x40)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x20)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x10)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x08)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x04)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x02)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				if (data & 0x01)
					putpixel(allegbit, pixelcnt++, y, 254);
				else
					putpixel(allegbit, pixelcnt++, y, 0);

				//            putpixel(allegbit,x,y,10);
			}
		}
	}
}

//----------------------------------------------------------------------------
/* Find the glyph index value from the unicode code using the TTF char mapping
   tables.  This is valid for all characters */
int _UnicodeToGlyphIndex(int source, TT_Face * face, TT_CharMap * charmap)
{
	/*
	   int    i, n;
	   short  platform, encoding;

	   First, look for a Unicode charmap
	   n = TT_Get_CharMap_Count(*face);

	   for(i=0;i<n;i++)
	   {
	   TT_Get_CharMap_ID(*face,i,&platform,&encoding);
	   if((platform == 3 && encoding == 1 )||
	   (platform == 0 && encoding == 0 ))
	   {
	   TT_Get_CharMap(*face,i,charmap);
	   i = n + 1;
	   }
	   }

	   Error conditions, return standard char
	   if(i==n)
	   return 0xFFFF;

	   return TT_Char_Index(*charmap,source);
	 */

	int i, n;
	unsigned short platform, encoding;

	/* First, look for a Unicode charmap */
	n = TT_Get_CharMap_Count(*face);

	for (i = 0; i < n; i++) {
		TT_Get_CharMap_ID(*face, i, &platform, &encoding);
		if ((platform == 3 && encoding == 1) || (platform == 0 && encoding == 0)) {
			TT_Get_CharMap(*face, i, charmap);
			i = n + 1;
		}
	}

	/* Error conditions, return standard char */
	if (i == n)
		return -1;

	return TT_Char_Index(*charmap, source);
}

//----------------------------------------------------------------------------
/* Load a ttf char */
struct BITMAP *_ttf_char(_allegttf * allegttf, const int glyphIndex, const int gray_render)
{
	int width;
	struct BITMAP *ret;
	TT_Error error;

	/* Make sure we have a valid value */

	if (glyphIndex == 0xFFFF)
		return NULL;

	/* Load the right glyph and outline and metrics */
	error = TT_Load_Glyph(allegttf->instance, allegttf->glyph, glyphIndex, TTLOAD_DEFAULT);
	if (error)
		return NULL;

	// Place the baseline of the character above the bottom of the bitmap
	TT_Get_Glyph_Metrics(allegttf->glyph, &allegttf->metrics);
	TT_Get_Glyph_Outline(allegttf->glyph, &allegttf->outline);
	TT_Translate_Outline(&allegttf->outline, -1 * allegttf->metrics.bearingX, (allegttf->points_h * 64) * OFFSET_RATIO);

	/* Set the rendering quality */
	allegttf->outline.second_pass = SECOND_PASS;
	allegttf->outline.high_precision = PRECISION;
	allegttf->outline.dropout_mode = DROPOUT_MODE;

	/* Clear the raster map */
	memset(allegttf->Bit.bitmap, 0, allegttf->Bit.size);

	/* Blit the character to the raster map */
	if (gray_render)
		TT_Get_Outline_Pixmap(allegttf->engine, &allegttf->outline, &allegttf->Bit);
	else
		TT_Get_Outline_Bitmap(allegttf->engine, &allegttf->outline, &allegttf->Bit);

	/* Make some minimum width */
	width = (allegttf->metrics.bbox.xMax - allegttf->metrics.bbox.xMin) / 64 + 1;
	if (width < 2)
		width = allegttf->imetrics.x_ppem / 2;

	/* Blit the bitmap to an Allegro BITMAP */
	ret = create_bitmap_ex(8, width, allegttf->imetrics.y_ppem * HEIGHT_RATIO);
	if (ret == NULL)
		return NULL;
	clear_to_color(ret, 0);

	/* Copy the rastermap to a temporary bitmap */
	_TT_Raster_Map_To_BITMAP(&allegttf->Bit, ret, gray_render);

	return ret;
}

//----------------------------------------------------------------------------
/* Cleanup a allegttf structure */
void cleanup_allegttf(_allegttf * allegttf, const int face)
{
	if (allegttf->Bit.bitmap != NULL)
		free(allegttf->Bit.bitmap);
	if (face)
		TT_Close_Face(allegttf->face);
	TT_Done_FreeType(allegttf->engine);
}

//----------------------------------------------------------------------------
