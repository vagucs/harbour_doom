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

STATIC background_buffer
STATIC fuzzoffset
STATIC fuzzpos

#include "doomdef.ch"
#include "doomstat.ch"
#include "m_fixed.ch"
#include "r_local.ch"

#define MAXWIDTH   1120
#define MAXHEIGHT  832
#define SBARHEIGHT 32
#define FUZZTABLE  50
#define PU_STATIC  1
#define PU_CACHE   8


STATIC PROCEDURE SetVid( nOff, nByte )
    MEMVAR I_VideoBuffer
    I_VideoBuffer := Stuff( I_VideoBuffer, nOff + 1, 1, Chr( nByte & 0xFF ) )
RETURN

STATIC FUNCTION GetVid( nOff )
    MEMVAR I_VideoBuffer
RETURN Asc( SubStr( I_VideoBuffer, nOff + 1, 1 ) )

STATIC FUNCTION ByteAt( cData, nIndex )
    IF ValType( cData ) == "C"
        RETURN Asc( SubStr( cData, nIndex + 1, 1 ) )
    ENDIF
RETURN cData[ nIndex + 1 ]

PROCEDURE R_DrawColumn()
    MEMVAR dc_colormap, dc_x, dc_yl, dc_yh, dc_iscale
    MEMVAR dc_texturemid, dc_source, centery, ylookup, columnofs
    LOCAL count := dc_yh - dc_yl
    LOCAL dest
    LOCAL frac
    LOCAL fracstep
    LOCAL src

    IF count < 0
        RETURN
    ENDIF

    dest := ylookup[ dc_yl + 1 ] + columnofs[ dc_x + 1 ]
    fracstep := dc_iscale
    frac := dc_texturemid + ( dc_yl - centery ) * fracstep

    DO WHILE .T.
        src := Asc( SubStr( dc_source, ( ( UShr( frac, FRACBITS ) & 127 ) ) + 1, 1 ) )
        SetVid( dest, Asc( SubStr( dc_colormap, src + 1, 1 ) ) )
        dest += SCREENWIDTH
        frac += fracstep
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_DrawColumnLow()
    MEMVAR dc_colormap, dc_x, dc_yl, dc_yh, dc_iscale
    MEMVAR dc_texturemid, dc_source, centery, ylookup, columnofs
    LOCAL count := dc_yh - dc_yl
    LOCAL x
    LOCAL dest
    LOCAL dest2
    LOCAL frac
    LOCAL fracstep
    LOCAL src
    LOCAL pixel

    IF count < 0
        RETURN
    ENDIF

    x := dc_x * 2
    dest := ylookup[ dc_yl + 1 ] + columnofs[ x + 1 ]
    dest2 := ylookup[ dc_yl + 1 ] + columnofs[ x + 2 ]
    fracstep := dc_iscale
    frac := dc_texturemid + ( dc_yl - centery ) * fracstep

    DO WHILE .T.
        src := Asc( SubStr( dc_source, ( ( UShr( frac, FRACBITS ) & 127 ) ) + 1, 1 ) )
        pixel := Asc( SubStr( dc_colormap, src + 1, 1 ) )
        SetVid( dest, pixel )
        SetVid( dest2, pixel )
        dest += SCREENWIDTH
        dest2 += SCREENWIDTH
        frac += fracstep
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_DrawFuzzColumn()
    MEMVAR dc_x, dc_yl, dc_yh, viewheight, ylookup, columnofs, colormaps
    LOCAL count
    LOCAL dest
    LOCAL pixel

    IF dc_yl == 0
        dc_yl := 1
    ENDIF
    IF dc_yh == viewheight - 1
        dc_yh := viewheight - 2
    ENDIF

    count := dc_yh - dc_yl
    IF count < 0
        RETURN
    ENDIF

    dest := ylookup[ dc_yl + 1 ] + columnofs[ dc_x + 1 ]

    DO WHILE .T.
        pixel := GetVid( dest + fuzzoffset[ fuzzpos ] )
        SetVid( dest, ByteAt( colormaps, 6 * 256 + pixel ) )
        fuzzpos++
        IF fuzzpos > FUZZTABLE
            fuzzpos := 1
        ENDIF
        dest += SCREENWIDTH
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_DrawFuzzColumnLow()
    MEMVAR dc_x, dc_yl, dc_yh, viewheight, ylookup, columnofs, colormaps
    LOCAL count
    LOCAL x
    LOCAL dest
    LOCAL dest2

    IF dc_yl == 0
        dc_yl := 1
    ENDIF
    IF dc_yh == viewheight - 1
        dc_yh := viewheight - 2
    ENDIF

    count := dc_yh - dc_yl
    IF count < 0
        RETURN
    ENDIF

    x := dc_x * 2
    dest := ylookup[ dc_yl + 1 ] + columnofs[ x + 1 ]
    dest2 := ylookup[ dc_yl + 1 ] + columnofs[ x + 2 ]

    DO WHILE .T.
        SetVid( dest, ByteAt( colormaps, 6 * 256 + GetVid( dest + fuzzoffset[ fuzzpos ] ) ) )
        SetVid( dest2, ByteAt( colormaps, 6 * 256 + GetVid( dest2 + fuzzoffset[ fuzzpos ] ) ) )
        fuzzpos++
        IF fuzzpos > FUZZTABLE
            fuzzpos := 1
        ENDIF
        dest += SCREENWIDTH
        dest2 += SCREENWIDTH
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_DrawTranslatedColumn()
    MEMVAR dc_colormap, dc_translation, dc_x, dc_yl, dc_yh, dc_iscale
    MEMVAR dc_texturemid, dc_source, centery, ylookup, columnofs
    LOCAL count := dc_yh - dc_yl
    LOCAL dest
    LOCAL frac
    LOCAL fracstep
    LOCAL src
    LOCAL translated

    IF count < 0
        RETURN
    ENDIF

    dest := ylookup[ dc_yl + 1 ] + columnofs[ dc_x + 1 ]
    fracstep := dc_iscale
    frac := dc_texturemid + ( dc_yl - centery ) * fracstep

    DO WHILE .T.
        src := Asc( SubStr( dc_source, UShr( frac, FRACBITS ) + 1, 1 ) )
        translated := Asc( SubStr( dc_translation, src + 1, 1 ) )
        SetVid( dest, Asc( SubStr( dc_colormap, translated + 1, 1 ) ) )
        dest += SCREENWIDTH
        frac += fracstep
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_DrawTranslatedColumnLow()
    MEMVAR dc_colormap, dc_translation, dc_x, dc_yl, dc_yh, dc_iscale
    MEMVAR dc_texturemid, dc_source, centery, ylookup, columnofs
    LOCAL count := dc_yh - dc_yl
    LOCAL x
    LOCAL dest
    LOCAL dest2
    LOCAL frac
    LOCAL fracstep
    LOCAL src
    LOCAL translated
    LOCAL pixel

    IF count < 0
        RETURN
    ENDIF

    x := dc_x * 2
    dest := ylookup[ dc_yl + 1 ] + columnofs[ x + 1 ]
    dest2 := ylookup[ dc_yl + 1 ] + columnofs[ x + 2 ]
    fracstep := dc_iscale
    frac := dc_texturemid + ( dc_yl - centery ) * fracstep

    DO WHILE .T.
        src := Asc( SubStr( dc_source, UShr( frac, FRACBITS ) + 1, 1 ) )
        translated := Asc( SubStr( dc_translation, src + 1, 1 ) )
        pixel := Asc( SubStr( dc_colormap, translated + 1, 1 ) )
        SetVid( dest, pixel )
        SetVid( dest2, pixel )
        dest += SCREENWIDTH
        dest2 += SCREENWIDTH
        frac += fracstep
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_InitTranslationTables()
    MEMVAR translationtables
    LOCAL i
    LOCAL aTables := Array( 3 * 256 )
    LOCAL n

    FOR i := 0 TO 255
        IF i >= 0x70 .AND. i <= 0x7F
            aTables[ i + 1 ] := 0x60 + ( i & 0x0F )
            aTables[ i + 257 ] := 0x40 + ( i & 0x0F )
            aTables[ i + 513 ] := 0x20 + ( i & 0x0F )
        ELSE
            aTables[ i + 1 ] := i
            aTables[ i + 257 ] := i
            aTables[ i + 513 ] := i
        ENDIF
    NEXT

    translationtables := ""
    FOR n := 1 TO Len( aTables )
        translationtables += Chr( aTables[ n ] )
    NEXT
RETURN

PROCEDURE R_DrawSpan()
    MEMVAR ds_y, ds_x1, ds_x2, ds_colormap, ds_xfrac, ds_yfrac
    MEMVAR ds_xstep, ds_ystep, ds_source, ylookup, columnofs
    LOCAL position
    LOCAL nStep
    LOCAL dest
    LOCAL count
    LOCAL spot
    LOCAL xtemp
    LOCAL ytemp
    LOCAL src

    position := ( ( ( ds_xfrac * ( 2 ^ 10 ) ) & 0xFFFF0000 ) | ;
                ( UShr( ds_yfrac, 6 ) & 0x0000FFFF ) )
    nStep := ( ( ( ds_xstep * ( 2 ^ 10 ) ) & 0xFFFF0000 ) | ;
            ( UShr( ds_ystep, 6 ) & 0x0000FFFF ) )
    dest := ylookup[ ds_y + 1 ] + columnofs[ ds_x1 + 1 ]
    count := ds_x2 - ds_x1

    DO WHILE .T.
        ytemp := ( UShr( position, 4 ) & 0x0FC0 )
        xtemp := UShr( position, 26 )
        spot := ( xtemp | ytemp )
        src := Asc( SubStr( ds_source, spot + 1, 1 ) )
        SetVid( dest, Asc( SubStr( ds_colormap, src + 1, 1 ) ) )
        dest++
        position := ( ( position + nStep ) & 0xFFFFFFFF )
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_DrawSpanLow()
    MEMVAR ds_y, ds_x1, ds_x2, ds_colormap, ds_xfrac, ds_yfrac
    MEMVAR ds_xstep, ds_ystep, ds_source, ylookup, columnofs
    LOCAL position
    LOCAL nStep
    LOCAL dest
    LOCAL count := ds_x2 - ds_x1
    LOCAL spot
    LOCAL src
    LOCAL pixel

    position := ( ( ( ds_xfrac * ( 2 ^ 10 ) ) & 0xFFFF0000 ) | ;
                ( UShr( ds_yfrac, 6 ) & 0x0000FFFF ) )
    nStep := ( ( ( ds_xstep * ( 2 ^ 10 ) ) & 0xFFFF0000 ) | ;
            ( UShr( ds_ystep, 6 ) & 0x0000FFFF ) )
    ds_x1 *= 2
    ds_x2 *= 2
    dest := ylookup[ ds_y + 1 ] + columnofs[ ds_x1 + 1 ]

    DO WHILE .T.
        spot := ( UShr( position, 26 ) | ( UShr( position, 4 ) & 0x0FC0 ) )
        src := Asc( SubStr( ds_source, spot + 1, 1 ) )
        pixel := Asc( SubStr( ds_colormap, src + 1, 1 ) )
        SetVid( dest, pixel )
        SetVid( dest + 1, pixel )
        dest += 2
        position := ( ( position + nStep ) & 0xFFFFFFFF )
        count--
        IF count < 0
            EXIT
        ENDIF
    ENDDO
RETURN

PROCEDURE R_InitBuffer( width, height )
    MEMVAR viewwindowx, viewwindowy, ylookup, columnofs
    LOCAL i

    viewwindowx := Shar( SCREENWIDTH - width, 1 )
    FOR i := 0 TO width - 1
        columnofs[ i + 1 ] := i
    NEXT

    IF width == SCREENWIDTH
        viewwindowy := 0
    ELSE
        viewwindowy := Shar( SCREENHEIGHT - SBARHEIGHT - height, 1 )
    ENDIF

    FOR i := 0 TO height - 1
        ylookup[ i + 1 ] := ( i + viewwindowy ) * SCREENWIDTH + viewwindowx
    NEXT
RETURN

PROCEDURE R_FillBackScreen()
    MEMVAR scaledviewwidth, viewwindowx, viewwindowy, viewheight, gamemode
    LOCAL src
    LOCAL x
    LOCAL y
    LOCAL patch
    LOCAL name
    LOCAL cRow

    IF scaledviewwidth == SCREENWIDTH
        background_buffer := NIL
        RETURN
    ENDIF

    IF background_buffer == NIL
        background_buffer := Replicate( Chr( 0 ), SCREENWIDTH * ( SCREENHEIGHT - SBARHEIGHT ) )
    ENDIF

    IF gamemode == commercial
        name := DEH_String( "GRNROCK" )
    ELSE
        name := DEH_String( "FLOOR7_2" )
    ENDIF

    src := W_CacheLumpName( name, PU_CACHE )
    FOR y := 0 TO SCREENHEIGHT - SBARHEIGHT - 1
        cRow := SubStr( src, ( ( y & 63 ) * 64 ) + 1, 64 )
        FOR x := 0 TO Int( SCREENWIDTH / 64 ) - 1
            background_buffer := Stuff( background_buffer, y * SCREENWIDTH + x * 64 + 1, 64, cRow )
        NEXT
        IF ( SCREENWIDTH & 63 ) != 0
            background_buffer := Stuff( background_buffer, ;
                y * SCREENWIDTH + Int( SCREENWIDTH / 64 ) * 64 + 1, ;
                ( SCREENWIDTH & 63 ), Left( cRow, ( SCREENWIDTH & 63 ) ) )
        ENDIF
    NEXT

    V_UseBuffer( background_buffer )

    patch := W_CacheLumpName( DEH_String( "brdr_t" ), PU_CACHE )
    FOR x := 0 TO scaledviewwidth - 1 STEP 8
        V_DrawPatch( viewwindowx + x, viewwindowy - 8, patch )
    NEXT
    patch := W_CacheLumpName( DEH_String( "brdr_b" ), PU_CACHE )
    FOR x := 0 TO scaledviewwidth - 1 STEP 8
        V_DrawPatch( viewwindowx + x, viewwindowy + viewheight, patch )
    NEXT
    patch := W_CacheLumpName( DEH_String( "brdr_l" ), PU_CACHE )
    FOR y := 0 TO viewheight - 1 STEP 8
        V_DrawPatch( viewwindowx - 8, viewwindowy + y, patch )
    NEXT
    patch := W_CacheLumpName( DEH_String( "brdr_r" ), PU_CACHE )
    FOR y := 0 TO viewheight - 1 STEP 8
        V_DrawPatch( viewwindowx + scaledviewwidth, viewwindowy + y, patch )
    NEXT

    V_DrawPatch( viewwindowx - 8, viewwindowy - 8, ;
        W_CacheLumpName( DEH_String( "brdr_tl" ), PU_CACHE ) )
    V_DrawPatch( viewwindowx + scaledviewwidth, viewwindowy - 8, ;
        W_CacheLumpName( DEH_String( "brdr_tr" ), PU_CACHE ) )
    V_DrawPatch( viewwindowx - 8, viewwindowy + viewheight, ;
        W_CacheLumpName( DEH_String( "brdr_bl" ), PU_CACHE ) )
    V_DrawPatch( viewwindowx + scaledviewwidth, viewwindowy + viewheight, ;
        W_CacheLumpName( DEH_String( "brdr_br" ), PU_CACHE ) )

    V_RestoreBuffer()
RETURN

PROCEDURE R_VideoErase( ofs, count )
    MEMVAR I_VideoBuffer
    IF background_buffer != NIL
        I_VideoBuffer := Stuff( I_VideoBuffer, ofs + 1, count, ;
            SubStr( background_buffer, ofs + 1, count ) )
    ENDIF
RETURN

PROCEDURE R_DrawViewBorder()
    MEMVAR scaledviewwidth, viewheight
    LOCAL top
    LOCAL side
    LOCAL ofs
    LOCAL i

    IF scaledviewwidth == SCREENWIDTH
        RETURN
    ENDIF

    top := Int( ( SCREENHEIGHT - SBARHEIGHT - viewheight ) / 2 )
    side := Int( ( SCREENWIDTH - scaledviewwidth ) / 2 )
    R_VideoErase( 0, top * SCREENWIDTH + side )
    ofs := ( viewheight + top ) * SCREENWIDTH - side
    R_VideoErase( ofs, top * SCREENWIDTH + side )
    ofs := top * SCREENWIDTH + SCREENWIDTH - side
    side *= 2
    FOR i := 1 TO viewheight - 1
        R_VideoErase( ofs, side )
        ofs += SCREENWIDTH
    NEXT
    V_MarkRect( 0, 0, SCREENWIDTH, SCREENHEIGHT - SBARHEIGHT )
RETURN

INIT PROCEDURE init_r_draw
    LOCAL i

    PUBLIC dc_colormap, dc_x, dc_yl, dc_yh, dc_iscale, dc_texturemid
    PUBLIC dc_source, dccount, dc_translation
    PUBLIC ds_y, ds_x1, ds_x2, ds_colormap, ds_xfrac, ds_yfrac
    PUBLIC ds_xstep, ds_ystep, ds_source, dscount
    PUBLIC ylookup, columnofs, translationtables, translations
    PUBLIC viewimage, viewwindowx, viewwindowy

    dc_colormap := ""
    dc_x := 0
    dc_yl := 0
    dc_yh := 0
    dc_iscale := 0
    dc_texturemid := 0
    dc_source := ""
    dccount := 0
    dc_translation := ""
    ds_y := 0
    ds_x1 := 0
    ds_x2 := 0
    ds_colormap := ""
    ds_xfrac := 0
    ds_yfrac := 0
    ds_xstep := 0
    ds_ystep := 0
    ds_source := ""
    dscount := 0
    ylookup := Array( MAXHEIGHT )
    AFill( ylookup, 0 )
    columnofs := Array( MAXWIDTH )
    AFill( columnofs, 0 )
    translationtables := ""
    translations := Array( 3 )
    FOR i := 1 TO 3
        translations[ i ] := Replicate( Chr( 0 ), 256 )
    NEXT
    viewimage := NIL
    viewwindowx := 0
    viewwindowy := 0
    background_buffer := NIL
    fuzzoffset := { ;
         SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH, ;
         SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH, ;
         SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH, ;
         SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH, -SCREENWIDTH, -SCREENWIDTH, ;
        -SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH, ;
         SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH, ;
        -SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH, -SCREENWIDTH, ;
         SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH, -SCREENWIDTH, -SCREENWIDTH, ;
        -SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH, ;
        -SCREENWIDTH,  SCREENWIDTH,  SCREENWIDTH, -SCREENWIDTH,  SCREENWIDTH }
    fuzzpos := 1
RETURN
