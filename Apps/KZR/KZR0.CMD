/* kzr0.CMD */
   pi=3.141592653589793238462643383279502884197169399375105820975
   ND=48
   Numeric Digits ND
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   Pfd=SysSearchPath("PATH", "kzr0.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   bufND =Pfd||"NDZahl.DAT"
   ret=LineOut(bufND, ND)
   signal on syntax name Fehlermeld

   parse upper arg str;   str=strip(str)
 
   if (length(str)= 0) then
   do; "start /PM /MAX view.exe" Pfd||"KZR.INF"; EXIT; end

   st1=str
   if Pos(":",       st1) > 0 then st2=Flt2(st1); else st2=st1
   if Pos("DIVGANZ", st2) > 0 then st3=Flt3(st2); else st3=st2
   if Pos("DIVREST", st3) > 0 then st4=Flt4(st3); else st4=st3
   say
                                                    
   if Pos("D2X", st4)>0 | Pos("X2D", st4)>0 |,
      Pos("B2X", st4)>0 | Pos("X2B", st4)>0 |,
      Pos("D2B", st4)>0 | Pos("B2D", st4)>0 | Pos("PRIM", st4)>0 then Signal FalschRuf

   Numeric Digits ND+6
   interpret "z="st4
          
   if DataType(z, N) <> 1 then Signal Fehlermeld
   if DataType(z, N)  = 1 then
   do
     Numeric Digits ND
     zz=Format(z)
     st10=ErgFormat(zz)
   end
   else st10=z
   say st4 "= "st10

PgmEnd:
   Call charout(bufND);   Call SysFileDelete bufND
   Dummy=MinNDA()
EXIT
  
Flt2:
  Procedure 
  arg sti
  n=Pos(":", sti); 
  l=length(":")
  sti=Overlay("/",sti, n, l)
  Return(sti)

Flt3:
  Procedure
  parse arg str
  i=1; st3.i=str
  Anf3:
  j=i+1
  l3.i=Pos("DIVGANZ", st3.i); if l3.i > 0 then Signal w31
  w31:
  if l3.i=0 then Signal w3e
  sub3.i=SubStr(st3.i, l3.i, 7)
  st3.i =DelStr(st3.i, l3.i, 7)
  if  sub3.i=="DIVGANZ" then neu3.i="%"
  st3.j=Insert(neu3.i, st3.i, l3.i-1  ); st3=st3.j
  i=i+1
  signal Anf3
  w3e:
  Return(st3)
                    
Flt4:
  Procedure
  parse arg str
  i=1; st4.i=str
  Anf4:
  j=i+1
  l4.i=Pos("DIVREST", st4.i); if l4.i > 0 then Signal w41
  w41:
  if l4.i=0 then Signal w4e
  sub4.i=SubStr(st4.i, l4.i, 7)
  st4.i =DelStr(st4.i, l4.i, 7)
  if  sub4.i=="DIVREST" then  neu4.i="//"
  st4.j=Insert(neu4.i, st4.i, l4.i-1  ); st4=st4.j
  i=i+1
  signal Anf4
  w4e:
  Return(st4)

ErgFormat:
  Procedure
  arg u
  if Pos(".", u)>0 & Pos("E", u)=0 then
  do
    do forever
      lu=length(u)
      if Pos("0", u, lu) > 0 then u=DelStr(u, lu); else leave
    end
    lu=length(u)
    if Pos(".", u) = lu then u=DelStr(u, lu)
  end
  Return(u)
   
Fehlermeld:   
  Beep(444, 200); Beep(628,300)
  Call Charout,"Fehlerhafte Eingabe oder Funktion nicht verfÅgbar ! "; say
  signal PgmEnd
                                                                                
FalschRuf:
  say
  Call Charout,"Die Umwandlungsfunktionen"; say; say
  Call Charout,"D2X, X2D, B2X, X2B, D2B  und  B2D"; say; say
  call Charout,"sowie die Funktion  Prim.CMD  zur Primfaktor-Zerlegung"; say
  call Charout,"dÅrfen nur von der Kommandozeile direkt und ohne den"; say
  call Charout,"vorangesetzten Teilstring  'kzr xy,'  eingegeben werden."; say; say
  call Charout,"(NÑheres dazu in der kzr.INF)"
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd
