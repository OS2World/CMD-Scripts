/* WINSIZE         CMD by Gord Snider  2011/01/17  v01.04.00  2017/02/10     */
/* PURPOSE: To set or show the size of a command window.

    SYNTAX: WINSIZE [columns] [rows]

Although SysTextScreenSize() (used by this script) returns Rows Columns,
in that order, this script outputs Columns before Rows because the usual use
of that data is with a MODE command, which accepts Columns, Rows, in that
order.

There are two window sizes that are useful to me that can be set just by
specifying a width,
230  results in a mode command of 230 35
160  results in a mode command of 160 47

NOTE: This script may issue a MODE command to change window size.
NOTE: This script assumes that RexxUtil.DLL has already been loaded.
NOTE: Because this script uses Rexxutil.DLL functions it likely works only in
      OS/2-compatible systems.
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

parse arg new_columns new_rows                             /* Get the new window size. */

if (new_columns = '' & new_rows = '') then
      nop
   else
      if ª(new_columns = '' | new_rows = '') then
            if new_columns * new_rows < 8192 then
                  'MODE' new_columns new_rows
               else say 'MODE values out of range.'              /* Set the new window size. */
         else do
            select
               when new_columns = 230 & new_rows = '' then new_rows = 35
               when new_columns = 160 & new_rows = '' then new_rows = 47
               otherwise nop
            end
      'MODE' new_columns new_rows
end

parse value SysTextScreenSize() with rows cols             /* Get the window size */
say cols 'Columns,   'rows 'Rows,   'rows * cols 'Characters,     8192 Max Characters'

exit 0
