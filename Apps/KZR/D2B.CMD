/* REXX-Programm D2B.CMD                                   */
/* D2B.CMD wandelt dezimale Zahlen in bin�re Zahlen. */
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call Color 1,white
   call SysCls
   Signal on syntax name D2BMsg

   /* Die Dateien "kzr.INF" und "krz.CMD   */
   /* befinden sich im selben Verzeichnis. */
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)

   parse UPPER arg strstr
   stE=strstr
   /* Zwischenr�ume aus dem String  strstr  entfernen */
   do forever
     lzw=Pos(" ", strstr)
     if lzw = 0 then leave
     strstr=DelStr(strstr,lzw,1)
   end

   if (length(strstr)= 0) then
   do
     "start view.exe" Pfd||"KZR.INF D2B"
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
   /* Die f�r die Berechnung einer Mantisse gew�nschte Anzahl     */
   /* der Dezimalstellen wird mit der Variablen  NM  eingestellt. */
   NM=strip(NM)
   if NM=="" then NM=20    

   stV=strip(stV) 
   if length(stV)>0 then 
   do
     stV=D2BInt(stV)
   end

   stN=strip(stN) 
   if length(stN)>0 then
   do
     stN=D2BMant(stN, NM)
     stN=SubStr(stN, 2)
   end
  
   stG=stV||stN

   /* Anfang der Ausgabe-Anweisungen */
   say
   Call Color 1,White
   Call Charout,"  Eingabe:"; say
   Call Color 1,Red
   Call Charout,"  Dezimal: "
   Call Color 1,White
   Call Charout,stA; say; say


   if length(stN)>0 then
   do
     call Color 0,white,black
     Call Charout,"  Kann die Mantisse der gew�nschten Bin�rzahl,"; say
     Call Charout,"  wie es in den meisten F�llen der Fall ist,"; say
     Call Charout,"  nur als "
     call Color 1,white
     Call Charout,"N�herungs-Ergebnis"
     call Color 0,white,black
     Call Charout," berechnet werden,"; say
     Call Charout,"  so wird die Mantisse mit bis zu "
     call Color 1,white
     Call Charout,NM
     call Color 0,white,black
     Call Charout," Stellen ausgegeben."; say
   end

   say
   Call Color 1,White
   Call Charout,"  Ausgabe:"; say
   Call Color 1,Green
   Call Charout,"    Bin�r: "
   Call Color 1,White
   Call Charout,strip(stG); say
   /* Ende der Ausgabe-Anweisungen */

PgmEnd:
   say
   call Color 0,white
EXIT


D2BInt:
   Procedure
   parse upper arg str.1
   m=1; n=m+1
   do forever
     z=1; i=1; j=i+1
     do forever
       z=z*2
       if z>str.m then leave
       i=i+1
     end
     n.m=i
     z.m=z/2
     str.n=str.m-z.m
     if str.n=0 then leave
     m=m+1; n=m+1
   end
   u=1; b0=0
   do while u<n.1
     B0=B0||0
     u=u+1
   end
   u=1
   do while u<=m
     B0=overlay('1', B0, n.u)
     u=u+1
   end
   Bin=Reverse(B0)
   Return(BIN)


D2BMant:
   Procedure
   parse upper arg str,NM
   i=1; j=i-1; stN.0="."||str; Mant="."
   do forever
     stN.i=stN.j*2
     stZ.i=trunc(stN.i)
     stN.i=stN.i-stZ.i
     if stN.j==0 | i>=NM then leave
     Mant=Mant||stZ.i
     i=i+1; j=i-1
   end
   /* Angeh�ngte Ziffern '0' werden entfernt. */
   /* String wird umgedreht.                  */
   Mant=Reverse(Mant)
   /* F�hrende Ziffern '0' werden entfernt.   */
   do forever
     if SubStr(Mant, 1, 1) >"0" then leave
     if SubStr(Mant, 1, 1)=="0" then
     do
       Mant=SubStr(Mant, 2)
     end
   end
   /* String wird wieder umgedreht.           */
   Mant='.'||Reverse(Mant)
   Return(Mant)


EingStr:
  say
  parse upper arg stst 
  Call Color 1,White
  Call Charout,"Sie haben in den String "
  Call Color 1,Cyan
  /* F�r die Anzeige der aktuellen Berechnung sollen die von  b2d.CMD  */
  /* in gro�e Buchstaben umgewandelte kleinen Buchstaben wieder        */
  /* in kleine Buchstaben umgewandelt werden.                          */
  kl="abcdefghijklmnopqrstuvwxyz���";  gr="ABCDEFGHIJKLMNOPQRSTUVWXYZ���"
  stst=translate(stst, kl, gr)
  Call Charout,stst; say
  Call Color 1,White
  Call Charout,"der Eingabe-Kette ein oder mehrere"; say
  Call Charout,"f�r Dezimalzahlen nicht erlaubte Zeichen eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd


Nichts:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"weder f�r den ganzzahligen Anteil noch f�r die Mantisse"; say
  Call Charout,"eine Dezimalzahl eingegeben."; say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd


FalschNum:
  say
  Call Color 1,White
  Call Charout,"Sie haben in die Eingabe-Kette"; say
  Call Charout,"f�r die Anzahl der intern zu verwendenden Stellen"; say
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
  Call Charout,"Dezimalzahl"
  Call Color 1,white
  Call Charout," in eine "
  Call Color 1,Green
  Call Charout,"Bin�rzahl"; say
  Call Color 1,white
  Call Charout,"umgewandelt werden, so mu� in der Eingabe-Kette nach dem"; say
  Call Charout,"String  "
  Call Color 1,cyan
  Call Charout,"d2b"
  Call Color 1,white
  Call Charout,"  mindestens  "
  Call Color 1,green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen enthalten sein."; say; say
  Call Charout,"Darauf mu�, bevor die in eine "
  Call Color 1,Green
  Call Charout,"Bin�rzahl"
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
  Call Charout,"N�heres ist in der "
  Call Color 1,Green
  Call Charout,"kzr.INF"
  Call Color 1,white
  Call Charout," zu finden."
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

  
D2BMsg:
   say
   Call Color 1,White
   Call Charout,"Sie haben bei der Eingabe der Umwandlungs-Aufgabe"; say
   Call Charout,"eines oder mehrere f�r dezimale Darstellung nicht erlaubte "
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

