25 Feb 1999.
Author: Daniel Hellerstein (danielh@econ.ag.gov)

         GIF_INFO: A utility for extracting information from GIF files.


GIF_INFO, ver 1.1, is an OS/2 REXX program that will extract information 
from a GIF file. This information includes the height, width, color 
table information, the number of images, the content of comment blocks, 
color table values, pixel values, and lots more. 

GIF_INFO also comes with  two sets of REXX procedures you can use for manipulating
GIF files. 

GIF_INFO is freeware; with the usual "use at your own risk" disclaimer (see
below for the details).

To install GIF_INFO:
  1) Install the  RXGDUTIL and REXXLIB dynamic link libraries
     If you don't have thes libraries, you can get them at 
        http://rpbcam.econ.ag.gov/thefiltr/blnddll.zip 
     -- be sure to read the READ.ME that's contained in BLNDDLL.ZIP.
  2) Unzip to an empty directory.
  3) Enter GIF_INFO ? at an os/2 comamnd prompt, and read on.


Alternatively, you can use the .RXX files (which contain sets of REXX 
procedures) to write your own programs.  There are three files:

PARSEGIF.RXX -- a complete set of REXX procedures. These require RXGDUTIL 
                and REXXLIB.
GIFVU.RXX    -- a rexx procedure that uses PARSEGIF.RXX to provide a simpler
                version of GIF_INFO (GIF_INFO is an extension of the GIFVU
                procedure).
GIFINFOa.RXX -- an older set of REXX procedures. These are not as powerful as the
                PARSEGIF.RXX procedures, but they do NOT require RXGDUTIL or
                REXXLIB. 

The documentation for these procedures is contained in the PARSEGIF.DOC and
GIFINFOa.DOC files, and GIFINFOa.CMD demonstrates the use of GIFINFOa.RXX.





                        ---------------------------

Basic copyright and it's never our fault disclaimer:

  Copyright 1999 by Daniel Hellerstein. Permission to use this program
  for any purpose is hereby granted without fee, provided that
  the author's name not be used in advertising or publicity
  pertaining to distribution of the software without specific written
  prior permision.

  This includes the right to subset and reuse the code, with proper attribution, 
 and subject to the proviso:

      We, the authors of GIF_INFO and any potentially affiliated institutions,
      disclaim any and all liability for damages due to the use, misuse, or
      failure of the product or subsets of the product.

    THIS SOFTWARE PACKAGE IS PROVIDED "AS IS" WITHOUT EXPRESS
    OR IMPLIED WARRANTY.
    THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE PACKAGE,
    INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
    IN NO  EVENT SHALL THE AUTHOR (Daniel Hellerstein) OR ANY PERSON OR
    INSTITUTION ASSOCIATED WITH THIS PRODUCT BE LIABLE FOR ANY
    SPECIAL,INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
    RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
    OF CONTRACT,NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
    IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE PACKAGE.


   GIF_INFO was developed on the personal time of Daniel Hellerstein,
   and is not supported, approved, or in any way an official product
   of my employer (USDA/ERS).


