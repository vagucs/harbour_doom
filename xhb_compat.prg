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

FUNCTION hb_qbitAnd( n1, n2 )
RETURN hb_bitAnd( n1, n2 )

FUNCTION hb_qbitOr( n1, n2 )
RETURN hb_bitOr( n1, n2 )

FUNCTION hb_qbitXor( n1, n2 )
RETURN hb_bitXor( n1, n2 )

FUNCTION hb_qbitNot( n1 )
RETURN hb_bitNot( n1 )

FUNCTION hb_stricmp( s1, s2 )
    LOCAL a := Lower( iif( s1 == NIL, "", s1 ) )
    LOCAL b := Lower( iif( s2 == NIL, "", s2 ) )
    IF a == b
        RETURN 0
    ENDIF
RETURN iif( a < b, -1, 1 )

FUNCTION hb_strnicmp( s1, s2, nLen )
    IF nLen == NIL
        nLen := Max( Len( iif( s1 == NIL, "", s1 ) ), Len( iif( s2 == NIL, "", s2 ) ) )
    ENDIF
RETURN hb_stricmp( Left( iif( s1 == NIL, "", s1 ), nLen ), Left( iif( s2 == NIL, "", s2 ), nLen ) )

FUNCTION LONG( n )
RETURN Int( n )
