/* TraceCtl - Generic trace control loop

   Copyright (c) 2001, 2011 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   2001-11-26 SHL Baseline
   2001-12-05 SHL Consistent naming
   2002-03-20 SHL Convert to REXX
   2003-02-24 SHL Add start formatter option
   2004-06-26 SHL Sync with standards
   2004-08-03 SHL Bypass shell errors
   2004-12-06 SHL Support multiple EXEs
   2011-03-01 SHL Sync with standards
*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

G.!Version = '0.2'

Main:

  say
  say G.!CmdName 'starting.'

  TRCEXEPATH = value('TRCEXEPATH',,G.!Env)

  /* Find boot drive */
  BootDrv = SysBootDrive()

  /* Must run from trace directory to avoid trap setting kernel tracepoints - fixme to know if still true? */
  oldDir = directory()
  call Directory BootDrv'\os2\system\trace'

  /* Check trace initialized */
  signal off ERROR
  '@trace /q >nul'
  signal on ERROR
  if RC = 1055 then do
    say 'Trace not initialized'
    exit RC
  end

  /* Clear trace buffer */
  'trace /s /c'
  'trace /q'
  say

  req = ''
  opt = '/s'
  newOpt = '/r'
  pid = GetPID('tracefmt.exe')
  fStartTraceFmt = pid == ''

  do while req \= 'Q'

    if TRCEXEPATH \== '' then do
      /* List is comma separated */
      s = translate(TRCEXEPATH, ' ', ',')
      do i = 1 to words(s)
	exe = word(s, i)
	pid = GetPID(exe)
	if pid == '' then
	  call Warn2 'Warning:' exe 'not running'
      end
    end

    if opt \= newOpt then do

      opt = newOpt
      'trace' opt

      if opt = '/r' then
	say 'Tracing resumed.'
      else do
	say 'Tracing suspended.'
	pid = GetPID('tracefmt.exe')
	fStartTraceFmt = pid == ''
      end
    end /* if newOpt */

    if fStartTraceFmt then do
      fStartTraceFmt = 0
      pid = GetPID('tracefmt.exe')
      if pid \= '' then
	say 'Tracefmt already running'
      else do
	say 'Starting tracefmt'
	'start tracefmt'
	call SysSleep 2
	pid = GetPID('tracefmt.exe')
	if pid == '' then
	  call Warn2 'Warning: can not start tracefmt'
      end
    end

    say
    call charout ,'S)uspend R)esume O)ptions F)ormat Q)uit H)elp ? '
    req = translate(SysGetKey('NOECHO'))
    say
    select
    when req == 'H' then do
      say
      say ' S      suspend tracing'
      say ' R      resume tracing'
      say ' Enter  toggle trace options'
      say ' O      show trace options'
      say ' Q      turn off tracing and quit'
      say ' F      start trace formatter'
      say ' H      this message'
      say ' !      invoke shell'
    end
    when req == 'F' then
      fStartTraceFmt = 1
    when req == 'O' then do
      say
      'trace /q'
    end
    when req == 'R' then
      newOpt = '/r'
    when req == 'S' then
      newOpt = '/s'
    when req == x2c('0d') then do
      /* Enter Key - toggle state */
      newOpt = translate(opt, 'sr', 'rs')
    end
    when req == 'Q' then
      nop
    when req == '!' then do
      sShell = value('OS2_SHELL',,G.!Env)
      say
      say 'Type exit to return'
      signal off Error
      '@'sShell
      signal on Error
    end
    otherwise
      nop				/* Ignore others */
    end /* select */

  end /* forever */

  /* Clean up */
  say
  'trace /c /s'
  'trace off'
  'trace off /p:all'
  say
  'trace /q'

  call directory oldDir

  exit

/* end main */

/*=== GetPID(exeName) Get PID for EXE ===*/

GetPID: procedure

  parse upper arg reqExe

  pidOut = ''

  '@pstat /c | rxqueue'

  matchLen = length(reqExe)

  /* Matches on first if multiple hits */

  do while queued() \= 0

    pull s
    /*
	      Parent
    Process   Process   Session   Process   Thread
      ID        ID        ID       Name       ID    Priority   Block ID   State
     00C9      0000       11      F:\IBMLAN\SERVICES\PEER.EXE    01      0300     FFFE0ACB   Block
   */
    if pidOut == '' & verify(substr(s, 2, 1), '0123456789ABCDEF', 'M') = 1
    then do
      /* Got process line */
      parse var s pid . . pstatExe .
      if pos('\', reqExe) = 0 then
	i = lastpos('\', pstatExe)	/* Match just exe name */
      else
	i = 0				/* Match full pathname */
      if substr(pstatExe, i + 1, matchLen) == reqExe then
	pidOut = pid
    end /* if */

  end /* while queued */

  if 0 then say 'GetPID('reqExe') returns' pidOut

  return pidOut

/* end GetPID */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose G.

  call GetCmdName
  call LoadRexxUtil
  G.!Env = 'OS2ENVIRONMENT'
  return

/* end Initialize */

/*=== ScanArgsUsage(message) Report ScanArgsUsage Error... ===*/

ScanArgsUsage:
  parse arg msg
  say msg
  say 'Usage:' G.!CmdName
  exit 255

/* end ScanArgsUsage */

/*=== ScanArgsHelp() Display help ===*/

ScanArgsHelp:

  say
  say 'Usage:' G.!CmdName '[-h]'
  say
  say ' -h  This message'

  exit 255

/* end ScanArgsHelp */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

/*=== Warn2(message) Warble and write message to STDERR ===*/

Warn2: procedure
  parse arg msg
  call 'LINEOUT' 'STDERR', msg
  do 10;
    f=random(262,1047)
    d=random(100,200)
    call beep f,d
  end
  return

/* end Warn2 */

/*==========================================================================*/
/*=== SkelRexx standards - Delete unused - Move modified above this mark ===*/
/*==========================================================================*/

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
