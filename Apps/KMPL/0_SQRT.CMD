/* REXX-Programm sqrt.CMD */

   arg x,ND
   Numeric Digits ND+30
             
   if (x=0) then return(0)
   if x<0 then signal VW 
   if x<1.0E-10000 && x>1.0E+10000 then signal VW 
   if (x=1) then return(1)

   if x<1 then SIGNAL A
   else
   do
     n=0
     do while x>100
       x=x/100
       n=n+1
     end
   end
   SIGNAL B

   A:
     n=0
     do while x<(0.01)
       x=x*100
       n=n-1
     end
     SIGNAL B

   B:
     y=1
     t=x/y
     do while abs(y-t) > y*10**(-ND-20)  
       y=(y+t)/2
       t=x/y
     end

   u=y*10**n
   numeric digits ND+5
   return(Format(u)) 
 
EXIT

vW:
   return(NULL)
   EXIT
