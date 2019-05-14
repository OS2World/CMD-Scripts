/* -----------------------------------------------------------------------
   Programmname     : Snake.CMD
   Version          : 1.0
   Voraussetzungen  : keine
   Verwendungszweck : rumdîdeln

   Autor / Datum    : Detlev Ahlgrimm / 21.01.1996


   Bemerkungen      :
    - Die Nummer des ersten Gebiets kann als Befehlszeilenparameter
      Åbergeben werden.

    - Die Schlange wird mit den Cursortasten gesteuert. ESC bricht das
      Spiel ab.

    - Nach dem Gebiet mit der Nummer 20 wird im aktuellen Pfad nach den
      Dateien GEBIET21.DAT, GEBIET22.DAT, ... gesucht. Diese Gebiete werden
      als Fortsetzung der integrierten Gebiete verwendet. Das Format dieser
      Fortsetzungsdateien gebe ich erst auf Anforderung via email heraus :-)
      Wer mîchte, kann es anhand des Programms natÅrlich auch selbst
      heraustÅfteln - eine email an mich ist aber sicherlich weniger
      aufwendig.
           Fido    : Detlev Ahlgrimm @ 2:240/5202.42
           Internet: DAhlgrimm @ hqsys.shnet.org

    - Snake.cmd ist FreeWare. Ich garantiere bezÅglich snake.cmd fÅr nix.
 ---------------------------------------------------------------------- */
PARSE ARG lvl

/*
SIGNAL ON FAILURE NAME CLEANUP
SIGNAL ON HALT    NAME CLEANUP
SIGNAL ON SYNTAX  NAME CLEANUP
*/

IF RxFuncQuery('SysLoadFuncs')=1 THEN DO
   CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
   CALL SysLoadFuncs
END

/* globale Variablen als solche definieren */
global="gebiet_pack. gebiet. schlange. mampfer. bewegung. glob. scr. CLEANUP"

/* einige globale Variablen mit Daten fÅllen */
bewegung.L.x=-1;   bewegung.L.y=0
bewegung.R.x=1;    bewegung.R.y=0
bewegung.O.x=0;    bewegung.O.y=-1
bewegung.U.x=0;    bewegung.U.y=1

glob.Frei        =" "
glob.Igel        =D2C(15)
glob.Frosch      =D2C(1)
glob.Mauer       =D2C(177)
glob.Mampfer     =D2C(233)
glob.Schlange    ="o"
glob.SchlangeKopf="S"

glob.obj.char =glob.Igel || glob.Frosch || glob.Mauer ||,
               glob.Mampfer || glob.Schlange
glob.obj.char2="î*#m"
glob.ansi=TestAufANSI()
glob.leben=4
glob.wartezeit=0.3

/* Fenster-Grundeinstellungen */
"@MODE 40,25 1>NUL 2>NUL"
CALL SysCls
PARSE VALUE SysTextScreenSize() WITH scr.zeilen scr.spalten

CALL GepackteGebietsDatenDefinieren

/* ggf. Levelnummer von der Befehlszeile Åbernehmen */
IF lvl="" THEN geb=1
ELSE           geb=lvl

SAY
SAY
SAY "Bitte geben sie ihren Namen ein:"
SAY
CALL CHAROUT , "   "
PARSE PULL spielername
IF spielername="" THEN spielername="Unbekannt"

CALL SysCls
CALL SysCurState "off"   /* Cursor aus */

startlvl=geb

/* Intro-Screen ausgeben */
IF geb=1 THEN DO
   CALL CHAROUT , FarbeEinbauen(intro)
   CALL SysCurPos 23, 13
   SAY "Leertaste....."
   CALL LeertasteHolen
END

/* Schleife Åber die Spiele */
DO FOREVER
   IF GebietLaden(geb)=0 THEN
      LEAVE /* Gebiet gibt's nich */

   CALL GebietAusgeben geb

   CALL SysCurPos 23, 16
   CALL CHAROUT , "Start mit Leertaste.."
   CALL LeertasteHolen
   CALL StatusAusgeben

   IF SchlangeSteuern()=1 THEN DO  /* hier spielt die Musik */
      DO i=1 TO 5
         CALL BEEP 1000+50*i, 50
      END
      geb=geb+1
   END; ELSE DO
      DO i=1 TO 30
         CALL BEEP 1000-30*i, 10
      END
      glob.leben=glob.leben-1
      IF glob.leben=0 THEN
         LEAVE
   END
END

endelvl=geb

CALL NeuenHighScoreAufnehmen startlvl, endelvl, spielername
CALL ZeigeHighScoreTabelle
CALL CHAROUT , CENTER("Leertaste.....", 40)
CALL LeertasteHolen

CLEANUP:
CALL SysCurPos 23, 0
EXIT 0



/* -----------------------------------------------------------------------
   Ein Gebiet laden. Au·erdem werden einige Grundeinstellungen
   vorgenommen.
   Spiele oberhalb Nummer 20 werden im aktuellen Pfad gesucht. Der
   Dateiname hat den Aufbau "GEBIET??.DAT". "??" entspricht der Nummer.
*/
GebietLaden: PROCEDURE EXPOSE (global)
   ARG gebietsnummer

   IF gebietsnummer<=20 THEN DO
      CALL Entpack gebiet_pack.gebietsnummer
   END; ELSE DO
      fn="GEBIET" || RIGHT('0' || gebietsnummer, 2) || ".DAT"

      IF STREAM(fn, "C", "QUERY EXISTS")="" THEN
         RETURN(0)

      i=1
      DO WHILE LINES(fn)
         gebiet.i=LINEIN(fn)
         i=i+1
      END
      gebiet.0=i-1
   END

   gebiet.froesche=0
   mampf_cnt=0

   DO i=1 TO gebiet.0
      gebiet.i=TRANSLATE(gebiet.i, glob.obj.char, glob.obj.char2)

      p=POS('S', gebiet.i)    /* Position der Schlange */
      IF p>0 THEN DO
         schlange.x=p-1
         schlange.y=i-1
      END

      p=POS(glob.Mampfer, gebiet.i)    /* Positionen der Mampfer */
      DO WHILE p>0
         mampf_cnt=mampf_cnt+1
         mampfer.mampf_cnt.x=p-1
         mampfer.mampf_cnt.y=i-1
         mampfer.mampf_cnt.richtung="R"
         p=POS(glob.Mampfer, gebiet.i, p+1)
      END

      p=POS(glob.Frosch, gebiet.i)    /* die Frîsche werden nur gezÑhlt */
      DO WHILE p>0
         gebiet.froesche=gebiet.froesche+1
         p=POS(glob.Frosch, gebiet.i, p+1)
      END
   END

   schlange.richtung="R"
   schlange.schwanz=schlange.x || ',' || schlange.y
   schlange.verlaengerung=0
   schlange.tot=0

   mampfer.0=mampf_cnt
RETURN(1)



/* -----------------------------------------------------------------------
   Gibt das aktuelle Gebiet aus.
*/
GebietAusgeben: PROCEDURE EXPOSE (global)
   ARG geb

   CALL SysCurPos 0, 0
   m=glob.Mauer

   DO i=1 TO gebiet.0
      ln=FarbeEinbauen(gebiet.i)
      IF scr.spalten=40 THEN
         CALL CHAROUT , ln
      ELSE
         SAY ln   /* der MODE-Befehl war nicht erfolgreich */
   END
   SAY FarbeEinbauen(" " || m || " Gebiet" RIGHT('0' || geb, 2),
                     m || m || " Frîsche    " || m || m ||,
                     " Leben   " || m)
   CALL StatusAusgeben
RETURN



/* -------------------------------------------------------
   Liefert 1, wenn ANSI verfÅgbar.
*/
TestAufANSI: PROCEDURE
   SAY
   PARSE VALUE SysCurPos() WITH p1y p1x
   /* an den Anfang der Zeile, und dann per ANSI einen hoch */
   CALL CHAROUT , D2C(13) || '1B'x || '[1A'
   PARSE VALUE SysCurPos() WITH p2y p2x

   IF p1y=p2y THEN   /* gleiche Zeilen -> ANSI(hoch) war erfolglos */
      RETURN(0)      /* -> ANSI nicht verfÅgbar */
   CALL SysCurPos p1y, p1x
RETURN(1)



/* -----------------------------------------------------------------------
   Setzt die Farbattribute im Åbergebenen String "q" und liefert das
   Ergebnis als RÅckgabe.
*/
FarbeEinbauen: PROCEDURE EXPOSE (global)
   PARSE ARG q

   IF glob.ansi=0 THEN RETURN(q) /* kein ANSI -> keine Farben */

   z=""
   DO i=1 TO LENGTH(q)
      c=SUBSTR(q, i, 1)
      SELECT
         WHEN c=glob.Mauer THEN
            z=z || "1B"x || "[1;31m" || glob.Mauer   || "1B"x || "[0m"
         WHEN c=glob.Frosch THEN
            z=z || "1B"x || "[1;32m" || glob.Frosch  || "1B"x || "[0m"
         WHEN c=glob.Igel THEN
            z=z || "1B"x || "[1;34m" || glob.Igel    || "1B"x || "[0m"
         WHEN c=glob.Mampfer THEN
            z=z || "1B"x || "[1;33m" || glob.Mampfer || "1B"x || "[0m"
         OTHERWISE z=z || c
      END
   END
RETURN(z)



/* -----------------------------------------------------------------------
   Gibt die Statuszeile aus.
*/
StatusAusgeben: PROCEDURE EXPOSE (global)
   CALL SysCurPos 23, 16
   SAY FarbeEinbauen("Frîsche" RIGHT('0' || gebiet.froesche, 2),
                     glob.Mauer || glob.Mauer || " Leben" glob.leben)
RETURN



/* -----------------------------------------------------------------------
   Holt eine Bewegungsrichtung (ohne zu warten, falls keine eingegeben
   wurde). ESC fÅhrt zu Abbruch des Programms.
*/
TasteHolen: PROCEDURE EXPOSE (global)
   IF CHARS()=0 THEN DO
      RETURN("")
   END

   /* Taste holen und Buffer lîschen */
   DO WHILE CHARS()>0
      key=C2D(SysGetKey("NOECHO"))
      IF key=224 THEN
         key=C2D(SysGetKey("NOECHO"))
   END

   SELECT
      WHEN key=27 THEN SIGNAL CLEANUP /* ESC */
      WHEN key=75 THEN rc="L"         /* Cursor links */
      WHEN key=77 THEN rc="R"         /* Cursor rechts */
      WHEN key=72 THEN rc="O"         /* Cursor hoch */
      WHEN key=80 THEN rc="U"         /* Cursor runter */
      OTHERWISE
         rc=""    /* keine oder illegale Taste gedrÅckt */
   END
RETURN(rc)



/* -----------------------------------------------------------------------
   Wartet auf eine BetÑtigung der Leertaste.
   ESC fÅhrt zu Abbruch des Programms.
*/
LeertasteHolen: PROCEDURE EXPOSE (global)
   key="x"
   DO WHILE key<>" "
      key=SysGetKey("NOECHO")
      IF C2D(key)=27 THEN
         SIGNAL CLEANUP
   END
RETURN



/* -----------------------------------------------------------------------
   Wartet die angegebene Anzahl von Sekunden (ungefÑhr).
   Der Timer mu· zuvor zurÅckgesetzt worden sein.
*/
Warten: PROCEDURE
   ARG sek

   ueberlast=0
   DO WHILE TIME("Elapsed")<sek
      NOP
      ueberlast=1
   END
/*
   IF ueberlast=0 THEN
      CALL BEEP 1000,10
*/
RETURN


/* -----------------------------------------------------------------------
   Hier lÑuft die Hauptschleife fÅr ein Spiel.
*/
SchlangeSteuern: PROCEDURE EXPOSE (global)
   geschafft=0

   DO WHILE geschafft=0
      CALL TIME "Reset"
      /* Mampfer bewegen (bei vielen Mampfern werden nicht alle bewegt) */
      limcnt=0
      IF mampfer.0>0 THEN
         DO mampf_cnt=1 TO mampfer.0

            IF mampfer.0>3 THEN
               IF RANDOM(mampfer.0)<mampfer.0-3 THEN
                  ITERATE

            limcnt=limcnt+1
            IF limcnt>5 THEN LEAVE
            CALL MampferBewegen mampf_cnt
         END

      IF schlange.tot=1 THEN DO
         LEAVE /* Mampfer hat den Kopf der Schlange gefressen */
      END

      key=TasteHolen()
      IF key<>"" THEN
         schlange.richtung=key   /* Richtungswechsel */

      /* neue Position nach dem Schritt berechnen */
      rtg=schlange.richtung
      schlange.x=schlange.x + bewegung.rtg.x
      schlange.y=schlange.y + bewegung.rtg.y

      IF schlange.x<0 | schlange.x>39 | schlange.y<0 | schlange.y>23 THEN
         LEAVE /* das Spielfeld wurde verlassen */

      /* testen, ob die neue Position fÅr die Schlange ungesund ist */
      neu=TestBewegung(schlange.x, schlange.y)

      IF neu<>glob.Frei & neu<>glob.Frosch THEN DO
         CALL SchlangeBewegen /* ...sie ist ziemlich ungesund */

         IF neu=glob.Igel     THEN LEAVE
         IF neu=glob.Mauer    THEN LEAVE
         IF neu=glob.Mampfer  THEN LEAVE
         IF neu=glob.Schlange THEN LEAVE
      END

      /* einen Schritt durchfÅhren */
      CALL SchlangeBewegen

      /* ein Frosch wurde gefressen */
      IF neu=glob.Frosch THEN DO
         gebiet.froesche=gebiet.froesche-1

         CALL BEEP 1000, 10
         CALL BEEP 500, 10
         CALL StatusAusgeben

         IF gebiet.froesche=0 THEN DO
            geschafft=1
         END
      END

      CALL Warten glob.wartezeit
   END
RETURN(geschafft)



/* -----------------------------------------------------------------------
   Verwaltet den Schlangen-Schwanz.
   (der Schanz kann vom Mampfer gekappt werden !)
*/
SchlangeBewegen: PROCEDURE EXPOSE (global)
   /* neue Position dem "Schwanz" zufÅgen */
   schlange.schwanz=schlange.x || ',' || schlange.y schlange.schwanz
   schlange.verlaengerung=schlange.verlaengerung+1

   lng=WORDS(schlange.schwanz)

   /* ehemaliger Kopf ist nun Schwanz -> Zeichen Ñndern */
   IF lng>1 THEN DO
      PARSE VALUE WORD(schlange.schwanz, 2) WITH zx ',' zy
      CALL Print zx, zy, glob.Schlange
   END

   IF schlange.verlaengerung>3 THEN DO
      schlange.verlaengerung=0   /* Schlange wird lÑnger - nix lîschen */
   END; ELSE DO
      PARSE VALUE WORD(schlange.schwanz, lng) WITH hx ',' hy
      CALL Print hx, hy, glob.Frei   /* hinteres Schwanzende wegmachen */
      schlange.schwanz=SUBWORD(schlange.schwanz, 1, lng-1)
   END

   /* Kopf ausgeben */
   CALL Print schlange.x, schlange.y, glob.SchlangeKopf
RETURN



/* -----------------------------------------------------------------------
   Bewegt den Mampfer mit der Nummer "mampf_cnt".
*/
MampferBewegen: PROCEDURE EXPOSE (global)
   ARG mampf_cnt

   /* Mampfer macht einen Schritt */
   rtg=mampfer.mampf_cnt.richtung
   tmp.x=mampfer.mampf_cnt.x + bewegung.rtg.x
   tmp.y=mampfer.mampf_cnt.y + bewegung.rtg.y
   tmp=TestBewegung(tmp.x, tmp.y)   /* Schritt mîglich ? */

   IF tmp=glob.Frei | tmp=glob.Schlange THEN DO
      alt.x=mampfer.mampf_cnt.x     /* Schritt mîglich -> durchfÅhren */
      alt.y=mampfer.mampf_cnt.y

      mampfer.mampf_cnt.x=tmp.x
      mampfer.mampf_cnt.y=tmp.y

      IF tmp=glob.Schlange THEN
         CALL MampferSchlangeKollision mampf_cnt

      CALL Print alt.x, alt.y, glob.Frei
      CALL Print mampfer.mampf_cnt.x, mampfer.mampf_cnt.y, glob.Mampfer
   END; ELSE DO
      /* Schritt nicht mîglich -> Wechsel der Bewegungsrichtung */
      mampfer.mampf_cnt.richtung=SUBSTR("LROU", RANDOM(3)+1, 1)
   END
RETURN



/* -----------------------------------------------------------------------
   Mampfer bei·t Schlange.
*/
MampferSchlangeKollision: PROCEDURE EXPOSE (global)
   ARG mampf_cnt

   /* Kopf der Schlange */
   PARSE VALUE WORD(schlange.schwanz, 1) WITH vx ',' vy

   /* Kopfbi· -> Exitus der Schlange */
   IF mampfer.mampf_cnt.x=vx & mampfer.mampf_cnt.y=vy THEN DO
      schlange.tot=1
      RETURN
   END

   /* sucht die Bi·position im Schwanz der Schlange */
   such=mampfer.mampf_cnt.x || ',' || mampfer.mampf_cnt.y
   p=WORDPOS(such, schlange.schwanz)
   IF p=0 THEN
      RETURN   /* kann eigentlich nicht vorkommen */

   /* wandelt den Schwanz ab der Bi·position in Mauer um */
   DO i=p TO WORDS(schlange.schwanz)
      PARSE VALUE WORD(schlange.schwanz, i) WITH vx ',' vy
      CALL Print vx, vy, glob.Mauer
   END

   /* Schwanz kappen */
   schlange.schwanz=SUBWORD(schlange.schwanz, 1, p-1)
RETURN



/* -----------------------------------------------------------------------
   Liefert den Inhalt an der Koordinate "x", "y".
*/
TestBewegung: PROCEDURE EXPOSE (global)
   ARG x, y
   y=y+1
RETURN(SUBSTR(gebiet.y, x+1, 1))



/* -----------------------------------------------------------------------
   Setzt das Zeichen "c" an der Koordinate "x", "y" im Fenster und
   im Feld.
*/
Print: PROCEDURE EXPOSE (global)
   PARSE ARG x, y, c

   CALL SysCurPos y, x
   CALL CHAROUT , FarbeEinbauen(c)

   y=y+1
   gebiet.y=OVERLAY(c, gebiet.y, x+1)
RETURN



/* -----------------------------------------------------------------------
   Entpackt ein gepacktes Spielfeld (in "strg") in das globale
   Array "gebiet.".
*/
Entpack: PROCEDURE EXPOSE (global)
   PARSE ARG strg

   ln=""
   geb_ln=0
   DO WHILE LENGTH(strg)>0
      lng=C2D(LEFT(strg, 1))

      /* LauflÑngencodierung */
      IF lng>C2D('a') THEN DO
         lng=lng-C2D('a')        /* ungepackte Daten */
         ln=ln || SUBSTR(strg, 2, lng)
         strg=SUBSTR(strg, lng+2)
      END; ELSE DO
         lng=lng-C2D('A')        /* Zeichenfolge */
         ln=ln || COPIES(SUBSTR(strg, 2, 1), lng)
         strg=SUBSTR(strg, 3)
      END

      IF LENGTH(ln)>=20 THEN DO  /* eine Zeile voll ? */
         geb_ln=geb_ln+1
         gebiet.geb_ln=""

         /* 4 Bit -> 8 Bit umwandeln */
         DO i=1 TO LENGTH(ln)
            c=C2D(SUBSTR(ln, i, 1))
            c=c-C2D("1")+11
            /* zweistellige Zahl als String anhÑngen */
            gebiet.geb_ln=gebiet.geb_ln || c
         END

         /* Zahlen nach Spielfeld wandeln */
         gebiet.geb_ln=TRANSLATE(gebiet.geb_ln, "#î*Sm ", "123456")
         ln=""
      END
   END
   gebiet.0=geb_ln
RETURN



/* -----------------------------------------------------------------------
   Introschirm und ein paar Gebiete global definieren.
*/
GepackteGebietsDatenDefinieren:

IF scr.spalten=40 THEN crlf=""
ELSE                   crlf="0A0D"x

intro=TRANSLATE(,
 "3333333333333333333333333333333333333333" || crlf ||,
 "3                                      3" || crlf ||,
 "3    333   <---  Mauer                 3" || crlf ||,
 "3                                      3" || crlf ||,
 "3    444   <---  Igel                  3" || crlf ||,
 "3                                      3" || crlf ||,
 "3    555   <---  Schlangenmampfer      3" || crlf ||,
 "3                                      3" || crlf ||,
 "3    777   <---  Frîsche               3" || crlf ||,
 "3                                      3" || crlf ||,
 "3333333333333333333333333333333333333333" || crlf ||,
 "3 Sie  sind  eine  Schlange  und haben 3" || crlf ||,
 "3 Hunger. Frîsche sind ihre Lieblings- 3" || crlf ||,
 "3 speise, Igel hingegen sind ihnen ein 3" || crlf ||,
 "3 Greul. Auch die Mauern  munden ihnen 3" || crlf ||,
 "3 nicht sonderlich. Und die Schlangen- 3" || crlf ||,
 "3 mampfer machen sogar Jagd auf sie.   3" || crlf ||,
 "3 Beweisen sie ihre Geschicklichkeit ! 3" || crlf ||,
 "3333333333333333333333333333333333333333" || crlf ||,
 "3  DOS       1990                      3" || crlf ||,
 "3  OS/2-REXX 1996 von Detlev Ahlgrimm  3" || crlf ||,
 "3              fÅr Wiebke              3" || crlf ||,
 "3333333333333333333333333333333333333333",,
 glob.Mauer || glob.Igel || glob.Mampfer || glob.Frosch, "3457")


gebiet_pack.1=,
 "U1b6Jhb6HhcJcb6Fhb^Dhb6Ihbcb6Jhd6dJGhbcb6Jhb6Ihbcd6hJDhf@ehh6Ihbcb6Jhk" ||,
 "16hhc11hhcb6NhbcEhbcb6Dhb@DhbdFhcceDhbcb6MhcJcEhbcc11Mhgchh^hcg6hhdhEI" ||,
 "hbcEhbcb6Dhi11hhehh@I1b6Shbcb6Phe@hhcd6heQhbcd6hdMhbcDhbcb6HhbdEhhehc^" ||,
 "hhcb6Ohfc1hJcb6EhdJh6Ihechhcc6fFhb6Ihechhcb6Ghb6LhbcU1"

gebiet_pack.2=,
 "U1c3EJhbcDhfdhhJcc6cEhcJ@DhdchdFhbcm6c11c116hdhcEheJhhcc6cMhb@Ehbce6hh" ||,
 "eNhddhcb6OhbcE1b6JhbdIhbcQ1ehc11E1b2F<Ehg116h11E1b2FGkhehh116h11E1c2FE" ||,
 "<Ehg116h11E1c2FE<Ehg11^c11E1b2FGhhehh16hD1E1b2F<Ehd1hcD1K1Ehd16hD1b6Nh" ||,
 "g11hc11b6Shbch6h@hTh@Mhbcb6Shbcb6Khcc6Ghbcb6Khcc6GhbcU1"

gebiet_pack.3=,
 "U1b3ShbEb3FhbcG1b6FhbEF1chcG1c6hF1b6Shbcb6ShbcJ1chcJ1b6Rhc11b6Rhc11o6h" ||,
 "h@hJh@hJh@hJEhc11o6hhJh@hJh@hJh@Ehc11o6hh@hJh@hJh@hJEhc11b6Rhc11H1bhJ1" ||,
 "dh11H1Lhc11H1bhJ1dh11H1EhbgGhc11H1bhJ1dh11H1Lhc11H1Lhc11H1bGJ1dh11c6fO" ||,
 "heeGhcU1"

gebiet_pack.4=,
 "U1i6hc11hGGEhceGFhbcd6heD1bcF1c6hG1d6hhD1bcD1Jhb1u6hh116h116hd<hhdFhhc" ||,
 "u16c11hhc16heGhhdFhhcb6Hhm16hd<hhdFhhcb6Hhcc1Jhb1f6hGGJEhL1f6hGGJEhbcK" ||,
 "1f6hGGJFhF1b5E1f6hGGJFhbcE1b6E1f6hGGJGhE1b6E1b6KhbcD1b6E1b6LhD1b6E1f6h" ||,
 "GGJEhhGJhc116E1f6heheDhiehehh116E1q6hehhJhhJhhJhc16E1i6hehhJhhDGfJhh16" ||,
 "E1f6heheDhiJhhJhhc6E1q6hGGJh@hJhhJdhh6E1c6TOhE1U1"

gebiet_pack.5=,
 "U1u3hh3hh3hh3hh3hh3hh3cu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6ch6" ||,
 "ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6Ed6Ed6Ed6E" ||,
 "d6Ed6Ed6Eu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch" ||,
 "6cu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu3c@3c@3c@3c@3c@3c@3cu6ch6" ||,
 "ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6ch6ch6ch6c" ||,
 "h6ch6ch6cu6ch6ch6ch6ch6ch6ch6cu6Eh6Eh6Eh6Eh6Eh6Eh6Eu6ch6ch6ch6ch6ch6ch" ||,
 "6cu4chhchhchhchhchhchhcU1"

gebiet_pack.6=,
 "U1b6GhF1FhdJhcb6DhdehhF1Hhbcd6hJEhF1cheDhdJhcb6EhcehF1Hhbcb6GhF1Hhbcb6" ||,
 "GhF1ihhJhhJhci6hehJhh5DgbcHhbcb6Ghb6D^bYHhbcb6Ghb5DgbcDhbJDhbce6hhJDhb" ||,
 "6D^bYHhbcc6eFhb5DgbcHhbcb6Ghb1D^j1hhehhehcb6Ghf15gc1Hhbcb6Dhiehh11^11H" ||,
 "hbce6hhJDhh11g11heFhbce6hheDhf11h11Hhbcb6EhbeKheehhcb6Shbcd6heLhbeEhbc" ||,
 "b6EhbJNhbcb4ShbcU1"

gebiet_pack.7=,
 "U1b6Shbcb6DhbJOhbcb6ShbcM1c6hG1b6Dhb^OhbcF1c6hN1b6EhbgNhbcJ1c6hJ1b6Jhb" ||,
 "gIhbcI1chcK1b6NhbgEhbcD1c6hH1chcG1b6Fhb^MhbcH1chcL1b6Lhb^GhbcM1chcG1c6" ||,
 "gRhbcI1chcK1b6JhbcJ1b6KhbcI1b4LhbcH1U1"

gebiet_pack.8=,
 "U1b6Fhb6FhbJGhbcj6hhedh6h@Fhb@DhcJcb6Jhb@EhbJDhbcd6h@FhcgeJhbcb6Mhc@eE" ||,
 "hbcb6Ehg6hdhh3Ihbcc6dDhc11Dhb6Ihbcb6Jhb6DhgdJhghcf6hhJ@Ehb@Jhbcc6JHhee" ||,
 "hheEhddhcb6Dhdc1EDhbdDhg16hehce6hh@Phbcb6Ghi@hhJhhgJEhbcd6heFhbJDheJhh" ||,
 "@Dhbcb6EhbeFhb@Hhbcl6ghhdhh@c16Ehfc1hhcd6hdHhbeEhfc1hhce6hheDhcJeDhbdF" ||,
 "hc^cb6Shbcb6EhcJdDhbJEhb6Dhbcb4Lhiehh6hhecU1"

gebiet_pack.9=,
 "U1e3chcL1f6@Jdcb6DcLhf6@hdcb6EcJ1g66@hdcb6EcJhg66@hdcb6FcH1D6e@hdcb6Fc" ||,
 "HhD6e@hdcb6GcF1E6e@hdcb6GcFhE6e@hdcb6HcD1F6e@hdcb6HcDhF6e@hdcb6Icb1G6e" ||,
 "@hdcb6IcbJG6e@hdcb6HcchhG6e@hdcb6Hcc11F6f5@hdYb6GcEhF6e@hdcb6Ecc1cE1c6" ||,
 "1D6e@hdcb6DcKhg66@hdcb6DcK1g66@hdcd6ccMhf2<d<;d6hcM1b6Dhbcb4ShbcU1"

gebiet_pack.10=,
 "U1b6IhbeJhbcb6Shbcf6c116J1b6D1c6cb6IhbgJhbEc6cH1b6I1c6cb3DhbgEhbeEhbgE" ||,
 "hbcf6c116J1b6D1c6cb6IhbgJhbEc6cH1b6I1c6cb3DhbgEhbeEhbgEhbcf6c116J1b6D1" ||,
 "c6cb6IhbgJhbEc6cH1b6I1c6cb3DhbgEhbeEhbgEhbcf6c116J1b6D1c6cb6IhbgJhbEc6" ||,
 "cH1b6I1c6cb6Shbcb6Shbcb6Shbcb4ShbcU1"

gebiet_pack.11=,
 "U1b6Shbcb6Shbcu6c16c16c16c16c16c16cu6cG6cG6cG6cG6cG6cG6cu6cG6cG6cG6cG6" ||,
 "cG6cG6cu6cG6cG6cG6cG6cG6cG6cb6Shbcb6Shbcu6hh3Eh3Eh3Eh3Eh3Ehhcu6hh3Eh3E" ||,
 "h3Eh3Eh3Ehhcu6hh3Eh3Eh3Eh3Eh3Ehhcu6hh11h11h11h11h11hhcb6Shbcb6Shbcb6Sh" ||,
 "bcc6hPcdhhcd6hcP6chcc6hPcd6hcu6hc^gh^gh^gh^gh^g6hcu6hch^gh^gh^gh^gh^6h" ||,
 "cu6hcgh^gh^gh^gh^gh6TcU1"

gebiet_pack.12=,
 "U1b2D<b@Fhkghgdh^gh^cb2D<Hhjghh^gghdce2<<@DhbcD1j6^^hZhg^cd2<<Ehb1Dhj1" ||,
 "h@gh^hhcd2<@Dhoc6eGJc6gh^@hZcc2<Ehc1hDGjh1h?hghhcc2@Dhdc6eDGfJchggD^b;" ||,
 "b2EhcchFGih5hh^^gcb2Ehc1eFGiJ1gh^dgcb2Ehc1eFGcJ1Dhdghcb2Ehc1eFGiJ1hgdh" ||,
 "gcb2Ehc1eFGiJ1h^gghcb2EhcchFGdh6^Dhc^cc2@Dhdc6eDGcJcDhe^hgcc2<GhDGjh1h" ||,
 "?gh@^;d2<@FhgeGJc6dDhd^^cd2<<Ehb1Dhj1h^gd^h@ce2<<@DhbcD1b6Fhd^dcb2D<Eh" ||,
 "hc16@^hgDhcgcb2D<b@Dhmc16hh^@^h^hcb4Hhmc16^h^h^^dhYU1"

gebiet_pack.13=,
 "U1b6IhbeJhbcd6hdGhcEJGhd@hce6h<@Ehde63Fhed<hce6d<<EheEhcJEhe<<@cb6D<i@" ||,
 "hhe6hh3DhbdD<bcb6GhbEDhccJGhbcb6Fhhe6hghh3Ghbcb6FhbEFhccJFhbcb6Ehje6hg" ||,
 "hghh3Fhbcb6EhbEHhccJEhbcb6Dhle6hghghghh3Ehbcb6DhbEJhccJDhbcq6hhe6hghgh" ||,
 "ghghh3Dhbce6hhELhfcJhhcu6he6hghghghghghh3hhcd6hENhecJhcd6e6Ohd3hcc6cQ1" ||,
 "chcb6Shbcb6Shbcb4ShbcU1"

gebiet_pack.14=,
 "U1o3GGhhcYcYcYcYcDhdGGEd3GGOhdGGEb1Shb1b5Shbcb1Shb1b6ShbYb1Shb1b5Shbcb" ||,
 "1Shb1b6ShbYb1Shb1b5Shbcb1Shb1b6ShbYb1Shb1b5Shbcb1Shb1b6Shbcb6Shbcb6Qhd" ||,
 "GGEb4EhjccYcYcYcYDhdGGEU1"

gebiet_pack.15=,
 "U1b6Shbcu6hGGJheGGhhGGJheGGhcu6hJhJhehehhJhJhehehcu6hJ^JhegehhJ^Jhegeh" ||,
 "cu6hJhJhehehhJhJhehehcu6hGGJheGGhhGGJheGGhcb6Shbcb6Shbcb6Shbcb6Shbcb6S" ||,
 "hbcb6Shbcb6Shbcb6Shbcu6h@hdhh@hdhh@hdhh@hcu2hh@hdhh@hdhh@hdhh@cu6dhh@h" ||,
 "dhh@hdhh@hdhh;b6Shbcb6Shbcb6Shbcb4ShbcU1"

gebiet_pack.16=,
 "U1b6Dheehh6HhbJDhbcl6Jdhheh6JhJIhbcb6Ghc16Dhie@hhcehci6c16@hhdIhech@ch" ||,
 "6he6hegDhk116hhdchhcb6IhlJcJ^ehhchecc6eDhcc1DhkchhGJehc1ch6h@hJhEFhdc1" ||,
 "1Ehbcl6hehhdhhehdHhc@cf6@hhgHhedhhdDhbEb6FhoJhc6hJhgh11hc1E1DhjdcJhhEJ" ||,
 "h6Dhbcf6hJE@Dhmc^hc16h6hehcb6HhbcFhc@6Dhbch6J@e6hcDhbJGhd6Jcu6c116ecJ@" ||,
 "hgehhJh@6hci6hhdhhcGEhb@Ehd6dcj6hehh^c11EhbcD1d6hcb6DhcedEhbJEhf6h@hcb" ||,
 "6GhnJhh@hhdh6hhecb4DhbJDhd@hJEhf6ehhcU1"

gebiet_pack.17=,
 "U1b6RhcJcb6Hhb^JhcJcc3EQ1c6cp6chhehJeJehehhGDhc6cu6chhehJJeehehehJhh6c" ||,
 "u6chheGJGGehehehJhh5cu6chhehJJeehehehJhh6cp6chhehJJeeGeGhGDhc6cc6cQhc6" ||,
 "cu6chhJehGhJeehJGGhh6ck6chhJeehJJDechJDhc6cu6chhGGeGJJeeJhGJhh6ck6chhJ" ||,
 "eehJJDechJDhc6cu6chhJeehJeJehJGGhh6cc6cQhc6cc5cP1dG6cc6eNhf^hh6cc6eQhc" ||,
 "6cS1c3Eb6MhbeFhbcb4Lhc^eFhbcU1"

gebiet_pack.18=,
 "U1c6hH1d6hcI1d6JcG1chJJ1d6hhF1d6hcJ1e1hhcE1Khcc1e16hhD1b6IheJh11h11hhc" ||,
 "11Khdc11j116hh16hcG1chhD1D1fhhchhG1d6hcD1D1b6DhbcG1chhE1E1DhG1d6hcE1E1" ||,
 "d6hcG1DhE1E1chhG1b6DhbcD1D1b6Khd6hhD1D1FhbJEhhc1hhc11d116Khh116hh11f11" ||,
 "hhcL1ehhc1e16hhM1e6hh1e1hhcN1dhhcd6hhO1d6ecd6hcP1chcc4hQ1c6cU1"

gebiet_pack.19=,
 "U1b6Jhb6Ihbcb6I1e6616G1bcc66HhE6EhDcb6H1E6F1Dcb6HhF6DhEcb6G1G6E1Dcc66F" ||,
 "hH6DhDcc66E1I6D1DcD6DhF6fh66hhEcD6c11F6d116D1EcE6bhG6ch6DhEcE6b1I6E1Dc" ||,
 "F6bhI6DhDcN6F1cccE6b3I6EhDcE6b1H6F1DcE6chhG6FhDcd616D1c61D6H1cccb6Ihb6" ||,
 "IhcccT1bcb4ShbcU1"

gebiet_pack.20=,
 "U1b6HhbeJhcJcb6Fhb@FhddheEhbcd6JdEhdJhcHhdJdcb6EhbeDhh6hJhhJcDhbcj6hhe" ||,
 "hh@hcGhb6Dhbcb6GhbeDhjdh^cJ@hhcg6e@Jh6DhlJhheh6hhdhEb6EhdEhdEhb@Dhe6hh" ||,
 "ch6@hchh6Hhg@hcJhce6eh6DhgJhh@eeEhd3hcj6hchJ@hh6GhfJhchcb6EhgehchhcHhc" ||,
 "6cd6@eEhf3h^J6Eheghecb6DhdJhcEhdchFDhdFhcd6hdDhe6hhJFhb6Dhbcd3h^Fhh@hh" ||,
 "@hhcEhbcp6hheh@hhJheheh6Ehbcb6EhbeHhhcJdhh6Ed6dJKhb6Dhd@ccb6FhiJdhh@hc" ||,
 "eFhb1b4DhbJLheehhcN1b3G1"
RETURN



/* -----------------------------------------------------------------------
   Nimmt "name" mit den Werten "sg", "eg" und dem Tagesdatum in die
   Highscore-Tabelle auf - wenn die Gebietsdifferenz besser als die
   bisher schlechteste Gebietsdifferenz ist.
*/
NeuenHighScoreAufnehmen: PROCEDURE EXPOSE (global)
   PARSE ARG sg, eg, name

   /* Daten des neuen Eintrags */
   datum=TRANSLATE(DATE('E'), '.', '/')
   nhss=FormatiereHighScoreZumSchreiben(sg, eg, datum, name)
   nhsz=eg-sg

   hs=""
   hslim=10 /* Maximum der EintrÑge */
   cnt=0
   IF LeseHighScore()=1 THEN DO
      DO i=1 TO glob.highscore.0
         PARSE VALUE glob.highscore.i WITH sg eg datum name
         hsz=eg-sg
         IF nhsz>hsz & nhss<>"" THEN DO
            hs=hs || nhss   /* neuen Eintrag einfÅgen */
            nhss=""
            cnt=cnt+1
            IF cnt>=hslim THEN LEAVE
         END
         hs=hs || FormatiereHighScoreZumSchreiben(sg, eg, datum, name)
         cnt=cnt+1
         IF cnt>=hslim THEN LEAVE
      END
   END

   IF cnt<hslim THEN
      hs=hs || nhss   /* nhss="", wenn schon enthalten */

   /* in den EAs des Scripts ablegen */
   PARSE SOURCE . . this_file
   rc=SysPutEA(this_file, "SnakeHS", hs)
RETURN



/* -----------------------------------------------------------------------
   Formatiert die Daten "sg", "eg", "datum" und "name" so um, da· sie
   in den EAs abgelegt werden kînnen. Der formatierte String wird als
   RÅckgabewert geliefert.
*/
FormatiereHighScoreZumSchreiben: PROCEDURE
   PARSE ARG sg, eg, datum, name
   str=RIGHT('0' || sg, 2) || RIGHT('0' || eg, 2) || datum || name || D2C(0)
RETURN(str)



/* -----------------------------------------------------------------------
   LÑdt die Highscore-Tabelle in das globale Array "glob.highscore.".
   Im Fehlerfall wird 0 zurÅckgeliefert - sonst 1.
*/
LeseHighScore: PROCEDURE EXPOSE (global)
   PARSE SOURCE . . this_file
   nxt=D2C(0)
   i=0

   IF SysGetEA(this_file, "SnakeHS", "hs")=0 THEN DO
      DO WHILE hs<>""
         PARSE VALUE hs WITH sg 3 eg +2 d +8 n (nxt) hs
         i=i+1
         glob.highscore.i=sg eg d n
      END
      glob.highscore.0=i
      RETURN(1)
   END
RETURN(0)



/* -----------------------------------------------------------------------
   LÑdt die Highscore-Tabelle und zeigt sie danach an.
*/
ZeigeHighScoreTabelle: PROCEDURE EXPOSE (global)
   IF scr.spalten=40 THEN crlf=""
   ELSE                   crlf="0A0D"x

   titel=CENTER("Highscore", 38)
   IF glob.ansi=0 THEN DO
      mauer=glob.Mauer
   END; ELSE DO
      mauer="1B"x || "[1;31m" || glob.Mauer || "1B"x || "[0m"
      titel="1B"x || "[1;32m" || titel      || "1B"x || "[0m"
   END

   CALL LeseHighScore
   CALL SysCls
   CALL CHAROUT , COPIES(mauer, 40) || crlf
   CALL CHAROUT , mauer || titel    || mauer || crlf
   CALL CHAROUT , COPIES(mauer, 40) || crlf
   DO i=1 TO 10
      IF i<=glob.highscore.0 THEN DO
         PARSE VALUE glob.highscore.i WITH sg eg datum name
         str=LEFT(sg'-'eg datum name, 36)
      END; ELSE
         str=COPIES(' ', 36)
      CALL CHAROUT , mauer str mauer || crlf

      IF i=1 THEN
         CALL CHAROUT , mauer || COPIES('-', 38) || mauer || crlf
      ELSE IF i<10 THEN
         CALL CHAROUT , mauer || COPIES(' ', 38) || mauer || crlf
   END
   CALL CHAROUT , COPIES(mauer, 40) || crlf
RETURN
