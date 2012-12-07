/* REXX-Funktion 0_exp.CMD */
   "@ echo off"
                   
   parse arg x,ND
   NUMERIC DIGITS ND+40

   if x=0 then do; u=1; signal W; end
   if abs(x)>=1.0E9 then signal VW 

   xg=trunc(x)
   xr=x-xg
   yxg=efunk(1,ND)
   yxr=efunk(xr,ND)
   u=yxr*yxg**xg

W: numeric digits ND+5
   return(Format(u))
EXIT

efunk:
   Procedure
   arg x, ND+40
   g=1; n=1; y=1
   do forever
     g=g*x/n
     if abs(g/y) < 10**(-ND-30) then leave
     y=y+g
     n=n+1
   end
   return(y)
   
vW:
   return(NULL)
   EXIT
