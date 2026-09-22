//----------------------------------------------------------------------------
//
// AATEXT - Antialiased text fonts for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Basic font loading functions
//----------------------------------------------------------------------------
#include <stdio.h>
#include <allegro.h>
#include <allegro/internal/aintern.h>
#include <string.h>
#include <ctype.h>
#include "internal.h"

//----------------------------------------------------------------------------
// The following functions are almost directly taken from Allegro's grabber program
//----------------------------------------------------------------------------
/* splits bitmaps into sub-sprites, using regions bounded by col #255 */
static void datedit_find_character(BITMAP * bmp, int *x, int *y, int *w, int *h)
{
	int c1;
	int c2;

	if (bitmap_color_depth(bmp) == 8) {
		c1 = 255;
		c2 = 255;
	} else {
		c1 = makecol_depth(bitmap_color_depth(bmp), 255, 255, 0);
		c2 = makecol_depth(bitmap_color_depth(bmp), 0, 255, 255);
	}

	/* look for top left corner of character */
	while ((getpixel(bmp, *x, *y) != c1) || (getpixel(bmp, *x + 1, *y) != c2) || (getpixel(bmp, *x, *y + 1) != c2)
		   || (getpixel(bmp, *x + 1, *y + 1) == c1) || (getpixel(bmp, *x + 1, *y + 1) == c2)) {
		(*x)++;
		if (*x >= bmp->w) {
			*x = 0;
			(*y)++;
			if (*y >= bmp->h) {
				*w = 0;
				*h = 0;
				return;
			}
		}
	}

	/* look for right edge of character */
	*w = 0;
	while ((getpixel(bmp, *x + *w + 1, *y) == c2) && (getpixel(bmp, *x + *w + 1, *y + 1) != c2)
		   && (*x + *w + 1 <= bmp->w))
		(*w)++;

	/* look for bottom edge of character */
	*h = 0;
	while ((getpixel(bmp, *x, *y + *h + 1) == c2) && (getpixel(bmp, *x + 1, *y + *h + 1) != c2)
		   && (*y + *h + 1 <= bmp->h))
		(*h)++;
}

/* magic number for GRX format font files */
#define FONTMAGIC    0x19590214L

/* import routine for the GRX font format */
static FONT *import_grx_font(AL_CONST char *filename)
{
	PACKFILE *f, *cf;
	FONT *fnt;
	FONT_MONO_DATA *fmd;
	char copyright[256];
	int *wtable;
	int width, height;
	int minchar, maxchar, numchar;
	int isfixed;
	int c, s;

	f = pack_fopen(filename, F_READ);
	if (!f)
		return NULL;

	if (pack_igetl(f) != FONTMAGIC) {
		pack_fclose(f);
		return NULL;
	}

	pack_igetl(f);

	width = pack_igetw(f);
	height = pack_igetw(f);
	minchar = pack_igetw(f);
	maxchar = pack_igetw(f);
	isfixed = pack_igetw(f);

	for (c = 0; c < 38; c++)
		pack_getc(f);

	numchar = maxchar - minchar + 1;

	if (!isfixed) {
		wtable = malloc(sizeof(int) * numchar);
		for (c = 0; c < numchar; c++)
			wtable[c] = pack_igetw(f);
	} else
		wtable = NULL;

	fnt = malloc(sizeof(FONT));
	fmd = malloc(sizeof(FONT_MONO_DATA));
	fmd->begin = minchar;
	fmd->end = maxchar;
	fmd->glyphs = malloc(numchar * sizeof(void *));
	fmd->next = NULL;
	fnt->data = (void *) fmd;
	fnt->height = height;
	fnt->vtable = font_vtable_mono;

	for (c = 0; c < numchar; c++) {
		FONT_GLYPH *g;

		if (wtable)
			width = wtable[c];

		s = ((width + 7) / 8) * height;

		g = malloc(sizeof(FONT_GLYPH) + s);

		g->w = width;
		g->h = height;

		pack_fread(g->dat, s, f);

		fmd->glyphs[c] = g;
	}

	if (!pack_feof(f)) {
		strcpy(copyright, filename);
		strcpy(get_extension(copyright), "txt");
		c = 'n';	// datedit_ask("Save font copyright message into '%s'", copyright);
		if ((c != 27) && (c != 'n') && (c != 'N')) {
			cf = pack_fopen(copyright, F_WRITE);
			if (cf) {
				while (!pack_feof(f)) {
					pack_fgets(copyright, sizeof(copyright) - 1, f);
					pack_fputs(copyright, cf);
					pack_fputs("\n", cf);
				}
				pack_fclose(cf);
			}
		}
	}

	pack_fclose(f);

	if (wtable)
		free(wtable);

	return fnt;
}

/* import routine for the 8x8 and 8x16 BIOS font formats */
static FONT *import_bios_font(AL_CONST char *filename)
{
	unsigned char data[256][16];
	PACKFILE *f;
	FONT *fnt;
	FONT_MONO_DATA *fmd;
	int c, y, h;

	f = pack_fopen(filename, F_READ);
	if (!f)
		return NULL;

	//   h = (f->todo == 2048) ? 8 : 16;
	h = 16;	// bad hack

	memset(data, 0, sizeof(data));

	for (c = 0; c < 256; c++) {
		for (y = 0; y < h; y++)
			data[c][y] = pack_getc(f);
	}

	pack_fclose(f);

	h = 0;

	for (c = 1; c < 256; c++) {
		for (y = 15; y >= 0; y--) {
			if (data[c][y])
				break;
		}

		y++;

		if (y > h)
			h = y;
	}

	fnt = malloc(sizeof(FONT));
	fmd = malloc(sizeof(FONT_MONO_DATA));
	fmd->begin = 1;
	fmd->end = 255;
	fmd->glyphs = malloc(255 * sizeof(void *));
	fmd->next = NULL;
	fnt->data = (void *) fmd;
	fnt->height = h;
	fnt->vtable = font_vtable_mono;

	for (c = 1; c < 256; c++) {
		FONT_GLYPH *g;

		g = malloc(sizeof(FONT_GLYPH) + h);
		g->w = 8;
		g->h = h;

		for (y = 0; y < h; y++)
			g->dat[y] = data[c][y];

		fmd->glyphs[c - 1] = g;
	}

	return fnt;
}

/* state information for the bitmap font importer */
static BITMAP *import_bmp = NULL;

static int import_x = 0;
static int import_y = 0;

/* import routine for the Allegro .pcx font format */
static FONT *import_bitmap_font(AL_CONST char *filename, int minchar, int maxchar, int cleanup)
{
	BITMAP **bmp;
	PALETTE junk;
	FONT *fnt;
	int x, y, w, h;
	int c, d;
	int max_h;
	int stride;
	int col;

	if (filename) {
		if (import_bmp)
			destroy_bitmap(import_bmp);

		import_bmp = load_bitmap(filename, junk);

		import_x = 0;
		import_y = 0;
	}

	if (!import_bmp)
		return NULL;

	if (bitmap_color_depth(import_bmp) != 8) {
		destroy_bitmap(import_bmp);
		import_bmp = NULL;
		return NULL;
	}

	bmp = malloc(65536 * sizeof(BITMAP *));
	max_h = 0;
	col = 0;
	c = 0;

	for (;;) {
		datedit_find_character(import_bmp, &import_x, &import_y, &w, &h);

		if ((w <= 0) || (h <= 0))
			break;

		bmp[c] = create_bitmap_ex(8, w, h);
		blit(import_bmp, bmp[c], import_x + 1, import_y + 1, 0, 0, w, h);
		max_h = MAX(max_h, h);
		import_x += w;

		if (col >= 0) {
			for (y = 0; y < h; y++) {
				for (x = 0; x < w; x++) {
					if (bmp[c]->line[y][x]) {
						if ((col) && (col != bmp[c]->line[y][x]))
							col = -1;
						else
							col = bmp[c]->line[y][x];
					}
				}
			}
		}

		c++;

		if ((maxchar > 0) && (minchar + c > maxchar))
			break;
	}

	if (c > 0) {
		if (col >= 0) {
			FONT_MONO_DATA *fmd;

			fnt = malloc(sizeof(FONT));
			fmd = malloc(sizeof(FONT_MONO_DATA));
			fmd->begin = minchar;
			fmd->end = minchar + c - 1;
			fmd->glyphs = malloc(c * sizeof(void *));
			fmd->next = NULL;
			fnt->data = (void *) fmd;
			fnt->height = max_h;
			fnt->vtable = font_vtable_mono;

			for (d = 0; d < c; d++) {
				FONT_GLYPH *g;

				w = bmp[d]->w;
				h = max_h;

				stride = (w + 7) / 8;

				g = malloc(sizeof(FONT_GLYPH) + stride * h);
				g->w = w;
				g->h = h;

				memset(g->dat, 0, stride * h);

				for (y = 0; y < h; y++) {
					for (x = 0; x < w; x++) {
						if (bmp[d]->line[y][x])
							g->dat[y * stride + x / 8] |= (0x80 >> (x & 7));
					}
				}

				fmd->glyphs[d] = g;
			}
		} else {
			FONT_COLOR_DATA *fcd;

			fnt = malloc(sizeof(FONT));
			fcd = malloc(sizeof(FONT_COLOR_DATA));
			fcd->begin = minchar;
			fcd->end = minchar + c - 1;
			fcd->bitmaps = malloc(c * sizeof(void *));
			fcd->next = NULL;
			fnt->data = (void *) fcd;
			fnt->height = max_h;
			fnt->vtable = font_vtable_color;

			for (d = 0; d < c; d++) {
				w = bmp[d]->w;
				h = max_h;

				fcd->bitmaps[d] = create_bitmap_ex(8, w, h);
				clear(fcd->bitmaps[d]);
				blit(bmp[d], fcd->bitmaps[d], 0, 0, 0, 0, w, h);
			}
		}
	} else
		fnt = NULL;

	for (d = 0; d < c; d++)
		destroy_bitmap(bmp[d]);

	free(bmp);

	if (cleanup) {
		destroy_bitmap(import_bmp);
		import_bmp = NULL;
	}

	return fnt;
}

/* import routine for the multiple range .txt font format */
static FONT *import_scripted_font(AL_CONST char *filename)
{
	char buf[256], *bmp_str, *start_str, *end_str;
	FONT *fnt = NULL;
	FONT *range;
	PACKFILE *f;
	int start, end;

	f = pack_fopen(filename, F_READ);
	if (!f)
		return NULL;

	while (pack_fgets(buf, sizeof(buf) - 1, f)) {
		bmp_str = strtok(buf, " \t");
		if (!bmp_str)
			goto badness;

		start_str = strtok(NULL, " \t");
		if (!start_str)
			goto badness;

		end_str = strtok(NULL, " \t");

		if (bmp_str[0] == '-')
			bmp_str = NULL;

		start = strtol(start_str, NULL, 0);

		if (end_str)
			end = strtol(end_str, NULL, 0);
		else
			end = -1;

		if ((start <= 0) || ((end > 0) && (end < start)))
			goto badness;

		range = import_bitmap_font(bmp_str, start, end, FALSE);

		if (!range) {
			//       if (bmp_str)
			//          datedit_error("Unable to read font images from %s", bmp_str);
			//       else
			//          datedit_error("Unable to read continuation font images");

			destroy_font(fnt);
			fnt = NULL;
			break;
		}

		if (fnt) {
			/* add to end of linked list */
			if (fnt->vtable == font_vtable_mono) {
				FONT_MONO_DATA *fmd = fnt->data;

				if (!fmd)
					fmd = range->data;
				else {
					while (fmd->next)
						fmd = fmd->next;

					fmd->next = range->data;
				}
			} else {
				FONT_COLOR_DATA *fcd = fnt->data;

				if (!fcd)
					fcd = range->data;
				else {
					while (fcd->next)
						fcd = fcd->next;

					fcd->next = range->data;
				}
			}
			free(range);
		} else
			fnt = range;
	}

	pack_fclose(f);

	destroy_bitmap(import_bmp);
	import_bmp = NULL;

	return fnt;

  badness:

	//   datedit_error("Bad font description (expecting 'file.pcx start end')");

	destroy_font(fnt);

	pack_fclose(f);
	destroy_bitmap(import_bmp);

	import_bmp = NULL;

	return NULL;
}

/* imports a font from an external file (handles various formats) */

FONT *load_font_2(const char *filename)
{
	PACKFILE *f;
	int id;
	FONT *ret;

	if (stricmp(get_extension(filename), "fnt") == 0) {
		f = pack_fopen(filename, F_READ);
		if (!f)
			ret = NULL;

		id = pack_igetl(f);
		pack_fclose(f);

		if (id == FONTMAGIC)
			ret = import_grx_font(filename);
		else
			ret = import_bios_font(filename);
	} else if (stricmp(get_extension(filename), "txt") == 0) {
		ret = import_scripted_font(filename);
	} else {
		ret = import_bitmap_font(filename, ' ', -1, TRUE);
	}

	return ret;
}
