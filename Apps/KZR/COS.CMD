/* REXX-Programm cos.cmd */
   Signal on syntax name cosMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAcos=Pfd||"NDAcos.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)
   Numeric Digits ND+10

   arg xx,y
   p0p=xx*xx /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     call charout(NDAcos); Call SysFileDelete NDAcos
     ret=LineOut(bufMsg, "Im Argument von  cos(...)  ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if ND > 450 then
   do
     ND=450
     call charout(NDAcos) ; Call SysFileDelete NDAcos
     ret=LineOut(NDAcos, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von   cos(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAcos) ; Call SysFileDelete NDAcos
   ret=LineOut(NDAcos, ND)

   if xx = 0 then do; y=1; Signal W; end

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

   pi14=pi/4;

   x=abs(xx)//(2*pi)
   /* x bleibt im Intervall  0 < x < 2*pi  */

   vz=1
   /* Das Intervall  0 < x < 2*pi  wird so zerlegt, da· die Reihen fÅr     */
   /* sin(x)  und  cos(x)  immer nur fÅr Werte  x < „/4  verwendet werden. */
   select
     when x > 7*pi14 then do; x = 2*pi-x;   vz=+1; Signal Cos; end
     when x > 6*pi14 then do; x = x-3*pi/2; vz=+1; Signal Sin; end
     when x > 5*pi14 then do; x = 3*pi/2-x; vz=-1; Signal Sin; end
     when x > 4*pi14 then do; x = x-pi;     vz=-1; Signal Cos; end
     when x > 3*pi14 then do; x = pi-x;     vz=-1; Signal Cos; end
     when x > 2*pi14 then do; x = x-pi/2;   vz=-1; Signal Sin; end
     when x >   pi14 then do; x = pi/2-x;   vz=+1; Signal Sin; end
     when x >   0    then do; x = x;        vz=+1; Signal Cos; end
     otherwise NOP
   end

Sin:
   /* Reihe sin(x) */
   g=1; z=x**2 ; m=2; v=1
   do forever
     g=-g*z/(m*(m+1))
     if abs(g/v) < 10**(-ND-7) then leave
     v=v+g
     m=m+2
   end
   y=v*x*vz
   Signal W

Cos:
   /* Reihe cos(x) */
   g=1; z=x**2; m=2; v=1
   do forever
     g=-g*z/(m*(m-1))
     if (abs(g/v) < 10**(-ND-7)) then leave
     v=v+g
     m=m+2
   end
   y=v*vz

W: numeric digits ND
   return(Format(y))

EXIT

cosMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAcos); Call SysFileDelete NDAcos
     ret=LineOut(bufMsg, "Sie haben in  cos(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

