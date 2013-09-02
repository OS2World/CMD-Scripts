/*  REXX-Programm  gcd(x,y)  */
   signal on syntax name potGCD 

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAGCD=Pfd||"NDAGCD.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"

   arg u,v,s

   if length(s) > 0 then
   do
     call charout(NDAGCD) ; Call SysFileDelete NDAGCD
     ret=LineOut(bufMsg, "Im Argument von  gcd(.. , ..)  ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   lu=length(Format(abs(u),,,0))
   lv=length(Format(abs(v),,,0))
   lm=Max(lu,lv)
   ND=lm
   NUMERIC DIGITS ND+6
 
   if v==0 then do; v=u; Signal RT; end
   if u==0 then do; v=v; Signal RT; end
   if u<0 then u=-u
   if v<0 then v=-v  
   do until u=0
     if u<v then
     do
       t=u
       u=v
       v=t
     end
     u=u-v
   end
RT: NUMERIC DIGITS ND
    return(Format(v))

potGCD:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAGCD) ; Call SysFileDelete NDAGCD
     ret=LineOut(bufMsg, "Sie haben in  gcd(.. , ..)  keine gÅltigen Argumente eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end
