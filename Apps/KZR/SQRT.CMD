/* REXX-Programm sqrt.CMD */
   signal on syntax name sqrtMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

/* An dieser Stelle mu·  "bufMsg"  gelîscht werden, damit dann,   */
/* die Datei  "Meldung.DAT"  leer ist, diese auch leer bleibt.    */
   call charout(bufMsg)
   Call SysFileDelete bufMsg

   parse arg x,y
   p0p=x*x /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     ret=LineOut(bufMsg, "Im Argument von  sqrt(...)  ist mindestens  1  nicht zulÑssiges Komma !")
     EXIT
   end

   if (x=0) then return(0)
   if (x=1) then return(1)

   if (x<0) then
   do
     /* An dieser Stelle mu·  "bufMsg"  gelîscht werden, damit Meldungen   */
     /* nicht aneinandergehÑngt werden.                                    */
     call charout(bufMsg)
     Call SysFileDelete bufMsg
     ret=LineOut(bufMsg, "Die zweite Wurzel aus " x"  ist eine komplexe Zahl !")
     EXIT
   end

   if x < 1.0E-10000 | x > 1.0E+10000 then
   do
     /* An dieser Stelle mu·  "bufMsg"  gelîscht werden, damit Meldungen   */
     /* nicht aneinandergehÑngt werden.                                    */
     call charout(bufMsg)
     Call SysFileDelete bufMsg
     call charout(bufND)
     Call SysFileDelete bufND
     ret=LineOut(bufMsg, "     Das Argument der Funktion sqrt(...)",
                         "                                           ",
                         "sollte entweder gleich  0                                                      ",
                         "oder grî·er als  1.0E-10000  und kleiner als  1.0E+10000  sein.")
     EXIT
   end

   NUMERIC DIGITS ND+12

   if x<1 then SIGNAL A
   else
   do
     n=0
     do while x>100
       x=x/100
       n=n+1
     end
   end
   SIGNAL B

   A:
     n=0
     do while x<(0.01)
       x=x*100
       n=n-1
     end
     SIGNAL B

   B:
     y=1
     t=x/y
     do while abs(y-t) > y*10**(-ND-7)
       y=(y+t)/2
       t=x/y
     end

   u=y*10**n
   numeric digits ND
   return(Format(u))


sqrtMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     /* An dieser Stelle mu·  "bufMsg"  gelîscht werden, damit Meldungen   */
     /* nicht aneinandergehÑngt werden.                                    */
     call charout(bufMsg)
     Call SysFileDelete bufMsg
     call charout(bufND)
     Call SysFileDelete bufND
     ret=LineOut(bufMsg, "Sie haben in  sqrt(...)  kein gÅltiges Argument eingegeben !")
   end

