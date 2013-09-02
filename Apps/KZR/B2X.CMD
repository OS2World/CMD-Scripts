/* REXX-Programm B2X.CMD                                 */
/* B2X.CMD wandelt binÑre Zahlen in hexadezimale Zahlen. */
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call Color 1,white
   call SysCls
   Signal on syntax name B2XMsg

   /* Die Dateien "kzr.INF" und "krz.CMD   */
   /* befinden sich im selben Verzeichnis. */
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)

   Numeric Digits 24
 
   parse UPPER arg strstr
   
   /* Im Eingabestring strstr gibt es ein Komma. */
   if Pos(",", strstr)>0 then
   do
     Call Komma strstr
   end
   
   /* ZwischenrÑume aus dem String  strstr  entfernen */
   do forever
     lzw=Pos(" ", strstr)
     if lzw = 0 then leave
     strstr=DelStr(strstr,lzw,1)
   end
   
   if (length(strstr)= 0) then
   do
     "start view.exe" Pfd||"KZR.INF B2X"
     EXIT
   end
   
   /* Im Eingabestring strstr gibt es keinen Punkt. */
   if Pos(".", strstr)==0 then
   do
     stA=strstr 
     stV=strstr
     stN=""
     if DataType(stV, 'B')<>1 then Call EingStr stV
     Signal WW
   end

   /* Im Eingabestring gibt es einen Punkt */
   if Pos(".", strstr)>0 then
   do
     parse UPPER value strstr with stV '.' stN
     stA=stV||'.'||stN
     if length(strip(stV))=0 & length(strip(stN)) =0 then Call Nichts  
     if length(strip(stV))>0 & DataType(stV, 'B')<>1 then Call EingStr stV
     if length(strip(stN))>0 & DataType(stN, 'B')<>1 then Call EingStr stN
   end

WW:
   stV=strip(stV) 
   if length(stV)>0 then 
   do
     stV=B2XInt(stV, NM)
   end

   stN=strip(stN) 
   if length(stN)>0 then
   do
     stN=B2XMant(stN, NM)
   end
  
   stG=stV||stN

   /* Anfang der Ausgabe-Anweisungen */
   say
   Call Color 1,White
   Call Charout,"  Eingabe:"; say
   Call Color 1,Red
   Call Charout,"        BinÑr: "
   Call Color 1,White
   Call Charout,stA; say; say
   Call Color 1,White
   Call Charout,"  Ausgabe:"; say
   Call Color 1,green
   Call Charout,"  Hexadezimal: "
   Call Color 1,White
   Call Charout,strip(stG); say
   /* Ende der Ausgabe-Anweisungen */

PgmEnd:
   say
   Call Color 0,White
EXIT


B2XInt:
   Procedure
   parse upper arg s

   /* Durch EinfÅgen  f Å h r e n d e r  Ziffern  0                  */ 
   /* die LÑnge des Strings auf ein ganzes Vielfaches von 4 bringen. */ 
   do forever 
     if length(s)//4 == 0 then leave
     s=Insert("0", s, 0)
   end /* do */

   /* Der ganzzahlige Anteil wird in Gruppen zu je 4 Stellen zerlegt. */
   i=1
   do forever
     l.i=length(s);
     if l.i==0 then leave
     l.i=length(s); 
     b.i=SubStr(s, l.i-3, 4)
     s=DelStr(s, l.i-3, 4)
     i=i+1
   end /* do */
   m=i
   
   HEX=""
   do i=1 to m
     /* Hier noch nicht A bis F fÅr 10 bis 15 */
     if DataType(strip(b.i), 'W')<>1 then leave
     /* Umwandlung der Zahlen 10 bis 15 in die Buchstaben A bis F */
     HEX=HEX||Bin2Hex(b.i)
   end /* do */
   HEX=REVERSE(HEX)

   /* Nullen am  A n f a n g   des Strings werden entfernt. */ 
   do forever
      if Pos("0", HEX, 1) <>1 then leave 
      HEX=SubStr(HEX, 2)
   end /* do */

   Return(HEX)


B2XMant:
   Procedure
   parse upper arg s

   /* Durch EinfÅgen von Ziffern  0  am  E n d e  des Strings        */ 
   /* die LÑnge des Strings auf ein ganzes Vielfaches von 4 bringen. */ 
   do forever 
     ls=length(s)
     if ls//4 == 0 then leave
     s=Insert("0", s, ls)
   end /* do */
   
   i=1 ; HEX="."
   do forever
     l.i=length(s);
     if l.i==0 then leave
     l.i=length(s); 
     b.i=SubStr(s, 1, 4)
     HEX=HEX||Bin2Hex(b.i)
     s=DelStr(s, 1, 4)
     i=i+1
   end /* do */

   /* Nullen am  E n d e  des Strings werden entfernt. */ 
   do forever
      l=length(HEX)
      if Pos("0", HEX, l)==0 then leave 
      HEX=DelStr(HEX, l)
   end /* do */

   Return(HEX)


Bin2Hex:
  arg b
  select
    when b == 0000 then x = '0'
    when b == 0001 then x = '1'
    when b == 0010 then x = '2'
    when b == 0011 then x = '3'
    when b == 0100 then x = '4'
    when b == 0101 then x = '5'
    when b == 0110 then x = '6'
    when b == 0111 then x = '7'
    when b == 1000 then x = '8'
    when b == 1001 then x = '9'
    when b == 1010 then x = 'A'
    when b == 1011 then x = 'B'
    when b == 1100 then x = 'C'
    when b == 1101 then x = 'D'
    when b == 1110 then x = 'E'
    when b == 1111 then x = 'F'
  otherwise NOP
  end  /* select */
  Return(x)


EingStr:
  say
  parse upper arg stst 
  Call Color 1,White
  Call Charout,"Sie haben in den String "
  Call Color 1,Cyan
  /* FÅr die Anzeige der aktuellen Berechnung sollen die von  B2X.CMD  */
  /* in gro·e Buchstaben umgewandelte kleinen Buchstaben wieder        */
  /* in kleine Buchstaben umgewandelt werden.                          */
  kl="abcdefghijklmnopqrstuvwxyzÑîÅ";  gr="ABCDEFGHIJKLMNOPQRSTUVWXYZéôö"
  stst=translate(stst, kl, gr)
  Call Charout,stst; say
  Call Color 1,White
  Call Charout,"der Eingabe-Kette ein oder mehrere"; say
  Call Charout,"fÅr binÑre Darstellung nicht erlaubte Zeichen eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd


Nichts:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"weder fÅr den ganzzahligen Anteil noch fÅr die Mantisse"; say
  Call Charout,"eine BinÑrzahl eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd


Komma:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette "
  Call Color 1,Cyan
  Call Charout,strstr; say
  Call Color 1,White
  Call Charout,"ein im Argument der Funktion "
  Call Color 1,Green
  Call Charout,"B2X.CMD"
  Call Color 1,White
  Call Charout," verbotenes Komma eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd
 

B2XMsg:
   say
   Call Color 1,White
   Call Charout,"Sie haben bei der Eingabe der Umwandlungs-Aufgabe"; say
   Call Charout,"eines oder mehrere fÅr binÑre Darstellung nicht erlaubte "
   Call Charout,"Zeichen eingegeben."; say
   Beep(444, 200); Beep(628,300)
   Signal PgmEnd

/***************************** ANSI-Prozeduren ******************************/


Color:     /* Call Color <Attr>,<ForeGround>,<BackGround>                */  
Procedure  /* Attr=1 -> HIGH;  Attr=0 -> LOW; Attr only for ForeGround ! */
arg A,F,B   
CLRS = "BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE"
A=strip(A); if length(A)==0 then A=0    
F=strip(F); if length(F)==0 then F=WHITE
B=strip(B); if length(B)==0 then B=BLACK
return CHAROUT(,D2C(27)||"["A";"WORDPOS(F,CLRS)+29";"WORDPOS(B,CLRS)+39"m")
