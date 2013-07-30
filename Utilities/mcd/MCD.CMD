/* MCD.CMD, (c) AD 1998-2009 */

PARSE ARG arguments

counter=0
list.0=''
DO WHILE arguments<>''
   PARSE VAR arguments dirname arguments
   IF Left(dirname,1)='"' THEN DO
      arguments=dirname arguments
      PARSE VAR arguments '"' dirname '"' arguments
   END
   IF dirname<>'' THEN DO
      counter=counter+1
      list.counter='"'||dirname||'"'
   END
END

DO i=1 TO counter
   '@MD' list.i
END i

'@CD' list.counter

EXIT
