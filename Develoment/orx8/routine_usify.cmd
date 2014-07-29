/*
program:   routine_USIfy.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   filters a string to contain English alphanumeric chars only; embedded non-alphanum chars are
           translated into an underscore ("_")
version:   1.0
date:      1997-04-15
changed:   ---

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     call or require & see code, resp. comments
           (also, you might copy & paste the code to the desired module, given its size)

comments:  prepared for the "8th International Rexx Symposium 1997", April 1997, Heidelberg/Germany


All rights reserved and copyrighted 1995-1997 by the author, no guarantee that
it works without errors, etc.  etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.
*/


/* produce translation tables to allow for "filtering" US-letters and numbers (e.g. for anchor-names) */
/* needed for routine "USify" in rgf-utility programs                                                 */
                        /* English alphanumeric letters */
tmp = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456790"
table_in  = XRANGE( )   /* get all chars */
                        /* set all non-alphanumeric chars to blank      */
table_out = TRANSLATE( table_in, tmp, tmp || table_in, " " )

.local ~ us.table_in  = table_in        /* save into local environment  */
.local ~ us.table_out = table_out       /* save into local environment  */


/* --->
   say "demoing USify ..."
   a = "Åber <den> Wîlkchen, mu· die Freiheit & ..."
   say "table_out" pp( .us.table_out )
   say pp( a )
   say pp( TRANSLATE( a, .us.table_out, .us.table_in) )
   say pp( usify( a ) ) "<--- from USIfy()"

EXIT

pp : procedure; return "[" || arg( 1 ) || "]"
<--- */




/* ------------------------------------------------------------------------------ */
/* just allow US-letters and numbers, replace anything else with *ONE* underscore   */
:: ROUTINE USIfy                        PUBLIC
   USE ARG string

   RETURN SPACE( TRANSLATE( string, .us.table_out, .us.table_in ), 1, "_" )
/******************************************************************************/


