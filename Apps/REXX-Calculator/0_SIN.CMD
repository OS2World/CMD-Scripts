/* REXX-Programm 0_sin.cmd */
   
   arg xx,ND
   /* Wegen der Periodizit„t der Sinusfunktion Genauigkeit */
   Numeric Digits ND+40

   if abs(xx)>=1.0E8 then signal VW 
   if xx = 0 then do; y=0; Signal W; end

   pi=3.||,
   1415926535897932384626433832795028841971693993751058209749445923078||,
   164062862089986280348253421170679821480865132823066470938446095505822317
   pi14=pi/4

   x=abs(xx)//(2*pi)
   /* x bleibt im Intervall  0 < x < 2ã  */

   vz=1
   /* Das Intervall  0 < x < 2*pi  wird so zerlegt, daá die Reihen fr     */
   /* sin(x)  und  cos(x)  immer nur fr Werte  x < ã/4  verwendet werden. */
   select
     when x > 7*pi14 then do; x = 2*pi-x;   vz=-1; Signal Sin; end
     when x > 6*pi14 then do; x = x-3*pi/2; vz=-1; Signal Cos; end
     when x > 5*pi14 then do; x = 3*pi/2-x; vz=-1; Signal Cos; end
     when x > 4*pi14 then do; x = x-pi;     vz=-1; Signal Sin; end
     when x > 3*pi14 then do; x = pi-x;     vz=+1; Signal Sin; end
     when x > 2*pi14 then do; x = x-pi/2;   vz=+1; Signal Cos; end
     when x >   pi14 then do; x = pi/2-x;   vz=+1; Signal Cos; end
     when x >   0    then do; x = x;        vz=+1; Signal Sin; end
     otherwise NOP
   end

Sin:
   /* Reihe sin(x) */
   g=1; z=x**2 ; m=2; v=1
   do forever
     g=-g*z/(m*(m+1))
     if abs(g/v) < 10**(-ND-30) then leave
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
     if (abs(g/v) < 10**(-ND-30)) then leave
     v=v+g
     m=m+2
   end
   y=v*vz

W: numeric digits ND+5
   return(Format(y*sign(xx)))

EXIT

vW:
   return(NULL)
   EXIT
