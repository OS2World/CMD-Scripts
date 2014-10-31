/* LogSpam.cmd: Log spam filter hits

   Copyright (c) 2002 Steven Levine and Associates, Inc.
   All rights reserved.

   $TLIB$: $ &(#) %n - Ver %v, %f $
   TLIB: $ $

   Revisions	13 Sep 02 SHL - Release

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call LoadFuncs

Main:

  parse arg szTag szMsgFile

  /* Assume called from REXX Filter action
     Usage: LogSpam Tag Filename
     Output: Tag Date Time MsgFileName
     Tag is filter id tag
  */

  szMsgFile = strip(szMsgFile)

  env = 'OS2ENVIRONMENT'
  szSubject = ' Subject:' value("MR2I.SUBJECT",,env)
  szTo = ' To:' value("MR2I.TO",,env)
  szFrom = ' From:' value("MR2I.FROM",,env)

  szLogFile = 'e:\tmp\icespam.log'

  call lineout szLogFile, szTag date() time() szMsgFile szTo szFrom szSubject
  call stream szLogFile, 'C', 'CLOSE'

  exit 0

/* end main */

/*=================================================================== */
/*=== Initialization and setup - Delete unused, but do not modify === */
/*=================================================================== */

/*=== LoadFuncs: Load fuctions ===*/

LoadFuncs:

/* Add all Rexx functions */
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  if RESULT then do
    say 'Cannot load SysLoadFuncs'
    exit 255
  end
  call SysLoadFuncs
end /* end do */

return

/* end LoadFuncs */

/*========================================================= */
/*=== Error Handlers - Delete unused, but do not modify === */
/*========================================================= */

/*=== Error() Trap ERROR, FAILURE etc. - returns szCondition or exits ===*/

Error:
  say
  parse source . . szThisCmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' szThisCmd
  if 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error' RC':' 'ERRORTEXT'(RC)
  say 'Source =' 'SOURCELINE'(SIGL)
  if 'CONDITION'('I') == 'CALL' then do
    szCondition = 'CONDITION'('C')
    say 'Returning'
    return
  end
  trace '?A'
  say 'Exiting'
  call 'SYSSLEEP' 2
  exit

/* end Error */

/*=== Halt() Trap HALT condition - returns szCondition or exits ===*/

Halt:
  say
  parse source . . szThisCmd
  say 'CONDITION'('C') 'signaled at' SIGL 'of' szThisCmd
  say 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
  if 'CONDITION'('I') == 'CALL' then do
    szCondition = 'CONDITION'('C')
    say 'Returning'
    return
  end
  say 'Exiting'
  exit

/* end Halt */

/* The end */
