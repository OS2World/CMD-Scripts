/* REXX-Programm tan.cmd                  */

   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
/*   Signal on syntax name tanMsg */

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAtan=Pfd||"NDAtan.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)
   NUMERIC DIGITS ND+14

   arg xx,y
   p0p=xx*xx /* Diese Anweisung porvoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     call charout(NDAtan) ; Call SysFileDelete NDAtan
     ret=LineOut(bufMsg, "Im Argument von  tan(..) ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if ND > 450 then
   do
     ND=450
     call charout(NDAtan) ; Call SysFileDelete NDAtan
     ret=LineOut(NDAtan, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von   tan(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAtan) ; Call SysFileDelete NDAtan
   ret=LineOut(NDAtan, ND)

   if xx = 0 then do; yy=0; Signal X; end

   pi=3.||,
   1415926535897932384626433832795028841971693993751058209749445923078||,
   164062862089986280348253421170679821480865132823066470938446095505822317||,
   253594081284811174502841027019385211055596446229489549303819644288109756||,
   659334461284756482337867831652712019091456485669234603486104543266482133||,
   936072602491412737245870066063155881748815209209628292540917153643678925||,
   903600113305305488204665213841469519415116094330572703657595919530921861||,
   173819326117931051185480744623799627495673518857527248912279381830119491||,
   298336733624406566430860213949463952247371907021798609437027705392171762||,
   93176752384674818467669405132

   pi14=pi/4; /* = „/4 */  pi24=pi/2  /* = „/2  */

   /* x bleibt im Intervall  0 < x < 2„  */
   x=abs(xx)//(2*pi)
   /* x bleibt im Intervall  0 < x < „   */
   x=x//pi

   NUMERIC DIGITS ND+10
   vzs=1; vzc=1
   /* Das Intervall  0 < x < 2*pi  wird so zerlegt, da· die Reihen fÅr     */
   /* sin(x)  und  cos(x)  immer nur fÅr Werte  x < „/4  verwendet werden. */
   /* vzs ist ein internes Vorzeichen sÅr die sinus-Reihe                  */
   /* vzc ist ein internes Vorzeichen sÅr die cosinus-Reihe                */
   select
     when x > 3*pi14 then do; x = pi-x;    vzs=+1;  vzc=-1; Signal A; end
     when x > 2*pi14 then do; x = x-pi/2;  vzs=+1;  vzc=-1; Signal B; end
     when x >   pi14 then do; x = pi/2-x;  vzs=+1;  vzc=+1; Signal C; end
     when x >   0    then do; x = x;       vzs=+1;  vzc=+1; Signal D; end
     otherwise NOP
   end

   /* yz = Wert des ZÑhlers;  yn = Wert des Nenners */
A: yz=sin(x,ND,vzs); yn=cos(x,ND,vzc); Signal W
B: yz=cos(x,ND,vzc); yn=sin(x,ND,vzs); Signal W
C: yz=cos(x,ND,vzc); yn=sin(x,ND,vzs); Signal W
D: yz=sin(x,ND,vzs); yn=cos(x,ND,vzc);

W: yy=yz/yn
X: numeric digits ND
   return(Format(sign(xx)*yy))

EXIT

Sin:
   Procedure
   /* Reihe sin(x) */
   arg x,ND,vzs
   g=1; z=x**2 ; m=2; v=1
   do forever
     g=-g*z/(m*(m+1))
     if abs(g/v) < 10**(-ND-7) then leave
     v=v+g
     m=m+2
   end
   ys=v*x*vzs
   return(ys)

Cos:
   Procedure
   /* Reihe cos(x) */
   arg x,ND,vzc
   g=1; z=x**2; m=2; v=1
   do forever
     g=-g*z/(m*(m-1))
     if (abs(g/v) < 10**(-ND-7)) then leave
     v=v+g
     m=m+2
   end
   yc=v*vzc
   return(yc)

tanMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAtan) ; Call SysFileDelete NDAtan
     ret=LineOut(bufMsg, "Sie haben in  tan(..)  kein gÅltiges Argument eingegeben !")
   /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
   /*  damit in den diesbezÅglichen temporÑren Dateien                      */
   /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

