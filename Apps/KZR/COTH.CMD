/* REXX-Programm coth.cmd  */
   Signal on syntax name cothMsg

/* Diese Variablen m�ssen f�r jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND �bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAcoth=Pfd||"NDAcoth.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 450 then
   do
     ND=450
     call charout(NDAcoth) ; Call SysFileDelete NDAcoth
     ret=LineOut(NDAcoth, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von  coth(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAcoth) ; Call SysFileDelete NDAcoth
   ret=LineOut(NDAcoth, ND)

   arg x,y  /* y soll "illegale" Komma's im Funktions-Argument aufsp�ren */
   p0p=x*x /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAcoth); Call SysFileDelete NDAcoth
     ret=LineOut(bufMsg, "Im Argument von  coth(...)  ist mindestens  1  nicht zul�ssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
     /*  damit in den diesbez�glichen tempor�ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end

   Numeric Digits ND+5

   if x = 0 then
   do
     call charout(NDAcoth); Call SysFileDelete NDAcoth
     ret=LineOut(bufMsg, "     Die Funktion coth(...) ist f�r den Wert x=0 nicht definiert.")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
  /*  damit in den diesbez�glichen tempor�ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end

   if abs(x) >= 1.0E+9 then
   do
     call charout(NDAcoth); Call SysFileDelete NDAcoth
     ret=LineOut(bufMsg, "     Der absolute Betrag des Argumentes der Funktion coth(...)",
                         "                     ",
                         "darf nicht gr��er als  1.0E+9  sein.")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
  /*  damit in den diesbez�glichen tempor�ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end


B: ep=exp(x); em=1/ep; y=(ep+em)/(ep-em)

W: numeric digits ND
   return(Format(y))

cothMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAcoth); Call SysFileDelete NDAcoth
     ret=LineOut(bufMsg, "Sie haben in  coth(...)  kein g�ltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel�scht, */
  /*  damit in den diesbez�glichen tempor�ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh�ngt werden.               */
     EXIT
   end

