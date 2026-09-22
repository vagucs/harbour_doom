#define ALLEGTTF_NOSMOOTH    0
#define ALLEGTTF_TTFSMOOTH   1
#define ALLEGTTF_REALSMOOTH  2

#include "inkey.ch"
#include "llibg.ch"
#include "common.ch"
#include "setcurs.ch"

procedure main
local screen,imagem
SET EVENTMASK TO INKEY_ALL
config_driver(GFX_DIRECTX_WIN)
config_lib(32,800,600)
setmode(30,80)
w=0
h=0
GET_DESKTOP_RESOLUTION(@w,@h)
? w
? h
h=_load_bitmap("teste.png")
? h
screen:=bitmap():new(,,,,.t.)
imagem:=bitmap():new("teste.png")         
? "Handle:",imagem
draw_sprite(screen,imagem,0,100)
inkey(0)
quit

//
////unscare_mouse()
////hide_mouse()
////DIRECTX_ENABLE_CURSOR()
////enable_HARDWARE_CURSOR()
////? SHOW_OS_CURSOR(2)
////wag:="wagner"
////cfile="teste.prg"
////cFile := HB_COMPILEBUF( 0, , "-w", , "-q0",, cFile )
////IF cFile == NIL
////   ERRORLEVEL( 1 )
////ELSE
////alerT("rpodando")
//	//hb_hrbRun( cFile )
////ENDIF
//
//do while lastkey()#27
//   @ 1,10 say LEFT_MOUSE_BUTTON()
//   @ 2,10 say MIDDLE_MOUSE_BUTTON()
//   @ 3,10 say RIGHT_MOUSE_BUTTON()
//   @ 5,10 say mouse_Driver()
//   @ 8,10 say mrow()
//   
//   @ 9,10 say mcol()
//
//   
//   @ 10,10 say inkey(0)
//enddo
////quit
//
//   WHILE ( .T. )
//      nKey := INKEY()
//      @ 10,10 say nKey
//      nStatus := KBDSTAT()
//       
//      @ 11,10 SAY IIF( ISBIT( nStatus, 1 ), "SHIFT", SPACE(20) )
//      @ 12,10 SAY IIF( ISBIT( nStatus, 3 ), "CTRL", SPACE(20) )
//      @ 13,10 SAY IIF( ISBIT( nStatus, 4 ), "ALT", SPACE(20) )
//      @ 14,10 SAY IIF( ISBIT( nStatus, 5 ), "SCROLL LOCK ON", SPACE(20) )
//      @ 15,10 SAY IIF( ISBIT( nStatus, 6 ), "NUM LOCK ON", SPACE(20) )
//      @ 16,10 SAY IIF( ISBIT( nStatus, 7 ), "CAPS LOCK ON", SPACE(20) )
//      @ 17,10 SAY IIF( ISBIT( nStatus, 8 ), "INSERT ON", SPACE(20) )
//      
//      IF ( nKey == K_ESC )
//         EXIT
//      ENDIF
//   END
//   
//   WHILE ( .T. )
//      nKey := INKEY()
//      IF ( nKey # 0 )
//         ?? "key: " + ALLTRIM( STR( nKey ) ) + ", status: " + ALLTRIM( STR( KbdStat() ) ) ; ?
//         IF ( nKey == K_ESC )
//            EXIT
//         ELSE
//            ?? "key: " + ALLTRIM( STR( nKey ) ) ; ?
//         ENDIF
//      ENDIF
//   END
   
//   //quit
//? makecol(  0,255,255)
//? makecol(  0,  0,  0)
//? makecol(  0,  0,255)
//? makecol(128,128,128)
//? makecol(255,  0,255)
//? makecol(128,128,128)
//? makecol(  0,128,  0)
//? makecol(  0,255,  0)
//? makecol(192,192,192)
//? makecol(128,  0,  0)
//? makecol(  0,  0,128)
//? makecol(  0,128,128)
//? makecol(128,  0,128)
//? makecol(255,  0,  0)
//? makecol(192,192,192)
//? makecol(128,128,  0)
//? makecol(255,255,255)
//? makecol(255,255,  0)
//inkey(0)
//? "Tamanho da tela:",screen:w,"x",screen:h
imagem:=bitmap():new("teste.png")
////_set_clip_rect(imagem:nHandle,10,10,5,5)
//x1=0
//y1=0
//x2=0
//y2=0
////_get_clip_rect(imagem:nHandle,@x1,@y1,@x2,@y2)
//? "X:",x1
//? "Y:",y1
//? "X2:",x2
//? "Y2:",y2
//inkey(0)
font=_load_ttf_font("dejavusans.ttf",10,ALLEGTTF_TTFSMOOTH)
_aatextout(screen:nHandle,font,"Wagner Nunes",200,200,makecol(255,255,255))
alert(_text_lenght(font,"Wagner"))
? "TESTE.PNG"
? imagem:w
? imagem:h
draw_sprite(screen,imagem,0,100)
putpixel(screen,200,200,makecol(255,255,255))
rectfill(screen,10,10,100,100,makecol(255,255,255))
arc(screen,320,240,itofix(-21),itofix(43),50,makecol(255,255,255))
aFnt:=fnt():new("arial10.fnt")
var=aFnt:StringLen("Wagner Nunes")
alert(var)
inkey(0)
clear
for i=1 to 10
   aFnt:DrawString(screen,150+(i*10),150+(i*10),"Wagner Nunes",makecol(255,255,255),makecol(33,33,33))
next
inkey(0)
clear
fnt2=fnt():new("decor.fnt")
for i=1 to 255
   Fnt2:DrawString(screen,150,150,chr(i),makecol(255,255,255),makecol(33,33,33))
   inkey(0)
   clear
next
imagem:destroy()


procedure ale
alert(wag)
