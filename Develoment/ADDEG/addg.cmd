/* OS/2-REXX-Programm Addg.CMD, 06.11.1996                           */
Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
Call SysLoadFuncs
"@ echo off"
numeric digits 16
Call SysCls
say
Call CsrAttrib "High";   Call Color "YELLOW","BLACK"
Call Charout,"  Einfache Additions-Routine fÅr RechnungsbetrÑge oder irgendwelche Summanden,"; say
Call Charout,"  ============================================================================"; say
Call CsrAttrib "Normal"
Call Charout,"        deren "
Call CsrAttrib "High";     Call Color "magenta"
Call Charout,"absolute BetrÑge"
Call CsrAttrib "Normal"
Call Charout," grî·er als 1,0E-6 und kleiner als 1,0E+6"; say
Call Charout,"                          oder exakt gleich Null sind."; say; say
Call Charout,"Geben Sie zunÑchst die Bezeichnung des Beleges"; say
Call Charout,"-- mit nicht mehr als 40 Characters -- ein und drÅcken Sie die Eingabetaste."; say; say
Call Charout,"Geben Sie sodann den Betrag des Beleges"; say
Call Charout,"-- wenn er ein Dezimalbruch ist, mit Dezimalkomma oder Dezimalpunkt -- "; say
Call Charout,"ein und drÅcken Sie die Eingabetaste."; say; say
Call Charout,"Ein zweimaliges DrÅcken der Eingabetaste ohne vorherige Eingabe einer";say
Call Charout,"Beleg-Bezeichnung und eines Beleg-Betrages beendet die Additions-Routine.";say;say;say
Call Charout,"                                                                     Werte     ";say
Call Charout,"Bezeichnung                                       Wert                der      ";say
Call Charout,"    des                                            des              Zwischen-  ";say
Call Charout,"  Beleges                                        Beleges             Summen    ";say
Call Charout,"========================================∫======================================"
say

"del" Summe.DAT "1>NUL 2>NUL"

/* Kopfleiste in der Datei Summe.DAT schreiben. */
ret=LineOut(Summe.DAT, "                                                                    Werte      ")
ret=LineOut(Summe.DAT, "Bezeichnung                                     Wert                 der       ")
ret=LineOut(Summe.DAT, "    des                                          des               Zwischen-   ")
ret=LineOut(Summe.DAT, "  Beleges                                      Beleges              Summen     ")
ret=LineOut(Summe.DAT, "========================================∫======================================")
ret=LineOut(Summe.DAT, "" )

n=1; x.1=0; x.0=0; s.0=0; p=0;

wieder:
ret=SysCurState("ON")
  Call Charout,"                                                                              "
  Call CsrLeft 78
  parse pull txt
  /* Warnung bei Eingabe zu vieler Buchstaben */
  if length(txt) > 40 then signal AnzTXT
weiter:
  ret=SysCurState("ON")
  pull x

  /* Sofern x mit einem Dezimalkomma eingegeben wurde. */
  /* wird die Position des Dezimalkomma's ermittelt,     */
  sop = Pos(",", x)

  /* Wenn in  x  kein Dezimalkomma vorhanden ist, ist  sop = 0. */
  /* In diesem Fall ist  x  eine ganze Zahl                     */
  /* oder  x  enthÑlt bereits einen Dezimal-Punkt);             */
  /* die Variable  x  bleibt unverÑndert.                       */
  /* Wenn Wenn jedoch in  x  ein Dezimalkomma vorhanden ist, */
  /* ist  sop <> 0.  In diesem Falle wird anstelle des         */
  /* Dezimalkomma's ein Dezimalpunkt eingefÅgt.                */
  if sop <> 0 then x = OverLay(".", x, sop)

  /* Eingabetaste ohne vorherige Eingabe beendet die Additions-Routine */
  if length(x) == 0 then signal AnzErg
  /* Warnung bei Eingabe eines Strings, der keine REXX-Zahl ist */
  if datatype(x) == CHAR then signal Anz1
  /* Warnung bei Eingabe zu vieler Ziffern */
  if length(x) > 13 then signal Anz2
  /* Warnung bei Eingabe einer Zahl, deren Betrag grî·er als 1.0E+0006 ist  */
  if abs(x) > 1.0E+0006 then signal Anz3
  /* Der Wert 0 darf eingegeben werden */
  if x = 0 then signal www
  /* Warnung bei Eingabe einer Zahl,                               */
  /* deren Betrag zwar kleiner als 1.0E-0006 aber grî·er als 0 ist */
  if abs(x) < 1.0E-0006 then signal Anz4
  www:
  s.n = s.p + x

  if abs(s.n) >= 1.0E0007 then Call Zuviel
  /* Anzeige */
  Call CsrUp 2
  Call Charout,txt
  ll1=44-length(txt)
  i=1
  zw1=""; zw0=" ";
  do while i < ll1
    zw1=zw1||zw0
    i=i+1
  end

  Call Charout,zw1; Call Charout,format(x, 8)
  /* Erzeugung eines Strings  zw,  dessen LÑnge von der Anzahl         */
  /* der Ziffern der eingegebenen Zahl einschlie·lich des Vorzeichens  */
  /* und eines Dezimalkomma's oder eines Dezimalpunktes anhÑngig ist.  */
  lz = length(format(x, 8, 7)) - length(format(x, 8))
  ll = 8+lz
  i=1
  zw=""; zw0=" ";
  do while i < ll
    zw=zw||zw0
    i=i+1
  end

  /* noch Anzeige */
  Call CsrAttrib "High";     Call Color "white"
  Call Charout,zw;       Call Charout,format(s.n, 8, 2);
  Call CsrAttrib "Normal";
  say

  ll2=43-length(txt)
  i=1
  zw2=""; zw0=" ";
  do while i < ll2
    zw2=zw2||zw0
    i=i+1
  end

  ll3=8+lz
  i=1
  zw3=""; zw0=" ";
  do while i < ll3
    zw3=zw3||zw0
    i=i+1
  end

  str=txt||zw2||format(x, 8)||zw3||format(s.n, 8, 2)
  ret1=LineOut(Summe.DAT, str)
  n=n+1; p=n-1
  signal wieder


ende:
/* Der Befehl "call charout(Summe.DAT)" ist erforderlich, */
/* weil Summe.DAT und somit auch die Datei Summe.DAT      */
/* nicht gelîscht werden kann.                            */
call charout(Summe.DAT)
"del" Summe.DAT "1>NUL 2>NUL"
Call SysCls
EXIT

/*************************** eigene Prozeduren ******************************/

AnzTXT:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Es sind zu viele Symbole oder Leerzeichen eingegeben worden !"; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Nach BetÑtigung der Eingabetaste"; say
  Call Charout,"ist die erneute Eingabe der Bezeichnung eines Beleges mîglich."; say
  Call Charout,"Bitte aber nicht mehr als 40 Symbole einschlie·lich der Leerzeichen eingeben."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 6
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call CsrUp 8
  Call Charout,"                                                                              "
  Call CsrLeft 78
  signal wieder

Anz1:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Die Zahleneingabe hat ein falsches Format !"; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Nach BetÑtigung der Eingabetaste ist die erneute Eingabe einer Zahl mîglich."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 4
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call CsrUp 6
  Call Charout,"                                                                              "
  Call CsrLeft 78
  signal weiter

Anz2:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Es sind zu viele Ziffern eingegeben worden !"; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Nach BetÑtigung der Eingabetaste ist die erneute Eingabe einer Zahl mîglich."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 4
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call CsrUp 6
  Call Charout,"                                                                              "
  Call CsrLeft 78
  signal weiter

Anz3:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Der absolute Betrag der eingegebenen Zahl ist grî·er als "
                           Call Color "CYAN"
  Call Charout,"1,0E+6"
                           Call Color "white"
  Call Charout," !"; say
  Call Charout,"Dieser Betrag kann in dieser Additions-Routine nicht verwendet werden."; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Nach BetÑtigung der Eingabetaste ist die erneute Eingabe einer Zahl mîglich."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 5
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call CsrUp 7
  Call Charout,"                                                                              "
  Call CsrLeft 78
  signal weiter

Anz4:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Der absolute Betrag der eingegebenen Zahl"; say
  Call Charout,"ist grî·er als "
                           Call Color "CYAN"
  Call Charout,"Null"
                           Call Color "white"
  Call Charout," und kleiner als "
                           Call Color "CYAN"
  Call Charout,"1,0E-6"
                           Call Color "white"
  Call Charout," !"; say
  Call Charout,"Dieser Betrag kann in dieser Additions-Routine nicht verwendet werden."; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Nach BetÑtigung der Eingabetaste ist die erneute Eingabe einer Zahl mîglich."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 6
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call CsrUp 8
  Call Charout,"                                                                              "
  Call CsrLeft 78
  signal weiter

Zuviel:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Der absolute Betrag der Endsumme wÑre gleich oder grî·er als "
                           Call Color "CYAN"
  Call Charout,"1,0E+7"
                           Call Color "white"
  Call Charout," !"; say
  Call Charout,"HierfÅr ist diese einfache Additions-Routine nicht gedacht."; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Nach BetÑtigung der Eingabetaste ist die erneute Eingabe einer Zahl mîglich."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 5
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call Charout,"                                                                              ";say
  Call CsrUp 7
  Call Charout,"                                                                              "
  Call CsrLeft 78
  signal weiter

AnzErg:
  say
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"Der Wert der Summe";say
  Call Charout,"der "
                           Call Color "green"
  n=n-1
  Call Charout,n
                           Call Color "white"
  Call Charout," eingegebenen Summanden ist: "
                           Call Color "YELLOW"
  Call Charout,s.n
  Call CsrAttrib "Normal"; say

  strErg1="Der Wert der Summe"
  strErg2="der eingegebenen Summanden ist              "||format(s.n, 8, 7)
  strErg3="                                                                      "
  strErg4="Endbetrag (auf ganze Pfennige aufgerundet): "||format(s.n, 8, 2)||" DM";

  ret=LineOut(Summe.DAT, "")
  ret=LineOut(Summe.DAT, strErg1)
  ret=LineOut(Summe.DAT, strErg2)
  ret=LineOut(Summe.DAT, strErg3)
  ret=LineOut(Summe.DAT, strErg4)
  ret=LineOut(Summe.DAT, "")

  say
  Call Charout,"Mîchten Sie das Additionsergebnis zusammen mit den Werten der Zwischensummen"; say
  Call Charout,"mit Hilfe des "
  Call CsrAttrib "High";   Call Color "cyan"
  Call Charout,"EPM-Editors"
  Call CsrAttrib "Normal"
  Call Charout," nochmals anschauen"; say
  Call Charout,"und, wenn erforderlich, auch ausdrucken ? (j/*) "; pull x

  select
  when x == 'J' then
  do
    Call SysCls
    ret=SysCurState("OFF")
    Call CsrAttrib "High";   Call Color "white","blue"
    Call Locate  5,  2
    Call Charout,"…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª"
    Call Locate  6,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate  7,  2
    Call Charout,"∫   In den "
                             Call Color "yellow"
    Call Charout,"Optionen"
                             Call Color "white"
    Call Charout," des "
                             Call Color "cyan"
    Call Charout,"EPM-Editors"
                             Call Color "white"
    Call Charout," sollte folgendes eingestellt sein:       ∫"
    Call Locate  8,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate  9,  2
    Call Charout,"∫   Anpassung -> Einstellungen -> Schrift:                                   ∫";
    Call Locate 10,  2
    Call Charout,"∫                     "
                             Call Color "yellow"
    Call Charout,"                      Schriftart"
                             Call Color "green"
    Call Charout," Courier Bitmap 13*8"
                             Call Color "white","blue"
    Call Charout,"   ∫"
    Call Locate 11,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 12,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 13,  2
    Call Charout,"∫   Soll das Ergebnis ausgedruckt werden,                                    ∫"
    Call Locate 14,  2
    Call Charout,"∫   so sollte in dem Fenster "
                             Call Color "yellow"
    Call Charout," Drucken"
                             Call Color "white","blue"
    Call Charout,"                                        ∫"
    Call Locate 15,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 16,  2
    Call Charout,"∫   die Einstellung "
                             Call Color "green","blue"
    Call Charout,"Unformatierter ASCII-Text"
                             Call Color "white","blue"
    Call Charout," aktiviert sein.                ∫"
    Call Locate 17,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 18,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 19,  2
    Call Charout,"∫                         "
                             Call Color "green","blue"
    Call Charout,"Weiter mit der Eingabetaste"
                             Call Color "white","blue"
    Call Charout,"                        ∫"
    Call Locate 20,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 21,  2
    Call Charout,"»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº"
    Call CsrAttrib "Normal"
    pull
    Call SysCls
    EPM Summe.DAT
  end
  otherwise NOP
  end
  signal ende

/***************************** ANSI-Prozeduren ******************************/

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

/* procedure to color screen
A:--------------------------------------------------------------*
accepts colors: BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE  *
*/
Color: Procedure /* Call Color <ForeGround>,<BackGround> */
arg F,B
Colors = "BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE"
return CHAROUT(,D2C(27)"["WORDPOS(F,COLORS)+29";"WORDPOS(B,COLORS)+39";m")

/*  change screen attributes
A:---------------------------------------------------------------*
attributes: NORMAL HIGH LOW ITALIC UNDERLINE BLINK RAPID REVERSE *
*/
CsrAttrib: Procedure  /* call CsrAttrib <Attrib> */
Arg A
attr = "NORMAL HIGH LOW ITALIC UNDERLINE BLINK RAPID REVERSE"
return CHAROUT(,D2C(27)"["WORDPOS(A,ATTR) - 1";m")

EndAll:
Call Color "White","Black"
CALL CsrAttrib "Normal"

