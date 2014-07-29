/*
program:   routine_ok.cmd
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


/******************************************************************************/
/*                                                                            */
/* name:    ok( boolean expression )                                          */
/*                                                                            */
/* purpose: return a string indicating "o.k." or "not o.k.", if .true resp.   */
/*          .false was given                                                  */
/*                                                                            */
/* returns: return a verbatim string                                          */
/*                                                                            */
/* remarks: ---                                                               */
/*                                                                            */
/* created: rgf, 95-08-23                                                     */

:: ROUTINE ok                    PUBLIC
   IF ARG(1) = 0 THEN RETURN "*** not o.k. ! ***"
                 ELSE RETURN "o.k."
/******************************************************************************/


