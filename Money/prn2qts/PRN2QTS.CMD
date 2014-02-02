/* Converts PRN to QTS, v1.2 */

NUMERIC DIGITS 17

CALL RxFuncAdd 'SysIni','RexxUtil','SysIni'

inifile='PMSTOCK.INI'
SAY
SAY "Quick&dirty conversion of Metastock's *.PRN to PM$tock's *.QTS file format"
SAY
IF Stream(inifile,'C','QUERY EXISTS')='' THEN DO
   SAY 'Error: file' inifile 'not found in' Directory()
   EXIT
END
CALL CharOut '','Which symbol to convert (e.g. RDSA)? '
PARSE PULL symbol
symbol=Translate(Strip(symbol))
IF symbol='' THEN EXIT
IF Length(symbol)>5 THEN EXIT
CALL SysIni inifile,'*P Tracked S*','All:','test.'
file=symbol||'.QTS'
IF Stream(file,'C','QUERY EXISTS')<>'' THEN DO
   SAY
   SAY 'Error: file' file 'already exists'
   EXIT
END
SAY 'Output will be written to file:' file
SAY
CALL CharOut '','Date from (YYYYMMDD, e.g. 20090000 or 20090101 for 20090101)? '
PULL first
first=Strip(first)
IF first='' THEN EXIT
IF Datatype(first,'W')=0 THEN EXIT 
IF first<19000000 THEN EXIT
IF first>Date('S') THEN EXIT
SAY
SAY 'Date upto and including (YYYYMMDD, e.g. 20100131 or 20100200 for 20100131),'
CALL CharOut '','or press <ENTER> for all data since' first||'? '
PULL final
final=Strip(final)
IF final<>'' THEN DO
   IF Datatype(final,'W')=0 THEN EXIT 
   IF final<first THEN EXIT
   IF final>Date('S') THEN EXIT
END
IF final='' THEN final=Date('S')
SAY
SAY

firstyear=Left(first,4)
finalyear=Left(final,4)
counter=0
DO year=firstyear TO finalyear
   source=year||'.PRN'
   IF Stream(source,'C','QUERY EXISTS')='' THEN DO
      SAY 'Error: file' source 'not found in' Directory()
      EXIT
   END
   SAY 'Processing file:' source
   data=LineIn(source)
   DO WHILE Lines(source)>0
      dataline=Strip(LineIn(source))
      PARSE VAR dataline ticker ',' period ',' day ',' open ',' high ',' low ',' close ',' volume ',' .
      IF ticker==symbol THEN DO
         IF day>=first THEN DO
            IF day<=final THEN DO
               counter=counter+1
               PARSE VAR day 1 y 5 m 7 d 9 . 
               part1.counter=m||'/'||d||'/'||y||',00:00'
               part2.counter=Format(close,,6)
               part3.counter='0.000000'
               part4.counter=Format(open,,6)||','||Format(high,,6)||','||Format(low,,6)||','||Format(volume,,0)
            END
         END
      END
   END
   CALL LineOut source
END year

IF counter=0 THEN DO
   SAY 'Error: no data found for symbol' symbol 'between' first 'and' final
   EXIT
END

SAY
SAY 'Lines found:' counter
SAY

IF counter>1 THEN DO
   DO i=2 TO counter
      j=i-1
      part3.i=Format((part2.i)-(part2.j),,6)
   END i
END

CALL LineOut file,counter
DO i=1 TO counter
   CALL LineOut file,part1.i||','||part2.i||','||part3.i||','||part4.i
END i

SAY 'File created:' file
SAY
found=0
DO i=1 TO test.0
   IF Strip(test.i)==symbol THEN found=i
END i
IF found=0 THEN DO
   CALL SysIni inifile,'*P Tracked S*',symbol,'Checked'||D2C(0)   
   SAY symbol "added to PM$tock's list of tracked stocks in" inifile||"." 
END

EXIT
