/*    REXX-Programm  bin.cmd  fr die Binomial-Koeffizienten    */
/*               (gesprochen: "n ber m")                       */
   signal on syntax name binMsg

/* Diese Variablen mssen fr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   parse arg n,m,s

   if length(s) > 0 then
   do
     ret=LineOut(bufMsg, "Im Argument von  bin(.. , ..)  ist mindestens  1  nicht zul„ssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   p0p=n*m /* Diese Anweisung provoziert eine Syntax-Fehlermeldung */

   nn=n//1
   if (nn<>0) then
   do
      ret=LineOut(bufMsg, "Das erste Argument der Funktion  bin(...)  muá eine ganze Zahl sein !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
      EXIT
    end

   mm=m//1
   if (mm<>0) then
   do
      ret=LineOut(bufMsg, "Das zweite Argument der Funktion  bin(...)  muá eine ganze Zahl sein !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
      EXIT
    end

   if (n>2000) then
   do
     ret=LineOut(bufMsg, "Das erste Argument der Funktion  bin(.. , ..)  darf 2000 nicht berschreiten !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if (n<m) then
   do
      ret=LineOut(bufMsg, "In der Funktion  bin(...)  muá die erste Variable gr”áer als die Zweite sein !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
      EXIT
   end

   if m=1 then do y=n; SIGNAL A; EXIT; end
   if m=n then do y=1; SIGNAL A; EXIT; end
   if m=0 then do y=1; SIGNAL A; EXIT; end

   numeric digits ND+10

   um=1; i=1 /* Berechnung von n! */
   do while (i<m+1)
     um=um*i
     i=i+1
   end

   un=1; i=1 /* Berechnung von m! */
   do while (i<n+1)
     un=un*i
     i=i+1
   end

   unm=1; i=1 /* Berechnung von (n-m)! */
   do while (i<n-m+1)
     unm=unm*i
     i=i+1
   end

   y=un/(um*unm)

A:
   numeric digits ND
   return(Format(y))

binMsg:
   sf=ErrorText(RC)
   if  Pos("Arithmetic overflow", sf) > 0 | Pos("Invalid whole", sf) >0 then
   do
     ret=LineOut(bufMsg, "Es mssen zu groáe Zahlenwerte verarbeitet werden !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     ret=LineOut(bufMsg, "Sie haben in  bin(...)  kein gltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

