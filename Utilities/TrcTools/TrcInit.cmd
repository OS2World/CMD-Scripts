/* TrcInit - Initialize OS/2 Trace for EDITME
   EDITME strings mark typical items that need to be configured

   Copyright (c) 2001, 2011 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   2001-01-11 SHL Baseline
   2004-07-26 SHL Resync
   2004-11-17 SHL Correct .cfg default logic
   2004-12-09 SHL Allow multiple EXEs and PIDs
   2005-04-06 SHL Ensure enable for all if not specific PID or EXE
   2011-03-01 SHL Sync with standards

   Config file options
     CMD = tracecmd		trace setup commands
     DIEONERROR = yes/no	die on errors
     EXE = exe			exe to trace
     FINDPID = yes/no		find PID for exe
     PID = pid			pid to trace (overrides exe)

   Notes: tracepoints are set in decimal and displayed in hex
	  pids are set in hex and displayed in hex
	  krnlrfs tracepoints 281 and 283 will trap on 14.93c to 14.100c

*/

/* signal on Error */
/* signal on FAILURE name Error */
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

G.!Version = '0.7'

Main:

  say
  say G.!CmdName 'starting.'

  '@setlocal'

  parse arg cmdLine
  if cmdLine = '-h' | cmdLine = '-?' then
    call ScanArgsHelp
  if left(cmdLine, 1) = '-' then
    call ScanArgsUsage

  call ReadCfg cmdLine

  drop cmdLine

  /* Build comma sep EXE list, find PIDs if requested */
  exe = ''
  fail = 0
  do iExe = 1 to Trc.!EXE.0
    if iExe > 1 then
      exe = exe','
    exe = exe || Trc.!EXE.iExe
    if Trc.!FindPID then do
      pid = EXE2PID(Trc.!EXE.iExe)
      if pid == '' then do
	call Warn2 'Warning:' Trc.!EXE.iExe 'not running'
	fail = 1
      end
      else do
	iPid = Trc.!PID.0 + 1
	Trc.!PID.iPid = pid
	Trc.!PID.0 = iPid
      end
    end
  end

  if fail then
    call Fatal 'Please check configuration file'	/* Time to die */

  /* Pass EXE names to others as comma sep list */
  call value 'TRCEXEPATH', exe, G.!Env

  /* Build PID list */
  pid = ''
  do iPid = 1 to Trc.!PID.0
    if pid \== '' then
      pid = pid','
    pid = pid || Trc.!pid.iPID
  end

  /* Find boot drive */
  BootDrv = SysBootDrive()

  /* Find trcctl.cmd in case in current dir and not in PATH */
  sTrcCtlCmd = SysSearchPath('PATH', 'trcctl.cmd')

  if sTrcCtlCmd == '' then
    call Fatal 'trcctl.cmd not found'

  /* Must run from here to avoid trap setting kernel tracepoints - fixme still true? */
  oldDir = directory()
  call Directory BootDrv'\os2\system\trace'

  /* Ensure trace initialized */
  '@trace /q >nul'
  if RC = 1055 then do
    say 'Initializing trace with 512KB buffer'
    'trace on /b:512'
    '@trace /q >nul'
  end
  if RC \= 0 then
    call Fatal 'Can not initialize trace, rc =' RC

  'trace off'
  'trace /c /s'

  /* EDITME = set tracepoint options here
	      for tracepoint listings see TraceCode.ref or
	      Warp4 traceref.inf
  */

  do i = 1 to Trc.!Cmd.0
    say Trc.!Cmd.i
    Trc.!Cmd.i
    if RC \= 0 then do
      call Warn2 'Warning: can not set tracepoints, rc =' RC
      /* EDITME - set to 0 to bypass failure exit */
      if Trc.!DieOnError then exit
    end
  end

  call Directory oldDir

  /* Trace specific process, if requested */
  if pid \= '' then
    'trace on /p:'pid
  else if exe \= '' then
    'trace on /n:'exe
  else
    'trace on /p:all'			/* Just in case */

  interpret 'call '''sTrcCtlCmd''''

  exit

/* end main */

/*=== EXE2PID(exeName) Get PID for EXE, return hex PID or empty string ===*/

EXE2PID: procedure

  parse upper arg exeNameIn

  hexPIDOut = ''

  matchCnt = length(exeNameIn)

  '@pstat /c | rxqueue'

  /* Match on first if multiple hits */

  do while queued() \= 0

    pull s

    if hexPIDOut \= '' then iterate	/* skip rest */

    /*
	      Parent
    Process   Process   Session   Process   Thread
      ID        ID        ID       Name       ID    Priority   Block ID   State
     00C9      0000       11      F:\IBMLAN\SERVICES\PEER.EXE    01      0300     FFFE0ACB   Block
   */

    if verify(substr(s, 2, 1), '0123456789ABCDEF', 'M') = 1
    then do
      /* Got process line */
      parse var s hexPID . . pathName .
      if pos('\', exeNameIn) = 0 then
	i = lastpos('\', pathName)	/* Match just exe name */
      else
	i = 0				/* Match full pathname */
      if substr(pathName, i + 1, matchCnt) == exeNameIn then
	hexPIDOut = hexPID
    end

  end /* while queued */

  return hexPIDOut

/* end EXE2PID */

/*=== PID2EXE(hexPID) Get EXE for PID, return pathname or empty string ===*/

PID2EXE: procedure

  parse arg hexPIDIn

  hexPIDIn = right('0000' || translate(hexPIDIn), 4)

  '@pstat /c | rxqueue'

  /* Match on first if multiple hits */
  exe = ''

  do while queued() \= 0

    pull s

    if exe \= '' then iterate		/* skip rest */

    /*
	      Parent
    Process   Process   Session   Process   Thread
      ID        ID        ID       Name       ID    Priority   Block ID   State
     00C9      0000       11      F:\IBMLAN\SERVICES\PEER.EXE    01      0300     FFFE0ACB   Block
   */

    if verify(substr(s, 2, 1), '0123456789ABCDEF', 'M') = 1
    then do
      /* Got process line */
      parse var s hexPID . . sPathName .
      if hexPIDIn = hexPID then
	exe = sPathName
    end

  end /* while queued */

  return exe

/* end PID2EXE */

/*=== ReadCfg(cfgFile) Read settings from trcinit.cfg ===*/

ReadCfg: procedure expose G. Trc.

  parse arg cfgFile

  if cfgFile = '' then
    cfgFile = G.!CmdName'.cfg'		/* Default */

  /* Preset */
  Trc.!Cmd.0 = 0
  Trc.!DieOnError = 1
  Trc.!EXE.0 = 0
  Trc.!FindPID = 0
  Trc.!PID.0 = 0

  /* Scan and parse */

  say 'Reading' cfgFile

  s = stream(cfgFile, 'C', 'QUERY EXISTS')

  if s == '' then do
    i = lastpos('.', cfgFile)
    j = lastpos('\', cfgFile)
    if i <= j then do
      s = stream(cfgFile'.cfg', 'C', 'QUERY EXISTS')
      if s \== '' then
	cfgFile = s
    end
    if s == '' then
      call ScanArgsUsage cfgFile 'does not exist.'
  end

  fail = 0
  warnmsg = ''
  failmsg = ''

  call stream cfgFile, 'C', 'OPEN READ'

  do while lines(cfgFile) \= 0

    line = linein(cfgFile)
    line = strip(line)

    if line = '' then iterate
    if left(line, 1) = ';' then iterate	/* Comment line */

    parse var line req '=' opt
    req = strip(req)
    opt = strip(opt)

    uopt = translate(opt)
    select
    when abbrev('YES', uopt) \= 0 then yesno = 1
    when uopt = 1 then yesno = 1
      when abbrev('NO', uopt) \= 0 then yesno = 0
    when uopt = 0 then yesno = 0
    otherwise yesno = ''
    end

    ureq = translate(req)
    select
    when abbrev('CMD', ureq) \= 0 then do
      if opt = '' then
	failmsg = 'Expected command line for' req
      else do
	i = Trc.!Cmd.0 + 1
	Trc.!Cmd.i = opt
	Trc.!Cmd.0 = i
      end
    end
    when abbrev('DIEONERROR', ureq) \= 0 then do
      if yesno = '' then
	failmsg 'Expected yes/no value for' req
      else
	Trc.!DieOnError = yesno
    end
    when abbrev('EXE', ureq) \= 0 then do
      if opt = '' then
	failmsg = 'Expected exe name for' req
      else do
	i = lastpos('.', opt)
	j = lastpos('\', opt)
	if i <= j then
	  opt = opt'.exe'
	exe = stream(opt, 'C', 'QUERY EXISTS')
	if exe == '' then
	  exe = SysSearchPath('PATH', opt)
	if exe == '' then do
	  warnmsg = opt 'not found by name or by PATH'
	  exe = opt
	end
	/* Always add to list */
	i = Trc.!EXE.0 + 1
	Trc.!EXE.i = exe
	Trc.!EXE.0 = i
      end
    end
    when abbrev('FINDPID', ureq) \= 0 then do
      if yesno = '' then
	failmsg = 'Expected yes/no value for' req
      else
	Trc.!FindPID = yesno
    end
    when abbrev('PID', ureq) \= 0 then do
      if datatype(opt, 'X') = 0 then
	failmsg = 'Expected hexadecimal PID number for' req
      else do
	exeNameOut = PID2EXE(opt)
	if exeNameOut = '' then
	  failmsg = 'PID' opt 'not running'
	else do
	  say 'PID' opt 'is' exeNameOut
	  i = Trc.!EXE.0 + 1
	  Trc.!EXE.i = exeNameOut
	  Trc.!PID.i = opt
	  Trc.!EXE.0 = i
	end
      end
    end
    otherwise
      failmsg = line 'unexpected - expected CMD DIEONERROR EXE FINDPID PID'
    end

    if failmsg \= '' then do
      call Warn1 failmsg
      failmsg = ''
      fail = 1
    end

    if warnmsg \= '' then do
      call Warn1 warnmsg
      warnmsg = ''
      if Trc.!DieOnError then
	fail = 1
    end

  end /* while lines */

  call stream cfgFile, 'C', 'CLOSE'

  if Trc.!PID.0 > 0 & Trc.!EXE.0 > 0 & \ Trc.!FindPID then do
    call Warn1 'PID not allowed with EXE'
    fail = 1
  end

  if fail then
    call Fatal 'Please check configuration file'	/* Time to die */

  return

/* end ReadCfg */

/*=== Initialize: Intialize globals ===*/

Initialize: procedure expose G.

  call LoadRexxUtil
  call GetCmdName
  G.!Env = 'OS2ENVIRONMENT'
  return

/* end Initialize */

/*=== ScanArgsHelp() Display usage help ===*/

ScanArgsHelp:

  say
  say 'Usage:' G.!CmdName '[cfgFile]'
  say
  say ' cfgFile  configuration file, defaults to' G.!CmdName'.cfg'

  exit 255

/* end ScanArgsHelp */

/*=== ScanArgsUsage(message) Report usage error ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \= '' then
    say msg
  say 'Usage:' G.!CmdName '[cfgFile]'
  exit 255

/* end ScanArgsUsage */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

/*=== Warn1(message) Beep and write message to STDERR ===*/

Warn1: procedure
  parse arg msg
  call lineout 'STDERR', msg
  call Beep 400, 300
  return

/* end Warn1 */

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
