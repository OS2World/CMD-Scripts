/* REXX-Programm pi.cmd */
  
/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDApi  =Pfd||"NDApi.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)
   Numeric Digits ND+4

   /* Berechnet  „  mit Hilfe von  arcsin(1/2) = „/6 */
   g=1; t=0.25; m=2; v=1
   do forever
     g=g*t*(m-1)*(m-1)/(m*(m+1))
     if g/v < 10**(-ND-20) then leave
     v=v+g
     m=m+2
   end
   y=3*v

W: numeric digits ND
   return(Format(y))

   EXIT
