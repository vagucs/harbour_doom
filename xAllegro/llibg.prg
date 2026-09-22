#include "llibg.ch"
static aModes:={;                          // Bits-W -H -L   -C -G
               {LLG_VIDEO_TXT               , 8, 640, 480, 80,25,0},;
               {LLG_VIDEO_VESA_TXT_80_60    , 8, 640, 480, 80,60,0},;
               {LLG_VIDEO_VESA_TXT_132_25   , 8, 640, 480,132,25,0},;
               {LLG_VIDEO_VESA_TXT_132_43   , 8, 640, 480,132,50,0},;
               {LLG_VIDEO_VESA_TXT_132_50   , 8, 640, 480,132,50,0},;
               {LLG_VIDEO_VESA_TXT_132_60   , 8, 640, 480,132,60,0},;
               {LLG_VIDEO_VGA_640_480_16    ,16, 640, 480, 80,30,1},;
               {LLG_VIDEO_VESA_800_592_16   ,16, 800, 592, 80,30,1},;
               {LLG_VIDEO_VESA_1024_768_16  ,16,1024, 768, 80,30,1},;
               {LLG_VIDEO_VESA_1280_1024_16 ,16,1280,1024, 80,30,1},;
               {LLG_VIDEO_VESA_640_480_256  ,16, 640, 480, 80,30,1},;
               {LLG_VIDEO_VESA_800_592_256  ,16, 800, 592, 80,30,1},;
               {LLG_VIDEO_VESA_1024_768_256 ,16,1024, 768, 80,30,1},;
               {LLG_VIDEO_VESA_1280_1024_256,16,1280,1024, 80,30,1},;
               {LLG_VIDEO_VESA_640_480_32K  ,24, 640, 480, 80,30,1},;
               {LLG_VIDEO_VESA_800_592_32K  ,24, 800, 592, 80,30,1},;
               {LLG_VIDEO_VESA_1024_768_32K ,24,1024, 768, 80,30,1},;
               {LLG_VIDEO_VESA_1280_1024_32K,24,1280,1024, 80,30,1},;
               {LLG_VIDEO_VESA_640_480_32K  ,24, 640, 480, 80,30,1},;
               {LLG_VIDEO_VESA_800_592_32K  ,24, 800, 592, 80,30,1},;
               {LLG_VIDEO_VESA_1024_768_32K ,24,1024, 768, 80,30,1},;
               {LLG_VIDEO_VESA_1280_1024_32K,24,1280,1024, 80,30,1},;
               {LLG_VIDEO_VESA_640_480_64K  ,24, 640, 480, 80,30,1},;
               {LLG_VIDEO_VESA_800_592_64K  ,24, 800, 592, 80,30,1},;
               {LLG_VIDEO_VESA_1024_768_64K ,24,1024, 768, 80,30,1},;
               {LLG_VIDEO_VESA_1280_1024_64K,24,1280,1024, 80,30,1},;
               {LLG_VIDEO_VESA_640_480_16M  ,24, 640, 480, 80,30,1},;
               {LLG_VIDEO_VESA_800_592_16M  ,24, 800, 592, 80,30,1},;
               {LLG_VIDEO_VESA_1024_768_16M ,24,1024, 768, 80,30,1},;
               {LLG_VIDEO_VESA_1280_1024_16M,24,1280,1024, 80,30,1},;
               }
static Modo_atual:=LLG_VIDEO_TXT,Ultimo_modo:=0,Mouse_clip:={0,0,0,0,0,0,0,0,0},Selected_font,nCoratual:=0

procedure gmode(nMode)
local aMode:={},nPos,x,n,lInfo:=.f.
if nMode<0 .or. nMode=Nil
   if nMode=Nil
      nMode=Modo_atual
   else
      nMode=nMode-nMode-nMode // Converte para positivo
   end if
   lInfo=.t.
end if
nPos=ascan(aModes,{|x|x[1]==nMode})
if nPos>0
   if !lInfo
      Ultimo_modo=Modo_atual
      Modo_atual=nPos
      config_lib(aModes[nPos,2],aModes[nPos,3],aModes[nPos,4])
      setmode(aModes[nPos,6],aModes[nPos,5])
   end if

   aadd(aMode,aModes[nPos,6]) // ROW
   aadd(aMode,aModes[nPos,5]) // COL
   aadd(aMode,aModes[nPos,4]) // WIDTH
   aadd(aMode,aModes[nPos,3]) // HEIGTH

   aadd(aMode,8)              // LINHAS DA FONTE
   aadd(aMode,16)             // COLUNAS DA FONTE
   
   x=aModes[nPos,3]
   if x=8
      x=256
   elseif x=16
      x=65535
   else
      x=16777265
   end if
   aadd(aMode,x) // Cores maxima
   
   aadd(aMode,Modo_atual) // Modo em uso

   aadd(aMode,421) // Versao da LLIBG por compatibilidade
   
   aadd(aMode,0) // LST COLOR

   aadd(aMode,0) // LST MODE
end if
return aMode

procedure ischar(x)
return valtype(x)=[C]

procedure isnum(x)
return valtype(x)=[N]

procedure gbmpload(cFile)
local aRet[3]
aRet[3]=bitmap():new(cFile)
aRet[1]=aRet[8]:h
aRet[2]=aRet[8]:w
return aclone(aRet)

procedure gbmpdisp(xHandle,nX,nY,nTransp) // nTransp é a cor transparente, será ignorada
local x
if valtype(xHandle)=[C]
   x=bitmap():new(cFile)
   draw_sprite(bitmap():new(,,,,.t.),x,nX,nY)
elseif valtype(xHandle)=[A]
   draw_sprite(bitmap():new(,,,,.t.),xHandle[3],nX,nY)
end if

procedure gfntload(cFontfile)
local aRet[11],font
aRet[11]=fnt():new(cFontfile)
aRet[1]=aRet[11]:cCopyright
aRet[2]=""
aRet[3]=.f.                   //FGL_FNT_FIXED
aRet[4]=cFontfile             //FGL_FNT_NAME
aRet[5]=aRet[11]:nWeight>0    //FGL_FNT_BOLD
aRet[6]=aRet[11]:lItalic      //FGL_FNT_ITALIC
aRet[7]=aRet[11]:lStrikeout   //FGL_FNT_STRIKEOUT
aRet[8]=aRet[11]:nPixelHeight //FGL_FNT_HEIGHT
aRet[9]=aRet[11]:nAvgWidth    //FGL_FNT_AVGWIDTH
aRet[10]=aRet[11]:nSize       //FGL_FNT_SIZE
Selected_font=aclone(aRet)
return aRet

procedure gfntset(aFont)
if valtype(aFont)=[A] .and. len(aFont)>=11
   Selected_font=aclone(aFont)
end if

procedure gfnterase(aFont)
if valtype(aFont)=[A]
   aFont={}
end if

procedure gwriteat(nX,nY,cTexto,nColor,nModo,aFont)
if valtype(nX)=[C]
   if valtype(Selected_font)=[A]
      return Selected_font[11]:StringLen(nX)
   else
      return len(nX)*8
   end if
end if
nBack=Nil
if valtype(nX)#[N]
   nX=0
end if
if valtype(nY)#[N]
   nY=0
end if
if valtype(cTexto)#[C]
   return
end if
if nColor=Nil
   nColor=nCoratual
end if
if Selected_font#Nil
   return Selected_font[11]:DrawString(bitmap():new(,,,,.t.),nY,nX,cTexto,nColor,nBack)
else
   if valtype(aFont)=[A]
      return aFont[11]:DrawString(bitmap():new(,,,,.t.),nY,nX,cTexto,nColor,nBack)
   end if
end if
return 0

procedure msetclip(aCord,nTipo)
if valtype(aCord)=[A] .and. len(aCord)=4 .and.valtype(nTipo)=[N]
   if nTipo=LLM_COR_TEXT
      aCord[1]=aCord[1]*16
      aCord[2]=aCord[2]*8
      aCord[3]=aCord[3]*16
      aCord[4]=aCord[4]*8
   end if
   Mouse_clip={aCord[1],aCord[2],aCord[3],aCord[4],aCord[1]/16,aCord[2]/8,aCord[3]/16,aCord[4]/8,nTipo}
   set_mouse_range(aCord[1],aCord[2],aCord[3],aCord[4])
end if
return aClone(Mouse_clip)

procedure fcdmadd

procedure fcnew

procedure fccreate

procedure __1st_065
procedure __1st_068
procedure __1st_069

procedure grect

procedure oaccess

procedure onew

procedure odel

procedure iget

procedure iput

procedure icopy

procedure bprint

procedure bmove

procedure bstabilize

procedure bonmouse

procedure mstate
local aRet
//aadd(aRet,

procedure gline

procedure ggetpixel

procedure gsetclip

procedure gframe

procedure gsetpal

procedure ocopy

procedure autocurvalue

procedure gsetexcl

procedure oassign
