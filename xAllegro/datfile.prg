#pragma BEGINDUMP

#include <math.h>
#include <allegro.h>
#include <hbapi.h>

/*
   Abre um arquivo DAT sem password.
   Exemplo: datafile = load_datafile("windowsvista.dat")
*/
HB_FUNC(LOAD_DATAFILE)
{
	hb_retnl((HB_ULONG)load_datafile(hb_parc(1)));
}

/*
   Abre um arquivo DAT com password.
   Exemplo: datafile = load_datafile_passwd("windowsvista.dat","newcode2905")
*/
HB_FUNC(LOAD_DATAFILE_PASSWD)
{
	DATAFILE *data;
        packfile_password(hb_parc(2));
	data=load_datafile(hb_parc(1));
	packfile_password(NULL);
	hb_retnl((HB_ULONG)data);
}

/*
   Busca um determinado BITMAP dentro do arquivo DAT pelo indice. O programa GRABBER ja cria o indice automaticamente
   ao salvar o arquivo DAT.
   Exemplo: #define BUTTON_OFF_MEANS	0	// BMP
            datafile = load_datafile_passwd("windowsvista.dat","newcode2905")
            teste    = datafile_image(datafile,BUTTON_OFF_MEANS)
            _draw_sprite(_get_screen(),teste,16,161)
            unload_datafile(datafile)
*/
HB_FUNC(DATAFILE_IMAGE)
{
	  DATAFILE *data;
	  BITMAP *img;
	  data=(DATAFILE *)hb_parnl(1);
	  img=(BITMAP *)data[hb_parnl(2)].dat;
	  hb_retnl((HB_ULONG)img);
}

/*
   Fecha um arquivo DAT aberto.
   Exemplo: unload_datafile(datafile)
*/
HB_FUNC(UNLOAD_DATAFILE)
{
	unload_datafile((DATAFILE *)hb_parnl(1));
}

#pragma ENDDUMP