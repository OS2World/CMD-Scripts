/* MONITOR.CMD */

/* RexxUtil functions used */

CALL RxFuncAdd 'SysCls','RexxUtil','SysCls'
CALL RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
CALL RxFuncAdd 'SysSleep','RexxUtil','SysSleep'

/* CTRL-Break catcher */

SIGNAL ON Halt

/* AEX   NL0000000107 */
/* BEL20 BE0389555039 */
/* CAC40 FR0003500008 */
/* PSI20 PTING0200002 */

/* Change this "isin="-line to change the stock exchange index in use */ 

isin='NL0000000107'


CALL SysCls
SAY

mep=''
IF isin=='NL0000000107' THEN mep=2
IF isin=='BE0389555039' THEN mep=3
IF isin=='FR0003500008' THEN mep=1
IF isin=='PTING0200002' THEN mep=5
IF mep='' THEN DO
   SAY 'Invalid ISIN-code:' isin
   SAY
   SAY 'Change the ISIN-code by changing this line:'
   SAY SourceLine(20)
   SAY
   EXIT
END
 
u='--user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.5b)"'
url='"http://www.euronext.com/trader/summarizedmarket/stocks-2634-NL-'
url=url||isin||'.html?selectedMep='||mep||'"'

IF Stream('INDEX','C','QUERY EXISTS')<>'' THEN CALL SysFileDelete 'INDEX'
'@WGET -q' u '-OINDEX' url
IF Stream('INDEX','C','QUERY EXISTS')<>'' THEN DO
   bestand=CharIn('INDEX',1,28672)
   CALL CharOut 'INDEX'
   PARSE VAR bestand . 'LAST_PRICE">' index '<' .
   index=Strip(index)
   IF DataType(Left(index,1))='NUM' THEN SAY Date() Time() '-' Translate(index,'.,',',.')
END

IF Date('B')//7<5 THEN DO
   DO WHILE Time('S')<63600
      DO WHILE Time('S')>32160
         CALL SysSleep 14
         '@WGET' u '-q -OINDEX' url
         IF Stream('INDEX','C','QUERY EXISTS')<>'' THEN DO
            bestand=CharIn('INDEX',1,28672)
            CALL CharOut 'INDEX'
            CALL SysFileDelete 'INDEX'
            PARSE VAR bestand . 'LAST_PRICE">' index '<' .
            index=strip(index)
            IF DataType(Left(index,1))='NUM' THEN SAY Date() Time() '-' Translate(index,'.,',',.')
         END
      END
   END
END

IF Stream('INDEX','C','QUERY EXISTS')<>'' THEN CALL SysFileDelete 'INDEX'

EXIT

Halt:

IF Stream('INDEX','C','QUERY EXISTS')<>'' THEN CALL SysFileDelete 'INDEX'
EXIT
