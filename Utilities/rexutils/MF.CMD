/* MF              CMD by Gord Snider  2005/11/06  v01.07.00  2016/03/31     */
/* PURPOSE: By default, (that is, when MF is specified with no parameters),
creates a zero-byte file entry in the current directory and issues a message
naming the file (with a filename of spacehog), with its file size.
Optionally, you may specify a filename and/or a path alone, and/or a
file size.

    SYNTAX:    MF [path\][filename] [/Bx | /Kx | /Mx]
         or    MF /?

     WHERE:
Filename is the optional name of the file you want to create.  If no filename
is supplied then a unique filename will be supplied by the SysTempFileName()
function with the mask "spacehog.???".

An optional path may be specified, with or without the filename,
to place the file in the specified directory, but a path alone MUST end in a
backslash, "\", to be recognized as a pure path.  With no path specified the
file is created in the current directory.

   OPTIONS:
One of the following optional switches may be used to set the file size:
/B, /K, /M and /G are literals standing for Bytes, Kilobytes, or Megabytes
Kilobyte = 1024 Bytes;  Megabyte = 1024 Kilobytes

"x" is a positive integer multiplier of B, K, or M.
The total size of the file may not be greater than is supported by the OS/2
file system you are using.
If a file size is specified the dummy file is filled with hex zeros, '00'x.

/?  triggers a display of a help screen and then exits.

NOTE: Repeated executions of this program specifying the same filename result
      in the outputs being concatenated into the named file (up to supported
      file size).
NOTE: This cmd requires my Rexx External Function  _commas().
NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: Because RexxUtil.DLL is used it is likely that this will run only in
      OS/2 compatible systems.
*/

/* opts     as of 2013/10/25 */
arg . '/'switches +0                                  /* split off the switches from the rest */
opt. = 0                                              /* unset options will be FALSE */
mod. = ''                                             /* unset option mods will be NULL */
do while pos( '/', switches) > 0                      /* each option must have leading slash */
   parse var switches '/'opt'/'switches +0            /* parse next option/modification set */
   parse upper var opt opt 2 mod                      /* split option from any modification */
   opt.opt = 1                                        /* capture option name, option value = TRUE */
   mod.opt = mod                                      /* capture option's modification, if any */
end   /* opts */

/* help     as of 2013/10/26 */
parse value SysTextScreenSize() with rows cols             /* used to check for window full */
opdel = '/'||'*'||'FF'x                                    /* This line needed by LN.CMD */
cldel = 'FF'x||'*'||'/'                                    /* This line needed by LN.CMD */
if opt.? then do                                           /* Help screen */
      do ll = 1 to sourceline() while left( sourceline( ll), 2) \= '*'||'/'    /* get next help line */
         sl = sourceline( ll)                              /* to shorten next REXX lines */
         if pos( cldel, sl) - pos( opdel, sl) = 7 then     /* both delims present, 7 chars apart */
               sl = delstr( sl, pos( opdel, sl) , 10)      /* remove line #, if any, anywhere in line */
         say strip( left( sl, cols - 1), 'T')              /* say the stripped help line */
         if (ll // (rows - 2)) = 0 & ,                     /* 2 lines short of full screen and */
            left( sourceline( ll + 1), 2) \= '*'||'/' then do  /* next line NOT end of comments */
               say '<Enter> to continue ...'
               pull .
         end
      end ll                                               /* end of list-a-help line loop */
      exit 0
end   /* help */

NUMERIC DIGITS 12                                          /* hndreds of gigabytes */

PARSE ARG dest '/' . +0                                    /* dest may be null, path, fn.ft, fqfn; with or without quotes */

IF Pos('"', dest) < Lastpos('"', dest) THEN                /* Remove any double quotes from destination filename, ... */
      PARSE VAR dest '"' dest '"'                          /* so I can find trailing backslash, if it exists.*/

dest = Strip( dest, 'T')                                   /* Destination filename now without trailing blanks. */

IF Right( dest, 1) = '\' THEN DO                           /* Is this a path alone? */
      path = dest                                          /* Capture path because I need to supply fn. */
      filename = ''                                        /* No file given, just path. */
   END
   ELSE DO
      path = ''                                            /* Dest may be null or fn.ft or FQFN. */
      filename = dest                                      /* Filename may be null or fn.ft or FQFN. */
END

IF filename = '' THEN filename = path || SysTempFileName( 'spacehog.???')

DO i = 1 TO 4                                              /* Set variables factor1 and factor2 */
   IF                     Word(   opt.B    opt.K    opt.M     1, i) THEN DO
         factor1 =        Word(   1        1024     1048576   0, i)   /*  Bytes, Kilobytes, Megabytes */
         factor2 = Value( Word(  'mod.B'  'mod.K'  'mod.M'    0, i))  /* multiplier */
         LEAVE i
   END
END i

IF factor2 = '' THEN DO                                    /* no modifier given */
      SAY "Multiplier not specified.  Reverting to zero-byte file."
      factor1 = 0
      factor2 = 0
END

opened = 0                                                 /* Flag = FALSE */
closed = 0                                                 /* Flag = FALSE */

IF Stream( filename, "C", "OPEN WRITE") = "READY:" THEN DO
      opened = 1
      DO factor2
         CALL CharOut filename, Copies('00'x, factor1)
      END
END

IF Stream( filename, "C", "CLOSE") = "READY:" THEN closed = 1
IF opened & closed
   THEN SAY "File created -" Stream( filename, "C", "QUERY EXISTS") "-"  ,
                    _commas( Stream( filename, "C", "QUERY SIZE")) "bytes"
   ELSE SAY "File not created."

EXIT 0
