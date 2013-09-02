/* REXX-Programm artanh.CMD  */
   Signal on syntax name artanhMsg

/* Diese Variablen mssen fr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAartanh=Pfd||"NDAartanh.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 400 then
   do
     ND=400
     call charout(NDAartanh) ; Call SysFileDelete NDAartanh
     ret=LineOut(NDAartanh, 400)
     Call Charout,"   Achtung, nur 400 Dezimalstellen bei der Berechnung von  artanh(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 400 ist, wird ND = ND  weitergegeben */
   call charout(NDAartanh) ; Call SysFileDelete NDAartanh
   ret=LineOut(NDAartanh, ND)

   arg x,y  /* y soll "illegale" Komma's im Funktions-Argument aufspren */
   p0p=x*x  /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung       */

   if length(y) > 0 then
   do
     call charout(NDAartanh); Call SysFileDelete NDAartanh
     ret=LineOut(bufMsg, "Im Argument von  artanh(...)  ist mindestens  1  nicht zul„ssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
     /*  damit in den diesbezglichen tempor„ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   Numeric Digits ND+4

   if abs(x) = 1 then
   do
     call charout(NDAartanh); Call SysFileDelete NDAartanh
     ret=LineOut(bufMsg, "Fr  |x| = 1  ist  |artanh(x)| = unendlich groá !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
     /*  damit in den diesbezglichen tempor„ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if abs(x) > 1 then
   do
     call charout(NDAartanh); Call SysFileDelete NDAartanh
     ret=LineOut(bufMsg, "Fr  |x| > 1  hat  artanh(x)  kein reelles Ergebnis !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
     /*  damit in den diesbezglichen tempor„ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if abs(x) >  0.3 then Signal B

A: m=2; g=1; v=1; t=x*x
   do forever
     g=g*t*(m-1)/(m+1)
     v=v+g
     if g/v < 10**(-ND-4) then leave
     m=m+2
   end
   y=x*v
   Signal W

B: y=ln(sqrt((1+x)/(1-x)))

   /* Ausgabe */
W: numeric digits ND
   return(Format(y))

artanhMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAartanh); Call SysFileDelete NDAartanh
     ret=LineOut(bufMsg, "Sie haben in  artanh(...)  kein gltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

