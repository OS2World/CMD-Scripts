/* REXX-Programm arcoth.CMD  */
   Signal on syntax name arcothMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAarcoth=Pfd||"NDAarcoth.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 400 then
   do
     ND=400
     call charout(NDAarcoth) ; Call SysFileDelete NDAarcoth
     ret=LineOut(NDAarcoth, 400)
     Call Charout,"   Achtung, nur 400 Dezimalstellen bei der Berechnung von  arcoth(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 400 ist, wird ND = ND  weitergegeben */
   call charout(NDAarcoth) ; Call SysFileDelete NDAarcoth
   ret=LineOut(NDAartanh, ND)

   arg x,y  /* y soll "illegale" Komma's im Funktions-Argument aufspÅren */
   p0p=x*x  /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAarcoth); Call SysFileDelete NDAarcoth
     ret=LineOut(bufMsg, "Im Argument von  arcoth(...)  ist mindestens  1  nicht zulÑssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   Numeric Digits ND+7

   if abs(x) = 1 then
   do
     call charout(NDAarcoth); Call SysFileDelete NDAarcoth
     ret=LineOut(bufMsg, "FÅr  |x| = 1  ist  |arcoth(x)| = unendlich gro· !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if abs(x) < 1 then
   do
     call charout(NDAarcoth); Call SysFileDelete NDAarcoth
     ret=LineOut(bufMsg, "FÅr  |x| < 1  hat  arcoth(x)  kein reelles Ergebnis !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   y=ln(sqrt((x+1)/(x-1)))

   /* Ausgabe */
W: numeric digits ND
   return(Format(y))

arcothMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAarcoth); Call SysFileDelete NDAarcoth
     ret=LineOut(bufMsg, "Sie haben in  arcoth(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

