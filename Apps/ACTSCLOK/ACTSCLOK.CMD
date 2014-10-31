/* REXX */
/********************************************************************************/
/*                                                                              */
/* Program: ACTSCLOK.CMD - set system date and time from Automatic              */
/*              Computer Time Service (ACTS) maintained by the                  */
/*              National Institute of Standards                                 */
/*                                                                              */
/* Version: 1.0 - October, 1992                                                 */
/*                                                                              */
/* Author:  Chuck Giglia, Delaware Valley OS/2 Users Group                      */
/*          1129 Webster Drive, Wilmington, Delaware 19803                      */
/*          Compuserve: 72317,3704                                              */
/*                                                                              */
/* Acknowledgements:                                                            */
/*          Many thanks to Jerry am Ende of the Delaware Valley OS/2            */
/*          Users Group for his enthusiasm toward REXX which piqued             */
/*          my interest in improving on his TIMESET.CMD routine.                */
/*          Also, I appreciate the design ideas I got from John                 */
/*          Deurbrouck in the October 27, 1992 issue of PC Magazine.            */
/*          His program was a bit flashier, but it was written for              */
/*          Windows in C and I didn't think this problem needed a               */
/*          graphical solution.                                                 */
/*                                                                              */
/*          I hope you can use this routine to your advantage, but I            */
/*          provide no warrantees nor do I guarantee that it performs           */
/*          any useful function.                                                */
/*                                                                              */
/*          Your feedback or ideas for improvement are appreciated.             */
/*                                                                              */
/* Product Description                                                          */
/*      ACTSCLOK.CMD is an OS/2 REXX command file which sets the System Date    */
/*      and Time of the invoking computer to the current date and time from     */
/*      the Automated Computer Time Service (ACTS) maintained by the National   */
/*      Institute of Standards. The ACTS returns Greenwich Mean Time (GMT),     */
/*      so ACTSCLOK.CMD provides for handling a positive or negative offset     */
/*      from GMT and allows the user to enable or disable Daylight Saving       */
/*      Time (DST) adjustment.                                                  */
/*                                                                              */
/* Usage is:                                                                    */
/*       ACTSCLOK <offset> <dstIndicator> <comPort> <PhoneNumber> <dialPrefix>  */
/*              <offset>       = Minutes from GMT (i.e. EST = -300).            */
/*                              The default is -300                             */
/*              <dstIndicator> = Adjust for DST? (Y or N). The default is Y     */
/*              <comPort>      = COM port to use (COM1, COM2, etc.). The        */
/*                              default is COM1                                 */
/*              <PhoneNumber>  = Area code and phone number of the ACTS.        */
/*                              The default is 303-494-4774.                    */
/*              <dialPrefix>   = Any dialing prefixes or codes required to dial */
/*                              the ACTS. The default is 1, (the comma causes   */
/*                              the modem to pause briefly before continuing)   */
/*                                                                              */
/*      Individual command line arguments may be forced to use the default by   */
/*      coding an exclamation point (!) in that argument's position. For example*/
/*      to accept all defaults except the COM port and dialling prefix, use:    */
/*                                                                              */
/*                      ACTSCLOK ! ! COM2 ! 9,                                  */
/*                                                                              */
/*      This example will set the system clock to 300 minutes before GMT during */
/*      Standard Time or 240 minutes before GMT during Daylight Saving Time.    */
/*      The system will use COM2 to dial 9,303-494-4774 to connect to the ACTS. */
/*                                                                              */
/********************************************************************************/

/* Initialize Defaults and Control Variables and Perform Startup Processing     */


CALL getDateFormat              /* determine the system date format */

dDialPrefix = "1,"              /* default dialing prefix   */

dPhoneNumber = "303-494-4774"   /* default telephone number */

dOffset = -300                  /* default minutes from GMT.*/
                                /* This is a signed whole   */
                                /* number (-300 is 5 hours  */
                                /* earlier than Greenwich   */
                                /* Mean Time - i.e. Eastern */
                                /* Standard Time in the USA)*/

dDSTIndicator = "Y"             /* default DST indicator.   */
                                /* "Y" means adjust for DST */
                                /* "N" means don't adjust   */

dCOMPort = "COM1"               /* defualt COM port         */

crLf = X2C("0D0A")

busyRetrys = 10                 /* number of times to redial*/
                                /* if busy or no answer     */

attemptNum = 1                  /* dial attempt counter     */

argTester = ""                  /* used to determine if     */
                                /* there are any arguments  */

connectLimit = 30               /* number of seconds to wait*/
                                /* for ACTS to answer       */

minutesPerDay = 24 * 60         /* used to determine if we  */
                                /* have adjusted the time   */
                                /* over a day boundary      */

daysPerMonth.1 = 31             /* load array of number of  */
daysPerMonth.2 = 28             /* days in each month       */
daysPerMonth.3 = 31             
daysPerMonth.4 = 30             /* NOTE: the value for      */
daysPerMonth.5 = 31             /* February will be adjusted*/
daysPerMonth.6 = 30             /* later in the logic if    */
daysPerMonth.7 = 31             /* this is a leap year      */
daysPerMonth.8 = 31
daysPerMonth.9 = 30
daysPerMonth.10 = 31
daysPerMonth.11 = 30
daysPerMonth.12 = 31

call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'

/* Get and Process any User-Supplied Arguements                                 */

PARSE UPPER ARG uOffset uDSTIndicator uCOMPort uPhoneNumber uDialPrefix

argTester = uOffset||uDSTIndicator||uCOMPort||uPhoneNumber||uDialPrefix

IF argTester == "?" | argTester == "" then do

     SAY " "
     SAY "ACTSCLOK.CMD is an OS/2 REXX command file which sets the System Date "
     SAY "     and Time of the invoking computer to the current date and time from "
     SAY "     the Automated Computer Time Service (ACTS) maintained by the National "
     SAY "     Institute of Standards. The ACTS returns Greenwich Mean Time (GMT), "
     SAY "     so ACTSCLOK.CMD provides for handling a positive or negative offset "
     SAY "     from GMT and allows the user to enable or disable Daylight Saving "
     SAY "     Time (DST) adjustment."
     SAY " "
     "@pause"
     SAY " "
     SAY "Usage is: ACTSCLOK <offset> <dstIndicator> <comPort> <PhoneNumber> <dialPrefix>"
     SAY "     <offset>       = Minutes from GMT (i.e. EST = -300). The default is -300"
     SAY "     <dstIndicator> = Adjust for DST? (Y or N). The default is Y"
     SAY "     <comPort>      = COM port to use (COM1, COM2, etc.). The default is COM1"
     SAY "     <PhoneNumber>  = Area code and phone number of the ACTS. The default"
     SAY "                         is 303-494-4774."
     SAY "     <dialPrefix>   = Any dialing prefixes or codes required to dial"
     SAY "                         the ACTS. The default is 1, (the comma"
     SAY "                         causes the modem to pause briefly before "
     SAY "                         continuing)"
     SAY " "
     "@pause"
     SAY " "
     SAY "      Individual command line arguments may be forced to use the default by "
     SAY "      coding an exclamation point (!) in that argument's position. For example "
     SAY "      to accept all defaults except the COM port and dialling prefix, use: "
     SAY " "
     SAY "                      ACTSCLOK ! ! COM2 ! 9, "
     SAY " "
     SAY "      This example will set the system clock to 300 minutes before GMT during "
     SAY "      Standard Time or 240 minutes before GMT during Daylight Saving Time. "
     SAY "      The system will use COM2 to dial 9,303-494-4774 to connect to the ACTS. "
     SAY " "
     "@pause"
     SAY " "
     exit
     
end  /* Do */

IF uOffset == "" | uOffset == "!" then
     offset = dOffset
else
     offset = uOffset

IF uDSTIndicator == "" | uDSTIndicator == "!" then
     dstIndicator = dDSTIndicator
else
     dstIndicator = uDSTIndicator

IF uCOMPort == "" | uCOMPort == "!" then
     comPort = dCOMPort
else
     comPort = uCOMPort

IF uPhoneNumber == "" | uPhoneNumber == "!" then
     phoneNumber = dPhoneNumber
else
     phoneNumber = uPhoneNumber

IF uDialPrefix == "" | uDialPrefix == "!" then
     dialPrefix = dDialPrefix
else
     dialPrefix = uDialPrefix

dialSequence = dialPrefix||phoneNumber

/* Open the COM Port and Set the Communications Parameters                      */

state = STREAM(comPort, "C", "OPEN")
"@MODE" comPort":1200,E,7,1 > NUL"

needToRetry = "Y"                       /* make sure we enter loop at least once */
DO WHILE attemptNum <= busyRetrys & needToRetry = "Y"

        SAY " "
        SAY " "
        SAY "Preparing to dial" dialSequence "on" comPort
        SAY "GMT Offset is" offset "minutes"
        SAY "DST Switch is" dstIndicator
        SAY " "
        SAY "Dialing Attempt Number" attemptNum
        SAY " "

        /* Dial the ACTS                                                        */

        SAY "Dialing . . ."
        SAY " "

        startTimer = time('R')          /* reset the elapsed time clock */
        CALL LINEOUT comPort, "ATDT"dialSequence||crLf

        /* Bypass first line of help information by grabbing                    */
        /* the first couple lines of output from the ACTS                       */
        /* and throwing them away                                               */

        needToRetry = "N"
        dataBuffer = ""
        DO WHILE POS("*", dataBuffer) == 0 & POS("#", dataBuffer) == 0

             dataBuffer = dataBuffer||CHARIN(comPort)
             IF POS("BUSY", dataBuffer) <> 0 then do    /* Handle busy condition */
                SAY "Busy!"
                needToRetry = "Y"
             end  /* Do */

             if time('E') > connectLimit then do        /* Handle no answer condition */
                say "No Response"
                needToRetry = "Y"
             end  /* Do */

             if needToRetry = "Y" then do
                call Hangup
                SAY " "
                attemptNum = attemptNum + 1
                say "Waiting . . ."
                SAY " "
                call SysSleep 5
                LEAVE
             end  /* Do */

        END /* DO WHILE POS("*", dataBuffer) == 0 & POS("#", dataBuffer) == 0 */

END /* DO WHILE attemptNum <= busyRetrys & needToRetry = "Y" */

IF attemptNum > busyRetrys then do
        SAY " "
        SAY "No response from ACTS after" busyRetrys "attempts"
        SAY "Please try again later"
        SAY " "
        EXIT
END

dataBuffer = ""
DO WHILE POS("UTC", dataBuffer) == 0

     dataBuffer = dataBuffer||CHARIN(comPort)

END

Call Hangup

state = STREAM(comPort, "C", "CLOSE")

PARSE VAR dataBuffer . ymdDate timeOfDay dstStatus .

/* Interpret the date retrieved from the ACTS */

currentYear = LEFT(ymdDate, 2)
currentMonth = SUBSTR(ymdDate, 4, 2)
currentDay = RIGHT(ymdDate, 2)

if currentYear // 4 == 0 then             /* check for leap year */
        daysPerMonth.2 = 29

/* Determine if we should adjust for Daylight Savings Time (DST)                */
/*   The DST indicator returned in the data will be 00 if we are                */
/*   on Standard Time or 99 to 51 if we are on Standard Time, but               */
/*   approaching DST.                                                           */
/*   This indicator will be 50 if we are on DST or 49 to 01 if we               */
/*   are on DST but approaching Standard Time.                                  */

IF dstIndicator == "Y" then
        IF dstStatus <= "50" & dstStatus >= "01" then    /* we're on DST */
                offset = offset + 60

/* Interpret then convert the time to minutes to simplify adjustment            */

currentHours = LEFT(timeOfDay, 2)
currentMinutes = SUBSTR(timeOfDay, 4, 2)
currentSeconds = RIGHT(timeOfDay, 2)

timeInMinutes = (currentHours * 60) + currentMinutes

/* Now, adjust the time and extract the date and time in a form suitable for    */
/* setting the system clock                                                     */

adjustedTime = timeInMinutes + offset

/* make adjustments if we have crossed a date boundary (i.e. crossed into       */
/* yesterday or into tomorrow)                                                  */

select          

   when adjustedTime < 0 then do                  /* we backed into yesterday   */
        adjustedTime = minutesPerDay + adjustedTime
        currentDay = currentDay - 1
        IF currentDay < 1 then do
                currentMonth = currentMonth - 1
                IF currentMonth < 1 then do
                    currentYear = currentYear - 1
                    currentMonth = 12 + currentMonth
                end    /* do */
                currentDay = daysPerMonth.currentMonth
        end    /* do */
   end    /* when do */

   when adjustedTime > minutesPerDay then do    /* we crossed into tomorrow */
        adjustedTime = adjustedTime - minutesPerDay
        currentDay = currentDay + 1
        if currentDay > daysPerMonth.currentMonth then do
                currentDay = currentDay - daysPerMonth.currentMonth
                currentMonth = currentMonth + 1
        end    /* do */
        if currentMonth > 12 then do
                currentMonth = currentMonth - 12
                currentYear = currentYear + 1
        end    /* do */
   end    /* when do */

   otherwise                                    /* we're still on today */
        nop

end  /* select */

currentHours = adjustedTime % 60
currentMinutes = adjustedTime // 60

/* Finally, Set the system date and time on this PC                             */

"@TIME" currentHours":"currentMinutes":"currentSeconds

select
   when monthPosition = 1 then               /* mm-dd-yy format */
     "@DATE" currentMonth"-"currentDay"-"currentYear
   when dayPosition = 1 then                 /* dd-mm-yy format */
     "@DATE" "currentDay"-currentMonth"-"currentYear
   when yearPosition = 1 then                /* yy-mm-dd format */
     "@DATE" currentYear"-"currentMonth"-"currentDay
   otherwise                                 /* default to US format */
     "@DATE" currentMonth"-"currentDay"-"currentYear
end  /* select */

SAY " "
SAY " "
SAY "New Time" TIME() "and Date" DATE()
SAY " "
SAY " "

exit

/********************************************************************************/
/* Subroutines Follow                                                           */
/********************************************************************************/

/* Subroutine Hangup - Hang up the telephone line to disconnect from the ACTS   */

Hangup:

     CALL LINEOUT comPort, crLf
     CALL LINEOUT comPort, crLf
     CALL LINEOUT comPort, "ATH"||crLf

Return

/* Subroutine getDateFormat - determine which date format has been set via      */
/*   the COUNTRY.SYS setting in the CONFIG.SYS file (i.e. mm-dd-yy, yy-mm-dd or */
/*   dd-mm-yy).                                                                 */

getDateFormat:

     "@if exist rxenter.dat erase rxenter.dat"

     CALL CHAROUT "rxenter.dat",x2c('0d')
     call lineout "rxenter.dat"

     "@date < rxenter.dat | RXQUEUE"

     DO WHILE QUEUED() > 0
        parse upper pull . '(' dFormat ')' .
     END

     say "Date Format is:" dFormat

     monthPosition = POS(dFormat, "MM")
     yearPosition  = POS(dFormat, "YY")
     dayPosition   = POS(dFormat, "DD")

     "@if exist rxenter.dat erase rxenter.dat"

RETURN

