/* REXX-Programm 0_cosh.cmd  */

   arg x,ND
   Numeric Digits ND+40
   
   if x=0 then do; y=1; Signal W; end
   if abs(x)>=1.0E8 then signal VW 
   if abs(x) <  0.1 then SIGNAL A
   if abs(x) >= 0.1 then SIGNAL B

A: u=1; v=1; m=2; z=x*x
   do while (abs(u/v) > 10**(-ND-30))
     g=z/(m*(m-1)); u=u*g; v=v+u; m=m+2; end
   y=v; SIGNAL W

B: ep=0_exp(x,ND); em=1/ep; y=(ep+em)/2

W: numeric digits ND+5
   return(Format(y))
EXIT

vW:
   return(NULL)
   EXIT
