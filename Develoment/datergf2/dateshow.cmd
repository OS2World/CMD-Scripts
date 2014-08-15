/*
program: rgfshow.cmd
type:    REXXSAA-OS/2, version 2.x
purpose: explain and demo REXX-scripts
version: 1.2
date:    1991-05-20
         1991-08-02
         1992-06-01, RGF, introduced SysGetKey()
         1993-03-22, RGF, show just DATERGF-related functions
needs:   RxUtils loaded

author:  Rony G. Flatscher,
         Wirtschaftsuniversit„t/Vienna
         Rony.Flatscher@wu-wien.ac.at

remark:  this program makes extensive use of REXX' stems. If you wish
         to add your own programs, follow the following steps:
         1) Search last "toshow.0"-entry
         2) Add another "toshow.0.x"-entry, where "x" is the preceeding
            number incremented by one
         3) Search last "toshow."-block
         4) copy it (starting from the line containing "block" to the
            end
         5) change descriptions to your program
         6) add at the end of this script your examples in procedure
            form "YOUR_PROGRAM_NAME_EXTENSION:"
         7) add SHOW_IT-statements
            - if SHOW_IT has no arguments, a pause will be executed
            - argument1: describes following example
            - argument2: contains the PROGRAM-name with arguments (optional)
            - argument3: contains a remark pertaining to example (optional)
         8) If your program or REXX-procedure does not return a value, use
            "SHOW_IT2" instead of "SHOW_IT"


All rights reserved, copyrighted 1991, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything
(money etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it and that the accompanying tutorial "RGFSHOW.CMD" is being distributed
together with DATERGF.CMD, DATE2STR.CMD, ATRGF.CMD, TIMEIT.CMD

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.
*/


/* check whether RxFuncs are loaded, if not, load them */
IF RxFuncQuery('SysLoadFuncs') THEN
DO
    /* load the load-function */
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'       

    /* load the Sys* utilities */
    CALL SysLoadFuncs                                                 
END


/* define toshow-description-subscripts */
aha. = ''               /* set default value for stem to nothing = '' */
aha.1 = 'rexx'
aha.2 = 'description'
aha.3 = 'comment'
aha.4 = 'version'
aha.5 = 'date'
aha.6 = 'author'
aha.7 = 'address'
aha.8 = 'organization'
aha.9 = 'country'
aha.10 = 'rights'
aha.11 = 'misc'


toshow. = ''            /* set default value for stem to nothing = '' */
i = 0
toshow.0.1 = 1          /* index for DATERGF.CMD */
toshow.0.2 = 2          /* index for DATE2STR.CMD */
/*
toshow.0.3 = 3          /* index for ATRGF.CMD */
toshow.0.4 = 4          /* index for TIMEIT.CMD */
*/

/* DATERGF.CMD - block */
i = i + 1
toshow.i.rexx         = "DATERGF.CMD  - date/time conversions & arithmetics"
toshow.i.description  = "comprehensive set for date/time conversion & arithmetics"
toshow.i.comment      = "(accounts for change from Julian to Gregorian calendar in 1582)"
toshow.i.version      = "1.3"
toshow.i.date         = "1992/06/18"
toshow.i.author       = "Rony G. Flatscher"
toshow.i.address      = "Rony.Flatscher@wu-wien.ac.at"
toshow.i.organization = "Wirtschaftsuniversit„t Wien (University of Economics Vienna)"
toshow.i.country      = "Austria - heart of Europe"
toshow.i.rights       = "Copyrighted (1991), all rights reserved"
toshow.i.misc         = "donated to the public domain"

toshow.i.1            = " (1)   Show syntax"
toshow.i.1.1          = "CALL DATERGF ?"
toshow.i.2            = " (2)   Show conversions with sorted dates (YYYYMMDD)"
toshow.i.2.1          = "CALL DATERGF_CONVERSIONS"
toshow.i.3            = " (3)   Show arithmetics with sorted dates"
toshow.i.3.1          = "CALL DATERGF_BASIC_CALCULATIONS"
toshow.i.4            = " (4)   Show year related functions"
toshow.i.4.1          = "CALL DATERGF_YEAR"
toshow.i.5            = " (5)   Show month related functions"
toshow.i.5.1          = "CALL DATERGF_MONTH"
toshow.i.6            = " (6)   Show day related functions"
toshow.i.6.1          = "CALL DATERGF_DAY"
toshow.i.7            = " (7)   Show week related functions"
toshow.i.7.1          = "CALL DATERGF_WEEK"
toshow.i.8            = " (8)   Show quarter related functions"
toshow.i.8.1          = "CALL DATERGF_QUARTER"

toshow.i.9            = " (9)   Show additional functions"
toshow.i.9.1          = "CALL DATERGF_MISCELLANEOUS"
toshow.i.10           = "(10)   Show examples with today's date"
toshow.i.10.1         = "CALL DATERGF_EXAMPLES"
toshow.i.11           = "(11)   SHOW ALL EXAMPLES supplied herein"
toshow.i.11.1         = "CALL DATERGF_CONVERSIONS"
toshow.i.11.2         = "CALL DATERGF_BASIC_CALCULATIONS"
toshow.i.11.3         = "CALL DATERGF_YEAR"
toshow.i.11.4         = "CALL DATERGF_MONTH"
toshow.i.11.5         = "CALL DATERGF_DAY"
toshow.i.11.6         = "CALL DATERGF_WEEK"
toshow.i.11.7         = "CALL DATERGF_QUARTER"
toshow.i.11.8         = "CALL DATERGF_MISCELLANEOUS"
toshow.i.11.9         = "CALL DATERGF_EXAMPLES"
toshow.i.11.10        = "CALL DATERGF_STORY_DATES"
toshow.i.12           = "(12)   A little story about dates ..."
toshow.i.12.1         = "CALL DATERGF_STORY_DATES"
/* end of DATERGF.CMD - block */


/* DATE2STR.CMD - block */
i = i + 1
toshow.i.rexx         = "DATE2STR.CMD - format date into string pattern"
toshow.i.description  = "allow formatting of sorted date into string pattern"
toshow.i.comment      = "uses DATERGF.CMD"
toshow.i.version      = "1.2"
toshow.i.date         = "1993-09-20"
toshow.i.author       = "Rony G. Flatscher"
toshow.i.address      = "Rony.Flatscher@wu-wien.ac.at"
toshow.i.organization = "Wirtschaftsuniversit„t Wien (University of Economics Vienna)"
toshow.i.country      = "Austria - heart of Europe"
toshow.i.rights       = "Copyrighted (1991-1994), all rights reserved"
toshow.i.misc         = "donated to the public domain"

toshow.i.1            = " (1)   Show syntax"
toshow.i.1.1          = "CALL DATE2STR ?"
toshow.i.2            = " (2)   Show examples"
toshow.i.2.1          = "CALL DATE2STR_EXAMPLES"
/* end of DATE2STR.CMD - block */


/* ATRGF.CMD - block */
i = i + 1
toshow.i.rexx         = "ATRGF.CMD    - execute command later"
toshow.i.description  = "allows for (repeating) executions of given command at given time"
toshow.i.comment      = "uses DATERGF.CMD, DATE2STR.CMD, SLEEP.EXE"
toshow.i.version      = "1.5"
toshow.i.date         = "1994/03/03"
toshow.i.author       = "Rony G. Flatscher"
toshow.i.address      = "Rony.Flatscher@wu-wien.ac.at"
toshow.i.organization = "Wirtschaftsuniversit„t Wien (University of Economics Vienna)"
toshow.i.country      = "Austria - heart of Europe"
toshow.i.rights       = "Copyrighted (1991-94), all rights reserved"
toshow.i.misc         = "donated to the public domain"

toshow.i.1            = " (1)   Show syntax"
toshow.i.1.1          = "CALL ATRGF ?"
toshow.i.2            = " (2)   Show examples, executing command the next possible time"
toshow.i.2.1          = "CALL ATRGF_AS_FAST_AS_POSSIBLE"
toshow.i.3            = " (3)   Show examples, executing command the next given day or date"
toshow.i.3.1          = "CALL ATRGF_NEXT"
toshow.i.4            = " (4)   Show examples, executing command on EVERY given day or date"
toshow.i.4.1          = "CALL ATRGF_EVERY"
toshow.i.5            = " (5)   Show examples, executing command EVERYTIME INTERVAL passed by"
toshow.i.5.1          = "CALL ATRGF_INTERVAL"
toshow.i.6            = " (6)   SHOW ALL EXAMPLES supplied herein"
toshow.i.6.1          = "CALL ATRGF_AS_FAST_AS_POSSIBLE"
toshow.i.6.2          = "CALL ATRGF_NEXT"
toshow.i.6.3          = "CALL ATRGF_EVERY"
toshow.i.6.4          = "CALL ATRGF_INTERVAL"
/* end of ATRGF.CMD - block */

/* TIMEIT.CMD - block */
i = i + 1
toshow.i.rexx         = "TIMEIT.CMD   - time program or REXX-script"
toshow.i.description  = "allows for timing the duration of a program"
toshow.i.comment      = "uses DATE2STR.CMD"
toshow.i.version      = "1.1"
toshow.i.date         = "1991/08/02"
toshow.i.author       = "Rony G. Flatscher"
toshow.i.address      = "Rony.Flatscher@wu-wien.ac.at"
toshow.i.organization = "Wirtschaftsuniversit„t Wien (University of Economics Vienna)"
toshow.i.country      = "Austria - heart of Europe"
toshow.i.rights       = "Copyrighted (1991), all rights reserved"
toshow.i.misc         = "donated to the public domain"

toshow.i.1            = " (1)   Show syntax"
toshow.i.1.1          = "CALL TIMEIT ?"
toshow.i.2            = " (2)   Show examples"
toshow.i.2.1          = "CALL TIMEIT_EXAMPLES"
/* end of TIMEIT.CMD - block */


/* Start of program */
spaces = RIGHT('', 10)
DO FOREVER
   i = 1       /* show main menu */
   SAY
   SAY '==============================================================================='
   SAY
   DO WHILE toshow.0.i <> ''
      tmp = toshow.0.i
      SAY spaces "("i")" toshow.tmp.rexx
      i = i + 1
   END
   i = i - 1

   SAY
   SAY spaces "Enter choice: 1 -" i "(0 to quit demo-program)"
   DO FOREVER
      PULL answer
      IF TRANSLATE(answer) = "Q" THEN EXIT
      IF answer >= 0 & answer <= i THEN LEAVE
      ELSE BEEP(1000,10)
   END

   IF answer = 0 THEN LEAVE


   DO FOREVER   /* show appropriate submenu */
      spaces = RIGHT('', 10)
      SAY
      SAY '=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--='
      SAY
      SAY '     'toshow.answer.rexx':'
      SAY
      SAY spaces "(99)   About" WORD(toshow.answer.rexx, 1) "..."
      i = 1
      DO WHILE toshow.answer.i <> ''
         SAY spaces toshow.answer.i
         i = i + 1
      END
      i = i - 1

      SAY
      SAY spaces "Enter choice: 1 -" i", 99 (0 to end)"

      DO FOREVER
         PULL answer2
         IF TRANSLATE(answer2) = "Q" THEN EXIT

         IF (answer2 >= 0 & answer2 <= i) | answer2 = 99 THEN LEAVE
         ELSE BEEP(1000,10)
      END

      IF answer2 = 0 THEN LEAVE
      ELSE IF answer2 = 99 THEN
      DO  /* show author-stuff */
         i = 1
         DO WHILE aha.i <> ''
            INTERPRET "tmp = toshow.answer."||aha.i
            IF tmp <> '' THEN SAY RIGHT(aha.i,12)':' tmp
            i = i + 1
         END
         SAY

         SAY RIGHT("Hit a key to continue, q to quit immediately.", 79, "=")
         tmp = TRANSLATE(SysGetKey("noecho"))
         IF tmp = "Q" THEN EXIT    /* q for quit was pressed */
      END
      ELSE /* show examples */
      DO
          i = 1
          DO WHILE toshow.answer.answer2.i <> ''
             INTERPRET toshow.answer.answer2.i
             i = i + 1
          END
      END
   END
END
SAY "end of RGFSHOW.CMD --------------"
EXIT

/*****************************************************************************/
/*****************************************************************************/


/**********************/
/* DATERGF - examples */
/**********************/


DATERGF_CONVERSIONS:

CALL  SHOW_IT 'Calculate days since 0000/01/01 (== 1. day == 1) and the reverse'

CALL  SHOW_IT '- calculate days:',,
              'DATERGF("00000101")'
CALL  SHOW_IT '- calculate days:',,
              'DATERGF("19940301")'
CALL SHOW_IT


CALL  SHOW_IT '- calculate days:',,
              'DATERGF("99991231")'
CALL  SHOW_IT '- calculate days based on 0000/01/01 (= 1. day == 1) with optional time:',,
              'DATERGF("19940301 16:45:01")',,
              '(728356. day, time fraction .6979...)'
CALL  SHOW_IT '- calculate sorted date (with optional time) from days[.fraction]:',,
              'DATERGF("728356.69792824074074", "S")',,
              '(produces sorted date and optional time, flag: "S")'
CALL SHOW_IT



CALL  SHOW_IT 'Transform sorted date into Julian date and the reverse'

CALL  SHOW_IT '- transform given sorted date into Julian date:',,
              'DATERGF("19940301","J")',,
              '(60th day in 1994, flag: "J")'
CALL  SHOW_IT '- transform given Julian date into sorted date (Julian Reversed):',,
              'DATERGF("1994060","JR")',,
              '(1st March in 1994, flag: "JR")'
CALL SHOW_IT


CALL  SHOW_IT 'Transform time into decimal fraction and the reverse'

CALL  SHOW_IT '- transform given time into decimal fraction:',,
              'DATERGF("5:45:01pm","F")',,
              '(flag: "F")'
CALL  SHOW_IT '- transform given fraction into 24hour-time (Fraction Reversed):',,
              'DATERGF("0.739594907407407","FR")',,
              '(note: resulting time is 24hour-format, flag: "FR")'
CALL SHOW_IT



CALL  SHOW_IT 'Calculate seconds based on given days with optional decimal time fraction'

CALL  SHOW_IT '- calculate seconds from days[.fraction]:',,
              'DATERGF("1.739594907407407","SEC")'

CALL  SHOW_IT '- calculate days[.fraction] from seconds (Seconds Reversed):',,
              'DATERGF("150301","SECR")'

CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_BASIC_CALCULATIONS:

/* Calculations with sorted dates */
CALL  SHOW_IT 'Calculations on sorted dates:'

CALL  SHOW_IT '- difference between two sorted dates (optional time):',,
              'DATERGF("19940301 12:00","-S", "19940201")',,
              '(difference between both dates is 28.5 days)'
CALL SHOW_IT

CALL  SHOW_IT '- difference between sorted date and a given amount of days:',,
              'DATERGF("19940301 12:00", "-", "28.5")',,
              '(note: result without time, as time = 00:00:00)'
CALL  SHOW_IT '- addition between sorted date and a given amount of days:',,
              'DATERGF("19940201", "+", "28.5")'
CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_MISCELLANEOUS:

CALL  SHOW_IT 'Miscellaneous functions for sorted dates'

CALL  SHOW_IT '- check date (if valid, return sorted date):',,
              'DATERGF("19920229","C")',,
              '(valid, because it is a leap-year)'
CALL SHOW_IT

CALL  SHOW_IT '- check date:',,
              'DATERGF("19920230","C")',,
              '(invalid)'
CALL  SHOW_IT '- test if leap-year:',,
              'DATERGF("19920715","L")',,
              '(leap-year)'
CALL SHOW_IT

CALL  SHOW_IT '- test if leap-year:',,
              'DATERGF("19931105","L")',,
              '(not a leap-year)'
CALL SHOW_IT

RETURN
/*****************************************************************************/



DATERGF_YEAR:

CALL  SHOW_IT 'Year related functions for sorted dates'

CALL  SHOW_IT '- check sorted date and return year:',,
              'DATERGF("19940715","Y")'
CALL  SHOW_IT '- get first date of year (Year Begin):',,
              'DATERGF("19940715","YB")'
CALL SHOW_IT

CALL  SHOW_IT '- get last date of year (Year End):',,
              'DATERGF("19940715 8:05:01pm","YE")'
CALL  SHOW_IT '- get first date of year and add 182 days and 12 hours:',,
              'DATERGF("19940715","YB","182.5")'
CALL SHOW_IT

CALL  SHOW_IT '- return the semester of the given date (1. or 2. half of year):',,
              'DATERGF("19940715","HY")'
CALL  SHOW_IT '- return the beginning date of this date''s half-year (Half''s Year Begin):',,
              'DATERGF("19940715","HYB")'
CALL SHOW_IT

CALL  SHOW_IT '- return the ending date of this date''s half-year (Half''s Year End):',,
              'DATERGF("19940715","HYE")'
CALL  SHOW_IT '- return the beginning date of this date''s half-year, add 120.3333333333 days:',,
              'DATERGF("19940715","HYB", "120.3333333333")'
CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_MONTH:

CALL  SHOW_IT 'Month related functions for sorted dates'

CALL  SHOW_IT '- check sorted date and return month:',,
              'DATERGF("19940715","M")'
CALL  SHOW_IT '- return monthname:',,
              'DATERGF("19940715","MN")'
CALL SHOW_IT

CALL  SHOW_IT '- get first date of month (Month begin):',,
              'DATERGF("19940715","MB")'
CALL  SHOW_IT '- get last date of month (Month end):',,
              'DATERGF("19920215","ME")',,
              '(leap-year, therefore 29 days)'
CALL  SHOW_IT '- get last date of month and add 14 days:',,
              'DATERGF("19920215","ME","14")'
CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_DAY:

CALL  SHOW_IT 'Day related functions for sorted dates'

CALL  SHOW_IT '- check date and return day:',,
              'DATERGF("19940715","D")'
CALL SHOW_IT

CALL  SHOW_IT '- return dayname:',,
              'DATERGF("19940715","DN")'
CALL  SHOW_IT '- return weekdayindex (Monday = 1, ..., Sunday = 7):',,
              'DATERGF("19940715","DI")',,
              '(Fridays will allways return 5)'
CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_WEEK:

CALL  SHOW_IT 'Week of year related functions for sorted dates'

CALL  SHOW_IT '- return week of year:',,
              'DATERGF("19940715","W")'
CALL  SHOW_IT '- return week of year:',,
              'DATERGF("19940105","W")'
CALL  SHOW_IT '- Attention for the following ''exotic'' weeks:'
CALL SHOW_IT

CALL  SHOW_IT '- return week of year:',,
              'DATERGF("19921231","W")',,
              '(53. week is CORRECT !!!)'
CALL  SHOW_IT '- return week of year:',,
              'DATERGF("19930101","W")',,
              '(53. week is CORRECT !!!)'
CALL  SHOW_IT '- return week of year:',,
              'DATERGF("15821231","W")',,
              '(1582 had 10 days less, hence 51. week)'
CALL SHOW_IT

CALL  SHOW_IT '- return the date for Monday of this date''s week (Week Begin = Monday):',,
              'DATERGF("19940715","WB")',,
              '(Date for Monday)'
CALL  SHOW_IT '- return the date for Sunday of this date''s week (Week End = Sunday):',,
              'DATERGF("19940715","WE")',,
              '(Date for Sunday)'
CALL SHOW_IT

CALL  SHOW_IT '- return the date for Friday of this date''s week (add 4 to Monday):',,
              'DATERGF("19940715","WB", "4")',,
              '(Date for Friday, same as date itself)'
CALL  SHOW_IT '- return the date for Saturday of this date''s week (add 5 to Monday):',,
              'DATERGF("19940715","WB", "5")',,
              '(Date for Saturday)'
CALL  SHOW_IT '- return the date for last week''s Thursday (subtract 4 from Monday):',,
              'DATERGF("19940715","WB", "-4")',,
              '(Date for last week''s Thursday)'
CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_QUARTER:

CALL  SHOW_IT 'Quarter of year related functions for sorted dates'

CALL  SHOW_IT '- return the quarter of the given date:',,
              'DATERGF("19940715","Q")'
CALL  SHOW_IT '- return the beginning date of this date''s quarter (Quarter Begin):',,
              'DATERGF("19940715","QB")'
CALL SHOW_IT

CALL  SHOW_IT '- return the ending date of this date''s quarter (Quarter End):',,
              'DATERGF("19940715","QE")'
CALL  SHOW_IT '- return the ending date of this date''s quarter and add 45 days:',,
              'DATERGF("19940715","QE", "45")'
CALL SHOW_IT

RETURN
/*****************************************************************************/


DATERGF_EXAMPLES:

CALL  SHOW_IT 'Miscellaneous EXAMPLES of DATERGF() with today''s date:'

CALL  SHOW_IT '- today''s date is:',,
              'DATE("S")',,
              '("DATE" is a REXX-built-in-function)'
CALL  SHOW_IT '- return today''s dayname:',,
              'DATERGF(DATE("S"),"DN")'
CALL SHOW_IT

CALL  SHOW_IT '- return today''s dayindex (1 = Monday, ..., 7 = Sunday):',,
              'DATERGF(DATE("S"),"DI")'
CALL  SHOW_IT '- return today''s week of year:',,
              'DATERGF(DATE("S"),"W")'
CALL  SHOW_IT '- return present quarter:',,
              'DATERGF(DATE("S"),"Q")'
CALL SHOW_IT

CALL  SHOW_IT '- return today''s date in Julian format:',,
              'DATERGF(DATE("S"),"J")'
CALL  SHOW_IT '- return number of days elapsed since the beginning of this year:',,
              'DATERGF(DATE("S"),"-S", DATERGF(DATE("S"),"YB"))',,
              '(note the 1 day difference to Julian date!)'
CALL SHOW_IT

CALL  SHOW_IT '- return number of days elapsed since the beginning of this quarter:',,
              'DATERGF(DATE("S"),"-S", DATERGF(DATE("S"),"QB"))'
CALL  SHOW_IT '- return the Monday, two weeks ago:',,
              'DATERGF(DATE("S"),"WB", "-14")',,
              '(get Monday of this week and subtract 14 days)'

CALL SHOW_IT

RETURN
/*****************************************************************************/

DATERGF_STORY_DATES:


SAY 'A little story about dates ...'
SAY '=============================='
SAY
SAY 'Men allways tried to measure time.  In the beginning the best way to measure'
SAY 'it seemed to have been counting the days between two full moons (29,5306'
SAY 'days).  Then people started to count the number of full moons in order to'
SAY 'find the number which comprised a full year.  They alternatively used'
SAY '29 and 30 days for a moon-month. A full year consisted of six 29 day-months '
SAY 'and six 30 day-months giving a total of 354 days per moon-year.'
SAY
SAY 'As a true sun-year lasts 365 days (actually 365 days and 5:48:46) the'
SAY 'moon-year was off by 11 days.  Therefore different rules applied to adjust'
SAY 'to the sun-year by adding sometimes a thirteenth month to a month-year. The'
SAY 'Roman tax system was based on moon-months, so they had to pay more taxes in'
SAY 'moon-years consisting of 13 months (some think that therefore the Romans'
SAY 'thought that number 13 was one that drew bad luck).'
SAY
SAY 'The moon-year was used by most of the ancient peoples, e.g. Babylonians,'
SAY 'Jews, Greek, Romans, Japanese (until 1873 !), Chinese (until 1911 !) etc.'
SAY

CALL SHOW_IT

SAY 'The Egyptians were using 365 days for a year quiet early.  As the correct'
SAY 'time for the earth to turn around the sun is about 365,25 days the Egyptian'
SAY 'sun-year was off by one day every four years.  238 B.C.  they started to'
SAY 'introduce a leap-year every four years to correct the situation.'
SAY
SAY 'Julius Gaius Caesar introduced the Egyptian sun-year with correcting'
SAY 'leap-years every four years.  This new calendar was called the'
SAY 'Julian Calendar thereafter.'
SAY
SAY 'As mentioned above it takes exactly 365 days and 5:48:46 for the earth to'
SAY 'turn around the sun once and NOT 365 days and 6:00:00 as is implied by'
SAY '365,25 days. Therefore the Julian Calendar caused an error if it was used'
SAY 'for centuries as it assumed 11 minutes and 14 seconds more than was correct.'
SAY

CALL SHOW_IT

SAY 'In 1582 the error in the Julian Calendar accounted already for 10 whole'
SAY 'days.  The Roman Catholic Pope Gregor XIII therefore had the Julian Calendar'
SAY 'corrected by'
SAY
SAY '        - skipping 10 days in 1582 (4. October was followed by the 15.),'
SAY '        - changing the rule for leap-years: from then on every year'
SAY '          dividable without a rest by 4 was a leap-year (like the Julian'
SAY '          Calendar) EXCEPT for whole centuries which are not dividable'
SAY '          without a rest by 400 (i.e.  1700, 1800, 1900, 2100 etc.  are not'
SAY '          leap-years whereas 1600, 2000, 2400 etc. ARE leap-years).'
SAY
SAY 'This new calendar is called Gregorian Calendar.'
SAY
SAY 'As it was a Roman Catholic pope who devised this change it took quite a long'
SAY 'time for others to adapt it. E.g. the German Protestants adapted it in 1700,'
SAY 'the Great Britains in 1752, Russia after World War I (including some Balkan'
SAY 'states).'
SAY
SAY 'Still the Gregorian Calendar will be off by one day every 3333 years.'
SAY

CALL SHOW_IT

SAY 'The most correct ancient sun-year calendar known today is a Middle American'
SAY 'one, stemming from the ancient Olmeks which will be correct for appr. 6000'
SAY 'years.'
SAY
SAY '--- end of an otherwise endless story ...'
SAY

CALL SHOW_IT

RETURN
/*****************************************************************************/






/*********************/
/* DATE2STR-examples */
/*********************/


DATE2STR_EXAMPLES:

CALL  SHOW_IT 'Standard delimiter (%):',,
              'DATE2STR("19940301","USA: %mm/%dd/%yyyy = %dddd (month = %mmmm)")',,
              '(USA-style)'
CALL  SHOW_IT 'Standard delimiter (%):',,
              'DATE2STR("19940106","%d. %m. %yyyy = %j. day in %yyyy and %w. week!")'
CALL  SHOW_IT 'Standard delimiter (%):',,
              'DATE2STR("19930101","%mm/%dd/%yy = %ddd %w. week!")',,
              '(53. week IS CORRECT for this year !!)'
CALL SHOW_IT

CALL  SHOW_IT 'Delimiter: "#"',,
              'DATE2STR("29940521","USA: #m/#dd/#yyyy = #DDD (month = #MMMM)","#")',,
              '(Delimiter: #, USA-style)'
CALL  SHOW_IT 'Delimiter: "\"',,
              'DATE2STR("19960301","Austria: \d. \m. \yy = \jjj. day in \yyyy","\")',,
              '(Delimiter: \, leap year!)'
CALL SHOW_IT

RETURN
/*****************************************************************************/



/********************/
/* TIMEIT-examples  */
/********************/


TIMEIT_EXAMPLES:

CALL  SHOW_IT2 'Time the duration of SLEEP.EXE (3 seconds to sleep):',,
               'TIMEIT SLEEP 3000 ?'
CALL SHOW_IT

CALL  SHOW_IT2 'Time the duration of the listing of *.SYS-files on drive C: and the waiting time until you press a key to continue:',,
               'TIMEIT DIR C:\*.sys & PAUSE'
CALL SHOW_IT

CALL  SHOW_IT2 'Time the duration of the REXX-script ATRGF.CMD:',,
               'TIMEIT ATRGF /W /I:00:01 @echo I''ll be back in a minute...'
CALL SHOW_IT

RETURN
/*****************************************************************************/

/********************/
/* ATRGF-examples  */
/********************/

ATRGF_AS_FAST_AS_POSSIBLE:

CALL  SHOW_IT3 'Execute the DIR-command at coming midnight in its own window:',,
               'ATRGF /W 00:00 DIR C:\*.*'

CALL SHOW_IT

CALL  SHOW_IT3 'Execute the DIR-command at 11:45pm, as early as possible:',,
               'ATRGF /W 11:45pm DIR C:\*.*'
CALL SHOW_IT

RETURN
/*****************************************************************************/

ATRGF_NEXT:

CALL  SHOW_IT3 'Start the backup-procedure next sunday at 14:30:',,
               'ATRGF /W 14:30 /NE:SU back_it_up',,
               '(BACK_IT_UP would be executed if it existed)'

CALL SHOW_IT

CALL  SHOW_IT3 'Start the backup-procedure on the last day of every month (31) at 14:30:',,
               'ATRGF /W 14:30 /NE:31 back_it_up',,
               '(BACK_IT_UP would be executed if it existed)'

CALL SHOW_IT

RETURN
/*****************************************************************************/


ATRGF_EVERY:

CALL  SHOW_IT3 'Start the backup-procedure Monday thru Friday at 14:30:',,
               'ATRGF /W 14:30 /E:MO-FR back_it_up',,
               '(BACK_IT_UP would be executed if it existed)'

CALL SHOW_IT

CALL  SHOW_IT3 'Start the backup-procedure on every 1st, 2nd, 3rd, 15th and last day in month (31), additionally on every friday at 14:30:',,
               'ATRGF /W 14:30 /E:15,31-1,FR-SA back_it_up',,
               '(BACK_IT_UP would be executed if it existed)'

CALL SHOW_IT

CALL  SHOW_IT3 'Test ATRGF with above example and show invocation dates:',,
               'ATRGF /W /T 14:30 /E:15,31-1,FR-SA back_it_up',,
               '(BACK_IT_UP would be executed if it existed)'

CALL SHOW_IT

RETURN
/*****************************************************************************/


ATRGF_INTERVAL:

CALL  SHOW_IT3 'Echo the message every minute:',,
               "ATRGF /W /I:00:01 @ECHO HI! I'll be back in a minute... "

CALL SHOW_IT

CALL  SHOW_IT3 'Test-mode: interval every 4 hours and 45 minutes:',,
               "ATRGF /W /T /I:04:45 @echo I'll be back in a minute..."

CALL SHOW_IT

CALL  SHOW_IT3 'Start the backup-procedure, starting at midnight, every 6 hours:',,
               'ATRGF /W 00:00 /I:06:00 back_it_up',,
               '(BACK_IT_UP would be executed every 6 hours, starting at midnight, if it existed)'

CALL SHOW_IT

CALL  SHOW_IT3 'Test-mode: interval starting at midnight, every 6 hours:',,
               'ATRGF /W /T 00:00 /I:06:00 back_it_up',,
               '(Test-mode: BACK_IT_UP would be executed every 6 hours, starting at midnight, if it existed)'

CALL SHOW_IT

RETURN
/*****************************************************************************/



/*****************************************************************************/
/* show example, execute it, show result */
SHOW_IT:
    IF ARG() = 0 THEN   /* no arguments ? */
    DO
       SAY RIGHT("Hit a key to continue, q to quit immediately.", 79, "=")
       tmp = TRANSLATE(SysGetKey("noecho"))

       IF tmp = "Q" THEN EXIT    /* q for quit was pressed */

       BEEP(100,3)
       PARSE PULL tmp
       RETURN
    END

    SAY
    SAY ARG(1)                                  /* header info */
    IF ARG(2) <> '' THEN DO
       SAY
       SAY '      'ARG(2)                       /* show example */
       INTERPRET 'A = 'ARG(2)                   /* execute example */
       SAY
       SAY '      result: "'A'" 'ARG(3)         /* show result */
    END
    SAY
    RETURN

SHOW_IT2:       /* execute programs and REXX-procedures which do not return values */
    SAY
    SAY ARG(1)                                  /* header info */
    IF ARG(2) <> '' THEN DO
       SAY
       SAY '      'ARG(2)                       /* show example */
       '@CALL 'ARG(2)                           /* execute example */
       SAY
       IF ARG() > 2 THEN
       DO
          SAY '      'ARG(3)                    /* show comment */
          SAY
       END
    END
    SAY
    RETURN


SHOW_IT3:       /* execute programs and REXX-procedures which do not return values */
    SAY
    SAY ARG(1)                                  /* header info */
    IF ARG(2) <> '' THEN DO
       SAY
       SAY '      'ARG(2)                       /* show example */
       '@CALL ' ARG(2)                          /* execute example */
       SAY
       IF ARG() > 2 THEN
       DO
          SAY '      'ARG(3)                    /* show comment */
          SAY
       END
    END
    SAY
    RETURN

