/* REXX-Funktion exp.CMD */
   signal on syntax name expMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   bufND =Pfd||"NDZahl.DAT"
   NDAexp=Pfd||"NDAexp.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   NUMERIC DIGITS ND+10

/* An dieser Stelle mu·  "bufMsg"  gelîscht werden, damit dann,   */
/* die Datei  "Meldung.DAT"  leer ist, diese auch leer bleibt.    */
   call charout(bufMsg)
   Call SysFileDelete bufMsg

   parse UPPER arg x,y
   p0p=x*x /* Diese Anweisung provoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     call charout(NDAexp); Call SysFileDelete NDAexp
     ret=LineOut(bufMsg, "Im Argument von  exp(...)  ist mindestens 1 nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if x=0 then do; u=1; signal W; end

   if abs(x) >= 1.0E+9 then
   do
     call charout(NDAexp); Call SysFileDelete NDAexp
     ret=LineOut(bufMsg, "     Der absolute Betrag des Argumentes der Funktion exp(...)",
                         "                      ",
                         "darf nicht grî·er als  1.0E+9  sein.")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   xg=trunc(x)
   xr=x-xg
   yxg=efunk(1,ND)
   yxr=efunk(xr,ND)
   u=yxr*yxg**xg

W: numeric digits ND
   return(Format(u))

EXIT

efunk:
   Procedure
   arg x, ND
   g=1; n=1; y=1
   do forever
     g=g*x/n
     if abs(g/y) < 10**(-ND-10) then leave
     y=y+g
     n=n+1
   end
   return(y)

expMsg:
   sf=ErrorText(RC)
   if  Pos("Arithmetic overflow", sf) > 0 | Pos("Invalid whole", sf) >0 then
   do
     call charout(NDAexp); Call SysFileDelete NDAexp
     ret=LineOut(bufMsg, "Es mÅssen zu gro·e Zahlenwerte verarbeitet werden !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAexp); Call SysFileDelete NDAexp
     ret=LineOut(bufMsg, "Sie haben in  exp(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

