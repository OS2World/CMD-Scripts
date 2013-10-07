/* MAINTAINER: Gili Tzabari (L8R@email.com)
   PLATFORM: OS/2 or eCS

   The following REXX code appends the the second argument to the environment setting associated with
   the first argument.

   For example, "addenv path c:\mytoy;" executes "set path=%path%;c:\mytoy"
*/

Parse Arg args
if (value(word(args, 1),,'OS2ENVIRONMENT')='') then
  'set ' || word(args, 1) || '=' || word(args, 2)
else
  'set ' || word(args, 1) || '=%' || word(args, 1) || '%;' || word(args, 2)
