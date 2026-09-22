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

#include "doomgeneric.ch"
#include "llibg.ch"

REQUEST HB_GT_ALLEG
REQUEST HB_GT_ALLEG_DEFAULT

PROCEDURE Main()

    config_driver( GFX_DIRECTX_WIN )
    config_lib( 32, 640, 480 )
    SetMode( 30, 80 )
    _set_window_title( "DOOM" )

    doom_hb_Create()

    DO WHILE .T.
        doomgeneric_Tick()
    ENDDO

RETURN
