/* REXX-Programm X2B.CMD                                    */
/* X2B.CMD wandelt hexadezimale Zahlen in binÑre Zahlen um. */
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call Color 1,white
   call SysCls
   Signal on syntax name X2BMsg

   /* Die Dateien "kzr.INF" und "krz.CMD   */
   /* befinden sich im selben Verzeichnis. */
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)

   Numeric Digits 24
 
   parse UPPER arg strstr
   stE=strstr
   /* ZwischenrÑume aus dem String  strstr  entfernen */
   do forever
     lzw=Pos(" ", strstr)
     if lzw = 0 then leave
     strstr=DelStr(strstr,lzw,1)
   end

   if (length(strstr)= 0) then
   do
     "start view.exe" Pfd||"KZR.INF X2B"
     EXIT
   end

   /* Im Eingabestring strstr gibt es ein Komma. */
   if Pos(",", strstr)>0 then
   do
     Call Komma strstr
   end

   /* Im Eingabestring strstr gibt es keinen Punkt. */
   if Pos(".", strstr)==0 then
   do
     stA=strstr 
     stV=strstr
     stN=""
     if DataType(stV, 'X')<>1 then Call EingStr stV
     Signal WW
   end

   /* Im Eingabestring gibt es einen Punkt */
   if Pos(".", strstr)>0 then
   do
     parse UPPER value strstr with stV '.' stN
     stA=stV||'.'||stN
     if length(strip(stV))=0 & length(strip(stN)) =0 then Call Nichts  
     if length(strip(stV))>0 & DataType(stV, 'X')<>1 then Call EingStr stV
     if length(strip(stN))>0 & DataType(stN, 'X')<>1 then Call EingStr stN
   end

WW:
   stV=strip(stV) 
   if length(stV)>0 then 
   do
     stV=X2BInt(stV)
   end

   stN=strip(stN) 
   if length(stN)>0 then
   do
     stN=X2BMant(stN)
   end
  
   stG=stV||stN

   /* Anfang der Ausgabe-Anweisungen */
   say
   Call Color 1,White
   Call Charout,"  Eingabe:"; say
   Call Color 1,Red
   Call Charout,"  Hexadezimal: "
   Call Color 1,White
   Call Charout,stA; say; say
   Call Color 1,White
   Call Charout,"  Ausgabe:"; say
   Call Color 1,green
   Call Charout,"        BinÑr: "
   Call Color 1,White
   Call Charout,strip(stG); say
   /* Ende der Ausgabe-Anweisungen */

PgmEnd:
   say
   Call Color 0,White
EXIT


X2BInt:
   Procedure
   parse upper arg s
 
   /* Der ganzzahlige Anteil wird in die einzelnen HEX-Ziffern zerlegt */
   /* und in binÑre Zahlen mit je 4 Ziffern 1 oder 0 umgewandelt.      */
   i=1; BIN=""
   do forever
     l.i=length(s)
     if l.i==0 then leave
     b.i=SubStr(s, 1, 1)
     s=DelStr(s, 1, 1)
     BIN=BIN||Hex2Bin(b.i)
     i=i+1
   end /* do */

   /* Nullen am  A n f a n g   des Strings werden entfernt. */ 
   do forever
      if Pos("0", BIN, 1) <>1 then leave 
      BIN=SubStr(BIN, 2)
   end /* do */

   Return(BIN)


X2BMant:
   Procedure
   parse upper arg s

   
   /* Die Mantisse wird in die einzelnen HEX-Ziffern zerlegt      */
   /* und in binÑre Zahlen mit je 4 Ziffern 1 oder 0 umgewandelt. */
   i=1 ; BIN="."
   do forever
     l.i=length(s);
     if l.i==0 then leave
     b.i=SubStr(s, 1, 1)
     BIN=BIN||Hex2Bin(b.i)
     s=DelStr(s, 1, 1)
     i=i+1
   end /* do */

   /* Nullen am  E n d e  des Strings werden entfernt. */ 
   do forever
      l=length(BIN)
      if Pos("0", BIN, l)==0 then leave 
      BIN=DelStr(BIN, l)
   end /* do */

   Return(BIN)


Hex2Bin:
  arg b
  select
    when b == '0' then x = 0000
    when b == '1' then x = 0001
    when b == '2' then x = 0010
    when b == '3' then x = 0011
    when b == '4' then x = 0100
    when b == '5' then x = 0101
    when b == '6' then x = 0110
    when b == '7' then x = 0111
    when b == '8' then x = 1000
    when b == '9' then x = 1001 
    when b == 'A' then x = 1010
    when b == 'B' then x = 1011
    when b == 'C' then x = 1100
    when b == 'D' then x = 1101
    when b == 'E' then x = 1110
    when b == 'F' then x = 1111
  otherwise NOP
  end  /* select */
  Return(x)


EingStr:
  say
  parse upper arg stst 
  Call Color 1,White
  Call Charout,"Sie haben in den String "
  Call Color 1,Cyan
  /* FÅr die Anzeige der aktuellen Berechnung sollen die von  X2B.CMD  */
  /* in gro·e Buchstaben umgewandelte kleinen Buchstaben wieder        */
  /* in kleine Buchstaben umgewandelt werden.                          */
  kl="abcdefghijklmnopqrstuvwxyzÑîÅ";  gr="ABCDEFGHIJKLMNOPQRSTUVWXYZéôö"
  stst=translate(stst, kl, gr)
  Call Charout,stst; say
  Call Color 1,White
  Call Charout,"der Eingabe-Kette ein oder mehrere"; say
  Call Charout,"fÅr hexadezimale Darstellung nicht erlaubte Zeichen eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd


Nichts:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"weder fÅr den ganzzahligen Anteil noch fÅr die Mantisse"; say
  Call Charout,"eine Hexadezimalzahl eingegeben."; say
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
  Call Charout,"X2B.CMD"
  Call Color 1,White
  Call Charout," verbotenes Komma eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd
 

X2BMsg:
   say
   Call Color 1,White
   Call Charout,"Sie haben bei der Eingabe der Umwandlungs-Aufgabe"; say
   Call Charout,"eines oder mehrere fÅr hexadezimale Darstellung "; say
   Call Charout,"nicht erlaubte Zeichen eingegeben."; say
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
