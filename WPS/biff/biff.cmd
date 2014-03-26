/* rexx biff - D C Saville January 2002
   dave.saville@ntlworld.com

  Coloured gauge on xcentre
  Green   - No messages
  Yellow - Number of unread messages in inboxes
  Red       - Number of unread messages in inboxes - at least one is urgent
*/

IF RxFuncQuery('SysLoadFuncs') THEN DO
   CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
      CALL SysLoadFuncs
      END

/* find all pmmail account dirs */

/* edit following path to find inboxes */

CALL SysFileTree 'D:\Apps\SouthSide\PMMail\*.act', 'dirs', 'OD'

xdirs = dirs.0 /* number of account dirs */
ToRead = 0
high = 0

DO WHILE xdirs <> 0 /* now count unread messages in inbox */
   inbox = dirs.xdirs'\INBOX.FLD\FOLDER.BAG'

   Do While Lines(inbox) <> 0
     stuff = Linein(inbox)

     Parse Var stuff priority 'DE'x .

     IF BitAnd(Right(priority, 3, 0), '003') = 0 THEN DO
       ToRead = ToRead + 1

       IF Priority = 10 then
         High = 1
     END
   END
   xdirs = xdirs -1
END

rc = Stream(inbox, 'C', 'CLOSE')

IF ToRead = 0 THEN DO
  gauge.1 = 100
  gauge.2 = 100
  gauge.3 = 100
END
ELSE DO

  IF high THEN DO
    gauge.1 = 0
    gauge.2 = 0
    gauge.3 = 100
  END
  ELSE DO
    gauge.1 = 0
    gauge.2 = 100
    gauge.3 = 100
  END
END

gauge.tooltip = 'Biff'
gauge.text = ToRead

EXIT