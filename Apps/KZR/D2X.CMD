/* REXX-Programm D2X.CMD                                   */
/* D2X.CMD wandelt dezimale Zahlen in hexadezimale Zahlen. */               
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call Color 1,white
   call SysCls
   Signal on syntax name D2XMsg  

   /* Die Dateien "kzr.INF" und "krz.CMD   */
   /* befinden sich im selben Verzeichnis. */
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)

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
     "start view.exe" Pfd||"KZR.INF D2X"
     EXIT
   end

   ll=length(strstr)
   ND=2*ll+200
   Numeric Digits ND

   if Pos(".", strstr)>0 & Pos(",", strstr)==0 then Call kommav

   /* Im Eingabestring strstr gibt es weder Komma noch Punkt. */
   if Pos(",", strstr)==0 & Pos(".", strstr)==0 then
   do
   /* Der Eingabestring strstr wird gleich str. */
     stA=strstr 
     stV=strstr
     stN=""
     if DataType(stV, 'W')<>1 then Call EingStr stV
     Signal WW
   end

   /* Im Eingabestring gibt es ein Komma, aber keinen Punkt */
   if Pos(",", strstr)>0 & Pos(".", strstr)=0 then
   do
     parse UPPER value strstr with NM ',' str
     stA=str
     stV=str
     stN=""
     if DataType(NM , 'W')<>1 then Call FalschNum NM
     if DataType(NM , 'W')=1 & NM<2 then Call FalschNum NM
     if DataType(stV, 'W')<>1 then Call EingStr stV
     Signal WW
   end

   /* Im Eingabestring gibt es sowohl ein Komma als auch einen Punkt */
   if Pos(",", strstr)>0 & Pos(".", strstr)>0 then
   do
     parse UPPER value strstr with NM ',' stV '.' stN
     stA=stV||'.'||stN
     if DataType(NM , 'W')<>1 then Call FalschNum NM
     if DataType(NM , 'W')=1 & NM<2 then Call FalschNum NM
     if length(strip(stV))=0 & length(strip(stN)) =0 then Call Nichts  
     if length(strip(stV))>0 & DataType(stV, 'W')<>1 then Call EingStr stV
     if length(strip(stN))>0 & DataType(stN, 'W')<>1 then Call EingStr stN
   end

WW:
   /* Die fÅr die Berechnung einer Mantisse gewÅnschte Anzahl     */
   /* der Dezimalstellen wird mit der Variablen  NM  eingestellt. */
   NM=strip(NM)
   if NM=="" then NM=20    

   stV=strip(stV) 
   if length(stV)>0 then 
   do
     stV=D2X(stV)
   end

   stN=strip(stN) 
   if length(stN)>0 then
   do
     stN=D2XMant(stN, NM)
     stN=SubStr(stN, 2)
   end
  
   stG=stV||stN

   /* Anfang der Ausgabe-Anweisungen */
   say
   Call Color 1,White
   Call Charout,"  Eingabe:"; say
   Call Color 1,Red
   Call Charout,"      Dezimal: "
   Call Color 1,White
   Call Charout,stA; say; say


   if length(stN)>0 then
   do
     call Color 0,white
     Call Charout,"  Kann die Mantisse der gewÅnschten Hexadezimalzahl,"; say
     Call Charout,"  wie es in den meisten FÑllen der Fall ist,"; say
     Call Charout,"  nur als "
     call Color 1,white
     Call Charout,"NÑherungs-Ergebnis"
     call Color 0,white
     Call Charout," berechnet werden,"; say
     Call Charout,"  so wird die Mantisse mit bis zu "
     call Color 1,white
     Call Charout,NM
     call Color 0,white
     Call Charout," Stellen ausgegeben."; say
   end

   say
   Call Color 1,White
   Call Charout,"  Ausgabe:"; say
   Call Color 1,green
   Call Charout,"  Hexadezimal: "
   Call Color 1,White
   Call Charout,strip(stG); say
   /* Ende der Ausgabe-Anweisungen */

PgmEnd:
   say
   call Color 0,white
EXIT


D2XMant:
   Procedure
   parse upper arg str, NM
   Numeric Digits NM+10
   str=strip(str)

   str="0."||str
   i=1; j=i-1; stN.0=str; HEX="."
   do forever
     stN.i=stN.j*16
     stZ.i=trunc(stN.i)
     stN.i=stN.i-stZ.i
     if stN.j==0 | i>=NM then leave
     stZ.i=HEXFil(stZ.i)
     HEX=HEX||stZ.i
     i=i+1; j=i-1
   end

   /* AngehÑngte Ziffern '0' werden entfernt. */
   /* String wird umgedreht.                  */
   HEX=Reverse(HEX)
   /* FÅhrende Ziffern '0' werden entfernt.   */
   do forever
     if SubStr(HEX, 1, 1) >"0" then leave
     if SubStr(HEX, 1, 1)=="0" then
     do
       HEX=SubStr(HEX, 2)
     end
   end
   /* String wird wieder umgedreht.           */
   HEX=Reverse(HEX)
   HEX="."||HEX
   return(HEX)

HEXFil:
  Procedure
  parse arg zz
  select
    when zz==10 then zz='A'
    when zz==11 then zz='B'
    when zz==12 then zz='C'
    when zz==13 then zz='D'
    when zz==14 then zz='E'
    when zz==15 then zz='F'
    otherwise NOP
  end
  return(zz)

EingStr:
  say
  parse upper arg stst 
  Call Color 1,White
  Call Charout,"Sie haben in den String "
  Call Color 1,Cyan
  /* FÅr die Anzeige der aktuellen Berechnung sollen die von  b2d.CMD  */
  /* in gro·e Buchstaben umgewandelte kleinen Buchstaben wieder        */
  /* in kleine Buchstaben umgewandelt werden.                          */
  kl="abcdefghijklmnopqrstuvwxyzÑîÅ";  gr="ABCDEFGHIJKLMNOPQRSTUVWXYZéôö"
  stst=translate(stst, kl, gr)
  Call Charout,stst; say
  Call Color 1,White
  Call Charout,"der Eingabe-Kette ein oder mehrere"; say
  Call Charout,"fÅr Dezimalzahlen nicht erlaubte Zeichen eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

Nichts:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"weder fÅr den ganzzahligen Anteil noch fÅr die Mantisse"; say
  Call Charout,"eine Dezimalzahl eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

FalschNum:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"fÅr die Anzahl der intern zu verwendenden Stellen"; say
  Call Charout,"mit "
  Call Color "Cyan"
  Call Charout,NM
  Call Color "White"
  Call Charout," keine positive ganze Zahl "
  Call Color "Cyan"
  Call Charout,"> 1"
  Call Color "White"
  Call Charout," eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd


kommav:
  say
  Call Color 1,white
  Call Charout,"Soll eine nicht ganzzahlige "
  Call Color 1,Red
  Call Charout,"Dezimalzahl"
  Call Color 1,white
  Call Charout," in eine "
  Call Color 1,Green
  Call Charout,"Hexadezimalzahl"; say
  Call Color 1,white
  Call Charout,"umgewandelt werden, so mu· in der Eingabe-Kette nach dem"; say
  Call Charout,"String  "
  Call Color 1,cyan
  Call Charout,"d2x"
  Call Color 1,white
  Call Charout,"  mindestens  "
  Call Color 1,green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen enthalten sein."; say; say
  Call Charout,"Darauf mu·, bevor die in eine "
  Call Color 1,Green
  Call Charout,"Hexadezimalzahl"
  Call Color 1,white
  Call Charout," umzuwandelnde "; say
  Call Charout,"nicht ganzzahlige "
  Call Color 1,Red
  Call Charout,"Dezimalzahl"
  Call Color 1,white
  Call Charout," eingegeben werden kann,"; say
  Call Charout,"eine "
  Call Color 1,cyan
  Call Charout,"ganze Zahl > 1"
  Call Color 1,white
  Call Charout,", gefolgt von einem "
  Call Color 1,cyan
  Call Charout,"einzelnen Komma"
  Call Color 1,white;  say
  Call Charout,"eingegeben werden."; say; say
  Call Charout,"NÑheres ist in der "
  Call Color 1,Green
  Call Charout,"kzr.INF"
  Call Color 1,white
  Call Charout," zu finden."
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

  
D2XMsg:
   say
   Call Color 1,White
   Call Charout,"Sie haben bei der Eingabe der Umwandlungs-Aufgabe"; say
   Call Charout,"eines oder mehrere fÅr dezimale Darstellung nicht erlaubte ",
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
