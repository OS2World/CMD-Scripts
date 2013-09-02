/*  REXX-Programm phi.cmd  */
   signal on syntax name phiMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAphi=Pfd||"NDAphi.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 50 then
   do
     ND=50
     call charout(NDAphi) ; Call SysFileDelete NDAphi
     ret=LineOut(NDAphi, 50)
     Call Charout,"   Achtung, nur  50 Dezimalstellen bei der Berechnung von  phi(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 50 ist, wird ND = ND  weitergegeben */
   call charout(NDAphi) ; Call SysFileDelete NDAphi
   ret=LineOut(NDAphi, ND)

   numeric digits 125
   /*    2/sqrt(2*Pi)=sqrt(2/Pi)  */
   c=0.7978845608028653558798921198687637369517172623298693153318516593413158517986036770025046678146138728606051177252703653710220
   /*    1/sqrt(2*Pi)   */
   d=0.39894228040143267793994605993438186847585863116493465766592582967065792589930183850125233390730693643030255886263518268551099
   Numeric Digits ND+10

   arg x,y
   z=x*x  /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     call charout(NDAphi) ; Call SysFileDelete NDAphi
     ret=LineOut(bufMsg, "Im Argument von  phi(...)  ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if x>=0 then sgn=1; else sgn=-1
   x=abs(x)

   if x >=  0    &  x <  6.2 then SIGNAL A
   if x >=  6.2  &  x < 14.8 then SIGNAL B
   if x >= 14.8  then do y=1; SIGNAL C; end

A: u=1; v=1; n=1; m=2;
   do while abs(u/v)>10**(-ND-7)
     g=-z*(m-1)/(m*(m+1)); u=u*g;  v=v+u; n=n+1; m=2*n
   end
   y=c*x*v; SIGNAL C

B: u=d*exp(-x*x/2)
   /* Der folgende Kettenbruch stammt aus dem Lexikon der Stochastik, */
   /* Seite 289; In der Definition von Ë(x) die Grenzen beachten !    */
   /* Nur bis zu 8 solcher Klammer-Verschachtelungen je Zeile         */
   /* werden erkannt; andernfalls meldet REXX einen Fehler.           */
   v12=96/x
   v11=88/(x+89/(x+90/(x+91/(x+92/(x+93/(x+94/(x+95/(x+v12))))))))
   v10=80/(x+81/(x+82/(x+83/(x+84/(x+85/(x+86/(x+87/(x+v11))))))))
   v9 =72/(x+73/(x+74/(x+75/(x+76/(x+77/(x+78/(x+79/(x+v10))))))))
   v8 =64/(x+65/(x+66/(x+67/(x+68/(x+69/(x+70/(x+71/(x+v9 ))))))))
   v7 =56/(x+57/(x+58/(x+59/(x+60/(x+61/(x+62/(x+63/(x+v8 ))))))))
   v6 =48/(x+49/(x+50/(x+51/(x+52/(x+53/(x+54/(x+55/(x+v7 ))))))))
   v5 =40/(x+41/(x+42/(x+43/(x+44/(x+45/(x+46/(x+47/(x+v6 ))))))))
   v4 =32/(x+33/(x+34/(x+35/(x+36/(x+37/(x+38/(x+39/(x+v5 ))))))))
   v3 =24/(x+25/(x+26/(x+27/(x+28/(x+29/(x+30/(x+31/(x+v4 ))))))))
   v2 =16/(x+17/(x+18/(x+19/(x+20/(x+21/(x+22/(x+23/(x+v3 ))))))))
   v1 = 8/(x+ 9/(x+10/(x+11/(x+12/(x+13/(x+14/(x+15/(x+v2 ))))))))
   v  = 1/(x+ 1/(x+ 2/(x+ 3/(x+ 4/(x+ 5/(x+ 6/(x+ 7/(x+v1 ))))))))
   y  =1-2*v*u

C: u=sgn*y
   numeric digits ND
   return(Format(u))

phiMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAphi) ; Call SysFileDelete NDAphi
     ret=LineOut(bufMsg, "Sie haben in  phi(...)  kein gÅltiges Argument eingegeben !")
   /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
   /*  damit in den diesbezÅglichen temporÑren Dateien                      */
   /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

