/*  REXX-Programm  pot(x,y) fÅr die Funktion  x hoch y */
   signal on syntax name potMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDApot=Pfd||"NDApot.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 400 then
   do
     ND=400
     call charout(NDApot) ; Call SysFileDelete NDApot
     ret=LineOut(NDApot, 400)
     Call Charout,"   Achtung, nur 400 Dezimalstellen bei der Berechnung von  pot(.. , ..)"
     say
     Beep(444, 200); Beep(628, 300)  /* Hier kein EXIT ! */
   end

  /* Wenn ND <= 400 ist, wird ND = ND  weitergegeben */
   call charout(NDApot) ; Call SysFileDelete NDApot
   ret=LineOut(NDApot, ND)

   NUMERIC DIGITS ND+6

   arg xx,y,s

   if length(s) > 0 then
   do
     call charout(NDApot) ; Call SysFileDelete NDApot
     ret=LineOut(bufMsg, "Im Argument von  pot(.. , ..)  ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if xx=0 & y=0 then do u=1; SIGNAL W; end
   if xx=0 & y=1 then do u=0; SIGNAL W; end
   if xx=1 & y=0 then do u=1; SIGNAL W; end

   /* Wenn y geradzahlig ist, xx**y verwenden. */
   if abs(y)//1 = 0 then do; u=xx**y; Signal W; end

   /* y ist nicht ganzzahlig */
   if xx < 0 & abs(y)//1 <> 0 then
   do
     call charout(NDApot) ; Call SysFileDelete NDApot
     ret=LineOut(bufMsg, "Die Potenz " xx"  hoch  "y"  ist keine reelle Zahl !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   /* Wenn xx > 0 ist. */
   vz=+1
   /* Wenn xx < 0 ist. */
   if xx < 0 then
   do
     if abs(y)//2=0 then vz=+1; else vz=-1
   end

   x=abs(xx)
   u=vz*exp(y*ln(x))

W: NUMERIC DIGITS ND
   return(Format(u))

potMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDApot) ; Call SysFileDelete NDApot
     ret=LineOut(bufMsg, "Sie haben in  pot(.. , ..)  keine gÅltigen Argumente eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

