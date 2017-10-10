/* FUNCTEST        CMD by Gord Snider  0000/00/00  v01.03.00  2016/11/29     */
/* PURPOSE: To serve as a launching program for functions or subroutines under
development or test when the main, i.e. calling, program is not (yet)
available.

    SYNTAX:    FUNCTEST function_name [argument(s)]
        or     FUNCTEST /?

     WHERE:
function_name  is the required filename of the function or subroutine you are
               testing
argument(s)    is whatever argument(s) the function or subroutine requires,
               in whatever form the function or subroutine requires

   OPTIONS:
/?    displays this help screen and exits.

NOTE: I need this cmd to test functions because my naming standard for external
      functions does not include a filetype, so they can't be run independently
      of a calling function.
NOTE: This cmd assumes that RexxUtil DLL has already been loaded.
NOTE: This cmd uses RexxUtil.DLL functions that make it likely to work only in
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

parse arg function arguments '/' . +0

if opt.T then "@SET RXTRACE=ON"                            /* Turns on TRACE for the execution of the function */

interpret call function arguments

if opt.T then "@SET RXTRACE="                              /* Turns off TRACE for the function */

if symbol('RESULT') = 'VAR' then say result                /* If there is a RESULT show it. */

exit 0
