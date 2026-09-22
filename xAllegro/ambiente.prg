procedure CONFIG_LIB(p1,p2,p3,p4,p5)
request HB_GT_ALLEG_DEFAULT
return _config_lib(p1,p2,p3,p4,p5)

procedure config_driver(string)
__config_driver(asc(substr(string,1,1)),asc(substr(string,2,1)),asc(substr(string,3,1)),asc(substr(string,4,1)))

#pragma BEGINDUMP

#include <math.h>
#include <allegro.h>
#include <hbapi.h>
/*
   Altera o titulo da janela, quando o padrão na GT for por exemplo GFX_AUTODETECT_WINDOWED.
   Devem ser feitas alteração na GTALLEG na linha (iRet = al_set_gfx_mode( GFX_AUTODETECT_FULLSCREEN, num_col, num_lin, 0, 0 );)
   Exemplo: _set_window_title("Titulo da janela")
*/
HB_FUNC(_SET_WINDOW_TITLE)
{
	  set_window_title(hb_parc(1));
}

/*
   Exibe caixa de mensagem da propria allegro.
   Exemplo: _allegro_message("Teste de mensagem")
*/
HB_FUNC(_ALLEGRO_MESSAGE)
{
//	allegro_message((HB_ULONG)hb_parc(1));
}

/*
   Alert da propia allegro com botoes.
   Exemplos:
   _alert3("Mensagem 1","Mensagem 2","Mensagem3","&Sim","&Não","&Cancelar",'s','n','c')
   _alert3("Mensagem 1","Mensagem 2","Mensagem3","&Sim","&Não",nil,'s','n',0)
*/
HB_FUNC(_ALERT3)
{
	hb_retnl(alert3(hb_parc(1),hb_parc(2),hb_parc(3),hb_parc(4),hb_parc(5),hb_parc(6),hb_parnl(7),hb_parnl(8),hb_parnl(9)));
}

HB_FUNC(SET_DISPLAY_SWITCH_MODE)
{
   hb_retni(set_display_switch_mode(hb_parni(1)));
}

HB_FUNC(GET_DESKTOP_RESOLUTION)
{
   int width, height, nret;
   nret=get_desktop_resolution(&width, &height);
   hb_storni(width,1);
   hb_storni(height,2);
   hb_retni(nret);
}
#pragma ENDDUMP