/*  Programm  root3.CMD                                                  */
/*  zur rekursiven Berechnung der dritten Wurzel von reellen Zahlen.     */
   signal on syntax name root3Msg

/* Diese Variablen mssen fr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)

   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   arg x,y
   p0p=x*x /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     ret=LineOut(bufMsg, "Im Argument von  root3(...)  ist mindestens  1  nicht zul„ssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if x < 1.0E-10000 | x > 1.0E+10000 then
   do
     ret=LineOut(bufMsg, "     Das Argument der Funktion root3(...)",
                         "                                          ",
                         "sollte entweder gleich  0                                                      ",
                         "oder gr”áer als  1.0E-10000  und kleiner als  1.0E+10000  sein.")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
     /*  damit in den diesbezglichen tempor„ren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   NUMERIC DIGITS (ND+12)
   vzx=1;
   if (x=0) then do; y=0; return(y); EXIT; end;
   if (x<0) then
   do
     vzx=-1; x=abs(x);
   end

   if 0<x then if x<1 then SIGNAL A

   n=0; do while x>100
          x=x/1000
          n=n+1
        end; SIGNAL B

A: n=0; do while x<0.01
          x=x*1000
          n=n-1
        end

B: y=1; t=x/(y*y)
        do while abs(y-t) > y*10**(-ND-5)
          y=(2*y+t)/3
          t=x/(y*y)
        end

   u=vzx*y*10**n
   numeric digits ND
   return(Format(u))

root3Msg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     ret=LineOut(bufMsg, "Sie haben in  root3(...)  kein gltiges Argument eingegeben !")
   /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
   /*  damit in den diesbezglichen tempor„ren Dateien                      */
   /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

