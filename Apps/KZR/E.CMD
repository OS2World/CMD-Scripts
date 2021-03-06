/* REXX-Programm e.cmd  */
   Signal on syntax name eMsg

/* Diese Variablen m�ssen f�r jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND �bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAe=Pfd||"NDAe.DAT"
   bufND  =Pfd||"NDZahl.DAT"
   bufMsg =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)
   Numeric Digits ND+4

   /* Berechnet die Zahl e=2.718.... */
   g=1; n=1; y=1
   do forever
     g=g*1/n
     if (abs(g/y) < 10**(-ND-7)) then leave
     y=y+g
     n=n+1
   end

W: numeric digits ND
   return(Format(y))

