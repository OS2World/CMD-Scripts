/* REXX-Programm kzrn.CMD */
/* Der folgende Aufruf  "Call RxFuncAdd....." lÑdt die           */
/* RexxUtil-Funktionen auch fÅr alle von  kzr.CMD  aufgerufenen  */
/* Funktionen wie z.B. sin(x), sqrt(x) oder auch  phi(x).        */
/* Lediglich die Funktionen  b2d.CMD, b2x.CMD, d2b.CMD, d2x.CMD, */
/* x2b.CMD  und  x2d.CMD  sowie  prim.CMD  haben selbst die hier */
/* folgenden zwei Zeilen, da sie ohne  kzr.CMD  direkt von der   */
/* Kommandozeile aufgerufen werden.                              */
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call Color 1,white
/*   call SysCls*/
   
   /* Wird bei der AusfÅhrung einer REXX-Anweisung ein Syntaxfehler */
   /* festgestellt, so wird zur Prozedur "Fehlermeldung" verzweigt. */
   signal on syntax name Fehlermeldung

   /* Die Datei "Ergebnis.DAT" wird in dem Verzeichnis abgelegt, */
   /* in dem auch die Datei "kzr.CMD" abgelegt ist.              */
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   buferg=Pfd||"Ergebnis.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufNDA=Pfd||"NDAZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"

   z = LineIn(buferg, 1)
   zv=z
   if length(zv)=0 then zv="Keines"

   /* Der Befehl "Call charout(buferg)" ist erforderlich, weil sonst */
   /* die Datei  Ergebnis.DAT, die Åber den Pfad Pfd erreichbar ist, */
   /* nicht gelîscht werden kann.                                    */
   Call charout(buferg);   Call SysFileDelete buferg

   parse arg str;   str=strip(str)

   if (length(str)= 0) then
   do; "start /PM /MAX view.exe" Pfd||"KZR.INF"; EXIT; end

   /* PrÅfung, ob das  e r s t e  Komma nach "kzr" eingegeben wurde. */
   ww=word(str, 1)
   l1=length(ww)
   lk=Pos(",", ww)
   p1=wordpos(" , ", str)

   if l1 <> lk then
   do
     if p1 = 0 then
     do
       Call charout(bufND);   Call SysFileDelete bufND
       Call charout(bufMsg);  Call SysFileDelete bufMsg
       Call kommav
     end
   end

   /* Zerlegen des Kommandozeilen-Strings nach eine Schablone.  */
   /* Das "UPPER" ist wichtig, damit verschiedene Schreibweisen */
   /* von "externen" Operatoren, wie z.B. divganz, DivGanz oder */
   /* dIVgANZ auch richtig erkannt werden.                      */
   parse value str with ND ',' st ';' v1 ',' v2
   /* v1 ist die Zuweisung fÅr die Variable 1                       */
   /* und v2 die Zuweisung fÅr die Variable 2.                      */
   /* v1, v2 oder auch v1 und v2 kînnen nach der Formulierung der   */
   /* Rechenaufgabe auf der Kommandozeile, jeweils durch ein Komma  */
   /* getrennt auf der Kommandozeile eingegeben werden.             */
   /* v1 und v2 mÅssen aber nicht eingegeben werden, wenn in der    */
   /* eigentlichen "Rechenaufgabe" keine Variablen vorhanden sind.  */

   /* PrÅfung, ob  ND  eine gÅltige REXX-Zahl ist */
   if Datatype(ND, 'N') <> 1 & length(ND) > 0 then
   do
     Call charout(bufND);   Call SysFileDelete bufND
     Call charout(bufMsg);  Call SysFileDelete bufMsg
     Call FalschZahl ND
   end

   /* PrÅfung, ob  ND  grî·er als  1  ist */
   if length(ND) > 0 & ND < 2 then
   do
     Call charout(bufND);   Call SysFileDelete bufND
     Call charout(bufMsg);  Call SysFileDelete bufMsg
     Call FalschArg
   end

   if length(ND) = 0 then ND = 20
   Numeric digits ND
   /* Die Variable ND wird an  bufND Åbergeben */
   ret=LineOut(bufND, ND)

   v1=strip(v1)                                   
   v2=strip(v2)                                   
   /* Es wird ÅberprÅft, ob die Variablen-Zuweisung auf der */
   /* Kommandozeile korrekt ist.                            */
   if length(v1) > 0 & Pos("=", v1) = 0 then Call NoVar
   if length(v2) > 0 & Pos("=", v2) = 0 then Call NoVar
                   
   if Pos(";", v1)>0 | Pos(":", v1)>0 then Call FalschZeichen
                                  
   if Pos("'", st) > 0 | Pos('"', st) > 0 | Pos("@", st) > 0 | ,
      Pos("?", st) > 0 | Pos('\', st) > 0 | Pos('#', st) > 0 | ,
      Pos('', st) > 0 | Pos('$', st) > 0 then
   do
     Call charout(bufND);   Call SysFileDelete bufND
     Call charout(bufMsg);  Call SysFileDelete bufMsg
     Call QuoteFilter
   end

   /* Umwandlung von st in gro·e Buchstaben */
   kl="divganzrest"; gr="DIVGANZREST"
   st=translate(st, gr, kl)
   st1=st
   if Pos(":",   st1)     > 0 then st2=Filter2(st1); else st2=st1
   if Pos("DIVGANZ", st2) > 0 then st3=Filter3(st2); else st3=st2
   if Pos("DIVREST", st3) > 0 then st4=Filter4(st3); else st4=st3
   st=st4
   /* Umwandlung von st in kleine Buchstaben */
   st=translate(st, kl, gr)
       
   select
     when  Pos(")0", st) > 0  then Signal twt
     when  Pos(")1", st) > 0  then Signal twt
     when  Pos(")2", st) > 0  then Signal twt
     when  Pos(")3", st) > 0  then Signal twt
     when  Pos(")4", st) > 0  then Signal twt
     when  Pos(")5", st) > 0  then Signal twt
     when  Pos(")6", st) > 0  then Signal twt
     when  Pos(")7", st) > 0  then Signal twt
     when  Pos(")8", st) > 0  then Signal twt
     when  Pos(")9", st) > 0  then Signal twt
     when  Pos("),", st) > 0  then Signal twt
     when  Pos(").", st) > 0  then Signal twt
     otherwise Signal twtw
   end
twt:
     Call charout(bufND);   Call SysFileDelete bufND
     Call charout(bufMsg);  Call SysFileDelete bufMsg
     Call Unsinn
twtw:
   stst=strip(st)
   v1  =strip(v1)
   v2  =strip(v2)

   /* Wichtig, damit das Ergebnis in der Variablen z verfÅgbar ist, und    */
   /* da· zuerst die Variablen  v1, v2 oder auch v1 und v2 verfÅgbar sind. */
   if length(v1) > 0 & length(v2) > 0 then
   do
   /* Hier ist zweimal ein Semikolon erforderlich, */
   /* da Trennung von drei REXX-Anweisungen        */
     st=v1||";"||v2||";   "||"z = "||stst
     Signal NV
   end

   if length(v1) > 0 & length(v2) = 0 then
   do
   /* Hier ist einmal ein Semikolon erforderlich,  */
   /* da Trennung von zwei REXX-Anweisungen        */
     st=v1||";   "||"z = "||stst
     Signal NV
   end

   if length(v2) > 0 & length(v1) = 0 then
   do
   /* Hier ist einmal ein Semikolon erforderlich,  */
   /* da Trennung von zwei REXX-Anweisungen        */
     st=v2||";   "||"z = "||stst
     Signal NV
   end

   st ="z = "||stst
NV:
   stA="z = "||stst

   /* FÅr die aktuelle Berechnung und deren Anzeige sollen die von    */
   /* alle gro·en Buchstaben in kleine Buchstaben umgewandelt werden  */
   kl="abcdefghijklmnopqrstuvwxyzÑîÅ";  gr="ABCDEFGHIJKLMNOPQRSTUVWXYZéôö"
   st = translate(st,  kl, gr)
   v1 = translate(v1,  kl, gr)
   v2 = translate(v2,  kl, gr)
   stA= translate(stA, kl, gr)
/*   say*/
    
   /* Die Funktionen D2X, X2D, B2X, X2B, D2B und B2D mÅssen direkt */
   /* von der Kommandozeile, das hei·t, ohne die Funktion kzr.CMD  */
   /* aufgerufen werden.                                           */
   /* Diese Abfrage mu· an dieser Stellegeschehen.                 */
   if Pos("D2X", st)>0 | Pos("X2D", st)>0 |,
      Pos("B2X", st)>0 | Pos("X2B", st)>0 |,
      Pos("D2B", st)>0 | Pos("B2D", st)>0 | Pos("PRIM", st)>0 then Signal FalschRuf
   
   Numeric Digits ND+4  /* Intern wird mit ND+4 Dezimalstellen gerechnet. */
   /* Dies ist der wichtigste Befehl ! */
   /**/         interpret st         /**/
   /* Dies ist der wichtigste Befehl ! */

 /* Von NDA_MIN wird der niedrigste Wert NDA fÅr die Rechengenauigkeit    */
 /* der verwendeten Funktionen ermittelt und dieser "Kernfunktion"kzr.CMD */
 /* fÅr die Ergebnisanzeige Åbergeben.                                    */
   ND=MinNDA()
   Numeric Digits ND

   /* Nur wenn das Ergebnis eine gÅltige REXX-Zahl ist, Ergebnis formen */
   if DataType(z, 'N') = 1 then
   do
     Numeric Digits ND
     zz=Format(z, , , , )
     st10=ErgFormat(zz)
   end
   else st10=z

   /* Ausgabe, wenn ein Ergebnis berechnet werden konnte */
/*   Call Color 0,White
   Call Charout,"Ergebnis der vorangegangenen Berechnung:"; say; say
   Call Color 1,Green
   Call Charout,"   "zv; say; say; say
   Call Color 0,White
   Call Charout,"Aufgabe der aktuellen Berechnung:"
   say; say
   
   Call Color 1,White
   Call Charout,"  "stA; say
   Call Color 0,White
   call Charout,"mit";say;
   Call Color 1,White
*/   
   if length(v1) > 0 then
   do
     parse value v1 with w1 '=' w2
     v1=strip(w1)||" = "||strip(w2)  
     Call Charout,"  "v1; say
   end

   if length(v2) > 0 then
   do
   parse value v2 with w1 '=' w2
     v2=strip(w1)||" = "||strip(w2)  
     Call Charout,"  "v2; say        
   end 
/*   say; say*/
/*   
   Call Color 1,White
   Call Charout,"Ergebnis  ";
   Call Color 1,White
   Call Charout,"z"
   Call Color 0,White
   Call Charout,"  der aktuellen Berechnung mit "
   Call Color 1,White
   Call Charout,ND
   Call Color 0,White
   Call Charout," Dezimalstellen:"
   say; say
   Call Color 1,Cyan
*/   Call Charout,"  "st10; /* say*/

   /* Nur wenn  st10  eine gÅltige REXX-Zahl ist. */     
   if DataType(st10, 'N')==1 then
   do
      /* Nur bei verschiedenen Ausgabeformaten Ausgabe von zwei Anzeigen. */
      if Compare(st10,  Format(st10, , , ,0)) <> 0 then
      do
         Call Charout,"  "Format(st10, , , ,0)
      end
      Call Color 0,White
      ret=LineOut(buferg, st10)
   end
/*   say*/

PgmEnd:
   Call Color 0,White
   Call charout(bufND);   Call SysFileDelete bufND
   Call charout(bufNDA);  Call SysFileDelete bufNDA
   Call charout(bufMsg);  Call SysFileDelete bufMsg
   /* Das REXX-Programm MinNDA.CMD lîscht temporÑre Dateien,          */
   /* die von "externen" mathematischen Funktionen hizugefÅgt wurden. */
   Dummy=MinNDA()
EXIT

/******************************* Prozeduren *********************************/

Filter2:
  Procedure
  parse arg str
  i=1; st2.i=str
  Anf2:
  j=i+1
  l2.i=Pos(":", st2.i)
  if l2.i=0 then Signal w2e
  st2.j=Overlay("/", st2.i, l2.i)
  st2=st2.j
  i=i+1
  Signal Anf2
  w2e:
  Return(st2)

Filter3:
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

Filter4:
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

/* Diese Funktion entfernt den Dezimalpunkt und die darauf folgenden      */
/* Ziffern  "0"  , wenn nach diesem Dezimalpunkt nur noch Nullen folgen.  */
ErgFormat:
  Procedure
  arg u
  /* Nur wenn das Ergebnis einen Dezimalpunkt enthÑlt */
  /* und in der Exponential-Schreibweise vorliegt.    */
  if Pos(".", u)>0 & Pos("E", u)=0 then
  do
  /* Ziffern-Reihe aus der Ziffer  "0"  nach dem Dezimalpunkt entfernen */
    do forever
      lu=length(u)
      if Pos("0", u, lu) > 0 then u=DelStr(u, lu); else leave
    end
    /* Den Dezimalpunkt entfernen */
    lu=length(u)
    if Pos(".", u) = lu then u=DelStr(u, lu)
   end
   Return(u)

NoVar:
  say
  Call Color 1,Red
  Call Charout,"Kein Ergebnis !"; say; say
  Call Color 1,White
  Call Charout,"Sie haben einen algebraisch unsinnigen Ausdruck eingeben"; say
  Call Charout,"oder einer Variablen keinen Wert zugewiesen. (NoVar)";say
  Call Color 0,White
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

kommav:
  say
  Call Color 1,white
  Call Charout,"In dem Kommandozeilen-String mu· nach dem Teilstring  "
  Call Color 1,cyan
  Call Charout,"kzr"; say
  Call Color 1,white
  Call Charout,"mindestens  "
  Call Color 1,green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen enthalten sein."; say
  Call Charout,"Darauf folgend, bevor die eigentliche ""Rechenaufgabe"" eingegeben wird,"; say
  Call Charout,"entweder";say
  Call Charout,"         ein "
  Call Color 1,cyan
  Call Charout,"einzelnes Komma"
  Call Color 1,white
  Call Charout," mit mindestens  "
  Call Color 1,green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen dahinter,"; say
  Call Charout,"oder";say
  Call Charout,"         eine "
  Call Color 1,cyan
  Call Charout,"ganze Zahl > 1"
  Call Color 1,white
  Call Charout,", gefolgt von"; say
  Call Charout,"         einem "
  Call Color 1,cyan
  Call Charout,"einzelnen Komma"
  Call Color 1,white
  Call Charout," mit mindestens  "
  Call Color 1,green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen dahinter."; say; say
  Call Charout,"NÑheres ist in der "
  Call Color 1,Green
  Call Charout,"kzr.INF"
  Call Color 1,white
  Call Charout," zu finden."
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

FalschZahl:
  say
  arg ND
  Call Color 1,Red
  Call Charout,"Kein Ergebnis !"; say; say
  Call Color 1,White
  Call Charout,"Anstelle einer ganzen Zahl, die grî·er als  1  sein mu·,"; say
  Call Charout,"haben Sie den String  "
  Call Color 1,cyan
  Call Charout,strip(ND)
  Call Color 1,White
  Call Charout,"  eingegeben."
  Call Color 0,White
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

FalschZeichen:
  say
  Call Color 1,Red
  Call Charout,"Kein Ergebnis !"; say; say
  Call Color 1,White
  Call Charout,"Sie haben nach der Festlegung der ersten Variablen"; say
  Call Charout,"anstelle des erforderlichen Kommas ein Semikolon,"; say
  Call Charout,"einen Punkt oder einen Doppelpunkt eingegeben."; say
  Call Color 0,White
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd
   
FalschArg:
  say
  Call Color 1,white
  Call Charout,"In dem Kommandozeilen-String mu· zwischen dem Teilstring  "
  Call Color 1,cyan
  Call Charout,"kzr"; say
  Call Color 1,white
  Call Charout,"und dem ersten  "
  Call Color 1,cyan
  Call Charout,"Komma"
  Call Color 1,white
  Call Charout,"  entweder"; say; say
  Call Charout,"eine  "
  Call Color 1,Green
  Call Charout,"ganze Zahl > 1"
  Call Color 1,white
  Call Charout,"  oder"; say
  Call Charout,"mindestens  "
  Call Color 1,Green
  Call Charout,"1"
  Call Color 1,white
  Call Charout,"  Leerzeichen eingegeben werden."
  Call Color 0,white
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

FalschRuf:
  say
  Call Color 1,white
  Call Charout,"Die Umwandlungsfunktionen"; say; say
  Call Color 1,cyan
  Call Charout,"D2X"
  call Color 0,white
  Call Charout,", "
  Call Color 1,cyan
  Call Charout,"X2D"
  call Color 0,white
  Call Charout,", "
  Call Color 1,cyan
  Call Charout,"B2X"
  call Color 0,white
  Call Charout,", "
  Call Color 1,cyan
  Call Charout,"X2B"
  call Color 0,white
  Call Charout,", "
  Call Color 1,cyan
  Call Charout,"D2B"
  call Color 0,white
  Call Charout," und "
  Call Color 1,cyan
  Call Charout,"B2D"; say; say
  call Color 1,white
  call Charout,"sowie die Funktion "
  Call Color 1,cyan
  call Charout,"Prim.CMD"
  call Color 1,white
  call Charout," zur Primfaktor-Zerlegung"; say
  call Charout,"dÅrfen nur von der Kommandozeile direkt und "
  Call Color 1,red
  call Charout,"ohne"
  call Color 1,white
  call Charout," den"; say
  call Charout,"vorangesetzten Teilstring "
  Call Color 1,cyan
  call Charout," kzr xy, "
  call Color 1,white
  call Charout," eingegeben werden."; say; say
  call Charout,"(NÑheres dazu in der kzr.INF)"
  call Color 0,white
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd
   
Fehlermeldung:
  sf=ErrorText(RC)
  
  Call CsrLeft 10
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call Charout,"                                                                              "; say
  Call CsrUp 12

  if  Pos("Invalid ex", sf) > 0 then
  do
    sfstr="Sie haben einen algebraisch unsinnigen Ausdruck eingeben,",
          "                     ",
          "einer Variablen keinen Wert zugewiesen",
          "                                        ",
          "oder gar keine mathematische Funktion aufgerufen."
    Signal raus
  end

  if  Pos("Arithmetic", sf) > 0 then
  do
    sfstr="Haben Sie etwa versucht, durch  0  zu dividieren ?   ˙˙˙˙˙   Pfui !"
    Signal raus
  end

  if  Pos('Unexpected ","', sf) > 0 then
  do
    sfstr="Sie haben zuviele rechte Klammern oder ein unzulÑssiges Komma eingegeben."
    Signal raus
  end

  if  Pos("Invalid ch", sf) > 0 then
  do
    sfstr="Sie haben ein in algebraischen AusdrÅcken unzulÑssiges Symbol eingegeben."
    Signal raus
  end

  if  Pos('Unmatched "("', sf) > 0 & Pos("in expression", sf, 15) > 0 then
  do
    sfstr="Sie haben zu viele linke oder zu wenige rechte Klammern eingegeben."
    Signal raus
  end

  if  Pos("Bad arithmetic conversion", sf) > 0 then
  do
    sfstr="     Sie haben einen algebraisch unsinnigen Ausdruck eingeben",
          "                 ",
          "     oder einer Variablen keinen Wert zugewiesen.",
          "                             ",
          "     Mîglicherweise aber wollten Sie in der aktuellen Rechenaufgabe",
          "           ",
          "     mit der Spezialvariablen  z  das Ergebnis der (gescheiterten)",
          "            ",
          "     vorangegangenen Rechenaufgabe verwenden,",
          "                                 ",
          "     der natÅrlich noch kein Wert zugewiesen war."
    Signal raus
  end

  if  Pos("Routine not", sf) > 0 then
  do
    sfstr="Die Funktion in diesem Ausdruck kann nicht aufgerufen werden."
    Signal raus
  end

  if  Pos("Invalid whole number", sf) > 0 then
  do
    sfstr="     Entweder werden fÅr die interne Rechengenauigkeit",
          "                        ",
          "     zu wenig Dezimalstellen verwendet,",
          "                                       ",
          "     oder Sie haben als Exponenten keine ganzen Zahlen eingegeben."
    Signal raus
  end

  if  Pos("Unknown command", sf) > 0 then
  do
    sfstr="Eingabe oder Ergebnis der Berechnung ist keine gÅltige REXX-Zahl."
    Signal raus
  end

  if  Pos("Name starts with number or", sf) > 0 then
  do
    sfstr="Sie haben einer Variablen keinen Wert zugewiesen. (Name starts with number)"
    Signal raus
  end

  /* Gibt Fehlermeldungen eines Unterprogramms zurÅck, */
  /* die in  bufMsg  gespeichert sind. Object-REXX-Version */
  if  Pos("Function or message did not", sf) > 0 then
  do
    sfstr=LineIn(bufMsg, 1)
    /* Hier besonders wichtig ! */
    Call charout(bufMsg);  Call SysFileDelete bufMsg
    Signal raus
  end

  /* Gibt Fehlermeldungen eines Unterprogramms zurÅck, */
  /* die in  bufMsg  gespeichert sind. Klass.-REXX-Version */
  if  Pos("Function did not", sf) > 0 then
  do
    sfstr=LineIn(bufMsg, 1)
    /* Hier besonders wichtig ! */
    Call charout(bufMsg);  Call SysFileDelete bufMsg
    Signal raus
  end

  if  Pos("Incorrect call to method", sf) > 0 then
  do
    sfstr=LineIn(bufMsg, 1)
    /* Hier besonders wichtig ! */
    Call charout(bufMsg);  Call SysFileDelete bufMsg
    Signal raus
  end
           
  raus:
  Call Color 1,Red
  Call Charout,"Kein Ergebnis !"; say; say
  Call Color 1,White
  Call Charout,sfstr; say
  Call charout(bufND);   Call SysFileDelete bufND
  Call charout(bufMsg);  Call SysFileDelete bufMsg
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

Unsinn:
  say;
  Call Color 1,Red
  Call charout(bufND);   Call SysFileDelete bufND
  Call charout(bufMsg);  Call SysFileDelete bufMsg
  Call Charout,"Kein Ergebnis !"; say; say
  Call Color 1,White
  Call Charout,"Sie haben einen algebraisch unsinnigen Ausdruck eingeben."
  say
  Beep(444, 200); Beep(628,300)
  Signal PgmEnd

QuoteFilter:
  say
  Call Color 1,Red
  Call Charout,"Kein Ergebnis !"; say; say
  Call Color 1,White
  Call Charout,"Die Symbole "
  Call Color 1,cyan; Call Charout,""; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"$"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"="; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"?"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"\"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"@"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"#"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"'"; Call Color 1,white; Call Charout," und "
  Call Color 1,cyan; Call Charout,'"'; say
  Call Color 1,white
  Call Charout,"dÅrfen auf der Kommandozeile dieses Programms nicht verwendet werden."; say;say
  call Charout,"Lediglich bei einer Zuweisung von Werten zu einer oder zwei der beiden"; say  
  call Charout,"Variablen, zum Beispiel  x=2  und/oder  y=3  unmittelbar im Anschlu·";say  
  call Charout,"an die Eingabe der eigentlichen Rechenaufgabe auf der Kommandozeile,";say  
  call Charout,"ist das Gleiheitszeichen erlaubt.";say; say  
  Call Color 1,Red
  Call Charout,"Warnung fÅr weitere Eingaben !"; say; say
  Call Color 1,white
  Call Charout,"Die Symbole  "
  Call Color 1,cyan; Call Charout,"%"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"&"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,"<"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,">"; Call Color 1,white; Call Charout," und "
  Call Color 1,cyan; Call Charout,"|"; Call Color 1,white
  Call Charout,"  sowie die Strings  "
  Call Color 1,cyan; Call Charout,"<<"; Call Color 1,white; Call Charout,", "
  Call Color 1,cyan; Call Charout,">>"; Call Color 1,white;  Call Charout," und "
  Call Color 1,cyan; Call Charout,"//"; say
  Call Color 1,white
  Call Charout,"dÅrfen auf der OS/2-Kommandozeile nur in bestimmten FÑllen verwendet werden;"; say
  Call Charout,"nur zeigt  "
  Call Color 1,cyan; Call Charout,"kzr.CMD"; Call Color 1,white
  Call Charout,"  bei Verletzung der einschlÑgigen Regeln"; say
  Call Charout,"leider keine diesbezÅglichen Meldung an."
  say
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


/* In kzr.cmd sind die Funktionen  CsrLeft  und  CsrUp  erforderlich. */
CsrLeft: procedure
arg l
Rc = Charout(,D2C(27)"["l"D")
Return ""


CsrUp: Procedure  /* CsrUp(Rows) */
Arg u
Rc = Charout(,D2C(27)"["u"A")
return ""


