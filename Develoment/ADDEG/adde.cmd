/* OS/2-REXX-Program Adde.CMD, 06.11.1996  */
Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
Call SysLoadFuncs
"@ echo off"
numeric digits 16
Call SysCls
say
Call CsrAttrib "High";   Call Color "YELLOW","BLACK"
Call Charout,"  A Simple Addition Program for Values of Invoices or Any Costs of Daily Life"; say
Call Charout,"  ==========================================================================="; say
Call CsrAttrib "Normal"
Call Charout,"                 whose "
Call CsrAttrib "High";     Call Color "magenta"
Call Charout,"absolute values"
Call CsrAttrib "Normal"
Call Charout," are larger than 1.0E-6"; say
Call Charout,"                                      and smaller than 1.0E+6"; say
Call Charout,"                                          or exact equal Zero."; say; say
Call Charout,"First type the label of the invoice or something similar"; say
Call Charout,"-- with no more than 40 characters (includung blanks) -- and hit the Enter key."; say; say
Call Charout,"Then type the value of the invoice or something similar"; say
Call Charout,"-- if it is a decimal fraction with decimal point or decimal comma -- "; say
Call Charout,"and hit the Enter key."; say; say
Call Charout,"If You hit the Enter key twice without typing something before";say
Call Charout,"the addition procedure will be finished.";say;say;say
Call Charout,"                                                                     value     ";say
Call Charout,"  label                                          value               of the    ";say
Call Charout,"  of the                                         of the              interim   ";say
Call Charout,"  invoice                                        invoice               sum     ";say
Call Charout,"========================================บ======================================"
say

"del" SUM.DAT "1>NUL 2>NUL"

/* Writing header in the file SUM.DAT */
ret=LineOut(SUM.DAT, "                                                                   valuee      ")
ret=LineOut(SUM.DAT, "  label                                        value               of the      ")
ret=LineOut(SUM.DAT, "  of the                                       of the              interim     ")
ret=LineOut(SUM.DAT, "  invoice                                      invoice               sum       ")
ret=LineOut(SUM.DAT, "========================================บ======================================")
ret=LineOut(SUM.DAT, "" )

n=1; x.1=0; x.0=0; s.0=0; p=0;

wieder:
ret=SysCurState("ON")
  Call Charout,"                                                                              "
  Call CsrLeft 78
  /* pulling label */
  parse pull txt
  /* Too much characters */
  if length(txt) > 40 then signal AnzTXT

weiter:
  ret=SysCurState("ON")
  /* pulling value */
  pull x

  /* If x was typed with a decimal comma                */
  /* the position of the decimal comma will be defined  */
  sop = Pos(",", x)

  /* If x was typed with a decimal comma                */
  /* ist  sop <> 0.  In this case the decimal comma     */
  /* will be replaced by a dezimal point.               */
  if sop <> 0 then x = OverLay(".", x, sop)

  /* Hittig the Enter key closes Adde.CMD */
  if length(x) == 0 then signal AnzErg

  /* Warning after pulling a string which is no REXX-number */
  if datatype(x) == CHAR then signal Anz1
  /* Warning after pulling too much figures */
  if length(x) > 13 then signal Anz2
  /* Warning after pulling a value                  */
  /* which absolute value is larger than 1.0E+0006  */
  if abs(x) > 1.0E+0006 then signal Anz3
  /* The value 0 is allowed */
  if abs(x) = 0 then signal www
  /* Warning after pulling a value                  */
  /* which absolute value is smaller than 1.0E-0006 */
  if abs(x) < 1.0E-0006 then signal Anz4
  www:
  s.n = s.p + x
  if abs(s.n) >= 1.0E0007 then Call Zuviel
  /* Showing on screen */
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
  /* Creating a string  zw  which length depends from the numbers */
  /* of figures including the sign and a decimal point            */
  /* or a decimal comma                                           */
  lz = length(format(x, 8, 7)) - length(format(x, 8))
  ll = 8+lz
  i=1
  zw=""; zw0=" ";
  do while i < ll
    zw=zw||zw0
    i=i+1
  end

  /* still showing on screen */
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
  ret1=LineOut(SUM.DAT, str)
  n=n+1; p=n-1
  signal wieder


ende:
/* The command "call charout(SUM.DAT)" is necessary          */
/* because otherwise the file  SUM.DAT  could not be deleted */
call charout(SUM.DAT)
"del" SUM.DAT "1>NUL 2>NUL"
Call SysCls
EXIT

/*************************** eigene Prozeduren ******************************/

AnzTXT:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"You typed too much symbols or blanks !"; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Hit the Enter key and repeat typing the label of the invoice."; say
  Call Charout,"Please do not type more than 40 characters (symbols or blanks)."; say
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
  signal wieder



Anz1:
  say
  ret=SysCurState("OFF")
  Call CsrAttrib "High";   Call Color "white"
  Call Charout,"You typed the number in a wrong format !"; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Hit the Enter key and repeat typing of the value of the invoice."; say
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
  Call Charout,"Yoe have typed too much figures or blanks !"; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Hit the Enter key and repeat typing of the value of the invoice."; say
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
  Call Charout,"The absolute value of the number You typed is larger than "
                           Call Color "CYAN"
  Call Charout,"1.0E+6"
                           Call Color "white"
  Call Charout," !"; say
  Call Charout,"This value can not be used in this simple addition procedure."; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Hit the Enter key and repeat typing of the value of the invoice."; say
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
  Call Charout,"The absolute value of the number You typed"; say
  Call Charout,"is greater than "
                           Call Color "CYAN"
  Call Charout,"Zero"
                           Call Color "white"
  Call Charout," and smaller than "
                           Call Color "CYAN"
  Call Charout,"1.0E-6"
                           Call Color "white"
  Call Charout," !"; say
  Call Charout,"This value can not be used in this simple addition procedure."; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Hit the Enter key and repeat typing of the value of the invoice."; say
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
  Call Charout,"The absolute value of the result would reach or exceed "
                           Call Color "CYAN"
  Call Charout,"1.0E+7"
                           Call Color "white"
  Call Charout," !"; say
  Call Charout,"This value can not be used in this simple addition procedure."; say; say
  Call CsrAttrib "Normal"
  Call Charout,"Hit the Enter key and repeat typing of the value of the invoice."; say
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
  Call Charout,"The value of the resulting sum";say
  Call Charout,"of the "
                           Call Color "green"
  n=n-1
  Call Charout,n
                           Call Color "white"
  Call Charout," typed values is: "
                           Call Color "YELLOW"
  Call Charout,s.n
  Call CsrAttrib "Normal"; say

  strErg1="The value of the resulting sum              "
  strErg2="of the typed values is:                     "||format(s.n, 8, 7)
  strErg3="                                            "
  strErg4="Value of the resulting sum:                 "||format(s.n, 8, 2)
  strErg5="(rounded up to 2 figures                    "
  strErg6=" after the decimal point)                   "

  ret=LineOut(SUM.DAT, "")
  ret=LineOut(SUM.DAT, strErg1)
  ret=LineOut(SUM.DAT, strErg2)
  ret=LineOut(SUM.DAT, strErg3)
  ret=LineOut(SUM.DAT, strErg4)
  ret=LineOut(SUM.DAT, strErg5)
  ret=LineOut(SUM.DAT, strErg6)
  ret=LineOut(SUM.DAT, "")

  say
  Call Charout,"Would You like to see once more the resulting sum"; say
  Call Charout,"together with all values of the interim sums with the aid of the "

  Call CsrAttrib "High";   Call Color "cyan"
  Call Charout,"EPM-EDITOR"; say

  Call CsrAttrib "Normal"
  Call Charout,"and -- if required -- to print them ? (y/*) "; pull x

  select
  when x == 'Y' then
  do
    Call SysCls
    ret=SysCurState("OFF")
    Call CsrAttrib "High";   Call Color "white","blue"
    Call Locate  5,  2
    Call Charout,"ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
    Call Locate  6,  2
    Call Charout,"บ                                                                            บ"
    Call Locate  7,  2
    Call Charout,"บ   In the "
                             Call Color "yellow"
    Call Charout,"options"
                             Call Color "white"
    Call Charout," of the "
                             Call Color "cyan"
    Call Charout,"EPM EDITOR"
                             Call Color "white"
    Call Charout,"                                         บ"; say
    Call Locate  8,  2
    Call Charout,"บ   he following point should be activated:"
                             Call Color "yellow"
    Call Charout,"   font: "
                             Call Color "green"
    Call Charout," Courier Bitmap 13*8"
                             Call Color "white","blue"
    Call Charout,"     บ"
    Call Locate  9,  2
    Call Charout,"บ                                                                            บ"
    Call Locate 10,  2
    Call Charout,"บ                                                                            บ"
    Call Locate 11,  2
    Call Charout,"บ   If the result should be printed,                                         บ"
    Call Locate 12,  2
    Call Charout,"บ   in the window "
                             Call Color "yellow"
    Call Charout,"Print"
                             Call Color "white"
    Call Charout," of the "
                             Call Color "cyan"
    Call Charout,"EPM EDITOR"
                             Call Color "white"
    Call Charout,"                                    บ"
    Call Locate 13,  2
    Call Charout,"บ                                                                            บ"
    Call Locate 14,  2
    Call Charout,"บ   the point "
                             Call Color "green"
    Call Charout,"Unformatted ASCII-Text"
                             Call Color "white"
    Call Charout," should be activated.                    บ"
    Call Locate 15,  2
    Call Charout,"บ                                                                            บ"
    Call Locate 16,  2
    Call Charout,"บ                                                                            บ"
    Call Locate 17,  2
    Call Charout,"บ                             "
                             Call Color "green","blue"
    Call Charout,"Hit the Enter key"
                             Call Color "white","blue"
    Call Charout,"                              บ"
    Call Locate 18,  2
    Call Charout,"บ                                                                            บ"
    Call Locate 19,  2
    Call Charout,"ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
    Call CsrAttrib "Normal"
    pull
    Call SysCls
    EPM SUM.DAT
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