/*
program: datergf.cmd
type:    REXXSAA-OS/2
purpose: allow transformations and calculations on sorted dates
         (reverse Julian dates into sorted dates)
version: 1.5
date:    1991-05-20
changed: 1992-06-07, RGF, error-message is only displayed on STDERR, if DATERGF was not
                          invoked as a function
         1992-06-18, removed bundling to ATRGF.CMD etc., RGF
         1993-09-20, changed the definition of ANSI-color-sequences; gets them from
                     procedure ScrColor.CMD
         1994-03-03, error-messages are shown, even if called as a function in order
                     to ease debugging

author:  Rony G. Flatscher,
         Wirtschaftsuniversit„t/Vienna
         Rony.Flatscher@wu-wien.ac.at

usage:   DATERGF(argument)
         DATERGF(argument, flag)
         DATERGF(argument1, flag, argument2)
         see enclosed Tutorial "RGFSHOW.CMD" and syntax below

needs:   SCRCOLOR.CMD

remark:  This program reflects the change in 1582, where the calendar
         was corrected by subtracting 10 days (1582/10/05 - 1582/10/14 were
         skipped) by the Roman Catholic pope Gregor XIII:
         0000/01/01 ---> 1581/12/31 ... Julian Calendar (every 4 years leap year)
         1582/01/01 ---> 9999/12/31 ... Gregorian Calendar, with 10 days less in 1582,
                                        every 4 years leap year, EXCEPT whole centuries
                                        which are not dividable MOD 400 = 0



All rights reserved, copyrighted 1991, 1992, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything
(money etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

procedures:
      CHECK_DATE:  check correct date and parse it
      CHECK_TIME:  check correct time and parse it
      DATE2DAYS:   calculate days based on 0000/01/01 (== 1)
      DAYS2DATE:   generate sorted day from given days
      TIME2FRACT:  calculate decimal fraction for time
      FRACT2TIME:  calculate time from given decimal fraction
      DATE2JULIAN: generate Julian date (YYYYDDD)
      JULIAN2DATE: generate sorted date (YYYYMMDD)
      WEEKDAY:     generate dayname and/or dayindex


syntax:
    SDATE ...... sorted date (YYYYMMDD)
    JDATE ...... Julian date (YYYYDDD)
    DAYS ....... DATERGF-days, if time supplied, time is a decimal fraction
    TIME ....... on input 24hour- (military) or 12hour-format allowed,
                 output will be allways in 24hour-format (military, computer)
    FRACT ...... decimal fraction of time
    SECONDS .... second-value for DAYS.FRACT

   Argument1:      Flag: Argument2:        Result:

   "SDATE[ TIME]"                          DAYS[.FRACT] since 00000101 inclusive
   "DAYS[.FRACT]", "S"                     SDATE[ TIME24]
   "SDATE[ TIME]", "J"                     JDATE
   "JDATE",        "JR"                    SDATE ("Julian Reversed")

   "TIME",         "F"                     FRACT
   "FRACT",        "FR"                    TIME24 ("Fraction Reversed")

   "DAYS[.FRACT]", "SEC"                   SECONDS
   "SECONDS",      "SECR"                  DAYS[.FRACT] ("SEConds Reversed")

   "SDATE[ TIME]", "-S", "SDATE[ TIME]"    DAYS[.FRACT]
   "SDATE[ TIME]", "-",  "DAYS[.FRACT]"    SDATE[ TIME24]
   "SDATE[ TIME]", "+",  "DAYS[.FRACT]"    SDATE[ TIME24]

   "SDATE[ TIME]", "C"                     SDATE if correct, nothing ('') if false
   "SDATE[ TIME]", "L"                     if leap-year, return 1, else 0

   "SDATE[ TIME]", "Y"                     check date & return year
   "SDATE[ TIME]", "YB"[, DAYS[.FRACT]]    year begin [+/- DAYS[.FRACT]]
   "SDATE[ TIME]", "YE"[, DAYS[.FRACT]]    year end [+/- DAYS[.FRACT]]

   "SDATE[ TIME]", "HY"                    semester index (1-2)
   "SDATE[ TIME]", "HYB"[, DAYS[.FRACT]]   semester begin [+/- DAYS[.FRACT]]
   "SDATE[ TIME]", "HYE"[, DAYS[.FRACT]]   semester end [+/- DAYS[.FRACT]]

   "SDATE[ TIME]", "M"                     check date & return month
   "SDATE[ TIME]", "MN"                    monthname
   "SDATE[ TIME]", "MB"[, DAYS[.FRACT]]    month begin [+/- DAYS[.FRACT]]
   "SDATE[ TIME]", "ME"[, DAYS[.FRACT]]    month end [+/- DAYS[.FRACT]]

   "SDATE[ TIME]", "D"                     check date & return day
   "SDATE[ TIME]", "DN"                    dayname
   "SDATE[ TIME]", "DI"                    dayindex (1=monday, ..., 7=sunday)

   "SDATE[ TIME]", "W"                     week-number
   "SDATE[ TIME]", "WB"[, DAYS[.FRACT]]    week begin (Monday) [+/- DAYS.[FRACT]]
   "SDATE[ TIME]", "WE"[, DAYS[.FRACT]]    week end (Sunday) [+/- DAYS.[FRACT]]

   "SDATE[ TIME]", "Q"                     quarter index (1-4)
   "SDATE[ TIME]", "QB"[, DAYS[.FRACT]]    quarter begin [+/- DAYS[.FRACT]]
   "SDATE[ TIME]", "QE"[, DAYS[.FRACT]]    quarter end [+/- DAYS[.FRACT]]

*/


IF ARG(1) = ''|ARG(1) = '?' THEN SIGNAL usage


/* invoked as a COMMAND (from command-line) or as a FUNCTION ? */
PARSE SOURCE . invocation .
invocation_as_function = (invocation = "FUNCTION")

IF \invocation_as_function THEN     /* called as COMMAND or SUBROUTINE and not as a FUNCTION! */
DO                                  /* only one argument-string, which has to be parsed ! */
   IF VERIFY(ARG(1), "(", "M") > 0 THEN
      PARSE ARG "(" tmp ")"
   ELSE
      tmp = ARG(1)

   PARSE VAR tmp argument1 "," argument2 "," argument3

   argument1 = STRIP(argument1)     /* strip blanks */
   argument2 = STRIP(argument2)
   argument3 = STRIP(argument3)
   argument1 = STRIP(argument1,,"'")/* strip ' */
   argument2 = STRIP(argument2,,"'")
   argument3 = STRIP(argument3,,"'")
   argument1 = STRIP(argument1,,'"')/* strip " */
   argument2 = STRIP(argument2,,'"')
   argument3 = STRIP(argument3,,'"')

   SELECT                  /* number of arguments */
      WHEN argument3 <> '' THEN argcount = 3
      WHEN argument2 <> '' THEN argcount = 2
      OTHERWISE                 argcount = 1

   END

END
ELSE     /* invoked as a function */
DO
    argument1 = ARG(1)
    argument2 = ARG(2)
    argument3 = ARG(3)
    argcount  = ARG()      /* number of arguments */
END


NUMERIC DIGITS 14          /* set precision to 14 digits after comma */

PARSE UPPER VAR argument1 date1 time1
flag = TRANSLATE(argument2)
PARSE UPPER VAR argument3 date2 time2

/* build monthdays array */
monthdays.1 = 31
monthdays.2 = 28
monthdays.3 = 31
monthdays.4 = 30
monthdays.5 = 31
monthdays.6 = 30
monthdays.7 = 31
monthdays.8 = 31
monthdays.9 = 30
monthdays.10 = 31
monthdays.11 = 30
monthdays.12 = 31


/* check sorted dates & numbers */

IF argument3 <> '' & flag <> '-S' THEN     /* check whether third argument is a valid number */
   IF \DATATYPE(argument3, 'N') THEN
   DO
      errmsg = argument3': not numeric'
      SIGNAL error
   END

SELECT
   /* check sorted date and adjust monthdays. array, if necessary */
   WHEN WORDPOS(flag, "S SEC SECR JR F FR") = 0 | flag = '' THEN
        DO
           date1 = check_date(date1)
           IF time1 <> '' THEN time1 = check_time(time1)
        END

   WHEN flag = 'F' THEN time1 = check_time(date1)       /* time in hand ? */

   OTHERWISE    /* argument1 a positive number ? */
        DO
           IF \DATATYPE(argument1,'N') THEN
           DO
              errmsg = argument1': not numeric'
              SIGNAL error
           END
           ELSE IF argument1 < 0 THEN
           DO
              errmsg = argument1': must be a positive number'
              SIGNAL error
           END
        END
END


/* act according to flag */
SELECT
   WHEN flag = '' THEN                  /* SDATE: calculate days of date = DAYS */
        DO
           days1 = date2days(date1)
           if time1 <> '' THEN fraction1 = time2fract(time1)
                          ELSE fraction1 = ''
           result_datergf = days1||SUBSTR(fraction1,2)
        END

   WHEN flag = 'S' THEN                 /* DAY: calculate date/time = SDATE */
        DO
          IF date1 < 1 THEN
          DO
                errmsg = argument1 argument2": yields invalid date (< 0000/01/01) !"
                SIGNAL error
          END

          days_int = date1 % 1
          IF days_int > 3652427 THEN    /* > 9999/12/31 ? */
          DO
                errmsg = argument1 argument2": yields invalid date (> 9999/12/31) !"
                SIGNAL error
          END

          time_only = date1 - days_int
          date = days2date(days_int)      /* get rid of fraction */

          IF time_only > 0 THEN date = date fract2time(time_only)

          result_datergf = date
        END

   WHEN flag = '-S' THEN                /* SDATE - SDATE = DAYS */
        DO
           days1 = date2days(date1)
           IF time1 <> '' THEN fraction1 = time2fract(time1)
                          ELSE fraction1 = ''
           result_datergf1 = days1||SUBSTR(fraction1,2)

           /* check date2 and prepare monthdays. */
           date2 = check_date(date2)
           days2 = date2days(date2)

           IF time2 <> '' THEN fraction2 = time2fract(check_time(time2))
           ELSE fraction2 = ''

           result_datergf2 = days2||SUBSTR(fraction2,2)
           result_datergf = result_datergf1 - result_datergf2
        END

   WHEN (flag = '-') | (flag = '+') THEN        /* SDATE-DAYS = SDATE */
        DO
          days1 = date2days(date1)

          IF time1 <> '' THEN fraction1 = time2fract(time1)
                         ELSE fraction1 = ''

          temp = days1||SUBSTR(fraction1,2)

          IF flag = '-' THEN
             temp = temp - date2           /* subtract */
          ELSE
             temp = temp + date2           /* add */

          IF temp < 1 | ABS(temp) > 3652427 THEN        /* < 0000/01/01 or > 9999/12/31 ? */
          DO
               errmsg = argument1 argument2 argument3": does not yield a valid date!"
               SIGNAL error
          END

          days1 = temp % 1                  /* days since 0000/01/01 inclusive == 1 */
          time1 = temp // 1                 /* time */
          result_datergf = days2date(days1)

          IF time1 > 0 THEN
             result_datergf = result_datergf fract2time(time1)
        END

   WHEN flag = 'J' THEN                 /* SDATE = JDATE */
        result_datergf = date2julian(date1)

   WHEN flag = 'JR' THEN                /* JDATE = SDATE (reverse Julian date) */
        result_datergf = julian2date(date1)

   WHEN flag = 'F' THEN                 /* generate FRACT from TIME */
        result_datergf = time2fract(time1)

   WHEN flag = 'FR' THEN                /* generate TIME24 from decimal fraction */
        result_datergf = fract2time(date1 // 1)

   WHEN flag = 'SEC' THEN               /* generate SECONDS from DAYS[.FRACTION] */
        result_datergf = (date1 * 86400 + 0.5) % 1  /* round to seconds */

   WHEN flag = 'SECR' THEN              /* generate DAYS[.FRACTION] from SECONDS */
        result_datergf = date1 / 86400

   WHEN flag = 'C' THEN                 /* check date[ time] */
        result_datergf = argument1

   WHEN flag = 'L' THEN                 /* is date in a leap year? */
        DO
           year = WORD(date1, 1)
           IF year > 1582 THEN             /* Gregorian calender */
              result_datergf = (((year // 4) = 0) & \((year // 100) = 0)) | ((year // 400)=0)
           ELSE result_datergf = ((year // 4) = 0) /* Julian calender    */
        END

   WHEN flag = 'Y' THEN                 /* return year */
        result_datergf = WORD(date1, 1)

   WHEN flag = 'YB' | flag = 'YE' THEN     /* return year-begin or -end  */
        DO
           year = WORD(date1, 1)           /* optionally add (negative) days */

           IF argcount < 3 THEN               /* no third argument */
           DO
              IF flag = 'YB' THEN result_datergf = year||'0101'
              ELSE result_datergf = year||'1231'

              IF time1 <> '' THEN result_datergf = result_datergf TRANSLATE(time1,':',' ')
           END
           ELSE
           DO
              IF flag = 'YB' THEN result_datergf = year '1 1'
              ELSE result_datergf = year '12 31'

              result_datergf = date2days(result_datergf)
              IF time1 <> '' THEN result_datergf = result_datergf + time2fract(time1)
              result_datergf = result_datergf + date2

              days = result_datergf % 1
              IF days < 1 | ABS(days) > 3652427 THEN    /* < 0000/01/01 or > 9999/12/31 ? */
              DO
                   errmsg = argument1 argument2 argument3": does not yield a valid date!"
                   SIGNAL error
              END

              fraction = result_datergf // 1
              result_datergf = days2date(days)
              IF fraction > 0 THEN result_datergf = result_datergf fract2time(fraction)
           END
        END

   WHEN flag = 'M' THEN                 /* return month */
        result_datergf = WORD(date1, 2)

   WHEN flag = 'MN' THEN                /* return monthname */
        result_datergf = WORD("January February March April May June July",
                 "August September October November December", WORD(date1, 2))

   WHEN flag = 'MB' | flag = 'ME' THEN     /* return month-begin or -end  */
        DO
           PARSE VAR date1 year month .    /* optionally add (negative) days */

           IF argcount < 3 THEN               /* no third argument */
           DO
              IF flag = 'MB' THEN result_datergf = year||RIGHT(month,2,'0')||'01'
              ELSE IF year = 1582 & month = 10 THEN result_datergf = year||RIGHT(month,2,'0')||'31'
              ELSE result_datergf = year||RIGHT(month,2,'0')||monthdays.month

              IF time1 <> '' THEN result_datergf = result_datergf TRANSLATE(time1,':',' ')
           END
           ELSE
           DO
              IF flag = 'MB' THEN result_datergf = year month '1'
              ELSE IF year = 1582 & month = 10 THEN result_datergf = year month '31'
              ELSE result_datergf = year month monthdays.month

              result_datergf = date2days(result_datergf)
              IF time1 <> '' THEN result_datergf = result_datergf + time2fract(time1)
              result_datergf = result_datergf + date2

              days = result_datergf % 1
              IF days < 1 | ABS(days) > 3652427 THEN    /* < 0000/01/01 or > 9999/12/31 ? */
              DO
                   errmsg = argument1 argument2 argument3": does not yield a valid date!"
                   SIGNAL error
              END

              fraction = result_datergf // 1
              result_datergf = days2date(days)
              IF fraction > 0 THEN result_datergf = result_datergf fract2time(fraction)
           END
        END


   WHEN flag = 'W' THEN                 /* calculate week of year */
        DO
          PARSE VAR date1 year month day

          PARSE VALUE weekday(year "1 1", "ALL") WITH days_a d_ia

          /* 1. week or old year's week ? */
          IF d_ia > 4 THEN diff = d_ia - 9
          ELSE diff = d_ia - 2

          c1 = SUBSTR(date2julian(date1),5,3) + diff
          result_datergf = c1 % 7 + 1           /* number of weeks */

          IF result_datergf > 51 THEN           /* last week in year ?, probably 1st week? */
          DO

             PARSE VALUE weekday(year "12 31", "ALL") WITH days_0 di0

             IF di0 < 4 THEN
                IF day > (31-di0) THEN result_datergf = 1 /* first week, as 31st smaller than thursday  */
          END
          ELSE IF result_datergf = 1 THEN       /* beginning of January, is it last year's last week ? */
          DO
             IF (day + diff) < 0 THEN
             DO
                PARSE VALUE weekday(RIGHT(year-1,4,'0') "1 1", "ALL") WITH days_0 di0

                IF di0 > 4 THEN diff2 = di0 - 9 /* second week is first */
                ELSE diff2 = di0 - 2            /* first week */

                c1 = SUBSTR(date2julian((RIGHT(year-1,4,'0') "12 31")),5,3) + diff2
                result_datergf  = c1 % 7 + 1            /* number of weeks */
             END
          END
        END

   WHEN flag = 'D' THEN                 /* return day */
        result_datergf = WORD(date1, 3)

   WHEN flag = 'DN' THEN                /* return dayname */
        result_datergf = weekday(date1)

   WHEN flag = 'DI' THEN               /* return dayindex */
        result_datergf = weekday(date1, "I")

   WHEN flag = 'WB' | flag = 'WE' THEN     /* return week-begin (MON) or -end (SUN)  */
        DO
           PARSE VALUE weekday(date1, "ALL") WITH tmp di

           IF flag = 'WB' THEN diff = 1 - di
           ELSE diff = 7 - di

           new_days = tmp + diff

           IF argcount < 3 THEN               /* no third argument */
           DO
              IF new_days < 1 THEN         /* 0000/01/01 = THU, no monday available */
              DO
                   errmsg = argument1 argument2": does not yield a valid date!"
                   SIGNAL error
              END
              result_datergf = days2date(new_days)
              IF time1 <> '' THEN result_datergf = result_datergf TRANSLATE(time1,':',' ')
           END
           ELSE
           DO
              IF time1 <> '' THEN result_datergf = new_days + time2fract(time1)
              ELSE result_datergf = new_days

              result_datergf = result_datergf + date2

              days = result_datergf % 1
              IF days < 1 | ABS(days) > 3652427 THEN    /* < 0000/01/01 or > 9999/12/31 ? */
              DO
                   errmsg = argument1 argument2 argument3": does not yield a valid date!"
                   SIGNAL error
              END

              fraction = result_datergf // 1
              result_datergf = days2date(days)
              IF fraction > 0 THEN result_datergf = result_datergf fract2time(fraction)
           END
        END


   WHEN flag = 'Q' THEN                 /* return quarter */
        DO
           year = WORD(date1, 1)
           tmp = WORD(argument1, 1)           /* sorted date */
           SELECT
              WHEN tmp < year||'0401' THEN result_datergf = 1
              WHEN tmp < year||'0701' THEN result_datergf = 2
              WHEN tmp < year||'1001' THEN result_datergf = 3
              OTHERWISE result_datergf = 4
           END
        END

   WHEN flag = 'QB' | flag = 'QE' THEN  /* return quarter-begin or -end  */
        DO                              /* optionally add (negative) days */
           year = WORD(date1, 1)
           tmp = WORD(argument1, 1)        /* sorted date */

           IF argcount < 3 THEN            /* no third argument */
           DO
              IF flag = 'QB' THEN       /* quarter begin */
              DO
                 SELECT
                    WHEN tmp < year||'0401' THEN result_datergf = year||'0101'
                    WHEN tmp < year||'0701' THEN result_datergf = year||'0401'
                    WHEN tmp < year||'1001' THEN result_datergf = year||'0701'
                    OTHERWISE result_datergf = year||'1001'
                 END
              END
              ELSE                      /* quarter end */
              DO
                 SELECT
                    WHEN tmp < year||'0401' THEN result_datergf = year||'0331'
                    WHEN tmp < year||'0701' THEN result_datergf = year||'0630'
                    WHEN tmp < year||'1001' THEN result_datergf = year||'0930'
                    OTHERWISE result_datergf = year||'1231'
                 END
              END

              IF time1 <> '' THEN result_datergf = result_datergf TRANSLATE(time1,':',' ')
           END
           ELSE
           DO
              IF flag = 'QB' THEN
              DO
                 SELECT
                    WHEN tmp < year||'0401' THEN result_datergf = year  '1 1'
                    WHEN tmp < year||'0701' THEN result_datergf = year  '4 1'
                    WHEN tmp < year||'1001' THEN result_datergf = year  '7 1'
                    OTHERWISE result_datergf = year  '10 1'
                 END
              END
              ELSE
              DO
                 SELECT
                    WHEN tmp < year||'0401' THEN result_datergf = year  '3 31'
                    WHEN tmp < year||'0701' THEN result_datergf = year  '6 30'
                    WHEN tmp < year||'1001' THEN result_datergf = year  '9 30'
                    OTHERWISE result_datergf = year  '12 31'
                 END
              END

              result_datergf = date2days(result_datergf)
              IF time1 <> '' THEN result_datergf = result_datergf + time2fract(time1)
              result_datergf = result_datergf + date2

              days = result_datergf % 1
              IF days < 1 | ABS(days) > 3652427 THEN    /* < 0000/01/01 or > 9999/12/31 ? */
              DO
                   errmsg = argument1 argument2 argument3": does not yield a valid date!"
                   SIGNAL error
              END

              fraction = result_datergf // 1
              result_datergf = days2date(days)
              IF fraction > 0 THEN result_datergf = result_datergf fract2time(fraction)
           END
        END

   WHEN flag = 'HY' THEN                /* return semester (1 = 1.half, 2 = 2.half */
           IF WORD(date1, 2) < 7 THEN result_datergf = 1
           ELSE result_datergf = 2

   WHEN flag = 'HYB' | flag = 'HYE' THEN   /* return quarter-begin or -end  */
        DO
           PARSE VAR date1 year month .    /* optionally add (negative) days */

           IF argcount < 3 THEN               /* no third argument */
           DO
              IF flag = 'HYB' THEN
              DO
                 IF month < 7 THEN result_datergf = year||'0101'
                 ELSE result_datergf = year||'0701'
              END
              ELSE
              DO
                 IF month < 7 THEN result_datergf = year||'0630'
                 ELSE result_datergf = year||'1231'
              END

              IF time1 <> '' THEN result_datergf = result_datergf TRANSLATE(time1,':',' ')
           END
           ELSE
           DO
              IF flag = 'HYB' THEN
              DO
                 IF month < 7 THEN result_datergf = year '1 1'
                 ELSE result_datergf = year '7 1'
              END
              ELSE
              DO
                 IF month < 7 THEN result_datergf = year  '6 30'
                 ELSE result_datergf = year '12 31'
              END

              result_datergf = date2days(result_datergf)
              IF time1 <> '' THEN result_datergf = result_datergf + time2fract(time1)
              result_datergf = result_datergf + date2

              days = result_datergf % 1
              IF days < 1 | ABS(days) > 3652427 THEN    /* < 0000/01/01 or > 9999/12/31 ? */
              DO
                   errmsg = argument1 argument2 argument3": does not yield a valid date!"
                   SIGNAL error
              END

              fraction = result_datergf // 1
              result_datergf = days2date(days)
              IF fraction > 0 THEN result_datergf = result_datergf fract2time(fraction)
           END
        END

   OTHERWISE
        DO
          errmsg = flag': unknown flag'
          SIGNAL error
        END
END

IF invocation_as_function THEN   /* invoked as function, therefore return the value */
   RETURN result_datergf         /* return value */

/* invoked from the COMMAND-line or as a SUBROUTINE, both invocations must not return a value */
SAY "DATERGF - result:" result_datergf       /* show result on standard output */
RETURN
/* end of main routine */






/* parse & check arguments */
CHECK_DATE: PROCEDURE EXPOSE monthdays.

    PARSE ARG 1 year 5 month 7 day 9

    IF \DATATYPE(year,'N') THEN
    DO
       errmsg = ARG(1)": year is not numeric"
       SIGNAL error
    END

    IF year < 0 THEN
    DO
       errmsg = ARG(1)": year must be 0000 or greater"
       SIGNAL error
    END

    /* is year a leap year ? */
    IF year > 1582 THEN                 /* Gregorian calender */
       leap_year = (((year // 4) = 0) & \((year // 100) = 0)) | ((year // 400)=0)
    ELSE leap_year = ((year // 4) = 0)  /* Julian calender    */

    monthdays.2 = 28 + leap_year
    IF year = 1582 THEN monthdays.10 = 21       /* 1582: October had 10 days less */

    SELECT
       WHEN \DATATYPE(month,'N') THEN
            DO
               errmsg = ARG(1)||": month is not numeric"
               SIGNAL error
            END
       WHEN (month < 1) | (month > 12) THEN
            DO
               errmsg = ARG(1)||": month out of range"
               SIGNAL error
            END
       OTHERWISE
            month = month % 1   /* get rid of leading nulls */
    END

    SELECT
       WHEN \DATATYPE(day,'N') THEN
            DO
               errmsg = ARG(1)": day is not numeric"
               SIGNAL error
            END
       WHEN (day < 1) THEN
            DO
               errmsg = ARG(1)": day out of range"
               SIGNAL error
            END
       WHEN year = 1582 & month = 10 THEN    /* Gregorian: 1582, October 1-4, 15-31 */
            DO
               IF (day > 4 & day < 15) | day > 31 THEN
               DO
                  IF day > 31 THEN
                     errmsg = ARG(1)": too many days for given month"
                  ELSE
                     errmsg = ARG(1)": day out of range (1582/10/05-1582/10/14 do not exist)"
                  SIGNAL error
               END
            END
       WHEN day > monthdays.month THEN
            DO
               errmsg = ARG(1)": too many days for given month"
               SIGNAL error
            END
       OTHERWISE
            day = day % 1 /* get rid of leading nulls */
    END

    RETURN year month day
/* end of CHECK_DATE */


/* parse & check time, return 24hour-Time (military time) */
CHECK_TIME: PROCEDURE EXPOSE monthdays.
    PARSE UPPER ARG tmp
    time24 = 1                  /* starting with 24 hour time in mind */
    time12 = POS('M', tmp)      /* AM or PM ? */
    IF time12 > 0 THEN
    DO
      time24 = 0                /* 12 hour time in hand */
      letter = SUBSTR(tmp, time12 - 1, 1)
      IF \((letter = 'A') | letter = 'P') THEN
      DO
         errmsg = ARG(1)': not a valid AM/PM-time'
         SIGNAL error
      END
      tmp = SUBSTR(tmp, 1, time12 - 2)  /* remove ?M */
    END

    PARSE VAR tmp hours ':' minutes ':' seconds

    SELECT
      WHEN hours = '' THEN hours = 0
      WHEN \datatype(hours,'N') THEN     /* no numeric type */
           DO
              errmsg = ARG(1)": hours are not numeric"
              SIGNAL error
           END
      WHEN (hours < 0) | (hours > 23) THEN      /* out of range    */
           DO
              errmsg = ARG(1)": hours out of range"
              SIGNAL error
           END
      OTHERWISE NOP
    END

    SELECT
      WHEN minutes = '' THEN minutes = 0
      WHEN \datatype(minutes,'N') THEN     /* no numeric type */
           DO
              errmsg = ARG(1)": minutes are not numeric"
              SIGNAL error
           END
      WHEN (minutes < 0) | (minutes > 59) THEN /* out of range    */
           DO
              errmsg = ARG(1)": minutes out of range"
              SIGNAL error
           END
      OTHERWISE NOP
    END

    SELECT
      WHEN seconds = '' THEN seconds = 0
      WHEN \datatype(seconds,'N') THEN     /* no numeric type */
           DO
              errmsg = ARG(1)": seconds are not numeric"
              SIGNAL error
           END
      WHEN (seconds < 0) | (seconds >= 60) THEN /* out of range    */
           DO
              errmsg = ARG(1)": seconds out of range"
              SIGNAL error
           END
      OTHERWISE NOP
    END

    IF \time24 THEN             /* received a 12hour time, adjust it to 24hour time */
    DO
       IF (letter = 'A') & (hours = 12) THEN hours = 0
       ELSE IF ((letter = 'P') & (hours < 12)) THEN hours = hours + 12
    END

    RETURN hours  minutes seconds
/* end of CHECK_TIME */



/* calculate days based on 0000/01/01 (= 1. day == 1) */
DATE2DAYS: PROCEDURE  EXPOSE monthdays.
    PARSE ARG year month day

    days_1    = year * 365
    leap_days = year % 4

    IF year > 0 THEN
    DO
       leap_days = leap_days + 1        /* account for leap year in 0000 */

       IF year > 1582 THEN days_1 = days_1 - 10 /* account for 1582, which had 10 days less */

       IF year > 1600 THEN         /* account for Gregorian calender */
       DO
           diff = year - 1600
           leap_days = leap_days - (diff % 100 - diff % 400)
           leap_year = (((diff // 4) = 0) & \((diff // 100) = 0)) | ((diff // 400)=0) /* leap year in hand ? */
       END
       ELSE leap_year = ((year // 4) = 0)       /* leap year in hand ? */

       leap_days = leap_days - leap_year
    END

    days_2 = SUBSTR(date2julian(ARG(1)), 5, 3)

    RETURN (days_1 + leap_days + days_2)
/* end of DATE2DAYS */


DAYS2DATE: PROCEDURE  EXPOSE monthdays. /* calculate sorted day from given days */
    days = ARG(1)

    avg_days = 365.25        /* average days a year */

    /* estimate years */
    IF days > 578181 THEN               /* year greater than 1582/12/31 ? */
       year1 = (days + 10 ) % avg_days  /* account for 10 missing days in 1582 */
    ELSE
       year1 = days % avg_days


    DO FOREVER

       /* is year1 a leap year ? */
       IF year1 > 1582 THEN                     /* Gregorian calender */
          year_days = (((year1 // 4) = 0) & \((year1 // 100) = 0)) | ((year1 // 400)=0)
       ELSE year_days = ((year1 // 4) = 0)      /* Julian calender    */

       IF year1 <> 1582 THEN year_days = year_days + 365
       ELSE year_days = 355             /* 1582 had 10 days less */

       days_year1 = date2days(year1 "1 1")   /* pad year with 0 */
       diff1 = days - days_year1

       IF diff1 < 0 THEN year1 = year1 - 1
       ELSE IF diff1 > (year_days - 1) THEN year1 = year1 + 1
       ELSE LEAVE
    END
    diff1 = diff1 + 1           /* one day off, due to subtraction */

    tmp = RIGHT(year1,4,'0')|| RIGHT(diff1,3,'0')       /* build Julian date */

    RETURN julian2date(tmp)     /* build sorted day */
/* end of DAYS2DATE */




/* calculate decimal fraction from time */
TIME2FRACT: PROCEDURE  EXPOSE monthdays.     /* calculate decimal value for time */
    PARSE ARG hours minutes seconds

    /* hour_div = 24      =   24           */
    /* min_div  = 1440    =   24 * 60      */
    /* sec_div  = 86400   =   24 * 60 * 60 */

    RETURN ((hours/24) + (minutes/1440) + (seconds/86400))
/* end of TIME2FRACT */


/* calculate time from fraction */
FRACT2TIME: PROCEDURE  EXPOSE monthdays.     /* calculate time from given value */
    /* hours    = 24      =   24           */
    /* minutes  = 1440    =   24 * 60      */
    /* seconds  = 86400   =   24 * 60 * 60 */

    tmp = arg(1) + 0.0000001            /* account for possible precision error */

    hours   = (tmp * 24) % 1
    minutes = (tmp * 1440 - hours * 60) % 1
    seconds = (tmp * 86400 - hours * 3600 - minutes * 60) % 1

    RETURN RIGHT(hours,2,'0')':'RIGHT(minutes,2,'0')':'RIGHT(seconds,2,'0')

/* end of FRACT2TIME */


/* build Julian date from sorted date, result: yyyyddd */
DATE2JULIAN: PROCEDURE EXPOSE monthdays.
    PARSE ARG year month day

    /* is year a leap year ? */
    IF year > 1582 THEN                 /* Gregorian calender */
       leap_year = (((year // 4) = 0) & \((year // 100) = 0)) | ((year // 400)=0)
    ELSE leap_year = (year // 4) = 0    /* Julian calender    */

    monthdays.2 = 28 + leap_year
    IF year = 1582 THEN monthdays.10 = 21       /* 1582: October just had 21 days */

    result_function = 0
    DO i = 1 TO month - 1
       result_function = result_function + monthdays.i
    END

    IF year = 1582 & month = 10 & day > 4 THEN day = day - 10       /* Gregorian: 10 days too many */
    result_function = result_function + day

    RETURN year||RIGHT(result_function,3,'0')
/* end of DATE2JULIAN */




/* build sorted date from Julian date, result: yyyymmdd */
JULIAN2DATE: PROCEDURE EXPOSE monthdays.
    year = SUBSTR(ARG(1),1,4)

    /* is year a leap year ? */
    IF year > 1582 THEN                 /* Gregorian calender */
       leap_year = (((year // 4) = 0) & \((year // 100) = 0)) | ((year // 400)=0)
    ELSE leap_year = (year // 4) = 0    /* Julian calender    */

    monthdays.2 = 28 + leap_year
    IF year = 1582 THEN monthdays.10 = 21       /* 1582: October just had 21 days */

    jul_days = SUBSTR(ARG(1),5)       /* Julian days */
    SELECT
       WHEN jul_days > (365 + leap_year) THEN
          DO
             errmsg = ARG(1)": too many days for the given year"
             SIGNAL error
          END
       WHEN year = 1582 & jul_days > 355 THEN       /* 1582: 10 days less than other years */
          DO
             errmsg = ARG(1)": too many days for 1582 (had 355 days only)"
             SIGNAL error
          END
       OTHERWISE NOP
    END

    /* calculate days */
    tmp = 0
    DO month = 1 TO 12
       tmp = tmp + monthdays.month
       IF tmp = jul_days THEN        /* exactly given days ?       */
       DO
          day = monthdays.month
          LEAVE
       END

       IF tmp > jul_days THEN      /* got over month              */
       DO
          day = monthdays.month - (tmp - jul_days)
          LEAVE
       END
    END

    /* 1582: October 1-4, 15-31,  adjust for 10 missing days if necessary */
    IF year = 1582 & month = 10 & day > 4 THEN day = day + 10

    RETURN year||RIGHT(month,2,'0')||RIGHT(day,2,'0')
/* end of JULIAN2DATE */




/* return day of sorted date as name or as index */
WEEKDAY: PROCEDURE EXPOSE monthdays.
    total_days = date2days(ARG(1))
    dayindex = (total_days + 2) // 7 + 1  /* normalize on Mondays = 1, ..., Sunday = 7 */

    IF ARG(2) = 'I' THEN result_function = dayindex
    ELSE IF ARG(2) = 'ALL' THEN result_function = total_days dayindex
    ELSE result_function = WORD("Monday Tuesday Wednesday Thursday Friday Saturday Sunday", dayindex)

    RETURN result_function
    /* remark:
        According to an advice of ISO a week starts with MONDAY, hence:
        Monday = 1, Tuesday = 2, Wednesday = 3, Thursday = 4, Friday = 5,
        Saturday = 6, Sunday = 7.
        The German DIN-organization already normalized on the ISO advice.
    */
/* end of WEEKDAY */

USAGE:
/* get ANSI-color-sequences from ScrColor.CMD */
PARSE VALUE ScrColor() WITH screen_normal screen_inverse text_normal text_info text_highlight text_alarm .

SAY
SAY text_info'DATERGF:'screen_normal' manipulate sorted dates, time, days and time-fractions'
SAY
SAY text_alarm'usage as a function in REXX-programs:'
SAY text_highlight'         DATERGF(argument)'
SAY '         DATERGF(argument, flag)'
SAY '         DATERGF(argument1, flag, argument2)'
SAY
SAY text_alarm'usage from command-line:'
SAY text_highlight'         DATERGF argument '
SAY '         DATERGF argument, flag '
SAY '         DATERGF argument1, flag, argument2 '
SAY
SAY screen_normal'         see enclosed Tutorial "RGFSHOW.CMD" and syntax below'
SAY
SAY text_alarm'syntax:'
SAY
SAY text_info'SDATE'screen_normal' ...... sorted date (YYYYMMDD)'
SAY text_info'JDATE'screen_normal' ...... Julian date (YYYYDDD)'
SAY text_info'DAYS'screen_normal' ....... DATERGF-days, if time supplied, time is a decimal fraction'
SAY text_info'TIME'screen_normal' ....... on input 24hour- (military) or 12hour-format allowed,'
SAY '             output will be allways in 24hour-format (military, computer)'
SAY text_info'FRACT'screen_normal' ...... decimal fraction of time'
SAY text_info'SECONDS'screen_normal' .... second-value for DAYS.FRACT'
SAY
SAY 'Argument1:      Flag: Argument2:        Result:'
SAY
SAY text_info'"SDATE[ TIME]"                          DAYS[.FRACT]'screen_normal' since 00000101 inclusive'
SAY text_info'"DAYS[.FRACT]", "S"                     SDATE[ TIME24]'
SAY '"SDATE[ TIME]", "J"                     JDATE'
SAY '"JDATE",        "JR"                    SDATE'screen_normal' ("Julian Reversed")'
SAY
SAY text_info'"TIME",         "F"                     FRACT'
SAY '"FRACT",        "FR"                    TIME24'screen_normal' ("Fraction Reversed")'
SAY
SAY text_info'"DAYS[.FRACT]", "SEC"                   SECONDS'
SAY '"SECONDS",      "SECR"                  DAYS[.FRACT]'screen_normal' ("SEConds Reversed")'
SAY
SAY text_info'"SDATE[ TIME]", "-S", "SDATE[ TIME]"    DAYS[.FRACT]'
SAY '"SDATE[ TIME]", "-",  "DAYS[.FRACT]"    SDATE[ TIME24]'
SAY '"SDATE[ TIME]", "+",  "DAYS[.FRACT]"    SDATE[ TIME24]'
SAY
SAY '"SDATE[ TIME]", "C"                     SDATE'screen_normal' if correct, nothing ('text_info''''''screen_normal') if false'
SAY text_info'"SDATE[ TIME]", "L"'screen_normal'                     if leap-year, return 1, else 0'
SAY text_info'"SDATE[ TIME]", "Y"'screen_normal'                     check date & return year'
SAY text_info'"SDATE[ TIME]", "YB"[, DAYS[.FRACT]]'screen_normal'    year begin 'text_info'[+/- DAYS[.FRACT]]'
SAY '"SDATE[ TIME]", "YE"[, DAYS[.FRACT]]'screen_normal'    year end 'text_info'[+/- DAYS[.FRACT]]'
SAY '"SDATE[ TIME]", "HY"'screen_normal'                    semester index (1-2)'
SAY text_info'"SDATE[ TIME]", "HYB"[, DAYS[.FRACT]]'screen_normal'   semester begin 'text_info'[+/- DAYS[.FRACT]]'
SAY '"SDATE[ TIME]", "HYE"[, DAYS[.FRACT]]'screen_normal'   semester end 'text_info'[+/- DAYS[.FRACT]]'
SAY
SAY '"SDATE[ TIME]", "M"'screen_normal'                     check date & return month'
SAY text_info'"SDATE[ TIME]", "MN"'screen_normal'                    monthname'
SAY text_info'"SDATE[ TIME]", "MB"[, DAYS[.FRACT]]'screen_normal'    month begin 'text_info'[+/- DAYS[.FRACT]]'
SAY '"SDATE[ TIME]", "ME"[, DAYS[.FRACT]]'screen_normal'    month end 'text_info'[+/- DAYS[.FRACT]]'
SAY ''
SAY '"SDATE[ TIME]", "D"'screen_normal'                     check date & return day'
SAY text_info'"SDATE[ TIME]", "DN"'screen_normal'                    dayname'
SAY text_info'"SDATE[ TIME]", "DI"'screen_normal'                    dayindex (1=monday, ..., 7=sunday)'
SAY
SAY text_info'"SDATE[ TIME]", "W"'screen_normal'                     week-number'
SAY text_info'"SDATE[ TIME]", "WB"[, DAYS[.FRACT]]'screen_normal'    week begin (Monday) 'text_info'[+/- DAYS.[FRACT]]'
SAY '"SDATE[ TIME]", "WE"[, DAYS[.FRACT]]'screen_normal'    week end (Sunday) 'text_info'[+/- DAYS.[FRACT]]'
SAY
SAY '"SDATE[ TIME]", "Q"'screen_normal'                     quarter index (1-4)'
SAY text_info'"SDATE[ TIME]", "QB"[, DAYS[.FRACT]]'screen_normal'    quarter begin 'text_info'[+/- DAYS[.FRACT]]'
SAY '"SDATE[ TIME]", "QE"[, DAYS[.FRACT]]'screen_normal'    quarter end 'text_info'[+/- DAYS[.FRACT]]'screen_normal
EXIT


ERROR:
/* 1994-03-03: produce an error-message on stderr even if called as a function
   /* invoked as a COMMAND (from command-line) or as a FUNCTION ? */
   PARSE SOURCE . invocation .
   invocation_as_function = (invocation = "FUNCTION")

   /* error message on device "STDERR", only if not called as function */
   IF \invocation_as_function THEN
*/

      '@ECHO DATERGF:' errmsg '>&2'

   EXIT ''                                      /* error, therefore return empty string */
