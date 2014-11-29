/* WTAG.CMD */
/* Wochentag bestimmen mit der ZELLER() -Funktion */
/* M. Werner, M„rz'96 */

sorted=date('s')
thismonth=SUBSTR(sorted,5,2)
thisyear=SUBSTR(sorted,1,4)
thisday=SUBSTR(sorted,7,2)

weiss=d2c(27) || '[1;37;40m'
rot=d2c(27) || '[1;31;40m'
gruen=d2c(27) || '[1;32;40m'
gelb=d2c(27) || '[1;33;40m'
dklgelb=d2c(27) || '[0;33;40m'

/* Die Parameter-Eingabeform abfragen */
PARSE ARG day'.'month'.'year
IF DATATYPE(day) \= 'NUM' then
PARSE ARG day' 'month' 'year
IF DATATYPE(day) \= 'NUM' then
PARSE ARG day'/'month'/'year
IF DATATYPE(day) \= 'NUM' then
PARSE ARG day'-'month'-'year

/* mit Parameter "?" : Syntax-Hilfe */
IF day='?' then CALL hilfe

/* ohne Parameter : Heute */
IF day='' then
DO
   month=thismonth
   year=thisyear
   day=thisday
   say dklgelb
   say '>>>  SYNTAX-Hilfe : "WTAG ?"  <<<'
   say
   say gelb || 'Wochentag heute :'
END

/* nur mit Tag-Parameter : dieser Monat */
IF month='' & year='' then
DO
   month=thismonth
   year=thisyear
END

/* nur mit Tag- u. Monat-Parameter : dieses Jahr */
IF year='' then year=thisyear

/* Falsche Eingabe abfangen */
IF DATATYPE(day) \= 'NUM' then
   DO
      call fehler
      say gruen || day 'ist keine Zahl'
      call hilfe
   END
IF DATATYPE(month) \= 'NUM' then
   DO
      call fehler
      say gruen || month 'ist keine Zahl'
      call hilfe
   END
IF DATATYPE(year) \= 'NUM' then
   DO
      call fehler
      say gruen || year 'ist keine Zahl'
      call hilfe
   END

/* Die 19.. anh„ngen, wenn sie fehlt */
IF length(year)=2 then year=19||year   

IF length(year) \= 4 then
      DO
         call fehler
         say gruen || 'Die Jahresangabe' year 'ist falsch'
         call hilfe
      END

IF day > 31 | day < 1 then
      DO
         call fehler
         say gruen || 'Die Tagesangabe' day 'ist falsch'
         call hilfe
      END

IF month > 12 | month < 1 then
      DO
         call fehler
         say gruen || 'Die Monatsangabe' month 'ist falsch'
         call hilfe
      END

IF month=2 & year//4=0 then               /* Wenn Schaltjahr */
   IF day = 29 then say gruen || 'Schalttag im Schaltjahr' year
   ELSE IF day > 29 then
      DO
         call fehler
         say gruen || 'Im Schaltjahr' year 'hat der Februar 29 Tage'
         call hilfe
      END
IF month=2 & year//4 >< 0 then            /* kein Schaltjahr */
   IF day > 28 then
      DO
         call fehler
         say gruen || 'Der Februar' year 'hat nur 28 Tage (kein Schaltjahr)'
         call hilfe
      END
IF day = 31 then
   DO
      IF month=4 | month=6 | month=9 | month=11 then
         DO
            call fehler
            say gruen || 'Der Monat' month 'hat nur 30 Tage'
            call hilfe
         END
   END /* do */

say gelb

nummer=ZELLER()

SELECT
   when nummer=0 then say day'-'month'-'year '= ein Sonntag'
   when nummer=1 then say day'-'month'-'year '= ein Montag'
   when nummer=2 then say day'-'month'-'year '= ein Dienstag'
   when nummer=3 then say day'-'month'-'year '= ein Mittwoch'
   when nummer=4 then say day'-'month'-'year '= ein Donnerstag'
   when nummer=5 then say day'-'month'-'year '= ein Freitag'
   otherwise say day'-'month'-'year '= ein Samstag'
END

EXIT

hilfe:
   say gelb
   say 'SYNTAX : WTAG tag monat jahr'
   say 'Dieses Jahr : WTAG tag monat'
   say 'Dieser Monat : WTAG tag'
   say 'Heute : WTAG'
   say dklgelb
   say 'M”gliche Datumsformate :'
   say 'Beispiel :  1 1 99  (bzw.: 01 01 1999)'
   say '    oder :  1.1.99  (bzw.: 01.01.1999)'
   say '    oder :  1/1/99  (bzw.: 01/01/1999)'
   say '    oder :  1-1-99  (bzw.: 01-01-1999)'
   say 'Ist das Jahr < 1900 bzw. > 1999 ,'
   say 'muá das Jahrhundert angegeben werden'
   EXIT

fehler:
say rot
say 'Falsche Datums-Eingabe !'
call beep 512,150
RETURN

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

