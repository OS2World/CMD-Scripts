/****************************** RxEdit.CMD *********************************/
/*                                                                         */
/* The four functions                                                      */
/*                                                                         */
/*      EditChar(), EditCharC(), EditStr(), EditStrC()                     */
/*                                                                         */
/* allow to edit uncolored and colored characters and strings.             */
/*                                                                         */
/*  1.                                                                     */
/*  ch=EditChar()                                                          */
/*  stores a single character in  ch                                       */
/*  without any attributes used by EditChar().                             */
/*  EditChar() shows the edited character on the screen                    */
/*  with the colors white on black while editing and                       */
/*  with the colors bright white on black after editing.                   */
/*                                                                         */
/*  2.                                                                     */
/*  ch=EditCharC(fcw, bcw, fca, bca)                                       */
/*  stores a single character in  ch                                       */
/*  without any attributes used by EditCharC().                            */
/*  EditCharC() shows the edited character on the screen                   */
/*  with  fcw  on  bcw  while editing and                                  */
/*  with  fca  on  bca  after You hit the Enter key.                       */
/*  Allowed colors for  fcw, bcw, fca, bca                                 */
/*  are: black, red, green, yellow, blue, magenta, cyan and white.         */
/*  Note that foreground colors  fcw  and  fca                             */
/*  are the highlighted version of the selected color.                     */
/*                                                                         */
/*  3.                                                                     */
/*  st=EditStr()                                                           */
/*  stores a string which length is 12 characters and stores it            */
/*  in the variable  st  without any attributes used by EditStr().         */
/*  EditStr() shows the edited string on the screen                        */
/*  with the colors white on black while editing and                       */
/*  with the colors bright white on black after editing.                   */
/*                                                                         */
/*  4.                                                                     */
/*  st=EditStrC(fcw, bcw, fca, bca)                                        */
/*  stores a string which length is 16 characters and stores it            */
/*  in the variable  st  without any attributes used by EditStrC().        */
/*  EditStrC() shows the edited string on the screen                       */
/*  with  fcw  on  bcw  while editing and                                  */
/*  with  fca  on  bca  after You hit the Enter key.                       */
/*  Allowed colors for  fcw, bcw, fca, bca                                 */
/*  are: black, red, green, yellow, blue, magenta, cyan and white.         */
/*  Note that foreground colors  fcw  and  fca                             */
/*  are the highlighted version of the selected color.                     */
/*                                                                         */
/*                                                                         */
/*  The following special keys are available                               */
/*  EditChar() and EditCharC():                                            */
/*                                                                         */
/*  Backspace, Enter, Esc                                                  */
/*                                                                         */
/*                                                                         */
/*  The following special keys are available                               */
/*  in EditStr() and EditStrC():                                           */
/*                                                                         */
/*  Backspace, Enter, Esc, left Arrow, right Arrow, Home, End, Entf        */
/*  (These key names are the english key names of a german keyboard.)      */
/*                                                                         */
/***************************************************************************/
/*                                                                         */
/*  If these functions are useful for You,                                 */
/*  please use them without any obligation (Freeware)                      */
/*                                                                         */
/*  The author of the ANSI-Procedures is Jamie Hoglund                     */
/*  jhoglund@cncns.com                                                     */
/*                                                                         */
/*                                                                         */
/*  Hermann Mahr                                                           */
/*  Hermann.Mahr@t-online.de                                               */
/*  24.05.1998                                                             */
/*                                                                         */
/***************************************************************************/
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   call SysCls
  
   /* Bei BetÑtigung der Tasten-Kombination  Strg+C  wird RxEdit.CMD beendet.  */
   signal on halt name ende
   
   call Locate 02,15
   call CsrAttrib "High";  call Color "white"   
   call Charout,"Please try the following four functions for editing:"
   call Locate 03,12
   call CsrAttrib "Normal"
   call Charout,"(If necessary, please read the comment in this RxEdit.CMD)"


   call Locate 05,06
   call Charout,"Edit a single uncolored character  ch:"
   call Locate 06,06
   call Charout,"ch  =  "; ch=EditChar()
   call Locate 07,06
   call Charout,"The single uncolored character  ch  is stored as:"
   call Locate 08,06
   call Charout,"ch  =  "ch
   
                                     
   call Locate 10,06
   call Charout,"Edit a single colored character  ch:"
   call Locate 11,06
   call Charout,"ch  =  "; ch=EditCharC("cyan","cyan","yellow","green")
   call Locate 12,06
   call Charout,"The single colored character  ch  is stored as:"
   call Locate 13,06
   call Charout,"ch  =  "ch
   
   call Locate 15,06
   call Charout,"Edit a uncolored string  str:"
   call Locate 16,06
   call Charout,"str =  "; str=EditStr(12)
   call Locate 17,06
   call Charout,"The uncolored string  str is stored as:"
   call Locate 18,06
   call Charout,"str =  "str
   
   call Locate 20,06
   call Charout,"Edit a colored string  str:"
   call Locate 21,06
   call Charout,"str =  "; str=EditStrC(16,"cyan","cyan","green","yellow")
   call Locate 22,06
   call Charout,"The colored string  str  is stored as:"
   call Locate 23,06
   call Charout,"str =  "str
   say
                
ende:           
EXIT


EditStr:
  Procedure
  /* ImGegensatz zur ANSI-Prozedur "call Locate y,x", deren Variable */
  /* y fÅr Zeile und x fÅr Spalte mit 1 beginnen, beginnen die       */
  /* Variablen fÅr Zeile und Spalte der Funktion                     */
  /* "parse value SysCurPos with Zeile Spalte" mit dem Wert 0  !!!!  */
  "@ echo off"
  /* Ausgangs-Koordinaten PosY und PosX ermitteln */
  anf="47"; bckspc="08"; ende="4F";   enter="0D"; entf="53" 
  esc="1B"; links="4B";  rechts="4D"; tab="09"
  parse value SysCurPos() with PosY PosX

  parse arg l

AnfEditStr:
  call SysCurPos PosY, PosX
  if l>=0 then call Charout,copies(" ",l)
  call SysCurPos PosY, PosX
  done=0; k=1; i=1; si=""
  k0=0
  do while done<>1
    
    /* Einlese-Befehl */
    ch=SysGetKey("noecho")

    /* Eingabetaste schlie·t die Eingabe ab. */
    if c2x(ch)==enter then done=1

    /* Escapetaste leert das Eingabefeld. */
    if c2x(ch)==esc & l>0 then Signal AnfEditStr

    /* Sondertasten, deren Tastencode zwei Symbole zurÅckliefert. */
    if c2x(ch)=="00" | c2x(ch)=="E0" then
    do
      /* andere Variable hc unbedingt erforderlich ! */
      hc=SysGetKey("noecho") 
      /* 1. Cursor nach links */
      if c2x(hc)==links & k>1 then
      do
        call SysCurPos PosY, PosX+k-2
        hc=""; ch=""
        k=k-1
      end
      /* 2. Cursor nach rechts */
      if c2x(hc)==rechts & k<l then
      do
        call SysCurPos PosY, PosX+k
        hc=""; ch=""
        k=k+1
      end
      /* 3. Cursor an den Anfang */
      if c2x(hc)==anf & k<=l+1 then
      do
        call SysCurPos PosY, PosX
        hc=""; ch=""
        k=1
      end
      /* 4. Cursor an das Ende */
      if c2x(hc)==ende & k<=l then
      do
        call SysCurPos PosY, PosX+l
        hc=""; ch=""
        k=l+1
      end
      /* 5. Entf-Taste einrichten */
      if c2x(hc)==entf & k<=l+1 then
      do
        call SysCurPos PosY, PosX
        call Charout,copies(" ",l)
        call SysCurPos PosY, PosX
        sa=DelStr(si, k)
        se=SubStr(si, k+1)
        call Charout,sa||se
        call SysCurPos PosY, PosX+k-1
      end
      /* 6. Fast alle Sondertasten werden ignoriert.     */
      k=k-1
      ch=""; hc="" 
    end /* Sondertasten, deren Tastencode zwei Symbole zurÅckliefert. */

    /* Tabtaste wird ignoriert */
    if c2x(ch)==tab then
    do
      ch=""
      k=k-1
    end

    /* Backspace-Taste einrichten. */
    if c2x(ch)==bckspc & k>1 then
    do
      lsi=Length(strip(si))
      lsik=lsi-k                     
        call SysCurPos PosY, PosX
        call Charout,copies(" ",l)
        call SysCurPos PosY, PosX    
        sil=Left(strip(si),k-2)
        sir=Right(strip(si),lsi-k+1)
        si=strip(sil||sir) 
        call Charout,si
        call SysCurPos PosY, PosX+k-2 
        k=k-1
    end

    /* Es werden nur erlaubte Zeichen eingelesen. */
    if k<=l & c2x(ch)<>bckspc then
    do
      call Charout,ch
      si=si||ch
      /* String vom Bildschirm einlesen und in der Variablen si speichern. */
      si=SysTextScreenRead(posY,PosX,l)
      if c2x(ch)==enter then leave
      k=k+1
    end

  end /* do while */

  /* Ausgabe-Vorbereitung */
  call SysCurPos PosY, PosX
  call CsrAttrib "High"
  if l>=0 then call Charout,copies(" ",l)
  call SysCurPos PosY, PosX
  call Charout,si
  call CsrAttrib "Normal"
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
  return(si) /* EditStr */


EditStrC:
  Procedure
  /* Farbige Ausgabe des Eingabestrings                              */
  /* ImGegensatz zur ANSI-Prozedur "call Locate y,x", deren Variable */
  /* y fÅr Zeile und x fÅr Spalte mit 1 beginnen, beginnen die       */
  /* Variablen fÅr Zeile und Spalte der Funktion                     */
  /* "parse value SysCurPos with Zeile Spalte" mit dem Wert 0  !!!!  */
  "@ echo off"
  anf="47"; bckspc="08"; ende="4F";   enter="0D"; entf="53" 
  esc="1B"; links="4B";  rechts="4D"; tab="09"
  /* Ausgangs-Koordinaten PosY und PosX ermitteln */
  parse value SysCurPos() with PosY PosX

  parse arg l,fve,fhe,fvb,fhb

  if l>0 then
  do
    z1=1
    z2=2 
  end
  if l==0 | l=="" then
  do
    z1=0
    z2=0 
  end
                      
AnfEditStrC:
  call SysCurPos PosY, PosX-z1
  call CsrAttrib "High";  call Color fve,fhe
  if l>=0 then call Charout,copies(" ",l+z2)
  call SysCurPos PosY, PosX
  done=0; k=1; si=""
  
  do while done<>1
    
    /* Einlese-Befehl */
    ch=SysGetKey("noecho")

    /* Eingabetaste schlie·t die Eingabe ab. */
    if c2x(ch)==enter then done=1

    /* Escapetaste leert das Eingabefeld. */
    if c2x(ch)==esc & l>0 then Signal AnfEditStrC

    /* Sondertasten, deren Tastencode zwei Symbole zurÅckliefert. */
    if c2x(ch)=="00" | c2x(ch)=="E0" then
    do
      /* andere Variable hc unbedingt erforderlich ! */
      hc=SysGetKey("noecho") 
      /* 1. Cursor nach links */
      if c2x(hc)==links & k>1 then
      do
        call SysCurPos PosY, PosX+k-2
        hc=""; ch=""
        k=k-1
      end
      /* 2. Cursor nach rechts */
      if c2x(hc)==rechts & k<l then
      do
        call SysCurPos PosY, PosX+k
        hc=""; ch=""
        k=k+1
      end
      /* 3. Cursor an den Anfang */
      if c2x(hc)==anf & k<=l+1 then
      do
        call SysCurPos PosY, PosX
        hc=""; ch=""
        k=1
      end
      /* 4. Cursor an das Ende */
      if c2x(hc)==ende & k<=l then
      do
        call SysCurPos PosY, PosX+l
        hc=""; ch=""
        k=l+1
      end
      /* 5. Entf-Taste einrichten */
      if c2x(hc)==entf & k<=l+1 then
      do
        call SysCurPos PosY, PosX
        call Charout,copies(" ",l)
        call SysCurPos PosY, PosX
        sa=DelStr(si, k)
        se=SubStr(si, k+1)
        call Charout,sa||se
        call SysCurPos PosY, PosX+k-1
      end
      /* 6. Fast alle Sondertasten werden ignoriert.     */
      k=k-1
      ch=""; hc="" 
    end /* Sondertasten, deren Tastencode zwei Symbole zurÅckliefert. */

    /* Tabtaste wird ignoriert */
    if c2x(ch)==tab then
    do
      ch=""
      k=k-1
    end

    /* Backspace-Taste einrichten. */
    if c2x(ch)==bckspc & k>1 then
    do
      lsi=Length(strip(si))
      lsik=lsi-k                     
        call SysCurPos PosY, PosX
        call Charout,copies(" ",l)
        call SysCurPos PosY, PosX    
        sil=Left(strip(si),k-2)
        sir=Right(strip(si),lsi-k+1)
        si=strip(sil||sir) 
        call Charout,si
        call SysCurPos PosY, PosX+k-2 
        k=k-1
    end

    /* Es werden nur erlaubte Zeichen eingelesen. */
    if k<=l & c2x(ch)<>bckspc then
    do
      call Charout,ch
      si=si||ch
      /* String vom Bildschirm einlesen und in der Variablen si speichern. */
      si=SysTextScreenRead(posY,PosX,l)
      if c2x(ch)==enter then leave
      k=k+1
    end

  end /* do while */

  /* Ausgabe-Vorbereitung */
  call SysCurPos PosY, PosX-z1
  call CsrAttrib "HIGH";  call Color fvb,fhb
  if l>=0 then call Charout,copies(" ",l+z2)
  call SysCurPos PosY, PosX
  call Charout,si
  call CsrAttrib "Normal" 
  /* Die folgenden zwei Zeilen sind unbedingt erforderlich, weil in        */
  /* dieser Funktion "EditStrC" beim Abschlu· der Eingabe mit "Enter" das  */
  /* hexadezimale Zeichen 0D (dezimal: 13) angehÑngt wird.                 */
  /* (Eine Ausnahme liegt dann vor, wenn genau soviele Zeichen eingegeben  */
  /* werden, wie es die zulÑssige LÑnge des Eingabestrings erlaubt.)       */
  /* Da dieses Zeichen zu den ASCII-Steuerzeichen gehîrt und somit von     */
  /* einem Editor nicht in einen Quelltext eingefÅgt werden kann, mu· fÅr  */
  /* REXX-Funktion "Pos" das Zeichen 0D mit Hilfe der REXX-Funktion x2c()  */
  /* dargestellt werden, also mit  x2c(0D).                                */
  q0D=Pos(x2c(0D), si)
  if q0D>0 then si=DelStr(si,q0D)
  return(si) /* EditStrC */



  
EditChar:
  Procedure
  /* ImGegensatz zur ANSI-Prozedur "call Locate y,x", deren Variable */
  /* y fÅr Zeile und x fÅr Spalte mit 1 beginnen, beginnen die       */
  /* Variablen fÅr Zeile und Spalte der Funktion                     */
  /* "parse value SysCurPos with Zeile Spalte" mit dem Wert 0  !!!!  */
  "@ echo off"                                            
  /* Ausgangs-Koordinaten PosY und PosX ermitteln */
  parse value SysCurPos() with PosY PosX 
  enter="0D"; bckspc="08"; esc="1B"

AnfEditChar:  
  call SysCurPos PosY, PosX  
  call Charout," "
  call SysCurPos PosY, PosX  
  done=0; k=1;si=""  
  
  do while done<>1
    
    /* Einlese-Befehl */
    ch=SysGetKey("noecho")
    
    /* Eingabetaste schlie·t die Eingabe ab. */                                
    if c2x(ch)==enter then done=1

    /* Escapetaste leert Eingabefeld. */                            
    if c2x(ch)==esc then Signal AnfEditChar

    /* Sondertasten, deren Tastencode zwei Symbole zurÅckliefert. */
    if c2x(ch)=="00" | c2x(ch)=="E0" then
    do
      /* andere Variable hc unbedingt erforderlich ! */
      hc=SysGetKey("noecho") 
      ch=""; hc=""  
      k=k-1 
    end    
    
    /* Tabtaste und Leertaste werden ignoriert */
    if c2x(ch)=="09" | c2x(ch)=="20" then 
    do
      ch=""
      k=k-1 
    end 

    /* Backspace-Taste fÅr EditChar einrichten. */
    if c2x(ch)==bckspc then Signal AnfEditChar

    /* Es werden nur erlaubte Zeichen eingelesen. */
    if k<=1 & c2x(ch)<>bckspc then
    do
      call Charout,ch
      si=si||ch
      if c2x(ch)==enter then leave
      k=k+1 
    end

  end /* do while */  
  
  /* Ausgabe-Vorbereitung */
  call SysCurPos PosY, PosX
  call CsrAttrib "High";  call Color "white"
  call Charout," "  
  call SysCurPos PosY, PosX
  call Charout,si 
  call CsrAttrib "Normal"
  /* Die folgenden zwei Zeilen sind unbedingt erforderlich, weil in        */
  /* dieser Funktion "EditChar" beim Abschlu· der Eingabe mit "Enter" das  */
  /* hexadezimale Zeichen 0D (dezimal: 13) angehÑngt wird.                 */
  /* (Eine Ausnahme liegt dann vor, wenn genau soviele Zeichen eingegeben  */
  /* werden, wie es die zulÑssige LÑnge des Eingabestrings erlaubt.)       */
  /* Da dieses Zeichen zu den ASCII-Steuerzeichen gehîrt und somit von     */
  /* einem Editor nicht in einen Quelltext eingefÅgt werden kann, mu· fÅr  */
  /* REXX-Funktion "Pos" das Zeichen 0D mit Hilfe der REXX-Funktion x2c()  */
  /* dargestellt werden, also mit  x2c(0D).                                */
  q0D=Pos(x2c(0D), si) 
  if q0D>0 then si=DelStr(si,q0D) 
  return(si) /* EditChar */       
         
EditCharC:
  Procedure
  /* Farbige Ausgabe des Eingabestrings                              */
  /* ImGegensatz zur ANSI-Prozedur "call Locate y,x", deren Variable */
  /* y fÅr Zeile und x fÅr Spalte mit 1 beginnen, beginnen die       */
  /* Variablen fÅr Zeile und Spalte der Funktion                     */
  /* "parse value SysCurPos with Zeile Spalte" mit dem Wert 0  !!!!  */
  "@ echo off"                                            
  /* Ausgangs-Koordinaten PosY und PosX ermitteln */
  parse value SysCurPos() with PosY PosX 
  enter="0D"; bckspc="08"; esc="1B" 

  parse arg fcw,bcw,fca,bca
  
AnfEditCharC:  
  call SysCurPos PosY, PosX  
  call CsrAttrib "High";   call Color fcw,bcw 
  call Charout," "
  call SysCurPos PosY, PosX  
  done=0; k=1; si="" 
   
  do while done<>1
    
    /* Einlese-Befehl */
    ch=SysGetKey("noecho")
    
    /* Eingabetaste schlie·t die Eingabe ab. */                                
    if c2x(ch)==enter then done=1

    /* Escapetaste leert das Eingabefeld. */
    if c2x(ch)==esc then Signal AnfEditCharC

    /* Sonderttasten, deren Tastencode zwei Symbole zurÅckliefert. */                                
    if c2x(ch)=="00" | c2x(ch)=="E0" then
    do
      /* andere Variable hc unbedingt erforderlich ! */
      hc=SysGetKey("noecho")
      ch=""; hc=""  
      k=k-1 
    end                                 
    
    /* Tabtaste und Leertaste werden ignoriert */
    if c2x(ch)=="09" | c2x(ch)=="20" then 
    do
      ch=""
      k=k-1 
    end
    
    /* Backspace-Taste einrichten. */
    if c2x(ch)==bckspc then Signal AnfEditCharC

    /* Es werden nur erlaubte Zeichen eingelesen. */
    if k<=1 & c2x(ch)<>bckspc then
    do  
      call Charout,ch
      si=si||ch
      if c2x(ch)==enter then leave
      k=k+1 
    end

  end /* do while */  
  
  /* Ausgabe-Vorbereitung */
  call SysCurPos PosY, PosX
  call CsrAttrib "HIGH";  call Color fca,bca  
  call Charout," "  
  call SysCurPos PosY, PosX
  call Charout,si 
  call CsrAttrib "Normal"
  /* Die folgenden zwei Zeilen sind unbedingt erforderlich, weil in        */
  /* dieser Funktion "EditCharC" beim Abschlu· der Eingabe mit "Enter" das */
  /* hexadezimale Zeichen 0D (dezimal: 13) angehÑngt wird.                 */
  /* (Eine Ausnahme liegt dann vor, wenn genau soviele Zeichen eingegeben  */
  /* werden, wie es die zulÑssige LÑnge des Eingabestrings erlaubt.)       */
  /* Da dieses Zeichen zu den ASCII-Steuerzeichen gehîrt und somit von     */
  /* einem Editor nicht in einen Quelltext eingefÅgt werden kann, mu· fÅr  */
  /* REXX-Funktion "Pos" das Zeichen 0D mit Hilfe der REXX-Funktion x2c()  */
  /* dargestellt werden, also mit  x2c(0D).                                */
  q0D=Pos(x2c(0D), si) 
  if q0D>0 then si=DelStr(si,q0D) 
  return(si) /* EditCharC */       
        

               
/*------------------------------- ANSI-Prozeduren-Anfang -------------------------------*/
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

/*-------------------------------- ANSI-Prozeduren-Ende --------------------------------*/
                  
