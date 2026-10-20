/*
DOOM generic portado para Harbour com interfaces minimas em C para acesso a allegro.

Por Wagner Nunes da Silva

vagucs@bol.com.br
vagucs@vagucs.com.br
vagucs@gmail.com

www.vagucs.com.br
*/
#include "xhb.ch"
#include "common.ch"
#include "hbclass.ch"

#translate ( <exp1> | <exp2> )      => ( hb_qbitOr( ( <exp1> ), ( <exp2> ) ) )
#translate ( <exp1> & <exp2> )      => ( hb_qbitAnd( ( <exp1> ), ( <exp2> ) ) )
#translate ( <exp1> ^^ <exp2> )     => ( hb_qbitXor( ( <exp1> ), ( <exp2> ) ) )

STATIC s_fullscreen := 0
STATIC s_scale := 2

#include "doomgeneric.ch"

STATIC PROCEDURE ParseVideoArgs()
    LOCAL p
    MEMVAR myargv

    s_fullscreen := iif( M_ParmExists( "-fullscreen" ), 1, 0 )

    p := M_CheckParmWithArgs( "-scaling", 1 )
    IF p > 0
        s_scale := Val( myargv[ p + 1 + 1 ] )
        IF s_scale < 1
            s_scale := 1
        ENDIF
        IF s_scale > 8
            s_scale := 8
        ENDIF
    ENDIF
RETURN

FUNCTION DG_Init()
    LOCAL nW
    LOCAL nH

    OutStd( "Initializing SDL3" + hb_eol() )

    I_AtExit( {|| SdlShutdown(), AlgExit() }, .T. )
    AlgInit()

    ParseVideoArgs()
    nW := 320 * s_scale
    nH := 200 * s_scale
    IF SdlOpen( nW, nH, s_fullscreen != 0 ) == 0
        I_Error( "SDL3: " + SdlLastError() + hb_eol() )
    ENDIF
    OutStd( "SDL3 video: " + hb_ntos( nW ) + "x" + hb_ntos( nH ) + ;
        iif( s_fullscreen != 0, " fullscreen", " windowed" ) + hb_eol() )
RETURN NIL

FUNCTION DG_Fullscreen()
RETURN SdlIsFullscreen()

FUNCTION DG_DrawFrame()
    MEMVAR I_VideoBuffer

    IF ValType( I_VideoBuffer ) == "C"
        SdlPresent( I_VideoBuffer )
    ENDIF
    IF SdlQuitRequested()
        I_Quit()
    ENDIF
RETURN NIL

FUNCTION DG_SleepMs( ms )
    SdlDelay( ms )
RETURN NIL

FUNCTION DG_GetTicksMs()
RETURN SdlTicks()

FUNCTION DG_GetKey( pressed, doomKey )
    LOCAL aKey

    aKey := SdlKeyPop()
    IF aKey == NIL
        IF SdlQuitRequested()
            I_Quit()
        ENDIF
        RETURN 0
    ENDIF
    pressed := aKey[ 1 ]
    doomKey := aKey[ 2 ]
RETURN 1

FUNCTION DG_SetWindowTitle( title )
    SdlSetTitle( title )
RETURN NIL

#pragma BEGINDUMP
#include "hbapi.h"
#include "hbapiitm.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define ALLEGRO_NO_KEY_DEFINES 1
#include <allegro.h>

#ifdef uint32_t
#undef uint32_t
#endif

#ifndef DOOMGENERIC_RESX
#define DOOMGENERIC_RESX 320
#endif
#ifndef DOOMGENERIC_RESY
#define DOOMGENERIC_RESY 200
#endif

typedef unsigned char pixel_t;

struct color
{
   unsigned char b;
   unsigned char g;
   unsigned char r;
   unsigned char a;
};

extern struct color colors[ 256 ];

void alleg_present_bitmap( BITMAP *src, int dx, int dy, int dw, int dh );

#ifdef ALLEGRO_WINDOWS
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0501
#endif
#define BITMAP WINDOWS_BITMAP
#include <windows.h>
#undef BITMAP
AL_FUNC( HWND, win_get_window, ( void ) );
AL_FUNC( void, win_set_window, ( HWND wnd ) );
static HWND s_fs_wnd = NULL;
static void AlgDestroyOverlay( void );
#endif

#ifndef DOOMGENERIC_RESX
#define DOOMGENERIC_RESX 320
#endif
#ifndef DOOMGENERIC_RESY
#define DOOMGENERIC_RESY 200
#endif

#define KEYQUEUE_SIZE 16

static int s_alg_exited = 0;
static BITMAP *temp_bitmap = NULL;
static volatile unsigned int s_KeyQueue[ KEYQUEUE_SIZE ];
static volatile unsigned int s_KeyQueueWriteIndex = 0;
static unsigned int s_KeyQueueReadIndex = 0;
static volatile unsigned int s_ticks = 0;

#ifndef DG_SCREENBUFFER_DEFINED
pixel_t *DG_ScreenBuffer = NULL;
#endif

void key_callback( int scancode )
{
   s_KeyQueue[ s_KeyQueueWriteIndex ] = ( unsigned int ) scancode;
   s_KeyQueueWriteIndex = ( s_KeyQueueWriteIndex + 1 ) % KEYQUEUE_SIZE;
}
END_OF_FUNCTION( key_callback );

void timer_callback( void )
{
   s_ticks++;
}
END_OF_FUNCTION( timer_callback );

/*
Filtro CRT (-crt): curvatura do tubo, scanlines, mascara RGB de fosforo,
vinheta e leve borrao horizontal. A geometria (pixel de origem e ganho de
cada pixel de saida) e pre-calculada em CrtBuild e so muda com o tamanho
de saida; por quadro sobra uma consulta e tres multiplicacoes por pixel.
*/
#define CRT_SRC_PIXELS ( DOOMGENERIC_RESX * DOOMGENERIC_RESY )
#define CRT_OUTSIDE    0xFFFFu

static int s_crt = 0;
static int s_crt_w = 0;
static int s_crt_h = 0;
static unsigned short *s_crt_map = NULL;
static unsigned char *s_crt_gain = NULL;
static unsigned int *s_crt_work = NULL;
static int s_crt_work_n = 0;
static BITMAP *s_crt_bmp = NULL;
static int s_crt_mask[ 3 ][ 3 ];
static unsigned int s_crt_rgb[ CRT_SRC_PIXELS ];
static unsigned char s_crt_src8[ CRT_SRC_PIXELS ];
static int s_crt_have_src = 0;

static void CrtFree( void )
{
   free( s_crt_map );
   free( s_crt_gain );
   free( s_crt_work );
   s_crt_map = NULL;
   s_crt_gain = NULL;
   s_crt_work = NULL;
   s_crt_work_n = 0;
   s_crt_w = 0;
   s_crt_h = 0;
   if( s_crt_bmp != NULL )
   {
      destroy_bitmap( s_crt_bmp );
      s_crt_bmp = NULL;
   }
}

static int CrtBuild( int dw, int dh )
{
   int x;
   int y;
   int m;
   int c;
   double sl_strength;
   double boost;
   double off;

   if( dw < 1 || dh < 1 )
      return 0;
   if( s_crt_map != NULL && s_crt_w == dw && s_crt_h == dh )
      return 1;

   free( s_crt_map );
   free( s_crt_gain );
   s_crt_map = ( unsigned short * ) malloc( ( size_t ) dw * dh * sizeof( unsigned short ) );
   s_crt_gain = ( unsigned char * ) malloc( ( size_t ) dw * dh );
   if( s_crt_map == NULL || s_crt_gain == NULL )
   {
      free( s_crt_map );
      free( s_crt_gain );
      s_crt_map = NULL;
      s_crt_gain = NULL;
      s_crt_w = 0;
      s_crt_h = 0;
      return 0;
   }
   s_crt_w = dw;
   s_crt_h = dh;

   /* abaixo de 2 linhas de saida por linha do Doom as scanlines geram moire */
   sl_strength = ( double ) dh / DOOMGENERIC_RESY - 1.0;
   if( sl_strength < 0.0 )
      sl_strength = 0.0;
   if( sl_strength > 1.0 )
      sl_strength = 1.0;
   sl_strength *= 0.45;

   for( y = 0; y < dh; y++ )
   {
      double ny = 2.0 * y / dh - 1.0;

      for( x = 0; x < dw; x++ )
      {
         double nx = 2.0 * ( x + 0.5 ) / dw - 1.0;
         double u = nx * ( 1.0 + ny * ny / 32.0 );
         double v = ny * ( 1.0 + nx * nx / 24.0 );
         size_t p = ( size_t ) y * dw + x;
         double sx;
         double sy;
         double d;
         double uu;
         double vv;
         double g;
         int ix;
         int iy;

         if( u <= -1.0 || u >= 1.0 || v <= -1.0 || v >= 1.0 )
         {
            s_crt_map[ p ] = CRT_OUTSIDE;
            s_crt_gain[ p ] = 0;
            continue;
         }

         sx = ( u + 1.0 ) * 0.5 * DOOMGENERIC_RESX;
         sy = ( v + 1.0 ) * 0.5 * DOOMGENERIC_RESY;
         ix = ( int ) sx;
         iy = ( int ) sy;
         if( ix > DOOMGENERIC_RESX - 1 )
            ix = DOOMGENERIC_RESX - 1;
         if( iy > DOOMGENERIC_RESY - 1 )
            iy = DOOMGENERIC_RESY - 1;

         d = ( sy - iy ) - 0.5;
         uu = ( u + 1.0 ) * 0.5;
         vv = ( v + 1.0 ) * 0.5;
         g = ( 1.0 - sl_strength * 4.0 * d * d )
           * pow( 16.0 * uu * vv * ( 1.0 - uu ) * ( 1.0 - vv ), 0.12 ) * 255.0;
         if( g < 0.0 )
            g = 0.0;
         if( g > 255.0 )
            g = 255.0;

         s_crt_map[ p ] = ( unsigned short ) ( iy * DOOMGENERIC_RESX + ix );
         s_crt_gain[ p ] = ( unsigned char ) ( g + 0.5 );
      }
   }

   /* mascara de fosforo so faz sentido com 2+ pixels de saida por pixel do Doom */
   if( dw >= 2 * DOOMGENERIC_RESX )
   {
      off = 0.70;
      boost = 1.40;
   }
   else
   {
      off = 1.0;
      boost = 1.15;
   }
   for( m = 0; m < 3; m++ )
      for( c = 0; c < 3; c++ )
         s_crt_mask[ m ][ c ] = ( int ) ( 256.0 * boost * ( m == c ? 1.0 : off ) );

   return 1;
}

static void CrtRender( const unsigned char *src, unsigned int *dst, int dw, int dh, int pitch )
{
   unsigned int lut[ 256 ];
   int x;
   int y;
   int i;

   for( i = 0; i < 256; i++ )
      lut[ i ] = ( ( unsigned int ) colors[ i ].r << 16 )
               | ( ( unsigned int ) colors[ i ].g << 8 )
               | ( unsigned int ) colors[ i ].b;

   for( y = 0; y < DOOMGENERIC_RESY; y++ )
   {
      const unsigned char *in = src + y * DOOMGENERIC_RESX;
      unsigned int *out = s_crt_rgb + y * DOOMGENERIC_RESX;

      for( x = 0; x < DOOMGENERIC_RESX; x++ )
      {
         unsigned int l = lut[ in[ x > 0 ? x - 1 : x ] ];
         unsigned int c = lut[ in[ x ] ];
         unsigned int r = lut[ in[ x < DOOMGENERIC_RESX - 1 ? x + 1 : x ] ];
         unsigned int cr = ( ( ( l >> 16 ) & 255 ) + 2 * ( ( c >> 16 ) & 255 ) + ( ( r >> 16 ) & 255 ) ) >> 2;
         unsigned int cg = ( ( ( l >> 8 ) & 255 ) + 2 * ( ( c >> 8 ) & 255 ) + ( ( r >> 8 ) & 255 ) ) >> 2;
         unsigned int cb = ( ( l & 255 ) + 2 * ( c & 255 ) + ( r & 255 ) ) >> 2;
         out[ x ] = ( cr << 16 ) | ( cg << 8 ) | cb;
      }
   }

   for( y = 0; y < dh; y++ )
   {
      const unsigned short *map = s_crt_map + ( size_t ) y * dw;
      const unsigned char *gain = s_crt_gain + ( size_t ) y * dw;
      unsigned int *out = dst + ( size_t ) y * pitch;
      int k = 0;

      for( x = 0; x < dw; x++ )
      {
         unsigned int idx = map[ x ];

         if( idx == CRT_OUTSIDE )
            out[ x ] = 0;
         else
         {
            unsigned int c = s_crt_rgb[ idx ];
            int g = gain[ x ];
            const int *mk = s_crt_mask[ k ];
            int r = ( ( int ) ( ( c >> 16 ) & 255 ) * g * mk[ 0 ] ) >> 16;
            int gr = ( ( int ) ( ( c >> 8 ) & 255 ) * g * mk[ 1 ] ) >> 16;
            int b = ( ( int ) ( c & 255 ) * g * mk[ 2 ] ) >> 16;

            if( r > 255 )
               r = 255;
            if( gr > 255 )
               gr = 255;
            if( b > 255 )
               b = 255;
            out[ x ] = ( ( unsigned int ) r << 16 ) | ( ( unsigned int ) gr << 8 ) | ( unsigned int ) b;
         }
         if( ++k == 3 )
            k = 0;
      }
   }
}

static void CrtPresentWindowed( int dx, int dy, int dw, int dh )
{
   int x;
   int y;
   int depth;
   int native32;

   if( ! s_crt_have_src || ! CrtBuild( dw, dh ) )
      return;

   if( s_crt_bmp == NULL || s_crt_bmp->w != dw || s_crt_bmp->h != dh )
   {
      if( s_crt_bmp != NULL )
         destroy_bitmap( s_crt_bmp );
      s_crt_bmp = create_bitmap( dw, dh );
      if( s_crt_bmp == NULL )
         return;
   }

   if( s_crt_work == NULL || s_crt_work_n != dw * dh )
   {
      free( s_crt_work );
      s_crt_work = ( unsigned int * ) malloc( ( size_t ) dw * dh * sizeof( unsigned int ) );
      s_crt_work_n = s_crt_work != NULL ? dw * dh : 0;
      if( s_crt_work == NULL )
         return;
   }

   CrtRender( s_crt_src8, s_crt_work, dw, dh, dw );

   depth = bitmap_color_depth( s_crt_bmp );
   native32 = depth == 32 && makecol32( 255, 0, 0 ) == 0xFF0000
              && makecol32( 0, 255, 0 ) == 0x00FF00 && makecol32( 0, 0, 255 ) == 0x0000FF;

   for( y = 0; y < dh; y++ )
   {
      const unsigned int *in = s_crt_work + ( size_t ) y * dw;

      if( native32 )
         memcpy( s_crt_bmp->line[ y ], in, ( size_t ) dw * sizeof( unsigned int ) );
      else if( depth == 32 )
      {
         unsigned int *out = ( unsigned int * ) s_crt_bmp->line[ y ];
         for( x = 0; x < dw; x++ )
            out[ x ] = ( unsigned int ) makecol32( ( in[ x ] >> 16 ) & 255, ( in[ x ] >> 8 ) & 255, in[ x ] & 255 );
      }
      else if( depth == 16 || depth == 15 )
      {
         unsigned short *out = ( unsigned short * ) s_crt_bmp->line[ y ];
         for( x = 0; x < dw; x++ )
            out[ x ] = ( unsigned short ) makecol_depth( depth, ( in[ x ] >> 16 ) & 255, ( in[ x ] >> 8 ) & 255, in[ x ] & 255 );
      }
      else
      {
         for( x = 0; x < dw; x++ )
            putpixel( s_crt_bmp, x, y, makecol_depth( depth, ( in[ x ] >> 16 ) & 255, ( in[ x ] >> 8 ) & 255, in[ x ] & 255 ) );
      }
   }

   alleg_present_bitmap( s_crt_bmp, dx, dy, dw, dh );
}

HB_FUNC( ALGSETCRT )
{
   s_crt = hb_parl( 1 ) ? 1 : 0;
}

HB_FUNC( ALGGETCRT )
{
   hb_retl( s_crt );
}

HB_FUNC( DG_ALLOCSCREEN )
{
   if( DG_ScreenBuffer == NULL )
      DG_ScreenBuffer = ( pixel_t * ) malloc( DOOMGENERIC_RESX * DOOMGENERIC_RESY * 4 );
   hb_retptr( DG_ScreenBuffer );
}

HB_FUNC( ALGINIT )
{
   hb_retni( allegro_init() );
}

HB_FUNC( ALGERRORTEXT )
{
   hb_retc( allegro_error );
}

HB_FUNC( ALGEXIT )
{
   if( s_alg_exited )
      return;
   s_alg_exited = 1;
#ifdef ALLEGRO_WINDOWS
   AlgDestroyOverlay();
#endif
   CrtFree();
   if( temp_bitmap != NULL )
   {
      destroy_bitmap( temp_bitmap );
      temp_bitmap = NULL;
   }
}

HB_FUNC( ALGINSTALLHOOKS )
{
   int result;

   LOCK_FUNCTION( key_callback );
   LOCK_VARIABLE( s_KeyQueue );
   LOCK_VARIABLE( s_KeyQueueWriteIndex );
   LOCK_VARIABLE( s_KeyQueueReadIndex );
   LOCK_FUNCTION( timer_callback );
   LOCK_VARIABLE( s_ticks );

   install_keyboard();
   keyboard_lowlevel_callback = key_callback;

   install_timer();
   result = install_int( timer_callback, 1 );
   hb_retni( result );
}

HB_FUNC( ALGREHOOKINPUT )
{
   install_keyboard();
   keyboard_lowlevel_callback = key_callback;
}

#ifdef ALLEGRO_WINDOWS
static WINDOWPLACEMENT s_wndpl;
static LONG s_wndstyle = 0;
static int s_wnd_saved = 0;

HB_FUNC( ALGSAVEWINDOW )
{
   HWND wnd;

   wnd = win_get_window();
   if( wnd == NULL )
   {
      hb_retni( 0 );
      return;
   }

   s_wndpl.length = sizeof( s_wndpl );
   GetWindowPlacement( wnd, &s_wndpl );
   s_wndstyle = GetWindowLong( wnd, GWL_STYLE );
   s_wnd_saved = 1;
   hb_retni( 1 );
}

static void AlgMonitorRect( HWND wnd, RECT *rc )
{
   HMONITOR mon;
   MONITORINFO mi;

   mon = MonitorFromWindow( wnd, MONITOR_DEFAULTTONEAREST );
   mi.cbSize = sizeof( mi );
   if( mon != NULL && GetMonitorInfo( mon, &mi ) )
      *rc = mi.rcMonitor;
   else
   {
      rc->left = 0;
      rc->top = 0;
      rc->right = GetSystemMetrics( SM_CXSCREEN );
      rc->bottom = GetSystemMetrics( SM_CYSCREEN );
   }
}
#endif

HB_FUNC( ALGSETBORDERLESS )
{
#ifdef ALLEGRO_WINDOWS
   HWND wnd;
   RECT rc;

   wnd = win_get_window();
   if( wnd == NULL )
   {
      hb_retni( 0 );
      return;
   }

   if( hb_parl( 1 ) )
   {
      if( ! s_wnd_saved )
      {
         s_wndpl.length = sizeof( s_wndpl );
         GetWindowPlacement( wnd, &s_wndpl );
         s_wndstyle = GetWindowLong( wnd, GWL_STYLE );
         s_wnd_saved = 1;
      }
      AlgMonitorRect( wnd, &rc );
      SetWindowLong( wnd, GWL_STYLE, WS_POPUP | WS_VISIBLE );
      SetWindowPos( wnd, HWND_TOP, rc.left, rc.top,
                    rc.right - rc.left, rc.bottom - rc.top,
                    SWP_FRAMECHANGED | SWP_SHOWWINDOW );
      SetForegroundWindow( wnd );
   }
   else if( s_wnd_saved )
   {
      SetWindowLong( wnd, GWL_STYLE, s_wndstyle | WS_VISIBLE );
      SetWindowPlacement( wnd, &s_wndpl );
      SetWindowPos( wnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                    SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED | SWP_SHOWWINDOW );
   }
   hb_retni( 1 );
#else
   hb_retni( 0 );
#endif
}

#ifdef ALLEGRO_WINDOWS
#define ALG_FS_CLASS "DoomMinialFS"
static HDC s_fs_wnddc = NULL;
static HDC s_fs_mem = NULL;
static HBITMAP s_fs_bmp = NULL;
static HGDIOBJ s_fs_old = NULL;
static unsigned int *s_fs_bits = NULL;
static int s_fs_bw = 0;
static int s_fs_bh = 0;
static int s_fs_dx = 0;
static int s_fs_dy = 0;
static int s_fs_bars = 0;
static unsigned int s_lut[ 256 ];

static void AlgRebuildLut( void )
{
   int i;

   for( i = 0; i < 256; i++ )
      s_lut[ i ] = ( unsigned int ) colors[ i ].b
                 | ( ( unsigned int ) colors[ i ].g << 8 )
                 | ( ( unsigned int ) colors[ i ].r << 16 );
}

static void AlgScaleNN( const unsigned char *src, unsigned int *dst,
                        int dw, int dh, int pitch )
{
   int x;
   int y;
   unsigned int xstep;
   unsigned int ystep;
   unsigned int yacc;

   if( src == NULL || dst == NULL || dw < 1 || dh < 1 )
      return;

   if( dw == DOOMGENERIC_RESX && dh == DOOMGENERIC_RESY )
   {
      for( y = 0; y < DOOMGENERIC_RESY; y++ )
      {
         const unsigned char *in = src + y * DOOMGENERIC_RESX;
         unsigned int *out = dst + y * pitch;
         for( x = 0; x < DOOMGENERIC_RESX; x++ )
            out[ x ] = s_lut[ in[ x ] ];
      }
      return;
   }

   xstep = ( ( unsigned int ) DOOMGENERIC_RESX << 16 ) / ( unsigned int ) dw;
   ystep = ( ( unsigned int ) DOOMGENERIC_RESY << 16 ) / ( unsigned int ) dh;
   yacc = 0;

   for( y = 0; y < dh; y++ )
   {
      const unsigned char *in = src + ( ( yacc >> 16 ) * DOOMGENERIC_RESX );
      unsigned int *out = dst + y * pitch;
      unsigned int xacc = 0;

      for( x = 0; x < dw; x++ )
      {
         out[ x ] = s_lut[ in[ xacc >> 16 ] ];
         xacc += xstep;
      }
      yacc += ystep;
   }
}

static void AlgFreeBackbuffer( void )
{
   if( s_fs_mem != NULL )
   {
      if( s_fs_old != NULL )
         SelectObject( s_fs_mem, s_fs_old );
      s_fs_old = NULL;
      if( s_fs_bmp != NULL )
         DeleteObject( s_fs_bmp );
      s_fs_bmp = NULL;
      DeleteDC( s_fs_mem );
      s_fs_mem = NULL;
   }
   s_fs_bits = NULL;
   s_fs_bw = 0;
   s_fs_bh = 0;
}

static int AlgEnsureBackbuffer( HDC hdc, int w, int h )
{
   BITMAPINFO bmi;
   void *bits;

   if( w < 1 || h < 1 )
      return 0;

   if( s_fs_mem != NULL && s_fs_bw == w && s_fs_bh == h && s_fs_bits != NULL )
      return 1;

   AlgFreeBackbuffer();
   s_fs_mem = CreateCompatibleDC( hdc );
   if( s_fs_mem == NULL )
      return 0;

   memset( &bmi, 0, sizeof( bmi ) );
   bmi.bmiHeader.biSize = sizeof( BITMAPINFOHEADER );
   bmi.bmiHeader.biWidth = w;
   bmi.bmiHeader.biHeight = -h;
   bmi.bmiHeader.biPlanes = 1;
   bmi.bmiHeader.biBitCount = 32;
   bmi.bmiHeader.biCompression = BI_RGB;
   bits = NULL;
   s_fs_bmp = CreateDIBSection( s_fs_mem, &bmi, DIB_RGB_COLORS, &bits, NULL, 0 );
   if( s_fs_bmp == NULL || bits == NULL )
   {
      if( s_fs_bmp != NULL )
         DeleteObject( s_fs_bmp );
      s_fs_bmp = NULL;
      DeleteDC( s_fs_mem );
      s_fs_mem = NULL;
      return 0;
   }

   s_fs_old = SelectObject( s_fs_mem, s_fs_bmp );
   s_fs_bits = ( unsigned int * ) bits;
   s_fs_bw = w;
   s_fs_bh = h;
   return 1;
}

static void AlgDrawLetterbox( HDC hdc, int win_w, int win_h, int dx, int dy, int dw, int dh )
{
   if( hdc == NULL )
      return;

   if( dy > 0 )
      PatBlt( hdc, 0, 0, win_w, dy, BLACKNESS );
   if( dx > 0 )
      PatBlt( hdc, 0, dy, dx, dh, BLACKNESS );
   if( dx + dw < win_w )
      PatBlt( hdc, dx + dw, dy, win_w - dx - dw, dh, BLACKNESS );
   if( dy + dh < win_h )
      PatBlt( hdc, 0, dy + dh, win_w, win_h - dy - dh, BLACKNESS );
}

static LRESULT CALLBACK AlgFsWndProc( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   HWND game;

   switch( msg )
   {
      case WM_PAINT:
      {
         PAINTSTRUCT ps;
         RECT rc;
         HDC hdc = BeginPaint( hwnd, &ps );
         GetClientRect( hwnd, &rc );
         AlgDrawLetterbox( hdc, rc.right, rc.bottom, s_fs_dx, s_fs_dy, s_fs_bw, s_fs_bh );
         if( s_fs_mem != NULL && s_fs_bw > 0 && s_fs_bh > 0 )
            BitBlt( hdc, s_fs_dx, s_fs_dy, s_fs_bw, s_fs_bh, s_fs_mem, 0, 0, SRCCOPY );
         EndPaint( hwnd, &ps );
         return 0;
      }
      case WM_ERASEBKGND:
         return 1;
      case WM_MOUSEACTIVATE:
         return MA_NOACTIVATE;
      case WM_ACTIVATE:
         game = win_get_window();
         if( game != NULL )
            SetForegroundWindow( game );
         return 0;
   }
   return DefWindowProc( hwnd, msg, wParam, lParam );
}

static void AlgDestroyOverlay( void )
{
   AlgFreeBackbuffer();
   s_fs_bars = 0;
   if( s_fs_wnddc != NULL && s_fs_wnd != NULL )
   {
      ReleaseDC( s_fs_wnd, s_fs_wnddc );
      s_fs_wnddc = NULL;
   }
   if( s_fs_wnd != NULL )
   {
      DestroyWindow( s_fs_wnd );
      s_fs_wnd = NULL;
   }
}

static void AlgPresentOverlaySrc( const unsigned char *src, int dx, int dy, int dw, int dh )
{
   HDC hdc;
   RECT rc;
   int win_w;
   int win_h;

   if( s_fs_wnd == NULL || src == NULL || dw < 1 || dh < 1 )
      return;

   GetClientRect( s_fs_wnd, &rc );
   win_w = rc.right;
   win_h = rc.bottom;
   if( win_w < 1 || win_h < 1 )
      return;

   if( dx < 0 )
      dx = 0;
   if( dy < 0 )
      dy = 0;
   if( dx + dw > win_w )
      dw = win_w - dx;
   if( dy + dh > win_h )
      dh = win_h - dy;
   if( dw < 1 || dh < 1 )
      return;

   hdc = s_fs_wnddc != NULL ? s_fs_wnddc : GetDC( s_fs_wnd );
   if( hdc == NULL )
      return;

   SetStretchBltMode( hdc, COLORONCOLOR );

   if( s_fs_bw != dw || s_fs_bh != dh || s_fs_dx != dx || s_fs_dy != dy )
      s_fs_bars = 0;

   if( ! AlgEnsureBackbuffer( hdc, dw, dh ) )
   {
      if( s_fs_wnddc == NULL )
         ReleaseDC( s_fs_wnd, hdc );
      return;
   }

   s_fs_dx = dx;
   s_fs_dy = dy;
   if( s_crt && CrtBuild( dw, dh ) )
      CrtRender( src, s_fs_bits, dw, dh, s_fs_bw );
   else
   {
      AlgRebuildLut();
      AlgScaleNN( src, s_fs_bits, dw, dh, s_fs_bw );
   }

   if( ! s_fs_bars )
   {
      AlgDrawLetterbox( hdc, win_w, win_h, dx, dy, dw, dh );
      s_fs_bars = 1;
   }

   BitBlt( hdc, dx, dy, dw, dh, s_fs_mem, 0, 0, SRCCOPY );

   if( s_fs_wnddc == NULL )
      ReleaseDC( s_fs_wnd, hdc );
}

static void AlgPresentOverlay( int dx, int dy, int dw, int dh )
{
   if( DG_ScreenBuffer != NULL )
      AlgPresentOverlaySrc( ( const unsigned char * ) DG_ScreenBuffer, dx, dy, dw, dh );
}

HB_FUNC( ALGOVERLAYSHOW )
{
   WNDCLASS wc;
   RECT rc;
   HWND game;
   HINSTANCE hInst;

   game = win_get_window();
   if( game == NULL )
   {
      hb_retni( 0 );
      return;
   }

   if( s_fs_wnd != NULL )
   {
      AlgMonitorRect( game, &rc );
      SetWindowPos( s_fs_wnd, HWND_TOPMOST, rc.left, rc.top,
                    rc.right - rc.left, rc.bottom - rc.top,
                    SWP_SHOWWINDOW | SWP_NOACTIVATE );
      s_fs_bars = 0;
      if( s_fs_wnddc != NULL )
         PatBlt( s_fs_wnddc, 0, 0, rc.right - rc.left, rc.bottom - rc.top, BLACKNESS );
      hb_retni( 1 );
      return;
   }

   hInst = GetModuleHandle( NULL );
   memset( &wc, 0, sizeof( wc ) );
   wc.style = CS_OWNDC;
   wc.lpfnWndProc = AlgFsWndProc;
   wc.hInstance = hInst;
   wc.hCursor = LoadCursor( NULL, IDC_ARROW );
   wc.hbrBackground = ( HBRUSH ) GetStockObject( NULL_BRUSH );
   wc.lpszClassName = ALG_FS_CLASS;
   RegisterClass( &wc );

   AlgMonitorRect( game, &rc );
   s_fs_wnd = CreateWindowEx( WS_EX_TOPMOST | WS_EX_NOACTIVATE, ALG_FS_CLASS,
                              "DOOM", WS_POPUP, rc.left, rc.top,
                              rc.right - rc.left, rc.bottom - rc.top,
                              NULL, NULL, hInst, NULL );
   if( s_fs_wnd == NULL )
   {
      hb_retni( 0 );
      return;
   }

   s_fs_wnddc = GetDC( s_fs_wnd );
   s_fs_bars = 0;
   if( s_fs_wnddc != NULL )
      PatBlt( s_fs_wnddc, 0, 0, rc.right - rc.left, rc.bottom - rc.top, BLACKNESS );
   ShowWindow( s_fs_wnd, SW_SHOWNOACTIVATE );
   SetForegroundWindow( game );
   hb_retni( 1 );
}

HB_FUNC( ALGPRESENTOVERLAYVID )
{
   const unsigned char *src = ( const unsigned char * ) hb_parc( 1 );

   if( src == NULL || hb_parclen( 1 ) < ( unsigned int ) ( DOOMGENERIC_RESX * DOOMGENERIC_RESY ) )
      return;

   AlgPresentOverlaySrc( src, hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ) );
}

HB_FUNC( ALGOVERLAYHIDE )
{
   AlgDestroyOverlay();
   hb_retni( 1 );
}

HB_FUNC( ALGOVERLAYSIZE )
{
   RECT rc;

   if( s_fs_wnd == NULL )
   {
      hb_ret();
      return;
   }

   GetClientRect( s_fs_wnd, &rc );
   hb_reta( 2 );
   hb_storvni( rc.right, -1, 1 );
   hb_storvni( rc.bottom, -1, 2 );
}
#else
static void AlgPresentOverlay( int dx, int dy, int dw, int dh )
{
   ( void ) dx;
   ( void ) dy;
   ( void ) dw;
   ( void ) dh;
}

HB_FUNC( ALGOVERLAYSHOW )
{
   hb_retni( 0 );
}

HB_FUNC( ALGOVERLAYHIDE )
{
   hb_retni( 0 );
}

HB_FUNC( ALGOVERLAYSIZE )
{
   hb_ret();
}

HB_FUNC( ALGPRESENTOVERLAYVID )
{
}
#endif

HB_FUNC( ALGBACKTOTEXT )
{
}

#ifdef ALLEGRO_WINDOWS
static HWND s_keep_wnd = NULL;

static BOOL CALLBACK AlgHideOtherWnd( HWND hwnd, LPARAM lParam )
{
   DWORD pid = 0;

   ( void ) lParam;
   GetWindowThreadProcessId( hwnd, &pid );
   if( pid == GetCurrentProcessId() && hwnd != s_keep_wnd && IsWindowVisible( hwnd ) )
      ShowWindow( hwnd, SW_HIDE );
   return TRUE;
}

static void AlgFixupWindow( int width, int height )
{
   HWND wnd;
   RECT rc;
   DWORD style;
   int sw;
   int sh;
   int ww;
   int hh;

   wnd = win_get_window();
   if( wnd == NULL )
      return;

   s_keep_wnd = wnd;
   set_window_title( "DOOM" );
   style = ( DWORD ) GetWindowLong( wnd, GWL_STYLE );
   if( ( style & WS_CAPTION ) == 0 )
      style = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE;
   rc.left = 0;
   rc.top = 0;
   rc.right = width;
   rc.bottom = height;
   AdjustWindowRect( &rc, style, FALSE );
   ww = rc.right - rc.left;
   hh = rc.bottom - rc.top;
   sw = GetSystemMetrics( SM_CXSCREEN );
   sh = GetSystemMetrics( SM_CYSCREEN );
   SetWindowPos( wnd, HWND_TOP, ( sw - ww ) / 2, ( sh - hh ) / 2, ww, hh,
                 SWP_SHOWWINDOW );
   ShowWindow( wnd, SW_SHOWNORMAL );
   SetForegroundWindow( wnd );
   EnumWindows( AlgHideOtherWnd, 0 );
}
#endif

static int AlgModeOk( void )
{
   return screen != NULL && SCREEN_W >= 320 && SCREEN_H >= 200;
}

HB_FUNC( ALGTRYSETMODE )
{
   int card = hb_parni( 1 );
   int width = hb_parni( 2 );
   int height = hb_parni( 3 );
   int depth = hb_parni( 4 );

   set_color_depth( depth );
   if( set_gfx_mode( card, width, height, 0, 0 ) != 0 || ! AlgModeOk() )
   {
      hb_retni( 0 );
      return;
   }
#ifdef ALLEGRO_WINDOWS
   AlgFixupWindow( SCREEN_W, SCREEN_H );
#endif
   hb_retni( 1 );
}

HB_FUNC( ALGTRYSETWINDOWED )
{
   int width = hb_parni( 1 );
   int height = hb_parni( 2 );
   int depth = hb_parni( 3 );
#ifdef ALLEGRO_WINDOWS
   int cards[ 3 ];
   int n = 3;
   int i;

   cards[ 0 ] = GFX_AUTODETECT_WINDOWED;
   cards[ 1 ] = GFX_DIRECTX_WIN;
   cards[ 2 ] = GFX_GDI;
#else
   int cards[ 1 ];
   int n = 1;
   int i;

   cards[ 0 ] = GFX_AUTODETECT_WINDOWED;
#endif

   set_color_depth( depth );
   for( i = 0; i < n; i++ )
   {
      if( set_gfx_mode( cards[ i ], width, height, 0, 0 ) == 0 && AlgModeOk() )
      {
#ifdef ALLEGRO_WINDOWS
         AlgFixupWindow( SCREEN_W, SCREEN_H );
#endif
         hb_retni( 1 );
         return;
      }
   }
   hb_retni( 0 );
}

HB_FUNC( ALGHIDEHOSTWINDOWS )
{
#ifdef ALLEGRO_WINDOWS
   s_keep_wnd = NULL;
   EnumWindows( AlgHideOtherWnd, 0 );
#endif
}

HB_FUNC( ALGSCREENW )
{
   hb_retni( SCREEN_W );
}

HB_FUNC( ALGSCREENH )
{
   hb_retni( SCREEN_H );
}

HB_FUNC( ALGSCREENDEPTH )
{
   hb_retni( screen != NULL ? bitmap_color_depth( screen ) : 0 );
}

HB_FUNC( ALGHASSCREEN )
{
   hb_retl( screen != NULL );
}

HB_FUNC( ALGHASSCREENBUFFER )
{
   hb_retl( DG_ScreenBuffer != NULL );
}

HB_FUNC( ALGHASTEMPBITMAP )
{
   hb_retl( temp_bitmap != NULL );
}

HB_FUNC( ALGCREATETEMPBITMAP )
{
   if( temp_bitmap != NULL )
   {
      destroy_bitmap( temp_bitmap );
      temp_bitmap = NULL;
   }

   if( screen == NULL )
   {
      hb_retni( 0 );
      return;
   }

   temp_bitmap = create_bitmap( DOOMGENERIC_RESX, DOOMGENERIC_RESY );
   if( ! temp_bitmap )
   {
      hb_retni( 0 );
      return;
   }

   clear_bitmap( temp_bitmap );
   hb_retni( 1 );
}

HB_FUNC( ALGCLEARBLACK )
{
   if( screen != NULL )
      clear_to_color( screen, makecol( 0, 0, 0 ) );
}

HB_FUNC( ALGDESKTOPRES )
{
   int width;
   int height;

   if( get_desktop_resolution( &width, &height ) == 0 )
   {
      hb_reta( 2 );
      hb_storvni( width, -1, 1 );
      hb_storvni( height, -1, 2 );
   }
   else
      hb_ret();
}

static void AlgCopy8ToTemp( const unsigned char *src )
{
   int x;
   int y;
   int depth;

   if( temp_bitmap == NULL || src == NULL )
      return;

   depth = bitmap_color_depth( temp_bitmap );

   if( depth == 8 )
   {
      for( y = 0; y < DOOMGENERIC_RESY; y++ )
         memcpy( temp_bitmap->line[ y ], src + y * DOOMGENERIC_RESX, DOOMGENERIC_RESX );
      return;
   }

   for( y = 0; y < DOOMGENERIC_RESY; y++ )
   {
      const unsigned char *in = src + y * DOOMGENERIC_RESX;

      if( depth == 32 )
      {
         unsigned int *out = ( unsigned int * ) temp_bitmap->line[ y ];
         for( x = 0; x < DOOMGENERIC_RESX; x++ )
         {
            struct color c = colors[ in[ x ] ];
            out[ x ] = ( unsigned int ) makecol( c.r, c.g, c.b );
         }
      }
      else if( depth == 16 || depth == 15 )
      {
         unsigned short *out = ( unsigned short * ) temp_bitmap->line[ y ];
         for( x = 0; x < DOOMGENERIC_RESX; x++ )
         {
            struct color c = colors[ in[ x ] ];
            out[ x ] = ( unsigned short ) makecol( c.r, c.g, c.b );
         }
      }
      else
      {
         for( x = 0; x < DOOMGENERIC_RESX; x++ )
         {
            struct color c = colors[ in[ x ] ];
            putpixel( temp_bitmap, x, y, makecol( c.r, c.g, c.b ) );
         }
      }
   }
}

HB_FUNC( ALGSYNCFROMVID )
{
   const unsigned char *src = ( const unsigned char * ) hb_parc( 1 );

   if( src == NULL || hb_parclen( 1 ) < ( unsigned int ) ( DOOMGENERIC_RESX * DOOMGENERIC_RESY ) )
      return;

   if( s_crt )
   {
      memcpy( s_crt_src8, src, CRT_SRC_PIXELS );
      s_crt_have_src = 1;
      return;
   }
   AlgCopy8ToTemp( src );
}

HB_FUNC( ALGSYNCFRAMEBUFFER )
{
   if( DG_ScreenBuffer == NULL )
      return;

   if( s_crt )
   {
      memcpy( s_crt_src8, DG_ScreenBuffer, CRT_SRC_PIXELS );
      s_crt_have_src = 1;
      return;
   }
   AlgCopy8ToTemp( ( unsigned char * ) DG_ScreenBuffer );
}

HB_FUNC( ALGSETPALETTE8 )
{
   PALETTE pal;
   int i;

   for( i = 0; i < 256; i++ )
   {
      pal[ i ].r = ( unsigned char ) ( colors[ i ].r >> 2 );
      pal[ i ].g = ( unsigned char ) ( colors[ i ].g >> 2 );
      pal[ i ].b = ( unsigned char ) ( colors[ i ].b >> 2 );
   }
   set_palette( pal );
}

HB_FUNC( ALGGETPALETTECHANGED )
{
#ifdef CMAP256
   hb_retl( palette_changed );
#else
   hb_retl( HB_FALSE );
#endif
}

HB_FUNC( ALGSETPALETTECHANGED )
{
#ifdef CMAP256
   palette_changed = hb_parl( 1 ) ? 1 : 0;
#endif
}

HB_FUNC( ALGSTRETCHBLIT )
{
   int dx = hb_parni( 1 );
   int dy = hb_parni( 2 );
   int dw = hb_parni( 3 );
   int dh = hb_parni( 4 );

   if( temp_bitmap == NULL )
      return;

#ifdef ALLEGRO_WINDOWS
   if( s_fs_wnd != NULL )
   {
      AlgPresentOverlay( dx, dy, dw, dh );
      return;
   }
#endif
   if( s_crt )
   {
      CrtPresentWindowed( dx, dy, dw, dh );
      return;
   }
   alleg_present_bitmap( temp_bitmap, dx, dy, dw, dh );
}

HB_FUNC( ALGRECTFILL )
{
   if( screen != NULL )
      rectfill( screen, hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ) );
}

HB_FUNC( ALGMAKECOL )
{
   hb_retni( makecol( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( ALGKEYDOWN )
{
   int sc = hb_parni( 1 );
#ifndef KEY_MAX
#define KEY_MAX 127
#endif
   if( s_alg_exited || keyboard_driver == NULL )
   {
      hb_retni( 0 );
      return;
   }
   hb_retni( ( sc >= 0 && sc < KEY_MAX && key[ sc ] ) ? 1 : 0 );
}

HB_FUNC( ALGKEYPOP )
{
   if( s_alg_exited )
   {
      hb_ret();
      return;
   }
   if( s_KeyQueueReadIndex == s_KeyQueueWriteIndex )
   {
      hb_ret();
      return;
   }

   hb_retni( ( int ) s_KeyQueue[ s_KeyQueueReadIndex ] );
   s_KeyQueueReadIndex++;
   s_KeyQueueReadIndex %= KEYQUEUE_SIZE;
}

HB_FUNC( ALGGETTICKS )
{
   hb_retnint( s_ticks );
}

HB_FUNC( ALGREST )
{
   rest( ( int ) hb_parnl( 1 ) );
}

HB_FUNC( ALGSETWINDOWTITLE )
{
   if( HB_ISCHAR( 1 ) )
      set_window_title( hb_parc( 1 ) );
}

HB_FUNC( ALGSCANCODETOASCII )
{
   if( s_alg_exited || keyboard_driver == NULL )
   {
      hb_retni( 0 );
      return;
   }
   hb_retni( scancode_to_ascii( hb_parni( 1 ) ) );
}

int loadpng_init( void )
{
   return 0;
}

#pragma ENDDUMP
