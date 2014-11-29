/* ALARMIN.CMD */
/* Alarmclock mit Memory-Funktion */
/* Syntax : ALARMIN minuten memory */
/* Beispiel : ALARMIN 10 Kaffeepause(= Alarm in 10 Minuten, Kaffeepause) */
/* Ab 0.1 Minuten (= Alarm in 6 Sekunden) */
/* M.Werner, M„rz'96 */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

clear = '1B'x || '[2J'
schwarzBack = '1B'x || '[40m'
gruen = '1B'x || '[1;32m'
dklgruen = '1B'x || '[0;32m'
rot = '1B'x || '[1;31m'
weiss = '1B'x || '[1;37m'

ARG anzahl memory
say  weiss || schwarzBack

IF anzahl='' then
   DO
   say dklgruen
   say 'Syntax bei Direktaufruf:  ALARMIN minuten memory'
   say '                   z.B.:  ALARMIN 10 Kaffeepause'
   say '                   (=>in 10 Minuten Kaffeepause)'
   say gruen
   say 'Syntax hier:  minuten memory'
   say '       z.B.:  10 kaffeepause'
   say '       (=>in 10 Minuten Kaffeepause)'
   pull anzahl memory
   END
IF anzahl='' then exit

/* Falsche Eingabe abfangen */
IF DATATYPE(anzahl) <> 'NUM' then CALL Fehler
IF anzahl < 0.1 then CALL Fehler
parse var anzahl '.' hintermKomma
IF length(hintermKomma) > 1 then CALL Fehler

anzahl = anzahl * 60     /* Minuten in Sekunden umrechnen */

say clear
DO FOREVER
   zeit=time(e)
   parse value zeit with sec '.'

   /* Alarm ausl”sen */
      IF sec  > anzahl then do
         say dklgruen
         say center('             'rot || anzahl/60 || dklgruen 'MINUTEN sind vorbei !',60)
         say rot
         say center(memory' !',60)
            DO 3
               call beep 500,200
               call syssleep(1)
            END /* do 5 */
         LEAVE
      END

      /* Zeit-Anzeige */
      say clear
      say weiss
      do 3
         say
      end /* do */
      say center(' A L A R M I N ',60)
      say center('Eingabe :' anzahl/60 'Minuten',60)
      say center('     Memory :' rot || memory, 60)
      say dklgruen
      say center('VORBEI :' sec%60 'min,' sec-sec%60*60 'sec',60)
      say copies(' Û', sec%60)
      say copies('', sec-sec%60*60) || gruen
      say copies('', anzahl-sec-(anzahl-sec)%60*60)
      say copies(' Û', (anzahl-sec)%60)
      say center('NOCH :' (anzahl-sec)%60 'min,' anzahl-sec-(anzahl-sec)%60*60 'sec',60)
      call syssleep(1)
END /* do forever */

EXIT

Fehler:
say rot
say 'Falsche Minuteneingabe :'
say '          - keine Zahl'
say '          - kleiner als 0.1'
say '          - mehr als 1 Stelle hinterm Komma'
say gruen
say 'Syntax : ALARMIN minuten memory'
say '         z.B.: ALARMIN 10 Kaffeepause'
say '         (=> Alarm in 10 Minuten, Kaffeepause)'
call beep 500,150
EXIT

