/* IsISIN.CMD v1.1 */

PARSE ARG isincode

mode=0
IF isincode='' THEN DO
   SAY 'International Securities Identifying Number verifyer v1.1'
   SAY
   SAY 'Enter a case-sensitive ISO-6166 Alpha-2 ISIN code with a length of 12'
   CALL CharOut '','characters, for example "IT0123456789"? ' 
   PARSE PULL isincode
   SAY
   IF isincode='' THEN EXIT
   isincode=Strip(isincode)
   mode=1
END

IF Length(isincode)<>12 THEN DO
   IF mode=0 THEN RETURN 1
   SAY isincode 'is NOT a valid ISIN code (invalid length)'
   EXIT
END

valid=0
DO i=1 TO 2
   item.i=SubStr(isincode,i,1)
   IF Pos(SubStr(isincode,i,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ')>0 THEN valid=valid+1
   IF valid<>i THEN DO
      IF mode=0 THEN RETURN 2
      SAY isincode 'is NOT a valid ISIN code, invalid character at position' i
      EXIT
   END
END i
DO i=3 TO 11
   item.i=SubStr(isincode,i,1)
   IF Pos(item.i,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')>0 THEN valid=valid+1
   IF valid<i THEN DO
      IF mode=0 THEN RETURN 3 
      SAY isincode 'is NOT a valid ISIN code, invalid character at position' i
      EXIT
   END
END i
item.12=SubStr(isincode,12,1)
IF Pos(item.12,'0123456789')>0 THEN valid=valid+1
IF valid<>12 THEN DO
   IF mode=0 THEN RETURN 4
   SAY isincode 'is NOT a valid ISIN code, invalid character at position 12' 
   EXIT
END

DO i=1 TO 11
   IF Pos(item.i,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',1)>0 THEN item.i=C2D(item.i)-C2D('A')+10
END i

isin=''
DO i=1 TO 11
   isin=isin||item.i
END i

correction=Length(isin)//2
multiplied=''
DO i=1 TO Length(isin) 
   character=SubStr(isin,i,1)
   IF (i+correction)//2=0 THEN character=character*2
   multiplied=multiplied||character
END i

sum=0
DO i=1 TO Length(multiplied)
   sum=sum+SubStr(multiplied,i,1)
END i

IF (sum+item.12)//10<>0 THEN DO
   IF mode=0 THEN RETURN 5
   SAY isincode 'is NOT a valid ISIN code, checksum failure'
   EXIT
END

IF mode=0 THEN RETURN 0
SAY isincode 'is possibly a valid ISIN code'

EXIT
