/* REXX-Programm sinh.cmd  */
   Signal on syntax name sinhMsg 

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAsinh=Pfd||"NDAsinh.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 450 then
   do
     ND=450
     call charout(NDAsinh) ; Call SysFileDelete NDAsinh
     ret=LineOut(NDAsinh, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von  sinh(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAsinh) ; Call SysFileDelete NDAsinh
   ret=LineOut(NDAsinh, ND)

   arg x,y /* y soll "illegale" Komma's im Funktions-Argument aufspÅren */
   p0p=x*x /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAsinh); Call SysFileDelete NDAsinh  /* hier Ñndern */
     ret=LineOut(bufMsg, "Im Argument von  sinh(...)  ist mindestens  1  nicht zulÑssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   Numeric Digits ND+5

   if x=0 then do; y=0; Signal W; end

   if abs(x) >= 1.0E+9 then
   do
     call charout(NDAsinh); Call SysFileDelete NDAsinh
     ret=LineOut(bufMsg, "     Der absolute Betrag des Argumentes der Funktion sinh(...)",
                         "                     ",
                         "darf nicht grî·er als  1.0E+9  sein.")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if abs(x) <  0.1 then SIGNAL A
   if abs(x) >= 0.1 then SIGNAL B

A: u=1; v=1; m=2; z=x*x
   do while (abs(u/v) > 10**(-ND-7))
     g=z/(m*(m+1)); u=u*g; v=v+u; m=m+2; end
   y=x*v; SIGNAL W

B: ep=exp(x); em=1/ep; y=(ep-em)/2

W: numeric digits ND
   return(Format(y))

sinhMsg:  /* hier Ñndern */
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAsinh); Call SysFileDelete NDAsinh  /* hier Ñndern */
     ret=LineOut(bufMsg, "Sie haben in  sinh(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

