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

STATIC sound_initialized := .F.
STATIC channels_playing := {}
STATIC allegro_voices := {}
STATIC dummy_sample := NIL
STATIC use_sfx_prefix := .F.

#include "deh_str.ch"
#include "doomtype.ch"
#include "i_allegrosound.ch"

#ifndef PU_STATIC
#define PU_STATIC 1
#endif


INIT PROCEDURE init_i_allegrosound
    LOCAL i

    PUBLIC use_libsamplerate
    PUBLIC libsamplerate_scale
    PUBLIC DG_sound_module

    use_libsamplerate := 0
    libsamplerate_scale := 0.65

    sound_initialized := .F.
    dummy_sample := NIL
    use_sfx_prefix := .F.

    channels_playing := {}
    allegro_voices := {}
    FOR i := 1 TO NUM_CHANNELS
        AAdd( channels_playing, NIL )
        AAdd( allegro_voices, -1 )
    NEXT

    DG_sound_module := sound_module_t():New()
    DG_sound_module:sound_devices := { ;
        SNDDEVICE_SB, ;
        SNDDEVICE_PAS, ;
        SNDDEVICE_GUS, ;
        SNDDEVICE_WAVEBLASTER, ;
        SNDDEVICE_SOUNDCANVAS, ;
        SNDDEVICE_AWE32 }
    DG_sound_module:num_sound_devices := Len( DG_sound_module:sound_devices )
    DG_sound_module:Init := {| lPrefix | I_Allegro_InitSound( lPrefix ) }
    DG_sound_module:Shutdown := {|| I_Allegro_ShutdownSound() }
    DG_sound_module:GetSfxLumpNum := {| sfx | I_Allegro_GetSfxLumpNum( sfx ) }
    DG_sound_module:Update := {|| I_Allegro_UpdateSound() }
    DG_sound_module:UpdateSoundParams := {| handle, vol, sep | I_Allegro_UpdateSoundParams( handle, vol, sep ) }
    DG_sound_module:StartSound := {| sfx, channel, vol, sep | I_Allegro_StartSound( sfx, channel, vol, sep ) }
    DG_sound_module:StopSound := {| handle | I_Allegro_StopSound( handle ) }
    DG_sound_module:SoundIsPlaying := {| handle | I_Allegro_SoundIsPlaying( handle ) }
    DG_sound_module:CacheSounds := {| sounds, num | I_Allegro_PrecacheSounds( sounds, num ) }
RETURN

STATIC FUNCTION LumpByte( cData, nIdx0 )
    LOCAL nPos

    nPos := nIdx0 + 1
    IF ValType( cData ) != "C" .OR. nPos < 1 .OR. nPos > Len( cData )
        RETURN 0
    ENDIF
RETURN ( Asc( SubStr( cData, nPos, 1 ) ) & 0xFF )

STATIC FUNCTION CacheSFX( sfxinfo )
    LOCAL nLump
    LOCAL nLumpLen
    LOCAL nRate
    LOCAL nLength
    LOCAL cData
    LOCAL sample

    nLump := sfxinfo:lumpnum
    cData := W_CacheLumpNum( nLump, PU_STATIC )
    nLumpLen := W_LumpLength( nLump )

    IF ValType( cData ) != "C" .OR. nLumpLen < 8 ;
         .OR. LumpByte( cData, 0 ) != 3 .OR. LumpByte( cData, 1 ) != 0
        RETURN .F.
    ENDIF

    nRate := LumpByte( cData, 2 ) + LumpByte( cData, 3 ) * 256
    nLength := LumpByte( cData, 4 ) + LumpByte( cData, 5 ) * 256 ;
         + LumpByte( cData, 6 ) * 65536 + LumpByte( cData, 7 ) * 16777216

    IF nLength > nLumpLen - 8 .OR. nLength <= 48
        RETURN .F.
    ENDIF

    nLength := nLength - 32
    sample := AlgSndCreateSfxSample( SubStr( cData, 17, nLength ), nRate )
    IF sample == NIL
        RETURN .F.
    ENDIF

    sfxinfo:driver_data := sample
    W_ReleaseLumpNum( nLump )
RETURN .T.

STATIC FUNCTION GetSfxLumpName( sfx )
    LOCAL cName

    IF sfx:link != NIL
        sfx := sfx:link
    ENDIF

    IF use_sfx_prefix
        cName := "ds" + DEH_String( sfx:name )
    ELSE
        cName := DEH_String( sfx:name )
    ENDIF
RETURN cName

STATIC FUNCTION I_Allegro_PrecacheSounds( sounds, num_sounds )
    LOCAL i
    LOCAL cName

    OutStd( "I_Allegro_PrecacheSounds: Precaching all sound effects.." )

    FOR i := 0 TO num_sounds - 1
        IF ( i % 6 ) == 0
            OutStd( "." )
        ENDIF
        cName := GetSfxLumpName( sounds[ i + 1 ] )
        sounds[ i + 1 ]:lumpnum := W_CheckNumForName( cName )
        IF sounds[ i + 1 ]:lumpnum != -1
            CacheSFX( sounds[ i + 1 ] )
        ENDIF
    NEXT

    OutStd( hb_eol() )
RETURN NIL

STATIC FUNCTION I_Allegro_GetSfxLumpNum( sfx )
RETURN W_GetNumForName( GetSfxLumpName( sfx ) )

STATIC FUNCTION I_Allegro_UpdateSoundParams( handle, vol, sep )
    IF ! sound_initialized .OR. handle < 0 .OR. handle >= NUM_CHANNELS
        RETURN NIL
    ENDIF
    IF channels_playing[ handle + 1 ] == NIL
        RETURN NIL
    ENDIF
    AlgSndVoiceSetVolume( allegro_voices[ handle + 1 ], vol )
    AlgSndVoiceSetPan( allegro_voices[ handle + 1 ], sep )
RETURN NIL

STATIC FUNCTION I_Allegro_StartSound( sfxinfo, channel, vol, sep )
    IF ! sound_initialized .OR. channel < 0 .OR. channel >= NUM_CHANNELS
        RETURN -1
    ENDIF

    IF channels_playing[ channel + 1 ] != NIL
        AlgSndVoiceStop( allegro_voices[ channel + 1 ] )
        channels_playing[ channel + 1 ] := NIL
    ENDIF

    IF sfxinfo:driver_data == NIL
        IF ! CacheSFX( sfxinfo )
            RETURN -1
        ENDIF
    ENDIF

    AlgSndReallocateVoice( allegro_voices[ channel + 1 ], sfxinfo:driver_data )
    AlgSndVoiceSetVolume( allegro_voices[ channel + 1 ], vol )
    AlgSndVoiceSetPan( allegro_voices[ channel + 1 ], sep )
    AlgSndVoiceStart( allegro_voices[ channel + 1 ] )

    channels_playing[ channel + 1 ] := sfxinfo
RETURN channel

STATIC FUNCTION I_Allegro_StopSound( handle )
    IF ! sound_initialized .OR. handle < 0 .OR. handle >= NUM_CHANNELS
        RETURN NIL
    ENDIF
    IF channels_playing[ handle + 1 ] == NIL
        RETURN NIL
    ENDIF
    AlgSndVoiceStop( allegro_voices[ handle + 1 ] )
    channels_playing[ handle + 1 ] := NIL
RETURN NIL

STATIC FUNCTION I_Allegro_SoundIsPlaying( handle )
    LOCAL nPos

    IF ! sound_initialized .OR. handle < 0 .OR. handle >= NUM_CHANNELS
        RETURN .F.
    ENDIF
    IF channels_playing[ handle + 1 ] == NIL
        RETURN .F.
    ENDIF

    nPos := AlgSndVoiceGetPos( allegro_voices[ handle + 1 ] )
    IF nPos < 0
        RETURN .F.
    ENDIF
RETURN .T.

STATIC FUNCTION I_Allegro_UpdateSound()
    LOCAL i
    LOCAL nPos

    FOR i := 0 TO NUM_CHANNELS - 1
        IF channels_playing[ i + 1 ] != NIL
            nPos := AlgSndVoiceGetPos( allegro_voices[ i + 1 ] )
            IF nPos < 0
                channels_playing[ i + 1 ] := NIL
            ENDIF
        ENDIF
    NEXT
RETURN NIL

STATIC FUNCTION I_Allegro_ShutdownSound()
    LOCAL i

    IF ! sound_initialized
        RETURN NIL
    ENDIF

    FOR i := 0 TO NUM_CHANNELS - 1
        IF channels_playing[ i + 1 ] != NIL
            AlgSndVoiceStop( allegro_voices[ i + 1 ] )
            channels_playing[ i + 1 ] := NIL
        ENDIF
        AlgSndDeallocateVoice( allegro_voices[ i + 1 ] )
        allegro_voices[ i + 1 ] := -1
    NEXT

    AlgSndDestroySample( dummy_sample )
    dummy_sample := NIL

    AlgSndRemoveSound()
    sound_initialized := .F.
RETURN NIL

STATIC FUNCTION I_Allegro_InitSound( lUsePrefix )
    LOCAL i
    LOCAL nErr

    use_sfx_prefix := lUsePrefix

    FOR i := 0 TO NUM_CHANNELS - 1
        channels_playing[ i + 1 ] := NIL
    NEXT

    AlgSndReserveVoices( NUM_CHANNELS, NUM_MIDI_CHANNELS )

    nErr := AlgSndInstall( "allegro.cfg" )
    IF nErr < 0
        OutStd( "install_sound failed: " + hb_ntos( nErr ) + ' "' + AlgSndError() + '"' + hb_eol() )
        RETURN .F.
    ENDIF

    OutStd( "Allegro sound initialized" + hb_eol() )
    OutStd( "Mixer quality " + hb_ntos( AlgSndMixerQuality() ) + hb_eol() )
    OutStd( "Mixer freq " + hb_ntos( AlgSndMixerFreq() ) + hb_eol() )
    OutStd( "Mixer bits " + hb_ntos( AlgSndMixerBits() ) + hb_eol() )
    OutStd( "Mixer channels " + hb_ntos( AlgSndMixerChannels() ) + hb_eol() )
    OutStd( "Mixer voices " + hb_ntos( AlgSndMixerVoices() ) + hb_eol() )
    OutStd( "Mixer buffer length " + hb_ntos( AlgSndMixerBuffer() ) + hb_eol() )

    dummy_sample := AlgSndCreateSample( 8, 0, 11025, 8 )
    IF dummy_sample == NIL
        OutStd( "Failed to create sound sample: " + AlgSndError() + hb_eol() )
        RETURN .F.
    ENDIF

    FOR i := 0 TO NUM_CHANNELS - 1
        allegro_voices[ i + 1 ] := AlgSndAllocateVoice( dummy_sample )
    NEXT

    sound_initialized := .T.
RETURN .T.

#pragma BEGINDUMP
#include "hbapi.h"
#include "hbapiitm.h"
#include <string.h>

#define ALLEGRO_NO_KEY_DEFINES 1
#include <allegro.h>

#ifdef uint32_t
#undef uint32_t
#endif

HB_FUNC( ALGSNDRESERVEVOICES )
{
   reserve_voices( hb_parni( 1 ), hb_parni( 2 ) );
}

HB_FUNC( ALGSNDINSTALL )
{
   hb_retni( install_sound( DIGI_AUTODETECT, MIDI_AUTODETECT, hb_parc( 1 ) ) );
}

HB_FUNC( ALGSNDERROR )
{
   hb_retc( allegro_error );
}

HB_FUNC( ALGSNDMIXERQUALITY )
{
   hb_retni( get_mixer_quality() );
}

HB_FUNC( ALGSNDMIXERFREQ )
{
   hb_retni( get_mixer_frequency() );
}

HB_FUNC( ALGSNDMIXERBITS )
{
   hb_retni( get_mixer_bits() );
}

HB_FUNC( ALGSNDMIXERCHANNELS )
{
   hb_retni( get_mixer_channels() );
}

HB_FUNC( ALGSNDMIXERVOICES )
{
   hb_retni( get_mixer_voices() );
}

HB_FUNC( ALGSNDMIXERBUFFER )
{
   hb_retni( get_mixer_buffer_length() );
}

HB_FUNC( ALGSNDCREATESAMPLE )
{
   SAMPLE *s;

   s = create_sample( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) );
   if( s == NULL )
      hb_ret();
   else
      hb_retptr( s );
}

HB_FUNC( ALGSNDCREATESFXSAMPLE )
{
   const char *data;
   HB_SIZE len;
   SAMPLE *s;

   data = hb_parc( 1 );
   len = hb_parclen( 1 );
   s = create_sample( 8, 0, hb_parni( 2 ), ( int ) len );
   if( s == NULL )
   {
      hb_ret();
      return;
   }
   if( s->data != NULL && data != NULL && len > 0 )
      memcpy( s->data, data, ( size_t ) len );
   hb_retptr( s );
}

HB_FUNC( ALGSNDDESTROYSAMPLE )
{
   SAMPLE *s = ( SAMPLE * ) hb_parptr( 1 );

   if( s )
      destroy_sample( s );
}

HB_FUNC( ALGSNDALLOCATEVOICE )
{
   hb_retni( allocate_voice( ( SAMPLE * ) hb_parptr( 1 ) ) );
}

HB_FUNC( ALGSNDDEALLOCATEVOICE )
{
   deallocate_voice( hb_parni( 1 ) );
}

HB_FUNC( ALGSNDREALLOCATEVOICE )
{
   reallocate_voice( hb_parni( 1 ), ( SAMPLE * ) hb_parptr( 2 ) );
}

HB_FUNC( ALGSNDVOICESETVOLUME )
{
   voice_set_volume( hb_parni( 1 ), hb_parni( 2 ) );
}

HB_FUNC( ALGSNDVOICESETPAN )
{
   voice_set_pan( hb_parni( 1 ), hb_parni( 2 ) );
}

HB_FUNC( ALGSNDVOICESTART )
{
   voice_start( hb_parni( 1 ) );
}

HB_FUNC( ALGSNDVOICESTOP )
{
   voice_stop( hb_parni( 1 ) );
}

HB_FUNC( ALGSNDVOICEGETPOS )
{
   hb_retni( voice_get_position( hb_parni( 1 ) ) );
}

HB_FUNC( ALGSNDREMOVESOUND )
{
   remove_sound();
}

#pragma ENDDUMP
