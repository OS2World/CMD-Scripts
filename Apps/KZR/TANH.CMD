/* REXX-Programm tanh.cmd  */

   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   Signal on syntax name tanhMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAtanh=Pfd||"NDAtanh.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 450 then
   do
     ND=450
     call charout(NDAtanh) ; Call SysFileDelete NDAtanh
     ret=LineOut(NDAtanh, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von  tanh(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAtanh) ; Call SysFileDelete NDAtanh
   ret=LineOut(NDAtanh, ND)

   arg x,y  /* y soll "illegale" Komma's im Funktions-Argument aufspÅren */
   p0p=x*x /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAtanh); Call SysFileDelete NDAtanh
     ret=LineOut(bufMsg, "Im Argument von  tanh(...)  ist mindestens  1  nicht zulÑssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   Numeric Digits ND+5

   if x=0 then do; y=0; Signal W; end

   if abs(x) >= 1.0E+9 then
   do
     call charout(NDAtanh); Call SysFileDelete NDAtanh
     ret=LineOut(bufMsg, "     Der absolute Betrag des Argumentes der Funktion tanh(...)",
                         "                     ",
                         "darf nicht grî·er als  1.0E+9  sein.")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

B: ep=exp(x); em=1/ep; y=(ep-em)/(ep+em)

W: numeric digits ND
   return(Format(y))

tanhMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAtanh); Call SysFileDelete NDAtanh
     ret=LineOut(bufMsg, "Sie haben in  tanh(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

