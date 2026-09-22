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

#include "deh_misc.ch"

#ifdef FEATURE_DEHACKED
INIT PROCEDURE init_deh_misc

    PUBLIC deh_initial_health
    PUBLIC deh_initial_bullets
    PUBLIC deh_max_health
    PUBLIC deh_max_armor
    PUBLIC deh_green_armor_class
    PUBLIC deh_blue_armor_class
    PUBLIC deh_max_soulsphere
    PUBLIC deh_soulsphere_health
    PUBLIC deh_megasphere_health
    PUBLIC deh_god_mode_health
    PUBLIC deh_idfa_armor
    PUBLIC deh_idfa_armor_class
    PUBLIC deh_idkfa_armor
    PUBLIC deh_idkfa_armor_class
    PUBLIC deh_bfg_cells_per_shot
    PUBLIC deh_species_infighting

    deh_initial_health      := DEH_DEFAULT_INITIAL_HEALTH
    deh_initial_bullets     := DEH_DEFAULT_INITIAL_BULLETS
    deh_max_health          := DEH_DEFAULT_MAX_HEALTH
    deh_max_armor           := DEH_DEFAULT_MAX_ARMOR
    deh_green_armor_class   := DEH_DEFAULT_GREEN_ARMOR_CLASS
    deh_blue_armor_class    := DEH_DEFAULT_BLUE_ARMOR_CLASS
    deh_max_soulsphere      := DEH_DEFAULT_MAX_SOULSPHERE
    deh_soulsphere_health   := DEH_DEFAULT_SOULSPHERE_HEALTH
    deh_megasphere_health   := DEH_DEFAULT_MEGASPHERE_HEALTH
    deh_god_mode_health     := DEH_DEFAULT_GOD_MODE_HEALTH
    deh_idfa_armor          := DEH_DEFAULT_IDFA_ARMOR
    deh_idfa_armor_class    := DEH_DEFAULT_IDFA_ARMOR_CLASS
    deh_idkfa_armor         := DEH_DEFAULT_IDKFA_ARMOR
    deh_idkfa_armor_class   := DEH_DEFAULT_IDKFA_ARMOR_CLASS
    deh_bfg_cells_per_shot  := DEH_DEFAULT_BFG_CELLS_PER_SHOT
    deh_species_infighting  := DEH_DEFAULT_SPECIES_INFIGHTING
RETURN
#endif
