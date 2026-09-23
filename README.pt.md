# doom_hb

![DOOM rodando em Harbour com Allegro](screenshot/doom1.png)

DOOM generic portado para Harbour, com interfaces mínimas em C para acesso ao Allegro 4.2.2.

Por **Wagner Nunes da Silva**

- vagucs@bol.com.br
- vagucs@vagucs.com.br
- vagucs@gmail.com
- [www.vagucs.com.br](https://www.vagucs.com.br)

English version: [README.md](README.md)

---

## O que é este projeto

O motor do Chocolate Doom / doomgeneric (lógica do jogo, renderer, menu, HUD, WAD, som de alto nível) está em **Harbour** (arquivos `.prg` / `.ch`).

A janela é criada pelo Harbour GT **GTALLEG** / **llibg** (`config_driver`, `config_lib`, `SetMode`), não por `set_gfx_mode` direto. O framebuffer interno do DOOM continua 320×200 em 8 bits (`I_VideoBuffer`).

O executável gerado é `Doom_hb.exe`.

É necessário um IWAD legal (shareware `doom1.wad` ou comercial `doom.wad` / `doom2.wad` / etc.).

---

## Proposta educacional

Este projeto é, antes de tudo, um **material de estudo**. O DOOM (1993) é um dos códigos mais estudados da história dos jogos: pequeno o bastante para ser lido de ponta a ponta, mas cheio de engenharia de verdade (renderização por BSP, matemática de ponto fixo, alocador de memória por zonas, laço de jogo por tics, sistema de arquivos WAD). Portá-lo para Harbour transforma esse código num curso prático.

O que o port pretende ensinar:

- **Ler C com os olhos de outra linguagem.** Cada arquivo `.prg` tem um equivalente em C em `base_c/`, com os mesmos nomes de função e, sempre que possível, a mesma estrutura. Dá para abrir `p_user.c` e `p_user.prg` lado a lado e acompanhar a tradução linha a linha.
- **O que os ponteiros realmente fazem.** Harbour não tem ponteiros. Sempre que o C usa `->`, `&`, aritmética de ponteiros, `memcpy` ou lista ligada, o port precisa expressar a *intenção* com objetos, referências, strings e índices. Isso deixa visível o que o C fazia de forma implícita.
- **Aritmética inteira e overflow.** O DOOM depende do "estouro" de 32 bits, de ângulos sem sinal (`angle_t`) e de ponto fixo 16.16 (`fixed_t`). Os números do Harbour não estouram, então o port precisa emular isso explicitamente (`AsU32`, `UShr`, `Shar`, `FixedMul`). Você aprende *por que* o original funciona, e não só *que* funciona.
- **Onde uma linguagem com máquina virtual basta, e onde não basta.** O motor inteiro roda em Harbour; o C ficou só para APIs nativas (Allegro) e alguns pontos críticos de desempenho. A fronteira entre os dois está documentada em [O que ficou em C, e por quê](#o-que-ficou-em-c-e-por-quê), e o trabalho de desempenho (por exemplo, levar as operações de bit para `HB_FUNC`) mostra como medir antes de otimizar.
- **O próprio Harbour, aplicado a um programa grande e real.** Classes, codeblocks, o pré-processador (`#translate`), escopo com `MEMVAR`/`PUBLIC`/`STATIC` e `#pragma BEGINDUMP` para C embutido, tudo usado em escala, num programa de cerca de 50 mil linhas em mais de 100 arquivos `.prg`.
- **Modernização de sistemas legados.** As mesmas técnicas servem para portar qualquer sistema antigo em C/C++ para uma linguagem de mais alto nível: manter o comportamento idêntico, isolar a camada nativa e conferir os resultados contra o original.

Sugestão de roteiro de estudo:

1. Compile e jogue o port (`compile.bat`), depois leia `main.prg` e `boot.prg` para ver como o jogo inicia.
2. Escolha um módulo pequeno (`m_random`, `m_bbox`, `p_telept`) e compare as versões `.c` e `.prg`.
3. Passe para o laço do jogo (`d_main`, `g_game`, `p_tick`) e a lista de thinkers.
4. Termine pelo renderer (`r_main`, `r_bsp`, `r_segs`, `r_draw`), onde ponto fixo e truques de bits aparecem o tempo todo.

---

## De C para Harbour: guia de conversão

### Tabela de conversão

| DOOM em C | DOOM em Harbour | Observações |
|---|---|---|
| `struct` / `typedef struct` | `CLASS ... DATA ... ENDCLASS` | `METHOD New()` inicializa cada campo. O C zera a memória estática; em Harbour o `DATA` começa como `NIL` |
| `thing->x`, `thing.x` | `thing:x` | Objetos são sempre referências, então acesso por ponteiro e por valor têm a mesma forma |
| `&thing` (endereço) | `thing` | A variável do objeto já é uma referência; identidade é comparada com `==` |
| `NULL` | `NIL` | `if (p)` vira `IF p != NIL` |
| `array[0]` | `array[1]` com compensação | Arrays em Harbour começam em 1: `finesine[angle]` → `finesine[ angle + 1 ]` |
| `typedef enum` | constantes `#define` em `.ch` | Mesmos valores numéricos do enum em C, para saves e tabelas continuarem compatíveis |
| macros `#define` | `#define` / `#translate` | O pré-processador do Harbour também reescreve operadores (veja operações de bit) |
| `&`, `\|`, `^` | `&`, `\|`, `^^` → `hb_qbitAnd/Or/Xor` | O `#translate` no topo de cada fonte converte para funções em C. Em Harbour `^` é potência, por isso o XOR é escrito `^^` |
| `~x` | `hb_qbitNot( x )` ou `x ^^ 0xFFFFFFFF` | |
| `x >> n` (sem sinal, ex.: `angle_t`) | `UShr( x, n )` | Shift lógico em 32 bits, implementado em C (`xhb_compat.prg`) |
| `x >> n` (com sinal, ex.: `fixed_t`) | `Shar( x, n )` | Shift aritmético (arredonda para −∞), implementado em C |
| `x << n` | `x * 2^n` ou `hb_qLBitShift( x, n )` | |
| estouro de 32 bits | `AsU32( n )` / `AsInt32( n )` | Inteiros do Harbour não estouram, então o "estouro" é explícito |
| `fixed_t` (16.16) | número + `FixedMul` / `FixedDiv` | A multiplicação/divisão em 64 bits fica em C (`m_fixed.prg`) para bater exatamente com o original |
| ponteiro de função (`actionf_t`) | codeblock ou string com nome da função | Chamado com `Eval()` ou via `IfaceCall()` |
| lista ligada (`prev`/`next`) | referência de objeto | Mesmo algoritmo, com `DATA prev` / `DATA next` |
| buffers `byte *`, `char *` | string/binário Harbour | `SubStr`, `Stuff`, `Asc`, `Chr` |
| `memcpy` / `memset` | `Stuff()`, `SubStr()`, `Replicate()` | Strings são valores; copiar é uma atribuição |
| `malloc` / `Z_Malloc` / `Z_Free` | objetos, arrays, strings | O coletor de lixo do Harbour libera a memória |
| variável global | `PUBLIC` + `MEMVAR` | Declarada numa `INIT PROCEDURE` e referenciada com `MEMVAR` onde é usada |
| `static` (escopo de arquivo) | `STATIC` | Mesmo significado |
| `for (i = 0; i < n; i++)` | `FOR i := 0 TO n - 1` | |
| `while (...)` | `DO WHILE ... ENDDO` | |
| `switch` / `case` | `SWITCH ... CASE ... ENDSWITCH` ou `DO CASE` | |
| `&&`, `\|\|`, `!` | `.AND.`, `.OR.`, `!` | |
| `a = b` | `a := b` | Em Harbour `=` também compara; o port usa sempre `:=` para atribuição |

### Exemplos lado a lado

Todos os trechos em C vêm de `base_c/`; as versões em Harbour são as que compõem o `Doom_hb.exe`.

#### Struct → CLASS

C (`base_c/d_think.h`):

```c
typedef struct thinker_s
{
    struct thinker_s*   prev;
    struct thinker_s*   next;
    think_t             function;
} thinker_t;
```

Harbour (`d_think.prg`):

```harbour
CLASS thinker_t
    DATA prev
    DATA next
    DATA function
    DATA owner
    DATA thinkfn
    METHOD New()
ENDCLASS

METHOD New() CLASS thinker_t
    ::prev := NIL
    ::next := NIL
    ::function := actionf_t():New()
    ::owner := NIL
    ::thinkfn := ""
RETURN Self
```

#### Ponteiros, arrays e ponto fixo

C (`base_c/p_user.c`):

```c
void P_Thrust (player_t* player, angle_t angle, fixed_t move)
{
    angle >>= ANGLETOFINESHIFT;

    player->mo->momx += FixedMul(move,finecosine[angle]);
    player->mo->momy += FixedMul(move,finesine[angle]);
}
```

Harbour (`p_user.prg`):

```harbour
PROCEDURE P_Thrust( player, angle, move )
    MEMVAR finecosine
    MEMVAR finesine
    angle := UShr( angle, ANGLETOFINESHIFT )
    player:mo:momx += FixedMul( move, finecosine[ angle + 1 ] )
    player:mo:momy += FixedMul( move, finesine[ angle + 1 ] )
RETURN
```

Três traduções em cinco linhas: `->` vira `:`, o shift sem sinal `>>=` vira `UShr()` e o índice que começava em 0 ganha `+ 1`.

#### Lista ligada e ponteiros de função

C (`base_c/p_tick.c`):

```c
void P_RunThinkers (void)
{
    thinker_t*  currentthinker;

    currentthinker = thinkercap.next;
    while (currentthinker != &thinkercap)
    {
        if ( currentthinker->function.acv == (actionf_v)(-1) )
        {
            currentthinker->next->prev = currentthinker->prev;
            currentthinker->prev->next = currentthinker->next;
            Z_Free (currentthinker);
        }
        else
        {
            if (currentthinker->function.acp1)
                currentthinker->function.acp1 (currentthinker);
        }
        currentthinker = currentthinker->next;
    }
}
```

Harbour (`p_tick.prg`):

```harbour
PROCEDURE P_RunThinkers()
    LOCAL currentthinker
    LOCAL nextthinker
    MEMVAR thinkercap

    currentthinker := thinkercap:next
    DO WHILE currentthinker != NIL .AND. !( currentthinker == thinkercap )
        nextthinker := currentthinker:next
        IF IsRemovedThinker( currentthinker )
            IF currentthinker:next != NIL
                currentthinker:next:prev := currentthinker:prev
            ENDIF
            IF currentthinker:prev != NIL
                currentthinker:prev:next := currentthinker:next
            ENDIF
        ELSE
            RunThinkerFn( currentthinker )
        ENDIF
        currentthinker := nextthinker
    ENDDO
RETURN

STATIC PROCEDURE RunThinkerFn( currentthinker )
    LOCAL x

    IF currentthinker:function == NIL
        RETURN
    ENDIF
    x := currentthinker:function:acp1
    IF ValType( x ) == "B"
        Eval( x )
    ELSEIF ValType( x ) == "C" .AND. ! Empty( x )
        IF currentthinker:owner != NIL
            IfaceCall( x, currentthinker:owner )
        ELSE
            IfaceCall( x, currentthinker )
        ENDIF
    ENDIF
RETURN
```

O `&thinkercap` desaparece (o objeto *é* a referência), o `Z_Free` não é necessário (coletor de lixo) e o ponteiro de função do C vira um codeblock (`"B"`) ou o nome de uma função (`"C"`).

#### Flags de bits

C (`base_c/p_mobj.c`):

```c
mo->flags &= ~MF_MISSILE;

if (mo->flags & MF_SKULLFLY)
{
    mo->flags &= ~MF_SKULLFLY;
    mo->momx = mo->momy = mo->momz = 0;
    P_SetMobjState (mo, mo->info->spawnstate);
}
```

Harbour (`p_mobj.prg`):

```harbour
mo:flags := ( mo:flags & ( MF_MISSILE ^^ 0xFFFFFFFF ) )

IF ( mo:flags & MF_SKULLFLY ) != 0
    mo:flags := ( mo:flags & ( MF_SKULLFLY ^^ 0xFFFFFFFF ) )
    mo:momx := 0
    mo:momy := 0
    mo:momz := 0
    P_SetMobjState( mo, mo:info:spawnstate )
ENDIF
```

Aqui o `&` e o `^^` são reescritos pelo pré-processador em `hb_qbitAnd()` / `hb_qbitXor()`:

```harbour
#translate ( <exp1> | <exp2> )      => ( hb_qbitOr( ( <exp1> ), ( <exp2> ) ) )
#translate ( <exp1> & <exp2> )      => ( hb_qbitAnd( ( <exp1> ), ( <exp2> ) ) )
#translate ( <exp1> ^^ <exp2> )     => ( hb_qbitXor( ( <exp1> ), ( <exp2> ) ) )
```

O "diferente de zero é verdadeiro" implícito do C também vira um `!= 0` explícito, e `a = b = c = 0` é separado em atribuições individuais.

#### `byte *` e `memcpy`

C (`base_c/r_draw.c`):

```c
void R_VideoErase (unsigned ofs, int count)
{
    if (background_buffer != NULL)
    {
        memcpy(I_VideoBuffer + ofs, background_buffer + ofs, count);
    }
}
```

Harbour (`r_draw.prg`):

```harbour
PROCEDURE R_VideoErase( ofs, count )
    MEMVAR I_VideoBuffer
    IF background_buffer != NIL
        I_VideoBuffer := Stuff( I_VideoBuffer, ofs + 1, count, ;
            SubStr( background_buffer, ofs + 1, count ) )
    ENDIF
RETURN
```

A tela é uma string Harbour de 64.000 bytes. A aritmética de ponteiros (`buffer + ofs`) vira uma posição começando em 1 (`ofs + 1`), e o `memcpy` vira `SubStr()` + `Stuff()`.

#### `typedef enum` → constantes

C (`base_c/doomdef.h`):

```c
typedef enum
{
    wp_fist,
    wp_pistol,
    wp_shotgun,
    wp_chaingun,
    wp_missile,
    wp_plasma,
    wp_bfg,
    wp_chainsaw,
    wp_supershotgun,

    NUMWEAPONS,

    wp_nochange

} weapontype_t;
```

Harbour (`doomdef.ch`):

```harbour
#define wp_fist         0
#define wp_pistol       1
#define wp_shotgun      2
#define wp_chaingun     3
#define wp_missile      4
#define wp_plasma       5
#define wp_bfg          6
#define wp_chainsaw     7
#define wp_supershotgun 8
#define NUMWEAPONS      9
#define wp_nochange     10
```

---

## O que ficou em C, e por quê

O C **não** é o motor do jogo. Ele existe só onde Harbour não consegue falar com a API nativa, ou onde o original depende de overflow e ponteiros de 32/64 bits.

### 1. Ligação Harbour ↔ Allegro 4 (`#pragma BEGINDUMP`)

O Allegro 4 é uma biblioteca C (`BITMAP *`, `SAMPLE *`, `MIDI *`, paleta, `stretch_blit`, fila de teclado, mixer). Harbour não acessa esses ponteiros sem um wrapper `HB_FUNC`.

| Arquivo | O que o C faz | Motivo |
|---|---|---|
| `doomgeneric_allegro.prg` | Bitmap temporário, paleta 8 bits, `stretch_blit`, teclado, ticks, título da janela, filtro CRT (`-crt`) | Hardware/API do Allegro; blit por pixel em Harbour é lento demais para 35 fps |
| `i_video.prg` | Blit opcional em C (`IVideoSetPalette` / `IVideoFinishUpdate`) | O vídeo roda **100% em Harbour** por padrão. Se ficar lento demais, use `-videoc` para copiar e escalar o framebuffer 320×200 em C |
| `i_allegrosound.prg` | Mixer, samples, vozes, volume/pan | `SAMPLE *` e mixer do Allegro |
| `i_allegromusic.prg` | Load/play/pause de MIDI | `MIDI *` do Allegro |
| `m_fixed.prg` | `FixedMul` / `FixedDiv` em 64 bits | Precisa do mesmo overflow/shift do DOOM original (`FRACBITS = 16`) |
| `xhb_compat.prg` | Operações de bit `hb_qbitAnd/Or/Xor/Not`, shifts `UShr` / `Shar` | Chamadas o tempo todo pelo renderer e pela lógica do jogo. Em C ficam cerca de 1,6× (bits) a 6–7× (shifts) mais rápidas que as versões PRG, com resultado idêntico. O `Shar` original em PRG ficou comentado para referência |
| `i_system.prg` | `malloc` e `MessageBox` do Windows | Zona de memória por ponteiro C; caixa de erro nativa |
| `d_iwad.prg` | Leitura do registro do Windows | Procurar IWADs instalados pelo jogo original |
| `m_misc.prg` | OEM → UTF-8 | Conversão Win32 de página de código |

### 2. GT Allegro / xAllegro (C de terceiro)

Compilados pelo `doom_hb.hbp`:

| Arquivo | Função |
|---|---|
| `xAllegro/gtallegd.c` | GT Harbour sobre Allegro. Em modo jogo (`AllegGameVideo(.T.)`) o refresh do console **não** sobrescreve a tela; `alleg_present_bitmap` faz o stretch para a janela |
| `xAllegro/ssf.c` | Fonte do GT |
| `xAllegro/ambiente.prg` | Wrappers (`_set_window_title`, resolução do desktop, etc.) |

Sem esse C, o Harbour não cria a janela DirectX (`GFX_DIRECTX_WIN`) nesse stack.

### 3. O que **não** entra na compilação Harbour

| Pasta | Papel |
|---|---|
| `base_c/` | Cópia de referência do DOOM em C. **Não** é compilada por `compile.bat` |
| `.hbmk/` | C gerado automaticamente pelo `hbmk2` a partir dos `.prg`. Não editar |

---

## Como compilar

### Requisitos (Windows)

- Harbour com `hbmk2` em `C:\HARBOUR\BIN`
- MinGW 4.8.1 em `c:\mingw-4.8.1` (gcc, libs)
- Allegro 4.2.2 estático: `c:\mingw-4.8.1\lib\liballeg.a`
- Compatibilidade xHarbour: `hbmk2 -lxhb`

### Compilar o port Harbour (o que você usa)

Na pasta do projeto:

```bat
compile.bat
```

Isso chama:

```bat
hbmk2 -lxhb doom_hb.hbp
```

Saída: `Doom_hb.exe`.

Feche o jogo antes de recompilar. Se `Doom_hb.exe` estiver aberto, o linker falha com *Permission denied*.

### Compilar o C de referência (opcional)

`build.bat` + `Makefile` geram um `Doom_hb.exe` a partir de `base_c/`. Não é o port Harbour.

---

## Como executar

Coloque o IWAD na mesma pasta do executável (ou passe o caminho):

```bat
Doom_hb.exe
Doom_hb.exe -iwad doom2.wad
Doom_hb.exe doom2.wad
```

Sem parâmetro, procura nesta ordem: `-iwad`, um argumento `*.wad`, busca estilo Chocolate Doom, depois arquivos locais (`doom1.wad`, `doom.wad`, `doom2.wad`, `plutonia.wad`, `tnt.wad`, Freedoom).

O boot mínimo começa em **E1M1 / MAP01**, habilidade **Hurt Me Plenty** (`MINIAL_*` em `boot.ch`).

---

## Teclas (padrão)

Controles clássicos do DOOM. Dá para remapeá-los em `default.cfg` / `doom_hbdoom.cfg`.

### Movimento e ação

| Tecla | Ação |
|---|---|
| Setas | Frente, trás, virar |
| **Shift** | Correr |
| **Alt** | Strafe (segurar) |
| **,** / **.** | Strafe esquerda / direita |
| **Ctrl** (esquerdo) | Atirar |
| **Espaço** | Usar / abrir porta |
| **1**–**8** | Trocar arma |
| **Pause** | Pausar |
| **Tab** | Abrir / fechar o mapa |

### Mapa (com o mapa aberto)

| Tecla | Ação |
|---|---|
| Setas | Mover o mapa |
| **+** / **-** | Zoom |
| **0** | Zoom máximo |
| **F** | Seguir o jogador |
| **G** | Grade |
| **M** | Marcar posição |
| **C** | Limpar marcas |
| **Tab** | Fechar o mapa |

### Menu e funções

| Tecla | Ação |
|---|---|
| **Esc** | Menu |
| **Enter** | Confirmar / avançar |
| **Backspace** | Voltar |
| **Y** / **N** | Sim / Não |
| **F1** | Ajuda |
| **F2** | Salvar |
| **F3** | Carregar |
| **F4** | Volume |
| **F5** | Detalhe gráfico |
| **F6** | Quick save |
| **F7** | Encerrar o jogo |
| **F8** | Mensagens |
| **F9** | Quick load |
| **F10** | Sair |
| **F11** | Gamma |
| **=** / **-** | Tamanho da tela |
| **Alt+Enter** | Alternar tela cheia |

### Mouse

| Botão | Ação |
|---|---|
| Esquerdo | Atirar |
| Direito | Strafe |
| Meio | Andar para frente |
| Clique duplo | Usar (se `dclick_use` estiver ligado) |

### Cheats (só nostalgia)

Digite no teclado durante o jogo, sem Enter:

| Código | Efeito |
|---|---|
| **IDDQD** | Modo Deus (*Degreelessness Mode*) |
| **IDKFA** | Todas as armas, munição, chaves e armadura |

---

## Parâmetros da linha de comando

Estes funcionam no boot atual (`doom_hb_Create` → `D_DoomMainMinimal`).

### IWAD

| Parâmetro | Descrição |
|---|---|
| `-iwad arquivo.wad` | IWAD a carregar (caminho ou só o nome) |
| `arquivo.wad` | Mesmo efeito, sem `-iwad` |

### Vídeo

O vídeo roda **100% em Harbour** por padrão (paleta e `I_FinishUpdate`). Se ficar lento demais, use `-videoc`.

| Parâmetro | Descrição |
|---|---|
| `-videoc` | Usa o caminho em C para paleta e blit do framebuffer (alternativa mais rápida) |
| `-scaling N` | Fator de escala do 320×200 (1–8). Sem isso, calcula sozinho |
| `-gfxmode rgba8888` | Framebuffer 32 bpp (padrão se não for CMAP256) |
| `-gfxmode rgb565` | Framebuffer 16 bpp |
| `-fullscreen` | Tenta tela cheia no Allegro |
| `-crt` | Filtro de monitor CRT: curvatura do tubo, scanlines, máscara RGB de fósforo e vinheta. Funciona em janela e em tela cheia |
| `-fps` | Mostra os quadros por segundo no canto superior direito da tela |

Na inicialização o log mostra `I_InitGraphics: video path: Harbour` ou `C`.

### Som

| Parâmetro | Descrição |
|---|---|
| `-nosound` | Sem SFX e sem música |
| `-nosfx` | Sem efeitos |
| `-nomusic` | Sem música |

### Configuração e sistema

| Parâmetro | Descrição |
|---|---|
| `-config arquivo.cfg` | Arquivo principal de configuração |
| `-extraconfig arquivo.cfg` | Config extra |
| `-mb N` | Megabytes da zona de memória |
| `-nogui` | Não mostra `MessageBox` em erro fatal |
| `-setmem ...` | Dump de memória estilo DOS (depuração) |

---

## Estrutura resumida

```
doom_hb.hbp          projeto hbmk2
compile.bat          compilação Harbour
main.prg             cria a janela GTALLEG e chama doom_hb_Create()
boot.prg             escolhe o IWAD e sobe o jogo
*.prg / *.ch         motor em Harbour
xAllegro/            GT Allegro + wrappers C
```

---


## Doe

### Ethereum

`0x1b64038A2b1DB73ABd0068d8B9B0d1dC5a90C5F1`

![QR Code Ethereum](docs/qr-ethereum.png)

### PIX

Chave: `vagucs@bol.com.br`

![QR Code PIX](docs/qr-pix.png)


