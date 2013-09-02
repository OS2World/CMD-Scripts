/* REXX-Programm arsinh.CMD  */
   Signal on syntax name arsinhMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAarsinh=Pfd||"NDAarsinh.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 400 then
   do
     ND=400
     call charout(NDAarsinh) ; Call SysFileDelete NDAarsinh
     ret=LineOut(NDAarsinh, 400)
     Call Charout,"   Achtung, nur 400 Dezimalstellen bei der Berechnung von  arsinh(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 400 ist, wird ND = ND  weitergegeben */
   call charout(NDAarsinh) ; Call SysFileDelete NDAarsinh
   ret=LineOut(NDAarsinh, ND)

   arg x,y  /* y soll "illegale" Komma's im Funktions-Argument aufspÅren */
   p0p=x*x  /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAarsinh); Call SysFileDelete NDAarsinh
     ret=LineOut(bufMsg, "Im Argument von  arsinh(...)  ist mindestens  1  nicht zulÑssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   Numeric Digits ND+7

   if abs(x) >  0.35 then Signal B

A: m=2; g=1; v=1; t=x*x
   do forever
     g=-g*t*(m-1)*(m-1)/(m*(m+1))
     v=v+g
     if abs(g/v) < 10**(-ND-4) then leave
     m=m+2
   end
   y=x*v
   Signal W

B: y=ln(x+sqrt(x*x+1))

   /* Ausgabe */
W: numeric digits ND
   return(Format(y))

arsinhMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAarsinh); Call SysFileDelete NDAarsinh
     ret=LineOut(bufMsg, "Sie haben in  arsinh(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

