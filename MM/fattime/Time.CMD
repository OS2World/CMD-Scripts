/* Move MP3s randomly to FAT MP3 player */

CALL RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'

mp3='C:\Susan\Multimedia\Music'     /* Base directory of MP3 file library */
size=256                            /* MP3 player's memory size, in MiB   */
usbdrive='B:\'                      /* MP3 player's drive _AND_ directory */
SAY 'Please read TIME.TXT first, you have to edit this file.'
EXIT

SAY 'Deleting all existing files...'
'@DEL' usbdrive||'*.*'

counter=0
picked.=0
size=size*1048576
SAY 'Selecting files...'
CALL SysFileTree mp3||'*.MP3','mp3s.','FOS'
SAY mp3s.0 'files found'
DO counter=1 TO mp3s.0
   fat.counter=D2X(counter,8)||'.MP3'
   copy.counter='@COPY "'||mp3s.counter||'"' usbdrive||fat.counter
   size.counter=Stream(mp3s.counter,'C','QUERY SIZE')
END counter
counter=mp3s.0

counter2=0
DO WHILE size>0 & counter>counter2
   file=Random(1,counter)
   IF picked.file=0 THEN DO
      picked.file=1
      counter2=counter2+1
      copy.file
      SAY fat.file
      SAY size size.file
      size=size-(size.file)
   END
END

EXIT
