/* OS/2-REXX-Programm Add1.CMD, 10.07.2004                  */
"mode co80,33"
Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
Call SysLoadFuncs
signal on halt name PgmEnd
numeric digits 16
"@ echo off"
pfd=Directory()/* Die Funktion  Directory()  erzeugt nicht immer       */
/* einen Bachslash am Ende; daher die folgende Prozedur */
if LastPos("\", pfd)<>length(pfd) then do
  Sum=pfd||"\"||SUMME.DAT
end
else do
  Sum=pfd||SUMME.DAT
end
/* Datei Sum freigeben. */
call Charout(Sum)
"del" Sum "1>NUL 2>NUL"
Call SysCls
say
Call Color 1,YELLOW,BLACK
Call Charout,"          Simple Addition Routine for invoice amounts or any amounts,"; say
Call Charout,"          ==========================================================="; say
call Color 0,white,black
Call Charout,"                whose "
Call Color 1,magenta,black
Call Charout,"absolute amounts"
call Color 0,white,black
Call Charout," are greater than 1.0E-6"; say
Call Charout,"                and smaller than 1.0E+6 or exact equal to zero."; say; say
Call Charout,"First type the designation of the receipt and hit the Enter key."; say; say
Call Charout,"After that type the amount of the receipt"; say
Call Charout,"-- if it is a decimal fraction use a decimal point or decimal comma -- "; say
Call Charout,"and hit the Enter key."; say; say
Call Charout,"If you hit the Enter key without preceding typing of the designation";say
Call Charout,"of a receipt and the amount of a receipt concludes this addition routine.";say
say
Call Charout,"                                                                     amounts   ";say
Call Charout,"Designation                                      amount                of      ";say
Call Charout,"  of the                                         of the              interim   ";say
Call Charout,"  receipt                                        receipt             result    ";say
Call Charout,"==============================================================================="

/* Kopfleiste in der Datei Summe.DAT schreiben. */
ret=LineOut(Sum, "                                                                    amounts    ")
ret=LineOut(Sum, "Designation                                    amount                 of       ")
ret=LineOut(Sum, "  of the                                       of the               interim    ")
ret=LineOut(Sum, "  receipt                                      receipt              results    ")
ret=LineOut(Sum, "===============================================================================")
ret=LineOut(Sum, "" )
n=1; m=1; x.1=0; x.0=0; s.0=0; p=0;
 
wieder:
ret=SysCurState("ON")
  Call Charout,"                                                                              "
  Call CsrLeft 78
  txt=strip(EditStr(1, cyan, cyan, 1, green, yellow, 42))
     if length(txt) == 0 then signal AnzErg
weiter:
  ret=SysCurState("ON")
  call CsrLeft 78
  call CsrUp 1
  call CsrRight 46
  x=EditStr(1, cyan, cyan, 1, green, yellow, 8)
  say 

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
  Call Charout," "||txt
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
  Call Color 1,white
  Call Charout,zw;       Call Charout,format(s.n, 8, 2);
  call Color 0,white,black
  say

  ll2=43-length(txt)
  i=1
  zw2=""; zw0=" ";
  do while i < ll2
    zw2=zw2||zw0
    i=i+1
  end

  ll3=8+lz-1
  i=1
  zw3=""; zw0=" ";
  do while i < ll3
    zw3=zw3||zw0
    i=i+1
  end

  str=" "||txt||zw2||format(x, 8)||zw3||format(s.n, 8, 2)
  ret1=LineOut(Sum, str)
  n=n+1; p=n-1
  signal wieder
 
PgmEnd:
Call SysCls
"mode co80,25"
EXIT

/*************************** eigene Prozeduren ******************************/
                                          
Anz1:
  say
  ret=SysCurState("OFF")
  Call Color 1,white
  Call Charout,"The input format of the amount is wrong !"; say; say
  call Color 0,white,black
  Call Charout,"Hit the Enter key and type the amount again."; say
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
  Call Color 1,white
  Call Charout,"The feeded amount consists ot to much numbers"; say; say
  call Color 0,white
  Call Charout,"Hit the Enter key and type the amount again."; say
  Beep(444, 200); Beep(628,300)
  pull
  Call CsrUp 4
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call Charout,"                                                                             ";say
  Call CsrUp 6
  Call Charout,"                                                                             "
  Call CsrLeft 78
  signal weiter

Anz3:
  say
  ret=SysCurState("OFF")
  Call Color 1,white
  Call Charout,"The absolute value of the feeded number is greater than "
  Call Color 1,CYAN
  Call Charout,"1,0E+6"
  Call Color 1,white
  Call Charout," !"; say
  Call Charout,"This value can not be used in this addition procedure."; say; say
  call Color 0,white
  Call Charout,"Hit the Enter key to feed another value."; say
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
  Call Color 1,white
  Call Charout,"The absolute value of the feeded number "; say
  Call Charout,"is greater than "
  Call Color 1,CYAN
  Call Charout,"Zero"
  Call Color 1,white
  Call Charout," and smaller than "
  Call Color 1,CYAN
  Call Charout,"1,0E-6"
  Call Color 1,white
  Call Charout," !"; say
  Call Charout,"This amount can not be used in this addition procedure."; say; say
  call Color 0,white,black
  Call Charout,"Hit the Enter key to feed another value."; say
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
  Call Color 1,white
  Call Charout,"The absolute value of the result is greater than "
  Call Color 1,CYAN
  Call Charout,"1,0E+7"
  Call Color 1,white
  Call Charout," !"; say
  Call Charout,"This simple addition procedure can not manage this value."; say; say
  call Color 0,white
  Call Charout,"Hit the Enter key to feed another value."; say
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
  call CsrUp 1
  call Charout,"                                                                               " 
  say
  Call Color 1,white
  Call Charout,"The amount of the sum"
  Call Charout," of the "
  Call Color 1,green
  n=n-1
  Call Charout,n
  Call Color 1,white
  Call Charout," feeded amounts is: "
  Call Color ,1,YELLOW
  Call Charout," "||s.n||" "
  call Color 0,white,black; say

  strErg1="The amount of the final result"
  strErg2="of the addition of the feeded amounts is                         "||format(s.n, 8, 7)
  strErg3="                                                                      "
  strErg4="The amount of the final result (rounded up to whole hundredth):  "||format(s.n, 8, 2)

  ret=LineOut(Sum, "")
  ret=LineOut(Sum, strErg1)
  ret=LineOut(Sum, strErg2)
  ret=LineOut(Sum, strErg3)
  ret=LineOut(Sum, strErg4)
  ret=LineOut(Sum, "")

  say
  Call Charout,"Would you like to see the result of the addition with the help "; say
  Call Charout,"of the "
  Call Color 1,cyan
  Call Charout,"EPM-Editor"
  call Color 0,white,black
  Call Charout," and, if necessary, to print the result ? (y/*) "; pull x

  select
  when x == 'Y' | x == 'y' then
  do
    Call SysCls
    ret=SysCurState("OFF")
    Call Color 1,white,blue
    Call Locate  5,  2
    Call Charout,"…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª"
    Call Locate  6,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate  7,  2
    Call Charout,"∫   In the "
    Call Color 1,yellow,blue
    Call Charout,"options"
    Call Color 1,white,blue
    Call Charout," of the "
    Call Color 1,cyan,blue
    Call Charout,"EPM-Editor"
    Call Color 1,white,blue
    Call Charout," should be adjusted:                     ∫"
    Call Locate  8,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate  9,  2
    Call Charout,"∫   Adjustment-> font:                                                       ∫";
    Call Locate 10,  2
    Call Charout,"∫                     "
    Call Color 1,yellow,blue
    Call Charout,"                            font"
    Call Color 1,green,blue
    Call Charout," Courier Bitmap 13*8"
    Call Color 1,white,blue
    Call Charout,"   ∫"
    Call Locate 11,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 12,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 13,  2
    Call Charout,"∫   If the result should be printed,                                         ∫"
    Call Locate 14,  2
    Call Charout,"∫   in the window "
    Call Color 1,yellow,blue
    Call Charout," Print"
    Call Color 1,white,blue
    Call Charout,"                                                     ∫"
    Call Locate 15,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 16,  2                                                 
    Call Charout,"∫   the adjustment "
    Call Color 1,green,blue
    Call Charout,"Unformated ASCII-Text"
    Call Color 1,white,blue
    Call Charout," must be activated.                  ∫"
    Call Locate 17,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 18,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 19,  2
    Call Charout,"∫                         "
    Call Color 1,green,blue
    Call Charout,"Hit the Enter key"
    Call Color 1,white,blue
    Call Charout,"                                  ∫"
    Call Locate 20,  2
    Call Charout,"∫                                                                            ∫"
    Call Locate 21,  2
    Call Charout,"»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº"
    call Color 0,white,black
    pull
    call Cls
    /* Datei Sum freigeben. */
    call Charout(Sum)
    "C:\OS2\apps\epm.exe 'windowsize1 0 0 0 0 2048'" sum 
  end
  otherwise NOP
  end
  signal PgmEnd

EditStr:
  Procedure
  parse arg at1, fg1, bg1, at2, fg2, bg2, l   
  RC=SaveCsr()        
  parse value RC with PosY PosX
  PosX=PosX+1  
                        
AnfEditStr:
  call Locate PosY, PosX-1
  call Color at1,fg1,bg1
  if l>=0 then call Charout,copies(" ",l+2)
  call Locate PosY, PosX
  k=1; si=""; sil=""; sir=""

  do forever 
    c1="#"; c2="#"
    
    /* Einlese-Befehl */
    c1=SysGetKey("noecho")
         
    /* Eingabetaste schlie·t die Eingabe ab. */
    if c2d(c1)=="13" & c2d(c2)=="35" then leave   

    /* Escapetaste leert das Eingabefeld. */
    if c2d(c1)=="27" & c2d(c2)=="35" & l>0 then Signal AnfEditStr
                                         
    /* Einlesen der Tastenkodes von Sondertasten,  */
    /* deren Tastencode zwei Symbole zurÅckliefert */
    if c2d(c1)=="224" then
    do
      c2=SysGetKey("noecho")
    end

    /* 1. Cursor nach links */
    if c2d(c1)=="224" & c2d(c2)=="75" & k>=2 then
    do
      call CsrLeft 1
      k=k-1
      iterate
      end
    
    /* 2. Cursor nach rechts */
    if c2d(c1)=="224" & c2d(c2)=="77" & k<l then
    do
      call CsrRight 1
      k=k+1
      iterate
    end
    
    /* 3. Cursor an den Anfang */
    if c2d(c1)=="224" & c2d(c2)=="71" & k<=l+1 then
    do
      call Locate PosY, PosX
      k=1
      iterate
    end
    
    /* 4. Cursor an das Ende */
    if c2d(c1)=="224" & c2d(c2)=="79" & k<=l+1 then
    do
      call Locate PosY, PosX+l-1
      k=l
      iterate
    end
    
    /* 5. Entf-Taste einrichten (fÅr k>=1) */ 
    if c2d(c1)=="224" & c2d(c2)=="83" & k>=1 then
    do
      sil=DelStr(si,k+0)
      sir=SubStr(si,k+1)
      si=sil||sir
      call Locate PosY, PosX-1        
      call Charout,copies(" ",l+2)  
      call Locate PosY, PosX 
      call Charout,si
      call Locate PosY, PosX+k-1
      iterate
    end
   
    /* Backspace-Taste einrichten (nur fÅr k>1) */
    if c2d(c1)=="8" & c2d(c2)=="35" & k==1 then iterate
    if c2d(c1)=="8" & c2d(c2)=="35" & k>=2 then
    do 
      sil=DelStr(si,k-1)
      sir=SubStr(si,k)
      si=sil||sir
      call Locate PosY, PosX-1
      call Charout,copies(" ",l+2)
      call Locate PosY, PosX
      call Charout,si
      call Locate PosY, PosX+k-2
      k=k-1
      iterate
    end  
                             
    /* Tabtaste wird ignoriert */
    if c2d(c1)=="9" & c2d(c2)=="35" then
    do
      c1=""
      k=k-1
    end
 
    /* Es werden nur erlaubte Zeichen eingelesen. */
    if c2d(c1)<>"224" & c2d(c2)=="35" & k>=1 & k<=l then
    do
      si=Overlay(c1, si, k)
      call Locate PosY, PosX 
      call Charout,si
      call Locate PosY, PosX+k
      k=k+1
    end
    
  end /* do forever */

  /* Die folgenden zwei Zeilen sind unbedingt erforderlich, weil in        */
  /* dieser Funktion "EditStr" beim Abschlu· der Eingabe mit "Enter" das   */
  /* hexadezimale Zeichen 0D (dezimal: 13) angehÑngt wird.                 */
  /* (Eine Ausnahme liegt dann vor, wenn genau soviele Zeichen eingegeben  */
  /* werden, wie es die zulÑssige LÑnge des Eingabestrings erlaubt.)       */
  /* Da dieses Zeichen zu den ASCII-Steuerzeichen gehîrt und somit von     */
  /* einem Editor nicht in einen Quelltext eingefÅgt werden kann, mu· fÅr  */
  /* REXX-Funktion "Pos" das Zeichen 0D mit Hilfe der REXX-Funktion x2c()  */
  /* dargestellt werden, also mit  x2c(0D).                                */
  q0D=Pos(x2c(0D), si)
  if q0D>0 then si=DelStr(si,q0D)
  /* Ausgabe-Vorbereitung */
  call Locate PosY, PosX-1 
  call Color at2,fg2,bg2
  call Charout,copies(" ",l+2)
  call Locate PosY, PosX
  call Charout,si
  call Color 0,white,black
  say 
  return(si) /* Ende EditStr */ 

              
/***************************** ANSI-Prozeduren ******************************/

    
SaveCsr: procedure  /* cursor_location = SaveCsr() (for PutCsr(x))*/
Rc = Charout(,D2C(27)"[6n")
Pull Q
Call CsrUp
return substr(q,3,2) substr(q,6,2)
/* im Original  "return Q"  im Original */
    
    
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

  
  
  



  
  
  
  
  
  
