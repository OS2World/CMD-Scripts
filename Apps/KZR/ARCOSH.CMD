/* REXX-Programm arcosh.CMD  */
   Signal on syntax name arcoshMsg

/* Diese Variablen m�ssen f�r jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND �bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAarcosh=Pfd||"NDAarcosh.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 400 then
   do
     ND=400
     call charout(NDAarcosh) ; Call SysFileDelete NDAarcosh
     ret=LineOut(NDAarcosh, 400)
     Call Charout,"   Achtung, nur 400 Dezimalstellen bei der Berechnung von  arcosh(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 400 ist, wird ND = ND  weitergegeben */
   call charout(NDAarcosh) ; Call SysFileDelete NDAarcosh
   ret=LineOut(NDAarcosh, ND)

   arg x,y  /* y soll "illegale" Komma's im Funktions-Argument aufsp�ren */
   p0p=x*x  /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAarcosh); Call SysFileDelete NDAarcosh
     ret=LineOut(bufMsg, "Im Argument von  arcosh(...)  ist mindestens  1  nicht zul�ssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
     /*  damit in den diesbez�glichen tempor�ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end

   Numeric Digits ND+7

   if x < 1 then
   do
     call charout(NDAarcosh); Call SysFileDelete NDAarcosh
     ret=LineOut(bufMsg, "Die Funktion  arcosh(...)  hat f�r Werte  x < 1  keine reelles Ergebnis.")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
     /*  damit in den diesbez�glichen tempor�ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end

   y=ln(x+sqrt(x*x-1))

   /* Ausgabe */
W: numeric digits ND
   return(Format(y))

arcoshMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAarcosh); Call SysFileDelete NDAarcosh
     ret=LineOut(bufMsg, "Sie haben in  arcosh(...)  kein g�ltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
  /*  damit in den diesbez�glichen tempor�ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end

