/* COMPDIRS        CMD by Gord Snider  2005/10/24  v02.01.00  2017/02/06     */
/* PURPOSE: Default action is to compare and report on the differences in file
content of 2 directories, the named directory and the current directory.  The
default comparison is on file name (case insensitive), date, time and size.
The comparison may be varied under switch control.

    SYNTAX:  COMPDIRS  "dir_name"  [/D]|[/C]  [/L] [/O]
        or   COMPDIRS  /?

     WHERE:
dir_name
      is a directory path, which must be enclosed in quotes,
      to have its filename list compared to the filename list of the current
      directory.
      The trailing backslash MUST be specified for a root, e.g.  C:\  ,
      for other directories beyond a root, NO trailing backslash,
      e.g. G:\cmd\devl
      The current directory will be used as the other directory name,

Optional switches:
/?    shows this help screen and exits
/D    compares subDIRECTORY names in the directory instead of filenames
/C    also shows files COMMON to both directories
/L    LOOSE compare, i.e. files must be equal in name only
/O    Output has no page breaks, (for redirecting output to a file)

NOTE: This script uses my Rexx External Function _color().
NOTE: This script assumes that RexxUtil.DLL is already loaded.
NOTE: Because this script uses RexxUtil.DLL it is likely to run
      only on OS/2-compatible systems.
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

parse arg name.1 '/' . +0                                  /* Split the quoted, named directory name from any options. */

name.1 = Strip( name.1, 'B')                               /* Strip spaces outside the quotes. */
name.1 = Strip( name.1, 'B', '"')                          /* Strip leading and trailing double quotes. */
name.1 = Strip( name.1, 'B', "'")                          /* Strip leading and trailing single quotes. */
name.1 = Strip( name.1, 'B', '"')                          /* Strip leading and trailing double quotes. */

if name.1 = '' then do
      say 'Directory name not specified.'
      exit
end

name.2 = Directory()                                       /* Capture the current directory name. */

if opt.D                                                   /* Comparing subdirectory names. */
      then do
         ff = 'D'
         object = 'Directories'                            /* Comparing subdirectory names. */
      end
      else do
         ff = 'F'                                          /* Comparing file names. */
         object = 'Files'
end

if opt.L then do                                           /* Loose compare. */
      oo = 'O'
      parse value 0 0 0 0 with kk nn mm pp                 /* Parsing columns */
   end
   else do                                                 /* Standard compare. */
      oo =  ''
      parse value 8 7 11 1 with kk nn mm pp                /* Parsing columns */
end

curdir = Directory()                                       /* Home to come back to. */
total  = 0                                                 /* Number of files in group. */
dir.   = 0                                                 /* All variables set to FALSE. */
line   = 0                                                 /* Count of screen lines. */

call say                                                   /* Blank line after command. */

name.1 = Directory( name.1)                                /* Verify found & expand to FQFN & change. */
call Directory( curdir)                                    /* If changed, revert to current. */
if name.1 = '' then do                                     /* Not found. */
      say arg( 1) 'not found.'
      exit
end

call say "Comparing ..."

/* Build 2 directory listing arrays  */
do i1 = 1 to 2                                             /* Index = number of directories. */
   name.i1 = strip( name.i1, 'T', '\') || '\'              /* One, and only one, trailing '\'. */

   call say _color( name.i1, wht)                          /* Report directory name! */
                                                           /* Number-indexed array contains ... */
   call SysFileTree name.i1'*', sfte.i1., ff || OO         /* filenames, date, time, size. */
                                                           /* sfte. = SysFileTreeEntry list. */
   do sfte_index = 1 to sfte.i1.0                          /* Build associative-dir.i filename arrays. */
      parse var sfte.i1.sfte_index date time size . (name.i1) fn     /* Split off each filename from FQFN. */
      fnu = Translate( fn)
      dir.i1.fnu.date.time.size = 1                        /* Dir.i filename array, value = TRUE */
   end sfte_index
end i1

/* List Common objects in directories. */
if opt.C then do
      call say                                             /* Blank line at beginning of Common Report. */
      call say _color(object 'common to' name.1 'and' name.2 '...', wht)    /* Title. */

      do sfte_index = 1 to sfte.2.0
         parse var sfte.2.sfte_index date time size . (name.2) fn
         fnu = Translate( fn)
         if dir.1.fnu.date.time.size then do               /* This filename also in other directory array. */
               total = total + 1                           /* Running total of common objects. */
               call say right( date, kk) || right( time, nn) || right( size, mm) || copies( ' ', pp) || fn
         end     /* if dir.1. ... then do */
      end sfte_index
   call say _color( total object 'common to' name.1 'and' name.2, wht)   /* Conclusion. */
   total = 0                                               /* Reset running total. */
end   /* then do  opt.C */

/* List Unique objects in directories. */
aa = 1
bb = 2

do 2                                                       /* Search for objects unique in each directory. */
   call say                                                /* Blank line at beginning of Unique Report. */
   call say _color( object 'unique in' name.aa, wht)       /* Title. */

   do sfte_index = 1 to sfte.aa.0                          /* Search for unique files in a directory. */
      parse var sfte.aa.sfte_index date time size . (name.aa) fn
      fnu = Translate( fn)
      if \(dir.bb.fnu.date.time.size) then do              /* Filename also in directory.b array? */
            total = total + 1
            call say right( date, kk) || right( time, nn) || right( size, mm) || copies( ' ', pp) || fn
      end   /* if \(dir.bb.fn ... then do */
   end sfte_index                                          /* No?  Unique! */

   call say _color( total object 'unique in' name.aa, wht) /* Conclusion. */
   total = 0                                               /* Reset running total. */
   aa = 2
   bb = 1
end   /* do 2 */

exit 0


say:
parse arg data
say data
line = line + 1
if opt.O then return
if line >= (rows - 3) then do
      say '<Enter> to continue ...'
      pull
      line = 0
end
return
