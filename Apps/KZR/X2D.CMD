/* REXX-Programm X2D.CMD                                   */
/* X2D.CMD wandelt dezimale Zahlen in hexadezimale Zahlen. */
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call Color 1,white
   call SysCls
   Signal on syntax name X2DMsg  

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
     "start view.exe" Pfd||"KZR.INF X2D"
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
     if DataType(stV, 'X')<>1 then Call EingStr stV
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
     if DataType(stV, 'X')<>1 then Call EingStr stV
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
     if length(strip(stV))>0 & DataType(stV, 'X')<>1 then Call EingStr stV
     if length(strip(stN))>0 & DataType(stN, 'X')<>1 then Call EingStr stN
   end

WW:
   /* Die fÅr die Berechnung einer Mantisse gewÅnschte Anzahl     */
   /* der Dezimalstellen wird mit der Variablen  NM  eingestellt. */
   NM=strip(NM)
   if NM=="" then NM=20    

   stV=strip(stV) 
   if length(stV)>0 then 
   do
     stV=X2D(stV)
   end

   stN=strip(stN) 
   if length(stN)>0 then
   do
     stN=X2DMant(stN, NM)
     stN=SubStr(stN, 2)
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


   if length(stN)>0 then
   do
   Call Color 0,White
     Call Charout,"  Kann die Mantisse der gewÅnschten Dezimalzahl,"; say
     Call Charout,"  wie es in den meisten FÑllen der Fall ist,"; say
     Call Charout,"  nur als "
     Call Color 1,White
     Call Charout,"NÑherungs-Ergebnis"
     Call Color 0,White
     Call Charout," berechnet werden,"; say
     Call Charout,"  so wird die Mantisse mit bis zu "
     Call Color 1,White
     Call Charout,NM
     Call Color 0,White
     Call Charout," Stellen ausgegeben."; say
   end

   say
   Call Color 1,White
   Call Charout,"  Ausgabe:"; say
   Call Color 1,green
   Call Charout,"      Dezimal: "
   Call Color 1,White
   Call Charout,strip(stG); say
   /* Ende der Ausgabe-Anweisungen */

PgmEnd:
   say
   Call Color 0,White
EXIT


X2DMant:
   Procedure
   parse upper arg str, NM
   Numeric Digits NM+10
   str=strip(str)
   /* Der Zahlenwert  z.i  der einzelnen Stellen der Hexadezimalzahl  */
   /* wird ermittelt und dann jeweils die Buchstaben A bis F in die   */
   /* Zahlen 10 bis 15 umgewandelt.                                   */
   i=0
   do forever
     z.i=SubStr(str, 1+i, 1)
     z.i=DEZFil(z.i)
     if z.i=" " then leave
     i=i+1
   end
   /* Jede Stelle  z.i  wird mit 16**(-i-1) multipliziert und alle  */
   /* Ergebnisse dann addiert.                                      */
   i=0; DEZ=0
   do forever
     if z.i==" " | i>=NM then leave
     DEZ=DEZ+(z.i)*(16**(-i-1))
     i=i+1
   end
   /* Die Mantisse wird in ein der Zahl NM entsprechendes Format gebracht. */
   Numeric Digits NM
   DEZ=Format(DEZ,,,,)
   /* AngehÑngte Ziffern '0' werden entfernt. */
   /* ZunÑchst wird der String umgedreht.     */
   DEZ=Reverse(DEZ)
   /* Jetzt fÅhrende Ziffern '0' werden entfernt.   */
   do forever
     if SubStr(DEZ, 1, 1) >"0" then leave
     if SubStr(DEZ, 1, 1)=="0" then
     do
       DEZ=SubStr(DEZ, 2)
     end
   end
   /* Der String wird wieder umgedreht.        */
   DEZ=Reverse(DEZ)
   return(DEZ)

DEZFil:
  Procedure
  parse arg zz
  select
    when zz=='A' then zz=10
    when zz=='B' then zz=11
    when zz=='C' then zz=12
    when zz=='D' then zz=13
    when zz=='E' then zz=14
    when zz=='F' then zz=15
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
  Call Charout,"fÅr hexadezimale Darstellung "
  Call Charout,"nicht erlaubte Zeichen eingegeben."; say
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


FalschNum:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"fÅr die Anzahl der intern zu verwendenden Stellen"; say
  Call Charout,"keine positive ganze Zahl "
  Call Color 1,Cyan
  Call Charout,"> 1"
  Call Color 1,White
  Call Charout," eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

kommav:
  say
  Call Color 1,white
  Call Charout,"Soll eine nicht ganzzahlige "
  Call Color 1,Red
  Call Charout,"Hexadezimalzahl"
  Call Color 1,white
  Call Charout," in eine "
  Call Color 1,green
  Call Charout,"Dezimalzahl"; say
  Call Color 1,white
  Call Charout,"umgewandelt werden, so mu· in der Eingabe-Kette nach dem"; say
  Call Charout,"String  "
  Call Color 1,cyan
  Call Charout,"x2d"
  Call Color 1,white
  Call Charout,"  mindestens  "
  Call Color 1,green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen enthalten sein."; say; say
  Call Charout,"Darauf mu·, bevor die in eine "
  Call Color 1,Green
  Call Charout,"Dezimalzahl"
  Call Color 1,white
  Call Charout," umzuwandelnde "; say
  Call Charout,"nicht ganzzahlige "
  Call Color 1,Red
  Call Charout,"Hexadezimalzahl"
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
          
  
X2DMsg:
   say
   Call Color 1,White
   Call Charout,"Sie haben bei der Eingabe der Umwandlungs-Aufgabe"; say
   Call Charout,"eines oder mehrere fÅr hexadezinale Darstellung nicht erlaubte ",
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
