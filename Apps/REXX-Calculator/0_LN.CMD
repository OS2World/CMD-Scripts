/* REXX-Programm 0_ln.cmd  */
 
   parse arg x,ND 
   
   /* FÅr Berechnung des Ln ist intern hohe Genauigkeit erforderlich. */ 
   NUMERIC DIGITS ND+40
   
   /* lna1 = ln(1.69) */
   lna1=0.||,
   5247285289349821040709919737619087944083329122628682807714352193917||,
   841152941153983271549167017823808545808161009529459962452580538075605143

   /* lna2 = ln(3.49) */
   lna2=1.||,
   2499017362143357951634986131299112939466823602028164371597327972818||,
   379181900889747291289440245239282509867619774937415989840364673381082569

   /* lna3 = ln(7) */
   lna3=1.||,
   9459101490553133051053527434431797296370847295818611884593901499375||,
   798627520692677876584985878715269930616942058511409117237522576777868431

   /* ln10 = ln(10) */
   ln10=2.||,
   3025850929940456840179914546843642076011014886287729760333279009675||,
   726096773524802359972050895982983419677840422862486334095254650828067566

   if x<1.0E-10000 | x>1.0E+10000 | x<0 then signal VW 
   if x  = 1    then do y=0;    return(y);   EXIT; end
   if x >= 1    then do z=x;    sgn=+1;  SIGNAL A; end
   if x <= 1    then do z=1/x;  sgn=-1;  SIGNAL A; end
   
A: p=10; n=0; do while (z>9.5); z=z/p; n=n+1; end

   if (5.0   <  z) then if (z <= 9.50 ) then
           do aa=7.00; aln=lna3; SIGNAL B; end
   if (2.430 <  z) then if (z <= 5.00 ) then
           do aa=3.49; aln=lna2; SIGNAL B; end
   if (1.05  <  z) then if (z <= 2.430) then
           do aa=1.69; aln=lna1; SIGNAL B; end
   if (0.95  <  z) then if (z <= 1.05 ) then SIGNAL C

B: tt=(z-aa)/(z+aa); t=tt*tt; u=1; m=1; v=1
   do while ((u/v) > 10**(-ND-30))
       g=t*(2*m-1)/(2*m+1); u=u*g; v=v+u; m=m+1; end
   y=sgn*(n*ln10 + aln+2*tt*v); SIGNAL E

C: tt=(z-1)/(z+1); t=tt*tt; u=1; m=1; v=1
   do while ((u/v) > 10**(-ND-30))
       g=t*(2*m-1)/(2*m+1); u=u*g; v=v+u; m=m+1; end
   y=sgn*(n*ln10 + 2*tt*v)

E: NUMERIC DIGITS ND+5
   return(Format(y))
EXIT

vW:
   return(NULL)
   EXIT
