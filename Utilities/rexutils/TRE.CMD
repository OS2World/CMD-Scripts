/* TRE             CMD by Gord Snider  2010/09/14  v03.13.00  2016/04/15     */
/* PURPOSE: Default action is to produce a screen display of the
subdirectories, as a tree, from the CURRENT directory, as root, out to its
leaves.  This action can be modified by specifying another directory as root
and/or by switches.

    SYNTAX: TRE [root] [/A] [/B] [/C] [/D] [/F] [/Lx] [/N] [/P] [/T] [/W] [/Z]
      or    TRE /?

If root is not specified, the base of the tree is the current directory.
If specified, that directory becomes the root of the tree and it must be:
 - a fully qualified local directory name, with no trailing backslash
 - any subdirectory of the current directory with its path from the current
     directory
 - the root of the current drive, '\'
 - the root of a local drive, e.g. C:\

The switches are optional slash-letter combinations.  Except for /?, which
must be used alone, you may specify any number of switches, in any order, but
output for /D, if specified, will always appear first, followed by output for
/F, if specified, followed by output for /B, if specified.  However, note that
specifying too many switches on one run will cause the lines to wrap on the
screen and this cmd does not handle line wraps well.

/?   calls this simple help screen and exits
/A   use ASCII characters instead of graphics characters for the tree
/B   shows the total number of BYTES in files in each (sub)directory
/C   shows data in COLOUR: subdirectories=magenta; files=yellow;
       bytes=cyan; paths=green; index numbers=red; directory names and
       branch byte totals=white; attributes=blue;
/D   shows the number of first level (sub)DIRECTORIES in each (sub)directory
/F   shows the number of FILES in each (sub)directory
/Lx  how many LEVELS to show.  x is a positive integer; i.e. '1' shows
       same subdirectories as DIR command would
/N   NUMBERS the subdirectories relative to the root directory.
/P   shows the PATH to each subdirectory
/T   shows the ATTRIBUTES of each subdirectory
/W   shows subDIRECTORIES, FILES, and rounded BYTES
/Z   shows total bytes by whole sub-branch

Additionally, whenever you have specified the /N switch, which produces a
(dotted) relative level number for each subdirectory, and you are given an
'<Enter> to continue ...' message, you may enter the (dotted) number of a
subdirectory to immediately make that subdirectory the current directory,
and exit from this cmd.
And, if from there you wish to go back to the directory in which you last
issued the TRE cmd, and, if my J.CMD is installed on your computer then
just execute a simple J cmd.

NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: This cmd requires my Rexx External Function _commas().
NOTE: This cmd sets the JPREVDIR= Environment variable to enable this cmd to
      work with my J.CMD if it is installed.
NOTE: Code page 437 or 850 is required for grahics display.  If another code
      page is in use Use /A switch to produce tree structure.
NOTE: If you select more than about 3 options it is likely that the output
      line will be long enough to wrap to a second screen line.  To avoid
      wrapping you may wish to issue a command like 'MODE 150 30' first.
NOTE: Depending on the options you specify there may be a period of intense
      CPU/disk activity before any output appears on the screen.
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

arg root '/' . +0                                          /* Root is something or null. */

curdir = Directory()                                       /* Record where we are now.  */
call Value 'JPREVDIR', curdir, 'OS2ENVIRONMENT'            /* SET curdir in env. variable for J.cmd. */
root = Directory( root)                                    /* Root now Null or expanded to full path. */
call   Directory curdir                                    /* Return to curdir In case of exit. */

if root = '' then do
      say
      say 'Specified Directory not found.'
      exit
end
root = Strip( root, 'T', '\')                              /* So 'C:\' works in SysFileTree(). */

numeric digits 13                                          /* 1000s of GB */
tot.  = 0                                                  /* Overall totals for dirs, files, bytes. */
clr.  = ''                                                 /* For ANSI Color array. */
lines = 0                                                  /* Window full? */

/* Start of Option processing. */
if opt.W then do                                           /* Whole enchilada!! */
      opt.D = 1                                            /* Directories */
      opt.F = 1                                            /* Files */
      opt.B = 0                                            /* No Exact Bytes */
      opt.S = 1                                            /* Short, rounded Bytes, instead */
      opt.N = 1
      opt.C = 1                                            /* Colors */
end

if opt.A then x = a                                        /* Tree in ASCII, no graphics. */
    else x = g                                             /* Tree in graphics. */

if opt.C then do                                           /* ANSI code Foreground colours */
      clr.blk = '1B'x || '[30;1;m'                         /* black         */
      clr.red = '1B'x || '[31;1;m'                         /* red, high     */
      clr.grn = '1B'x || '[32;1;m'                         /* green, high   */
      clr.ylw = '1B'x || '[33;1;m'                         /* yellow, high  */
      clr.blu = '1B'x || '[34;1;m'                         /* blue, high    */
      clr.mga = '1B'x || '[35;1;m'                         /* magenta, high */
      clr.cyn = '1B'x || '[36;1;m'                         /* cyan, high    */
      clr.wht = '1B'x || '[37;1;m'                         /* white, high   */
      clr.nrm = '1B'x || '[0;m'                            /* normal        */
end

if opt.L then                                              /* Qualify 'Level' argument */
      if Datatype( mod.L, 'Whole') & (mod.L > -1) then     /* Whole # > -1 */
            depth = mod.L                                  /* Restrict number of included levels. */
         else do
            say 'Level x must be a non-negative integer.'
            exit
      end    /* if datatype() */
   else depth = -1                                         /* Opt.L not specified. */

if opt.S then opt.B = 0                                    /* Just in case ... */
/* All necessary work on the options has been done. */

/* Code for putting numbers at left, i.e. set values for dirs, files, bytes column width. */
/* Begin by getting values for sdw, sfw, sbw, for root only. */
if opt.D then sdw = Max( Length( _commas( subdirs( root))), 0)    /* Width for subdirectory column. */
if opt.F then sfw = Max( Length( _commas(   files( root))), 0)    /* Width for files column. */
if opt.B then sbw = Max( Length( _commas(   bytes( root))), 0)    /* Width for bytes column. */

if opt.D | opt.F | opt.B then call width root, depth       /* Final numbers for sdw, sfw, sbw. */

tot. = 0                                                   /* New set of numbers to come.  */

if opt.Z then do                                           /* For total bytes by branch */
      bigg = 0
      szw = 0
      call SysFileTree root || '\' || '*', 'fld.', 'DO'    /* List of first level directories. */
      do k = 1 to fld.0                                    /* i.e. roots of all branches */
         call SysFileTree fld.k ||'\'||'*', 'zw.', 'FS'    /* List of all files in branch, ... */
         do mm = 1 to zw.0                                 /* branch root by branch root. */
            parse var zw.mm 1 . 17 big 29 .                /* Get size of each file in branch */
            bigg = bigg + big                              /* Get total bytes of each branch */
         end mm
         szw = Max( szw, Length( _commas( bigg)))                    /* Get biggest branch total field width. */
      end k
end
/* End of code for aligning numbers at left. */

/* Build first output line, field by field, as per specified options, with root directory data. */
if opt.D then call CharOut , clr.mga || Right( _commas( subdirs( root)), sdw) || clr.nrm' '  /* # subdirs */
if opt.F then call CharOut , clr.ylw || Right( _commas(   files( root)), sfw) || clr.nrm' '  /* # files   */
if opt.B then call CharOut , clr.cyn || Right( _commas(   bytes( root)), sbw) || clr.nrm' '  /* # bytes   */
if opt.S then call CharOut , clr.cyn ||                   bytes( root)        || clr.nrm' '
if opt.Z then call CharOut , clr.wht ||                   Copies( ' ',   szw) || clr.nrm' '

              call CharOut , clr.wht ||                          root'\'      || clr.nrm' '  /* default root */

if opt.T then call CharOut , clr.blu ||                    Atts( root)        || clr.nrm' '  /* atts */
              call CharOut , '0D0A'x                       /* CR/LF */
lines = lines + 1                                          /* Window full? */
/* End of build for first output line. */

call next root,,depth,    /* <== Recursion pivot point. */ /* Off and running ... */

/* Now finish up. */
if opt.N then do                                           /* Code for relative numbers. */
      say '<Enter> to continue ...'                        /* At the end of the display. */
      pull dotnum                                          /* Dotted relative directory number. */
      if dotnum \= '' then
            if dotnum == '0' then exit
               else signal dotted
end   /* if opt.N then do */

/* Optional Last line, with totals. */
say                                                        /* Build up optional final line. */
if                         opt.L  then call CharOut , 'To Level' mod.l' '
if opt.D | opt.F | opt.B | opt.S  then call CharOut , 'Total'
if opt.D                          then call CharOut , clr.mga || ' SubDirectories:'_commas( tot.d) || clr.nrm
if         opt.F                  then call CharOut , clr.ylw ||        '   Files:'_commas( tot.f) || clr.nrm
if                 opt.B | opt.S  then call CharOut , clr.cyn ||        '   Bytes:'_commas( tot.b) || clr.nrm

exit 0      /* ********* End of CMD ********* */


   /* This procedure is executed for each directory line (i. e. tree branch) put on the screen. */
next: procedure expose opt. clr. tot. root rows x lines curdir sdw sfw sbw szw /* Enable new variable set. */

parse arg thisdir,spacer,depth,lnums                       /* Spacer = line leading characters. */
                                                           /* lnums=relative subdir level numbers. */
if depth = 0 then return                                   /* Opt.N levels accomplished. */

call SysFileTree thisdir || '\' || '*', 'dir.', 'DO'       /* Are subdirs here? */

do dir = 1 to dir.0                                        /* If any, process the subdir list. */
   if dir < dir.0
      then do; leader.g = D2C( 195); leader.a = '+'; end   /* 'Ã' or '+' for all subdirs but the last ... */
      else do; leader.g = D2C( 192); leader.a = '+'; end   /* 'À' or '+' for the last subdir. */

   /* Output a regular data line consisting of the data for one directory to the screen,
      field by field, per specified options. */
   if opt.D then call CharOut , clr.mga ||          right( _commas( subdirs( dir.dir)), sdw) || clr.nrm' '
   if opt.F then call CharOut , clr.ylw ||          right( _commas(   files( dir.dir)), sfw) || clr.nrm' '
   if opt.B then call CharOut , clr.cyn ||          right( _commas(   bytes( dir.dir)), sbw) || clr.nrm' '
   if opt.S then call CharOut , clr.cyn ||                            bytes( dir.dir)        || clr.nrm' '
   if opt.Z & \datatype( lnums || dir, 'W') then
                 call CharOut , copies( ' ', szw)                                            || clr.nrm' '
   if opt.Z &  datatype( lnums || dir, 'W') then
                 call CharOut , clr.wht ||          right( _commas(  bratot( dir.dir)), szw) || clr.nrm' '
                 call CharOut , spacer leader.x
   if opt.N then call CharOut , clr.red ||                          lnums || dir             || clr.nrm' '
                 call CharOut , clr.wht || substr( dir.dir,    lastpos( '\', dir.dir) + 1)   || clr.nrm' '
   if opt.T then call CharOut , clr.blu ||                             atts( dir.dir)        || clr.nrm' '
   if opt.P then call CharOut , clr.grn || substr( dir.dir, 1, lastpos( '\', dir.dir))       || clr.nrm
                 call CharOut , '0D0A'x                    /* CR/LF to complete the line. */
   /* End of build for regular output line. */

   lines = lines + 1                                       /* Window full? */
   if lines / (rows - 3) >= 1 then do                      /* Full window? In the middle of the run. */
         say '<Enter> to continue ...'
         pull dotnum                                       /* Dotted relative directory number. */
         if dotnum == '0' then exit
         if dotnum \= '' then signal dotted                /* Relative directory level numbers. */
         lines = 0
         say                                               /* Blank line at top of window. */
   end   /* if lines / (rows - 3) > 1 */

   if leader.g = D2C( 195)                                 /* Ã Already using graphics and not last subdir. */
      then do; leader.g = D2C( 179); leader.a = '|'; end   /* ³ Prepare for next output line. */
      else do; leader.g = D2C(  32); leader.a = ' '; end   /*                     */

   call next dir.dir, spacer leader.x, depth - 1, lnums || dir || '.'  /* <======= Recursive call. */
end dir                                                    /* Back to top of dir loop for next output line. */
return   /* end of next: */                                /* A leaf has been reached. */


bytes: procedure expose tot. opt.                          /* Count the bytes in this subdir. */
bytes = 0                                                  /* Both col width and number finding. */
call SysFileTree arg( 1)'\' || '*', 'f.', 'F'              /* List all files in dir. */
do i = 1 to f.0                                            /* For each file ... */
   parse var f.i . . bites . .                             /* find and total the directory bytes. */
   bytes = bytes + bites
end i
tot.b = tot.b + bytes                                      /* Running total bytes for tree. */
if opt.B then return bytes                                 /* Number of bytes in this dir. */
select
   when bytes > 999999999 then do; div = 1000000000; unit = 'G'; end
   when bytes >    999999 then do; div =    1000000; unit = 'M'; end
   when bytes >       999 then do; div =       1000; unit = 'K'; end
   when bytes >         0 then do; div =          1; unit = 'B'; end
   otherwise                       div =          1; unit = ' '
end
return format( bytes / div, 4, 0) || unit                  /* Rounded & shortened bytes. */


files: procedure expose tot.                               /* Count files in this subdir. */
call SysFileTree arg( 1)'\' || '*', 'f.', 'F'
tot.f = tot.f + f.0                                        /* Running total of files. */
return f.0                                                 /* Number of files in this dir. */


subdirs: procedure expose tot.                             /* Count the subdirs. */
call SysFileTree arg( 1)'\' || '*', 'd.', 'DO'             /* Get a list of subdirs in this dir. */
tot.d = tot.d + d.0                                        /* Running total of subdirs. */
return d.0                                                 /* Number of subdirs in this dir. */


width: procedure expose tot. opt. sdw sfw sbw              /* Used by 'numbers at left'. */
parse arg thisdir, depth                                   /* Sets column widths. */
if depth = 0 then return
call SysFileTree thisdir || '\' || '*', 'dir.', 'DO'       /* Are subdirs here? */
do dir = 1 to dir.0                                        /* If any, process the subdir list. */
   if opt.D then sdw = max( length( _commas( subdirs( dir.dir))), sdw)   /* # subdirs */
   if opt.F then sfw = max( length( _commas(   files( dir.dir))), sfw)   /* # files */
   if opt.B then sbw = max( length( _commas(   bytes( dir.dir))), sbw)   /* # bytes */
   call width dir.dir, depth - 1                           /* <======= Recursive call. */
end dir                                                    /* Back to top of dir loop for next dir. */
return


atts: procedure                                            /* Attributes of a Directory. */
call SysFileTree arg( 1), 'f.', 'D'
parse var f.1 cd ct . atts .
return atts cd ct                                          /* atts date time */


bratot: procedure
parse arg thisdir
brabyttot = 0
CALL SysFileTree thisdir||'\'||'*', 'file.', 'FS'          /* Work on current tree files. */
DO file = 1 TO file.0
   parse var file.file 1 . 17 big 29 .
   brabyttot = brabyttot + big
END file
return brabyttot


dotted:
call Directory root                                        /* Set root as new current directory. */
do while length( dotnum) > 0
   call SysFileTree '*', 'sd.', 'DO'                       /* Works on current directory. */
   parse var dotnum num '.' dotnum                         /* First relative directory number. */
   if num < 1 | num > sd.0 then do
         say 'Number out of range.'
         call Directory curdir                             /* Bombing out - Go home. */
         exit
   end
   call Directory sd.num                                   /* Set new current directory. */
   drop sd.                                                /* SubDirectory list. */
end    /* do while length( dotnum) */
exit                                                       /* You are in the dotted directory. */
