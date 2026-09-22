/*
 Classe para cerregar arquivos FNT compativeis com a LLIBG e FGLIB do clipper 5.X
 
 Por: Wagner Nunes
 Data: 10/05/2009
 http://www.vagucs.com.br
 vagucs@bol.com.br
 vagucs@vagucs.com.br
*/

#include "hbclass.ch"

#define ELM_CHAR      1
#define ELM_OFFSET    2
#define ELM_BITS      3
#define ELM_BYTES_BMP 4
#define ELM_SPAN      5

CLASS FNT
   VAR cVersion INIT ""
   VAR nSiZe INIT 0
   VAR cCopyright INIT ""
   VAR cFace INIT ""
   VAR nType INIT 0
   VAR nPoints INIT 0
   VAR nVerticalResolution INIT 0
   VAR nHorizontalResolution INIT 0
   VAR nAscent INIT 0
   VAR nInternalLeading INIT 0
   VAR nExternalLeading INIT 0
   VAR lItalic INIT .f.
   VAR lUnderline INIT .f.
   VAR lStrikeout INIT .f.
   VAR nWeight INIT 0
   VAR nCharset INIT 0
   VAR nPixelWidth INIT 0
   VAR nPixelHeight INIT 0
   VAR nFamily INIT 0
   VAR nAvgWidth INIT 0
   VAR nMaxWidth INIT 0
   VAR nFirstChar INIT 0
   VAR nLastChar INIT 0
   VAR nDefaultChar INIT 0
   VAR nBreakChar INIT 0
   VAR nWidthBytes INIT 0
   VAR nDevice INIT 0
   VAR nFace INIT 0
   VAR nPointer INIT 0
   VAR nOffset INIT 0
   VAR nReserved INIT 0
   VAR nErrocode INIT 0
   VAR nNumberChar INIT 0
   VAR nZoom INIT 0

   VAR aCharinfo INIT {}

   METHOD New(cFile)
   METHOD DrawString(nBmp,nX,nY,cString,nForecolor,nBackcolor)
   METHOD StringLen(cString)
  
END CLASS

METHOD NEW(cFile) CLASS FNT
Local nHandle,cTemp,nCount,nRow,nBits
nHandle=fopen(cFile)
if ferror()#0
   ::nErrocode=ferror()
   return self
else
   // Carrega o Header da fonte
   cTemp=space(2);fread(nHandle,@cTemp,2);::cVersion=iif(bin2i(cTemp)=512,"2.00","3.00")     // Versao
   cTemp=space(4);fread(nHandle,@cTemp,4);::nSize=bin2l(cTemp)                               // Tamanho do arquivo
   cTemp=space(60);fread(nHandle,@cTemp,60);::cCopyright=alltrim(strtran(cTemp,chr(0),""))   // Copyright/Autor
   cTemp=space(2);fread(nHandle,@cTemp,2);::nType=bin2i(cTemp)                               // Tipo
   cTemp=space(2);fread(nHandle,@cTemp,2);::nPoints=bin2i(cTemp)                             // Pontos
   cTemp=space(2);fread(nHandle,@cTemp,2);::nVerticalResolution=bin2i(cTemp)                 // Resolucao vertical
   cTemp=space(2);fread(nHandle,@cTemp,2);::nHorizontalResolution=bin2i(cTemp)               // Resolucao horizontal
   cTemp=space(2);fread(nHandle,@cTemp,2);::nAscent=bin2i(cTemp)                             // Ascento
   cTemp=space(2);fread(nHandle,@cTemp,2);::nInternalLeading=bin2i(cTemp)                    // Leading ?
   cTemp=space(2);fread(nHandle,@cTemp,2);::nExternalLeading=bin2i(cTemp)
   cTemp=space(1);fread(nHandle,@cTemp,1);::lItalic=bin2i(cTemp)#0                           // Italico
   cTemp=space(1);fread(nHandle,@cTemp,1);::lUnderline=bin2i(cTemp)#0                        // Underline
   cTemp=space(1);fread(nHandle,@cTemp,1);::lStrikeout=bin2i(cTemp)#0                        // Riscado
   cTemp=space(2);fread(nHandle,@cTemp,2);::nWeight=bin2i(cTemp)                             // Peso da fonte
   cTemp=space(1);fread(nHandle,@cTemp,1);::nCharset=asc(cTemp)                              // Charset
   cTemp=space(2);fread(nHandle,@cTemp,2);::nPixelWidth=bin2i(cTemp)                         // Largura da fonte
   cTemp=space(2);fread(nHandle,@cTemp,2);::nPixelHeight=bin2i(cTemp)                        // Altura da fonte
   cTemp=space(1);fread(nHandle,@cTemp,1);::nFamily=bin2i(cTemp)                             // Familia da fonte
   cTemp=space(2);fread(nHandle,@cTemp,2);::nAvgWidth=bin2i(cTemp)                           // Media de largura
   cTemp=space(2);fread(nHandle,@cTemp,2);::nMaxWidth=bin2i(cTemp)                           // Maior largura
   cTemp=space(1);fread(nHandle,@cTemp,1);::nFirstChar=bin2i(cTemp)                          // Primeiro caractere da tabela ascii
   cTemp=space(1);fread(nHandle,@cTemp,1);::nLastChar=bin2i(cTemp)                           // Ultimo caractere da tabela ascii
   cTemp=space(1);fread(nHandle,@cTemp,1);::nDefaultChar=bin2i(cTemp)                       
   cTemp=space(1);fread(nHandle,@cTemp,1);::nBreakChar=bin2i(cTemp)
   cTemp=space(2);fread(nHandle,@cTemp,2);::nWidthBytes=bin2i(cTemp)
   cTemp=space(4);fread(nHandle,@cTemp,4);::nDevice=bin2l(cTemp)
   cTemp=space(4);fread(nHandle,@cTemp,4);::nFace=bin2l(cTemp)                               // Posicao no arquivo onde esta o nome da fonte
   cTemp=space(4);fread(nHandle,@cTemp,4);::nPointer=bin2l(cTemp)                            // Ponteiro onde comeca o bitmap das fontes
   cTemp=space(4);fread(nHandle,@cTemp,4);::nOffset=bin2l(cTemp)                             // Offset dos bitmaps
   cTemp=space(1);fread(nHandle,@cTemp,1);::nReserved=bin2l(cTemp)
  
   if ::cVersion="2.00"
      ::nNumberChar=(::nLastChar-::nFirstChar)-1
      for nCount=1 to ::nNumberChar
         cTemp=space(4)
         fread(nHandle,@cTemp,4)
         aadd(::aCharinfo,{chr(nCount+::nFirstChar-1),; // Caractere ASC
                           bin2i(right(cTemp,2)),;      // Posição/Offset
                           bin2i(left(cTemp,2)),;       // Bits
                           "",;                         // Bytes do arquivo
                           0,;                          // Span/Bits > 0 * 8
                           }) 
         
      next
      for nCount=1 to len(::aCharInfo)
         ::aCharInfo[nCount,ELM_SPAN]=val(left(transform((::aCharInfo[nCount,ELM_BITS]-1)/8,"9999999999.999"),10)) // Corta a casa decimais para fazer o calculo de bits da fonte com precisao
         for nRow=0 to ::nPixelHeight
            for nBits=0 to (::aCharInfo[nCount,ELM_SPAN])
               fseek(nHandle,::aCharInfo[nCount,ELM_OFFSET]+nRow+(::nPixelHeight*(nBits))) // Carrega o mapeamento binario de cada fonte
               cTemp=" "
               fread(nHandle,@cTemp,1)
               ::aCharInfo[nCount,ELM_BYTES_BMP]=cTemp+::aCharInfo[nCount,ELM_BYTES_BMP]
            next
         next
      next
   else
      ::nErrorCode=-1 // Versao nao suportada 3.00 e outras
   end if
   fclose(nHandle)
end if
return self

METHOD DrawString(nBmp,nX,nY,cChar,nForeColor,nBackColor) CLASS FNT
Local nPos,nLine,cLine,nCol,nCharpos,nBin,tempBmp,oneChar
for each oneChar in cChar
   nPos=aScan(::aCharInfo,{|Element|Element[ELM_CHAR]=oneChar}) // Localiza a fonte no array das fontes
   if nPos>0
      if nBackColor#Nil
         _rectfill(nBmp:nHandle,nY+1,nX,nY+::aCharInfo[nPos,ELM_BITS],nX+::nPixelHeight,nBackColor) // Otimizado para desenhar o fundo mais rapido
      end if
      nCharpos=len(::aCharInfo[nPos,ELM_BYTES_BMP])+1
//      for nLine:=1 to ::nPixelHeight
      nLine=0
      while ++nLine<::nPixelHeight
         nCharpos-=::aCharInfo[nPos,ELM_SPAN]+1
         cLine=left(makebinary(substr(::aCharInfo[nPos,ELM_BYTES_BMP],nCharpos,::aCharInfo[nPos,ELM_SPAN]+1)),::aCharInfo[nPos,ELM_BITS]) // Transforma ja em uma posicao binaria
         nCol=nY
         _force_c(nBmp:nHandle,nCol,nX+nLine,nForecolor,cLine,len(cLine))
//         for each nBin in cLine // Otimizado para rodar mais rapidamente
//            nCol++
//            if nBin=[1]
//               _nputpixel(nBmp:nHandle,nCol,nX+nLine,nForeColor) // Putpixel sem verificacoes para rodar mais rapido
//            end if
//         end if
      //next
      enddo
      nY+=::aCharInfo[nPos,ELM_BITS] // Movimenta as colunas para a direita de acordo com o tamanho do caractere
   end if
next
return ::StringLen(cChar)

METHOD StringLen(cString) CLASS FNT
Local nLen:=0,nCount,nPos,cChar
for each cChar in cString
   nPos=aScan(::aCharInfo,{|Element|Element[ELM_CHAR]=cChar}) // Localiza o caractere dentro da fonte
   if nPos>0
      nLen+=::aCharInfo[nPos,ELM_BITS] // Soma o numero de bits que ele representa para variavel de retorno, a soma de bits dos caracteres e o tamanho total da string na tela
   end if
next
return nLen

procedure rev(cStr)
local i,cRet:=""
for i=len(cStr) to 1 step -1
   cRet+=cStr[i]
next
return cRet

procedure makebinary(cBin)
local cRet,i,j,cB
cRet=""
for each cB in cBin
   for j=0 to 7
      cRet=iif(isbit(asc(cB),j),"1","0")+cRet
   next
next
return cRet

#pragma BEGINDUMP
#include "hbapi.h"
#include "allegro.h"

//    _force_c(nBmp:nHandle,nCol,nX+nLine,nForecolor,cLine,len(cLine))

HB_FUNC(_FORCE_C)
{
   BITMAP *nBmp=(BITMAP *)hb_parnl(1);
   int y=hb_parni(2);
   int x=hb_parni(3);
   int nForeColor=hb_parni(4);
   int nLine=hb_parni(6);
   int jmp;
   char *binary=hb_parc(5);
   unsigned int nCount;
   for(nCount=0;nCount<nLine;nCount++)
   {
      y++;
      if (binary[nCount]==49){
         for(jmp=0;binary[nCount+jmp]!=49;jmp++){}
         nCount=nCount+jmp;
         hline(nBmp,y,x,y+jmp,nForeColor);
         y=y+jmp;
      }
   }
}


HB_FUNC(_NPUTPIXEL)
{
   putpixel((BITMAP *)hb_parnl(1),hb_parni(2),hb_parni(3),hb_parni(4));
}   

#pragma ENDDUMP

/*procedure main
local aFnt
aFnt:=fnt():new("arial10.fnt")
var=aFnt:StringLen("Wagner Nunes")
aFnt:DrawString(0,0,"Wagner")*/

