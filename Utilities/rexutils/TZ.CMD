/* TZ              CMD by Gord Snider  2011/12/05  v00.02.00  2017/01/30     */
/* PURPOSE: To decode, from the command line, your TZ setting, as found as an
OS/2 environment variable.

    SYNTAX: TZ [/?]

A full length TZ variable, in OS/2, will tell you:
- the acronym for the time zone you are in;
- number of hours that time zone is
  (ahead,later,east,'+')/(behind,earlier,west,'-'), of Greenwich Mean Time;
Then if Daylight Saving time is used:
- the Daylight Saving Time acronym;
- the number of the month to go to daylight saving;
- the number of the week in the month to go to daylight saving;
- the number of the day of the week, to go to daylight saving, 0 = Sunday;
- the number of seconds after midnight the change occurs;
- then it will tell you the numbers of the month, week, and day of week for
  the switch back to Standard Time;
- then it will tell you the size of the switch, in seconds.

   OPTIONS:
/?   show a help screen and exit

NOTE: I sometimes see the TZ variables for North America as being a POSITIVE
      number of hours offset from UTC.  My searches show the number of hours
      offset in North America (whole western hemisphere) should be NEGATIVE.
NOTE: This script is written only for North America.
NOTE: This script assumes that RexxUtil.DLL is already loaded.
NOTE: Because this script uses RexxUtil.DLL it is likely to work only with
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
      end ll                                               /* end of list-a-help-line loop */
      exit 0
end   /* help */

string = value( 'tz',, 'OS2ENVIRONMENT')

parse var string  zone ',' m1 ',' w1 ',' d1 ',' t1 ',' m2 ',' w2 ',' d2 ',' t2 ',' s

flag = 0                                        /* 0 = Standard time, 1 = Daylight Saving Time */
s_t = ''                                        /* Standard Time zone acronym */
a_b = ''                                        /* ahead or behind GMT */
d_t = ''                                        /* Daylight Saving Time acronym */

do i = 1 to length( zone)                       /* Decode the time zone data ... */
   x = substr( zone, i, 1)                      /* character by character.       */
   select
      when verify( x, '0123456789+-', 'M') > 0 then do    /* Have hit the hours ahead/behind part. */
         a_b = a_b || x                         /* Build the number of hrs ahead/behind quantity. */
         flag = 1                               /* Offset built */
         end
      when flag then                            /* Build the Daylight Saving Time acronym. */
         d_t = d_t || x
      otherwise                                 /* Build the Standard Time time zone acronym. */
         s_t = s_t || x
   end   /* select */
end i

say
say 'This TZ string comes from the OS/2 Environment.'                          /* To Screen */
say string                                                                     /* To Screen */
say 'and provides the following data:'
say
if s_t = 'AST' then say 'Atlantic Time Zone'                                   /* To Screen */
if s_t = 'EST' then say 'Eastern Time Zone'
if s_t = 'CST' then say 'Central Time Zone'
if s_t = 'MST' then say 'Mountain Time Zone'
if s_t = 'PST' then say 'Pacific Time Zone'

if left( a_b, 1) = '-' then
      ab = 'behind (west of, earlier in the day than)'
   else
      ab = 'ahead (east of, later in the day than)'

say a_b 'hours' ab 'Greenwich Mean Time.'                                      /* To Screen */
say

/* If all Daylight Saving Time data is present ... */
if m1 = '' | w1 = '' | d1 = '' | t1 = '' | m2 = '' | w2 = '' | d2 = '' | t2 = '' | s = '' then nop
   else do
   /* Spring forward */
   m3 = word( 'January' 'February' 'March' 'April' 'May' 'June' 'July' 'August' 'September' 'October' 'November' 'December',  m1)

   if sign( w1) = -1 then do
         ord = word( '00'x 'second' 'third' 'fourth' 'fifth', abs( w1))
         f_l1 = 'last'
         end
      else do
         ord = word( 'first' 'second' 'third' 'fourth' 'fifth', w1)
         f_l1 = ''
         end
   day1 = word( 'Sunday' 'Monday' 'Tuesday' 'Wednesday' 'Thursday' 'Friday' 'Saturday', d1 + 1)

   say 'Spring forward' s 'seconds, ('s/3600' hour), to Daylight Saving Time'     /* To Screen */
   say t1 'seconds ('t1/3600' hours) after midnight on the' ord f_l1 day1 'in' m3'.' /* To Screen */
   say

   /* Fall back */
   if sign( w2) = -1 then do
         ord = word( '00'x 'second' 'third' 'fourth' 'fifth', abs( w2))
         f_l2 = 'last'
         end
      else do
         ord = word( 'first' 'second' 'third' 'fourth' 'fifth', w2)
         f_l2 = ''
         end
   day2 = word( 'Sunday' 'Monday' 'Tuesday' 'Wednesday' 'Thursday' 'Friday' 'Saturday', d1 + 1)
   m4 = word( 'January' 'February' 'March' 'April' 'May' 'June' 'July' 'August' 'September' 'October' 'November' 'December',  m2)

   say 'Fall back' s 'seconds, ('s/3600' hour), to Standard Time'                 /* To Screen */
   say t2 'seconds ('t2/3600' hours) after midnight on the' ord f_l2 day2 'in' m4'.' /* To Screen */
end

exit 0
