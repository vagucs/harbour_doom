ALLEGTTF
========


Version 2.3
-----------
I didnt understand the makefiles anymore so I made a new one that work for 
DJGPP and Linux.  I havent tested it on any other platforms.
The low memory procedures are hopelessly broken so they have been reverted to 
the standard method.
Changed included ttf font to DevaVuSans because it is much better quality.
Newer gcc compiler gives warnings about type-punning, so removed warnings 
during compilation :0


Version 2.2
-----------
Makefile changes communicated by Jens Hassler
Ran indent on the sources
Fixed 8-bit drawing
Removed some examples that are too much trouble to maintain


Version 2.1
-----------
Now compatible with Allegro 4.2.1 and GCC 4.
The compiled library (libalttf.a) is compiled with GCC 4 and DJGPP 2.04!
To install it, copy allegttf.h to /djgpp/include/ and libalttf.a to /djgpp/lib/.

  Florian Xaver 2006-12-28


Version 2.0
-----------
Anti-aliased text output and font loading routines for Allegro

By Doug Eleveld
deleved@dds.nl

I DID NOT write any of the files in the /source/freetype directory
They came from the Freetype Project.
(see /source/freetype/licence.txt) for links.

Linux fix by Juraj Michalek (http://games.linux.sk)


