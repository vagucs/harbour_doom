# doom_hb

![DOOM running on Harbour with Allegro](screenshot/doom1.png)

DOOM generic ported to Harbour, with minimal C interfaces for Allegro 4.2.2.

By **Wagner Nunes da Silva**

- vagucs@bol.com.br
- vagucs@vagucs.com.br
- vagucs@gmail.com
- [www.vagucs.com.br](https://www.vagucs.com.br)

Versão em português: [README.pt.md](README.pt.md)

---

## What this project is

The Chocolate Doom / doomgeneric engine (game logic, renderer, menu, HUD, WAD, high-level sound) lives in **Harbour** (`.prg` / `.ch` files).

The window is created by the Harbour **GTALLEG** / **llibg** GT (`config_driver`, `config_lib`, `SetMode`), not by a raw `set_gfx_mode` call. The internal DOOM framebuffer is still 320×200, 8-bit (`I_VideoBuffer`).

The built executable is `Doom_hb.exe`.

You need a legal IWAD (shareware `doom1.wad` or commercial `doom.wad` / `doom2.wad` / etc.).

---

## Educational purpose

This project is, above all, a **study piece**. DOOM (1993) is one of the most studied codebases in game history: small enough to read end to end, yet full of real engineering (BSP rendering, fixed-point math, a zone allocator, a tic-based game loop, a WAD file system). Porting it to Harbour turns that code into a hands-on course.

What the port is meant to teach:

- **Reading C through the eyes of another language.** Every `.prg` file has a C counterpart in `base_c/` with the same function names and, as far as possible, the same structure. You can open `p_user.c` and `p_user.prg` side by side and follow the translation line by line.
- **What pointers really do.** Harbour has no pointers. Each time the C code uses `->`, `&`, pointer arithmetic, `memcpy` or a linked list, the port has to express the *intent* with objects, references, strings and indexes. That makes visible what the C code was doing implicitly.
- **Integer arithmetic and overflow.** DOOM relies on 32-bit wrap-around, unsigned angles (`angle_t`) and 16.16 fixed-point (`fixed_t`). Harbour numbers do not wrap, so the port must emulate it explicitly (`AsU32`, `UShr`, `Shar`, `FixedMul`). You learn *why* the original works, not just *that* it works.
- **Where an interpreted/VM language is enough, and where it is not.** The whole engine runs in Harbour; C is kept only for native APIs (Allegro) and a few hot-path helpers. The line between the two is documented in [What remains in C, and why](#what-remains-in-c-and-why), and the performance work (for example, moving bit operations to `HB_FUNC`) shows how to measure before optimizing.
- **Harbour itself, applied to a large real program.** Classes, codeblocks, the preprocessor (`#translate`), `MEMVAR`/`PUBLIC`/`STATIC` scoping, and `#pragma BEGINDUMP` for inline C — all used at scale, in a program of about 50,000 lines across more than 100 `.prg` files.
- **Legacy modernization.** The same techniques apply when porting any old C/C++ system to a higher-level language: keep behavior identical, isolate the native layer, and verify results against the original.

Suggested way to study:

1. Build and play the port (`compile.bat`), then read `main.prg` and `boot.prg` to see how the game starts.
2. Pick a small module (`m_random`, `m_bbox`, `p_telept`) and compare the `.c` and `.prg` versions.
3. Move on to the game loop (`d_main`, `g_game`, `p_tick`) and the thinker list.
4. Finish with the renderer (`r_main`, `r_bsp`, `r_segs`, `r_draw`), where fixed-point and bit tricks are everywhere.

---

## From C to Harbour: conversion guide

### Conversion table

| DOOM in C | Harbour DOOM | Notes |
|---|---|---|
| `struct` / `typedef struct` | `CLASS ... DATA ... ENDCLASS` | `METHOD New()` initializes every field. C zeroes static memory; Harbour `DATA` starts as `NIL` |
| `thing->x`, `thing.x` | `thing:x` | Objects are always references, so pointer and value access look the same |
| `&thing` (address of) | `thing` | The object variable already is a reference; identity is compared with `==` |
| `NULL` | `NIL` | `if (p)` becomes `IF p != NIL` |
| `array[0]` | `array[1]` with offset | Harbour arrays are 1-based: `finesine[angle]` → `finesine[ angle + 1 ]` |
| `typedef enum` | `#define` constants in `.ch` | Same numeric values as the C enum, so saved games and tables still match |
| `#define` macros | `#define` / `#translate` | The Harbour preprocessor also rewrites operators (see bit operations) |
| `&`, `\|`, `^` | `&`, `\|`, `^^` → `hb_qbitAnd/Or/Xor` | `#translate` at the top of each file maps them to C functions. `^` is exponentiation in Harbour, so XOR is written `^^` |
| `~x` | `hb_qbitNot( x )` or `x ^^ 0xFFFFFFFF` | |
| `x >> n` (unsigned, e.g. `angle_t`) | `UShr( x, n )` | Logical shift on 32 bits, implemented in C (`xhb_compat.prg`) |
| `x >> n` (signed, e.g. `fixed_t`) | `Shar( x, n )` | Arithmetic shift (rounds toward −∞), implemented in C |
| `x << n` | `x * 2^n` or `hb_qLBitShift( x, n )` | |
| 32-bit wrap-around | `AsU32( n )` / `AsInt32( n )` | Harbour integers do not overflow, so wrap-around is explicit |
| `fixed_t` (16.16) | number + `FixedMul` / `FixedDiv` | The 64-bit multiply/divide stays in C (`m_fixed.prg`) to match the original exactly |
| function pointer (`actionf_t`) | codeblock or function-name string | Called with `Eval()` or through `IfaceCall()` |
| linked list (`prev`/`next`) | object references | Same algorithm, `DATA prev` / `DATA next` |
| `byte *`, `char *` buffers | Harbour string (binary-safe) | `SubStr`, `Stuff`, `Asc`, `Chr` |
| `memcpy` / `memset` | `Stuff()`, `SubStr()`, `Replicate()` | Strings are immutable values; copying is an assignment |
| `malloc` / `Z_Malloc` / `Z_Free` | objects, arrays, strings | Harbour's garbage collector frees memory |
| global variable | `PUBLIC` + `MEMVAR` | Declared in an `INIT PROCEDURE`, referenced with `MEMVAR` where used |
| `static` (file scope) | `STATIC` | Same meaning |
| `for (i = 0; i < n; i++)` | `FOR i := 0 TO n - 1` | |
| `while (...)` | `DO WHILE ... ENDDO` | |
| `switch` / `case` | `SWITCH ... CASE ... ENDSWITCH` or `DO CASE` | |
| `&&`, `\|\|`, `!` | `.AND.`, `.OR.`, `!` | |
| `a = b` | `a := b` | `=` in Harbour is also comparison; the port always uses `:=` for assignment |

### Side-by-side examples

All C snippets come from `base_c/`; the Harbour versions are the ones compiled into `Doom_hb.exe`.

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

#### Pointers, arrays and fixed-point

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

Three translations in five lines: `->` becomes `:`, the unsigned shift `>>=` becomes `UShr()`, and the 0-based index gets `+ 1`.

#### Linked list and function pointers

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

`&thinkercap` disappears (the object *is* the reference), `Z_Free` is not needed (garbage collector), and the C function pointer becomes a codeblock (`"B"`) or a function name (`"C"`).

#### Bit flags

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

The `&` and `^^` here are rewritten by the preprocessor into `hb_qbitAnd()` / `hb_qbitXor()`:

```harbour
#translate ( <exp1> | <exp2> )      => ( hb_qbitOr( ( <exp1> ), ( <exp2> ) ) )
#translate ( <exp1> & <exp2> )      => ( hb_qbitAnd( ( <exp1> ), ( <exp2> ) ) )
#translate ( <exp1> ^^ <exp2> )     => ( hb_qbitXor( ( <exp1> ), ( <exp2> ) ) )
```

C's implicit "non-zero is true" also becomes an explicit `!= 0`, and `a = b = c = 0` is split into separate assignments.

#### `byte *` and `memcpy`

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

The screen is a 64,000-byte Harbour string. Pointer arithmetic (`buffer + ofs`) becomes a 1-based position (`ofs + 1`), and `memcpy` becomes `SubStr()` + `Stuff()`.

#### `typedef enum` → constants

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

## What remains in C, and why

C is **not** the game engine. It stays only where Harbour cannot talk to a native API, or where the original code depends on 32/64-bit overflow and pointers.

### 1. Harbour ↔ Allegro 4 bindings (`#pragma BEGINDUMP`)

Allegro 4 is a C library (`BITMAP *`, `SAMPLE *`, `MIDI *`, palette, `stretch_blit`, key queue, mixer). Harbour cannot touch those pointers without an `HB_FUNC` wrapper.

| File | What the C does | Why |
|---|---|---|
| `doomgeneric_allegro.prg` | Scratch bitmap, 8-bit palette, `stretch_blit`, keyboard, ticks, window title, CRT filter (`-crt`) | Allegro hardware/API; a Harbour per-pixel blit is too slow for 35 fps |
| `i_video.prg` | Optional C blit (`IVideoSetPalette` / `IVideoFinishUpdate`) | Video runs **100% in Harbour** by default. If that is too slow, use `-videoc` to copy and scale the 320×200 framebuffer in C |
| `i_allegrosound.prg` | Mixer, samples, voices, volume/pan | Allegro `SAMPLE *` and mixer |
| `i_allegromusic.prg` | MIDI load/play/pause | Allegro `MIDI *` |
| `m_fixed.prg` | 64-bit `FixedMul` / `FixedDiv` | Must match original DOOM overflow/shift (`FRACBITS = 16`) |
| `xhb_compat.prg` | Bit operations `hb_qbitAnd/Or/Xor/Not`, shifts `UShr` / `Shar` | Called constantly by the renderer and game logic. In C they are about 1.6× (bit ops) to 6–7× (shifts) faster than the PRG versions, with identical results. The original PRG `Shar` is kept as a comment for reference |
| `i_system.prg` | `malloc` and Windows `MessageBox` | Zone memory as a C pointer; native error box |
| `d_iwad.prg` | Windows registry read | Find IWADs installed by the original game |
| `m_misc.prg` | OEM → UTF-8 | Win32 code-page conversion |

### 2. GT Allegro / xAllegro (third-party C)

Linked by `doom_hb.hbp`:

| File | Role |
|---|---|
| `xAllegro/gtallegd.c` | Harbour GT on top of Allegro. In game-video mode (`AllegGameVideo(.T.)`) the console refresh does **not** overwrite the screen; `alleg_present_bitmap` stretches into the window |
| `xAllegro/ssf.c` | GT font |
| `xAllegro/ambiente.prg` | Wrappers (`_set_window_title`, desktop resolution, etc.) |

Without this C, Harbour cannot open the DirectX window (`GFX_DIRECTX_WIN`) on this stack.

### 3. What is **not** part of the Harbour build

| Folder | Role |
|---|---|
| `base_c/` | Reference copy of the C DOOM. **Not** built by `compile.bat` |
| `.hbmk/` | C auto-generated by `hbmk2` from the `.prg` files. Do not edit |

---

## How to compile

### Requirements (Windows)

- Harbour with `hbmk2` in `C:\HARBOUR\BIN`
- MinGW 4.8.1 in `c:\mingw-4.8.1` (gcc and libs)
- Static Allegro 4.2.2: `c:\mingw-4.8.1\lib\liballeg.a`
- xHarbour compatibility: `hbmk2 -lxhb`

### Build the Harbour port (the one you run)

From the project folder:

```bat
compile.bat
```

That runs:

```bat
hbmk2 -lxhb doom_hb.hbp
```

Output: `Doom_hb.exe`.

Close the game before rebuilding. If `Doom_hb.exe` is still running, the linker fails with *Permission denied*.

### Build the reference C port (optional)

`build.bat` + `Makefile` produce a `Doom_hb.exe` from `base_c/`. That is not the Harbour port.

---

## How to run

Put the IWAD next to the executable (or pass a path):

```bat
Doom_hb.exe
Doom_hb.exe -iwad doom2.wad
Doom_hb.exe doom2.wad
```

With no argument it looks for, in order: `-iwad`, a bare `*.wad` argument, a Chocolate Doom-style search, then local files (`doom1.wad`, `doom.wad`, `doom2.wad`, `plutonia.wad`, `tnt.wad`, Freedoom).

The minimal boot starts at **E1M1 / MAP01**, skill **Hurt Me Plenty** (`MINIAL_*` in `boot.ch`).

---

## Keys (defaults)

Classic DOOM controls. They can be remapped in `default.cfg` / `doom_hbdoom.cfg`.

### Movement and actions

| Key | Action |
|---|---|
| Arrow keys | Forward, back, turn |
| **Shift** | Run |
| **Alt** | Strafe (hold) |
| **,** / **.** | Strafe left / right |
| **Ctrl** (left) | Fire |
| **Space** | Use / open door |
| **1**–**8** | Change weapon |
| **Pause** | Pause |
| **Tab** | Toggle automap |

### Automap (while the map is open)

| Key | Action |
|---|---|
| Arrow keys | Pan the map |
| **+** / **-** | Zoom |
| **0** | Max zoom |
| **F** | Follow the player |
| **G** | Grid |
| **M** | Mark position |
| **C** | Clear marks |
| **Tab** | Close the map |

### Menu and function keys

| Key | Action |
|---|---|
| **Esc** | Menu |
| **Enter** | Confirm / go forward |
| **Backspace** | Back |
| **Y** / **N** | Yes / No |
| **F1** | Help |
| **F2** | Save |
| **F3** | Load |
| **F4** | Volume |
| **F5** | Graphic detail |
| **F6** | Quick save |
| **F7** | End game |
| **F8** | Messages |
| **F9** | Quick load |
| **F10** | Quit |
| **F11** | Gamma |
| **=** / **-** | Screen size |
| **Alt+Enter** | Toggle full-screen |

### Mouse

| Button | Action |
|---|---|
| Left | Fire |
| Right | Strafe |
| Middle | Walk forward |
| Double-click | Use (if `dclick_use` is on) |

### Cheats (nostalgia only)

Type these on the keyboard during play; no Enter needed:

| Code | Effect |
|---|---|
| **IDDQD** | God mode (*Degreelessness Mode*) |
| **IDKFA** | All weapons, ammo, keys, and armor |

---

## Command-line parameters

These work on the current boot path (`doom_hb_Create` → `D_DoomMainMinimal`).

### IWAD

| Parameter | Description |
|---|---|
| `-iwad file.wad` | IWAD to load (path or filename) |
| `file.wad` | Same thing, without `-iwad` |

### Video

Video runs **100% in Harbour** by default (palette and `I_FinishUpdate`). If that is too slow, pass `-videoc`.

| Parameter | Description |
|---|---|
| `-videoc` | Use the C path for palette and framebuffer blit (faster fallback) |
| `-scaling N` | Scale factor from 320×200 (1–8). If omitted, it is computed |
| `-gfxmode rgba8888` | 32 bpp framebuffer (default when not CMAP256) |
| `-gfxmode rgb565` | 16 bpp framebuffer |
| `-fullscreen` | Try Allegro full-screen |
| `-crt` | CRT monitor filter: tube curvature, scanlines, RGB phosphor mask and vignette. Works windowed and full-screen |

Startup logs `I_InitGraphics: video path: Harbour` or `C`.

### Sound

| Parameter | Description |
|---|---|
| `-nosound` | No SFX and no music |
| `-nosfx` | No sound effects |
| `-nomusic` | No music |

### Config and system

| Parameter | Description |
|---|---|
| `-config file.cfg` | Main config file |
| `-extraconfig file.cfg` | Extra config file |
| `-mb N` | Zone memory size in megabytes |
| `-nogui` | Do not show a `MessageBox` on fatal error |
| `-setmem ...` | DOS-style memory dump (debug) |

---

## Layout

```
doom_hb.hbp          hbmk2 project
compile.bat          Harbour build
main.prg             opens the GTALLEG window and calls doom_hb_Create()
boot.prg             picks the IWAD and starts the game
*.prg / *.ch         engine in Harbour
xAllegro/            Allegro GT + C wrappers
```

---

## Donate

### Ethereum

`0x1b64038A2b1DB73ABd0068d8B9B0d1dC5a90C5F1`

![Ethereum QR Code](docs/qr-ethereum.png)

### PIX

Key: `vagucs@bol.com.br`

![PIX QR Code](docs/qr-pix.png)
