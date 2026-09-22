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

#include "deh_str.ch"

#undef DEH_String
#undef DEH_AddStringReplacement

FUNCTION DEH_String( s )
    /* Sem tabela de replacement neste port; identidade. */
RETURN s

FUNCTION DEH_AddStringReplacement( from_text, to_text )
    HB_SYMBOL_UNUSED( from_text )
    HB_SYMBOL_UNUSED( to_text )
RETURN NIL

FUNCTION DEH_printf( cText )
    IF cText != NIL
        OutStd( cText )
    ENDIF
RETURN NIL

FUNCTION DEH_fprintf( xHandle, cText )
    IF cText == NIL
        RETURN NIL
    ENDIF
    IF ValType( xHandle ) == "N"
        FWrite( xHandle, cText )
    ELSE
        OutStd( cText )
    ENDIF
RETURN NIL

FUNCTION DEH_snprintf( buffer, nLen, cText )
    LOCAL cOut

    cOut := iif( cText == NIL, "", cText )
    IF ValType( nLen ) == "N" .AND. nLen > 0
        cOut := Left( cOut, nLen - 1 )
    ENDIF
    buffer := cOut
RETURN Len( cOut )
