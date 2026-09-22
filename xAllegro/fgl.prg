#define  FGL_TEXT_NORMAL     3
#define  FGL_TEXT_43_80      43
#define  FGL_TEXT_50_80      50
#define  FGL_TEXT_60_80      264
#define  FGL_TEXT_25_132     265
#define  FGL_TEXT_43_132     266
#define  FGL_TEXT_50_132     267
#define  FGL_TEXT_60_132     268

// graphical modes
#define  FGL_GRAPHICS_640_480_16    18
#define  FGL_GRAPHICS_800_600_16    258
#define  FGL_GRAPHICS_1024_768_16   260
#define  FGL_GRAPHICS_1280_1024_16  262
#define  FGL_GRAPHICS_640_400_256   256
#define  FGL_GRAPHICS_640_480_256   257
#define  FGL_GRAPHICS_800_600_256   259
#define  FGL_GRAPHICS_1024_768_256  261
#define  FGL_GRAPHICS_1280_1024_256 263
#define  FGL_GRAPHICS_640_480_32k   272
#define  FGL_GRAPHICS_800_600_32k   275
#define  FGL_GRAPHICS_1024_768_32k  278
#define  FGL_GRAPHICS_1280_1024_32k 281
#define  FGL_GRAPHICS_640_480_64k   273
#define  FGL_GRAPHICS_800_600_64k   276
#define  FGL_GRAPHICS_1024_768_64k  279
#define  FGL_GRAPHICS_1280_1024_64k 282

#define  FGL_MODE_TEXT_ROW    1
#define  FGL_MODE_TEXT_COL    2
#define  FGL_MODE_GRAPH_MAXY  3
#define  FGL_MODE_GRAPH_MAXX  4
#define  FGL_MODE_GRAPH_ROW   3
#define  FGL_MODE_GRAPH_COL   4
#define  FGL_MODE_FONT_HEIGHT 5
#define  FGL_MODE_FONT_WIDTH  6
#define  FGL_MODE_NUMCOLORS   7
#define  FGL_MODE_IN_USE      8
#define  FGL_MODE_GRAPHIC     9
#define  FGL_MODE_FOREGROUND  10
#define  FGL_MODE_BACKGROUND  11

#define FGL_FNT_SIGNATURE              1
#define FGL_FNT_CARGO                  2
#define FGL_FNT_FIXED                  3
#define FGL_FNT_NAME                   4
#define FGL_FNT_BOLD                   5
#define FGL_FNT_ITALIC                 6
#define FGL_FNT_STRIKEOUT              7
#define FGL_FNT_HEIGHT                 8
#define FGL_FNT_AVGWIDTH               9
#define FGL_FNT_SIZE                  10

#define FGL_FNT_IS_FND   'FND'
#define FGL_FNT_IS_FNT   'FNT'

static atual_mode:=FGL_TEXT_NORMAL,Selected_font,nCoratual,nBgcoratual

proc FGLSETMODE(nMode)
local aInfos:={}
local aModes:={{FGL_TEXT_NORMAL           ,16, 640, 480,25, 80,0},;
               {FGL_TEXT_43_80            ,16, 640, 480,43, 80,0},;
               {FGL_TEXT_50_80            ,16, 640, 480,50, 80,0},;
               {FGL_TEXT_60_80            ,16, 640, 480,60, 80,0},;
               {FGL_TEXT_25_132           ,16, 640, 480,25,132,0},;
               {FGL_TEXT_43_132           ,16, 640, 480,43,132,0},;
               {FGL_TEXT_50_132           ,16, 640, 480,50,132,0},;
               {FGL_TEXT_60_132           ,16, 640, 480,60,132,0},;
               {FGL_GRAPHICS_640_480_16   ,16, 640, 480,30, 80,1},;
               {FGL_GRAPHICS_800_600_16   ,16, 800, 600,30, 80,1},;
               {FGL_GRAPHICS_1024_768_16  ,16,1024, 768,30, 80,1},;
               {FGL_GRAPHICS_1280_1024_16 ,16,1280,1024,30, 80,1},;
               {FGL_GRAPHICS_640_400_256  ,16, 640, 400,30, 80,1},;
               {FGL_GRAPHICS_640_480_256  ,16, 640, 480,30, 80,1},;
               {FGL_GRAPHICS_800_600_256  ,16, 800, 600,30, 80,1},;
               {FGL_GRAPHICS_1024_768_256 ,16,1024, 768,30, 80,1},;
               {FGL_GRAPHICS_1280_1024_256,16,1280,1024,30, 80,1},;
               {FGL_GRAPHICS_640_480_32k  ,24, 640, 480,30, 80,1},;
               {FGL_GRAPHICS_800_600_32k  ,24, 800, 600,30, 80,1},;
               {FGL_GRAPHICS_1024_768_32k ,24,1024, 768,30, 80,1},;
               {FGL_GRAPHICS_1280_1024_32k,24,1280,1024,30, 80,1},;
               {FGL_GRAPHICS_640_480_64k  ,32, 640, 480,30, 80,1},;
               {FGL_GRAPHICS_800_600_64k  ,32, 800, 600,30, 80,1},;
               {FGL_GRAPHICS_1024_768_64k ,32,1024, 768,30, 80,1},;
               {FGL_GRAPHICS_1280_1024_64k,32,1280,1024,30, 80,1}}
if nMode=NIl
   nMode=0
end if
for i=1 to len(aModes)
   if aModes[i,1]=atual_mode .or. iif(nMode<0,aModes[i,1]=abs(nMode),.f.)
      aadd(aInfos,aModes[i,5]) //FGL_MODE_TEXT_ROW
      aadd(aInfos,aModes[i,6]) //FGL_MODE_TEXT_COL
      aadd(aInfos,aModes[i,4]) //FGL_MODE_GRAPH_MAXY
      aadd(aInfos,aModes[i,3]) //FGL_MODE_GRAPH_MAXX
      aadd(aInfos,aModes[i,5]) //FGL_MODE_GRAPH_ROW
      aadd(aInfos,aModes[i,6]) //FGL_MODE_GRAPH_COL
      aadd(aInfos,8)           //FGL_MODE_FONT_HEIGHT
      aadd(aInfos,16)          //FGL_MODE_FONT_WIDTH
      aadd(aInfos,aModes[i,2]) //FGL_MODE_NUMCOLORS
      aadd(aInfos,.t.)         //FGL_MODE_IN_USE
      aadd(aInfos,aModes[i,7]) //FGL_MODE_GRAPHIC
      aadd(aInfos,0)           //FGL_MODE_FOREGROUND
      aadd(aInfos,0)           //FGL_MODE_BACKGROUND
   end if
next
for i=1 to len(aModes)
   if aModes[i,1]=nMode
      config_lib(aModes[i,2],aModes[i,3],aModes[i,4])
      setmode(aModes[i,5],aModes[i,6])
      atual_mode=nMode
      nCoratual:=makecol(255,255,255)
      nBgcoratual:=makecol(0,0,0)
   end if
next
return aInfos

proc FGLMHIDE
scare_mouse()

proc FGLMSHOW
unscare_mouse()


proc FGLFONTLOAD(cFontfile)
local aRet[11],font
aRet[11]=fnt():new(cFontfile)
aRet[1]=aRet[11]:cCopyright
aRet[2]=""
aRet[3]=.f.             //FGL_FNT_FIXED
aRet[4]=cFontfile             //FGL_FNT_NAME
aRet[5]=aRet[11]:nWeight>0             //FGL_FNT_BOLD
aRet[6]=aRet[11]:lItalic             //FGL_FNT_ITALIC
aRet[7]=aRet[11]:lStrikeout             //FGL_FNT_STRIKEOUT
aRet[8]=aRet[11]:nPixelHeight             //FGL_FNT_HEIGHT
aRet[9]=aRet[11]:nAvgWidth             //FGL_FNT_AVGWIDTH
aRet[10]=aRet[11]:nSize             //FGL_FNT_SIZE
Selected_font=aclone(aRet)
return aRet

procedure FGLFONTERASE(aFont)
aFont={}


//FGLFontSet( <aFont | FGL_ROM_FONT>  [, <nClipTop> , <nClipBottom> ] ) 
proc FGLFONTSET(aFont)
if valtype(aFont)=[A] .and. len(aFont)>=11
   Selected_font=aclone(aFont)
end if


//FGLWriteAt( [<nX>,<nY>,[<nColor>],[<nBackgroundColor>],] <cString> )          nLength
proc FGLWRITEAT(nX,nY,nColor,nBack,cTexto)
if valtype(nX)=[C]
   if valtype(Selected_font)=[A]
      return Selected_font[11]:StringLen(nX)
   else
      return len(nX)*8
   end if
end if
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
//if nBack=Nil .or. nBack=0
//   nBack=nBgcoratual
//end if
if Selected_font#Nil
   return Selected_font[11]:DrawString(bitmap():new(,,,,.t.),nY,nX,cTexto,nColor,nBack)
end if
return 0


/*if nColor=Nil
   nColor=255
end if
if valtype(nX)=[C]
   return len(nX)*8
end if
gfxtext(nY,nX,cTexto,nColor*2,16,32)
return len(cTexto)*8*?
*/

proc FGLSETCOLOR(nColor)
local nRet
nRet=nCoratual
nCoratual=nColor
return nRet
//? "FGLSETCOLOR"


proc FGLSETBGCOLOR(nColor)
local nRet
nRet=nBgcoratual
nBgcoratual=nColor
return nRet

proc FGLELLIPSE(nXmid,nYmid,nXrad,nYrad,nColor)
if nColor=Nil
   nColor=nCoratual
end if
ellipse(bitmap():new(,,,,.t.),nXmid,nYmid,nXrad,nYrad,nColor)

//FGLGetBackground( <nXleft> , <nYtop> , <nXright> , <nYbottom> )    
proc FGLGETBACKGROUND(nXleft,nYtop,nXright,nYbottom)    
local aRet[8],bmp
nXright++
nYbottom++
aRet[8]=bitmap():new(,nXright-nXleft,nYbottom-nYtop)
_blit(_get_screen(),aRet[8]:nHandle,nXleft,nYtop,0,0,nXright-nXleft,nYbottom-nYtop)
aRet[1]="BMP"
aRet[6]=aRet[8]:w
aRet[7]=aRet[8]:h
return aclone(aRet)

//FGLShowDDB( <nX> , <nY> , <aDDB> [, <nTrans>] )   
proc FGLSHOWDDB(nX,nY,aDIB,nFlags,nTrans)
draw_sprite(bitmap():new(,,,,.t.),aDib[8],nX,nY)

//FGLFillEllipse( <nXmid> , <nYmid> , <nXrad> , <nYrad >[, <nColor>] [, <nBorderColor> ])   
proc FGLFILLELLIPSE(nXmid,nYmid,nXrad,nYrad,nColor,nBorderColor)
if nColor=Nil
   nColor=nCoratual
end if
ellipsefill(bitmap():new(,,,,.t.),nXmid,nYmid,nXrad,nYrad,nColor)
if nBorderColor#Nil
   ellipse(bitmap():new(,,,,.t.),nXmid,nYmid,nXrad,nYrad,nColor)
end if
return .t.

//FGLShowDIB( <nX> , <nY> , <aDIB> , <nFlags> [, nTrans] )    
proc FGLSHOWDIB(nX,nY,aDIB,nFlags,nTrans)
draw_sprite(bitmap():new(,,,,.t.),aDib[8],nX,nY)

proc FGLLOADBMP(cBmp)
local aRet[8]
aRet[8]=bitmap():new(cBmp)
aRet[1]="BMP"
aRet[6]=aRet[8]:w
aRet[7]=aRet[8]:h
return aclone(aRet)

//FGLLine( <nXleft> , <nYtop> , <nXright> , <nYbottom> [, <nColor> ] )
proc FGLLINE(nXleft,nYtop,nXright,nYbottom,nColor)
if nColor=Nil
   nColor=nCoratual
end if
line(bitmap():new(,,,,.t.),nXleft,nYtop,nXright,nYbottom,nColor)

//FGLRectangle( <nXleft> , <nYtop> , <nXright> , <nYbottom> [, <nColor> ] )   
proc FGLRECTANGLE(nXleft,nYtop,nXright,nYbottom,nColor)
if nColor=Nil 
   nColor=nCoratual
end if
rect(bitmap():new(,,,,.t.),nXleft,nYtop,nXright,nYbottom,nColor)
//? "FGLRECTANGLE"

//FGLFillRectangle( <nXleft> , <nYtop> , <nXright> , <nYbottom> [, <nColor>] )
proc FGLFILLRECTANGLE(nXleft,nYtop,nXright,nYbottom,nColor) 
if nColor=Nil 
   nColor=nBgcoratual
   // Retira cor de fundo atual
end if
rectfill(bitmap():new(,,,,.t.),nXleft,nYtop,nXright,nYbottom,nColor)


proc FGLSETVIEWPORT(nX,nY,nX2,nY2)
local aOldc,x1,y1,x2,y2
_get_clip_rect(_get_screen(),@x1,@y1,@x2,@y2)
aOldc={x1,y1,x2,y2}
if !(nY=Nil .or. nY=Nil .or. nX2=Nil .or. nY2=Nil)
   _set_clip_rect(_get_screen(),nX,nY,nX2,nY2)
end if
return aOldc

proc FGLMAKEDDB(aDDB)
return aclone(aDDB)

//X,Y,COR
proc fglsetpixel(x,y,cor)
if cor#nil
   if cor#makecol(255,0,255)
      putpixel(bitmap():new(,,,,.t.),x,y,cor)
   end if
end if
