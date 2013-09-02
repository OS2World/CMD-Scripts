/*  REXX-Programm erf(x) */
   signal on syntax name erfMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAerf=Pfd||"NDAerf.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)
   NDa=ND

   if ND > 50 then
   do
     ND=50
     call charout(NDAerf) ; Call SysFileDelete NDAerf
     ret=LineOut(NDAerf, 50)
     Call Charout,"   Achtung, nur  50 Dezimalstellen bei der Berechnung von  erf(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 50 ist, wird ND = ND  weitergegeben */
   call charout(NDAerf) ; Call SysFileDelete NDAerf
   ret=LineOut(NDAerf, ND)

   numeric digits 125
   /*    1/sqrt(Pi)     */
   c2=0.5641895835477562869480794515607725858440506293289988568440857217106424684414934144867436602021073634430283479063617073516899
   Numeric Digits ND+10

   arg x,y
   z=x*x /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     call charout(NDAerf) ; Call SysFileDelete NDAerf
     ret=LineOut(bufMsg, "Im Argument von  erf(...)  ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if x>=0 then sgn=1; else sgn=-1
   x=abs(x)
   if 0    <= x then if x < 4.5  then SIGNAL A
   if 4.5  <= x then if x < 10.5 then SIGNAL B
   if 10.5 <= x then do y=1; SIGNAL C; end

A: n=1; u=1; v=1;
   do while u/v>10**(-ND-7)
   g=2*z/(2*n+1); u=u*g; v=v+u; n=n+1; end
   y=2*c2*x*v*exp(-z); Signal C

B:
   v10=40/x
   v9 =36/(x+36.5/(x+37/(x+37.5/(x+38/(x+38.5/(x+39/(x+39.5/(x+v10))))))))
   v8 =32/(x+32.5/(x+33/(x+33.5/(x+34/(x+34.5/(x+35/(x+35.5/(x+v9 ))))))))
   v7 =28/(x+28.5/(x+29/(x+29.5/(x+30/(x+30.5/(x+31/(x+31.5/(x+v8 ))))))))
   v6 =24/(x+24.5/(x+25/(x+25.5/(x+26/(x+26.5/(x+27/(x+27.5/(x+v7 ))))))))
   v5 =20/(x+20.5/(x+21/(x+21.5/(x+22/(x+22.5/(x+23/(x+23.5/(x+v6 ))))))))
   v4 =16/(x+16.5/(x+17/(x+17.5/(x+18/(x+18.5/(x+19/(x+19.5/(x+v5 ))))))))
   v3 =12/(x+12.5/(x+13/(x+13.5/(x+14/(x+14.5/(x+15/(x+15.5/(x+v4 ))))))))
   v2 = 8/(x+ 8.5/(x+ 9/(x+ 9.5/(x+10/(x+10.5/(x+11/(x+11.5/(x+v3 ))))))))
   v1 = 4/(x+ 4.5/(x+ 5/(x+ 5.5/(x+ 6/(x+ 6.5/(x+ 7/(x+ 7.5/(x+v2 ))))))))
   v  = 1/(x+ 0.5/(x+ 1/(x+ 1.5/(x+ 2/(x+ 2.5/(x+ 3/(x+ 3.5/(x+v1 ))))))))

   y=1-c2*v*exp(-z);

C: u=sgn*y
   numeric digits ND
   return(Format(u))

erfMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAerf) ; Call SysFileDelete NDAerf
     ret=LineOut(bufMsg, "Sie haben in  erf(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

