/*----------------------------------------------------------------------------+
| DATECONV Exec|Cmd                                                           |
+-----------------------------------------------------------------------------+
| This is a front-end to call the DATECONV FUNCTION internal code below.      |
| See DATECONV PACKAGE and DATECONV HELPCMS for more information.             |
+----------------------------------------------------------------------------*/
parse source . temp .
if temp = 'COMMAND' then
  do
    say 'DATECONV can only be called as a REXX Function or Sub-Routine.'
    exit 99
  end
if arg() > 5 then temp = ''                      /* too many arguments */
else temp = dateconv(arg(1),arg(2),arg(3),arg(4),arg(5))
exit temp


/*----------------------------------------------------------------------------+
| DATECONV FUNCTION                                                           |
+-----------------------------------------------------------------------------+
| This code is a REXX internal function; add it to your REXX programs.        |
| See DATECONV PACKAGE and DATECONV HELPCMS for more information.             |
+-----------------------------------------------------------------------------+
| Labels used within DATECONV Procedure are:                                  |
|   Dateconv:             <--- entry point                                    |
|   Dateconv_yy2cc:       <--- 2 digit to 4 digit year conversion
|   Dateconv_b2s_s2b:     <--- Basedate/Sorted format conversion              |
+-----------------------------------------------------------------------------+
| YYMMDD Change history:
| 900803 rlb v1.0 new code.   Russel L. Brooks    BROOKS/SJFEVMX
| 900808 rlb v2.0 new, better, faster.  doesn't use old BASEDATE code.
| 900821 rlb v3.0 add Arg(4) "Yx" to control assumed leading year digits.
|                 add format_out "L" for leap year.
| 910220 rlb v4.0 add Arg(5) Offset output date +/- days.
|                 Turn Trace Off at both labels. Set ERROR in Month Select.
| 910226 rlb v4.1 move TRACE past PROCEDURE for compiler.
| 910418 rlb v4.2 add ISO date format yyyy-mm-dd.
|                 allow input date to default to TODAY.
|                 convert all uses of EBCDIC Not sign "ª" to "<>".
|                 change input date parsing to allow leading blanks.
|                 if offset amount is 0 turn offset off.
| 910916 rlb v5.0 generate all formats but select what is requested.
|                 reduce overchecking, drop numerics 15 in b2s2b routine.
|                 allow muliple format request.
| 930414 rlb v5.1 bugfix: don't allow yyyymm00 as a valid Date(S) date.
| 940831 rlb v6.0 bugfix: better detection of invalid Date(J|U) dates.
|                 combine Date(E|O|U) code.  remove unneeded code.
|                 Signal on NoValue (but _we_ don't have 'novalue' label).
|                 only develop DOW, Month, Leapyear if asked for.
|                 test numbers w/ verify(integer) instead of datatype(W).
| 950113 rlb v6.1 parse out days/month for very small speed increase.
| 980629 rlb v7.0 changed internal variable 'yx' to 'cc' (century).
|                 if Fi=U/E/O/J & cc = '' then 100 year sliding window.
|
+----------------------------------------------------------------------------*/
dateconv:
procedure
trace O
signal on novalue                             /* force error detection */

parse UPPER arg date date_xtra, fi xtra1, fo xtra2, cc xtra3, offset

select
  when xtra1 <> '' then out = 'ERROR'
  when xtra2 <> '' then out = 'ERROR'
  when xtra3 <> '' then out = 'ERROR'
  when arg()  > 5  then out = 'ERROR'
  otherwise                                              /* initialize */
    parse value fi with 1 fi 2 . sdate bdate out .     /* 1 ltr + nuls */
    today = date('S') date('B')
end

/*----------------------------------------------------------------------+
| Input date formats U/E/O/J only use 2 digit years.  If CC is null then
| we'll calculate an appropriate century using a 100 year sliding window
| similar to what Rexx's Date() uses.
|
| Date format "C" is different.  Event though it doesn't specify a
| century we won't try to calculate one based on a sliding window.
| The user can specify an alternate century via Arg(4) "CC".
+----------------------------------------------------------------------*/
if cc <> '' then                                   /* check user value */
  select
    when verify(cc,'0123456789') > 0 then out = 'ERROR'       /* <>Num */
    when length(cc) <> 2             then out = 'ERROR'
    when cc < 0                      then out = 'ERROR'
    otherwise nop                                /* user's CC looks ok */
  end

/*----------------------------------------------------------------------+
| If no leading +/- sign then treat as +.  User could use + but if not
| included in quotes then REXX strips off the + sign.
+----------------------------------------------------------------------*/
parse value space(offset,0) with 1 offset_sign 2 offset_amnt . 1 offset .
if offset = '' then offset = 0
else
  do
    if offset_sign = '+' | offset_sign = '-' then nop
    else
      do
        offset_sign = '+'                 /* missing so default to '+' */
        offset_amnt = offset        /* use entire user field as amount */
      end
    if verify(offset_amnt,'0123456789') >0 then out = 'ERROR' /* <>Num */
    if offset_amnt = 0 then offset = 0            /* no offset request */
    else offset = 1                 /* yes, return date needs shifting */
  end

/*----------------------------------------------------------------------+
| Examine date according to "fi" (format in) caller passed.  If ok then
| convert date to either "B"asedate, "S"orted, or both formats.
|
| Dates are converted because it is easy to create "fo" (format out)
| dates from one or the other of these input formats.  This also limits
| having to directly support every possible "fi" to "fo" combination.
+----------------------------------------------------------------------*/
select
  when out <> '' then nop                    /* Error already detected */
  when fi = '' then                                           /* today */
    do
      /*----------------------------------------------------------------+
      | special case.  allow input date and input format to default to
      | TODAY.  This bypasses input date validation because we can rely
      | on REXX to supply valid dates.
      +----------------------------------------------------------------*/
      if date = '' then parse value today with sdate bdate .
      else out = 'ERROR'                  /* missing FormatIN for date */
    end
  when fi = 'N' then                             /* Normal dd Mmm yyyy */
    do  /* Test for N early because its only one that uses 'date_xtra' */
      parse value date date_xtra with dd mm yy date_xtra
      if date_xtra <> '' then out = 'ERROR'          /* too many parms */
      else
        do
          mm = wordpos(mm,'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC')
          if mm = 0 then out = 'ERROR'       /* invalid 3 letter month */
          else sdate = yy || right(mm,2,0)right(dd,2,0)
        end
    end
  when date_xtra <> '' then out = 'ERROR'            /* too many parms */
  when fi = 'B' then bdate = date                   /* Basedate dddddd */
  when fi = 'S' then sdate = date                   /* Sorted yyyymmdd */
  when fi = 'D' then                                       /* Days ddd */
    select
      when verify(date,'0123456789') > 0 then out = 'ERROR'   /* <>Num */
      otherwise
        yyyy = left(today,4)
        dd = dateconv_b2s_s2b(yyyy'0101','S')               /* Jan 1st */
        temp = dateconv_b2s_s2b(yyyy+1'0101','S') /* Jan 1st next year */
        if date < 1 | date > temp-dd then out = 'ERROR' /* max 365|366 */
        else bdate = dd + date - 1
    end
  when fi = 'C' then                                  /* Century ddddd */
    select
      when verify(date,'0123456789') > 0 then out = 'ERROR'   /* <>Num */
      otherwise
        if cc = '' then cc = left(today,2)
        dd = dateconv_b2s_s2b(cc'000101','S')          /* this century */
        temp = dateconv_b2s_s2b(cc+1'000101','S')      /* next century */
        if date<1 | date>temp-dd then out = 'ERROR' /* max 36524|36525 */
        else bdate = dd + date - 1
    end
  when fi = 'J' then                                   /* Julian yyddd */
    select
      when length(date) <> 5 then out = 'ERROR'
      when verify(date,'0123456789') > 0 then out = 'ERROR'   /* <>Num */
      otherwise
        parse value date with 1 yy 3 ddd .
        if cc = '' then cc = dateconv_yy2cc(yy)
        yyyy = cc || yy
        dd = dateconv_b2s_s2b(yyyy'0101','S')               /* Jan 1st */
        temp = dateconv_b2s_s2b(yyyy+1'0101','S')   /* Jan 1st next yy */
        if ddd < 1 | ddd > temp-dd then out = 'ERROR'   /* max 365|366 */
        else bdate = dd + ddd - 1
    end
  otherwise                  /* USA|European|Ordered|ISO ...or invalid */
    select
      when fi = 'U' then parse value date with mm'/'dd'/'yy .
      when fi = 'E' then parse value date with dd'/'mm'/'yy .
      when fi = 'O' then parse value date with yy'/'mm'/'dd .
      when fi = 'I' then parse value date with 1 cc 3 yy'-'mm'-'dd .
      otherwise out = 'ERROR'                     /* invalid Format_In */
    end
    select
      when out <> ''       then nop
      when verify(space(cc yy mm dd,0),'0123456789') > 0 then out = 'ERROR'
      when length(yy) <> 2 then out = 'ERROR'
      when length(mm)  > 2 then out = 'ERROR'
      when length(dd)  > 2 then out = 'ERROR'
      otherwise
        if cc = '' then cc = dateconv_yy2cc(yy)
        sdate = cc || right(yy,2,0)right(mm,2,0)right(dd,2,0)
    end
end

/*----------------------------------------------------------------------+
| If the output date is being shifted by an offset then...
|   1- get the basedate if it doesn't already exist
|   2- offset the basedate by the amount requested
|   3- scratch sorted date because it doesn't match offset basedate
+----------------------------------------------------------------------*/
if offset & out = '' then
  do
    if bdate = '' then
      do
        bdate = dateconv_b2s_s2b(sdate,'S')
        if bdate = '' then out = 'ERROR'
      end
    if out = '' then                                       /* no Error */
      do
        if offset_sign = '+' then bdate = bdate + offset_amnt
        else                      bdate = bdate - offset_amnt
      end
    sdate = ''     /* date shifted, if sdate existed it is now invalid */
  end

/*----------------------------------------------------------------------+
| we have Basedate or Sorted, generate the other if we don't have both.
+----------------------------------------------------------------------*/
select
  when out <> '' then nop                                     /* error */
  when bdate = '' then
    do
      bdate = dateconv_b2s_s2b(sdate,'S')
      if bdate = '' then out = 'ERROR'
    end
  when sdate = '' then
    do
      sdate = dateconv_b2s_s2b(bdate,'B')
      if sdate = '' then out = 'ERROR'
    end
  otherwise nop  /* both Bdate and Sdate already exist (and no errors) */
end

parse value sdate with 1 yyyy 5 . 1 cc 3 yy 5 mm 7 dd .
parse value '' with ddd ddddd month .        /* (re)initialize to null */

/*----------------------------------------------------------------------+
| "fo" Format_Out defaults to "Normal" out.
| "*" means return multiple formats, ALL if just "*" or the set of dates
| specified by the letters following "*".
+----------------------------------------------------------------------*/
parse value fo with 1 fo_string 2 temp
select
  when fo_string = '' then fo_string = 'N' /* default: "Normal" format */
  when fo_string <> '*' then nop   /* use single letter in 'fo_string' */
  otherwise
    if temp = '' then fo_string = 'NBSMWDJCOEULI'       /* all formats */
    else fo_string = temp       /* multiple formats selected by caller */
end

if out = '' then                                    /* if no Error yet */
  do while fo_string <> ''
    parse value fo_string with 1 fo 2 fo_string
    select
      when fo = 'B' then out = out bdate                   /* Basedate */
      when fo = 'S' then out = out sdate                   /* Sorted   */
      when fo = 'M' | fo = 'N' then
        do
          if month = '' then
            do
              temp =      'January February March April May June July'
              temp = temp 'August September October November December'
              month = word(temp,mm)
              if month = '' then
                do
                  out = 'ERROR'
                  leave
                end
            end
          if fo = 'M' then out = out month                 /* Month    */
          else out = out dd+0 left(month,3) yyyy           /* Normal   */
        end
      when fo = 'W' then                                   /* Weekday  */
        do
          temp = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
          out = out word(temp,(bdate//7)+1)
        end
      when fo = 'D' | fo = 'J' then
        do
          if ddd = '' then
            do
              ddd = dateconv_b2s_s2b(yyyy'0101','S')
              if ddd = '' then
                do
                  out = 'ERROR'
                  leave
                end
              else ddd = bdate - ddd + 1
            end
          if fo = 'D' then out = out ddd                   /* Days     */
          else out = out yy || right(ddd,3,0)              /* Julian   */
        end
      when fo = 'C' then                                   /* Century  */
        do
          ddddd = dateconv_b2s_s2b(cc'000101','S')
          if ddddd = '' then
            do
              out = 'ERROR'
              leave
            end
          else ddddd = bdate - ddddd + 1
          out = out ddddd
        end
      when fo = 'L' then                                   /* Leapyear */
        do
          select
            when yyyy //   4 > 0 then leap_year = 0
            when yyyy // 100 > 0 then leap_year = 1
            when yyyy // 400 = 0 then leap_year = 1
            otherwise                 leap_year = 0
          end
          out = out leap_year
        end
      when fo = 'E' then out = out dd'/'mm'/'yy            /* European */
      when fo = 'O' then out = out yy'/'mm'/'dd            /* Ordered  */
      when fo = 'U' then out = out mm'/'dd'/'yy            /* USA      */
      when fo = 'I' then out = out yyyy'-'mm'-'dd          /* ISO      */
      otherwise
        out = 'ERROR'                     /* Format_Out not recognized */
        leave
    end
  end

if out = 'ERROR' then out = '' /* null return indicates function error */
return strip(out,'L')           /*  <---  Dateconv Function exits here */


/*----------------------------------------------------------------------+
| Calculate a suitable Century for a 2 digit year using a sliding window
| similar to Rexx's Date() function.
|
|   (current_year - 50) = low end of window
|   (current_year + 49) = high end of window
+----------------------------------------------------------------------*/
dateconv_yy2cc:
temp = left(today,4) + 49
if (left(temp,2)||arg(1)) <= temp then return left(temp,2)
else                                   return left(temp,2) - 1


/*----------------------------------------------------------------------+
| Convert Date(B) <--> Date(S)
|
| Arg(1) :  Date(B) or Date(S) date to be converted to other format.
|
| Arg(2) :  "B" or "S" to identify Arg(1)
|
| Return :  the converted date or "" (null) if an error detected.
+----------------------------------------------------------------------*/
dateconv_b2s_s2b:
procedure
trace O
signal on novalue                             /* force error detection */

arg dd .          /* Total days or sorted date, don't know which (yet) */
if verify(dd,'0123456789') > 0 then return ''                 /* <>Num */

/* Initialize Days per month stem */
temp = 0 31 28 31 30 31 30 31 31 30 31 30 31
parse value temp with d. d.1 d.2 d.3 d.4 d.5 d.6 d.7 d.8 d.9 d.10 d.11 d.12 .

select
  when arg(2) = 'B' then                 /* Convert Date(B) to Date(S) */
    do
      dd = dd + 1                               /* Date(S) = Date(B)+1 */
      yyyy = dd  % 146097 * 400                     /* 400 year groups */
      dd   = dd // 146097           /* all 400 year groups are similar */

      temp = dd  %  36524                           /* 100 year groups */
      dd   = dd //  36524
      if temp = 4 then
        do
          temp = 3  /* back up 1, 4th 100 year group not same as 1st 3 */
          dd = dd + 36524
        end
      yyyy = temp * 100 + yyyy

      temp = dd  %   1461                             /* 4 year groups */
      dd   = dd //   1461
      if temp = 25 then
        do
          temp = 24 /* back up 1, 25th 4 year group not same as 1st 24 */
          dd = dd + 1461
        end
      yyyy = temp * 4 + yyyy

      yyyy = dd % 365.25 + yyyy                       /* 1 year groups */
      dd   = dd - ((dd % 365.25) * 365.25) % 1

      if dd = 0 then parse value 12 31 with mm dd .        /* Dec 31st */
      else
        do
          yyyy = yyyy + 1                      /* partial year = mm/dd */
          select
            when yyyy //   4 > 0 then nop
            when yyyy // 100 > 0 then d.2 = 29            /* Leap Year */
            when yyyy // 400 = 0 then d.2 = 29            /* Leap Year */
            otherwise                 nop
          end
          do mm = 1 while dd > d.mm                    /* count months */
            dd = dd - d.mm                   /* while subtracting days */
          end
        end
      return right(yyyy,4,0)right(mm,2,0)right(dd,2,0) /* Date(Sorted) */
    end
  when arg(2) = 'S' then                 /* Convert Date(S) to Date(B) */
    do
      if length(dd) <> 8 then return ''
      parse value dd with 1 yyyy 5 mm 7 dd .
      select
        when yyyy //   4 > 0 then nop
        when yyyy // 100 > 0 then d.2 = 29                /* Leap Year */
        when yyyy // 400 = 0 then d.2 = 29                /* Leap Year */
        otherwise                 nop
      end
      mm = mm + 0                                  /* strip leading 0s */
      if d.mm = 0 then return ''                          /* bad month */
      if dd = 0 | dd > d.mm then return ''                /* bad days  */

      /* What was the Basedate December 31st of the "PREVIOUS" year?   */
      yyyy = yyyy - 1                                 /* previous year */
      if yyyy = 0 then days = 0          /* there was no previous year */
      else days = yyyy * 365 + (yyyy % 4) - (yyyy % 100) + (yyyy % 400)

      /* What 'nth' day of this year is mm/dd? */
      do i = 1 to (mm-1)
        days = days + d.i              /* add days of completed months */
      end
      return days + dd - 1               /* Date(Basedate) = Date(S)-1 */
    end
  otherwise return ''                  /* Error: Arg(2) not "B" or "S" */
end
/*----------------------------------------------------------------------------+
| End of DATECONV FUNCTION code.                                              |
+----------------------------------------------------------------------------*/
