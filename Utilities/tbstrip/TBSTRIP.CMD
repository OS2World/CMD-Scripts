/* TBSTRIP.CMD - Output last lines of an (ASCII) source file */

/* (c) Torus Brokers 1997 */

/* Usage information ? */

ARG params

IF params='' | params='-?' | params='/?' THEN DO
   SAY
   SAY
   SAY 'TBSTRIP sends the last (specified number of) lines of a (specified)'
   SAY 'file to an (specified) output device. Usage :'
   SAY
   SAY '   TBSTRIP <filename> <lines> <UNC|device> [-?|/?]'
   SAY
   SAY 'Where -? or /? is optional, to display this usage information.'
   SAY
   SAY '   <filename> source file'
   SAY '   <lines>    number of lines to send to output device'
   SAY '   <UNC>      UNC of output device (optional), or'
   SAY '   <device>   Output device (filename, LPTx, PRN, etc.)'
   SAY
   SAY 'Examples :'
   SAY
   SAY '   TBSTRIP C:\CONFIG.SYS 60 \\server\printer'
   SAY '   TBSTRIP C:\CONFIG.SYS 60 "HPFS filename"'
   SAY '   TBSTRIP "HPFS filename" 60 LPT2'
   SAY '   TBSTRIP /?'
   SAY
   EXIT
END

/* Take care of parameters */

PARSE VAR params filename rest
IF Left(filename,1)='"' THEN DO
   params=filename rest
   PARSE VAR params '"' filename '"' rest
END

IF rest='' THEN DO
   SAY
   SAY
   SAY 'Invalid number of parameters. Type "TBSTRIP /?" for usage'
   SAY 'information.'
   SAY
   EXIT
END

PARSE VAR rest linenrs sendto
IF Left(sendto,1)='"' THEN DO
   rest=linenrs sendto
   PARSE VAR rest linenrs '"' sendto '"'
END

IF sendto='' THEN DO
   SAY
   SAY
   SAY 'Invalid number of parameters. Type "TBSTRIP /?" for usage'
   SAY 'information.'
   SAY
   EXIT
END

IF DataType(linenrs,'W')=0 THEN DO
   SAY
   SAY
   SAY 'Number of lines to send to output device not valid. This must'
   SAY 'be a whole number, 1 or more.'
   SAY
   EXIT
END

/* UNC specified ? Use it as the output device */

unc=0

IF Left(sendto,2)='\\' THEN DO
   uncname=FileSpec('Name',sendto)
   sendto='TBSTRIP.TMP'
   unc=1
END

/* Specified source file exists ? */

IF Stream(filename,'c','query exists')='' THEN DO
   SAY 'File' filename 'not found.'
   EXIT
END

/* Number of lines at least 1 ? */

IF linenrs<1 THEN DO
   SAY
   SAY
   SAY 'Number of lines to send to output device not valid. This must'
   SAY 'be a whole number, 1 or more.'
   SAY
   EXIT
END

/* Count and read lines in source file */

line.0=linenrs
count=0

DO WHILE Lines(filename)>0
   x=LineIn(filename)
   IF x<>'' THEN DO
      count=count+1
      line.count=x
   END
END
CALL LineOut filename

/* Nothing to output ? */

IF count=0 THEN DO
   SAY 'File' filename 'is empty.'
   EXIT
END

/* Skip lines ? */

first=1
last=count
IF last>linenrs THEN first=count-linenrs+1

/* Output */

DO i=first TO last
   retval=LineOut(sendto,line.i)
   IF retval<>0 THEN DO
      SAY 'Cannot send output to file or device' sendto||'.'
      CALL LineOut sendto
      EXIT
   END
END i

CALL LineOut sendto

IF unc=0 THEN EXIT

/* Output (UNC only) */

'@COPY' sendto uncname
'@DEL' sendto

EXIT

