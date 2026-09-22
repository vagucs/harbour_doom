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

STATIC deh_allow_extended_strings
STATIC deh_allow_long_strings
STATIC deh_allow_long_cheats
STATIC deh_apply_cheats

#include "deh_main.ch"


INIT PROCEDURE init_deh_main


    deh_allow_extended_strings := .F.
    deh_allow_long_strings := .F.
    deh_allow_long_cheats := .F.
    deh_apply_cheats := .T.
RETURN

/* FEATURE_DEHACKED esta desligado neste port; rotinas sao stubs. */

FUNCTION DEH_ParseCommandLine()
RETURN NIL

FUNCTION DEH_LoadFile( filename )
    HB_SYMBOL_UNUSED( filename )
RETURN 0

FUNCTION DEH_LoadLump( lumpnum, allow_long, allow_error )
    HB_SYMBOL_UNUSED( lumpnum )
    HB_SYMBOL_UNUSED( allow_long )
    HB_SYMBOL_UNUSED( allow_error )
RETURN 0

FUNCTION DEH_LoadLumpByName( name, allow_long, allow_error )
    HB_SYMBOL_UNUSED( name )
    HB_SYMBOL_UNUSED( allow_long )
    HB_SYMBOL_UNUSED( allow_error )
RETURN 0

FUNCTION DEH_ParseAssignment( line, variable_name, value )
    HB_SYMBOL_UNUSED( line )
    variable_name := NIL
    value := NIL
RETURN .F.

FUNCTION DEH_Checksum( digest )
    HB_SYMBOL_UNUSED( digest )
RETURN NIL
