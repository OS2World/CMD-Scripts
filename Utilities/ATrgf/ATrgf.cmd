/*
program: atrgf.cmd
type:    REXXSAA-OS/2, version 2.x
purpose: execute command at specified time
version: 3.01
date:    1991-05-24
changed: 1991-07-26, RGF, streamlined the code a little bit..., added colors
         1992-06-01, RGF, adapted for 32bit OS/2
         1993-08-02, RGF, bug fixed on /E-switch: would not take starting day
                          into account (reported by Steve Hoiness,
                                        <76077.3121@compuserve.com>)
         1993-09-20, RGF, changed the definition of ANSI-color-sequences; gets them from
                          procedure ScrColor.CMD
         1993-11-08, RGF use ANSI-color-sequences in all places;
                         added black and white option (/B) to suppress ANSI-colors on output;
                         added option (/M) to execute a program, if it was supposed to be
                               executed between midnight and the time atrgf was invoked,
                               suggested by sktoni@uta.fi (Tommi Nieminen);
                         bug fixed on daynames, used date-number if daynames were given
                               individually
         1996-04-19, RGF, bug fixed w.r.t. switch "/M"


author:  Rony G. Flatscher,
         Wirtschaftsuniversit„t/Vienna
         RONY@AWIWUW11.BITNET
         Rony.Flatscher@wu-wien.ac.at

needs:   all RxUtil-functions loaded, DATERGF.CMD, DATE2STR.CMD, SCRCOLOR.CMD

usage:   ATRGF [/B] [/M] [/W] [/T] time command
         ATRGF [/B] [/M] [/W] [/T] time /NE:dayordate command
         ATRGF [/B] [/M] [/W] [/T] time /E:dayordate command
         ATRGF [/B] [/M] [/W] [/T] [time] /I:time command

         see enclosed Tutorial "RGFSHOW.CMD" and syntax below


All rights reserved, copyrighted 1991-1993, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything (money
etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it and that the accompanying tutorial "RGFSHOW.CMD" is being distributed
together with ATRGF.CMD, DATERGF.CMD, DATE2STR.CMD, SCRCOLOR.CMD, TIMEIT.CMD

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

procedures:
    CHECK_TIME          check and parse time into hh:mm
    SHOW_DURATION       show duration of command
    DURATION            format elapsed seconds into time
    NEXT_DATE           produce next date
    NEXT_DAY            produce next week-day
    SCHEDULE_IT         schedule command
    SHOW_SLEEP_EXECUTE  show next invocation, sleep until it and execute command


usage:   ATRGF [/W] [/T] [/B] [/M] time command
         ATRGF [/W] [/T] [/B] [/M] time /NE:dayordate command
         ATRGF [/W] [/T] [/B] [/M] time /E:dayordate command
         ATRGF [/W] [/T] [/B] [/M] [time] /I:time command

syntax:
    COMMAND ..... any command as entered thru the keyboard to start
                  a program
    TIME ........ on input 24hour- (military) or 12hour-format allowed,
                  output will be allways in 24hour-format (military, computer)
    DAYORDATE ... DAY[-DAY]|DATE[-DATE][,...]
                  DAY .... 2 letter digit (MO, TU, WE, TH, FR, SA, SU)
                  DATE ... 1-2 digits (1-31)
                  more than one day or date must be delimited by a comma

flags:
    /W  ......... execute ATRGF.CMD in a separate Window
    /T  ......... Testmode
    /B  ......... show output in black and white (don't attach ANSI-color-codes
                  to strings)
    /M  ......... execute command, if it can be scheduled between midnight and
                  time of first invocation of ATRGF

    /NE: ........ NExt dayordate
    /E:  ........ Every dayordate
    /I:  ........ every time-Interval

*/

SIGNAL ON HALT
SIGNAL ON ERROR
SIGNAL ON FAILURE    NAME ERROR
SIGNAL ON NOTREADY   NAME ERROR
SIGNAL ON NOVALUE    NAME ERROR
SIGNAL ON SYNTAX     NAME ERROR


/* check whether RxFuncs are loaded, if not, load them */
IF RxFuncQuery('SysLoadFuncs') THEN
DO
    /* load the load-function */
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'

    /* load the Sys* utilities */
    CALL SysLoadFuncs
END

glob. = ''                      /* default for empty subscripts */

/* analyse switches */
arg_1 = ARG(1)

switches = " "
/* four optional switches to checked for */
DO 4
   tmp = arg_1
   PARSE VAR arg_1 left "/"switch arg_1
   switch_char = LEFT(TRANSLATE(switch), 1)

   IF left <> "" | switch_char = "I" THEN
   DO
      arg_1 = tmp
      LEAVE
   END
   switches = switches || switch_char
END

/* check whether switches are valid */
IF VERIFY(switches, "BMWT ") <> 0 THEN
   CALL stop_it "unknown switch in [" || ARG(1) || "]."

switch_text = ""

IF POS("B", switches) > 0 THEN          /* only black and white output, no colors */
   switch_text = switch_text "/B"
ELSE
DO
   /* get screen-colors */
   PARSE VALUE ScrColor() WITH glob.eScrNorm    glob.eScrInv,
                               glob.eTxtNorm    glob.eTxtInf,
                               glob.eTxtHi      glob.eTxtAla,
                               glob.eTxtNormInv glob.eTxtInfInv,
                               glob.eTxtHiInv   glob.eTxtAlaInv .
END


/* sleep & execute command in a separate window ? */
bExecuteInSeparateWindow = (POS("W", switches) > 0)


/* execute command once if it could be scheduled in between midnight and time of
   starting ATRGF ? */
glob.bExecuteIfBetweenMidnightAndNow = (POS("M", switches) > 0)
IF glob.bExecuteIfBetweenMidnightAndNow THEN
   switch_text = switch_text "/M"


/* switch to testmode ? */
glob.bTestmode = (POS("T", switches) > 0)
IF glob.bTestmode THEN
   switch_text = switch_text "/T"

IF arg_1 = '' | arg_1 = '?' THEN SIGNAL usage

/* defaults */
glob.executions = 0                            /* number of executions so far */
glob.format_date = "%yyyy-%mm-%dd"             /* format string for dates */
glob.daynames = "MO TU WE TH FR SA SU"         /* valid daynames */

glob.argument = STRIP(arg_1)                   /* get rid of leading & trailing blanks */
glob.argument.upp = TRANSLATE(glob.argument)  /* get arguments in uppercase    */

CALL say_c

IF bExecuteInSeparateWindow THEN
DO                       /* TITLE:     */
   '@START /C /WIN /MIN  "ATRGF 'ARG(1)'" /PGM atrgf' switch_text arg_1  /* start a new window */
   EXIT        /* end the program */
END


CALL proceed
EXIT
/*  end of main-routine */



/******************************************/
/* parse time, additional switch, command */
PROCEED: PROCEDURE EXPOSE glob.

    word1 = WORD(glob.argument.upp, 1)

    PARSE VAR word1 hours ':' minutes
    time_in_hand = (DATATYPE(hours,'N'))    /* First argument a time-argument? */

    IF time_in_hand THEN
       glob.eTim =  check_time(word1)            /* check time & get 24hourformat */
    ELSE
    DO /* no time given, therefore interval, starting immediately */
       IF POS("/I:", word1) = 0 THEN
          CALL stop_it  "wrong syntax; '/I:' expected."
    END

    /* prepare initialization data */
    /* get current date and time */
    PARSE VALUE DATE("S") TIME("L") WITH glob.eStart.eDat glob.eStart.eTim

    IF glob.bExecuteIfBetweenMidnightAndNow THEN
    DO
       glob.eStartOriginal.eDat = glob.eStart.eDat
       glob.eStartOriginal.eTim = glob.eStart.eTim

       tmp = DATERGF(DATE("S"), "-", DATERGF("1", "SECR"))

       PARSE VAR tmp glob.eLast.eDat glob.eLast.eTim
       glob.eStart.eDat = glob.eLast.eDat
       glob.eStart.eTim = glob.eLast.eTim
    END
    ELSE
    DO
       glob.eLast.eDat = glob.eStart.eDat
       glob.eLast.eTim = glob.eStart.eTim
    END


    word2 = WORD(glob.argument.upp,2)     /* get parameter, if any */

    SELECT
       WHEN (POS("/I:", word2) > 0) | \time_in_hand THEN    /* Interval ? */
            DO
               glob.type = 1
               PARSE VAR glob.argument.upp . "/I:" glob.interval .
               PARSE VAR glob.argument . "/" . glob.command
               glob.interval = check_time(glob.interval)

               /* decimal fraction of interval */
               glob.interval.fract = DATERGF(glob.interval, "F")

               IF glob.eTim = '' THEN         /* no start time given = start immediately */
               DO
                   tmp = DATERGF(glob.eStart.eDat glob.eStart.eTim, "+", glob.interval.fract)
                   glob.eNext.eDat = WORD(tmp, 1)

                   IF WORDS(tmp) > 1 THEN glob.eNext.eTim = SUBSTR(WORD(tmp, 2),1,5)
                   ELSE glob.eNext.eTim = "00:00"
               END
               ELSE      /* starting time is given */
               DO
                   IF glob.eStart.eTim > glob.eTim THEN /* start tomorrow, as it is already later than specified time */
                   DO
                      glob.eNext.eDat = DATERGF(glob.eStart.eDat, "+", 1)
                      glob.eNext.eTim = glob.eTim
                   END
                   ELSE     /* start today at specified time */
                   DO
                      glob.eNext.eDat = glob.eStart.eDat
                      glob.eNext.eTim = glob.eTim
                   END
               END

               CALL schedule_it
            END

       WHEN (POS("/NE:", word2) > 0) THEN   /* start on next date_or_day ? */
            DO
               glob.type = 2
               PARSE VAR glob.argument.upp . "/NE:" dayordate .
               PARSE VAR glob.argument . "/" . glob.command

               IF DATATYPE(dayordate, 'N') THEN     /* numeric */
                  IF dayordate < 1 | dayordate > 31 THEN
                      CALL stop_it  dayordate": invalid day-number for date"
                  ELSE
                  DO
                       glob.eNext_date = dayordate % 1    /* get rid of leading 0 */
                       glob.eNext_date_string = glob.eNext_date /* string to show */
                       glob.eNext_date_no = 1             /* no. of dates */
                       glob.eNext.eDat = next_date(glob.eNext_date_no, glob.eLast.eDat)
                  END
               ELSE         /* weekday given */
               DO
                   dayindex = WORDPOS(dayordate, glob.daynames)
                   IF dayindex = 0 THEN
                      CALL stop_it  dayordate": invalid dayname"

                   glob.eNext_day = dayindex
                   glob.eNext_day_string = dayordate     /* string to show */
                   glob.eNext_day_no = 1                 /* no. of days */
                   glob.eNext.eDat = next_day(glob.eNext_day_no, glob.eLast.eDat)
               END

               glob.eNext.eTim = glob.eTim

               CALL schedule_it
               CALL show_duration
            END

       WHEN (POS("/E:", word2) > 0) THEN    /* start on every date_or_day ? */
            DO
               glob.type = 3
               PARSE VAR glob.argument.upp . "/E:" dayordate .
               PARSE VAR glob.argument . "/" . glob.command

               /* Parse days or dates to execute command */
               DO WHILE dayordate <> ''
                  PARSE VAR dayordate tmp1 ',' dayordate
                  PARSE VAR tmp1 day_start '-' day_end

                  /* day or date ? */
                  IF DATATYPE(day_start, 'N') THEN     /* numeric */
                  DO
                     IF day_start < 1 | day_start > 31 THEN
                         CALL stop_it  day_start": invalid date"

                     data_type = 1          /* date */
                  END
                  ELSE      /* weekday in hand */
                  DO
                     IF WORDPOS(day_start, glob.daynames) = 0 THEN
                        CALL stop_it  day_start": invalid dayname"

                     data_type = 2          /* day */
                  END

                  IF day_end = '' THEN      /* no interval */
                  DO
                     IF data_type = 1 THEN  /* date in hand */
                     DO
                        tmp = day_start % 1         /* get rid of possible leading 0 */
                        glob.tmp = 'x'             /* next invocation */
                     END
                     ELSE                   /* dayname in hand */
                     DO
                        tmp = day_start             /* keep day-name, bugfix */
                        glob.tmp = 'x'             /* next invocation on dayname */
                     END
                  END
                  ELSE           /* interval in hand */
                  DO
                     IF data_type = 1 THEN       /* first token was a date: 1-31 */
                     DO
                        IF \DATATYPE(day_end, 'N') | day_end < 1 | day_end > 31 THEN
                               CALL stop_it  day_start'-'day_end": invalid date"

                        IF day_end < day_start THEN         /* wrap around end of month ? */
                        DO

                           day_start = day_start % 1            /* get rid of leading 0 */
                           DO WHILE day_start < 32
                              glob.day_start = 'x'           /* next invocation */
                              day_start = day_start + 1
                           END
                           day_start = 1
                        END

                        day_start = day_start % 1      /* get rid of leading 0 */
                        DO WHILE day_start <= day_end
                           glob.day_start = 'x'       /* next invocation */
                           day_start = day_start + 1
                        END
                     END
                     ELSE                /* first token was a day: MO-SU */
                     DO
                        dayindex_end = WORDPOS(day_end, glob.daynames)
                        IF dayindex_end = 0 THEN
                           CALL stop_it  day_start'-'day_end": invalid dayname"

                        dayindex_start = WORDPOS(day_start, glob.daynames)

                        IF dayindex_end < dayindex_start THEN    /* wrap around end of week ? */
                        DO
                           DO WHILE dayindex_start < 8
                              tmp = WORD(glob.daynames, dayindex_start)
                              glob.tmp = 'x'    /* next invocation */
                              dayindex_start = dayindex_start + 1
                           END
                           dayindex_start = 1
                        END

                        DO WHILE dayindex_start <= dayindex_end
                           tmp = WORD(glob.daynames, dayindex_start)
                           glob.tmp = 'x'       /* next invocation */
                           dayindex_start = dayindex_start + 1
                        END
                     END
                  END
               END

               /* prepare ordered demo-values and invocation string */
               /* prepare ordered invocation days */
               glob.eNext_day_no = 0
               DO i = 1 TO 7
                  tmp = WORD(glob.daynames, i)
                  IF glob.tmp <> '' THEN
                  DO
                     IF glob.eNext_day <> '' THEN
                     DO
                        glob.eNext_day = glob.eNext_day i
                        glob.eNext_day_string = glob.eNext_day_string', 'tmp
                     END
                     ELSE   /* first day-element */
                     DO
                        glob.eNext_day = i
                        glob.eNext_day_string = tmp      /* string to show */
                     END
                     glob.eNext_day_no = glob.eNext_day_no + 1
                  END
               END
               IF glob.eNext_day_no = 0 THEN glob.eNext_day_no = ''

               /* prepare ordered invocation dates */
               glob.eNext_date_no = 0
               DO i = 1 TO 31
                  IF glob.i <> '' THEN
                  DO
                     IF glob.eNext_date <> '' THEN
                     DO
                        glob.eNext_date = glob.eNext_date i
                        IF (value_inhand + 1) = i THEN
                            value_inhand = i
                        ELSE
                        DO
                           IF value_last_used <> value_inhand THEN
                           DO
                              glob.eNext_date_string = glob.eNext_date_string||'-'||value_inhand||', '||i
                              value_inhand = i
                              value_last_used = i
                           END
                           ELSE
                           DO
                              glob.eNext_date_string = glob.eNext_date_string||', '||i
                              value_inhand = i
                              value_last_used = i
                           END
                        END
                     END
                     ELSE   /* first date-element */
                     DO
                        glob.eNext_date = i
                        glob.eNext_date_string = i       /* string to show */
                        value_inhand = i
                        value_last_used = i
                     END
                     glob.eNext_date_no = glob.eNext_date_no + 1
                  END
               END

               IF glob.eNext_date_no = 0 THEN glob.eNext_date_no = ''
               ELSE
                  IF value_last_used <> value_inhand THEN     /* interval left ? */
                  DO
                     glob.eNext_date_string = glob.eNext_date_string||'-'||value_inhand
                     value_inhand = 0
                  END

               CALL schedule_it
            END

       OTHERWISE                            /* start once on given time ? */
            DO
               glob.type = 4
               PARSE VAR glob.argument . glob.command

               CALL schedule_it
               CALL show_duration
            END
    END

    RETURN
/* end of PROCEED routine ********************************************************/



/* parse & check time, return 24hour clock */
CHECK_TIME: PROCEDURE EXPOSE glob.
    PARSE UPPER ARG tmp
    time24 = 1                  /* starting with 24 hour time in mind */
    time12 = POS('M', tmp)      /* AM or PM ? */
    IF time12 > 0 THEN
    DO
      time24 = 0                /* 12 hour time in hand */
      letter = SUBSTR(tmp, time12 - 1, 1)
      IF \((letter = 'A') | letter = 'P') THEN
         CALL stop_it  ARG(1)': not a valid AM/PM-time'

      tmp = SUBSTR(tmp, 1, time12 - 2)  /* remove ?M */
    END

    PARSE VAR tmp hours ':' minutes ':' seconds

    SELECT
      WHEN hours = '' THEN hours = 0

      WHEN \datatype(hours,'N') THEN     /* no numeric type */
              CALL stop_it  ARG(1)": hours are not numeric"

      WHEN (hours < 0) | (hours > 23) THEN      /* out of range    */
              CALL stop_it  ARG(1)": hours out of range"

      OTHERWISE NOP
    END

    SELECT
      WHEN minutes = '' THEN minutes = 0

      WHEN \datatype(minutes,'N') THEN     /* no numeric type */
              CALL stop_it  ARG(1)": minutes are not numeric"

      WHEN (minutes < 0) | (minutes > 59) THEN /* out of range    */
              CALL stop_it  ARG(1)": minutes out of range"

      OTHERWISE NOP
    END

    /* ignore seconds, if any */

    IF \time24 THEN             /* received a 12hour time, adjust it to 24hour time */
    DO
       IF (letter = 'A') & (hours = 12) THEN hours = 0
       ELSE IF ((letter = 'P') & (hours < 12)) THEN hours = hours + 12
    END

    RETURN RIGHT(hours,2,'0')':'RIGHT(minutes,2,'0')
/* end of CHECK_TIME **********************************************************/



/* produce next date for /NE: or /E: flags */
NEXT_DATE:
    date_index = ARG(1)         /* index for date-string */
    last_dat = ARG(2)           /* last date to look-up */
    date_index = date_index + 1

    IF date_index > glob.eNext_date_no THEN
       date_index = 1

    next_dat_to_produce = WORD(glob.eNext_date, date_index)

    digits = SUBSTR(last_dat, 7, 2)
    eom = SUBSTR(DATERGF(last_dat, "ME"), 7, 2)

    /* already last date of month in hand ? If so, next month must be chosen */
    IF digits = eom THEN digits = 99    /* already last date of month in hand ?*/

    /* next date within same month ? */
    IF digits < next_dat_to_produce THEN
    DO
        /* already last date in month ? */
        IF next_dat_to_produce < eom THEN       /* o.k. for producing new date */
           result = SUBSTR(last_dat, 1, 6) || RIGHT(next_dat_to_produce,2,'0')
        ELSE                                    /* date is last day of month */
           result = SUBSTR(last_dat, 1, 6) || eom
    END
    ELSE      /* date of following month */
    DO
       tmp = DATERGF(last_dat, "ME", "1")       /* first date of next month */
       last_day = DATERGF(tmp, "ME")            /* end of next month */

       IF next_dat_to_produce < SUBSTR(last_day, 7, 2) THEN
            result = SUBSTR(tmp, 1, 6) || RIGHT(next_dat_to_produce,2,'0')
       ELSE result = last_day
    END

    RETURN result               /* return next date and actual date_index */
/* end of NEXT_DATE ***********************************************************/



/* produce next day for /NE: or /E: flags */
NEXT_DAY:
    day_index = ARG(1)          /* index for date-string */
    last_dat = ARG(2)
    day_index = day_index + 1

    IF day_index > glob.eNext_day_no THEN
       day_index = 1

    next_day_to_produce = WORD(glob.eNext_day, day_index)

    IF DATERGF(last_dat, "DI") < next_day_to_produce THEN
       result = DATERGF(last_dat, "WB", next_day_to_produce-1)
    ELSE
       result = DATERGF(last_dat, "WE", next_day_to_produce)

    RETURN result               /* return next date and actual day_index */
/* end of NEXT_DAY ************************************************************/




/* show-duration, if execution just took place once */
SHOW_DURATION: PROCEDURE EXPOSE glob.
    CALL say_c
    IF glob.bTestmode = 0 THEN
    DO
       CALL say_c " execution started:" glob.eTxtHi || RIGHT(DATERGF(glob.eLast.eDat, "DN")||',',12),
            DATE2STR(glob.eLast.eDat, glob.format_date) SUBSTR(glob.eLast.eTim,1,5)

       tmp = "   execution ended:" || glob.eTxtHi
       IF glob.eLast.eDat <> glob.eEnded.eDat THEN
          tmp = tmp RIGHT(DATERGF(glob.eEnded.eDat, "DN")||',',12) DATE2STR(glob.eEnded.eDat, glob.format_date)
       ELSE
          tmp = tmp RIGHT('',12) RIGHT('', LENGTH(DATE2STR(glob.eEnded.eDat, glob.format_date)))

       CALL say_c tmp  SUBSTR(glob.eEnded.eTim,1,5) glob.eTxtInf || "(duration:" glob.eTxtHi ||,
            glob.eEnded.eDuration || glob.eTxtInf || ")"
    END
    ELSE
    DO
       x = glob.eTxtHi || RIGHT('',12) 'ATRGF: *** Test mode ***'
       tmp = " execution started:"
       CALL say_c tmp x
       tmp = "   execution ended:"
       CALL say_c tmp x
    END
    RETURN
/* end of SHOW_DURATION ******************************************************/




/* format elapsed seconds into time DURATION */
CALC_DURATION: PROCEDURE EXPOSE glob.

    fraction = DATERGF(ARG(1), "SECR")

    IF fraction >= 1 THEN tmp = fraction % 1 glob.eTxtInf || "day(s)" glob.eTxtHi || DATERGF(DATERGF(ARG(1), "SECR"), "FR")
    ELSE tmp = DATERGF(DATERGF(ARG(1), "SECR"), "FR")

    RETURN tmp
/* end of duration ************************************************************/




/* calculate waiting time, before executing command */
SCHEDULE_IT: PROCEDURE EXPOSE glob.

    SELECT
       WHEN glob.type = 1 THEN      /* interval */
            DO FOREVER
               IF glob.bTestmode = 0 THEN
                  glob.eTo_wait_sec = DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", DATE("S") TIME("L"))
               ELSE
                  glob.eTo_wait_sec = DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", glob.eLast.eDat glob.eLast.eTim)

               nul = TIME("R")                          /* reset timer */

               /* increment next execution until seconds to wait become positive */
               DO WHILE glob.eTo_wait_sec < 0 & glob.bTestmode = 0
                  tmp = DATERGF(glob.eNext.eDat glob.eNext.eTim, "+", glob.interval.fract)
                  glob.eNext.eDat = WORD(tmp, 1)       /* get next date */

                  IF WORDS(tmp) > 1 THEN glob.eNext.eTim = SUBSTR(WORD(tmp, 2),1,5) /* get next time */
                  ELSE glob.eNext.eTim = "00:00"

                  glob.eTo_wait_sec = DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", DATE("S") TIME("L"))

                  IF glob.bExecuteIfBetweenMidnightAndNow THEN
                     if glob.eTo_wait_sec < 0 then
                        glob.eTo_wait_sec = 0

                  nul = TIME("R")                       /* reset timer */
               END

               glob.eTo_wait_sec = DATERGF(glob.eTo_wait_sec,"SEC")

               CALL show_sleep_execute

               tmp = DATERGF(glob.eLast.eDat glob.eLast.eTim, "+", glob.interval.fract)
               glob.eNext.eDat = WORD(tmp, 1)          /* get date */

               IF WORDS(tmp) > 1 THEN glob.eNext.eTim = SUBSTR(WORD(tmp, 2),1,5)  /* get next time */
               ELSE glob.eNext.eTim = "00:00"
            END

       WHEN glob.type = 2 THEN      /* Next day or date */
            DO
               IF glob.bTestmode = 0 THEN
                  glob.eTo_wait_sec = DATERGF(DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", DATE("S") TIME("L")), "SEC")
               ELSE
                  glob.eTo_wait_sec = DATERGF(DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", glob.eLast.eDat glob.eLast.eTim), "SEC")

               nul = TIME("R")
               CALL show_sleep_execute
            END

       WHEN glob.type = 3 THEN      /* every given day or date */
            DO
               dates_todo = glob.eNext_date_no > 0
               days_todo = glob.eNext_day_no > 0

               glob.eNext.eTim = glob.eTim            /* standard execution time */

               x1 = glob.eLast.eDat

               IF \glob.bExecuteIfBetweenMidnightAndNow THEN
                  x1 = datergf(x1, "-", 1)              /* make sure, that invocation is possible on same day too */

               DO FOREVER
                  IF dates_todo THEN    /* find first date after present one */
                  DO
                     di = DATERGF(x1, "D")              /* get day-portion of date */

                     /* if already last day of month, set index to last element */
                     IF SUBSTR(DATERGF(x1, "ME"), 7,2) = di THEN
                        tmp = glob.eNext_date_no
                     ELSE
                     DO                                 /* search for next date to produce */
                        tmp = 1

                        DO FOREVER
                           tmp0 = WORD(glob.eNext_date, tmp)
                           IF tmp0 = '' | tmp0 > di THEN LEAVE
                           tmp = tmp + 1
                        END
                        tmp = tmp - 1
                     END

                     tmp1_date = next_date(tmp, x1)
                  END
                  ELSE tmp1_date = "99991231"

                  IF days_todo THEN                     /* find first date after present one */
                  DO
                     di = DATERGF(x1, "DI")
                     tmp = 1

                     DO FOREVER
                        tmp0 = WORD(glob.eNext_day, tmp)
                        IF tmp0 = '' | tmp0 > di THEN LEAVE
                        tmp = tmp + 1
                     END
                     tmp = tmp - 1

                     tmp2_date = next_day(tmp, x1)
                  END
                  ELSE tmp2_date = "99991231"

                  IF tmp1_date <= tmp2_date THEN        /* next to schedule: date */
                      glob.eNext.eDat = tmp1_date
                  ELSE                                  /* next to schedule: day */
                      glob.eNext.eDat = tmp2_date


                  IF glob.bTestmode = 0 THEN           /* do it for real ? */
                     glob.eTo_wait_sec = DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", DATE("S") TIME("L"))
                  ELSE                                  /* test ATRGF, show next invocation */
                     glob.eTo_wait_sec = DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", glob.eLast.eDat glob.eLast.eTim)

                  nul = TIME("R")                       /* reset timer */


                  IF glob.bExecuteIfBetweenMidnightAndNow THEN
                     IF glob.eTo_wait_sec < 0 THEN
                        glob.eTo_wait_sec = 0


                  IF glob.eTo_wait_sec < 0 THEN        /* execution lasted longer than next scheduled date! */
                     x1 = glob.eNext.eDat              /* get next date to execute */
                  ELSE
                  DO
                     glob.eTo_wait_sec = DATERGF(glob.eTo_wait_sec, "SEC")
                     CALL show_sleep_execute
                     x1 = glob.eLast.eDat
                  END
               END

            END

       OTHERWISE                     /* today or the next day */
            DO
               glob.eNext.eTim = glob.eTim

               IF glob.eNext.eTim <= glob.eLast.eTim THEN /* execution on next day */
                  glob.eNext.eDat = DATERGF(glob.eStart.eDat, "+", 1)
               ELSE
                  glob.eNext.eDat = glob.eStart.eDat      /* execution on same day */

               glob.eTo_wait_sec = DATERGF(DATERGF(glob.eNext.eDat glob.eNext.eTim, "-S", DATE("S") TIME("L")), "SEC")

               nul = TIME("R")

               CALL show_sleep_execute
            END
    END
    RETURN
/* end of SCHEDULE_IT *********************************************************/




/* show time-table, sleep & execute passed command */
SHOW_SLEEP_EXECUTE: PROCEDURE EXPOSE glob.
    CALL say_c

    IF glob.bExecuteIfBetweenMidnightAndNow THEN
    DO
       CALL say_c "           started:" glob.eTxtHi || RIGHT(DATERGF(glob.eStartOriginal.eDat, "DN")||',',12),
                              DATE2STR(glob.eStartOriginal.eDat, glob.format_date) glob.eStartOriginal.eTim
       CALL say_c glob.eTxtAla || "           switch:  /M, therefore pretending:"
    END


    CALL say_c "           started:" glob.eTxtHi || RIGHT(DATERGF(glob.eStart.eDat, "DN")||',',12),
                           DATE2STR(glob.eStart.eDat, glob.format_date) glob.eStart.eTim

    IF glob.eStart.eDat <> glob.eLast.eDat | glob.eStart.eTim <> glob.eLast.eTim THEN
    DO
       CALL say_c
       CALL say_c "    last execution:" glob.eTxtHi || RIGHT(DATERGF(glob.eLast.eDat, "DN")||',',12),
                DATE2STR(glob.eLast.eDat, glob.format_date) SUBSTR(glob.eLast.eTim,1,5)

       IF glob.bTestmode = 0 THEN
       DO
          tmp = "   execution ended:"
          IF glob.eLast.eDat <> glob.eEnded.eDat THEN
             tmp2 = RIGHT(DATERGF(glob.eEnded.eDat, "DN")||',',12) DATE2STR(glob.eEnded.eDat, glob.format_date)
          ELSE
             tmp2 = RIGHT('',12) RIGHT('', LENGTH(DATE2STR(glob.eEnded.eDat, glob.format_date)))

          tmp = tmp glob.eTxtHi || tmp2
          CALL say_c tmp  SUBSTR(glob.eEnded.eTim,1,5) glob.eTxtInf || "(duration:",
                   glob.eTxtHi || glob.eEnded.eDuration || glob.eTxtInf || ")"
       END
       ELSE
       DO
          x = RIGHT('',12) '*** Test mode ***'
          tmp = " execution started:"
          CALL say_c tmp x
          tmp = "   execution ended:"
          CALL say_c tmp x
       END
    END

    CALL say_c
    CALL say_c "    next execution:" glob.eTxtHi || RIGHT(DATERGF(glob.eNext.eDat, "DN") || ',',12),
             DATE2STR(glob.eNext.eDat, glob.format_date) glob.eNext.eTim

    IF glob.bExecuteIfBetweenMidnightAndNow THEN
       IF (glob.eStartOriginal.eDat glob.eStartOriginal.eTim) > (glob.eNext.eDat glob.eNext.eTim) THEN
          glob.eTo_wait_sec = 0

    tmp = calc_duration(glob.eTo_wait_sec)

    CALL say_c "      time to wait:" RIGHT("",12) glob.eTxtHi || tmp
    CALL say_c

    tmp = glob.eTxtAla
    IF glob.type = 2 THEN           /* NEXT-date */
       tmp = tmp || RIGHT("on next",12)
    ELSE                             /* EVERY-date */
       tmp = tmp || RIGHT("on EVERY",12)

    IF glob.eNext_date_no > 0 THEN
       CALL say_c " execution date(s):" tmp glob.eTxtHi || glob.eNext_date_string

    IF glob.eNext_day_no > 0 THEN
       CALL say_c "  execution day(s):" tmp glob.eTxtHi || glob.eNext_day_string

    IF glob.interval <> '' THEN
       CALL say_c "execution interval:" glob.eTxtAla || RIGHT("EVERY",12) || glob.eTxtHi  glob.interval

    IF glob.executions > 0 THEN
       CALL say_c " executions so far:" glob.eTxtHi || glob.executions glob.eTxtInf || "time(s)"

    CALL say_c
    CALL say_c "command to execute: [" || glob.eTxtHi || glob.command || glob.eTxtInf || "]"
    CALL say_c

    IF glob.bTestmode > 0 THEN      /* testing mode */
    DO
       IF glob.type = 1 | glob.type = 3 THEN
       DO
          CALL say_c '             ATRGF: *** Test mode ***'
          CALL say_c '                    Hit return to get next invocation date'
          CALL say_c '                    OR '
          CALL say_c '                    Enter EXIT to end testing mode'
          PULL x
          /* looping mode? If so, exit from here */
          IF x = 'EXIT' & (glob.type = 1 | glob.type = 3) THEN EXIT
       END

       glob.eLast.eDat = glob.eNext.eDat
       glob.eLast.eTim = glob.eNext.eTim
    END
    ELSE
    DO
       x = glob.eTo_wait_sec - TIME("R")  /* deduct time needed to arrive at this position */
       if x < 0 THEN x = 0
       x = (x + 0.5) % 1                /* result must be an integer */
       CALL SysSleep x                  /* seconds to sleep */
       CALL say_c
       PARSE VALUE DATE("S") TIME("L") TIME("R") WITH glob.eLast.eDat glob.eLast.eTim .

       'CALL 'glob.command             /* execute command */
    END

    IF glob.bExecuteIfBetweenMidnightAndNow THEN
    DO
       glob.eStart.eDat = glob.eStartOriginal.eDat
       glob.eStart.eTim = glob.eStartOriginal.eTim

/* original
       glob.eLast.eDat  = glob.eStartOriginal.eDat
       glob.eLast.eTim  = glob.eStartOriginal.eTim
*/

       IF (glob.eStartOriginal.eDat glob.eStartOriginal.eTim) > (glob.eNext.eDat glob.eNext.eTim) THEN
       DO
          glob.eLast.eDat  = glob.eNext.eDat
          glob.eLast.eTim  = glob.eNext.eTim
       END
       ELSE
       DO
          glob.eLast.eDat  = glob.eStartOriginal.eDat
          glob.eLast.eTim  = glob.eStartOriginal.eTim
       END



       glob.bExecuteIfBetweenMidnightAndNow = 0
    END

    /* get actual date, time and elapsed time */
    PARSE VALUE DATE("S") TIME("L") TIME("R") WITH glob.eEnded.eDat glob.eEnded.eTim tmp

    glob.eEnded.eDuration = calc_duration(tmp)
    glob.executions = glob.executions + 1
    RETURN
/* end of SHOW_SLEEP_EXECUTE *************************************************/



USAGE:
   CALL say_c
   CALL say_c glob.eTxtHi || 'ATRGF:' || glob.eTxtInf || '   execute command at specified time'
   CALL say_c
   CALL say_c
   CALL say_c 'usage:' || glob.eTxtHi || '   ATRGF [/B] [/M] [/W] [/T] time command'
   CALL say_c glob.eTxtHi || '         ATRGF [/B] [/W] [/M] [/T] time /NE:dayordate command'
   CALL say_c glob.eTxtHi || '         ATRGF [/B] [/W] [/M] [/T] time /E:dayordate command'
   CALL say_c glob.eTxtHi || '         ATRGF [/B] [/W] [/M] [/T] [time] /I:time command'glob.eTxtInf
   CALL say_c
   CALL say_c '         see enclosed Tutorial "RGFSHOW.CMD" and syntax below'
   CALL say_c
   CALL say_c 'syntax:'
   CALL say_c glob.eTxtHi || '   COMMAND' || glob.eTxtInf || ' ..... any command as entered thru the keyboard to start'
   CALL say_c '                 a program'
   CALL say_c glob.eTxtHi || '   TIME' || glob.eTxtInf || ' ........ on input 24hour- (military) or 12hour-format allowed,'
   CALL say_c '                 output will be allways in 24hour-format (military, computer)'
   CALL say_c glob.eTxtHi || '   DAYORDATE' || glob.eTxtInf || ' ... ' || glob.eTxtHi || 'DAY[-DAY]|DATE[-DATE][,...]'
   CALL say_c glob.eTxtHi || '                 DAY' || glob.eTxtInf || ' .... 2 letter digit (' || glob.eTxtHi || 'MO' || glob.eTxtInf ||,
           ', ' || glob.eTxtHi || 'TU' || glob.eTxtInf || ',' glob.eTxtHi || 'WE' || glob.eTxtInf || ', ' ||,
           glob.eTxtHi || 'TH' || glob.eTxtInf || ', ' || glob.eTxtHi || 'FR' || glob.eTxtInf || ', ' || glob.eTxtHi ||,
           'SA' || glob.eTxtInf || ',' || glob.eTxtHi || 'SU' || glob.eTxtInf || ')'
   CALL say_c glob.eTxtHi || '                 DATE' || glob.eTxtInf || ' ... 1-2 digits (' || glob.eTxtHi || '1-31' || glob.eTxtInf || ')'
   CALL say_c '                 more than one day or date must be delimited by a comma'
   CALL say_c
   CALL say_c '   flags:'
   CALL say_c glob.eTxtHi || '   /B' || glob.eTxtInf || '  ......... show output in' glob.eTxtHi || 'b' || glob.eTxtInf || 'lack/white (no ANSI-colors)'
   CALL say_c glob.eTxtHi || '   /M' || glob.eTxtInf || '  ......... execute command immediately, if scheduling between' glob.eTxtHi ||,
                            'm' || glob.eTxtInf || 'idnight'
   CALL say_c '                 and the time of first invocation of ATRGF itself is possible'
   CALL say_c glob.eTxtHi || '   /W' || glob.eTxtInf || '  ......... execute ATRGF.CMD in a separate ' || glob.eTxtHi || 'W' || glob.eTxtInf || 'indow'
   CALL say_c glob.eTxtHi || '   /T' || glob.eTxtInf || '  ......... ' || glob.eTxtHi || 'T' || glob.eTxtInf || 'est mode'
   CALL say_c glob.eTxtHi || '   /NE:' || glob.eTxtInf || ' ........ ' || glob.eTxtHi || 'ne' || glob.eTxtInf || 'xt dayordate'
   CALL say_c glob.eTxtHi || '   /E:' || glob.eTxtInf || '  ........ ' || glob.eTxtHi || 'e' || glob.eTxtInf || 'very dayordate'
   CALL say_c glob.eTxtHi || '   /I:' || glob.eTxtInf || '  ........ every time-' || glob.eTxtHi || 'i' || glob.eTxtInf || 'nterval'
   CALL say_c
   CALL say_c 'examples:'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 00:00 copy *.* a:'glob.eTxtInf
   CALL say_c '          ... copy all files at midnight to drive A:'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 17:00 "beep & @echo Hey, time to go home! & PAUSE"'glob.eTxtInf
   CALL say_c '          ... at 5:00pm beep, show message and wait for keystroke'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 20:30 /NE:FR back_it_up'glob.eTxtInf
   CALL say_c '          ... call "BACK_IT_UP" at 8:30pm on ' || glob.eTxtHi || 'ne' || glob.eTxtInf || 'xt friday'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 20:30 /NE:31 back_it_up'glob.eTxtInf
   CALL say_c '          ... call "BACK_IT_UP" at 8:30pm on the ' || glob.eTxtHi || 'ne' || glob.eTxtInf || 'xt last day of month'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 20:30 /E:1-31 back_it_up'glob.eTxtInf
   CALL say_c '          ... call "BACK_IT_UP" at 8:30pm on ' || glob.eTxtHi || 'e' || glob.eTxtInf || 'very day'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 20:30 /E:FR,1,15,31 back_it_up'glob.eTxtInf
   CALL say_c '          ... call "BACK_IT_UP" at 8:30pm on ' || glob.eTxtHi || 'e' || glob.eTxtInf || 'very friday, on every'
   CALL say_c '              first, 15th and last day in a month'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 17:00 /E:MO-FR "beep & @echo Hey, time to go home! & PAUSE"'glob.eTxtInf
   CALL say_c '          ... at 5:00pm beep, show message and wait for keystroke mondays'
   CALL say_c '              thru fridays (executing command forever on given DAYORDATE)'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF 00:00 /I:00:05 MOVE_IT.CMD -v'glob.eTxtInf
   CALL say_c '          ... starting at midnight, execute every 5 minutes (' || glob.eTxtHi || 'i' || glob.eTxtInf || 'nterval)'
   CALL say_c '              "move_it.cmd" with the parameter "-v"'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF /I:00:05 MOVE_IT.CMD -v'glob.eTxtInf
   CALL say_c '          ... call every 5 minutes (' || glob.eTxtHi || 'i' || glob.eTxtInf || 'nterval) "move_it.cmd" with'
   CALL say_c '              the parameter "-v"'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF /W 20:30 /E:FR-MO,15,31-1 back_it_up'glob.eTxtInf
   CALL say_c '          ... call "BACK_IT_UP" at 8:30pm on ' || glob.eTxtHi || 'e' || glob.eTxtInf || 'very friday, saturday,'
   CALL say_c '              sunday, monday, on ' || glob.eTxtHi || 'e' || glob.eTxtInf || 'very, first, 15th and last day in a month,'
   CALL say_c '              execute in a separate ' || glob.eTxtHi || 'w' || glob.eTxtInf || 'indow'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF /T 20:30 /E:FR-MO,15,31-1 back_it_up'glob.eTxtInf
   CALL say_c '          ... ' || glob.eTxtHi || 't' || glob.eTxtInf || 'esting of command; show invocation dates'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF /W /T 20:30 /E:FR-MO,15,31-1 back_it_up'glob.eTxtInf
   CALL say_c '          ... ' || glob.eTxtHi || 't' || glob.eTxtInf || 'esting of command; show invocation dates; use a separate'
   CALL say_c '              ' || glob.eTxtHi || 'w' || glob.eTxtInf || 'indow for it'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF /B'glob.eTxtInf
   CALL say_c '          ... show usage of ATRGF in black and white (no colors on output)'
   CALL say_c
   CALL say_c glob.eTxtHi || '    ATRGF /M /W 8:00 /E:MO back_it_up'glob.eTxtInf
   CALL say_c '          ... call "BACK_IT_UP" at 8:00am on ' || glob.eTxtHi || 'e' || glob.eTxtInf || 'very monday, execute in a'
   CALL say_c '              separate ' || glob.eTxtHi || 'w' || glob.eTxtInf || 'indow; if ATRGF was started on ' || glob.eTxtHi || 'monday'  || glob.eTxtInf || ' at 9am'
   CALL say_c '              (in fact after 8am), the command will still (!) be executed,'
   CALL say_c '              because of the ' || glob.eTxtHi ||  '/M' || glob.eTxtInf ||  '-switch ' || glob.eTxtHi ||  '!!!'

   CALL say_c
   EXIT
/***************************************************/

SAY_C: PROCEDURE EXPOSE glob.
   SAY glob.eTxtInf || ARG(1) || glob.eScrNorm
   RETURN

HALT:
    CALL say_c
    CALL say_c glob.eTxtAla || "ATRGF: User interrupted program."
    EXIT

ERROR:
   myrc        = RC
   errorlineno = SIGL
   errortext   = ERRORTEXT(myrc)
   errortype   = CONDITION("C")
   CALL stop_it pp(myrc)":" pp( errortext ) "in line #" pp(errorlineno ) "REXX-SIGNAL:" pp( errortype )

/*
   User pressed ctl-c or closed session
*/
HALT:
   CALL STOP_IT "User interrupted program."

/*
   Clean up and close open files
*/
STOP_IT:
   IF ARG(1) <> "" THEN CALL say_c  glob.eTxtAla || "ATRGF:"  glob.eTxtAlaInv || ARG(1)
   EXIT -1


pp : return "[" || arg( 1 ) || "]"

