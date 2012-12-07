/* REXX-Programm 0_arctan.cmd */
/* Pi24=„/2                 */

   arg xxx,ND
   Numeric Digits ND+30
   vz=sign(xxx)
   xx=abs(xxx)
   
   pi24=1.570796326794896619231321691639751442098584699687552910487472296154
              
   if xx = +1 then do; y=pi24/2; Signal W; end
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
     if abs(g/v) < 10**(-ND-20) then leave
     m=m+2
   end
   y=1*pi24-v/xx

W: Numeric Digits ND+5
   Return(Format(vz*y))

EXIT

TanArc:
   Procedure
   arg x,ND+30
   t=x**2; g=1; u=1; v=1; m=2
   do forever
     g=-t*g*(m-1)/(m+1)
     v=v+g
     if abs(g/v) < 10**(-ND-20 ) then leave
     m=m+2
   end
   return(x*v)
