/* This is an example of how to write an image in the TIFF format.  It can   */
/* write either a single palette or RGB image, 8bit, uncompressed formats.   */
/* Units are in dots per inch.                                               */
/* The image is written after the tag data.                                  */
/*                                                                           */
/* The real work is done by the subroutine OutputTIFF().  The main routine   */
/* in this program builds a simple image to write.                           */
/*                                                                           */
/*  ImageWidth                256 100 SHORT or LONG                          */
/*  ImageLength               257 101 SHORT or LONG                          */
/*  BitsPerSample             258 102 SHORT 8,8,8                            */
/*  Compression               259 103 SHORT 1 or 32773                       */
/*  PhotometricInterpretation 262 106 SHORT 2                                */
/*                                                                           */
/*  StripOffsets              273 111 SHORT or LONG                          */
/*  SamplesPerPixel           277 115 SHORT 3 or more                        */
/*  RowsPerStrip              278 116 SHORT or LONG                          */
/*  StripByteCounts           279 117 LONG or SHORT                          */
/*  XResolution               282 11A RATIONAL  The number of pixels per     */
/*     ResolutionUnit in the ImageWidth (typically, horizontal               */
/*                                                                           */
/*  YResolution               283 11B RATIONAL                               */
/*  ResolutionUnit            296 128 SHORT 1, 2 or 3                        */
/*  Software                  305 131 ASCII                                  */
/*  DateTime                  306 132 ASCII 20  YYYY:MM:DD HH:MM:SS          */
/*  Artist                    315 13B ASCII                                  */
/*                                                                           */
/*  ColorMap                  320 140 SHORT 3 * (2**BitsPerSample)           */
/*                                                                           */
/*                                                                           */
/* IFD Entry                                                                 */
/*  Each 12-byte IFD entry has the following format:                         */
/*  Bytes 0-1 The Tag that identifies the field.                             */
/*  Bytes 2-3 The field Type.                                                */
/*  Bytes 4-7 The number of values, Count of the indicated Type.             */
/*  Bytes 8-11 The Value Offset, the file offset (in bytes) of the Value for */
/*     the field.                                                            */
/*  The Value is expected to begin on a word boundary; the corresponding     */
/*     Value Offset will thus be an even number.                             */
 
/* Data. is a compound variable having the structure Data.h.i.j.  "h" is the */
/* band number, and may be either 1 or 3.  "i" is the column number.  "j" is */
/* the row number.  Column and row must be positive, interger indexes values.*/
/* If h=1 then a color mapped image is written, also refered to as a color   */
/* table or palette image.  If h=3 then an RGB image is written.             */
/* Any range of the input array may be written and every nth element in row  */
/* and column may be written.  The values in Data.h.i.j are integers, 0 - 255*/
/* If a color table is used the compound variables Temp_red.i, Temp_green.i, */
/* and Temp_blue.i must contain the color values.  "i" must be integer, 0 -  */
/* 255 and values must also be interger, 0 - 255. */
/*                                                                           */
/* This example shows holding all the data to be written in memory.  I do not*/
/* actually do it this way.  500MB files are a bit much to hold in RAM.  I   */
/* have indicated in the code 2 palces where I actually have calls to        */
/* routines that read a line of an input file and provide the necessary data */
/* for the TIFF image.  These are noted by the following line:               */
/*               /* Insert call to read routine here. */                     */
/*                                                                           */
/*                                                                           */
/* Doug Rickman, March 7, 2000.  This code may be used as you wish.  Please  */
/* give credit where appropriate.                                            */ 

parse arg NBands
if NBands=1 | NBands=3 then nop
else do
   say 'You must give the number of bands in the output image, either 1 or 3.'
   return 0
   end

/* Create simple example data. */
if NBands = 1 then do
   /* Build gray scale color table. */
   do i = 0 to 255
      Temp_red.i   = i
      Temp_green.i = i
      Temp_blue.i  = i
      end i

   h=1
   do i = 1 to 100
      do j = 1 to 100
         Data.h.i.j=i+j
         end j
      end i
   end /* if NBands .... */

else do
   h=1
   do i = 1 to 100
      do j = 1 to 100
         Data.h.i.j=i
         end j
      end i
   h=2
   do i = 1 to 100
      do j = 1 to 100
         Data.h.i.j=j
         end j
      end i
   h=3
   do i = 1 to 100
      do j = 1 to 100
         Data.h.i.j=255-i-j
         end j
      end i

   end /* else do ... */

rc=OutputTIFF('ExampleOut.tif',5,92,3,90,NBands,1,300)
return 1

OutputTIFF:

procedure expose Data. Temp_red. Temp_green. Temp_blue.

out               = arg(1)
InitialColumn2Pin = arg(2) /* Initial column to write.                       */
LastColumn2Pin    = arg(3) /* Last column to write.                          */
InitialRow2Pin    = arg(4) /* Initial row to write.                          */
LastRow2Pin       = arg(5) /* Last row to write.                             */
NBands            = arg(6) /* Number of bands to write, either 1 or 3.       */
SampleRate        = arg(7) /* Sample rate.  Every nth value written. Integer.*/
ReproductionResolution = arg(8) /* Reproduction resolution, DPI.             */

'del'  '2>> nul 1>>&2 ' /* delete the output if it exists. */

/* First define the values to be written out. */
 
/* Header bytes. */
TIFFID    = '49 49 2A 00'x /* Little Endian TIFF. */
IFDOffset = '08 00 00 00'x /* Immediately after TIFFID */
v=TIFFID||IFDOffset
rc=charout(out,v,)


/* Begin building IFD and tag information.  First determine length of IFD.   */
/* Build an entry and appended to variable "IFD"   If information in excess  */
/* of the value field must be stored it is built and appended to the variable*/
/* ExtraInfo.  Both variables are written after construction is completed.   */

if NBands = 1 then do 
   IFD       = reverse(d2c(16,2))
   IFDLength = 2 + 12*16 + 4 
   /* Length of IFD = Number of Entries + N*12 Byte entries + '0000' at end. */
   end
else do
   IFD       = reverse(d2c(15,2))
   IFDLength = 2 + 12*15 + 4 /* Length of IFD */
   end

ExtraInfo = ''
   
/*  1. Number of elements.                                                   */
NElements = LastColumn2Pin-InitialColumn2Pin+1
v         = NElements/SampleRate
NElements = trunc(v)+(v>0)*(v\=trunc(v))  /* Ceiling operation. */

Entry = reverse(d2c(256,2)) || reverse(d2c(4,2)) || reverse(d2c(1,4)) || reverse(d2c(NElements,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  2. Number of lines.                                                      */
NLines    = LastRow2Pin-InitialRow2Pin+1
v         = NLines/SampleRate
NLines    = trunc(v)+(v>0)*(v\=trunc(v))  /* Ceiling operation. */

Entry = reverse(d2c(257,2)) || reverse(d2c(4,2)) || reverse(d2c(1,4)) || reverse(d2c(NLines,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  3. BitsPerSample */
if NBands = 1 then do
   Entry = reverse(d2c(258,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(8,4))
   end
else do
   Offset= 8 + IFDLength + length(ExtraInfo)
   Entry = reverse(d2c(258,2)) || reverse(d2c(3,2)) || reverse(d2c(3,4)) || reverse(d2c(Offset,4))
   ExtraInfo = ExtraInfo || reverse(d2c(8,2)) || reverse(d2c(8,2)) || reverse(d2c(8,2))
   end
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  4. Compression */
Entry = reverse(d2c(259,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(1,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  5. PhotometricInterpretation */
if NBands = 1 then 
   Entry = reverse(d2c(262,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(3,4))
else
   Entry = reverse(d2c(262,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(2,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  6. StripOffsets */
if NLines = 1 then do
   Entry = reverse(d2c(273,2)) || reverse(d2c(4,2)) || reverse(d2c(1,4)) || reverse(d2c(1,4))
   end
else do
   Offset= 8 + IFDLength + length(ExtraInfo)
   Entry = reverse(d2c(273,2)) || reverse(d2c(4,2)) || reverse(d2c(NLines,4)) || reverse(d2c(Offset,4))
      
   /* I'll need to build the extra info. */
   
   SpacerStart  = length(ExtraInfo)
   SpacerLength = NLines*4
   Spacer       = ''
   Spacer       = right(Spacer,SpacerLength,' ')

   ExtraInfo    = ExtraInfo || Spacer
   end /* else do */
   
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  7. SamplesPerPixel */
if NBands = 1 then 
   Entry = reverse(d2c(277,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(1,4))
else
   Entry = reverse(d2c(277,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(3,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  8. RowsPerStrip */
Entry = reverse(d2c(278,2)) || reverse(d2c(4,2)) || reverse(d2c(1,4)) || reverse(d2c(1,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/*  9. StripByteCounts */
if NLines = 1 then do
   if NBands = 1 then
      Entry = reverse(d2c(279,2)) || reverse(d2c(4,2)) || reverse(d2c(1,4)) || reverse(d2c(NElements,4))
   else
      Entry = reverse(d2c(279,2)) || reverse(d2c(4,2)) || reverse(d2c(1,4)) || reverse(d2c(NElements*3,4))
   end
else do
   Offset= 8 + IFDLength + length(ExtraInfo)
   Entry = reverse(d2c(279,2)) || reverse(d2c(4,2)) || reverse(d2c(NLines,4)) || reverse(d2c(Offset,4))
   if NBands = 1 then 
      StripByteCounts = NElements
   else 
      StripByteCounts = NElements * 3

   do i = 1 to NLines
      ExtraInfo = ExtraInfo || reverse(d2c(StripByteCounts,4))      
      end i
   end
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 10. XResolution */
Offset= 8 + IFDLength + length(ExtraInfo)
Entry = reverse(d2c(282,2)) || reverse(d2c(5,2)) || reverse(d2c(1,4)) || reverse(d2c(Offset,4))

rc=ContinuedFraction(ReproductionResolution)
parse var rc v1 v2

ExtraInfo = ExtraInfo || reverse(d2c(v1,4)) || reverse(d2c(v2,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 11. YResolution */
Offset= 8 + IFDLength + length(ExtraInfo)
Entry = reverse(d2c(283,2)) || reverse(d2c(5,2)) || reverse(d2c(1,4)) || reverse(d2c(Offset,4))

ExtraInfo = ExtraInfo || reverse(d2c(v1,4)) || reverse(d2c(v2,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 12. Units */
Entry = reverse(d2c(296,2)) || reverse(d2c(3,2)) || reverse(d2c(1,4)) || reverse(d2c(2,4))
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 13. Software */
Offset= 8 + IFDLength + length(ExtraInfo)
Software  = "Patterned after code by Doug Rickman, MSFC/NASA" 
Software  = Software || '00'x
LSoftware = length(software)

Entry     = reverse(d2c(305,2)) || reverse(d2c(1,2)) || reverse(d2c(LSoftware,4)) || reverse(d2c(Offset,4))

ExtraInfo = ExtraInfo || Software 
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 14. Date Time */
Offset= 8 + IFDLength + length(ExtraInfo)
Entry     = reverse(d2c(306,2)) || reverse(d2c(1,2)) || reverse(d2c(20,4)) || reverse(d2c(Offset,4))

parse value Date('S') with y 5 m 7 d
Date     = y':'m':'d
DateTime = Date Time('N') || '00'x

ExtraInfo = ExtraInfo || DateTime
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 15. Artist */
Offset= 8 + IFDLength + length(ExtraInfo)
Artist = "I doubt the artist is Doug Rickman."
Artist = Artist || '00'x
LArtist= length(Artist)

Entry     = reverse(d2c(315,2)) || reverse(d2c(1,2)) || reverse(d2c(LArtist,4)) || reverse(d2c(Offset,4))

ExtraInfo = ExtraInfo || Artist 
IFD = IFD || Entry
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */

/* 16. Color Table */
if NBands = 1 then do
   Offset= 8 + IFDLength + length(ExtraInfo)
   Entry     = reverse(d2c(320,2)) || reverse(d2c(3,2)) || reverse(d2c(768,4)) || reverse(d2c(Offset,4))

   ColorMap = ''
   do i = 0 to 255
      ColorMap  = ColorMap || reverse(d2c(256*Temp_red.i,2))
      end i
   do i = 0 to 255
      ColorMap  = ColorMap || reverse(d2c(256*Temp_green.i,2))
      end i
   do i = 0 to 255
      ColorMap  = ColorMap || reverse(d2c(256*Temp_blue.i,2))
      end i
   ExtraInfo = ExtraInfo || ColorMap
   IFD = IFD || Entry
   end

else nop

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */


/* End of IFD.  Write 4 zeros. */
IFD = IFD || reverse(d2c(0,4))
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   */


/* Now compute the strip offsets and replace the Spacer used in entry 6.     */
DataStart = 8 + IFDLength + length(ExtraInfo)

/* Strip Offsets, 1 per line. */
V = ''
do i = 0 to NLines-1
   Offset = DataStart + i*StripByteCounts    
   V = V || reverse(d2c(Offset,4))      
   end i

ExtraInfo = overlay(V,ExtraInfo,SpacerStart+1)

/* Now write out the IFD and Extra information. */
rc=charout(out,IFD||ExtraInfo,)

/* Now write the image data. */

/* Have to do this to avoid confusion inside the loops */
InitialRow2PinB   =InitialRow2Pin
LastRow2PinB      =LastRow2Pin     

select 
   when NBands = 1 then do
      y=0
      do LineLoop = InitialRow2PinB to LastRow2PinB by SampleRate 
         InitialRow2Pin   =LineLoop
         LastRow2Pin      =LineLoop
         /* Insert call to read routine here. */
         DataOut = ''
         do ElementLoop = InitialColumn2Pin to LastColumn2Pin  by SampleRate
            DataOut = DataOut || d2c(data.1.ElementLoop.LineLoop) 
            end ElementLoop
         rc=charout(out,DataOut)
         end LineLoop   
      end /* when .... */

   otherwise do
      y=0
      do LineLoop = InitialRow2PinB to LastRow2PinB  by SampleRate
         InitialRow2Pin   =LineLoop
         LastRow2Pin      =LineLoop
         /* Insert call to read routine here. */
         DataOut = ''
         do ElementLoop = InitialColumn2Pin to LastColumn2Pin  by SampleRate
            DataOut = DataOut || d2c(data.2.ElementLoop.LineLoop) || d2c(data.3.ElementLoop.LineLoop) || d2c(data.1.ElementLoop.LineLoop)  
            end ElementLoop
         rc=charout(out,DataOut)
         end LineLoop
      end /* otherwise do ... */

   end /* end select */
rc=stream(out,'c','close')

return 1

ContinuedFraction:
/* Given a real number find two integers that closely approximate.  By       */
/* Ian Collier, Feb. 28, 2000 via posting in comp.lang.rexx.  Mod. D Rickman.*/
/* "maxnum" gives the maximum value for either the numerator or denominator. */
procedure

realno = arg(1)
   
numeric digits 100
maxnum = 2**31 -1
   
parse value 0 1 1 0 with p0 p q0 q
do while p<maxnum & q<maxnum
   n=trunc(realno)
   parse value p n*p+p0 with p0 p
   parse value q n*q+q0 with q0 q
   if n=realno then do
      /* say "Exact representation found:" */
      p0=p
      q0=q
      leave
   end
   realno=1/(realno-n)
end

/* say p0 '/' q0 '=' p0/q0  */

return p0 q0


