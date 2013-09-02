/*  REXX-Programm  mod(x,y)  */
   signal on syntax name potMOD  

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAMOD=Pfd||"NDAMOD.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"

   arg u,v,s
   
   if length(s)>0 then
   do
     call charout(NDAMOD) ; Call SysFileDelete NDAMOD
     ret=LineOut(bufMsg, "Im Argument von  MOD(.. , ..)  ist mindestens  1  nicht zulÑssige Variable !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end
  
   if length(v)=0 | v==0 then
   do
     call charout(NDAMOD) ; Call SysFileDelete NDAMOD
     ret=LineOut(bufMsg, "Die zweite Variable der Funktion  MOD(.. , ..)  fehlt oder ist gleich Null !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end
                                  
   if v<1 then
   do
     call charout(NDAMOD) ; Call SysFileDelete NDAMOD
     ret=LineOut(bufMsg, "Das zweite Argument von  MOD(.. , ..)  darf nicht Null oder negativ sein !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT              
   end                               
                                  
   lu=length(Format(abs(u),,,0))
   lv=length(Format(abs(v),,,0))
   lm=Max(lu,lv); 
   ND=lm
   NUMERIC DIGITS ND+6

/*   if v=1 & abs(u)>0 then do; z=0; signal RT; end
   if v>1 & abs(u)=0 then do; z=0; signal RT; end  */
 
   if abs(u)>0 & v=1  then do; z=0; signal RT; end
   if abs(u)=0 & v>=1 then do; z=0; signal RT; end  
   if sign(u)==sign(v) then z=u-v*trunc(u/v) 
                       else z=u+v*(1-trunc(u/v))
   RT:
   NUMERIC DIGITS ND
   return(Format(z))

potMOD:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAMOD) ; Call SysFileDelete NDAMOD
     ret=LineOut(bufMsg, "Sie haben in  MOD(.. , ..)  keine gÅltigen Argumente eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end
