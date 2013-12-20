/* IA2CSV.CMD - Convert Internet Adventurer Address book to csv format */
/*              so it can be imported into PMMail/2 */

/*              Written by ASchw@worldnet.att.net in May 1999 */

Address = ''
file = 'iaaddr.dat'

SAY ' ' 
SAY 'Converting Internet Adventurer Address book to CSV format for PMMail/2...'
SAY ' '

SAY 'This is a brute force conversion of the file iaaddr.dat.'
SAY 'Addresses are converted by searching for the @ symbol.'
SAY 'Make sure only the e-mail address contains the @ symbol'
SAY 'or this program will terminate prematurely.'
SAY 'Only the e-mail address, alias, name and remarks are'
SAY 'converted, but the program can be changed to decode'
SAY 'more information.'
SAY 'Check the output file NEWADDR.CSV with a text editor'
SAY 'for any invalid entries.'

SAY ' '
SAY 'Press C to start conversion, any other key to exit...'
PARSE PULL keyhit
IF TRANSLATE(keyhit) <> 'C' then
  EXIT

IF Stream( file, 'C', 'Query Exists' ) <> '' THEN    /* file exists */
  DO
    filesize = Chars(file)
    count = 1
    SAY 'There are approx. ' || filesize % 609 || ' addresses to convert.'
    buffer = CharIn(file, 1, filesize)
    DO i = 1 TO filesize
      IF SUBSTR(buffer, i, 1) = '@' THEN
        DO
          call charOut , "1B"x || "[s Saving address " || count || "1B"x || "[u"
          count = count + 1
          charx = ''
          StartX = 0
          EndX = 0
          StartAlias = 0
          EndAliasX = 0
          StartName = 0
          EndName = 0
          StartRemark = 0
          EndRemark = 0

          Address = ''
          Alias = ''
          Name = ''
          Remarks = ''

          /* get address */
          DO j = i to i - 20 BY -1
            IF SUBSTR(buffer, j, 1) = X2C('00') THEN
             DO
               StartX = j + 1
               LEAVE
             END
          END

          DO j = i to i + 40
            IF SUBSTR(buffer, j, 1) = X2C('00') THEN
              DO
                EndX = j
                LEAVE
              END
          END

          IF StartX <> 0 & EndX <> 0 THEN
             Address = '"' || Substr(buffer, StartX, EndX - StartX) || '"'

          /* get alias */
          StartAlias = StartX - 131
          DO j = StartAlias to StartAlias + 16
            IF SUBSTR(buffer, j, 1) = X2C('00') THEN
             DO
               EndAliasX = j
               LEAVE
             END
          END

          IF StartAlias <> 0 & EndAliasX <> 0 THEN
             Alias = '"' || Substr(buffer, StartAlias, EndAliasX - StartAlias) || '"'

          /* get name */
          StartName = StartX - 98
          DO j = StartName to StartName + 50
            IF SUBSTR(buffer, j, 1) = X2C('00') THEN
             DO
               EndName = j
               LEAVE
             END
          END

          IF StartName <> 0 & EndName <> 0 THEN
             Name = '"' || Substr(buffer, StartName, EndName - StartName) || '"'

          /* get remarks */
          StartRemark = StartX + 389
          DO j = StartRemark to StartRemark + 50
            IF SUBSTR(buffer, j, 1) = X2C('00') THEN
             DO
               EndRemark = j
               LEAVE
             END
          END

          IF StartRemark <> 0 & EndRemark <> 0 THEN
             Remarks = '"' || Substr(buffer, StartRemark, EndRemark - StartRemark) || '"'

          temp = 'Adr,' || Address || ',' || Alias || ',' || Name || ',1,,,,,,,,,,,,,,,,,,,,,' || Remarks
          rc=LINEOUT('NEWADDR.CSV', temp)

        END
    END

    rc=LINEOUT('NEWADDR.CSV') /*close*/
    SAY ' '
    SAY 'Conversion completed. See file NEWADDR.CSV for result.'
  END
ELSE
  SAY 'File IAADDR.DAT not found.'

EXIT

