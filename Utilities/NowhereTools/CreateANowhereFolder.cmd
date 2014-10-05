/* CreateANowhereFolder - create a nowhere folder
   $Id: $

   Copyright (c) 2009 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   19 Nov 09 SHL Baseline

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Gbl.!Version = '0.1'

Main:

  parse arg folderNum
  folderNum = strip(folderNum)

  if folderNum \= '' then do
    if \ datatype(folderNum, 'W') then call ScanArgsUsage 'Folder number required'
    if folderNum <= 0 then call ScanArgsUsage 'Folder number must be greater than 0'
  end

  class = 'WPVault'
  title = 'Nowhere' || folderNum
  location = SysBootDrive() || '\'
  setup = ''
  call CreateObject title, location, class, setup

  exit

/* end main */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose Gbl.
  call GetCmdName
  call LoadRexxUtil
  return

/* end Initialize */

/*=== ScanArgsUsage(message) Report Scanargs usage error exit routine ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \== '' then
    say msg
  say 'Usage:' Gbl.!CmdName 'folder-number'
  exit 255

/* end ScanArgsUsage */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== CreateObject(name, location, class, setupString) return 1 if OK ===*/

CreateObject: procedure expose Gbl.
  name = arg(1)
  location = arg(2)
  class = arg(3)
  setup = arg(4)
  /* Create object */
  say 'Creating' name 'as' class 'object'
  rc = SysCreateObject(class,,
		       name,,
		       location,,
		       setup,,
		       'REPLACE')
  if rc \= 1 then
    say 'Can not create' class name 'object'
  return rc	/* 1 if OK */

/* end CreateObject */

/*========================================================================== */
/*=== SkelRexx standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== Error() Report ERROR, FAILURE etc., trace and exit or return if called ===*/

Error:
  say
  parse source . . cmd
  say 'CONDITION'('C') 'signaled at' cmd 'line' SIGL'.'
  if 'CONDITION'('D') \= '' then say 'REXX reason =' 'CONDITION'('D')'.'
  if 'CONDITION'('C') == 'SYNTAX' & 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error =' RC '-' 'ERRORTEXT'(RC)'.'
  else if 'SYMBOL'('RC') == 'VAR' then
    say 'RC =' RC'.'
  say 'Source =' 'SOURCELINE'(SIGL)

  if 'CONDITION'('I') \== 'CALL' | 'CONDITION'('C') == 'NOVALUE' | 'CONDITION'('C') == 'SYNTAX' then do
    trace '?A'
    say 'Enter REXX commands to debug failure.  Press enter to exit script.'
    call 'SYSSLEEP' 2
    if 'SYMBOL'('RC') == 'VAR' then exit RC; else exit 255
  end

  return

/* end Error */

/*=== Fatal(message) Report fatal error and exit ===*/

Fatal:
  parse arg msg
  call lineout 'STDERR', ''
  call lineout 'STDERR', Gbl.!CmdName':' msg
  call Beep 200, 300
  exit 254

/* end Fatal */

/*=== GetCmdName() Get script name; set Gbl.!CmdName ===*/

GetCmdName: procedure expose Gbl.
  parse source . . cmdName
  cmdName = filespec('N', cmdName)	/* Chop path */
  c = lastpos('.', cmdName)
  if c > 1 then
    cmdName = left(cmdName, c - 1)	/* Chop extension */
  Gbl.!CmdName = translate(cmdName, xrange('a', 'z'), xrange('A', 'Z'))	/* Lowercase */
  return

/* end GetCmdName */

/*=== Halt() Report HALT condition and exit ===*/

Halt:
  say
  parse source . . cmd
  say 'CONDITION'('C') 'signaled at' cmd 'line' SIGL'.'
  say 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
  say 'Exiting.'
  exit 'CONDITION'('C')

/* end Halt */

/*=== LoadRexxUtil() Load RexxUtil functions ===*/

LoadRexxUtil:
  if RxFuncQuery('SysLoadFuncs') then do
    call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    if RESULT then
      call Fatal 'Cannot load SysLoadFuncs'
    call SysLoadFuncs
  end
  return

/* end LoadRexxUtil */

/* The end */
