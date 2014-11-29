/* MONAT.CMD */
/* M O N A T S K A L E N D E R  */ 
/* mit der ZELLER-Funktion */
/* M. Werner, MÑrz 1996 */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

sorted=date('S')
thismonth=SUBSTR(sorted,5,2)
thisyear=SUBSTR(sorted,1,4)

gruen=d2c(27) || '[1;32;40m'
dklgruen=d2c(27) || '[0;32;40m'
rot=d2c(27) || '[1;31;40m'
grau=d2c(27) || '[0;37;40m'

/* Die Parameter abfragen */
PARSE ARG month'.'year
IF DATATYPE(month) <> 'NUM' then
PARSE ARG month' 'year
IF DATATYPE(month) <> 'NUM' then
PARSE ARG month'/'year
IF DATATYPE(month) <> 'NUM' then
PARSE ARG month'-'year

/* Syntax-Hilfe : Monat ? */
IF  month='?' then call hilfe

/* ohne Parameter : dieser Monat */
IF month='' then 
   DO
      month=thismonth
      year=thisyear
   END

/* nur mit Monat-Parameter : dieses Jahr */
IF year='' then year=thisyear

/* Falsch Eingabe abfangen */
IF DATATYPE(month) \= 'NUM' then
   DO
      call fehler
      say gruen || 'Die Monatsangabe "' month '" ist keine Zahl'
      call hilfe
   END
IF DATATYPE(year) \= 'NUM' then
   DO
      call fehler
      say gruen || 'Die Jahresangabe "' year '" ist keine Zahl'
      call hilfe
   END

IF month > 12 | month < 1 then
   DO
      call fehler
      say gruen || 'Die Monatsangabe "' month '" ist falsch'
      call hilfe
   END

/* Die 19.. anhÑngen, wenn sie fehlt */
IF length(year)=2 then year=19||year  
IF length(year) \= 4 then
   DO
      call fehler
      say gruen || 'Die Jahresangabe "' year '" ist falsch'
      call hilfe
   END

/* Wochentag des 1. des Monats */
day=1
num=ZELLER() +1

/* Der 1. des Monats wird an die richtige Position gerÅckt */
week=''
DO num-1
   week=week || '   '
END

/* Wieviele Tage hat der Monat */
SELECT
   when month=2 then
      IF year//4 = 0 then     /* Schaltjahr */
      mthLen=29
      ELSE
      mthLen=28
   when month=4 | month=6 | month=9 | month=11 then
      mthLen=30
   otherwise
      mthLen=31
END  /* select */

call SysCls
do 3
   say
end /* do */
say dklgruen || center('>>>  SYNTAX-Hilfe : "MONAT ?"  <<<', 60)
do 2
   say
end /* do */

/* TabellenÅberschrift */
say gruen
say Center(month || '/' || year,60)
say Center('  S  M  D  M  D  F  S' , 60)

/* éu·ere Schleife: Max. 6 Wochen */
/* Innere Schleife: Formatiert num u. hÑngt den Tag an week */
DO wk=1 to 6 UNTIL day > mthLen
   DO num=num to 7 UNTIL day > mthLen
      week=week Format(day,2)
      day=day+1
   end /* do */
   num=1
   say '                   'week
   week=''
end /* do */

/* ZELLER's Congruence */
ZELLER:
If month > 2 then
DO
   adjMonth = month - 2
   adjYear = year
end
ELSE
DO
   adjMonth = month + 10
   adjYear = year - 1
end /* do */

century = adjYear % 100
yearInCentury = adjYear - 100 * century
dayOfWeek= ((13 * adjMonth -1) % 5 + day + yearInCentury + yearInCentury % 4+ century % 4 - century -century +77) // 7
return dayOfWeek

fehler:
say rot
   say 'Inkorrekte Datumseingabe'
   call beep 512, 150
   return

hilfe:
   say grau
   say ' Syntax : MONAT monat jahr'
   say ' Dieses Jahr : MONAT monat'
   say ' Dieser Monat : MONAT' || gruen
   say ' MONAT         -dieser Monat'
   say ' MONAT 5       -Mai diese Jahres'
   say ' MONAT 1 99    -Januar 1999' || grau
   say ' auch :   1/99'
   say '          1.99'
   say '          1-99'
   say ' auch mit fÅhrenden Nullen und 19.. :'
   say '          01 1999'
   say '          01/1999'
   say '          01.1999'
   say '          01-1999'
   say ' Bei einem Datum < 1900 und > 1999'
   say ' mu· das Jahrhundert angegeben werden'
   exit

