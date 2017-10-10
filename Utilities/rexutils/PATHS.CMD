/* PATHS           CMD by Gord Snider  2009/06/06  v01.13.00  2017/07/16     */
/* PURPOSE: Default action is to break into single paths the PATH entry from
the environment, as source data.  Optional selections of other environment
variables as source data are available.  Also the selection may be selected
from the CONFIG.SYS file, directly, as source data.

    SYNTAX:  PATHS  [selection][,fnft]  [/C]
        or   PATHS /?

     WHERE:
selection  is one of the following literals;
           path   (the default)
           libpath  (Only valid with /C)
           dpath
           help
           classpath
           include
           bookshelf
           lib

fnft       filename.filetype of a file you are looking for in a directory in the
           selected chain of directories.
           FN.FT MUST BE SEPARATED FROM THE SELECTION BY A COMMA.

   OPTIONS:
/? - shows a help screen and exits.
/C - selects the raw data from CONFIG.SYS as source directly.

The first line of the output shows the following information:
selection (PATH, LIBPATH, DPATH, HELP, CLASSPATH, INCLUDE, BOOKSHELF, LIB),
source (Environment or CONFIG.SYS),
number of entries in the selection,
total number of characters in the selection.

Any directory that shows red on the screen is listed in the selection but no
longer exists on the hard drive.
Any directory that shows yellow on the screen is listed in the selection
and exists on the hard drive but has no files in it.

The fnft, if it exists, is listed after the path it is found in.

NOTE: This cmd requires my external REXX function _COUNT()
NOTE: This cmd assumes that RexxUtil.DLL has already been loaded, so this cmd
      is likely to run only on OS/2-compatible systems.
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

PARSE VALUE Value( 'OSDIR', , 'OS2ENVIRONMENT') WITH bootdrive '\' .  /* reflects bootdrive */

config = bootdrive'\config.sys'                            /* Your CONFIG.SYS file on this bootdrive */

clr.red = '1B'x || '[31;1;m'                               /* red, high     */
clr.ylw = '1B'x || '[33;1;m'                               /* yellow, high  */
clr.nrm = '1B'x || '[0;m'                                  /* normal        */

ARG preselection '/' . +0                                  /* all arguments */
PARSE VAR preselection selection . ',' fnft

IF selection = '' THEN selection = 'PATH'

IF WordPos( selection,      'PATH LIBPATH DPATH BOOKSHELF CLASSPATH INCLUDE HELP LIB') = 0 THEN DO
      SAY selection 'not a valid choice.'
      SAY 'Valid choices are PATH LIBPATH DPATH BOOKSHELF CLASSPATH INCLUDE HELP LIB'
      EXIT
END

IF selection = "LIBPATH" THEN opt.C = 1                    /* Force input from CONFIG.SYS */

/* Must have at least a dummy file to search for */
IF fnft = '' THEN fnft = "ÿ"                               /* "ÿ" = ALT+255 = xFF */

SAY
lines = 1                                                  /* counting window lines */

flag = 'N'                                                 /* Found the data source yet? */

/* Choose the data source, ENVIRONMENT or CONFIG.SYS */
IF opt.C THEN DO                                           /* selection data from CONFIG.SYS */
      CALL Stream config, 'C', 'OPEN READ'

      DO WHILE Lines( config)                              /* line by line thru CONFIG.SYS */
         line = LineIn( config)                            /* next line from CONFIG.SYS */
            /* find the line from source that we want */
         IF ((Left( line,  9) = 'SET PATH=')      & (selection = 'PATH'))      | ,
            ((Left( line,  8) = 'LIBPATH=')       & (selection = 'LIBPATH'))   | ,
            ((Left( line, 10) = 'SET DPATH=')     & (selection = 'DPATH'))     | ,
            ((Left( line, 14) = 'SET BOOKSHELF=') & (selection = 'BOOKSHELF')) | ,
            ((Left( line, 14) = 'SET CLASSPATH=') & (selection = 'CLASSPATH')) | ,
            ((Left( line, 12) = 'SET INCLUDE=')   & (selection = 'INCLUDE'))   | ,
            ((Left( line,  9) = 'SET HELP=')      & (selection = 'HELP'))      | ,
            ((Left( line,  8) = 'SET LIB=')       & (selection = 'LIB'))
            THEN DO      /* found wanted line */
               PARSE VAR line . '=' paths                  /* split off data part of line */
               srce = 'CONFIG.SYS'
               CALL Stream config, 'C', 'CLOSE'
               flag = 'Y'
               LEAVE     /* do while lines( config), found wanted line */
         END   /* if  ((left( line, */
      END   /* do while Lines( config), read next line */

      IF flag = 'N' THEN DO
            SAY 'Source' selection 'not found in CONFIG.SYS.'
            EXIT
      END
   END   /*  if opt.C then do */
   ELSE DO                                                 /* selection data from ENVIRONMENT */
      PARSE VALUE Value( selection,,'OS2ENVIRONMENT') WITH paths      /* assign whole data string to paths variable */
      IF paths = '' THEN DO
            SAY "Source" selection "not found in ENVIRONMENT."
            EXIT
      END
      srce = 'ENVIRONMENT'
END   /* if opt.C ... then ... else */

paths_lngth = Length( paths)
entries = _Count( ';', paths)
IF Substr( paths, paths_lngth, 1) <> ";" THEN
      entries = entries + 1
SAY 'Selection:' selection',  Source:' srce',  Entries:' entries',  Characters:' paths_lngth


/* Break up the data string into units */
DO UNTIL Length( paths) = 0
   PARSE VAR paths path ';' paths                          /* split off next directory from selection at ; */

   CALL SysFileTree path, 'stem.', 'D'                     /* check for directory's existence */

   IF stem.0 = 0 THEN                                      /* dir does not exist on hard drive */
         clr.what = clr.red
      ELSE DO

         CALL SysFileTree Strip( path, 'T', '\')'\'||'*', 'hit.', 'F'

         IF hit.0 = 0 THEN                                 /* dir exists on hard drive but is empty */
               clr.what = clr.ylw
            ELSE DO
               clr.what = clr.nrm                             /* dir exists and has files in it. */

               CALL SysFileTree Strip( path, 'T', '\')'\'fnft, 'hit.', 'F'

               IF hit.0 = 1 THEN
                     path = path hit.1
         END
   END   /* IF stem.0 = 0 THEN */

   SAY clr.what||path||clr.nrm                             /* output to screen */

   lines = lines + 1                                       /* one more window line */

   IF lines > (rows - 2) THEN DO                           /* window full? */
         SAY "<Enter> to continue ..."
         PULL
         lines = 1
         SAY
   END
END    /* do until Length( */

EXIT 0
