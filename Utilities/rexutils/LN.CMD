/* LN              CMD by Gord Snider  2010/04/17  v04.05.00  2016/12/27     */
/* PURPOSE: By default adds line numbers, as comments, in columns 105 - 114,
(suitable for landscape-oriented printing on letter-sized paper), to all lines
in a file (usually a REXX cmd), on disk in the current directory.  If there
is already data in the number-space columns then the line is counted but left
unnumbered.  The default line-number interval is 1.  The output overwrites the
original file.  The original file is first copied to a file of the same name
in the same directory but with the added filetype of '.ln' .
The default action can be varied by optional switches.

    SYNTAX:  LN /?
        or   LN cmdfn [/L|/P|/G] [/B] [/Ix]
        or   LN cmdfn /R

     WHERE:
cmdfn    is the filename (usually a REXX cmd file) to add line numbers to.
         Files outside the current directory can be fully specified.

   OPTIONS:
/?       prints out this help screen and exits. Used alone.
/L       inserts line number at LEFT end of each line, at columns   1 -  10.
/P       PORTRAIT orientation - adds line numbers,     at columns  81 -  90.
/G       Landscape orientation on LEGAL-sized paper,   at columns 147 - 156.
/B       BLANK lines NOT numbered; used alone, or with /L or /P or /G.
/Ix      INTERVAL of line numbers.  'x' is a positive integer.
/R       REMOVES line numbers produced by this cmd.  Used alone.

Sensible switch combinations:
/L or /P or /G, with or without /B, and with or without /Ix
/Ix
/R   To remove line numbers only, specify /R as the only option.

To change line number position specify the switch for new position only; or let
the default happen.  Old line numbers are removed automatically.

The file you specify is used as input to produce a new, backup file with
the same name in the same directory as the input file, but with a new,
additional filetype of '.ln'. Then the output file overwrites the input file.

If you attempt to line-number a file that has already been line-numbered
(but only if numbered by this cmd) the current line numbers will be removed
and new line numbers added.  In other words, the lines in the file will be
renumbered in one step.  (Usually, while developing a cmd that has been
line-numbered the line numbers get shifted out of their places in columns
105 - 114, or 81 - 90, or 147 - 156, or even to new lines.)  When a renumber is
called for this cmd will find the old line number, whatever columns it is in.

NOTE: This cmd assumes that RexxUtil DLL has already been loaded.
NOTE: Because RexxUtil DLL contains functions specific to OS/2 it is likely
      that this cmd will work only in OS/2 compatible systems.
*/
/*
For the line numbers position I picked columns 81 - 90, for portrait printing,
or for landscape printing, columns 105 - 114 on letter-sized paper, or 147 - 156
for landscape printing on legal-sized paper to put the line numbers at the far
right.  This works with my choice of MONOSPACED font. So all code lines should
be less than 105 or 147 characters for landscape printing,
or less than 81 characters for portrait printing.
YMMV.

What sets LN.CMD apart from other line numbering programs is the format of the
comment containing the line number.  The apparently-blank spaces separating the
comment delimiters from the line number are not true blanks.  They are hex FF
(decimal 255) characters that appear blank.  The line number removal process
searches for comment delimiters plus hex FF (decimal 255) characters that are
7 spaces apart anywhere in a line.  This pattern was considered UNLIKELY
BUT NOT IMPOSSIBLE to appear elsewhere in a program. If this data pattern DOES
appear elsewhere and you specify the switch for line number removal THAT DATA
WILL BE INCORRECTLY REMOVED.  BE WARNED.
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

/* ***** Switch verification and handling. ***** */
if opt.I & \(datatype( mod.I, 'W')) then do                /* Uppercase I = Interval. */
      say '/I specified but mod.I not an integer or not specified.'
      exit
end

if opt.I then
      int = mod.I                                          /* Upper case I, new line-numbering Interval. */
   else
      int = 1                                              /* Default line-numbering interval is 1. */

if opt.S then do                                           /* Remove old style line numbers ... */
      if datatype( mod.S, 'W') then nop                    /* with column number. */
         else do
            say 'mod.S' mod.S 'not a whole number.'
            exit
      end
end

select
   when opt.L then col =   0                               /* For inserting numbering at left end of line. */
   when opt.P then col =  80                               /* Portrait orientation, 8.5" wide. */
   when opt.G then col = 146                               /* Landscape, on legal paper, 11" x 14". */
   otherwise       col = 104                               /* Default, landscape, letter 11" x  8.5". */
end
/* ***** End of switch verification and handling. ***** */

parse arg cmdfn . '/' .                                    /* simple fn.ft or FQN */

/* Verify existence and Open input file. */
fqfn_i = Stream( cmdfn, 'C', 'QUERY EXISTS')               /* FQFN, or null, the input filename. */
if fqfn_i = '' then do
      say 'Input File not found or not specified,' cmdfn   /* Input File not found. */
      exit
   end
say

if Stream( fqfn_i".LN", 'C', 'QUERY EXISTS') ª= '' then    /* Delete any older backup file. */
     "DEL" fqfn_i".LN"

"COPY"  fqfn_i   fqfn_i".LN"                               /* Copy to backup file. */

if Stream( fqfn_i, 'C', 'OPEN READ') = 'READY:' then       /* Open input file. */
      say 'Input  ' fqfn_i
   else do
      say 'Problem opening input file' fqfn_i
      exit
end

/* Line by line file processing. */
do i1 = int by int while Lines( fqfn_i)                    /* Loop through input file line by line. */
                                                           /* starting at, & incrementing by, INTERVAL */
   line = LineIn( fqfn_i)                                  /* Read input file line. */

   if opt.R & opt.S then                                   /* To remove 'old style' line numbers. */
         if substr( line, mod.S, 3) = '/'||'*'||' '  ,     /* mod.S = column of old-style line number */
          & datatype( substr( line, mod.S + 3, 4), 'W')  , /* UNDOCUMENTED */
          & substr( line, mod.S + 7, 3) = ' '||'*'||'/' then
            line = delstr( line, mod.S, 10)

   if pos( cldel, line) - pos( opdel, line) = 7 & ,        /* Remove any previous LN.CMD line number ... */
      datatype( substr( line, pos( opdel, line) + 3, 4), 'W') then
         line = delstr( line, pos( opdel, line), 10)       /* whereever found. */

   line = strip( line, 'T')                                /* Strip trailing blanks on each line. */

   if col \= 0 then                                        /* Check line for clear space at ... */
         if substr( line, col + 1, 10) = ''                /* col 81 or 105 or 146. */
            then ns = 1                                    /* ns = 1 means number space is clear */
            else ns = 0                                    /* ns = 0 means number space is dirty */
      else ns = 1                                          /* 'Number space' ALWAYS clear for opt.L  */

   lnp = opdel || right( i1, 4, 0) || cldel                /* lnp = Line Number Pattern, with number. */

   select                                 /* The times when we DON'T want to insert a line number ... */
      when opt.R then nop                                  /* Only removing line numbers. */

      when \(ns) then nop                                  /* Number-space dirty. */

      when opt.B & length( line) = 0 then i1 = i1 - int    /* Blank unnumbered, subtract interval */

      otherwise line = insert( lnp, line, col)             /* Insert a line number into number space. */
   end  /* select */

   queue line                                              /* Newly numbered line into External data queue. */

end i1                                                     /* End of input line processing */
call Stream fqfn_i, 'C', 'CLOSE'                           /* Close Input file. */

if SysFileDelete( fqfn_i) = 0 then do                      /* Delete old file. */
      say 'Deleted' fqfn_i
      if Stream( fqfn_i, 'C', 'OPEN WRITE') = 'READY:' then      /* Open new output file. */
            say 'Output file opened' fqfn_i
         else do
            say 'Problem opening output file' fqfn_i
            say 'Recover from .LN file.'
            exit
      end
   end
   else do
      say 'Problem deleting input file' fqfn_i
      exit
end

do j1 = 1 to queued()
   parse pull line
   call LineOut fqfn_i, line                               /* Write out the final result from queue. */
end j1

if Stream( fqfn_i, 'C', 'CLOSE') = 'READY:' then
      say 'Output file closed'  fqfn_i

exit 0
