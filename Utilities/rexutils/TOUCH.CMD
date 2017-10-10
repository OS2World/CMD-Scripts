/* TOUCH           CMD by Gord Snider  2003/02/02  v01.02.00  2016/12/18     */
/* PURPOSE: To set a file's date and time to the current date and time.

    SYNTAX:  TOUCH target | *
       or   TOUCH /?

     WHERE:
target  is a filename in the current directory; or
*       is all the files in the current directory;

/?      optional switch to show a help screen and exit;

NOTE: This cmd assumes that RexxUtil.DLL has already been loaded.
NOTE: The use of RexxUtil.DLL makes it likely that this will run only on OS/2
      compatible systems.
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

parse arg target '/' . +0

if pos( '"', target) > 0 then
   parse var target . '"' target '"' .

say 'Date and Time set to' Date() Time()

if target = '*' then do
      call SysFileTree '*', 'file.', 'FO'
      do i = 1 to file.0
         call SysSetFileDateTime( file.i)
         if result > 0 then do
               say file.i 'RC =' result
               exit 1
               end /* do */
      end i
      end /* do */
   else call SysSetFileDateTime( target)

exit 0
