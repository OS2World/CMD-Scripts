/* BYTES           CMD by Gord Snider  2010/11/24  v00.04.00  2016/12/17     */
/* PURPOSE: Default action is to produce a screen display after calculating
the number of subdirectories, the number of files, and the number of bytes
occupied by a whole branch of a directory tree, from the CURRENT directory
as root, out to all its leaves.
This behaviour may be modified by specifying another directory as the root
and/or by using switches to vary the output.

    SYNTAX:  BYTES [root] [/C] [/D] [/F[N[N]]] [Lx] [/S]
        or   BYTES /?

The root may be
  - the unqualified name of a subdirectory in the current directory;
  - the fully qualified name of any local (sub)directory.
  - the root of the current drive, i.e. '\'
  - the root directory of a local drive (specified with a drive letter,
    a colon, and a backslash, e.g. C:\),
  -  * ; all subdirectories in the current directory.
  - root may also be a single dot, standing for the current directory,
    or two dots, standing for the parent directory.

The switches are slash-letter combinations.  Except for /?, which must be
used alone, you may specify any number of options, in any order.  Their
effects are cumulative.
/?     produces this simple help screen and then exits
/C     shows data in COLOUR: subdirectories=magenta; files=yellow; bytes=cyan
/D     lists each subDirectory as it is encountered
/F[N[N]]
       lists File's data for each file found in the branch;
       the addition of N reduces the file listing to Fully Qualified Name only;
       second N reduces file listing to fn.ft
       If this option is selected its output appears after the output for /D if
       it is selected.
/Lx    sets a maximum number of directory nesting levels deeper,
/S     Subdirectory summary, gives Subtotals by subdirectory,
       subdirectories of present directory in magenta, files in yellow,
       bytes in cyan.
       If this option is selected its output appears after the output for /F if
       it is selected.

NOTE: This cmd assumes the RexxUtil DLL is already loaded, which makes it
      likely to run only on OS/2-compatible systems.
NOTE: This cmd uses my _commas() external function.
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
      end ll                                               /* end of list-a-help-line loop */
      exit 0
end   /* help */

numeric digits 12                                          /* 100s of GigaBytes */

arg root '/' . +0                                          /* Root directory of tree. */
root = Strip( root, 'T')                                   /* Trailing blanks. */
if root = '' then                                          /* Final check.  Is root directory valid? */
      root = Directory()                                   /* Default is current directory. */

if opt.L then                                              /* qualify 'Level' argument */
      if datatype( mod.L, 'Whole') & (mod.L > -1) then
            depth = mod.L                                  /* Additional levels of depth */
         else do
            say 'Level x must be a positive integer or zero.'
            exit
      end
   else depth = ''

all.sdirs = 0         /* + Root */                         /* Total number of subdirectories in tree. */
all.files = 0                                              /* Total number of files in tree. */
all.bytes = 0                                              /* Total number of bytes in tree. */
lines     = 1                                              /* Count of window lines. */

clr.      = ''                                             /* To hold ANSI color array. */
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

curdir = Directory()                                       /* Save current directory for return. */
root = directory( root)                                    /* Root must now be NULL or FQFN. */
call directory curdir                                      /* Come back here. */
if root = '' then do
      say 'Specified Directory not found.'
      exit
end

call next root, depth          /* <======= */              /* Off and running ...  */

/* Now finish up. */
if (opt.D | opt.F | opt.S) then
      if lines > (rows - 5) then do                        /* Is the window full? */
            say '  <Enter> to continue ....'
            pull .
end

say
say clr.wht || 'Totals for tree based on:' root         || clr.nrm 'to' depth 'additional levels.'
say clr.mga || '   SubDirectories:' || _commas( all.sdirs) || clr.nrm ,
    clr.ylw || '   Files:'          || _commas( all.files) || clr.nrm ,
    clr.cyn || '   Bytes:'          || _commas( all.bytes) || clr.nrm

exit 0


/* This procedure is executed on each directory to total the number of */
/* directories, files, bytes there. */
next: procedure expose opt. mod. all. clr. rows lines root /* Execute once per directory. */
parse arg thisdir, depth
here_bytes = 0                                             /* Total bytes for this directory. */
thisdir = strip( thisdir, 'T', '\') || '\'                 /* Prevent SysFileTree conflict. */

/* With these two CALLs I will collect all the data I need to produce reports. */
call SysFileTree thisdir || '*', 'sdirs.', 'DO'            /* List of Subfolders in 'sdirs.'. */
call SysFileTree thisdir || '*', 'files.', 'F'             /* List of Files here in 'files.'. */

/* Now process any files in this directory. */
all.files = all.files + files.0                            /* Running total of number of files. */
do file = 1 to files.0                                     /* Loop to process list of filenames in directory. */
   parse var files.file 1 date 9 . 11 time 17 . 19 size 29 . 31 attr 36 . 38 thisfile
   all.bytes = all.bytes + size                            /* Running cumulative total of bytes. */
   here_bytes = here_bytes + size                          /* Total of bytes in this directory. */

   if opt.F then do                                        /* Show files data. */
         select
            when (mod.F = 'S')  then say date time size attr Filespec( 'N', thisfile)
            when (mod.F = 'N')  then say                                    thisfile
            when (mod.F = 'NN') then say                     Filespec( 'N', thisfile)
            otherwise                say date time size attr                thisfile
         end  /* select */
         lines = lines + 1
         if lines > (rows - 3) then do
               say '  <Enter> to continue ..'
               pull                                        /* Pause ... */
               say                                         /* Blank line at top of each window. */
               lines = 1
         end  /* if lines then do */
   end    /* if opt.F */
end file                                                /* Have processed all the files and bytes. */

if opt.S then do                                           /* Subdirectory subtotals. */

      say clr.wht || '....' thisdir       || clr.nrm' ' ,  /* 4 dot line subdirectory summary. */
          clr.mga || _commas( sdirs.0)    || clr.nrm' ' ,  /* giving subdirectories in this directory */
          clr.ylw || _commas( files.0)    || clr.nrm' ' ,  /* files in this directory and */
          clr.cyn || _commas( here_bytes) || clr.nrm       /* bytes in this directory. */

      lines = lines + 1
      if lines > (rows - 3) then do
            say '  <Enter> to continue ...'
            pull
            say                                            /* Blank line at top of each window. */
            lines = 1
      end   /* if lines then do */
end   /* if opt.S then do */
/* End of file processing. */

/* Now Process subdirectories in this directory. */
all.sdirs = all.sdirs + sdirs.0                            /* Add # of subdirectories here to total. */

do dir = 1 to sdirs.0                                      /* Process list of subdirectories */
   if opt.D then do                                        /* List subdirectory as encountered, unless ...  */
         lines = lines + 1

         say clr.wht || '..' sdirs.dir || clr.nrm          /* 2 dot line subdirectory announcement. */

         if lines > (rows - 3) then do
               say '  <Enter> to continue .....'
               pull
               lines = 1
         end
   end   /* if opt.D ... then */

   if depth = '' then
         call next sdirs.dir      /*<========>*/           /* Pivot point of the recursion */
      else if depth > 0 then
              call next sdirs.dir, depth - 1
end dir                                                    /* Back to top of dir loop */
return                                                     /* To line after 'Off and running' */
