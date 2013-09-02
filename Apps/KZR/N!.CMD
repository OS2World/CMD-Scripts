/* REXX-Funktion n!.CMD */
   signal on syntax name n!Msg

/* Diese Variablen mssen fr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND bernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   parse arg n,y
   p0p=n*n /* Diese Anweisung provoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     ret=LineOut(bufMsg, "Im Argument von  n!(...)  ist mindestens  1  nicht zul„ssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if n=0 then do u=1; Signal W; end

   if n < 0 then
   do
     ret=LineOut(bufMsg, "Das Argument der Funktion  n!(...)  muá gr”áer als Null sein !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   if n > 6000 then
   do
     ret=LineOut(bufMsg, "Das Argument der Funktion  n!(...)  sollte 6000 nicht berschreiten,",
                         "          ",
                         "weil sonst die Rechenzeit zu groá werden wrde.")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

   nn=n//1
   if nn <> 0 then
   do
      ret=LineOut(bufMsg, "Das Argument der Funktion  n!(...)  muá eine ganze Zahl sein !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
      EXIT
    end

    Numeric Digits ND+10
    u=1; i=1
    do while (i<n+1)
      u=u*i
      i=i+1
    end

W:
   numeric digits ND
   return(Format(u))

n!Msg:
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
     ret=LineOut(bufMsg, "Sie haben in  n!(...)  kein gltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gel”scht, */
  /*  damit in den diesbezglichen tempor„ren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergeh„ngt werden.               */
     EXIT
   end

