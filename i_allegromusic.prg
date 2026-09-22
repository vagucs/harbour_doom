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

STATIC music_initialized := .F.
STATIC musicpaused := .F.
STATIC current_music_volume := 0
STATIC current_track_music := NIL
STATIC current_track_loop := .F.

#include "deh_str.ch"
#include "doomtype.ch"
#include "gusconf.ch"
#include "i_allegromusic.ch"

#define MID_HEADER_MAGIC "MThd"
#define MUS_HEADER_MAGIC ( "MUS" + Chr( 26 ) )


INIT PROCEDURE init_i_allegromusic

    PUBLIC timidity_cfg_path
    PUBLIC gus_patch_path
    PUBLIC gus_ram_kb
    PUBLIC DG_music_module

    timidity_cfg_path := ""
    gus_patch_path := ""
    gus_ram_kb := 1024

    music_initialized := .F.
    musicpaused := .F.
    current_music_volume := 0
    current_track_music := NIL
    current_track_loop := .F.

    DG_music_module := music_module_t():New()
    DG_music_module:sound_devices := { ;
        SNDDEVICE_PAS, ;
        SNDDEVICE_GUS, ;
        SNDDEVICE_WAVEBLASTER, ;
        SNDDEVICE_SOUNDCANVAS, ;
        SNDDEVICE_GENMIDI, ;
        SNDDEVICE_AWE32 }
    DG_music_module:num_sound_devices := Len( DG_music_module:sound_devices )
    DG_music_module:Init := {|| I_Allegro_InitMusic() }
    DG_music_module:Shutdown := {|| I_Allegro_ShutdownMusic() }
    DG_music_module:SetMusicVolume := {| volume | I_Allegro_SetMusicVolume( volume ) }
    DG_music_module:PauseMusic := {|| I_Allegro_PauseSong() }
    DG_music_module:ResumeMusic := {|| I_Allegro_ResumeSong() }
    DG_music_module:RegisterSong := {| data, len | I_Allegro_RegisterSong( data, len ) }
    DG_music_module:UnRegisterSong := {| handle | I_Allegro_UnRegisterSong( handle ) }
    DG_music_module:PlaySong := {| handle, looping | I_Allegro_PlaySong( handle, looping ) }
    DG_music_module:StopSong := {|| I_Allegro_StopSong() }
    DG_music_module:MusicIsPlaying := {|| I_Allegro_MusicIsPlaying() }
    DG_music_module:Poll := {|| I_Allegro_PollMusic() }
RETURN

STATIC FUNCTION I_Allegro_ShutdownMusic()
RETURN NIL

STATIC FUNCTION I_Allegro_InitMusic()
    music_initialized := .T.
RETURN .T.

STATIC FUNCTION I_Allegro_SetMusicVolume( volume )
    LOCAL nDigi

    nDigi := AlgMusicGetDigiVol()
    AlgMusicSetVolume( nDigi, volume * 2 )
    current_music_volume := volume
RETURN NIL

STATIC FUNCTION I_Allegro_PlaySong( handle, looping )
    LOCAL nRet

    IF ! music_initialized
        RETURN NIL
    ENDIF
    IF handle == NIL
        RETURN NIL
    ENDIF

    current_track_music := handle
    current_track_loop := looping

    nRet := AlgMusicPlayMidi( current_track_music, looping )
    IF nRet < 0
        OutErr( "Error playing midi: " + hb_ntos( nRet ) + ' "' + AlgMusicError() + '"' + hb_eol() )
    ENDIF
RETURN NIL

STATIC FUNCTION I_Allegro_PauseSong()
    IF ! music_initialized
        RETURN NIL
    ENDIF
    musicpaused := .T.
    AlgMusicPause()
RETURN NIL

STATIC FUNCTION I_Allegro_ResumeSong()
    IF ! music_initialized
        RETURN NIL
    ENDIF
    musicpaused := .F.
    AlgMusicResume()
RETURN NIL

STATIC FUNCTION I_Allegro_StopSong()
    IF ! music_initialized
        RETURN NIL
    ENDIF
    AlgMusicStop()
    current_track_music := NIL
RETURN NIL

STATIC FUNCTION I_Allegro_UnRegisterSong( handle )
    IF ! music_initialized
        RETURN NIL
    ENDIF
    IF handle == NIL
        RETURN NIL
    ENDIF
    AlgMusicDestroy( handle )
RETURN NIL

STATIC FUNCTION IsMid( mem, nLen )
    IF nLen <= 4
        RETURN .F.
    ENDIF
    IF ValType( mem ) == "C"
        RETURN Left( mem, 4 ) == MID_HEADER_MAGIC
    ENDIF
RETURN .F.

STATIC FUNCTION ConvertMus( musdata, nLen, filename )
    LOCAL instream
    LOCAL outstream
    LOCAL outbuf := NIL
    LOCAL outbuf_len := 0
    LOCAL nResult

    instream := mem_fopen_read( musdata, nLen )
    outstream := mem_fopen_write()

    nResult := mus2mid( instream, outstream )

    IF nResult == 0
        mem_get_buf( outstream, @outbuf, @outbuf_len )
        M_WriteFile( filename, outbuf, outbuf_len )
    ENDIF

    mem_fclose( instream )
    mem_fclose( outstream )
RETURN nResult

STATIC FUNCTION I_Allegro_RegisterSong( data, nLen )
    LOCAL filename
    LOCAL music

    IF ! music_initialized
        RETURN NIL
    ENDIF

    filename := M_TempFile( "doom.mid" )

    IF IsMid( data, nLen ) .AND. nLen < MAXMIDLENGTH
        M_WriteFile( filename, data, nLen )
    ELSE
        ConvertMus( data, nLen, filename )
    ENDIF

    music := AlgMusicLoad( filename )

    IF music == NIL
        OutErr( "Error loading midi: " + AlgMusicError() + hb_eol() )
    ENDIF

    FErase( filename )
RETURN music

STATIC FUNCTION I_Allegro_MusicIsPlaying()
    IF ! music_initialized
        RETURN .F.
    ENDIF
RETURN current_track_music != NIL .AND. AlgMusicPos() > 0

STATIC FUNCTION GetMusicPosition()
RETURN AlgMusicTime()

STATIC FUNCTION I_Allegro_PollMusic()
RETURN NIL

#pragma BEGINDUMP
#include "hbapi.h"
#include "hbapiitm.h"

#define ALLEGRO_NO_KEY_DEFINES 1
#include <allegro.h>

#ifdef uint32_t
#undef uint32_t
#endif

HB_FUNC( ALGMUSICGETDIGIVOL )
{
   int digivol = -1;

   get_volume( &digivol, NULL );
   hb_retni( digivol );
}

HB_FUNC( ALGMUSICSETVOLUME )
{
   set_volume( hb_parni( 1 ), hb_parni( 2 ) );
}

HB_FUNC( ALGMUSICPLAYMIDI )
{
   MIDI *midi = ( MIDI * ) hb_parptr( 1 );

   hb_retni( play_midi( midi, hb_parl( 2 ) ? TRUE : FALSE ) );
}

HB_FUNC( ALGMUSICPAUSE )
{
   midi_pause();
}

HB_FUNC( ALGMUSICRESUME )
{
   midi_resume();
}

HB_FUNC( ALGMUSICSTOP )
{
   stop_midi();
}

HB_FUNC( ALGMUSICDESTROY )
{
   MIDI *midi = ( MIDI * ) hb_parptr( 1 );

   if( midi )
      destroy_midi( midi );
}

HB_FUNC( ALGMUSICLOAD )
{
   MIDI *midi;

   midi = load_midi( hb_parc( 1 ) );
   if( midi == NULL )
      hb_ret();
   else
      hb_retptr( midi );
}

HB_FUNC( ALGMUSICPOS )
{
   hb_retnl( midi_pos );
}

HB_FUNC( ALGMUSICTIME )
{
   hb_retnd( midi_time );
}

HB_FUNC( ALGMUSICERROR )
{
   hb_retc( allegro_error );
}

#pragma ENDDUMP
