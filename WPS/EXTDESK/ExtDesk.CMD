/* ExtDesk.CMD tries to call EXTINST or EXTREMOV depending on the class */
/* "ExtendedDesktop" already being loaded (EXTREMOV), or not (EXTINST). */

CALL RxFuncAdd 'SysQueryClassList','RexxUtil','SysQueryClassList'

execute='@EXTINST.EXE'
word='enabled'

CALL SysQueryClassList "class."
DO i=1 TO class.0
   IF class.i=='ExtendedDesktop EXTDESK' THEN DO
      execute='@EXTREMOV.EXE'
      word='disabled'
      LEAVE i
   END
END i

SAY
SAY 'ExtDesk.CMD - Extended Desktop Switcher'
SAY 'Result:'
execute
SAY
SAY 'Extended Desktop will be' word 'after the next reboot.'
SAY
SAY 'Press <ENTER>...'
PULL .

EXIT
