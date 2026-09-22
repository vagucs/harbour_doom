#
# Makefile genérico para xHarbour
#
# Autor: Wagner Nunes da Silva
# http://www.vagucs.com.br
# vagucs@vagucs.com.br
# vagucs@bol.com.br
# -----------------------------
# 55+ (33) 3314-2242
# 55+ (33) 3314-1578
# 55+ (33) 8802-4151
#
HB_INC_INSTALL=c:\mingw\include
HB_LIB_INSTALL=c:\mingw\lib
# Compilador C que sera usado
CC=c:\mingw\bin\gcc
LINK=c:\mingw\bin\ar

# Compilador que sera usada para gerar o .C
HARBOUR =c:\harbourmgw\bin\harbour

# Especifique todos os .PRG's aqui com a extensão .O
OBJS=bitmap.o gtalleg.o ssf.o savepng.o loadpng.o \
regpng.o primitivo.o truecolor.o math.o fgl.o mouseapi.o \
ttf.o font.o ambiente.o datfile.o llibg.o

# Especifique aqui o nome do arquivo executável
LIB=libllibg.a

# Regra para criação do executável
all: $(OBJS)
   $(LINK) -q $(LIB) $(OBJS)

.SUFFIXES: .o .c .prg
# Regra para criação do .C a partir do .PRG
.prg.c:
   $(HARBOUR) $(*).prg -i$(HB_INC_INSTALL) $(HARBOUR_FLAGS) -m -n -p

# Regra para criação do .O a partir do .C
.c.o:
   $(CC) -c -Wall $< -o$(*).o  -I$(HB_INC_INSTALL) -DALLEGRO_STATICLINK
