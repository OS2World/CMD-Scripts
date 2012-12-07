/* REXX-PROGRAM kmpl_e.CMD      */

   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   Call SysCls
"mode co80,30"

 /* Bei Bettigung der Tasten-Kombination  Strg+C  wird kmpl.CMD beendet.  */
   signal on halt name PgmEnd

 /* Mit den folgenden Zeilen wird, wenn das Verzeichnis, in dem sich diese */
 /* Datei  kmpl.CMD  befindet, im Pfad steht, sichergestellt, daแ auch die */
 /* Datei  kmpl.INF  bei Fehlern von kmpl.CMD angezeigt werden kann,       */
 /* wenn   kmpl.CMD  nicht aus diesem Verzeichnis aufgerufen wird.         */
   Pfd=SysSearchPath("PATH", "kmpl.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   
Anf:  
   call Locate 02,12
   call Charout,"Elementary Calculations with two Complex Numbers "
   call Color 1,white;    call Charout,"Z1"
   call Color 0,white;    call Charout," and "
   call Color 1,white;    call Charout,"Z2";say
   call Locate 03,18
   call Color 0,white;    
   call Charout,"with there components "
   call Color 1,white;    call Charout,"Re1"
   call Color 0,white;    call Charout,", "
   call Color 1,white;    call Charout,"Im1"
   call Color 0,white;    call Charout,"  and  "
   call Color 1,white;    call Charout,"Re2"
   call Color 0,white;    call Charout,", "
   call Color 1,white;    call Charout,"Im2"
   call Color 0,white;    call Charout,""
   call Locate 04,07
   call Charout,"Calculations of Funktion Values of the Results"
   call Charout," of these Calculations"
   sch=0                          
   
lRe1:  
   call Locate 06,09
   call Charout,"                                                                 "
   call Locate 06,09
   call Charout,"(1) "
   call Color 1,white;    call Charout,"Re1"
   call Color 0,white;    call Charout," = " 
   Re1=strip(EditStr(06,19,54))
   if DataType(Re1, 'N')<>1 then
   do    
     Call Quatsch
     Call Loesch
     Call SysCurState ON
     signal lRe1
   end    
   call Locate 06,19
   call Charout,"                                                                 "
   call Locate 06,19;                                            
   call Color 1,white;    call Charout,Re1
   call Color 0,white;    
   if sch==1 then signal sel
   if sch==2 then signal anz1
   sch=0
   
lIm1:
   call Locate 07,09
   call Charout,"                                                                 "
   call Locate 07,09
   call Charout,"(2) "
   call Color 1,white;    call Charout,"Im1"
   call Color 0,white;    call Charout," = "
   Im1=strip(EditStr(07,19,54))
   if DataType(Im1, 'N')<>1 then
   do    
     Call Quatsch
     Call Loesch
     Call SysCurState ON
     signal lIm1
   end    
   call Locate 07,19
   call Charout,"                                                                 "
   call Locate 07,19;                                            
   call Color 1,white;    call Charout,Im1
   call Color 0,white;    
   if sch==1 then Signal sel 
   if sch==2 then signal anz1
   sch=0 

anz1:
   call Locate 08,19
   call Charout,"                                                                 "
   call Locate 08,14;                                            
   call Color 1,white;
   if Im1>0 then
     do
       call Charout, "Z1 = "; call color 1,cyan; call Charout, Re1 "+"Im1"*i";
     end

   if Im1<0 then 
     do
       call Charout, "Z1 = "; call Color 1,cyan; call Charout, Re1    Im1"*i" 
     end
     
   if Im1==0 then
     do
       call Charout, "Z1 = "; call Color 1,cyan; call Charout, Re1 "+"Im1"*i" 
     end
   
   if Im1=="+0" then
     do
       call Charout, "Z1 = "; call Color 1,cyan; call Charout, Re1    Im1"*i" 
     end
   
   if Im1=="-0" then
     do
       call Charout, "Z1 = "; call Color 1,cyan; call Charout, Re1    Im1"*i" 
     end
    
     call Color 0,white;    
   if sch==2 then signal sel

lRe2:   
   call Locate 09,09
   call Charout,"                                                                 "
   call Locate 09,09
   call Charout,"(3) "             
   call Color 1,white;    call Charout,"Re2"
   call Color 0,white;    call Charout," = "
   Re2=strip(EditStr(09,19,54))
   if DataType(Re2, 'N')<>1 then
   do    
     Call Quatsch
     Call Loesch
     Call SysCurState ON
     signal lRe2
   end 
   call Locate 09,19; 
   call Charout,"                                                                "
   call Locate 09,19; 
   call Color 1,white;    call Charout,Re2
   call Color 0,white;
   if sch==1 then signal sel
   if sch==2 then signal anz2
   sch=0
   
lIm2:   
   call Locate 10,09
   call Charout,"                                                                 "
   call Locate 10,09
   call Charout,"(4) "
   call Color 1,white;    call Charout,"Im2"
   call Color 0,white;    call Charout," = "
   Im2=strip(EditStr(10,19,54))
   if DataType(Im2, 'N')<>1 then
   do    
     Call Quatsch
     Call Loesch
     Call SysCurState ON
     signal lIm2
   end    
   call Locate 10,19
   call Charout,"                                                                 "
   call Locate 10,19; 
   call Color 1,white;    call Charout,Im2
   call Color 0,white;    
   if sch==1 then Signal sel 
   if sch==2 then signal anz2
   sch=0 

anz2:
   call Locate 11,19
   call Charout,"                                                                 "
   call Locate 11,14;                                            
   call Color 1,white;
   if Im2>0 then
     do
       call Charout, "Z2 = "; call color 1,cyan; call Charout, Re2 "+"Im2"*i";
     end

   if Im2<0 then 
     do
       call Charout, "Z2 = "; call Color 1,cyan; call Charout, Re2    Im2"*i" 
     end
     
   if Im2==0 then
     do
       call Charout, "Z2 = "; call Color 1,cyan; call Charout, Re2 "+"Im2"*i" 
     end
   
   if Im2=="+0" then
     do
       call Charout, "Z2 = "; call Color 1,cyan; call Charout, Re2    Im2"*i" 
     end
   
   if Im2=="-0" then
     do
       call Charout, "Z2 = "; call Color 1,cyan; call Charout, Re2    Im2"*i" 
     end
    
     call Color 0,white;    
   if sch==2 then signal sel

lop:    
   call Locate 12,09
   call Charout,"(5) Operator (+,-,*,/ or # instead of ^) :     "
   op=EditStr(12,52,1)
   
   if op<>"+" & op<>"-" & op<>"*" & op<>"/" & op<>"#" then
   do
     Beep(250, 200)
     Signal lop
   end
   call Locate 12,52
   if op=="#" then op="^"
   call Locate 12,52
   call Color 1,Cyan;     call Charout,op
   call Color 0,white
   if sch==1 then Signal sel
   if sch==3 then Signal selsel

lnd:
   call Locate 13,09
   call Charout,"(6) How many decimal figures (ND<=54) ? :        "
   ND=EditStr(13,49,2)
   if ND<4 | ND>54 then
   do    
     Beep(250, 200)
     Signal lnd
   end
   call Locate 13,49
   call Color 1,Cyan;     call Charout,ND
   call Color 0,white
   if sch==1 then Signal sel
   if sch==3 then Signal selsel

   Numeric Digits ND+15
   /* Mathematische Konstanten */
   pi=3.1415926535897932384626433832795028841971693993751058209749445923078
   /* ln10 = ln(10) */
   ln10=2.3025850929940456840179914546843642076011014886287729760333279009675
   /*  m10 = 1/ln(10) */
   m10=0.434294481903251827651128918916605082294397005803666566114453783165
   
sel:   
   call Locate 15,04 
   call Charout,"To change values hit (1,2,3,4,5,6)   , otherwise hit Return.   " 
   ent=EditStr(15,39,1)
   select 
      when ent=='1' then do; sch=1; Signal 0lRe1; end
      when ent=='2' then do; sch=1; Signal 0lIm1; end
      when ent=='3' then do; sch=1; Signal 0lRe2; end
      when ent=='4' then do; sch=1; Signal 0lIm2; end
      when ent=='5' then do; sch=1; Signal lop;  end
      when ent=='6' then do; sch=1; Signal lnd;  end
      when ent==''  then do; sch=1; Signal we1;  end
      otherwise 
      do
        Call SysCurState OFF
        Beep(250, 200)
        Call SysCurState ON
        Signal sel
      end
   end

we1:   
   if op=='+' then
   do
     Re=Re1+Re2; Im=Im1+Im2
     signal Ausdr
   end

   if op=='-' then
   do
     Re=Re1-Re2; Im=Im1-Im2
     signal Ausdr
   end

   if op=='*' then
   do
     Re=Re1*Re2-Im1*Im2; Im=Re1*Im2+Re2*Im1
     signal Ausdr
   end
                               
   if op=='/' then
   do
     nen=Re2**2+Im2**2  
     if nen==0 then
     do   
       call nenNull 
       call Loesch
       Call SysCurState ON
       call SysCls
       signal Anf
     end
     Re=(Re1*Re2+Im1*Im2)/nen
     Im=(Im1*Re2-Re1*Im2)/nen
     signal Ausdr
   end
   
   if op=='^' then
   do
    
     if Re1==0 & Im1==0 & Re2==0 & Im2==0 then call Unbestimmt
     if Re1==0 & Im1==0 then
     do
       Re=0
       Im=0
       signal Ausdr
     end 
                   
     /* Berechnung des Betrages btr1  */
     btr1qdrt=Re1**2+Im1**2
     if btr1qdrt==0 then Signal ueb1  
     if btr1qdrt<=1.0E-10000 && btr1qdrt>=1.0E+10000 then Call Unzul sqrt, btr1qdrt, "239"
     ueb1:
     btr1=0_sqrt(btr1qdrt, ND)
     /* Berechnung des Winkels phi1   */
     if Re1>0 & Im1==0 then 
     do   
       phi1=0
       signal ww1
     end
   
     if Re1<0 & Im1==0 then 
     do   
       phi1=pi
       signal ww1
     end
   
     if Re1==0 & Im1>0 then 
     do   
       phi1=Pi/2
       signal ww1
     end
   
     if Re1==0 & Im1<0 then 
     do   
       phi1=-Pi/2
       signal ww1
     end
   
     if Re1<>0 then
     do
       d=0_arctan(Im1/Re1, ND)
       /* Zuordnung des ArcusTangens-Wertes in den Quadranten */ 
       if Re1>0 & Im1>0 then do; phi1=d;    Signal ww1; end 
       if Re1<0 & Im1>0 then do; phi1=d+pi; Signal ww1; end 
       if Re1<0 & Im1<0 then do; phi1=d-pi; Signal ww1; end 
       if Re1>0 & Im1<0 then do; phi1=d;    Signal ww1; end 
     end
     ww1: 
     if Re1==0 & Im1>0  then phi1=+pi/2
     if Re1==0 & Im1<0  then phi1=-pi/2
     if Re1==0 & Im1==0 then phi1=0

     ln_btr1=0_ln(btr1,ND)
     exp_Re=Re2*ln_btr1-Im2*phi1
     exp_Im=Im2*ln_btr1+Re2*phi1
     if abs(exp_Re)>=9.9E+7 then Call Unzul exp, exp_Re, "284"
     if abs(exp_Im)>=9.9E+7 then Call Unzul exp, exp_Im, "285"
     u =  0_exp(exp_Re,ND)
     Re=u*0_cos(exp_Im,ND)
     Im=u*0_sin(exp_Im,ND)
                                                    
Ausdr:
   call Locate 17,04 
   call Farb "(Re + Im*i)"
   call Color 0,white;    call Charout," = "
   call Color 1,White;    call Charout,"Z1"
   call Color 1,Cyan;     call Charout,op 
   call Color 1,White;    call Charout,"Z2"
   call Color 0,white;    call Charout," = "
   call Color 1,White;    call Charout,"(Re1 + Im1*i)"
   call Color 1,Cyan;     call Charout,op 
   call Color 1,White;    call Charout,"(Re2 + Im2*i)" 
   call Locate 19,04
   call Charout,"                                                                   "      
   call Locate 19,04
   call Color 1,yellow;   call Charout,"Re = "
   call Color 1,Green;    call Charout,Format(Re,,ND,,0)
   call Locate 20,04
   call Charout,"                                                                   "      
   call Locate 20,04
   call Color 1,yellow;   call Charout,"Im = "
   call Color 1,Green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white
   if sch=3 then signal ltne
   if sch=4 then signal selsel

selsel:
   call Locate 22,04
   call Charout,"Look for both complex numbers "
   call Color 1,white;
   call Charout,"Z1"
   call Color 0,white;
   call Charout," and "
   call Color 1,white;
   call Charout,"Z2"
   call Color 0,white;
   call Charout," above. Would you like to change the"
   call Locate 23,04
   call Charout,"operator (5) and/or the number (6) of decimal figures for the result   "
   call Locate 24,04
   call Charout,"and then calculate a (n)ew? result? (5,6,n)   , otherwise hit Return.  "
   entent=EditStr(24,48,1)
   select 
      when entent=='5' then do; sch=3; Signal lop;  end
      when entent=='6' then do; sch=3; Signal lnd;  end
      when entent=='n' then do; sch=4; Signal we1;  end
      when entent==''  then do; sch=3; Signal ltne; end
      otherwise
      do
        Call SysCurState OFF
        Beep(250, 200)
        Call SysCurState ON
        Signal selsel
      end
   end

ltne:   
   call Locate 22,69
   call Charout,"           "
   call Locate 22,02
   call Charout,"Suppose that the calculated complex number "; 
   call Farb "(Re + Im*i)" 
   call Charout," is used as an argument "
   call Locate 23,02
   call Charout,"of one of the functions implemented in this program. "
   call Locate 24,02
   call Charout,"Would you like to (c)alculate values of these functions, or to edit     "
   call Locate 25,02
   call Charout,"(o)ther values of ";
   call Color 1,white;
   call Charout,"Re1"
   call Color 0,white;
   call Charout,", "
   call Color 1,white;
   call Charout,"Im1"
   call Color 0,white;
   call Charout,", "
   call Color 1,white;
   call Charout,"Re2"
   call Color 0,white;
   call Charout,", "
   call Color 1,white;
   call Charout,"Im2"
   call Color 0,white;
   call Charout,", "
   call Charout,"or to leave the Program? (c,o,l)    "
   
   tne=EditStr(25,73,1)                          
   select 
      when tne==' ' | tne=='C' | tne=='c' then do; Signal mehr; end
      when tne=='L' | tne=='l' then 
                               do
                                 call Locate 24,00
                                 Signal PgmEnd
                               end
      when tne=='O' | tne=='o' then do; Call SysCls; Signal Anf; end
      otherwise
      do
        Call SysCurState OFF
        Beep(250, 200)
        Call SysCurState ON
        Signal ltne
      end
   end
                  
mehr:            
   
   Numeric Digits ND+15
            
andere:
/* A N F A N G   der Berechnung von Betrag  btr  und  Winkel  phi         */
/* derjenigen komplexen Zahl  Re + Im*i, die das Ergebnis der Berechnung  */
/* des ersten Teils dieses Programms ist.                                 */
/* Die Gr”แen  btr  und  phi  werden im zweiten Teil dieses Programms bei */
/* der Berechnung von Funktionswerten einiger Funktionen verwendet.       */  
 
  /* Berechnung des Betrages btr, allgemein */
   btrqdrt=Re**2+Im**2
   if btrqdrt==0 then Signal ueb  
   if btrqdrt<=1.0E-10000 && btrqdrt>=1.0E+10000 then Call Unzul sqrt, btrqdrt, "360"
   ueb:
   btr=0_sqrt(btrqdrt, ND)

  /* Berechnung des Winkels phi,  allgemein */
   if Re>0 & Im==0 then 
   do   
     phi=0
     signal ww
   end

   if Re<0 & Im==0 then 
   do   
     phi=pi
     signal ww
   end

   if Re==0 & Im>0 then 
   do   
     phi=Pi/2
     signal ww
   end

   if Re==0 & Im<0 then 
   do   
     phi=-Pi/2
     signal ww
   end

   if Re<>0 then
   do
     argu=Im/Re
     d=0_arctan(argu, ND)
     /* Zuordnung des ArcusTangens-Wertes in den Quadranten */ 
     if Re>0 & Im>0 then do; phi=d;    Signal ww; end 
     if Re<0 & Im>0 then do; phi=d+pi; Signal ww; end 
     if Re<0 & Im<0 then do; phi=d-pi; Signal ww; end 
     if Re>0 & Im<0 then do; phi=d;    Signal ww; end 
   end
   ww: 
   if Re==0 & Im>0  then phi=+pi/2
   if Re==0 & Im<0  then phi=-pi/2
   if Re==0 & Im==0 then phi=0

/* E N D E   der Berechnung von Betrag  btr  und  Winkel  phi             */
/* derjenigen komplexen Zahl  Re + Im*i, die das Ergebnis der Berechnung  */
/* des ersten Teils dieses Programms ist.                                 */
/* Die Gr”แen  btr  und  phi  werden im zweiten Teil dieses Programms bei */
/* der Berechnung von Funktionswerten einiger Funktionen verwendet.       */  

   call SysCls
   call Locate 02,04
   call Color 1,Yellow;   call Charout,"Re = "
   call Color 1,Green;    call Charout,Format(Re,,ND,,0)
   call Locate 03,04
   call Color 1,Yellow;   call Charout,"Im = "
   call Color 1,Green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white
   
   call Locate 05,03; call Charout,"(1)  z = abs. value of (Re + Im*i)"
   call Locate 06,03; call Charout,"(2)  z = phase of (Re + Im*i)"
   call Locate 07,03; call Charout,"(3)  z = (Re + Im*i)^y"
   call Locate 08,03; call Charout,"(4)  z = exp(Re + Im*i)"
   call Locate 09,03; call Charout,"(5)  z =  b^(Re + Im*i)"
   call Locate 10,03; call Charout,"(6)  z =  ln(Re + Im*i)"
   call Locate 11,03; call Charout,"(7)  z = log(Re + Im*i)"
   call Locate 12,03; call Charout,"(8)  z =               "
   call Locate 13,03; call Charout,"(9)  z =               "
   call Locate 14,02; call Charout,"(10)  z =               "
                     
   call Locate 05,42; call Charout,"(11)  z =  sin(Re + Im*i)"
   call Locate 06,42; call Charout,"(12)  z =  cos(Re + Im*i)"
   call Locate 07,42; call Charout,"(13)  z =  tan(Re + Im*i)"
   call Locate 08,42; call Charout,"(14)  z =  cot(Re + Im*i)"
   call Locate 09,42; call Charout,"(15)  z = sinh(Re + Im*i)"
   call Locate 10,42; call Charout,"(16)  z = cosh(Re + Im*i)"
   call Locate 11,42; call Charout,"(17)  z = tanh(Re + Im*i)"
   call Locate 12,42; call Charout,"(18)  z = coth(Re + Im*i)"
   call Locate 13,42; call Charout,"(19)  z =                "
   call Locate 14,42; call Charout,"(20)  Leave the program"
                                              
lfu:                                              
   call Locate 16,72
   call Charout,"  "
   call Locate 16,04
   call Charout,"Which funktion value shall be calculated ? Number (1 bis 20):     "
   fu=EditStr(16,66,2)

   select
      when fu='1'  then Signal Betrl
      when fu='2'  then Signal Winl
      when fu='3'  then Signal hochl
      when fu='4'  then Signal expl
      when fu='5'  then Signal hbhl
      when fu='6'  then Signal lnlnl
      when fu='7'  then Signal logl
      when fu='8'  then Signal lab8
      when fu='9'  then Signal lab9
      when fu='10' then Signal lab10
      when fu='11' then Signal sinl
      when fu='12' then Signal cosl
      when fu='13' then Signal tanl
      when fu='14' then Signal cotl
      when fu='15' then Signal sinhl
      when fu='16' then Signal coshl
      when fu='17' then Signal tanhl
      when fu='18' then Signal cothl
      when fu='19' then Signal lab19
      when fu='20' then Signal PgmEnd
      otherwise                               
      do                                      
        Call SysCurState OFF
        Beep(250, 200)
        Call SysCurState ON
        Signal lfu
      end                                     
   end     

Betrl:   
   call SysCls
   call Locate 02,04
   call Charout,"Calculation of the absolute value of the complex number "
   call Farb "(Re + Im*i)"
   call Locate 04,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 05,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;    
   call Locate 08,04
   call Charout,"The absolute value of the complex number "; call Farb "(Re + Im*i)"
   call Locate 10,04
   call Charout,"is " 
   call Color 1,cyan;     call Charout,Format(btr,,ND,,0)
   call Locate 16,04
   call Color 0,white;    
   call Charout,"========================================================="
   call Locate 19,04
   call Charout,"Should of the complex number "
   call Farb "(Re + Im*i)"
   call Color 0,white;    call Charout," with the components" 
   call Locate 21,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 22,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;    
   call Auswahl
   signal PgmEnd
  
Winl:   
   call SysCls
   call Locate 02,04
   call Charout,"Calculation of the phase of the complex number "
   call Farb "(Re + Im*i)"
   call Locate 04,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 05,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;    
   call Locate 08,04
   call Charout,"The phase "
   call Color 1,cyan;     call Charout,"phi"
   call Color 0,white;    
   call Charout," of the complex number "; call Farb "(Re + Im*i)"
   call Charout,", in radians, is "
   call Locate 10,04
   call Color 1,cyan;     call Charout,"phi"
   call Color 0,white;      
   call Charout," = "
   call Color 1,cyan;     call Charout,Format(phi,,ND,,0)
   call Color 0,white;
   call Charout,"."
   call Locate 16,04
   call Charout,"========================================================="
   call Locate 19,04
   call Charout,"Should of the complex number "
   call Farb "(Re + Im*i)"
   call Color 0,white;    call Charout," with the components" 
   call Locate 21,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 22,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;
   
   call Auswahl
   signal PgmEnd

hochl:
   call SysCls
   call Locate 02,04
   call Charout,"Calculation of the function "
   call Farb "(Re + Im*i)^(y)"
   call Locate 04,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 05,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;    
neuExp:   
   Call SysCurState ON
   call Locate 06,04
   call Charout,"Exponent  y  = "; yy=EditStr(06,20,60)                            
   call Charout,copies(" ",length(yy))
   /* Der folgende Befehl verhindert das Herumtanzen des Corsors  */
   /* nach der Eingabe von yy=EditStr(06,04,60).       Stelle q30 */
   Call SysCurState OFF
   signal on syntax name NVMsg1 
   st="y="strip(yy)
   interpret st
   if DataType(y, 'N')<>1 then
   do
     call Quatsch
     call Loesch 
     Call SysCurState ON
     signal neuexp
   end
  
  /* Berechnung des Betrages */
   if btr==0 & y==0 then Call Unbestimmt 
   if btr==0 then
   do
     Re3Erg=0
     Im3Erg=0
     signal we3
   end
   
   uu=y*0_ln(btr,ND)
   if    abs(uu)>=9.9E+7 then Call Unzul exp, uu,    "616"
   if abs(y*phi)>=9.9E+7 then Call Unzul exp, y*phi, "617"
       u=0_exp(uu,ND) 
  /* Berechnung der Winkelfunktionen */
   Recos=0_cos(y*phi,ND)
   IMsin=0_sin(y*phi,ND)
  /* Berechnung der Komponenten */
   Re3Erg=u*Recos   
   Im3Erg=u*Imsin   
   we3:
   /* Der folgende Befehl ist wichtig, um den Corsor wieder einzuschalten, */
   /* nachdem er an der Stelle  q30  ausgeschaltet wurde.                  */
   Call SysCurState ON
   call Ergebnis "(Re + Im*i)^("strip(yy)")", Re3Erg, Im3Erg, ND 
   call Auswahl
   signal PgmEnd
                                
expl:
  /* Berechnung des Betrages */
   if abs(Re)>=9.9E+7 then Call Unzul exp, Re, "635"
   if abs(Im)>=9.9E+7 then Call Unzul exp, Im, "636"
       u=0_exp(Re,ND)
  /* Berechnung der Winkelfunktionen */
   Recos=0_cos(Im,ND)
   IMsin=0_sin(Im,ND)
  /* Berechnung von Real- und Imaginrteil */
   Re4Erg=u*Recos  
   Im4Erg=u*Imsin  
  
   call VorAnz   "exp(Re + Im*i)", Re,     Im,     ND  
   call Ergebnis "exp(Re + Im*i)", Re4Erg, Im4Erg, ND 
   call Auswahl
   signal PgmEnd
  
hbhl:
   call SysCls
   call Locate 02,04;                            
   call Charout,"Calculation of the function "
   call Farb "b^(Re + Im*i)"
   call Locate 04,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 05,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;    
neuhbhl:   
   Call SysCurState ON
   call Locate 06,04
   call Charout,"                                                        "
   call Locate 06,04
   call Charout,"Basis  b  = "; bb=EditStr(06,17,60)
   call Charout,copies(" ",length(bb))
   /* Der folgende Befehl verhindert das Herumtanzen des Corsors */
   /* nach der Eingabe von bb=EditStr(06,04,60).       Stelle q50      */
   Call SysCurState OFF
   signal on syntax name NVMsg2 
   st="b="bb
   interpret st
   if DataType(b, 'N')<>1 then
   do
     call Quatsch
     call Loesch 
     Call SysCurState ON
     signal neuhbhl
   end 
  
   if b>0 then
   do
     ReRe=Re*0_ln(b,ND)
     ImIm=Im*0_ln(b,ND)
     signal w51
   end
   
   if b<0 then
   do
     b=abs(b)
     ReRe=Re*0_ln(b,ND)-Im*pi
     ImIm=Re*pi +Im*0_ln(b,ND)
     signal w51
   end
   
   if b==0 then
   do
     Re5Erg=0
     Im5Erg=0
     signal w52
   end
              
w51:                   
  /* Berechnung des Betrages */
   if abs(ReRe)>=9.9E+7 then Call Unzul exp, ReRe, "709"
   if abs(ImIm)>=9.9E+7 then Call Unzul exp, ImIm, "710"
       u=0_exp(ReRe,ND)
  /* Berechnung der Winkelfunktionen */
   Recos=0_cos(ImIm,ND)
   IMsin=0_sin(ImIm,ND)
  /* Berechnung von Real- und Imaginrteil */
   Re5Erg=u*Recos   
   Im5Erg=u*Imsin   
w52:      
   /* Der folgende Befehl ist wichtig, um den Corsor wieder einzuschalten, */
   /* nachdem er an der Stelle  q50  ausgeschaltet wurde.                  */
   Call SysCurState ON
   call Ergebnis "("strip(bb)")^(Re + Im*i)", Re5Erg, Im5Erg, ND 
   call Auswahl
   signal PgmEnd
   
lnlnl:
  /* Berechnung des Betrages */
   u=0_ln(btr, ND)
  /* Berechnung der Komponenten */
   Re6Erg=u   
   Im6Erg=phi   
  
   call VorAnz   "ln(Re + Im*i)", Re,     Im,     ND  
   call Ergebnis "ln(Re + Im*i)", Re6Erg, Im6Erg, ND 
   call Auswahl
   signal PgmEnd
   
logl:
  /* Berechnung des Betrages */
   u=0_ln(btr, ND)
  /* Berechnung der Komponenten */
   Re7Erg=u*m10   
   Im7Erg=phi*m10   
  
   call VorAnz   "log(Re + Im*i)", Re,     Im,     ND  
   call Ergebnis "log(Re + Im*i)", Re7Erg, Im7Erg, ND 
   call Auswahl
   signal PgmEnd
   
lab8:   
   call NochNicht
   call Loesch
   signal lfu
   
lab9:     
   call NochNicht
   call Loesch
   signal lfu
     
lab10:     
   call NochNicht
   call Loesch
   signal lfu
     
sinl:                                              
  /* Berechnung der Komponenten */
   Re11Erg=0_sin(Re,ND)*0_cosh(Im,ND)   
   Im11Erg=0_cos(Re,ND)*0_sinh(Im,ND)   
  
   call VorAnz   "sin(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "sin(Re + Im*i)", Re11Erg, Im11Erg, ND 
   call Auswahl
   signal PgmEnd
   
cosl:   
  /* Berechnung der Komponenten */
   Re12Erg=+0_cos(Re,ND)*0_cosh(Im,ND)   
   Im12Erg=-0_sin(Re,ND)*0_sinh(Im,ND)   
  
   call VorAnz   "cos(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "cos(Re + Im*i)", Re12Erg, Im12Erg, ND 
   call Auswahl
   signal PgmEnd
       
tanl:                
  /* Berechnung der Komponenten */
   Nen13=0_cos(2*Re,ND)+0_cosh(2*Im,ND)
   if Nen13==0 then
   do   
     call nenNull
     call Loesch
     Call SysCurState ON
     call SysCls
     signal Anf
   end
   Re13Erg=0_sin(2*Re,ND)/Nen13   
   Im13Erg=0_sinh(2*Im,ND)/Nen13   
  
   call VorAnz   "tan(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "tan(Re + Im*i)", Re13Erg, Im13Erg, ND 
   call Auswahl
   signal PgmEnd

cotl:
  /* Berechnung der Komponenten */
   Nen14=0_cosh(2*Im,ND)-0_cos(2*Re,ND)
   if Nen14==0 then
   do   
     call nenNull
     call Loesch
     Call SysCurState ON
     call SysCls
     signal Anf
   end
   Re14Erg=+0_sin(2*Re,ND)/Nen14   
   Im14Erg=-0_sinh(2*Im,ND)/Nen14   
  
   call VorAnz   "cot(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "cot(Re + Im*i)", Re14Erg, Im14Erg, ND 
   call Auswahl
   signal PgmEnd
   
sinhl:
  /* Berechnung der Komponenten */
   Re15Erg=0_sinh(Re,ND)*0_cos(Im,ND) 
   Im15Erg=0_cosh(Re,ND)*0_sin(Im,ND)   
  
   call VorAnz   "sinh(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "sinh(Re + Im*i)", Re15Erg, Im15Erg, ND 
   call Auswahl
   signal PgmEnd
                                        
coshl:                
  /* Berechnung der Komponenten */
   Re16Erg=0_cosh(Re,ND)*0_cos(Im,ND)   
   Im16Erg=0_sinh(Re,ND)*0_sin(Im,ND)   
  
   call VorAnz   "cosh(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "cosh(Re + Im*i)", Re16Erg, Im16Erg, ND 
   call Auswahl
   signal PgmEnd
   
tanhl:                
  /* Berechnung der Komponenten */
   Nen17=0_cosh(2*Re,ND)+0_cos(2*Im,ND)
   if Nen17==0 then
   do   
     call nenNull
     call Loesch
     Call SysCurState ON
     call SysCls
     signal Anf
   end
   Re17Erg=0_sinh(2*Re,ND)/Nen17   
   Im17Erg=0_sin(2*Im,ND)/Nen17   
  
   call VorAnz   "tanh(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "tanh(Re + Im*i)", Re17Erg, Im17Erg, ND 
   call Auswahl
   signal PgmEnd
   
cothl:      
  /* Berechnung der Komponenten */
   Nen18=0_cosh(2*Re,ND)-0_cos(2*Im,ND)
   if Nen18==0 then
   do   
     call nenNull
     call Loesch
     Call SysCurState ON
     call SysCls
     signal Anf
   end
   Re18Erg=+0_sinh(2*Re,ND)/Nen18   
   Im18Erg=-0_sin(2*Im,ND)/Nen18   
  
   call VorAnz   "coth(Re + Im*i)", Re,      Im,      ND  
   call Ergebnis "coth(Re + Im*i)", Re18Erg, Im18Erg, ND 
   call Auswahl
   signal PgmEnd
      
lab19:      
   call NochNicht
   call Loesch                                      
   signal lfu
      
PgmEnd:
   call Color 0,white
   call SysCls
"mode co80,25"
EXIT

/******************* Eigene Prozeduren und Funktionen **********************/


0lRe1:
  sch=2
  call lRe1
  
0lIm1:               
  sch=2             
  call lIm1

0lRe2:
  sch=2
  call lRe2
  
0lIm2:               
  sch=2             
  call lIm2
            
            
EditStr:
  Procedure
  parse arg PosY, PosX, l
  
  anf="47"; bckspc="08"; ende="4F";   enter="0D"; entf="53" 
  esc="1B"; links="4B";  rechts="4D"; tab="09"

AnfEditStr:
  call Locate PosY, PosX-1
  if l>=0 then call Charout,copies(" ",l+2)
  call Locate PosY, PosX
  k=1; i=1; si=""; sil=""; sir=""; u=1

  EditStrAnf:  
  do forever 
    /* Einlese-Befehl */
    ch=SysGetKey("noecho")
         
    /* Eingabetaste schlieแt die Eingabe ab. */
    if c2x(ch)==enter then leave   

    /* Escapetaste leert das Eingabefeld. */
    if c2x(ch)==esc & l>0 then Signal AnfEditStr
                                         
    /* Sondertasten, deren Tastencode zwei Symbole zurckliefert */
    if c2x(ch)=="00" | c2x(ch)=="E0" then
    do
      /* andere Variable hc unbedingt erforderlich ! */
      hc=SysGetKey("noecho")
      
      /* 1. Cursor nach links */
      if c2x(hc)==links & k>1 then
      do
        call CsrLeft
        k=k-1
        u=1
        signal EditStrAnf
      end
      /* 2. Cursor nach rechts */
      if c2x(hc)==rechts & k<l then
      do
        call CsrRight 
        k=k+1
        u=1
        signal EditStrAnf
      end

      /* 3. Cursor an den Anfang */
      if c2x(hc)==anf & k<=l+1 then
      do
        call Locate PosY, PosX
        k=1
        u=1
        signal EditStrAnf
      end

      /* 4. Cursor an das Ende */
      if c2x(hc)==ende & k<=l then
      do
        call Locate PosY, PosX+l-1
        k=l
        u=1
        signal EditStrAnf
      end
      
      /* 5. Entf-Taste einrichten (fr k>=1) */ 
      if c2x(hc)==entf & k>=1 then
      do
        lsi=length(si)
        call Locate PosY, PosX+k-1
        /* Cursor steht am Anfang des Eingabefeldes (k=1) */
        if k==1 then
        do
          if u==1 then a1=1
          if u>=2 then a1=0
          si=SubStr(si,2+a1) 
          u=u+1
          signal EditStrAnf
        end  
        
        /* Cursor steht nicht am Anfang des Eingabefeldes (k>=2) */
        if k>=2 then
        do
          sil=DelStr(si,k+1)
          sir=SubStr(si,k+2)
          si=sil||sir
        end  
        call Locate PosY, PosX-1        
        call Charout,copies(" ",l+2) 
        if k==1 then a2=0
        if k>=2 then a2=-1
        call Locate PosY, PosX+a2  
        call Charout,si 
        call Locate PosY, PosX+k-1
        signal EditStrAnf
      end
   
    signal EditStrAnf
    end /* Sondertasten, deren Tastencode zwei Symbole zurckliefert */
       
    /* Backspace-Taste einrichten (nur fr k>1) */
    if c2x(ch)==BckSpc & k==1 then
    do
       ch=""
       k=k-1
    end   
    if c2x(ch)==BckSpc & k>1 then
    do 
      lt=length(si)
      ll=l-k+1
      sil=DelStr(si,k)
      sir=SubStr(si, k+1, ll)
      call Locate PosY, PosX-1
      si=sil||sir
      call Charout,copies(" ",l+2)
      call Locate PosY, PosX-1
      call Charout,si
      call Locate PosY, PosX+k-2
      k=k-1
      signal EditStrAnf
    end  
                             
    /* Tabtaste wird ignoriert */
    if c2x(ch)==tab then
    do
      ch=""
      k=k-1
    end
 
    /* Es werden nur erlaubte Zeichen eingelesen. */
    if k<=l then
    do
      call Charout,ch
      si=Overlay(ch, si, k+1)                                   
      call Locate PosY, PosX+k
    end
    /* Bedingung k<=l ist wichtig ! */
    if k<=l then k=k+1

  end /* do forever */

/* Ausgabe-Vorbereitung */
/*  call Locate PosY, PosX-1
  call Charout,copies(" ",l+2) */
  call Locate PosY, PosX-1
  call Charout,si
  
  /* Die folgenden zwei Zeilen sind unbedingt erforderlich, weil in        */
  /* dieser Funktion "EditStr" beim Abschluแ der Eingabe mit "Enter" das   */
  /* hexadezimale Zeichen 0D (dezimal: 13) angehngt wird.                 */
  /* (Eine Ausnahme liegt dann vor, wenn genau soviele Zeichen eingegeben  */
  /* werden, wie es die zulssige Lnge des Eingabestrings erlaubt.)       */
  /* Da dieses Zeichen zu den ASCII-Steuerzeichen geh”rt und somit von     */
  /* einem Editor nicht in einen Quelltext eingefgt werden kann, muแ fr  */
  /* REXX-Funktion "Pos" das Zeichen 0D mit Hilfe der REXX-Funktion x2c()  */
  /* dargestellt werden, also mit  x2c(0D).                                */
  q0D=Pos(x2c(0D), si)
  if q0D>0 then si=DelStr(si,q0D)
/*  return(Substr(si,2)||" ") *//* Ende EditStr */
  return(strip(si)) /* Ende EditStr */ 
 
                  
Farb:
   arg str
   /* parse value str with bernimmt immer groแe Buchstaben */
   parse value str with s1'RE's2'IM's3
   kl="abcdefghijklmnopqrstuvwxyz”";  gr="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   s1=translate(s1, kl, gr)
   s2=translate(s2, kl, gr)  
   s3=translate(s3, kl, gr) 
   
   call Color 1,white;    call Charout,s1
   call Color 1,yellow;   call Charout,"Re"
   call Color 1,white;    call Charout,s2
   call Color 1,yellow;   call Charout,"Im"
   call Color 1,white;    call Charout,s3
   call Color 0,white;     
   return

 
VorAnz:
   call SysCls
   parse arg st1,intRe,IntIm,ND
   call Locate 02,04
   call Charout,"Calculation of the function "
   call Farb st1
   call Locate 04,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(intRe,,ND,,0)
   call Locate 05,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(intIm,,ND,,0)
   call Color 0,white;    
   return

 
Quatsch:  
   Call SysCurState OFF
   call Color 1,cyan,cyan
   call Locate 20,03
   say"ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
   call Locate 21,03
   say"บ                                                                         บ"
   call Locate 22,03
   say"บ                                                                         บ"
   call Locate 23,03
   say"บ                                                                         บ"
   call Locate 24,03
   say"ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
   call Locate 22,17
   call Charout,"!! The edited String is no valid REXX number !!"                              
   call Locate 24,29
   call Color 1,Green,green
   call Charout," Back with return "
   call Color 0,white;    
   Beep(250, 200)
   q=EditStr(25,1,0)
   Call SysCurState ON
   return                              
 
   
nenNull:  
   Call SysCurState OFF
   call Color 1,cyan,cyan
   call Locate 19,03
   say"ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
   call Locate 20,03
   say"บ                                                                         บ"
   call Locate 21,03
   say"บ                                                                         บ"
   call Locate 22,03
   say"บ                                                                         บ"
   call Locate 23,03
   say"บ                                                                         บ"
   call Locate 24,03
   say"ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
   call Locate 21,20
   call Charout,"!! While calculeting a function value !!"
   call Locate 22,24
   call Charout,"!! a denominator equals zero !!"
   call Locate 24,32
   call Color 1,Green,Green
   call Charout," Back with return "
   call Color 0,white;    
   Beep(250, 200)
   q=EditStr(25,1,0)
   return                              
  
    
Unbestimmt:  
   Call SysCurState OFF
   call Color 1,cyan,cyan
   call Locate 20,03
   say"ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
   call Locate 21,03
   say"บ                                                                         บ"
   call Locate 22,03
   say"บ                                                                         บ"
   call Locate 23,03
   say"บ                                                                         บ"
   call Locate 24,03
   say"ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
   call Locate 22,10
   call Charout,"!! This calculation has an indefinite result !!"
   call Locate 24,24
   call Color 1,Green,Green
   call Charout," Back with return "
   call Color 0,white;    
   Beep(250, 200)
   q=EditStr(25,1,0)
   Call SysCls
   Call SysCurState ON
   Signal Anf
   return
    
                                
NochNicht:  
   Call SysCurState OFF
   call Color 1,cyan,cyan
   call Locate 20,03
   say"ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
   call Locate 21,03
   say"บ                                                                         บ"
   call Locate 22,03
   say"บ                                                                         บ"
   call Locate 23,03
   say"บ                                                                         บ"
   call Locate 24,03
   say"ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
   call Locate 22,19
   call Charout,"!! A function is not yet implemented here!!"
   call Locate 24,32
   call Color 1,Green,Green
   call Charout," Back with return "
   call Color 0,white;    
   Beep(250, 200)
   q=EditStr(25,1,0)
   Call SysCurState ON
   return
 
                     
Loesch:  
   call Locate 19,03
   call Locate 20,03
   say"                                                                           "
   call Locate 21,03
   say"                                                                           "
   call Locate 22,03
   say"                                                                           "
   call Locate 23,03
   say"                                                                           "
   call Locate 24,03
   say"                                                                           "
   call Locate 22,12
   return                              
 
   
Ergebnis: /* Diese Prozedur kann fast alle Ergebnisse ausgeben. */
          /* Ausnahmen sind die Funktionen 1 und 2.             */
   parse arg st1,ReErg,ImErg,ND
   call Locate 08,04
   call Charout,"The components "
   call Color 1,white;    call Charout,"ErgRe"
   call Color 0,white;    call Charout," und "
   call Color 1,white;    call Charout,"ErgIm"
   call Color 0,white;    
   call Charout," of the calculated complex number"
   call Locate 10,04
   call Farb st1
   call Locate 12,04
   call Charout,"are:"
   call Locate 14,04
   call Color 1,white;    call Charout,"ErgRe"
   call Color 0,white;    call Charout," = "
   call Color 1,cyan;     call Charout,Format(ReErg,,ND,,0)
   call Locate 15,04       
   call Color 1,white;    call Charout,"ErgIm"
   call Color 0,white;    call Charout," = "
   call Color 1,cyan;    call Charout,Format(ImErg,,ND,,0)
   call Locate 17,04
   call Color 0,white;    
   call Charout,"========================================================="
   call Locate 19,04
   call Charout,"Should of the complex number "
   call Farb "(Re + Im*i)"
   call Color 0,white;
   call Charout," with the components" 
   call Locate 21,04
   call Color 1,yellow;   call Charout,"Re"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Re,,ND,,0)
   call Locate 22,04
   call Color 1,yellow;   call Charout,"Im"
   call Color 0,white;    call Charout," = "
   call Color 1,green;    call Charout,Format(Im,,ND,,0)
   call Color 0,white;    
   return

 
Auswahl:
q3q:   
   call Locate 24,50
   call Charout,"                           "   
   call Locate 24,04
   call Charout,"another funktion be calculated ? (y,n) "   
   call Locate 24,50; qqq=EditStr(24,43,1) 
                 
   select
      when qqq==' ' | qqq=='y' | qqq=='Y' then do; Signal andere; end
      when qqq=='n' | qqq=='N' then do; Signal PgmEnd; end
      otherwise
      do
        Call SysCurState OFF
        Beep(250, 200)
        Call SysCurState ON
        signal q3q
      end
   end
   return                             
 
                           
Unzul:
   parse arg fnkt, st, zeile
   Call SysCurState OFF
   call Color 1,cyan,cyan
   call Locate 04,02
   say"ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
   call Locate 05,02
   say"บ                                                                            บ"
   call Locate 06,02
   say"บ                                                                            บ"
   call Locate 07,02
   say"บ                                                                            บ"
   call Locate 08,02
   say"บ                                                                            บ"
   call Locate 09,02
   say"บ                                                                            บ"
   call Locate 10,02
   say"บ                                                                            บ"
   call Locate 11,02
   say"บ                                                                            บ"
   call Locate 12,02
   say"บ                                                                            บ"
   call Locate 13,02
   say"บ                                                                            บ"
   call Locate 14,02
   say"บ                                                                            บ"
   call Locate 15,02
   say"บ                                                                            บ"
   call Locate 16,02
   say"บ                                                                            บ"
   call Locate 17,02
   say"บ                                                                            บ"
   call Locate 18,02
   say"บ                                                                            บ"
   call Locate 19,02
   say"บ                                                                            บ"
   call Locate 20,02
   say"บ                                                                            บ"
   call Locate 21,02
   say"บ                                                                            บ"
   call Locate 22,02
   say"บ                                                                            บ"
   call Locate 23,02
   say"บ                                                                            บ"
   call Locate 24,02
   say"ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
   call Locate 06,06
   call Charout,"Source code line: "
   call Locate 06,26
   call Color 1,white,cyan
   call Charout,zeile
   call Locate 10,06
   call Color 1,yellow,cyan 
   call Charout,"While calculating the function "
   call Locate 12,06
   call Color 1,white,cyan
   call Charout,fnkt"("st")"
   call Color 1,yellow,cyan
   call Locate 14,06
   call Charout,"the function argument "
   call Locate 16,06
   call Color 1,white,cyan
   call Charout,st
   call Color 1,yellow,cyan
   call Locate 19,06
   call Charout,"was out of the allowable area."
   call Locate 20,06
   call Charout,"For details of the allowable areas of function arguments"
   call Locate 21,06
   call Charout,"look to kmpl_e.INF !"
   call Locate 24,32
   call Color 1,Green,Green
   call Charout," Back with return "
   call Color 0,white;    
   Beep(250, 200)
   q=EditStr(25,1,0)
   Call SysCurState ON
   call SysCls
   signal Anf
   return     
 
 
nvMsg1: 
   Call SysCurState OFF
   Beep(250, 200)
   signal neuexp
 
 
nvMsg2: 
   Call SysCurState OFF
   Beep(250, 200)
   signal neuhbhl
 
 
   
                            
/*---------------------------- ANSI-Prozeduren ----------------------------*/
/* Ansi Procedures for moving the cursor */
Locate: Procedure   /*  Call Locate Row,Col */
Row = arg(1)
Col = Arg(2)
Rc = Charout(,D2C(27)"["Row";"col"H")
return ""

CsrUp: Procedure  /* CsrUp(Rows) */
Arg u
Rc = Charout(,D2C(27)"["u"A")
return ""

CsrDown: Procedure /* CsrDn(Rows) */
Arg d
Rc = Charout(,D2C(27)"["d"B")
return ""

CsrRight: Procedure  /* CsrRight(Cols) */
arg r
Rc = Charout(,D2C(27)"["r"C")
Return ""

CsrLeft: procedure  /* CsrLeft(Cols) */
arg l
Rc = Charout(,D2C(27)"["l"D")
Return ""


/*
A------------------------------------------------------------:*
SaveCsr and PutCsr are meant to be used together for saving  :*
and restoring the cursor location. Do not confuse            :*
with Locate, CsrRow, CsrCol, these are different routines.   :*
SaveCsr Returns a string that PutCsr can use.                :*
A:*/
SaveCsr: procedure  /* cursor_location = SaveCsr() (for PutCsr(x))*/
Rc = Charout(,D2C(27)"[6n")
Pull Q
Call CsrUp
return Q

PutCsr: procedure  /* Call PutCsr <Previous_Location>  (From SaveCsr() ) */
Where = arg(1)
Rc = Charout(,substr(Where,1,7)"H")
return ""
/*
A:*/
/* clear screen :*/
Cls: Procedure      /* cls() Call Cls */
Rc = CharOut(,D2C(27)"[2J")
return ""

    /* get cursors Line */
CsrRow: Procedure      /* Row = CsrRow()*/
Rc = Charout(,D2C(27)"[6n")
Pull Q
Return substr(Q,3,2)

   /* get cursors column */
CsrCol: Procedure          /*  Col = CsrCol()  */
Rc = Charout(,D2C(27)"[6n")
Pull Q
return Substr(Q,6,2)

                 
Color:     /* Call Color <Attr>,<ForeGround>,<BackGround>                */  
Procedure  /* Attr=1 -> HIGH;  Attr=0 -> LOW; Attr only for ForeGround ! */
arg A,F,B   
CLRS = "BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE"
A=strip(A); if length(A)==0 then A=0    
F=strip(F); if length(F)==0 then F=WHITE
B=strip(B); if length(B)==0 then B=BLACK
return CHAROUT(,D2C(27)||"["A";"WORDPOS(F,CLRS)+29";"WORDPOS(B,CLRS)+39"m")
                 
EndAll:
Call Color "White","Black"
CALL CsrAttrib "Normal"
