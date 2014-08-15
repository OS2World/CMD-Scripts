/* f2dtest - REXX program for testing the age of a specified file. */
/* RRC 95-10-30 Original release. */

call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs
call SysLoadFuncs

SemName = ARG(1)
IF SemName = '' THEN DO
     say 'Requires a filename parameter'
     EXIT
END
FileDate = STREAM( SemName, 'C', 'query datetime' )
Now = Time('S')/86400
Today = Date('B') || SUBSTR(Now,2)
NumericDate = File2Dat(FileDate)
Age = Today - NumericDate
AgeInt = Age % 1
AgeFrac = Age - AgeInt

say 'File date is 'FileDate
say 'File2Dat interprets this as: 'NumericDate
say 'Today is 'Today
say 'Thus the file is 'Age' days old'
say 'Interpreted by FRACT2TIME, this is 'AgeInt' days -- 'FRACT2TIME(AgeFrac)' (h:m:s) old'

exit


/* calculate time from fraction */
FRACT2TIME: PROCEDURE                   /* calculate time from given value */
    /* hours    = 24      =   24           */
    /* minutes  = 1440    =   24 * 60      */
    /* seconds  = 86400   =   24 * 60 * 60 */

    tmp = arg(1) + 0.0000001            /* account for possible precision error */

    hours   = (tmp * 24) % 1
    minutes = (tmp * 1440 - hours * 60) % 1
    seconds = (tmp * 86400 - hours * 3600 - minutes * 60) % 1

    RETURN RIGHT(hours,2,'0')':'RIGHT(minutes,2,'0')':'RIGHT(seconds,2,'0')

/* end of FRACT2TIME */
