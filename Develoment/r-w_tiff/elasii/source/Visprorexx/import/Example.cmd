/* Example program to read Tiff files using REXX.                            */
/* To use type Example filename where "filename" is a SMALL TIFF file.  The  */
/* code can handle large files, but this example is setup to dump the file   */
/* values to the screen.  Do you really want to wait while 100,000,000 lines */
/* scroll across the terminal?                                               */
/*                                                                           */
/* I make no pretense that this code is perfect, or that it even works.      */
/* I've not even attempted to code decompression algorithms.                 */
/* For some tags I have no known examples to test against.  Worse, I have    */
/* found a couple of errors that two fairly common OS/2 & UNIX programs make */
/* in writing TIFF files.  I've included work arounds for these in the code. */
/* If you find a bug and fix it I would be very grateful if you would send   */
/* the code to me.  If you don't want to fix it you can try sending a small  */
/* test file and a discription of the problem.  I might feel like messing    */
/* with it.  :-)                                                             */
/*                                                                           */
/* You are free to use and modify the code.  I ask you give credit where     */
/* appropriate.                                                              */
/*                                                                           */
/*                                                                           */
/* Doug Rickman Feb. 11, 2000; doug@hotrocks.msfc.nasa.gov                   */
/* version of March 6, 2000                                                  */

parse arg in

/* Open the .tiff and read the parameters needed.                            */
rc=ReadTIFFTags(in,'CHECKBYTES','QUIET') /* See ReadTIFFTags for options list*/
if rc = 0 then do
   say in' is probably not a TIFF file.'
   return -1 /* This is probably not a TIFF. */
   end

/* Read just the Image File Directories.                                     */
rc=ReadTIFFTags(in,'READ_IFD','SAY') /* Illustrates use of "SAY" option.     */

rc=ReadTIFFTags(in,'READTAGS','QUEUE') /* Illustrates use of "QUEUE" option. */
NPulls = queued()
   do i = 1 to NPulls
      pull v
      say v 
      end i

rc=ReadTIFFTags(in,'READTAGS','FILE') /* Illustrates use of "QUEUE" option.  */
                                    /* Will write log into tiff's directory. */
 
rc=ReadTIFFImage(in,1) /* Dump file values.  For this example values go to   */
                       /* console.  Don't try this with a large file!        */
if rc\=1 then say 'File could not be read'

return 1
/* End of root routine. */

/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  ReadTIFFTags:                        -------------*/

ReadTIFFTags:
/* Read all of the tags for all images in a  .tif file.                      */
/*                                                                           */
/*    ReadTIFFTags attempts to read all tags for all images in a file.       */
/* Values are placed as strings in either TIFFINFO.i._Value.Tag or in        */
/* TIFFINFO.i._Value.Tag.j if the number of values this variable may have is */
/* greater than one.  This is  done whether or not the tag is "understood."  */
/* The routine ReadIFD: is used to read an image file directory.  The        */
/* routine DeCodeTags: is used to read each tag.  Since tags may exist which */
/* either can not be read (probably due to a format this code does not       */
/* support) or a subroutine has not been created to decipher there has to be */
/* for the code to tell a calling routine that something is wrong with a     */
/* specific tag. Therefore two variables are created which indicate whether a*/
/* given tag can even be read or an image can be read. See below for details.*/
/* There is a separate subroutine for each tag.                              */
/*                                                                           */
/* Three arguments are passed to the main (this) routine:                    */
/*    in       - The name of the file to be read.                            */
/*    ReadData - ReadData can be set to:                                     */
/*       CHECKBYTES  - Check first 4 bytes for TIFF flag value,              */
/*       READ_IFD    - Read the image file directories.                      */
/*       READTAGS    - Read tags for all images.                             */
/*    Verbosity      - How information should be provided. Valid values are: */
/*       QUIET       - The default.  No textual information provided.        */
/*       FILE        - Textual information returned in queue.                */
/*       SAY         - Use the "SAY" instruction.                            */
/*       QUEUE       - Write information ot the session Queue.               */
/*                                                                           */
/* Returns:                                                                  */
/*     1 - File is a tif file and requested data are provided.               */
/*     0 - File is not a tif file.                                           */
/*    -1 - A valid value for ReadData was not provided.                      */
/*    -2 - The file could not be opened to read.                             */
/*    -3 - Bad argument for Verbosity.                                       */
/*                                                                           */
/*    The list of tags for each image is read into a compound variable,      */
/* TIFFINFO.i._Tag.j with the number of tags for the image in the 0th entry. */
/* The number of values and the value for each tag is read into              */
/* TIFFINFO.i._NValues.Tag and TIFFINFO.IFDCounter._Value.Tag  These are NOT */
/* "indexed arrays" with a value stored in TIFFINFO.IFDCounter._Value.0!     */
/* Rather, the value of "Tag" is the tag number as defined by the Tiff 6.0   */
/* specification document. Thus, to get the number of lines in image i look  */
/* in TIFFINFO.i._Value.257                                                  */
/*                                                                           */
/*    Most of the tag information is returned in the compound variable       */
/* TIFFINFO.  This is a description of the contents of TIFFINFO.:            */
/*    TIFFINFO.0                - The number of images                       */
/*    TIFFINFO.i._Tag.j         - The jth Tag for image i, an indexed "array"*/
/*                                1-TIFFINFO.i.0, with index 0 holding N Tags*/
/*    TIFFINFO.i._Type.Tag      - Data type for tag.  Tag # per Tiff Specs.  */
/*    TIFFINFO.i._NValues.Tag   - NValues for tag.  Tag # as per Tiff Specs. */
/*    TIFFINFO.i._Value.Tag     - Value for tag. Tag # as per Tiff Specs.    */
/*                                                                           */
/* Notes on TIFFINFO.i._Value.Tag:                                           */
/*    If the type is either 1, 2, or 3 TIFFINFO.i._Value.Tag will be the hex */
/* form of whatever was stored in Value after the return from ReadIFD.  Also */
/* the string ' Hex' will have been appended.  Subroutines which handle such */
/* tags must first strip the ' Hex' string and convert back to "character"   */
/* form.  The desired string will be present after the return from DeCodeTags*/
/*                                                                           */
/*    If the tag is defined as possibly having multiple values then value n  */
/* will be stored in TIFFINFO.i._Value.Tag.n and TIFFINFO.i._Value.Tag.0     */
/* will be set to the number of entries.  Thus a user of the tags can check  */
/* to see multiple entries are permitted by checking the value of            */
/* TIFFINFO.i._Value.Tag.0.  If multiple entries are not permitted this will */
/* not have been changed from the default string.                            */
/*                                                                           */
/* Some special entries in TIFFINFO. are created to ease programming:        */
/*    TIFFINFO.i._Color.j       - 16bit color, "Color"="Red"|"Green"|"Blue"  */
/*    TIFFINFO.i._ReadTagFlag.Tag - YES|NO, Tag of image i can be read       */
/*    TIFFINFO.i._ReadDataFlag  - YES|NO, Image i can be read                */
/*                                                                           */
/* Before attempting to read the values for an image's tags the state of     */
/*    TIFFINFO.i._ReadTagFlag.Tag is checked.  This is set in ReadIFD:.      */ 
/* Before attempting to read the image check                                 */
/*    the state of TIFFINFO.i._ReadDataFlag  This is set in DeCodeTags:.     */
/*                                                                           */
/*   Colors are indexed 0 - NColors, the number of color in the table is     */
/* TIFFINFO.IFDCounter._NValues.320/3   Color values are 16 bit.  To obtain  */
/* and 8 bit value divide by 256.  It appears that TIFF writers do no zero   */
/* out the color table for entries which are not used! If you need to avoid  */
/* reading/using non-meaningful color table entries... I don't know what to  */
/* do other than read the data file and check all recorded data values.      */
/*                                                                           */
/*    Tag subroutines read the information for a tag entry and then either   */
/* decipher the value field or go and read the TIFF file and decipher that   */
/* information.  When ever possible the information from a tag will be       */
/* written back into TIFFINFO.i._Value.Tag   Thus, in a sense one can think  */
/* of the tag subroutines as converting TIF formatted information into       */
/* strings that REXX can handle.                                             */
/*    Each tag reading subroutine returns either a 1 or a negative value.  If*/
/* a 1 is returned the tag was understood and the image data can be read.    */
/* A return of 1 does not guarantee the information in the tag will be used. */
/* It simply means the default reading software will execute.                */
/* This utilizes a subroutine for each tag. To handle a new tag number, add  */
/* the number to the "MasterTagList" variable and a subroutine for that tag. */
/*                                                                           */
/* Limitations: (that are not obvious)                                       */
/*    The TIFF standard allows the number of bits per sample (i.e. the bits  */
/* per channel) to be a variable.  This code and the subroutines assume that */
/* bits per sample is a constant.  Subroutine Tag258 makes this check.       */
/*    If the type is either Byte or ASCII and the number of values is small  */
/* enough to fit in 4 Bytes the value is supposed to be in the value field   */
/* of the directory entry.  I have no samples to test to be sure the code in */
/* ReadIFD actually handles this correctly.  And I suspect many TIFF writers */
/* don't do it according to Hoyle, as the point is a bit ambiguous in the    */
/* documentation.  In similar manner if type is 3 and number of values is 2  */
/* the information is supposed to be in the value field.  I do not have a    */
/* file to test this case either.                                            */ 
/*    Tag 339 specifies the nature of the values stored, integer, FP, etc.   */
/* If DeCodeTags does not return a value in TIFFINFO.i._Value.339.1 (which   */
/* happens when this tag is not specified) then TIFFINFO.i._Value.339.1 is   */
/* set to 1 (meaning unsigned integer data).  This is the default according  */
/* to the Tiff 6.0 document.                                                 */
/*    There are some tags at the end I have not finished, for example the    */
/* series of tags for JPEG images and tiling are not completed.  The         */
/* programmer would be well advised to examine the subroutines for the tags  */
/* and be sure they are returning useful values.  Please note I have         */
/* the code such that virtually all of the code for a tag can be simply      */
/* from another tag having the same type and number of values.  This may     */
/* waste code but it makes adding and modifying fucntionality much easier.   */
/*                                                                           */
/* Throughout this code and the tag subroutines are calls to Speaker2Animals:*/
/* That routine provides a standardized method of providing information back */
/* to the programmer or the user if the programmer so desires.  A call       */
/* to Speaker2Animals requires:                                              */
/*    in     - Input file, used to name an output file if action= 'FILE',    */
/*             May be blank.                                                 */
/*    Action - Speaker2Animals is to take. Values may be                     */
/*       DELETE  - Delete the existing output file.                          */
/*       QUIET   - The default.  No textual information provided.            */
/*       FILE    - Textual information returned in queue.                    */
/*       SAY     - Use the "SAY" instruction.                                */
/*       QUEUE   - Write information to the session Queue.                   */
/*    Txt        - The string to be written, said, etc.                      */
/*                                                                           */
/*                                                                           */
/* Doug Rickman Jan 28, 2000, ver. March 6,2000                              */

procedure expose TIFFINFO. TagList. (ExposeList)

numeric digits 20

drop TIFFINFO.

in       = arg(1)
ReadData = arg(2)
Verbosity= arg(3)

if Verbosity='' then Verbosity='QUIET'

OutLogFile=in'.ReadTIFFLog'

/* Check input options for validity. */
select 
   when ReadData='CHECKBYTES'  then nop
   when ReadData='READ_IFD'    then nop
   when ReadData='READTAGS'    then nop
   otherwise return -1 /* A valid value for ReadData was not provided.       */
   end  /* select */

select
   when Verbosity='QUIET' then nop
   when Verbosity='FILE'  then nop
   when Verbosity='SAY'   then nop
   when Verbosity='QUEUE' then nop
   otherwise return -3 /* Bad arguement. */
   end /* select */
   
rc=stream(in,'C','open read')
if rc\="READY:" then return -2 /* The file could not be opened to read.      */

/*       ------------------------------------------------------------        */
/*       ---------------        Check first 4 Bytes      ------------        */
/*       ------------------------------------------------------------        */
Order='Not a TIFF file.'
data=c2x(charin(in,1,4))
select
   when data='4D4D002A' then do /* Big-endian, i.e. motorola, swap bytes */
      /* say 'Big Endian' */
      order='BE'
      ReturnValue=1
      end
   when data='49492A00' then do /* Little-endian, i.e. Intel             */
      /* say 'Little Endian' */
      order='LE'
      ReturnValue=1
      end
   otherwise do
      ReturnValue=0
      end
   end /* select */

rc=Speaker2Animals(OutLogFile,'DELETE','')

/* Verbosity='SAY' */
rc=Speaker2Animals(OutLogFile,Verbosity,'Input file: 'in)
if Order='BE' then 
   rc=Speaker2Animals(OutLogFile,Verbosity,'Byte Order: BE - "Big Endian" "Motorola"')
else 
   rc=Speaker2Animals(OutLogFile,Verbosity,'Byte Order: LE - "little Endian" "Intel"')

rc=Speaker2Animals(OutLogFile,Verbosity,'')


/*    ------   Potential exit.   ------   */
if ReadData='CHECKBYTES' then do
   rc=stream(in,'C','close')
   return ReturnValue
   end


/*       ------------------------------------------------------------        */
/*       -------   Read list of (partially) supported tags   --------        */
/*       ------------------------------------------------------------        */
/* List of all tags for which there is a subroutine to read the tag contents.*/
MasterTagList = 254, /* NewSubFileType            */
                255, /* Subfiletype               */
                256, /* NElements                 */
                257, /* NLines                    */
                258, /* BitsPerSample             */
                259, /* Compression               */
                262, /* PhotometricInterpretation */
                263, /* Thresholding              */
                264, /* CellWidth                 */
                265, /* Dither Cell Length        */
                266, /* FillOrder                 */
                269, /* DocumentName              */
                270, /* ImageDescription          */
                271, /* Make                      */
                272, /* Model                     */
                273, /* StripOffsets              */
                274, /* Orientation               */
                277, /* Samples (Bands) PerPixel  */
                278, /* RowsPerStrip              */
                279, /* StripByteCounts           */
                280,
                281,
                282, /* X Resolution              */
                283, /* Y Resolution              */
                284, /* Planar Configuration      */
                285,
                286,
                287,
                288,
                289,
                290,
                291,
                292,
                293,
                296, /* Resolution unit           */
                297,
                301,
                305, /* Software                  */
                306, /* Date Time                 */
                315, /* Artist                    */
                316,
                317,
                318,
                319,
                320,
                321,
                322,
                323,
                324,
                325,
                332,
                333,
                334,
                336,
                337,
                338,
                339,
                340,
                341,
                342,  /* Reference B&W used        */
                512,  /* JPG information           */
                513,  /* JPG information           */
                514,  /* JPG information           */
                515,  /* JPG information           */
                517,  /* JPG information           */
                518,  /* JPG information           */
                519,  /* JPG information           */
                520,  /* JPG information           */
                521,  /* JPG information           */
                532,
              33432   /* Copyright                 */

do i = 1 to words(MasterTagList)
   parse var MasterTagList TagList.i MasterTagList
   end i
TagList.0= i-1

/*       ------------------------------------------------------------        */
/*       -----   Get Offset to the first Image File Directory.  -----        */
/*       ------------------------------------------------------------        */
Offset=charin(in,,4)
if order='LE' then Offset=reverse(Offset)
Offset=x2d(c2x(Offset))
TIFFINFO._IFDOffset.1=Offset

/*       ------------------------------------------------------------        */
/*       ---------    Read all Image File Directories.      ---------        */
/*       ------------------------------------------------------------        */
do i = 1
   ii=i+1
   rc    = ReadIFD(in,Offset,i,Verbosity,OutLogFile)
   parse var rc Offset 
      
   if Offset = 0 then leave i
   TIFFINFO._IFDOffset.i=Offset
   end i
TIFFINFO.0=i

/* Verbosity='SAY' */
if Verbosity='QUIET' then nop
else do
   Txt= 'Image#  Tag#  Type NValues Value/Offset'
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   do i=1 to TIFFINFO.0
      do j = 1 to TIFFINFO.i._Tag.0
         tag=TIFFINFO.i._tag.j
         txt=right(i,6),
             right(TIFFINFO.i._tag.j,5),
             right(TIFFINFO.i._Type.Tag,5),
             right(TIFFINFO.i._NValues.Tag,7),
             right(TIFFINFO.i._Value.Tag,12)
         rc=Speaker2Animals(OutLogFile,Verbosity,txt)
         end j
      rc=Speaker2Animals(OutLogFile,Verbosity,' ')
      end i
   rc=Speaker2Animals(OutLogFile,Verbosity,' ')
   end /* else do ... */

if ReadData='READ_IFD'   then do
   rc=stream(in,'C','close')
   return 1
   end

/*       ------------------------------------------------------------        */
/*       -----   Read the information in the tags for all images. ---        */
/*       ------------------------------------------------------------        */
do i=1 to TIFFINFO.0
   rc=DeCodeTags(in,i,order,Verbosity,OutLogFile)

   /* This makes sure there is a value for the sample format tag. This means */
   /* unsigned integer data, which is the default.                           */
   if TIFFINFO.i._Value.339.1='TIFFINFO.'i'._VALUE.339.1' then do 
      TIFFINFO.i._Value.339.1=1
      TIFFINFO.i._Value.339.0=1
      end

   end i

rc=stream(in,'C','close')
return 1

/*       ------------------------------------------------------------        */
/*       ------      End of ReadTIFFTags:                     -------        */
/*       ------------------------------------------------------------        */


/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  ReadIFD                              -------------*/
/* Read the image file directory (IFD) for image IFDCounter.  This will      */
/* obtain the number of tags for this image, and for each tag the type,      */
/* number of values and the "value."  Remember the value can be either the   */
/* information sought or a Byte offset to where the information is stored.   */

ReadIFD:
procedure expose TIFFINFO. Order

in         = arg(1)
Offset     = arg(2)
IFDCounter = arg(3)
Verbosity  = arg(4)  /* Argument to Speaker2Animals: See subroutine header.  */
OutLogFile = arg(5)  /* File to receive output from Speaker2Animals.         */

ReadDataFlag='YES'
/* trace ?i */
rc=stream(in,'c','seek ='Offset+1 )
NTags=charin(in,,2)

if order='LE' then NTags=reverse(NTags)
TIFFINFO.IFDCounter._Tag.0=x2d(c2x(NTags))

/* Note to programmer, comment the next line out to get dump under control   */
/* calling program.                                                          */
Verbosity='QUIET' 
rc=Speaker2Animals(OutLogFile,Verbosity,'Image Number: 'IFDCounter)
rc=Speaker2Animals(OutLogFile,Verbosity,'Offset to IFD: 'Offset)
rc=Speaker2Animals(OutLogFile,Verbosity,'Number of Tags: 'TIFFINFO.IFDCounter._Tag.0)

/* TIFFINFO.IFDCounter.0 */

do i=1 to TIFFINFO.IFDCounter._Tag.0
   data=charin(in,,12)

   parse var data tag 3 type 5 NValues 9 Value
   if order='LE' then do
      tag     = reverse(tag)
      type    = reverse(type)
      NValues = reverse(NValues)
      end
   Tag = x2d(c2x(tag))
   TIFFINFO.IFDCounter._Tag.i       = tag 
   TIFFINFO.IFDCounter._Type.Tag    = x2d(c2x(type)) 
   TIFFINFO.IFDCounter._NValues.Tag = x2d(c2x(NValues)) 

   TIFFINFO.IFDCounter._ReadTagFlag.Tag='YES'
   
/*                                                                           */
/* From the TIFF 6 documentation.                                            */
/* Types                                                                     */
/*  The field types and their sizes are:                                     */
/*  1 = BYTE 8-bit unsigned integer.                                         */
/*  2 = ASCII 8-bit byte that contains a 7-bit ASCII code; the last byte     */
/*      must be NUL (binary zero).                                           */
/*  3 = SHORT 16-bit (2-byte) unsigned integer.                              */
/*  4 = LONG 32-bit (4-byte) unsigned integer.                               */
/*  5 = RATIONAL Two LONGs: the first represents the numerator of a fraction;*/
/*      the second, the denominator.                                         */
/*  6 = SBYTE An 8-bit signed (twos-complement) integer.                     */
/*  7 = UNDEFINED An 8-bit byte that may contain anything, depending on the  */
/*      definition of the field.                                             */
/*  8 = SSHORT A 16-bit (2-byte) signed (twos-complement) integer.           */
/*  9 = SLONG A 32-bit (4-byte) signed (twos-complement) integer.            */
/*  10 = SRATIONAL Two SLONG s: the first represents the numerator of a      */
/*       fraction, the second the denominator.                               */
/*  11 = FLOAT Single precision (4-byte) IEEE format.                        */
/*  12 = DOUBLE Double precision (8-byte) IEEE format.                       */
/*                                                                           */
            
   select   
      when TIFFINFO.IFDCounter._Type.Tag=1 then do
         /* Value could be 1-4 Bytes of data or an offset. */
         TIFFINFO.IFDCounter._Value.Tag=c2x(Value) 'Hex'
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='YES'
         end
      when TIFFINFO.IFDCounter._Type.Tag=2 then do
         /* Value could be 1-3 Bytes of ASCII data or offset. */
         TIFFINFO.IFDCounter._Value.Tag=c2x(Value) 'Hex'
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='YES'
         end
      when TIFFINFO.IFDCounter._Type.Tag=3 then do
         /* Value could be 1 or 2 numbers or offset. */
         TIFFINFO.IFDCounter._Value.Tag=c2x(Value) 'Hex'
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='YES'
         end
      when TIFFINFO.IFDCounter._Type.Tag=4 then do
         /* "Value" may be either a value of offset. */
         if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
         else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value)) 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='YES'
         end
      when TIFFINFO.IFDCounter._Type.Tag=5 then do
         /* "Value" has to be an offset. */
         if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
         else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value)) 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='YES'
         end
      when TIFFINFO.IFDCounter._Type.Tag=6  then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      when TIFFINFO.IFDCounter._Type.Tag=7  then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      when TIFFINFO.IFDCounter._Type.Tag=8  then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      when TIFFINFO.IFDCounter._Type.Tag=9  then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      when TIFFINFO.IFDCounter._Type.Tag=10 then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      when TIFFINFO.IFDCounter._Type.Tag=11 then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      when TIFFINFO.IFDCounter._Type.Tag=12 then 
         TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      otherwise TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
         
      end  /* select */   

   end i

/* Are there more IFDs? */
Offset=charin(in,,4)
Offset=x2d(c2x(Offset))
return Offset

/* --- end subroutine   -  ReadIFD                              -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  DeCodeTags                           -------------*/
/* Read through the list of tags for an image, be sure there is a subroutine */
/* that can handle that tag.  Then call the subroutine and decipher the      */
/* information for that tag.                                                 */
/* Any time a tag reading subroutine cann't understand the values in a tag   */
/* OR knows the reading software can not read a given structure, AND controls*/
/* the READING OF THE DATA will return a negative value.  This will cause    */
/* this routine to return a "NO" to the calling routine.                     */

DeCodeTags:
procedure expose TIFFINFO. TagList.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Verbosity  = arg(4)  /* Argument to Speaker2Animals: See subroutine header.  */
OutLogFile = arg(5)  /* File to receive output from Speaker2Animals.         */

TIFFINFO.IFDCounter._ReadDataFlag='YES'
ReadDataFlag='YES'  

/* Verbosity='SAY' */

do i=1 to TIFFINFO.IFDCounter._Tag.0
   do k=1 to TagList.0    
      if TagList.k=TIFFINFO.IFDCounter._Tag.i then leave k
      end k
   Tag=TIFFINFO.IFDCounter._Tag.i
   if k > TagList.0 then do
      Txt= 'An unrecognized tag: 'Tag 'has been found.  It has',
           'data type: 'TIFFINFO.IFDCounter._Type.Tag,
           'Number of Values: 'TIFFINFO.IFDCounter._NValues.Tag,
           'Value/Offset: 'TIFFINFO.IFDCounter._Value.Tag
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
      TIFFINFO.IFDCounter._ReadTagFlag.Tag='NO'
      iterate i
      end

   /* Be sure this tag can be read.  This may be set in ReadIFD:             */
   if TIFFINFO.IFDCounter._ReadTagFlag.Tag = 'NO' then do
      Txt= 'Tag 'Tag' can not be read because the storage type is not supported.'
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
      iterate i
      end

   /* in         - Name of input file.                                       */
   /* IFDCounter - The number of the image being considered.                 */
   /* order      - LE|BE, Byte order.                                        */
   /* Tag        - The tag number to be processed.                           */
   /* Verbosity  - Argument to Speaker2Animals: See subroutine header.       */

   interpret 'rc= Tag'Tag'(in,IFDCounter,order,Tag,Verbosity,OutLogFile)'

   if rc \=1 then do
      ReadDataFlag='NO'
      TIFFINFO.IFDCounter._ReadDataFlag='NO'
      Txt= ' '
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
      Txt= '*** The subroutine for Tag 'Tag' has raised a flag indicating the image can not be read. ***'
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
      Txt= ' '
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
      end

   end i
return ReadDataFlag

/* --- end subroutine   -  DeCodeTags:                          -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  ReadTIFFImage:                       -------------*/
ReadTIFFIMage:
/* Read all of the tags for all images in a  .tif file.                      */
/* Returns:                                                                  */
/*     -1 - The Planar configuration is not supported.                       */
/*     -2 - The file could not be opened for reading.                        */
/*     -3 - ReadTiffTags found a tag or a tag value which is necessary to    */
/*          read the image but can not be handled either by ReadTiffTags or  */
/*          by this routine, "ReadTiffImage".                                */
/*     -4 - A tag which must be read by this routine can not be read.        */
/*     -5 - Reader for this format not yet implemented.                      */

procedure expose TIFFINFO. TagList. (ExposeList)

in         = arg(1)
IFDCounter = arg(2)

if TIFFINFO.IFDCounter._ReadDataFlag = "YES" then nop
else return -3

rc=stream(in,'C','open read')
if rc\="READY:" then return -2 /* The file could not be opened to read.      */

/* Make checks. */
/* Number of elements. */
if TIFFINFO.IFDCounter._ReadTagFlag.256 = 'NO' then 
   return -4

/* Number of lines. */
if TIFFINFO.IFDCounter._ReadTagFlag.257 = 'NO' then 
   return -4

/* Number of Bits per pixel. */
/* This makes the assumption that all channels have the same number of Bytes.*/
if TIFFINFO.IFDCounter._ReadTagFlag.258 = 'NO' then 
   return -4

/* Photometric Interpretation. */
if TIFFINFO.IFDCounter._ReadTagFlag.262 = 'NO' then 
   return -4

/* Number of strips. */
if TIFFINFO.IFDCounter._ReadTagFlag.273 = 'NO' then 
   return -4

/* Sample per Pixel. */
if TIFFINFO.IFDCounter._ReadTagFlag.277 = 'NO' then 
   return -4

/* RowsPerStrip. */
if TIFFINFO.IFDCounter._ReadTagFlag.278 = 'NO' then 
   return -4

/* Data format. */
if TIFFINFO.IFDCounter._ReadTagFlag.284 = 'NO' then 
   return -4
if TIFFINFO.IFDCounter._Value.284 \= 1 then return -1  /* A unsupported format. */

if TIFFINFO.IFDCounter._Value.339.1=3 then
   return -6 /* The data are floating point. */


/* Photometric Interpretation. */
PhotometricInterpretation = TIFFINFO.IFDCounter._Value.262

select 
   when PhotometricInterpretation=2 then /* RGB     */
      ReturnValue = ReadTiffImageRGB(in,IFDCounter)

   when PhotometricInterpretation=3 then /* Palette */
      ReturnValue = ReadTiffImagePalette(in,IFDCounter)
      
   otherwise ReturnValue = -5
   end /* end select */

return ReturnValue
/* --- end subroutine   -  ReadTIFFImage:                       -------------*/
/* --------------------------------------------------------------------------*/


/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  ReadTIFFImagePalette:                -------------*/
/* Read the image data into the compound variable data.k.i.j, where k=1,2 or */
/* 3 (R,G,B), and i is element (column) 1 - NElements, and h is line (row)   */
/* 1 - NLines.  Extra samples if present are dropped.                        */
/* If memory is a problem insert code at either "Point A" or "Point B" to    */
/* save the data and then drop the variable Data.                            */

ReadTiffImagePalette:
procedure expose TIFFINFO.  Data.

in         = arg(1)
IFDCounter = arg(2)

drop Data.

NStrips         = TIFFINFO.IFDCounter._Value.273.0
RowsPerStrip    = TIFFINFO.IFDCounter._Value.278
NElements       = TIFFINFO.IFDCounter._Value.256
NLines          = TIFFINFO.IFDCounter._Value.257
NBitsPerPixel   = TIFFINFO.IFDCounter._Value.258.1

v=(NBitsPerPixel/8)*NElements
NBytesPerLine=trunc(v)+(v>0)*(v\=trunc(v))  /* Ceiling operation. */

select
   when NBitsPerPixel=4 then do
      /* This gets used after the data have been converted to Hex. */
      LineParse=NBytesPerLine*2 + 1 
      select
         when TIFFINFO.IFDCounter._Value.339.1=1 then Precision=2
         when TIFFINFO.IFDCounter._Value.339.1=2 then Precision=1
         when TIFFINFO.IFDCounter._Value.339.1=4 then Precision=2
         otherwise do
            say ' Doug goofed yet again.'
            return -5
            end
         end /* select */               
      end
   when NBitsPerPixel=8 then do
      LineParse=NBytesPerLine+1
      select
         when TIFFINFO.IFDCounter._Value.339.1=1 then Precision=4
         when TIFFINFO.IFDCounter._Value.339.1=2 then Precision=2
         when TIFFINFO.IFDCounter._Value.339.1=4 then Precision=4
         otherwise do
            say ' Doug goofed yet again.'
            return -5
            end
         end /* select */      
      end
   otherwise return -5
   end /* select */


/* At some point if I will want to read just a part of an image.  These      */
/* variable will be needed then.                                             */
StartStripN = 1
LastStripN = NStrips

h = 0       /* This is the line counter. */

/* Get offset for each strip and read the strip. */
do strip = StartStripN to LastStripN

   offset=TIFFINFO.IFDCounter._Value.273.strip   
   Length=TIFFINFO.IFDCounter._Value.279.strip
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)

   if NBitsPerPixel=4 then do
      Data=c2x(data) /* Convert the data to hex. */
      do Row = 1 to RowsPerStrip
         h = h+1 /* Line counter. */
         /* Extract a single line of data and break into elements. */
         parse var data LineData =(LineParse) data
         do i = 1 to NElements
            parse var LineData v 2 LineData
            v=x2d(v,Precision)

            /* Two choices are available.  The programmer may turn on either or both. */
            /* Option 1: returns the value recorded in the file. */
            data.1.i.h  = v

            say 'el: 'right(i,6) 'Line: 'right(h,6) ' ' right(v,3),
               right(TIFFINFO.IFDCounter._Red.v,5),
               right(TIFFINFO.IFDCounter._Green.v,5),
               right(TIFFINFO.IFDCounter._Blue.v,5)            
                        
            /* Option 2: returns the RGB values in separate channels. */
            data.1.i.h=TIFFINFO.IFDCounter._Red.v
            data.2.i.h=TIFFINFO.IFDCounter._Green.v
            data.3.i.h=TIFFINFO.IFDCounter._Blue.v

            end i
         if h=NLines then leave strip /* Last strip may not have as many rows.*/
         end Row
      end /* if ... =4 then do ... */
   
   else do
      do Row = 1 to RowsPerStrip
         h = h+1 /* Line counter. */
         /* Extract a single line of data and break into elements. */
         parse var data LineData =(LineParse) data
         do i = 1 to NElements
            parse var LineData v 2 LineData
            v=c2d(v,Precision)

            say 'el: 'right(i,6) 'Line: 'right(h,6) ' ' right(v,3),
               right(TIFFINFO.IFDCounter._Red.v,5),
               right(TIFFINFO.IFDCounter._Green.v,5),
               right(TIFFINFO.IFDCounter._Blue.v,5)            
                        
            /* Two choices are available.  The programmer may turn on either or both. */
            /* Option 1: returns the value recorded in the file. */
            data.1.i.h  = v
                        
            /* Option 2: returns the RGB values in separate channels. */
            data.1.i.h=TIFFINFO.IFDCounter._Red.v
            data.2.i.h=TIFFINFO.IFDCounter._Green.v
            data.3.i.h=TIFFINFO.IFDCounter._Blue.v
            
            end i
         if h=NLines then leave strip /* Last strip may not have as many rows.*/
         end Row
      end /* else do ... */
   end strip
rc=stream(in,'C','close')

return 1
/* --- end subroutine   -  ReadTIFFImagePalette:                -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  ReadTIFFImageRGB:                    -------------*/
/* Read the image data into the compound variable data.k.i.j, where k=1,2 or */
/* 3 (R,G,B), and i is element (column) 1 - NElements, and h is line (row)   */
/* 1 - NLines.  Extra samples if present are dropped.                        */
/* If memory is a problem insert code at either "Point A" or "Point B" to    */
/* save the data and then drop the variable Data.                            */

ReadTiffImageRGB:
procedure expose TIFFINFO.  Data.

in         = arg(1)
IFDCounter = arg(2)

drop Data.

if TIFFINFO.IFDCounter._Value.339.1  = 3 then return -5 /* FP data       */
if TIFFINFO.IFDCounter._Value.258.1 \= 8 then return -5 /* NBitsPerPixel */

NStrips         = TIFFINFO.IFDCounter._Value.273.0
RowsPerStrip    = TIFFINFO.IFDCounter._Value.278
NElements       = TIFFINFO.IFDCounter._Value.256
NLines          = TIFFINFO.IFDCounter._Value.257
SamplesPerPixel = TIFFINFO.IFDCounter._Value.277

NBytesPerLine        = NElements*SamplesPerPixel

LineParse            = NBytesPerLine+1
SamplesPerPixelParse = SamplesPerPixel+1

/* At some point if I will want to read just a part of an image.  These      */
/* variable will be needed then.                                             */
StartStripN = 1
LastStripN = NStrips

h = 0       /* This is the line counter. */

/* Get offset for each strip and read the strip. */
do strip = StartStripN to LastStripN

   offset=TIFFINFO.IFDCounter._Value.273.strip   
   Length=TIFFINFO.IFDCounter._Value.279.strip
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)

      do Row = 1 to RowsPerStrip
         h = h+1 /* Line counter. */
         /* Extract a single line of data and break into elements. */
         parse var data LineData =(LineParse) Data
         do i = 1 to NElements
            parse var LineData red 2 green 3 blue 4 . =(SamplesPerPixelParse) LineData
            data.1.i.h=c2d(red)
            data.2.i.h=c2d(green)
            data.3.i.h=c2d(blue)
            say 'el: 'right(i,6) 'Line: 'right(h,6) ' ',
               right(data.1.i.h,3),
               right(data.2.i.h,3),
               right(data.3.i.h,3)
            
            /* Point A - this access a single pixel at a time. */
            
            end i
         
         /* Point B - this access an entire line at a time. */
            
         if h=NLines then leave strip /* Last strip may not have as many rows.*/
         end Row
   end strip
rc=stream(in,'C','close')

return 1

/* --- end subroutine   -  ReadTIFFImageRGB:                    -------------*/
/* --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------*/
/* --- begin subroutine -  Speaker2Animals:                     -------------*/

Speaker2Animals:
/* Write or say information as needed.                                       */
/*                                                                           */
/* The output file is closed after each write.  This is slower, but no big   */
/* deal given the purpose and use of this routine.                           */
/*                                                                           */
/*                                                                           */
/* Three arguments are passed to the main routine:                           */
/*    in       - The name of the file to be read.                            */
/*    Verbosity      - How information should be provided. Valid values are: */
/*       DELETE      - Delete the existing output file.                      */
/*       QUIET       - The default.  No textual information provided.        */
/*       FILE        - Textual information returned in queue.                */
/*       SAY         - Use the "SAY" instruction.                            */
/*       QUEUE       - Write information to the session Queue.               */
/*    Txt            - The string to be written, said, etc.                  */
/*                                                                           */
/* Returns:                                                                  */
/*     1 - All is well.                                                      */
/*    -3 - Bad argument for Verbosity.                                       */
/*                                                                           */
/* If "FILE" is used output written to a file stored in the variable "out".  */
/* with the extension '.ReadTIFFLog' added.  This means you had better be    */
/*                                                                           */
/* It is up to you you to figure out the reference in this subroutine's name.*/
/* Hint: it is from a story by David Niven.                                  */

procedure expose TIFFINFO. TagList. (ExposeList)

out      = arg(1)
Verbosity= arg(2)
Txt      = arg(3)

if Verbosity='' then Verbosity='QUIET'

/* Check input parameter. */
select
   when Verbosity='DELETE' then do
      'del' out '2>> nul 1>>&2 '
      /* rc=dosdel(out) */ /* This uses REXXLIB.DLL, which is what I prefer. */
      return 1
      end
   when Verbosity='QUIET'  then nop
   when Verbosity='FILE' then do
      rc=lineout(out, Txt)
      rc=lineout(out)
      /* Closing the file after each write is slower, but it means the file  */
      /* can be examined while this subroutine is still running.             */
      end
   when Verbosity='SAY' then do
      say Txt
      end
   when Verbosity='QUEUE' then do
      queue Txt
      end
   otherwise return -3 /* Bad argument. */
   end /* select */


return 1
/* --- end subroutine   -  Speaker2Animals:                     -------------*/
/* --------------------------------------------------------------------------*/


/*       ------------------------------------------------------------        */
/*       -----------   Begin Subroutines to Read Tags    ------------        */
/*       ------------------------------------------------------------        */
/*       -----------     One Subroutine for each tag     ------------        */
/*       ---   A subroutine is named 'Tag'||the tag number||':'   ---        */
/*       ------------------------------------------------------------        */
/*  Standard Exposed variables:                                              */
/*     TIFFINFO.   - Compound variable, holds tags and other information.    */
/*                                                                           */
/*  Standard arguments:                                                      */
/*     in          - The name of the input file.                             */
/*     order       - LE|BE, Byte order.                                      */
/*     IFDCounter  - The number of the image being considered.               */
/*     Tag         - Tag to be processed.                                    */
/*     Verbosity   - Argument to Speaker2Animals:                            */
/* Subroutines which which handle tags whose values can be Byte, ASCII,      */
/* Short or Long (1,2,3,4 respectively) may have to determinine if the value */
/* in TIFFINFO.IFDCounter._Value.Tag are the numbers needed or an offset.    */
/*                                                                           */
/*    -----------------------------------------------------------------      */
Tag254:
/*    Name       Tag Hex Type  NValues                                       */
/* NewSubfileType 254 FE LONG 1                                              */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NewSubFileType = x2b(d2x(TIFFINFO.IFDCounter._Value.Tag,8))

Txt= 'Tag   254: "New Subfile Type"'

if substr(NewSubFileType,1,1)=1 then do
   Txt= Txt '  The image is a reduced resolution version of another image in this',
        ' TIFF file.'
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   return -1 
   end
if substr(NewSubFileType,2,1)=1 then do
   Txt= Txt '  The image is a single page of a multi-page image.'
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   return -2
   end
if substr(NewSubFileType,3,1)=1 then do
   Txt=Txt '  The image is a transparency mask for another image in this TIFF',
       ' file.  The PhotometricInterpretation value better =4. '
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   return -3
   end
return 1

/*    -----------------------------------------------------------------      */
Tag255:
/*    Name       Tag Hex Type  NValues                                       */
/* SubfileType   255 FF  SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

SubfileType=TIFFINFO.IFDCounter._Value.Tag

Txt= 'Tag   255: "Subfile Type"'

select  
   when SubfileType=1 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Full resolution image).')
      ReturnValue= 1
      end      
   when SubfileType=2 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Reduced resolution image).')
      ReturnValue= -1
      end
   when SubfileType=3 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Page from multi-page image).')
      ReturnValue= -2
      end
   otherwise do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown subfile type!)'
      ReturnValue= -3
      end
   end  /* select */
return ReturnValue

/*    -----------------------------------------------------------------      */
Tag256:
/*    Name       Tag Hex Type           NValues                              */
/* ImageWidth    256 100 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

select
   when TIFFINFO.IFDCounter._Type.Tag=3 then do
      parse var TIFFINFO.IFDCounter._Value.Tag Value .
      Value=x2c(Value)
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
      end
   
   otherwise nop /* Type = 4 */

   end /* select */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   256: "NElements"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag257:
/*    Name       Tag Hex Type           NValues                              */
/* ImageLength   256 100 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

select
   when TIFFINFO.IFDCounter._Type.Tag=3 then do
      parse var TIFFINFO.IFDCounter._Value.Tag Value .
      Value=x2c(Value)
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
      end
   
   otherwise nop /* Type = 4 */

   end /* select */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   257: "NLines"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag258:
/*    Name       Tag Hex Type  NValues                                       */
/* BitsPerSample 258 102 SHORT SamplesPerPixel                               */
/* An error is reported if the number of bits per channel is not constant.   */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

ReturnValue=1

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
         if order='LE' then do
            v1=x2d(c2x(reverse(v1)))
            v2=x2d(c2x(reverse(v2)))
            end
         else do
            v1=x2d(c2x(v1))
            v2=x2d(c2x(v2))
            end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))

      if Offset = 8 then do
         /* The bits per pixel is probably set wrong! PMView has this defect!*/
         do k=1  to TIFFINFO.IFDCounter._NValues.Tag
            TIFFINFO.IFDCounter._Value.Tag.k = 8
            end k
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
         end /* if ... = 8 then do ... */
         
      else do /* Value is an offset. */
         length=TIFFINFO.IFDCounter._NValues.Tag*NBytesPerValue
         rc=stream(in,'c','seek ='Offset+1)
         data=charin(in,,length)
      
         do k=1 to TIFFINFO.IFDCounter._NValues.Tag
            parse var data v 3 data
            if order='LE' then v=reverse(v)
            TIFFINFO.IFDCounter._Value.Tag.k = x2d(c2x(v))
            end k
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
        
         end /* else do ... */
      end /* otherwise */
   end /* end select */

/* Check to make sure same bits per pixel for all channels.            */
/* This is done to simplify the reading of the image data.             */
do k=2 to TIFFINFO.IFDCounter._NValues.Tag
   km1=k-1
   if TIFFINFO.IFDCounter._Value.Tag.km1 = TIFFINFO.IFDCounter._Value.Tag.k then nop
   else do
      rc=Speaker2Animals(OutLogFile,Verbosity,'*** The number of bits per sample is not constant. ***')
      ReturnValue=-1 
      end
   end k          

Txt= 'Tag   258: "Bits per Channel"'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Channel #Bits'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,22) right(TIFFINFO.IFDCounter._Value.Tag.K,5)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return ReturnValue



/*       ------------------------------------------------------------        */
/*       -----------   Begin Subroutines to Read Tags    ------------        */
/*       ------------------------------------------------------------        */
/*       -----------     One Subroutine for each tag     ------------        */
/*       ---   A subroutine is named 'Tag'||the tag number||':'   ---        */
/*       ------------------------------------------------------------        */
/*  Standard Exposed variables:                                              */
/*     TIFFINFO.   - Compound variable, holds tags and other information.    */
/*                                                                           */
/*  Standard arguments:                                                      */
/*     in          - The name of the input file.                             */
/*     order       - LE|BE, Byte order.                                      */
/*     IFDCounter  - The number of the image being considered.               */
/*     Tag         - Tag to be processed.                                    */
/*     Verbosity   - Argument to Speaker2Animals:                            */
/* Subroutines which which handle tags whose values can be Byte, ASCII,      */
/* Short or Long (1,2,3,4 respectively) may have to determinine if the value */
/* in TIFFINFO.IFDCounter._Value.Tag are the numbers needed or an offset.    */
/*                                                                           */
/*    -----------------------------------------------------------------      */
Tag254:
/*    Name       Tag Hex Type  NValues                                       */
/* NewSubfileType 254 FE LONG 1                                              */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NewSubFileType = x2b(d2x(TIFFINFO.IFDCounter._Value.Tag,8))

Txt= 'Tag   254: "New Subfile Type"'

if substr(NewSubFileType,1,1)=1 then do
   Txt= Txt '  The image is a reduced resolution version of another image in this',
        ' TIFF file.'
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   return -1 
   end
if substr(NewSubFileType,2,1)=1 then do
   Txt= Txt '  The image is a single page of a multi-page image.'
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   return -2
   end
if substr(NewSubFileType,3,1)=1 then do
   Txt=Txt '  The image is a transparency mask for another image in this TIFF',
       ' file.  The PhotometricInterpretation value better =4. '
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   return -3
   end
return 1

/*    -----------------------------------------------------------------      */
Tag255:
/*    Name       Tag Hex Type  NValues                                       */
/* SubfileType   255 FF  SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

SubfileType=TIFFINFO.IFDCounter._Value.Tag

Txt= 'Tag   255: "Subfile Type"'

select  
   when SubfileType=1 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Full resolution image).')
      ReturnValue= 1
      end      
   when SubfileType=2 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Reduced resolution image).')
      ReturnValue= -1
      end
   when SubfileType=3 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Page from multi-page image).')
      ReturnValue= -2
      end
   otherwise do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown subfile type!)'
      ReturnValue= -3
      end
   end  /* select */
return ReturnValue

/*    -----------------------------------------------------------------      */
Tag256:
/*    Name       Tag Hex Type           NValues                              */
/* ImageWidth    256 100 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

select
   when TIFFINFO.IFDCounter._Type.Tag=3 then do
      parse var TIFFINFO.IFDCounter._Value.Tag Value .
      Value=x2c(Value)
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
      end
   
   otherwise nop /* Type = 4 */

   end /* select */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   256: "NElements"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag257:
/*    Name       Tag Hex Type           NValues                              */
/* ImageLength   256 100 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

select
   when TIFFINFO.IFDCounter._Type.Tag=3 then do
      parse var TIFFINFO.IFDCounter._Value.Tag Value .
      Value=x2c(Value)
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
      end
   
   otherwise nop /* Type = 4 */

   end /* select */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   257: "NLines"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag258:
/*    Name       Tag Hex Type  NValues                                       */
/* BitsPerSample 258 102 SHORT SamplesPerPixel                               */
/* An error is reported if the number of bits per channel is not constant.   */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

ReturnValue=1

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
         if order='LE' then do
            v1=x2d(c2x(reverse(v1)))
            v2=x2d(c2x(reverse(v2)))
            end
         else do
            v1=x2d(c2x(v1))
            v2=x2d(c2x(v2))
            end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))

      if Offset = 8 then do
         /* The bits per pixel is probably set wrong! PMView has this defect!*/
         do k=1  to TIFFINFO.IFDCounter._NValues.Tag
            TIFFINFO.IFDCounter._Value.Tag.k = 8
            end k
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
         end /* if ... = 8 then do ... */
         
      else do /* Value is an offset. */
         length=TIFFINFO.IFDCounter._NValues.Tag*NBytesPerValue
         rc=stream(in,'c','seek ='Offset+1)
         data=charin(in,,length)
      
         do k=1 to TIFFINFO.IFDCounter._NValues.Tag
            parse var data v 3 data
            if order='LE' then v=reverse(v)
            TIFFINFO.IFDCounter._Value.Tag.k = x2d(c2x(v))
            end k
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
        
         end /* else do ... */
      end /* otherwise */
   end /* end select */

/* Check to make sure same bits per pixel for all channels.            */
/* This is done to simplify the reading of the image data.             */
do k=2 to TIFFINFO.IFDCounter._NValues.Tag
   km1=k-1
   if TIFFINFO.IFDCounter._Value.Tag.km1 = TIFFINFO.IFDCounter._Value.Tag.k then nop
   else do
      rc=Speaker2Animals(OutLogFile,Verbosity,'*** The number of bits per sample is not constant. ***')
      ReturnValue=-1 
      end
   end k          

Txt= 'Tag   258: "Bits per Channel"'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Channel #Bits'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,22) right(TIFFINFO.IFDCounter._Value.Tag.K,5)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return ReturnValue


/*    -----------------------------------------------------------------      */
Tag259:
/*    Name       Tag Hex Type  NValues                                       */
/* Compression   259 103 SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   259: "Compression"' TIFFINFO.IFDCounter._Value.Tag

Compression = TIFFINFO.IFDCounter._Value.Tag
select
   when Compression=1 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (No Compression).')
      ReturnValue= 1
      end
   when Compression=2 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (CCITT Group 3 1-D Modified Huffman run-length encoding).')
      ReturnValue= -1
      end
   when Compression=3 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (CCITT T.4 encoding).')
      ReturnValue= -2
      end
   when Compression=4 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (CCITT T..6 encoding).')
      ReturnValue= -3
      end
   when Compression=5 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (LZW Compression).')
      ReturnValue= -4
      end
   when Compression=6 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (JPEG Compression).')
      ReturnValue= -5
      end
   when Compression=32773 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Pack bits Compression).')
      ReturnValue= -6
      end
   otherwise do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown Compression).')
      ReturnValue= -7
      end
   end /* select */
return  ReturnValue

/*    -----------------------------------------------------------------      */
Tag262:
/*    Name                   Tag Hex Type  NValues                           */
/* PhotometricInterpretation 262 106 SHORT 1                                 */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   262: "Photometric Interpretation"' TIFFINFO.IFDCounter._Value.Tag

select
   when TIFFINFO.IFDCounter._Value.Tag=0  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Zero is White).')
      ReturnValue= -1
      end      
   when TIFFINFO.IFDCounter._Value.Tag=1  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Zero is Black).')
      ReturnValue= -2
      end
   when TIFFINFO.IFDCounter._Value.Tag=2  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (RGB data).')
      ReturnValue= 1
      end
   when TIFFINFO.IFDCounter._Value.Tag=3  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Color table [palette] used).')
      ReturnValue= 1
      end
   when TIFFINFO.IFDCounter._Value.Tag=4  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Transparency mask).')
      ReturnValue= -3
      end
   when TIFFINFO.IFDCounter._Value.Tag=6  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (YCC Color model).')
      ReturnValue= -4
      end
   when TIFFINFO.IFDCounter._Value.Tag=8  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (1976 CIE L*a*b* Color model).')
      ReturnValue= -5
      end
   otherwise do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown PhotometricInterpretation)!')
      ReturnValue= -6
      end
   end  /* select */
   
return  ReturnValue

/*    -----------------------------------------------------------------      */
Tag263:
/*    Name       Tag Hex Type  NValues                                       */
/* Threshholding 263 107 SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
end

Txt= 'Tag   263: "Threshholding"' TIFFINFO.IFDCounter._Value.Tag

select
   when TIFFINFO.IFDCounter._Value.Tag=1  then 
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (No dithering or halftone applied to image.)')
   when TIFFINFO.IFDCounter._Value.Tag=1  then 
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (An ordered dithering or halftone applied to image.)')
   when TIFFINFO.IFDCounter._Value.Tag=1  then 
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (A randomized dithering or halftone applied to image.)')   
   otherwise 
      rc=Speaker2Animals(OutLogFile,Verbosity,'Unknown thresholding value.')
end  /* select */
return 1

/*    -----------------------------------------------------------------      */
Tag264:
/*    Name       Tag Hex Type  NValues                                       */
/* CellWidth     264 108 SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   264: "Dither Cell Width"' TIFFINFO.IFDCounter._Value.Tag)

return 1

/*    -----------------------------------------------------------------      */
Tag265:
/*    Name       Tag Hex Type  NValues                                       */
/* CellLength    265 109 SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   265: "Dither Cell Length"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag266:
/*    Name       Tag Hex Type  NValues                                       */
/* FillOrder     266 10A SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

if TIFFINFO.IFDCounter._Type.Tag=3 then do
parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   266: "Fill Order"' TIFFINFO.IFDCounter._Value.Tag

select
   when TIFFINFO.IFDCounter._Value.Tag=1  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Pixels packed left to right in byte.)')
      ReturnValue = 1
      end
   when TIFFINFO.IFDCounter._Value.Tag=2  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Pixels packed right to left in byte.)')
      ReturnValue = -1
      end
   otherwise do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown FillOrder!)')
      ReturnValue = -2
      end
   end  /* select */
return 1

/*    -----------------------------------------------------------------      */
Tag269:
/*    Name       Tag Hex Type  NValues                                       */
/* DocumentName  269 10D ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end

DocumentName=strip(Data,'T','00'x)
DocumentName=translate(DocumentName,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag = DocumentName

Txt= 'Tag   269: "Document Name"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag270:
/*    Name          Tag Hex Type  NValues                                    */
/* ImageDescription 270 10E ASCII                                            */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end
ImageDescription = strip(Data,'T','00'x)
ImageDescription = translate(ImageDescription ,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag = ImageDescription

Txt= 'Tag   270: "Image Description"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag271:
/*    Name       Tag Hex Type  NValues                                       */
/*    Make       271 10F ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end

Make=strip(Data,'T','00'x)
Make=translate(Make,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag = Make

Txt= 'Tag   270: "Make"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag272:
/*    Name       Tag Hex Type  NValues                                       */
/*    Model      272 110 ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end
Model=strip(Data,'T','00'x)
Model=translate(Model,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag = Model

Txt= 'Tag   270: "Model"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag273:
/*    Name       Tag Hex Type          NValues                               */
/* StripOffsets  273 111 SHORT or LONG StripsPerImage                        */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NStrips=TIFFINFO.IFDCounter._NValues.Tag

/* Branch based on type. */
if TIFFINFO.IFDCounter._Type.Tag=3 then do
   parse var TIFFINFO.IFDCounter._Value.Tag Value .
   Value=x2c(Value)
   
   select   
      when NStrips=1 then do
         if order='LE' then TIFFINFO.IFDCounter._Value.Tag.1=x2d(c2x(reverse(Value)))
         else TIFFINFO.IFDCounter._Value.Tag.1=x2d(c2x(left(Value,2)))
         TIFFINFO.IFDCounter._Value.Tag.0=1
         end
      
      when NStrips=2 then do
         parse var Value v1 3 v2
            if order='LE' then do
               v1=x2d(c2x(reverse(v1)))
               v2=x2d(c2x(reverse(v2)))
               end
            else do
               v1=x2d(c2x(v1))
               v2=x2d(c2x(v2))
               end
         TIFFINFO.IFDCounter._Value.Tag.1 = v1
         TIFFINFO.IFDCounter._Value.Tag.2 = v2
         TIFFINFO.IFDCounter._Value.Tag.0 = 2
         end
      
      otherwise do /* Value is an offset. */
         if order='LE' then 
            Offset=x2d(c2x(reverse(Value)))
         else 
            Offset=x2d(c2x(Value))
         rc=stream(in,'c','seek ='Offset+1 )
         Length=NStrips*2 /* Bytes in a SHORT */
         Data=charin(in,,Length)
         do i= 1 to NStrips
            parse var Data v 3 Data
            if order='LE' then v=reverse(v)
            TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
            end i
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
         end
      end /* Select */
   end /* if type=3 then do ... */

else do /* type = 4. */

   select 
      when NStrips=1 then do
         TIFFINFO.IFDCounter._Value.Tag.1=TIFFINFO.IFDCounter._Value.Tag
         TIFFINFO.IFDCounter._Value.Tag.0=1
         end

      otherwise do
         Offset=TIFFINFO.IFDCounter._Value.Tag
         rc=stream(in,'c','seek ='Offset+1 )
         Length=NStrips*4 /* Bytes in a LONG  */
         Data=charin(in,,Length)
         do i= 1 to NStrips
            parse var Data v 5 Data
            if order='LE' then v=reverse(v)
            TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))      
            end i
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
         end /* otherwise do ... */
      end /* end select */
   end /* else do ... */


Txt= 'Tag   273: "Strip Offsets"'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Strip OffsetByte'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,20) right(TIFFINFO.IFDCounter._Value.Tag.K,10)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return 1

/*    -----------------------------------------------------------------      */
Tag274:
/*    Name       Tag Hex Type  NValues                                       */
/* Orientation   274 112 SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Orientation=TIFFINFO.IFDCounter._Value.Tag

Txt= 'Tag   274: "Orientation"' TIFFINFO.IFDCounter._Value.Tag

select
   when Orientation=1  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image is right side up and left to right.)')
      ReturnValue=1
      end
   when Orientation=2  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image is right side up and right to left.)')
      ReturnValue= 1
      end
   when Orientation=3  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image is upside down and right to left.)')
      ReturnValue= 1
      end
   when Orientation=4  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image is upsidedown and left to right.)')
      ReturnValue= 1
      end
   when Orientation=5  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image rows and colomns are swapped.)')
      ReturnValue=-4
      end
   when Orientation=6  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image rows and columns are swapped and right to left.)')
      ReturnValue=-5
      end
   when Orientation=7  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image rows and columns are swapped and upside down and right to left.)')
      ReturnValue=-6
      end
   when Orientation=8  then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Image rows and columns are swapped and upside down.)')
      ReturnValue=-7
      end
   otherwise  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '   (Unknown Orientation.)')
      ReturnValue=-8
      end

   end  /* select */
return ReturnValue

/*    -----------------------------------------------------------------      */
Tag277:
/*    Name         Tag Hex Type  NValues                                     */
/* SamplesPerPixel 277 115 SHORT 1                                           */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   277: "Samples (Channels) per Pixel"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag278:
/*    Name       Tag Hex Type          NValues                               */
/* RowsPerStrip  278 116 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

if TIFFINFO.IFDCounter._Type.Tag=3 then do
   parse var TIFFINFO.IFDCounter._Value.Tag Value .
   Value=x2c(Value)
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
   end

else nop

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   278: "Rows per Strip"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag279:
/*    Name         Tag Hex Type          NValues                             */
/* StripByteCounts 279 117 LONG or SHORT StripsPerImage                      */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

/* Branch based on type. */
if TIFFINFO.IFDCounter._Type.Tag=3 then do
   parse var TIFFINFO.IFDCounter._Value.Tag Value .
   Value=x2c(Value)
   
   select   
      when TIFFINFO.IFDCounter._NValues.Tag=1 then do
         if order='LE' then TIFFINFO.IFDCounter._Value.Tag.1=x2d(c2x(reverse(Value)))
         else TIFFINFO.IFDCounter._Value.Tag.1=x2d(c2x(left(Value,2)))
         TIFFINFO.IFDCounter._Value.Tag.0=1
         end
      
      when TIFFINFO.IFDCounter._NValues.Tag=2 then do
         parse var Value v1 3 v2
            if order='LE' then do
               v1=x2d(c2x(reverse(v1)))
               v2=x2d(c2x(reverse(v2)))
               end
            else do
               v1=x2d(c2x(v1))
               v2=x2d(c2x(v2))
               end
         TIFFINFO.IFDCounter._Value.Tag.1 = v1
         TIFFINFO.IFDCounter._Value.Tag.2 = v2
         TIFFINFO.IFDCounter._Value.Tag.0 = 2
         end
      
      otherwise do /* Value is an offset. */
         if order='LE' then 
            Offset=x2d(c2x(reverse(Value)))
         else 
            Offset=x2d(c2x(Value))
         rc=stream(in,'c','seek ='Offset+1 )
         Length=TIFFINFO.IFDCounter._NValues.Tag*2 /* Bytes in a SHORT */
         Data=charin(in,,Length)
         do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
            parse var Data v 3 Data
            if order='LE' then v=reverse(v)
            TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
            end i
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
         end
      end /* Select */
   end /* if type=3 then do ... */

else do /* type = 4. */
   select 
      when TIFFINFO.IFDCounter._NValues.Tag=1 then do
         TIFFINFO.IFDCounter._Value.Tag.1=TIFFINFO.IFDCounter._Value.Tag
         TIFFINFO.IFDCounter._Value.Tag.0=1
         end

      otherwise do
         Offset=TIFFINFO.IFDCounter._Value.Tag
         rc=stream(in,'c','seek ='Offset+1 )
         Length=TIFFINFO.IFDCounter._NValues.Tag*4 /* Bytes in a LONG  */
         Data=charin(in,,Length)
         do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
            parse var Data v 5 Data
            if order='LE' then v=reverse(v)
            TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))      
            end i
         TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
         end /* otherwise do ... */
      end /* end select */
   end /* else do ... */


Txt= 'Tag   279: "Strip Byte Counts"'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Strip     #Bytes'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,20) right(TIFFINFO.IFDCounter._Value.Tag.K,10)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return 1

/*    -----------------------------------------------------------------      */
Tag280:
/*    Name        Tag Hex Type  NValues                                      */
/* MinSampleValue 280 118 SHORT SamplesPerPixel                              */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
         if order='LE' then do
            v1=x2d(c2x(reverse(v1)))
            v2=x2d(c2x(reverse(v2)))
            end
         else do
            v1=x2d(c2x(v1))
            v2=x2d(c2x(v2))
            end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))
      rc=stream(in,'c','seek ='Offset+1 )
      Length=TIFFINFO.IFDCounter._NValues.Tag*2 /* Bytes in a SHORT */
      Data=charin(in,,Length)
      do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
         parse var Data v 3 Data
         if order='LE' then v=reverse(v)
         TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
         end i
      TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
      end

   end /* end select */

Txt= 'Tag   280: Minimum Sample Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Channel Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,22) right(TIFFINFO.IFDCounter._Value.Tag.K,5)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return 1

/*    -----------------------------------------------------------------      */
Tag281:
/*    Name        Tag Hex Type  NValues                                      */
/* MaxSampleValue 281 119 SHORT SamplesPerPixel                              */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
         if order='LE' then do
            v1=x2d(c2x(reverse(v1)))
            v2=x2d(c2x(reverse(v2)))
            end
         else do
            v1=x2d(c2x(v1))
            v2=x2d(c2x(v2))
            end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))
      rc=stream(in,'c','seek ='Offset+1 )
      Length=TIFFINFO.IFDCounter._NValues.Tag*2 /* Bytes in a SHORT */
      Data=charin(in,,Length)
      do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
         parse var Data v 3 Data
         if order='LE' then v=reverse(v)
         TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
         end i
      TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
      end

   end /* end select */

Txt= 'Tag   280: Maximum Sample Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Channel Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,22) right(TIFFINFO.IFDCounter._Value.Tag.K,5)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return 1

/*    -----------------------------------------------------------------      */
Tag282:
/*    Name       Tag Hex Type     NValues                                    */
/* XResolution   282 11A RATIONAL 1                                          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Offset=TIFFINFO.IFDCounter._Value.Tag
rc=stream(in,'c','seek ='Offset+1 )
Data=charin(in,,8)
parse var Data v1 5 v2

if order='LE' then do
   v1=x2d(c2x(reverse(v1)))
   v2=x2d(c2x(reverse(v2)))
   end   
else do
  v1=x2d(c2x(v1)) 
  v2=x2d(c2x(v2)) 
  end
NPixelsPerResolutionUnitX=v1/v2
TIFFINFO.IFDCounter._Value.Tag=NPixelsPerResolutionUnitX

Txt= 'Tag   282: "Number of Pixels per Resolution Unit, X axis"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag283:
/*    Name       Tag Hex Type     NValues                                    */
/* YResolution   283 11B RATIONAL 1                                          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Offset=TIFFINFO.IFDCounter._Value.Tag
rc=stream(in,'c','seek ='Offset+1 )
Data=charin(in,,8)
parse var Data v1 5 v2

if order='LE' then do
   v1=x2d(c2x(reverse(v1)))
   v2=x2d(c2x(reverse(v2)))
   end   
else do
  v1=x2d(c2x(v1)) 
  v2=x2d(c2x(v2)) 
  end
NPixelsPerResolutionUnitY=v1/v2
TIFFINFO.IFDCounter._Value.Tag=NPixelsPerResolutionUnitY

Txt= 'Tag   283: "Number of Pixels per Resolution Unit, Y axis"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag284:
/*    Name             Tag Hex Type  NValues                                 */
/* PlanarConfiguration 284 11C SHORT 1                                       */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   284: "Planar Configuration"' TIFFINFO.IFDCounter._Value.Tag

select
   when TIFFINFO.IFDCounter._Value.Tag=1  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (components for each pixel stored contiguously).')
      ReturnValue =1
      end
   when TIFFINFO.IFDCounter._Value.Tag=2  then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (components stored sequentially as planes).')
      ReturnValue =-1
      end
   otherwise do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown Planar Configuration)!')
      ReturnValue =-1
      end
   end  /* select */
return ReturnValue

/*    -----------------------------------------------------------------      */
Tag285:
/*    Name       Tag Hex Type  NValues                                       */
/* PageName      285 11D ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end
PageName=strip(Data,'T','00'x)
PageName=translate(PageName,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=PageName

Txt= 'Tag   285: "Page Name"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag286:
/*    Name       Tag Hex Type     NValues                                    */
/* XPosition     286 11E RATIONAL                                            */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Offset=TIFFINFO.IFDCounter._Value.Tag
rc=stream(in,'c','seek ='Offset+1 )
Data=charin(in,,8)
parse var Data v1 5 v2

if order='LE' then do
   v1=x2d(c2x(reverse(v1)))
   v2=x2d(c2x(reverse(v2)))
   end   
else do
  v1=x2d(c2x(v1)) 
  v2=x2d(c2x(v2)) 
  end

TIFFINFO.IFDCounter._Value.Tag=v1/v2

Txt= 'Tag   286: "X Position"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag287:
/*    Name       Tag Hex Type     NValues                                    */
/* YPosition     287 11F RATIONAL                                            */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Offset=TIFFINFO.IFDCounter._Value.Tag
rc=stream(in,'c','seek ='Offset+1 )
Data=charin(in,,8)
parse var Data v1 5 v2

if order='LE' then do
   v1=x2d(c2x(reverse(v1)))
   v2=x2d(c2x(reverse(v2)))
   end   
else do
  v1=x2d(c2x(v1)) 
  v2=x2d(c2x(v2)) 
  end

TIFFINFO.IFDCounter._Value.Tag=v1/v2

Txt= 'Tag   287: "Y Position"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag288:
/*    Name       Tag Hex Type  NValues                                       */
/* FreeOffsets   288 120 LONG                                                */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   288: "Free Offsets is present, it will not be used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return -1

/*    -----------------------------------------------------------------      */
Tag289:
/*    Name        Tag Hex Type  NValues                                      */
/* FreeByteCounts 289 121 LONG                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   289: "Free Byte Counts is present, it will not be used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return -1

/*    -----------------------------------------------------------------      */
Tag290:
/*    Name          Tag Hex Type  NValues                                    */
/* GrayResponseUnit 290 122 SHORT 1                                          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   290: "Grey response unit is present, it will not be used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag291:
/*    Name          Tag Hex Type  NValues                                    */
/* GrayResponseCurve 291 123 SHORT 2**BitsPerSample                          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
      if order='LE' then do
         v1=x2d(c2x(reverse(v1)))
         v2=x2d(c2x(reverse(v2)))
         end
      else do
         v1=x2d(c2x(v1))
         v2=x2d(c2x(v2))
         end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))
      rc=stream(in,'c','seek ='Offset+1 )
      Length=TIFFINFO.IFDCounter._NValues.Tag*2 /* Bytes in a SHORT */
      Data=charin(in,,Length)
      do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
         parse var Data v 3 Data
         if order='LE' then v=reverse(v)
         TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
         end i
      TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
      end

   end /* end select */

Txt= 'Tag   291: "Gray response curve is present, it will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Entry# Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,21) right(TIFFINFO.IFDCounter._Value.Tag.K,5)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return 1

/*    -----------------------------------------------------------------      */
Tag292:
/*    Name       Tag Hex Type  NValues                                       */
/* T4Options     292 124 LONG 1                                              */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   292: "T4 Options, CCITT T4 encoding is used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return -1

/*    -----------------------------------------------------------------      */
Tag293:
/*    Name       Tag Hex Type  NValues                                       */
/* T6Options     293 125 LONG 1                                              */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   293: "T6 Options, CCITT T6 encoding is used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return -1

/*    -----------------------------------------------------------------      */
Tag296:
/*    Name        Tag Hex Type  NValues                                      */
/* ResolutionUnit 296 128 SHORT 1                                            */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

ResolutionUnit=TIFFINFO.IFDCounter._Value.Tag

Txt= 'Tag   296: "Resolution Unit"' TIFFINFO.IFDCounter._Value.Tag

select
   when ResolutionUnit=1 then
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (No resolution unit specified).')
   when ResolutionUnit=2 then 
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (inches).')
   when ResolutionUnit=3 then
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (centimeters).')
   otherwise 
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  (Unknown resolution unit).')
   end  /* select */
return 1

/*    -----------------------------------------------------------------      */
Tag297:
/*    Name       Tag Hex Type  NValues                                       */
/* PageNumber    297 129 SHORT 2                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

parse var Value v1 3 v2
if order='LE' then do
   v1=x2d(c2x(reverse(v1)))
   v2=x2d(c2x(reverse(v2)))
   end
else do
   v1=x2d(c2x(v1))
   v2=x2d(c2x(v2))
   end
TIFFINFO.IFDCounter._Value.Tag.1 = v1
TIFFINFO.IFDCounter._Value.Tag.2 = v2
TIFFINFO.IFDCounter._Value.Tag.0 = 2

Txt= 'Tag   297: "Page Number, page of pages"' v1 '/' v2
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag301:
/*    Name          Tag Hex Type  NValues                                    */
/* TransferFunction 301 12D SHORT {1 or SamplesPerPixel}* 2** BitsPerSample  */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   301: "Transfer function is present, it will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag305:
/*    Name       Tag Hex Type  NValues                                       */
/*   Software    305 131 ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end
Software=strip(Data,'T','00'x)
Software=translate(Software,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=Software

Txt= 'Tag   305: "Software"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1


/*    -----------------------------------------------------------------      */
Tag306:
/*    Name       Tag Hex Type  NValues                                       */
/* DateTime      306 132 ASCII 20                                            */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end

DateTime=strip(Data,'T','00'x)
DateTime=translate(DateTime,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=DateTime

Txt= 'Tag   306: "Date Time Y:M:D H:M:S"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag315:
/*    Name       Tag Hex Type  NValues                                       */
/*    Artist     315 13B ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end
Artist=strip(Data,'T','00'x)
Artist=translate(Artist,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=Artist

Txt= 'Tag   315: "Artist"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag316:
/*    Name       Tag Hex Type  NValues                                       */
/* HostComputer  316 13C ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end
HostComputer=strip(Data,'T','00'x)
HostComputer=translate(HostComputer,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=HostComputer

Txt= 'Tag   316: "Artist"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag317:
/*    Name       Tag Hex Type  NValues                                       */
/* Predictor     317 13D SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

Txt= 'Tag   317: "Predictor"' TIFFINFO.IFDCounter._Value.Tag

select
   when TIFFINFO.IFDCounter._Value.Tag=1 then do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  No prediction scheme used before encoding.')
      ReturnValue=1
      end
   when TIFFINFO.IFDCounter._Value.Tag=2 then  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  Horizontal differencing used before encoding.')
      ReturnValue=-1
      end
   otherwise  do
      rc=Speaker2Animals(OutLogFile,Verbosity,Txt '  Prediction value is of unknown meaning.')
      ReturnValue=-2
      end
   end
return ReturnValue

/*    -----------------------------------------------------------------      */
Tag318:
/*    Name       Tag Hex Type     NValues                                    */
/* WhitePoint    318 13E RATIONAL 2                                          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Offset=TIFFINFO.IFDCounter._Value.Tag
rc=stream(in,'c','seek ='Offset+1 )
Data=charin(in,,16)
parse var Data v1 5 v2 9 v3 13 v4

if order='LE' then do
   v1=x2d(c2x(reverse(v1)))
   v2=x2d(c2x(reverse(v2)))
   v3=x2d(c2x(reverse(v3)))
   v4=x2d(c2x(reverse(v4)))
   end   
else do
  v1=x2d(c2x(v1)) 
  v2=x2d(c2x(v2)) 
  v3=x2d(c2x(v3)) 
  v4=x2d(c2x(v4)) 
  end
  
WhitePoint=v1/v2 v3/v4
TIFFINFO.IFDCounter._Value.Tag=WhitePoint

Txt= 'Tag   318: "White Point"' v1 '/' v2
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag319:
/*    Name               Tag Hex Type     NValues                            */
/* PrimaryChromaticities 319 13F RATIONAL 6                                  */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Offset=TIFFINFO.IFDCounter._Value.Tag
rc=stream(in,'c','seek ='Offset+1 )
do i = 1 to 3
   Data=charin(in,,16)
   parse var Data v1 5 v2 9 v3 13 v4

   if order='LE' then do
      v1=x2d(c2x(reverse(v1)))
      v2=x2d(c2x(reverse(v2)))
      v3=x2d(c2x(reverse(v3)))
      v4=x2d(c2x(reverse(v4)))
      end   
   else do
      v1=x2d(c2x(v1)) 
      v2=x2d(c2x(v2)) 
      v3=x2d(c2x(v3)) 
      v4=x2d(c2x(v4)) 
      end
   v.i= v1/v2','v3/v4
   end i

TIFFINFO.IFDCounter._Value.Tag=v.1 v.2 v.3

Txt= 'Tag   319: "Primary Chromaticities"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

rc=Speaker2Animals(OutLogFile,Verbosity,'               red[x],   red[y]  = 'v.1)
rc=Speaker2Animals(OutLogFile,Verbosity,'               green[x], green[y]= 'v.2)
rc=Speaker2Animals(OutLogFile,Verbosity,'               blue[x],  blue[y] = 'v.3)
return 1

/*    -----------------------------------------------------------------      */
Tag320:
/*    Name       Tag Hex Type  NValues                                       */
/* ColorMap      320 140 SHORT 3 * (2**BitsPerSample)                        */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

/* BitsPerSample=TIFFINFO.IFDCounter._Value.258 */

NFields=TIFFINFO.IFDCounter._NValues.Tag
NColors=NFields/3
length = NFields * 2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then 
   Offset=x2d(c2x(reverse(Value)))
else 
   Offset=x2d(c2x(Value))
rc=stream(in,'c','seek ='Offset+1 )

Data=charin(in,,Length)

/* Red */
do i = 0 to NColors-1
   parse var Data v 3 Data
   /* rc=Speaker2Animals(OutLogFile,Verbosity,'red i= 'i c2x(v) x2d(c2x(v)) x2d(c2x(reverse(v))) */
   if order='LE' then v = reverse(v)
   TIFFINFO.IFDCounter._Red.i = x2d(c2x(v))
   end

/* Green */
do i = 0 to NColors-1
   parse var Data v 3 Data
   /* rc=Speaker2Animals(OutLogFile,Verbosity,'green i= 'i c2x(v) x2d(c2x(v)) x2d(c2x(reverse(v))) */
   if order='LE' then v = reverse(v)
   TIFFINFO.IFDCounter._Green.i = x2d(c2x(v))
   end

/* Blue */
do i = 0 to NColors-1
   parse var Data v 3 Data
   /* rc=Speaker2Animals(OutLogFile,Verbosity,'blue i= 'i c2x(v) x2d(c2x(v)) x2d(c2x(reverse(v))) */
   if order='LE' then v = reverse(v)
   TIFFINFO.IFDCounter._Blue.i = x2d(c2x(v))
   end


Txt= 'Tag   320: "Color palette."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Entry#  Red Green  Blue        R    G    B'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
do i = 0 to NColors-1
   Txt= right(i,20),
        right(TIFFINFO.IFDCounter._Red.i,5),
        right(TIFFINFO.IFDCounter._Green.i,5),
        right(TIFFINFO.IFDCounter._Blue.i,5),
        '   ',
        right(TIFFINFO.IFDCounter._Red.i/256,4),
        right(TIFFINFO.IFDCounter._Green.i/256,4),
        right(TIFFINFO.IFDCounter._Blue.i/256,4),

   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end /* end do */

return 1
Maximum color value=65535
to convert to 0-255 scale divide by 256


/*    -----------------------------------------------------------------      */
Tag321:
/*    Name       Tag Hex Type  NValues                                       */
/* HalftoneHints 321 141 SHORT 2                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 321, Halftone Hints are present.')
return 1

/*    -----------------------------------------------------------------      */
Tag322:
/*    Name       Tag Hex Type          NValues                               */
/* TileWidth     322 142 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

if TIFFINFO.IFDCounter._Type.Tag=3 then do
   parse var TIFFINFO.IFDCounter._Value.Tag Value .
   Value=x2c(Value)
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
   end

else nop

Txt= 'Tag   322: "Tile Width is present, it will not be used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return -1

/*    -----------------------------------------------------------------      */
Tag323:
/*    Name       Tag Hex Type          NValues                               */
/* TileLength    323 143 SHORT or LONG 1                                     */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

if TIFFINFO.IFDCounter._Type.Tag=3 then do
   parse var TIFFINFO.IFDCounter._Value.Tag Value .
   Value=x2c(Value)
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))
   end

else nop

Txt= 'Tag   323: "Tile length is present, it will not be used."' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return -1

/*    -----------------------------------------------------------------      */
Tag324:
/*    Name       Tag Hex Type  NValues                                       */
/* TileOffsets   324 144 LONG  TilesPerImage                                 */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   324: "Tile offsets are present, they will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return -1

/*    -----------------------------------------------------------------      */
Tag325:
/*    Name        Tag Hex Type          NValues                              */
/* TileByteCounts 325 145 SHORT or LONG TilesPerImage                        */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   325: "Tile Byte counts are present, they will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return -1

/*    -----------------------------------------------------------------      */
Tag332:
/*    Name       Tag Hex Type  NValues                                       */
/*   InkSet      332 14C SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   332: "Ink set"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag333:
/*    Name       Tag Hex Type  NValues                                       */
/* InkNames      333 14D ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end

v=strip(Data,'T','00'x)
v=translate(Copyright,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=v

Txt= 'Tag   333: "Ink Names"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag334:
/*    Name       Tag Hex Type  NValues                                       */
/* NumberOfInks  334 14E SHORT 1                                             */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag   334: "Number of inks"' TIFFINFO.IFDCounter._Value.Tag)
return 1

/*    -----------------------------------------------------------------      */
Tag336:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 336, Dot Range is used.')
return 1

/*    -----------------------------------------------------------------      */
Tag337:
/*    Name       Tag Hex Type  NValues                                       */
/* TargetPrinter 337 151 ASCII                                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end

v=strip(Data,'T','00'x)
v=translate(Copyright,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=v

Txt= 'Tag   333: "Target printer"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag338:
/*    Name       Tag Hex Type  NValues                                       */
/* ExtraSamples  338 152 SHORT number of extra components per pixel          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
         if order='LE' then do
            v1=x2d(c2x(reverse(v1)))
            v2=x2d(c2x(reverse(v2)))
            end
         else do
            v1=x2d(c2x(v1))
            v2=x2d(c2x(v2))
            end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))
      rc=stream(in,'c','seek ='Offset+1 )
      Length=TIFFINFO.IFDCounter._NValues.Tag*2 /* Bytes in a SHORT */
      Data=charin(in,,Length)
      do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
         parse var Data v 3 Data
         if order='LE' then v=reverse(v)
         TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
         end i
      TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
      end

   end /* end select */

Txt= 'Tag   338: Extra Samples are present'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Channel Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   Txt= right(K,22) right(TIFFINFO.IFDCounter._Value.Tag.K,5)
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

return 1

/*    -----------------------------------------------------------------      */
Tag339:
/*    Name       Tag Hex Type  NValues                                       */
/* SampleFormat  339 153 SHORT SamplesPerPixel                               */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

NBytesPerValue=2

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

select 
   when TIFFINFO.IFDCounter._NValues.Tag = 1 then do
      if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
      else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))            
      TIFFINFO.IFDCounter._Value.Tag.1 = TIFFINFO.IFDCounter._Value.Tag
      TIFFINFO.IFDCounter._Value.Tag.0 = 1
      end

   when TIFFINFO.IFDCounter._NValues.Tag = 2 then do
      parse var Value v1 3 v2
         if order='LE' then do
            v1=x2d(c2x(reverse(v1)))
            v2=x2d(c2x(reverse(v2)))
            end
         else do
            v1=x2d(c2x(v1))
            v2=x2d(c2x(v2))
            end
      TIFFINFO.IFDCounter._Value.Tag.1 = v1
      TIFFINFO.IFDCounter._Value.Tag.2 = v2
      TIFFINFO.IFDCounter._Value.Tag.0 = 2
      end

   otherwise do /* Value is an offset. */
      if order='LE' then 
         Offset=x2d(c2x(reverse(Value)))
      else 
         Offset=x2d(c2x(Value))
      rc=stream(in,'c','seek ='Offset+1 )
      Length=TIFFINFO.IFDCounter._NValues.Tag*2 /* Bytes in a SHORT */
      Data=charin(in,,Length)
      do i= 1 to TIFFINFO.IFDCounter._NValues.Tag
         parse var Data v 3 Data
         if order='LE' then v=reverse(v)
         TIFFINFO.IFDCounter._Value.Tag.i=x2d(c2x(v))
         end i
      TIFFINFO.IFDCounter._Value.Tag.0 = TIFFINFO.IFDCounter._NValues.Tag
      end

   end /* end select */

Txt= 'Tag   339: Sample Format'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
Txt= '               Channel Value'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

Txt.1 = 'unsigned integer data'
Txt.2 = 'two s complement signed integer data'
Txt.3 = 'IEEE floating point data [IEEE]'
Txt.4 = 'undefined data format'

do k=1  to TIFFINFO.IFDCounter._NValues.Tag
   v = TIFFINFO.IFDCounter._Value.Tag.K
   Txt= right(K,22) right(v,5) Txt.v
   rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
   end k   

/* Check to see if this is a format is the same for all channels.      */
do k=2 to TIFFINFO.IFDCounter._NValues.Tag
   km1=k-1
   if TIFFINFO.IFDCounter._Value.Tag.km1 = TIFFINFO.IFDCounter._Value.Tag.k then nop
   else do
      rc=Speaker2Animals(OutLogFile,Verbosity,'*** The format for each channel is not constant. ***')
      end
   end k          

return 1

/*    -----------------------------------------------------------------      */
Tag340:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   340: "Minimum Sample Values are present, they will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

return 1

/*    -----------------------------------------------------------------      */
Tag341:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   341: "Maximum Sample Values are present, they will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/*    -----------------------------------------------------------------      */
Tag342:
/*    Name       Tag Hex Type  NValues                                       */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

Txt= 'Tag   342: "Transfer range present, it will not be used."'
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 342, Transfer range is used.')
return 1

/*    -----------------------------------------------------------------      */
Tag512:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 512, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag513:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 513, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag514:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 514, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag515:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)
if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
else TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(left(Value,2)))

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 515, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag517:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 517, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag518:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 518, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag519:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 519, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag520:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 520, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag521:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 521, for JPEG is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag532:
/*    Name       Tag Hex Type  NValues                                       */

Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

rc=Speaker2Animals(OutLogFile,Verbosity,'Tag 532, Reference BlackWhite is used.')
return -1

/*    -----------------------------------------------------------------      */
Tag33432:
/*    Name       Tag Hex Type  NValues                                       */
/*  Copyright  33432 8298 ASCII Any                                          */
Procedure expose TIFFINFO.

in         = arg(1)  /* Input file name.                                     */
IFDCounter = arg(2)  /* The number of the image being considered.            */ 
Order      = arg(3)  /* BE|LE, Byte order                                    */
Tag        = arg(4)  /* Entry holding current tag number.                    */
Verbosity  = arg(5)  /* Verbosity  - Argument to Speaker2Animals:            */
OutLogFile = arg(6)  /* File to receive output from Speaker2Animals.         */

parse var TIFFINFO.IFDCounter._Value.Tag Value .
Value=x2c(Value)

if Length < 5 then Data=Value
else do
   /* "Value" is an offset. */
   if order='LE' then TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(reverse(Value)))
   else  TIFFINFO.IFDCounter._Value.Tag=x2d(c2x(Value))            
   Length=TIFFINFO.IFDCounter._NValues.Tag
   Offset=TIFFINFO.IFDCounter._Value.Tag
   rc=stream(in,'c','seek ='Offset+1 )
   Data=charin(in,,Length)
   end

Copyright=strip(Data,'T','00'x)
Copyright=translate(Copyright,'0d0a'x,'00'x)
TIFFINFO.IFDCounter._Value.Tag=Copyright

Txt= 'Tag   285: "Page Name"' TIFFINFO.IFDCounter._Value.Tag
rc=Speaker2Animals(OutLogFile,Verbosity,Txt)
return 1

/* --------------------------------------------------------------------------*/


