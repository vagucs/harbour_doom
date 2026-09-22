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

#include "p_tick.ch"
#include "p_local.ch"
#include "d_player.ch"
#include "doomstat.ch"
#include "doomdef.ch"


PROCEDURE P_InitThinkers()
    MEMVAR thinkercap
    thinkercap:prev := thinkercap
    thinkercap:next := thinkercap
RETURN

PROCEDURE P_AddThinker( thinker )
    MEMVAR thinkercap
    thinkercap:prev:next := thinker
    thinker:next := thinkercap
    thinker:prev := thinkercap:prev
    thinkercap:prev := thinker
RETURN

PROCEDURE P_RemoveThinker( thinker )
    thinker:function:acv := -1
RETURN

PROCEDURE P_AllocateThinker( thinker )
    HB_SYMBOL_UNUSED( thinker )
RETURN

STATIC FUNCTION IfaceCall( xFun, x1, x2 )
    LOCAL nArgs := PCount() - 1

    IF xFun == NIL
        RETURN NIL
    ENDIF

    IF ValType( xFun ) == "B"
        IF nArgs <= 0
            RETURN Eval( xFun )
        ELSEIF nArgs == 1
            RETURN Eval( xFun, x1 )
        ENDIF
        RETURN Eval( xFun, x1, x2 )
    ENDIF

    IF ValType( xFun ) == "C"
        IF nArgs <= 0
            RETURN &( xFun )()
        ELSEIF nArgs == 1
            RETURN &( xFun )( x1 )
        ENDIF
        RETURN &( xFun )( x1, x2 )
    ENDIF
RETURN NIL

STATIC FUNCTION IsRemovedThinker( thinker )
    LOCAL x

    IF thinker == NIL .OR. thinker:function == NIL
        RETURN .F.
    ENDIF
    x := thinker:function:acv
RETURN ValType( x ) == "N" .AND. x == -1

STATIC PROCEDURE RunThinkerFn( currentthinker )
    LOCAL x

    IF currentthinker:function == NIL
        RETURN
    ENDIF
    x := currentthinker:function:acp1
    IF ValType( x ) == "B"
        Eval( x )
    ELSEIF ValType( x ) == "C" .AND. ! Empty( x )
        IF currentthinker:owner != NIL
            IfaceCall( x, currentthinker:owner )
        ELSE
            IfaceCall( x, currentthinker )
        ENDIF
    ENDIF
RETURN

PROCEDURE P_RunThinkers()
    LOCAL currentthinker
    LOCAL nextthinker
    MEMVAR thinkercap

    currentthinker := thinkercap:next
    DO WHILE currentthinker != NIL .AND. !( currentthinker == thinkercap )
        nextthinker := currentthinker:next
        IF IsRemovedThinker( currentthinker )
            IF currentthinker:next != NIL
                currentthinker:next:prev := currentthinker:prev
            ENDIF
            IF currentthinker:prev != NIL
                currentthinker:prev:next := currentthinker:next
            ENDIF
        ELSE
            RunThinkerFn( currentthinker )
        ENDIF
        currentthinker := nextthinker
    ENDDO
RETURN

PROCEDURE P_Ticker()
    LOCAL i
    MEMVAR consoleplayer
    MEMVAR demoplayback
    MEMVAR leveltime
    MEMVAR menuactive
    MEMVAR netgame
    MEMVAR paused
    MEMVAR playeringame
    MEMVAR players

    IF paused
        RETURN
    ENDIF

    IF ! netgame ;
         .AND. menuactive != 0 ;
         .AND. ! demoplayback ;
         .AND. players[ consoleplayer + 1 ]:viewz != 1
        RETURN
    ENDIF

    FOR i := 0 TO MAXPLAYERS - 1
        IF playeringame[ i + 1 ]
            P_PlayerThink( players[ i + 1 ] )
        ENDIF
    NEXT

    P_RunThinkers()
    P_UpdateSpecials()
    P_RespawnSpecials()

    leveltime++
RETURN

INIT PROCEDURE init_p_tick
    PUBLIC thinkercap
    PUBLIC leveltime

    thinkercap := thinker_t():New()
    thinkercap:prev := thinkercap
    thinkercap:next := thinkercap
    leveltime := 0
RETURN
