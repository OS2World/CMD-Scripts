/* linear_memory_map - write Theseus Linear Memory Map to timestamped file or stdout
   Avoids Theseus GUI window full issues
   Use - to request output to stdout

   Copyright (c) 2012 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License, Version 2.  The GPL Software License can be found
   in gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   2012-09-24 SHL Baseline
   2012-10-18 SHL Handle RT2LoadFuncs1 nits

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

G.!Version = '0.1'

Main:

  parse arg cmdLine
  cmdLine = strip(cmdLine)

  select
  when cmdLine == '-' then do
    call Pass2
  end
  when cmdLine == '-?' then do
    say 'Usage:' G.!CmdName '[filename]'
  end
  otherwise
    call Pass1 cmdLine
  end

  exit

/* end main */

/*=== Pass1() Redirect to stdout ===*/

Pass1: procedure expose G.

  parse arg fn

  if fn == '' then
    fn = directory() || '\' || MakeTimestampedFileName(G.!CmdName || '.lst')

  say 'Writing to' fn

  parse source . . cmd
  if Is4OS2() then
    cmd = '@'cmd '-' '>'fn
  else do
    shell = value('COMSPEC',, G.!Env);
    cmd = shell '/c' cmd '-' '>'fn
  end
  cmd

  return

/* end Pass1 */

/*=== Pass2() Write output to stdout ===*/

Pass2: procedure expose G.

  /* Theseus directory must be in PATH and LIBPATH
   * or must run from Theseus directory
   */
  do 1
    exe = 'theseus4.exe'
    dir = ''
    s = SysSearchPath('PATH', exe)
    if s \== '' then leave		/* Assume in LIBPATH too */
    /* Check well known places */
    dir = 'd:\devtools\theseus4\' || exe
    dir = stream(dir, 'C', 'QUERY EXISTS')
    if dir \== '' then leave
    call Fatal exe 'not found in PATH or well-known places'
  end

  if dir \== '' then do
    i = lastpos('\', dir)
    dir = substr(dir, 1, i - 1)		/* Chop \exename from path */
    olddir = directory()
    call WarnMsg 'Running from' dir
    call directory dir			/* Run from Theseus directory */
  end

  call RxFuncQuery 'RT2LoadFuncs1'
  if RESULT then do
    call RxFuncAdd 'RT2LoadFuncs1', 'THESEUS1', 'RT2LoadFuncs1'
    if RESULT then
      call Fatal 'RxFuncAdd failed for RT2LoadFuncs1 with RESULT' RESULT
  end
  /* FIXME TO doc why RT2LoadFuncs1 must always be run - must do some extra init */
  call RT2LoadFuncs1
  if RESULT then
    call Fatal 'RT2LoadFuncs1 failed with error' RESULT

  nop

  call RT2GetLinMemMap

  if dir \== '' then
    call directory olddir

  call WarnMsg 'Done'

  return

/* end Pass2 */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose G.
  call GetCmdName
  call LoadRexxUtil
  G.!Env = 'OS2ENVIRONMENT'
  return

/* end Initialize */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

/*=== Is4OS2() Return true if 4OS2 running ===*/

Is4OS2: procedure expose G.
  call setlocal
  '@set X=%@eval[0]'
  yes = value('X',, G.!Env) = 0
  call endlocal
  return yes				/* if running under 4OS2 */

/* end Is4OS2 */

/*=== MakeTimestampedFileName() Return timestamped filename ===*/

MakeTimestampedFileName: procedure expose G.

  parse arg fileName

  if fileName = '' then
    call Fatal 'MakeTimestampedFileName requires a file name argument'

  /* Generate yyyymmdd-hhmm */
  s = date('S') || '-' || left(space(translate(time(),,':'),0), 4)

  i = lastpos('.', fileName)
  j = lastpos('\', fileName)
  /* Generate name-yyyymmdd-hhmm.ext */
  if i = 0 | i < j then
    s = fileName || '-' || s		/* No extension */
  else
    s = substr(fileName, 1, i - 1) || '-' || s || substr(fileName, i)

  return s

/* end MakeTimestampedFileName */

/*=== WarnMsg(message,...) Write multi-line warning message to STDERR ===*/

WarnMsg: procedure
  do i = 1 to arg()
    msg = arg(i)
    call 'LINEOUT' 'STDERR', msg
  end
  return

/* end WarnMsg */

/*==========================================================================*/
/*=== SkelRexx standards - Delete unused - Move modified above this mark ===*/
/*==========================================================================*/

/*=== Error() Report ERROR, FAILURE etc., trace and exit or return if called ===*/

Error:
  say
  parse source . . cmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' cmd'.'
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
  call 'LINEOUT' 'STDERR', ''
  call 'LINEOUT' 'STDERR', G.!CmdName':' msg 'at script line' SIGL
  call 'BEEP' 200, 300
  call 'SYSSLEEP' 2
  exit 254

/* end Fatal */

/*=== GetCmdName() Get script name; set G.!CmdName ===*/

GetCmdName: procedure expose G.
  parse source . . cmd
  cmd = filespec('N', cmd)		/* Chop path */
  c = lastpos('.', cmd)
  if c > 1 then
    cmd = left(cmd, c - 1)		/* Chop extension */
  G.!CmdName = translate(cmd, xrange('a', 'z'), xrange('A', 'Z'))	/* Lowercase */
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
  exit 253

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
