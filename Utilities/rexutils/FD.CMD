/* FD  (FindDirs)  CMD by Gord Snider              v01.05.00  2017/04/15     */
/* PURPOSE: Given a (partial) directory name, find and display all path names
that have that (partial) name, with a number.  Entering that number will make
that directory current.  Default action is to search all local drives.

    SYNTAX:   FD target [/Dd1: d2: ...]
    or        FD " tar get " [/Dd1: d2: ...]
    or        FD /?

     WHERE:
target    is the full name, or partial name, of a directory.
" tar get "   is a directory name that has a space in it, and/or at the start,
and/or at the end, or special characters.  Enclose the name in DOUBLE quotes.

   OPTIONS:
/D  prefixes a list of drives (d1: d2: ...) to be searched.
/?  shows a help screen and exits.

NOTE: This script works best in a large window, e.g. MODE CO100,43
NOTE: This script assumes RexxUtil.DLL is already loaded.
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

arg target '/' . +0

if pos( '"', target) > 0 then                              /* Are there quotes around the target? */
      parse var target '"' target '"'                      /* Strip them off. */
   else target = strip( target)                            /* Remove any trailing blanks. */

opline. = ''                                               /* Array for output lines. */
opline  = 0                                                /* opline = output line number */
dirline = 0                                                /* Count of directory lines. */

if opt.D then
      drivemap = mod.D                                     /* Search specified drives. */
   else
      parse value SysDriveMap( , 'LOCAL') with drivemap 'P:'   /* Search all LOCAL drives before P: */

do i = 1 to words( drivemap)                               /* Step thru drivemap drives. */
   current = word( drivemap, i)                            /* Pick next drive letter. */
   if SysDriveInfo( current) <> '' then                    /* Skip any non-responding drives. */
         call next current                                 /* Pass the drive root. */
end i

say "Type 'number <ENTER>', to switch; or <ENTER>, to exit."
opline = opline + 1
pull gotonum                                               /* Capture any drive number. */
if gotonum <> '' then                                      /* A directory number was selected. */
      call directory( opline.gotonum)                      /* Make that directory current. */

exit 0


NEXT: procedure expose opline target rows opline. oldrows oldcols dirline

parse arg thisdrive                                        /* Pick up current directory name. */

say
say 'Scanning drive' thisdrive '...'
opline = opline + 2

call SysFileTree thisdrive || '\' || '*', 'dir.', 'SDO'    /* Pick up subdirectories of current directory. */

do dir = 1 to dir.0                                        /* Loop through all subdirectories. */
   if pos( target, translate( dir.dir)) > 0 then do        /* If a directory contains target string ... */
      dirline = dirline + 1                                /* Increment directory line number. */
      opline = opline + 1                                  /* Increment screen line number. */
      say right( dirline, 4) dir.dir                       /* SAY directory number and name. */
      opline.dirline = dir.dir                             /* Save the output. */

      if opline > rows - 4 then do                         /* Is screen full? */
            say 'Type directory number, <ENTER>, to switch; or <ENTER>, to continue; or 0 to exit.'
            opline = opline + 1
            pull gotonum
            if gotonum = 0 then exit
            if gotonum <> '' then do                       /* A directory number was selected. */
                  call directory opline.gotonum            /* Make that directory current. */
                  exit
                  end
               else opline = 0                             /* Reset the opline number for next screenfull. */
            end   /* if row ... then */
      end   /* if pos( ... then */
end dir

return
