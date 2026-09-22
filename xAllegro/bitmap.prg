#include "hbclass.ch"

CLASS BITMAP
   METHOD New(cArquivo,nW,nH,nBits,lScreen)
   METHOD Destroy
   METHOD w // Largura do bitmap
   METHOD h // Altura do bitmapï
   METHOD clip // Se est  com clipping ativado ou nÆo
   METHOD cl
   METHOD cr
   METHOD ct
   METHOD cb // Area do clipping coluna, linha, linha baixo, direita
   METHOD line // Area da imagem
   VAR nHandle INIT 0
END CLASS

METHOD NEW(cArquivo,nW,nH,nBits,lScreen) CLASS BITMAP
if lScreen=Nil
   if !(cArquivo=Nil)
      if file(cArquivo)
         ::nHandle=_load_bitmap(cArquivo)
      end if
   else
      if !(nW=Nil .or. nH=Nil)
         if nBits=Nil
            ::nHandle=_create_bitmap(nW,nH)
         else
            ::nHandle=_create_bitmap_ex(nBits,nW,nH)
         end if
      end if
   end if
else
   ::nHandle=_get_screen()
end if
return self

METHOD Destroy CLASS BITMAP
if ::nHandle>0
   if ::nHandle#_get_screen()
      _destroy_bitmap(::nHandle)
   end if
end if
::nHandle=0
return .t.

METHOD w CLASS BITMAP
if ::nHandle>0
   return _get_w_bitmap(::nHandle)
end if
return 0

METHOD h CLASS BITMAP
if ::nHandle>0
   return _get_h_bitmap(::nHandle)
end if
return 0

METHOD clip CLASS BITMAP
if ::nHandle>0
   return _get_clip_bitmap(::nHandle)
end if
return .f.

METHOD cl CLASS BITMAP
if ::nHandle>0
   return _get_cl_bitmap(::nHandle)
end if
return 0

METHOD cr CLASS BITMAP
if ::nHandle>0
   return _get_cr_bitmap(::nHandle)
end if
return 0


METHOD ct CLASS BITMAP
if ::nHandle>0
   return _get_ct_bitmap(::nHandle)
end if
return 0


METHOD cb CLASS BITMAP
if ::nHandle>0
   return _get_cb_bitmap(::nHandle)
end if
return 0


METHOD line CLASS BITMAP
if ::nHandle>0
   return _get_line_bitmap(::nHandle)
end if
return ""

/*             Rotinas diversas para se trabalhar com BITMAP */

procedure draw_sprite(destino,imagem,coluna,linha)
if valtype(destino)=[O] .and. valtype(imagem)=[O]
   if destino:nHandle>0 .and. imagem:nHandle>0 .and. valtype(coluna)=[N] .and. valtype(linha)=[N]
      _draw_sprite(destino:nHandle,imagem:nHandle,coluna,linha)
   end if
end if
return Nil

#pragma BEGINDUMP

#include <math.h>
#include <allegro.h>
#include <hbapi.h>

HB_FUNC(_GET_CLIP_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retl(temp->clip);
}

HB_FUNC(_GET_LINE_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retc((char *)temp->line);
}

HB_FUNC(_GET_CB_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retnl((HB_ULONG)temp->cb);
}

HB_FUNC(_GET_CT_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retnl((HB_ULONG)temp->ct);
}

HB_FUNC(_GET_CL_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retnl((HB_ULONG)temp->cl);
}

HB_FUNC(_GET_CR_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retnl((HB_ULONG)temp->cr);
}

HB_FUNC(_GET_H_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retnl((HB_ULONG)temp->h);
}

HB_FUNC(_GET_W_BITMAP) // Ok
{
    BITMAP *temp;
    temp=(BITMAP *)hb_parnl(1);
    hb_retnl((HB_ULONG)temp->w);
}

HB_FUNC(_CREATE_BITMAP){ // Ok
   BITMAP *temp;
   temp=create_bitmap(hb_parnl(1),hb_parnl(2));
   hb_retnl((HB_ULONG)temp);
}

HB_FUNC(_CREATE_BITMAP_EX){ // Ok
   BITMAP *temp;
   temp=create_bitmap_ex(hb_parnl(1),hb_parnl(2),hb_parnl(3));
   hb_retnl((HB_ULONG)temp);
}

HB_FUNC(_DESTROY_BITMAP){ // Ok
   destroy_bitmap((BITMAP *)hb_parnl(1));
}

HB_FUNC(_LOAD_BITMAP){ // Ok
   PALETTE pal;
   hb_retnl((HB_ULONG)load_bitmap(hb_parc(1),pal));
}

HB_FUNC(_GET_SCREEN){
   hb_retnl((HB_ULONG) screen);
}

HB_FUNC(_DRAW_SPRITE){
   BITMAP *dest;
   BITMAP *font;
   int x,y;
   dest=(BITMAP *)hb_parnl(1);
   font=(BITMAP *)hb_parnl(2);
   y=hb_parnl(3);
   x=hb_parnl(4);
   draw_sprite(dest,font,y,x);
}

HB_FUNC(_SET_CLIP_RECT)
{
   int x1,y1,x2,y2;
   BITMAP *bmp;
   bmp=(BITMAP *)hb_parnl(1);
   x1=hb_parni(2);
   y1=hb_parni(3);
   x2=hb_parni(4);
   y2=hb_parni(5);
   set_clip_rect(bmp,x1,y1,x2,y2);
}

HB_FUNC(_SET_CLIP_STATE)
{
   BITMAP *bmp;
   bmp=(BITMAP *)hb_parnl(1);
   set_clip_state(bmp,hb_parni(2));
}

HB_FUNC(_GET_CLIP_STATE)
{
   BITMAP *bmp;
   bmp=(BITMAP *)hb_parnl(1);
   hb_retni(get_clip_state(bmp));
}

HB_FUNC(_GET_CLIP_RECT)
{
   int x1,y1,x2,y2;
   BITMAP *bmp;
   bmp=(BITMAP *)hb_parnl(1);
   get_clip_rect(bmp,&x1,&y1,&x2,&y2);
   hb_storni((int)x1,2);
   hb_storni((int)y1,3);
   hb_storni((int)x2,4);
   hb_storni((int)y2,5);
}

HB_FUNC(_BLIT){
    BITMAP *dest=(BITMAP *)hb_parnl(1);
    BITMAP *source=(BITMAP *)hb_parnl(2);
    int x=hb_parni(3);
    int y=hb_parni(4);
    int xi=hb_parni(5);
    int yi=hb_parni(6);
    int xie=hb_parni(7);
    int yie=hb_parni(8);
    blit(dest,source,x,y,xi,yi,xie,yie);
}

//pivot_sprite(BITMAP *bmp, BITMAP *sprite, int x, int y, int cx, int cy, fixed angle);
HB_FUNC(_PIVOT_SPRITE)
{
    BITMAP *dest=(BITMAP *)hb_parnl(1);
    BITMAP *source=(BITMAP *)hb_parnl(2);
    int x=hb_parni(3);
    int y=hb_parni(4);
    int cx=hb_parni(5);
    int cy=hb_parni(6);
    int angle=hb_parni(7);
    pivot_sprite(dest,source,x,y,cx,cy,itofix(angle));
}

// rotate_sprite(BITMAP *bmp, BITMAP *sprite, int x, int y, fixed angle);
HB_FUNC(_ROTATE_SPRITE)
{
    BITMAP *dest=(BITMAP *)hb_parnl(1);
    BITMAP *source=(BITMAP *)hb_parnl(2);
    int x=hb_parni(3);
    int y=hb_parni(4);
    int angle=hb_parni(5);
    rotate_sprite(dest,source,x,y,itofix(angle));
}



#pragma ENDDUMP