_______________________________________
Contents:

Example.cmd  - a "wrapper" program.  It demonstrates how to use the contained subroutines.  These subroutines are intented to provide a mechanism for REXX programs to access data stored in TIFF files. The primary routine is ReadTiffTags.

ExampleOut.cmd - a "wrapper" program. It demonstrates how to the the contained subroutine to write a TIFF image. The primary routine is OutputTIFF.

Test4bitPalette_PC.tif - Test image for Example.cmd.
Test8bitPalette_PC.tif - Test image for Example.cmd.
Test8bitPalette_UNIX.tif - Test image for Example.cmd.
TestRGB_PC.TIF - Test image for Example.cmd.
Test4bitPalette_PC.tif.ReadTIFFLog - Output created by Example.cmd.
Test8bitPalette_PC.tif.ReadTIFFLog - Output created by Example.cmd.
Test8bitPalette_UNIX.tif.ReadTIFFLog - Output created by Example.cmd.
TestRGB_PC.TIF.ReadTIFFLog - Output created by Example.cmd.

ExampleOut_Palette.tif - Output from ExampleOut when a color palette image is made.
ExampleOut_RGB.tif - Output from ExampleOut when a RGB image is made.

Readme.txt - This file.

Tiff6.pdf - Version 6 of the TIFF specification document.


_______________________________________
Programming:
See the comments within Example.cmd and ExampleOut.cmd to learn how to use the subroutines for your own purposes.  

_______________________________________
To run:

Example.cmd requires a single parameter, the name of a TIFF file.  For example

	Example Test4bitPalette_PC.tif 

or better yet

	pmrexx Example Test4bitPalette_PC.tif

Each run of example generate a file with the extension .ReadTIFFLog.  This will contain a dump of the tag information within the TIFF file.


ExampleOut.cmd is run by entering the program name at the command line followed by either a 1 or a 3.  A 1 will cause a TIFF image using a color table to be written.  A 3 will cause a RGB image to be written.  The name of the output file is ExampleOut.tif.


Doug Rickman
Global Hydrology and Climate Center
MSFC/NASA

doug@hotrocks.msfc.nasa.gov

