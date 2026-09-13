
THE FOLLOWING FILES ARE INCLUDED IN THE BGCON 1.6 RELEASE:

bgcon.exe   bgCon itself.
bgcon.doc   The bgCon manual in Microsoft Word 6.0 format.
bgcon.pdf   The bgCon manual in Adobe Acrobat format (distributed separately).
bgv.cof     Saturn-based background viewer in coff format.
bgv.sre     Saturn-based background viewer in S-record format.
bgv.doc     Manual for the background viewer.
bgv.pdf     Viewer manual in Adobe Acrobat format (distributed separately).
dehuff.o    Decompression module for the delta/Huffman algorithm.
dehuff.s    Source for dehuff.o.
dehuff.h    C header file for linking to dehuff.o.
readme.txt  This file.


WHAT'S NEW IN BGCON 1.6:

bgCon now supports the SGA3 file format, which allows image data to include
header information describing its format and establishing links between the
various components of an image (e.g. character pattern data, pattern name
data, and a color palette).  See the bgCon manual for details.

bgCon now comes with a Saturn-based background viewer which will display
any type of background at a variety of resolutions.

It is now possible to pass arguments from the DOS command line to a bgCon
script file.  Script files can contain variables that look and act like
the variables found in DOS batch files.  See the bgCon manual for details.

The help and status displays have been reformatted to include more
information.

Bug fix:  bgCon now does a better job of detecting when it is out of memory.

Bug fix:  bgCon now correctly parses 8-bit TGA files (this bug may only have
	  been present in v1.5).


BGCON REVISION HISTORY:

v1.61:   03/22/96:   Fixed bug in detecting reflections of 2x2 characters.

v1.6:    12/05/95:   Current release (see above).

v1.5:    11/21/95:   Added dhuff (delta/Huffman) compression algorithm,
                     the object module dehuff.o to perform decompression,
                     and the header file dehuff.h to declare the decom-
                     pression function.  Fixed a bug in rgbhi: it didn't
                     work with 24-bit pixels.  IFF files now report their
                     dimensions when being loaded.

v1.4b:   10/03/95:   Added ppp command.  Fixed bug in parsing iff files.
                     Fixed bug in parsing 16-bit tga files.  Identifiers
                     in assembler source files are now declared global.
                     Added rgbhi command.  Added trans command.  Changed
                     name of chsp command to pnsz.

v1.3b:   09/28/95:   Added support for iff files ("ILBM" and "PBM ").
                     Made output routines more verbose.  Added xflip
                     and yflip commands; added logic to guard against
                     eliminating X reflections at bit depths > 8.

v1.21b:  09/25/95:   Bug fix:  now sets bit map size correctly when
                     reading .pcx files.

v1.2b:   08/30/95:   Added if command and support for Targa files; loading
                     an image now sets the bit map size automatically.

v1.1b:   08/24/95:   Added po command, plus various cosmetic enhancements.

v1.0b:   08/23/95:   Initial beta release; reads PCX files only.
