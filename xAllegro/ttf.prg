#pragma BEGINDUMP
//#define ALLEGTTF_NOSMOOTH    0
//#define ALLEGTTF_TTFSMOOTH   1
//#define ALLEGTTF_REALSMOOTH  2

#include "allegttf.h"
#include "hbapi.h"

HB_FUNC(_LOAD_TTF_FONT)
{
   char *cFilename;
   int point;
   int OPT;
   FONT *Fnt;
   cFilename=hb_parc(1);
   point=hb_parni(2);
   OPT=hb_parni(3);
   Fnt=load_ttf_font(cFilename,point,OPT);
   hb_retnl((HB_ULONG)Fnt);
}

//FONT* load_ttf_font_ex (const char* filename, const int points_w, const int points_h, const int smooth) 
HB_FUNC(_LOAD_TTF_FONT_EX)
{
   char *cFilename;
   int pointw;
   int pointh;
   int OPT;
   FONT *Fnt;
   cFilename=hb_parc(1);
   pointw=hb_parni(2);
   pointh=hb_parni(3);
   OPT=hb_parni(4);
   Fnt=load_ttf_font_ex(cFilename,pointw,pointh,OPT);
   hb_retnl((HB_ULONG)Fnt);
}


HB_FUNC(_DESTROY_FONT)
{
   FONT *Fnt=(FONT *)hb_parnl(1);
   destroy_font(Fnt);
}

HB_FUNC(_READ_HEIGHT_PROPERTY)
{
   FONT *Fnt=(FONT *)hb_parnl(1);
   hb_retnl(Fnt->height)   ;
}
HB_FUNC(_TEXT_LENGHT)
{
   FONT *Fnt=(FONT *)hb_parnl(1);
   char *cTexto=hb_parc(2);
   hb_retni(text_length(Fnt,cTexto));
}

HB_FUNC(TEXT_MODE)
{
   text_mode(hb_parnl(1));
}

HB_FUNC(_AATEXTOUT)
{
   BITMAP *bmp=(BITMAP *)hb_parnl(1);
   FONT *font=(FONT *)hb_parnl(2);
   char *string=(char *)hb_parc(3);
   int x=hb_parni(4);
   int y=hb_parni(5);
   int colour=hb_parni(6);
   aatextout(bmp,font,string,x,y,colour);
}

HB_FUNC(_AATEXTOUT_CENTER)
{
   BITMAP *bmp=(BITMAP *)hb_parnl(1);
   FONT *font=(FONT *)hb_parnl(2);
   char *string=(char *)hb_parc(3);
   int x=hb_parni(4);
   int y=hb_parni(5);
   int colour=hb_parni(6);
   aatextout_center(bmp,font,string,x,y,colour);
}

HB_FUNC(_AATEXTOUT_RIGHT)
{
   BITMAP *bmp=(BITMAP *)hb_parnl(1);
   FONT *font=(FONT *)hb_parnl(2);
   char *string=(char *)hb_parc(3);
   int x=hb_parni(4);
   int y=hb_parni(5);
   int colour=hb_parni(6);
   aatextout_right(bmp,font,string,x,y,colour);
}