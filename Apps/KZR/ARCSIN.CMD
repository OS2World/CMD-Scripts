/* REXX-Programm arcsin.cmd */
/* Pi24=„/2                 */
   Signal on syntax name arcsinMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAarcsin=Pfd||"NDAarcsin.DAT"
   bufND    =Pfd||"NDZahl.DAT"
   bufMsg   =Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)

   if ND > 450 then
   do
     ND=450
     call charout(NDAarcsin) ; Call SysFileDelete NDAarcsin
     ret=LineOut(NDAarcsin, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von  arcsin(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAarcsin) ; Call SysFileDelete NDAarcsin
   ret=LineOut(NDAarcsin, ND)

   Numeric Digits ND+10

   pi24=1.||,
   5707963267948966192313216916397514420985846996875529104874722961539||,
   082031431044993140174126710585339910740432566411533235469223047752911158||,
   626797040642405587251420513509692605527798223114744774651909822144054878||,
   329667230642378241168933915826356009545728242834617301743052271633241066||,
   968036301245706368622935033031577940874407604604814146270458576821839462||,
   951800056652652744102332606920734759707558047165286351828797959765460930||,
   5869096630589655255927403723118998137478367594287636244561396909150597456

   arg xxx,y  /* y soll "illegale" Komma's im Funktions-Argument aufspÅren */
   p0p=xxx*xxx /* Diese Anweisung prvoziert eine Syntax-Fehlermeldung     */
   vz=sign(xxx)

   if y > 0 then
   do
     call charout(NDAarcsin) ; Call SysFileDelete NDAarcsin
     ret=LineOut(bufMsg, "Im Argument von  arcsin(...)  ist mindestens  1  nicht zulÑssiges Komma !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   xx=abs(xxx)

   if xx > 1 then
   do
     call charout(NDAarcsin) ; Call SysFileDelete NDAarcsin
     ret=LineOut(bufMsg, "FÅr |x|>1 ist der Arcussinus nicht definiert !")
     /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
     /*  damit in den diesbezÅglichen temporÑren Dateien                      */
     /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if xx=1 then do; y=pi24; Signal W; end

   /* Berechnung von x = xx/sqrt(1-xx*xx)  fÅr |xx| <= 1 */
   x=1-xx*xx
   y=1
   do while abs(y-x/y)>10**(-ND-7)*y
     y=(y+x/y)/2
   end
   xx=xx/y

        /* Berechnung von arctan(x) */
        if 0    <= xx & xx <  0.56 then Signal A
        if 0.56 <= xx & xx <  2    then
        do
          x=(xx-1)/(xx+1)
          Signal B
        end
        if xx >= 2 then Signal C

     A: /* Arctan fÅr 0 <= xx < 0.4142 */
        y=TanArc(xx,ND)
        Signal W

     B: /* Arctan fÅr 0.4142 <= x < 2.414 */
        y=Pi24/2+TanArc(x,ND)
        Signal W

     C: /* Arctan fÅr x > 2.414 */
        t=xx**2; v=1; m=2; g=1
        do forever
          g=-g*(m-1)/(t*(m+1))
          v=v+g
          if abs(g/v) < 10**(-ND-7) then leave
          m=m+2
        end
        y=1*pi24-v/xx

W: Numeric Digits ND
   Return(Format(vz*y))

EXIT

TanArc:
   Procedure
   arg x,ND
   t=x**2; g=1; u=1; v=1; m=2
   do forever
     g=-t*g*(m-1)/(m+1)
     v=v+g
     if abs(g/v) < 10**(-ND-5 ) then leave
     m=m+2
   end
   return(x*v)

arcsinMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAarcsin) ; Call SysFileDelete NDAarcsin
     ret=LineOut(bufMsg, "Sie haben in  arcsin(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

