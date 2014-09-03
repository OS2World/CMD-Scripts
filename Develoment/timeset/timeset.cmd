/* REXX */
/* Procedure to call Naval Observatory and set System Time  */
/* Author: Jerry am Ende, Compuserve 73237,131              */
/* Date  : 08/09/92                                         */
/*                                                          */
/* Notes: Change Year to Current Year                       */
/*        Change offset for Daylight Savings Time           */
/*        This version is setup for COM2 change to COM1 if  */
/*          needed                                          */
/*                                                          */

parse arg year offset PhoneNumber ComPort

"CLS"                   /* Clear Screen */

if year = "" then do
   say "Usage is: TIMESET <year> <offset> <PhoneNumber> <ComPort>"
   say "          <year>        = 2 digit year (e.g. 1992 = 92)"
   say "          <offset>      = Hours from Greenwich Mean time. Eastern"
   say "                           Daylight Time = 4"
   say "          <PhoneNumber> = Phone Number of Naval Observatory"
   say "                           1-202-653-0351 is default"
   say "          <ComPort>     = ComPort where modem is connected"
   say "                           COM1 is default"
   return
   end

if offset == "" then                /* Set Defaults */
   offset = 4

if PhoneNumber == "" then
   PhoneNumber = "1-202-653-0351"

if ComPort == "" then
   ComPort = "COM1"

modays.1 = 31           /* initialize days in each month */
modays.2 = 28
modays.3 = 31
modays.4 = 30
modays.5 = 31
modays.6 = 30
modays.7 = 31
modays.8 = 31
modays.9 = 30
modays.10 = 31
modays.11 = 30
modays.12 = 31

if ((year // 4) == 0) then    /* Check for Leap Year */
   modays.2 = 29

CrLf = X2C("0D0A")

State = STREAM(ComPort,"C","OPEN")
"@MODE" ComPort":1200,E,7,1 > NUL"

CALL LINEOUT ComPort, "ATX3DT"PhoneNumber||CrLf    /* Dial In */
StartTime = time('E')
ReturnStuff = ""
DO WHILE pos('UTC',ReturnStuff) == 0          /* UTC is end of String */
  ReturnStuff = ReturnStuff||CHARIN(ComPort)
  if (pos('BUSY',ReturnStuff) <> 0) then do   /* Check for Busy */
     CALL LINEOUT ComPort,"ATH"CrLf            /* Hang Up */
     State = STREAM(ComPort,"C","CLOSE")
     Say "Line Busy, Please Try Again..."
     return
     end
  if ((time('E') - StartTime) > 45) then do   /* Check for Timeout */
     CALL LINEOUT ComPort,"ATH"CrLf            /* Hang Up */
     State = STREAM(ComPort,"C","CLOSE")
     Say "Sorry, Timeout..."
     return
     end
END

NavalString = Right(ReturnStuff,20)    /* Retrieve the time/date string */

CALL LINEOUT ComPort,"ATH"CrLf          /* Hang Up */

State = STREAM(ComPort,"C","CLOSE")
parse var NavalString . doy time .

/* Convert time to HH:MM:SS */
hour = right(left(time,2) - offset,2,'0')
if (hour < 0) then do
   hour = hour + 24
   doy = doy - 1
   end
minute = right(substr(time,3,2),2,'0')
second = right(substr(time,5,2),2,'0')
TimeString = hour || ':' || minute || ':' || second

/* Convert doy to MM-DD-YY format */
month = 0
SumDays = 0
do while (SumDays < doy)
   month = month + 1
   SumDays = SumDays + modays.month
end
SumDays = SumDays - modays.month
Day = doy - Sumdays
DateString = right(Month,2,'0') || '-' || right(Day,2,'0') || '-' || Year

OldTime = Time()
OldDate = Date()

/* Send Date & Time to OS2 */
"@DATE" DateString
"@TIME" TimeString

Say "Date & Time was             " OldDate OLdTime
Say "Date & Time has been Set to:" Date() Time()

return
