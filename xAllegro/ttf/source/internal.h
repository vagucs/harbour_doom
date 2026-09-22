//----------------------------------------------------------------------------
//
// ALLEGTTF - True type font loader for Allegro
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl)
//
//----------------------------------------------------------------------------
#ifndef ALLEGTTF_INTERNAL_HEADER
#define ALLEGTTF_INTERNAL_HEADER

//----------------------------------------------------------------------------
#include <allegro.h>
#include "freetype/freetype.h"

//----------------------------------------------------------------------------
// Basic font scaling variables
//----------------------------------------------------------------------------
#define HEIGHT_RATIO 7/6
#define OFFSET_RATIO 1/3

//----------------------------------------------------------------------------
// Antialiased font rendering hook
//----------------------------------------------------------------------------
int _antialiased_render(AL_CONST FONT * f, int ch, int fg, int bg, struct BITMAP *bmp, int x, int y);

//----------------------------------------------------------------------------
// Internal functions
//----------------------------------------------------------------------------
/* Used for scratchpad for blitting the characters */
#define _SCRATCHPAD_HEIGHT 128
#define _SCRATCHPAD_WIDTH  128
extern struct BITMAP *_scratchpad;

/* Used for fast aliasing for filled background modes */
extern int _aliasmap[8];

/* Used for fast changing of the transparency map in 256 color aliasing */
/* color_map46 is used as a flag to see if the color maps have been initialized */
extern COLOR_MAP *_alias_color_map46;
extern COLOR_MAP *_alias_color_map141;

void _setup_aliasmap(int fg, int bg, int depth);
void _prepare_aliasmap(int fg, int bg, int depth);

void _antialiased_8bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y);
void _antialiased_8bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y);

#ifdef ALLEGRO_COLOR16
void _antialiased_15_or_16bit_filled_render(struct BITMAP *b, struct BITMAP *bmp, int x, int y);
void _antialiased_15bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y);
void _antialiased_15bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y);

void _antialiased_16bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y);
void _antialiased_16bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y);
#endif

#ifdef ALLEGRO_COLOR24
void _antialiased_24bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y);
void _antialiased_24bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y);
#endif

#ifdef ALLEGRO_COLOR32
void _antialiased_32bit_filled_render(struct BITMAP *b, int fg, int bg, struct BITMAP *bmp, int x, int y);
void _antialiased_32bit_empty_render(struct BITMAP *b, int fg, struct BITMAP *bmp, int x, int y);
#endif

int _antialiased_clip(int ct, int cb, int y, int *h);

// Unfinished functions
//void _antialiased_8bit_blit (struct BITMAP *dest, int x, int y, int w, int h);
//void _antialiased_15bit_blit (struct BITMAP *dest, int x, int y, int w, int h);
//void _antialiased_16bit_blit (struct BITMAP *dest, int x, int y, int w, int h);
//void _antialiased_24bit_blit (struct BITMAP *dest, int x, int y, int w, int h);
//void _antialiased_32bit_blit (struct BITMAP *dest, int x, int y, int w, int h);

//----------------------------------------------------------------------------
// Basic font loading functions
//----------------------------------------------------------------------------

/* The structure holding all the freetype variables */
typedef struct _allegttf {

	/* Freetype variables */
	TT_Engine engine;
	TT_Face face;
	TT_Face_Properties properties;
	TT_Instance instance;
	TT_Glyph glyph;
	TT_Instance_Metrics imetrics;
	TT_CharMap char_map;
	TT_Outline outline;
	TT_Glyph_Metrics metrics;
	TT_Raster_Map Bit;
	unsigned char gray_palette[5];

	/* Helper variables */
	int points_w;
	int points_h;
	int gray_render;
} _allegttf;

/* Rendering quality variables.
   Set for highest quality since speed isn't an issue here */
#define PRECISION 1
#define SECOND_PASS 1
#define DROPOUT_MODE 2

/* Allocate a raster map */
TT_Error _Init_TT_Raster_Map(TT_Raster_Map * Bit, const int w, const int h, const int gray_render);

/* Blit a rastermap to an Allegro bitmap */
void _TT_Raster_Map_To_BITMAP(TT_Raster_Map * Bit, struct BITMAP *allegbit, const int gray_render);

/* Find the glyph index value from the unicode code using the TTF char mapping
   tables.  This is valid for all characters */
int _UnicodeToGlyphIndex(int source, TT_Face * face, TT_CharMap * charmap);

/* Load a ttf char */
struct BITMAP *_ttf_char(_allegttf * allegttf, const int unicode, const int gray_render);

/* Cleanup a allegttf structure */
void cleanup_allegttf(_allegttf * allegttf, const int face);

//----------------------------------------------------------------------------
#endif
