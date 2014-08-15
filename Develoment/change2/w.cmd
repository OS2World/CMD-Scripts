/* w.cmd, ein Programm zum eleganten Verzeichnis-Wechsel */
"@ echo off"

  Y="C"             /* Hier den Laufwerksbuchstaben eintragen, auf dem   */
                    /* einige Pufferdateien sowohl w„hrend des Laufes    */
                    /* der w.cmd gespeichert als auch am Ende von w.cmd  */
                    /* wieder gel”scht werde.                            */
  X=Y||":"||"\"

  /* šbernahme des Kommandozeilen-Parameters */
  parse arg ziel
  ziel=strip(ziel)

  /* Nichts eingegeben */
  if length(ziel) = 0
  then do
         "cd\"
         signal E
       end

/************** Laufwerks-Wechsel (Anfang) *********************/

  if length(ziel)=2
  then do
    ziel1 = substr(ziel,2,2)
    if (COMPARE(ziel1,':')=0)
    then do
          ziel "2>" X"FehlLW2.DAT"
      StrLW2=Charin(X"FehlLW2.DAT",1,7)
       call charout(X"FehlLW2.DAT")

      if (COMPARE(StrLW2,"SYS0015") = 0)
      then do
        Call LWAnz substr(ziel, 1, 1)
        signal E
      end  /* Ende von "if (COMPARE(StrLW2,"SYS0015") = 0)" */
      "cd\"
      signal E
    end         /* Ende von "if (COMPARE(ziel1,':')=0)" */
  end           /* Ende von "if length(ziel)=2" */

/************** Laufwerks-Wechsel (Ende) *********************/


/************** Vervollst„ndigung des Pfades (Anfang) ******************/

  if ((Compare(substr(ziel,2,1),':')=0) & (Compare(substr(ziel,3,1),'\')=0))
  then do
         neuZiel=ziel
         SIGNAL AQ
       end

  if ((Compare(substr(directory(),2,1),':')=0) &,
      (Compare(substr(directory(),3,1),'\')=0),
       & (length(directory())>3))
  then do
         neuZiel=directory()||'\'||ziel
         SIGNAL AQ
       end

  neuZiel=directory()||ziel

AQ:
  ziel=neuZiel

/************** Vervollst„ndigung des Pfades (Ende) ******************/


  parse var ziel w.1  '\' w.2  '\' w.3  '\',
                 w.4  '\' w.5  '\' w.6  '\',
                 w.7  '\' w.8  '\' w.9  '\',
                 w.10 '\' w.11 '\' w.12


  if (length(w.1) > 0)
  then do
         w.1 "2>" X"FehlVz1.DAT"
         "cd\"
         StrVz1=Charin(X"FehlVz1.DAT",1,7);
          call charout(X"FehlVz1.DAT")
         if (COMPARE(StrVz1,"SYS0015") = 0)
         then do
                Call LWAnz substr(w.1, 1, 1)
                signal E
              end
       end


  if (length(w.2) > 0)
  then do
         "cd" w.2 "2>" X"FehlVz2.DAT"
         StrVz2=Charin(X"FehlVz2.DAT",1,7);
          call charout(X"FehlVz2.DAT")
         if (COMPARE(StrVz2,"SYS0003") = 0)
         then do
                LwLw=substr(w.1, 1, 1)
                Call LWStamm LwLw w.2
                signal E
              end
       end

  if (length(w.3) > 0)
  then do
         "cd" w.3 "2>" X"FehlVz3.DAT"
         StrVz3=Charin(X"FehlVz3.DAT",1,7);
          call charout(X"FehlVz3.DAT")
         if (COMPARE(StrVz3,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.3
                signal E
              end
       end

  if (length(w.4) > 0)
  then do
         "cd" w.4 "2>" X"FehlVz4.DAT"
         StrVz4=Charin(X"FehlVz4.DAT",1,7);
          call charout(X"FehlVz4.DAT")

         if (COMPARE(StrVz4,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.4
                signal E
              end
       end

  if (length(w.5) > 0)
  then do
         "cd" w.5 "2>" X"FehlVz5.DAT"
         StrVz5=Charin(X"FehlVz5.DAT",1,7);
          call charout(X"FehlVz5.DAT")

         if (COMPARE(StrVz5,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.5
                signal E
              end
       end

  if (length(w.6) > 0)
  then do
         "cd" w.6 "2>" X"FehlVz6.DAT"
         StrVz6=Charin(X"FehlVz6.DAT",1,7);
          call charout(X"FehlVz6.DAT")

         if (COMPARE(StrVz6,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.6
                signal E
              end
       end

  if (length(w.7) > 0)
  then do
         "cd" w.7 "2>" X"FehlVz7.DAT"
         StrVz7=Charin(X"FehlVz7.DAT",1,7);
          call charout(X"FehlVz7.DAT")

         if (COMPARE(StrVz7,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.7
                signal E
              end
       end

  if (length(w.8) > 0)
  then do
         "cd" w.8 "2>" X"FehlVz8.DAT"
         StrVz8=Charin(X"FehlVz8.DAT",1,7);
          call charout(X"FehlVz8.DAT")

         if (COMPARE(StrVz8,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.8
                signal E
              end
       end

  if (length(w.9) > 0)
  then do
         "cd" w.9 "2>" X"FehlVz9.DAT"
         StrVz9=Charin(X"FehlVz9.DAT",1,7);
          call charout(X"FehlVz9.DAT")

         if (COMPARE(StrVz9,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.9
                signal E
              end
       end

  if (length(w.10) > 0)
  then do
         "cd" w.10 "2>" X"FehlVz10.DAT"
         StrVz10=Charin(X"FehlVz10.DAT",1,7);
           call charout(X"FehlVz10.DAT")

         if (COMPARE(StrVz10,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.10
                signal E
              end
       end

  if (length(w.11) > 0)
  then do
         "cd" w.11 "2>" X"FehlVz11.DAT"
         StrVz11=Charin(X"FehlVz11.DAT",1,7);
           call charout(X"FehlVz11.DAT")

         if (COMPARE(StrVz11,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.11
                signal E
              end
       end

  if (length(w.12) > 0)
  then do
         "cd" w.12 "2>" X"FehlVz12.DAT"
         StrVz12=Charin(X"FehlVz12.DAT",1,7);
           call charout(X"FehlVz12.DAT")

         if (COMPARE(StrVz12,"SYS0003") = 0)
         then do
                Call VzUVz directory() w.12
                SIGNAL E
              end
       end

E:
"del" X"Fehl*.DAT 1>NUL 2>NUL"
EXIT

/* %%%%%%%%%%%%%%%%%%%%%%%%%% Eigene Prozeduren %%%%%%%%%%%%%%%%%%%%%%%%%%%%*/


LWAnz:
  parse arg Param
  Call CsrAttrib "High";   Call Color "yellow","black"
  say
  Call Charout,"   Ein Laufwerk  "
                           Call Color "cyan"
  Call Charout,param
                           Call Color "yellow","black"
  Call Charout,"  gibt es nicht auf diesem Computer"
  say
  Call CsrAttrib "Normal"; Call Color "white","black"
  Return













/*
LWAnz:
  parse arg Param
  Call CsrAttrib "High";   Call Color "yellow","black"
  say
  Call Charout,"Auf diesem Rechner gibt es kein Laufwerk  "
                           Call Color "white"
  Call Charout,param
  say
  Call CsrAttrib "Normal"; Call Color "white","black"
  Return
*/

VzUVz:
  parse arg param
  parse value param with param1 param2
  Call CsrAttrib "High";   Call Color "yellow","black"
  say
  Call Charout,"   Ein Unterverzeichnis  "
                           Call Color "cyan"
  Call Charout,param2
                           Call Color "yellow","black"
  say
  Call Charout,"          gibt es nicht  "
  say
  Call Charout,"         im Verzeichnis  "
                           Call Color "cyan"
  Call Charout,param1
  say
  Call CsrAttrib "Normal"; Call Color "white","black"
  Return

LWStamm:
  parse arg param
  parse value param with param1 param2
  Call CsrAttrib "High";   Call Color "yellow","black"
  say
  Call Charout,"       Ein Verzeichnis  "
                           Call Color "cyan"
  Call Charout,param2
  say
                           Call Color "yellow"
  Call Charout,"         gibt es nicht  "
  say
  Call Charout,"   im Stammverzeichnis  "
  say
  Call Charout,"         des Laufwerks  "
                           Call Color "cyan"
  Call Charout,param1
  say
  Call CsrAttrib "Normal"; Call Color "white","black"
  Return

/* %%%%%%%%%%%%%%%%%%%%%%%%%%% ANSI-Prozeduren %%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

Color: Procedure        /* Call Color <ForeGround>,<BackGround> */
arg F,B
Colors = "BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE"
return CHAROUT(,D2C(27)"["WORDPOS(F,COLORS)+29";"WORDPOS(B,COLORS)+39";m")

CsrAttrib: Procedure                  /* call CsrAttrib <Attrib> */
Arg A
attr = "NORMAL HIGH LOW ITALIC UNDERLINE BLINK RAPID REVERSE"
return CHAROUT(,D2C(27)"["WORDPOS(A,ATTR) - 1";m")

EndAll:
Call Color "White","Black"
CALL CsrAttrib "Normal"
