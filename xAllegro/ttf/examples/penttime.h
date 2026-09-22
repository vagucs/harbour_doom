//----------------------------------------------------------------------------
//
// DETL - A template library 2.0 beta
//
// Douglas Eleveld (D.J.Eleveld@anest.azg.nl or deleveld@dds.nl)
//
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Pentium timer class and macros
//
// C++ class wrapper around some macros that I got from comp.os.msdos.djgpp
//
//----------------------------------------------------------------------------
#ifndef PENTIUM_TIMER_HEADER
#define PENTIUM_TIMER_HEADER

//----------------------------------------------------------------------------
//#include "detl.h"

//----------------------------------------------------------------------------
// What I found on comp.os.msdos.djgpp through dejanews:

// Subject:      DJGPP RDTSC demo  (Pentium-only, ~100 lines)
// From:         Tom Burgess <Tom_Burgess@bc.sympatico.ca>
// Date:         1997/04/20
// Message-Id:   <3359E27B.6C9A@bc.sympatico.ca>
// Newsgroups:   comp.os.msdos.djgpp

/* rdtsc.c: DJGPP inline asm demo of Pentium cycle counter usage */
/* Reference: Agner Fog's "How to optimize for the Pentium" */
/* also thanks to Leath Muller for earlier posted RDTSC code */

// Hi, here's some code that might be useful to some for low-level
// Pentium optimization. If you get weird results, look carefully at
// what is known to be in cache when the code executes, code & data
// alignment, cache line conflicts, AGIs etc. Agner Fog warns that
// RDTSC doesn't work with virtual 86 mode but I've noted no problems
// with win95 dos shell, RHIDE or whatever. He also points out
// special Pentium Pro considerations which I have not addressed.
// Check out: http://announce.com/agner/assem/assem.html

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* RDTSC1 and RDTSC2 are macros to get Pentium RDTSC cycle count */
/* This returns 64 bits in EAX and EDX. */
/* If dest is address of a GNU long long, the 64 bit subtraction */
/* needed for interval measurement can be done directly */

/* RDTSC1 generates code for the initial timestamp read - the cld
   and nops are included for repeatable pairing and to eliminate
   shadowing effects from previous instructions */

#define RDTSC1(dest) \
__asm__(".byte 0x0F, 0x31\n\t"\
        "movl    %%eax, (%%edi)\n\t"\
        "movl    %%edx, 4(%%edi)\n\t"\
        "cld \n\t"\
        "nop \n\t nop \n\t nop \n\t"\
        "nop \n\t nop \n\t nop \n\t"\
        "nop \n\t nop \n\t"\
        : : "D" (dest) : "eax", "edx")

// I added here the extra nops that were mentioned in a later posting

/* use RDTSC2 immediately after the code under test. The clc is a 
   non-pairable filler that also elimate potential shadow effects */

#define RDTSC2(dest) \
__asm__("clc \n\t"\
        ".byte 0x0F, 0x31\n\t"\
        "movl    %%eax, (%%edi)\n\t"\
        "movl    %%edx, 4(%%edi)\n\t"\
        : : "D" (dest) : "eax", "edx")

//----------------------------------------------------------------------------
// C access to the timer and profiler
#ifndef __cplusplus

typedef struct {
	unsigned long long _overhead;
	unsigned long long _start;
	unsigned long long _end;
	unsigned long long _runs;
	unsigned long long _total;
} c_pentium_profiler;

#define PROFILER_RESET(x)  { RDTSC1(&(x)._start); \
                             RDTSC2(&(x)._end); \
                             \
                             RDTSC1(&(x)._start); \
                             RDTSC2(&(x)._end); \
                             (x)._overhead = (x)._end - (x)._start; \
                             \
                             (x)._runs = 0.; \
                             (x)._total = 0.; \
                           }

#define PROFILER_START(x)  { RDTSC1(&(x)._start); }

#define PROFILER_STOP(x)   { RDTSC2(&(x)._end); \
                            (x)._runs++; \
                            (x)._total += ((x)._end - (x)._start)-(x)._overhead; \
                           }

#define PROFILER_CYCLES(x) (((double)((x)._total))/((double)((x)._runs)))

#define PROFILER_OVERHEAD(x) ((double)((x)._overhead))

//----------------------------------------------------------------------------
// C++ access to the timer and profiler
#else

// Pentuim timer class for cycle counts
class pentium_timer {
  private:
	unsigned long long _overhead;
	unsigned long long _start;
	unsigned long long _end;

  public:
	// Basic constructor
	 pentium_timer(void) {
		/* Just want to get stuff into L1 cache */
		RDTSC1(&_start);
		RDTSC2(&_end);

		/* Measure overhead */
		RDTSC1(&_start);
		RDTSC2(&_end);

		_overhead = _end - _start;
	};

	// Start and stop the timer
	inline void start(void) {
		RDTSC1(&_start);
	};
	inline void stop(void) {
		RDTSC2(&_end);
	};

	// Info functions
	inline unsigned long long overhead(void) const {
		return _overhead;
	};
	inline unsigned long long cycles(void) const {
		return (_end - _start) - _overhead;
	};
};

//----------------------------------------------------------------------------
// Pentuim timer class for cycle counts
class pentium_profiler {
  private:
	// The internal timer
	pentium_timer timer;

	// Stats info
	unsigned long long _runs;
	unsigned long long _total;

  public:
	// Basic constructor
	 pentium_profiler(void):_runs(0), _total(0) {
	};

	// Start and stop the timer
	inline void start(void) {
		timer.start();
	};
	inline void stop(void) {
		timer.stop();
		_runs++;
		_total += timer.cycles();
	};

	// Info functions
	inline unsigned long long cycles(void) const {
		if (_runs == 0)
			return 0;
		return (_total - timer.overhead() * _runs) / _runs;
	};
	inline unsigned long long runs(void) const {
		return _runs;
	};
};

#endif
//----------------------------------------------------------------------------
#endif
