/* PDumpCtl - ProcDump control front-end

   Dump named process/pid or run interactive
   OK to exit to shell and update options
   fixme to configure multiple apps
   fixme to allow full command line control

   Copyright (c) 2001, 2014 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License, Version 2.  The GPL Software License can be found
   in gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   2011-02-22 SHL Baseline - clone from PDumpCtl4.cmd
   2012-01-16 SHL Update usage help
   2012-05-25 SHL Normalize dump dir slashes; sync with templates
   2012-08-12 SHL Rework command line error reporting
   2012-08-12 SHL Add proliant option
   2012-08-21 SHL Normalize directory name for pdumpctl
   2013-10-24 SHL Report force failures nicer
   2014-01-28 SHL Add normal and instance dump styles
   2014-02-02 SHL Allow new command from command line
   2014-02-07 SHL Update all to say version 0.9

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call SetLocal

call Initialize

G.!Version = '0.9'

Main:

  parse arg cmdLine
  call ScanArgs cmdLine
  drop cmdLine

  if G.!Batch & G.!Cmds == '' then
    call ScanArgsUsage 'Batch mode requires one or more commands'

  call ChkRequired
  call FindDumpDir

  /* pdumpusr option summary - see \OS2\SYSTEM\RAS\PROCDUMP.DOC
     summ       Summary for dumped threads (default)
     syssumm	Summary for all threads
     idt	Interrupt descriptor table
     laddr	Linear address range(s)
     paddr(all)	Add physical memory
     sysldr	Loader data for all processes
     sysfs	File System data for all processes (default)
     sysvm	Virtual Memory data for all processes
     systk	Task Management related data for all processes
     private	Private code and data referenced by process
     shared	Shared code and data referenced by process
     idt	Interrupt descriptor table
     instance	Instance data referenced by the process.
     mvdm	MVDM instance data for process (default)
     sysmvdm	MVDM data for all VDM and the kernel resident heap
     sem	Semaphore data for all blocked threads in process (default)
     syssem	SEM data for all blocked threads in system
     krheaps	Kernel Resident Heaps
     ksheaps	Kernel Swappable Heaps
     smp	???
     syspg	Physical and Page Memory management records (PF, VP, PTE, PDE)
     sysio	IO subsystem structures (AIRQI, DIRQ, PDD eps, PDD chain)
     trace	System trace buffers
     strace	STRACE buffer

     pdumpsys kernel defaults are
     smp, syssumm, idt, sysfs, systk, sysvm, syssem, syspg, sysio, trace, strace

     pdumpusr kernel defaults are
     summ, sysfs, mvdm, sem

  */

  if \ G.!Batch then
    call ViewSettings

  call DoCmds

  if G.!Batch then
    exit

  call AskCommands

  call ViewSettings

  exit

/* end main */

/*=== AddShared() Add shared data to dump ===*/

AddShared: procedure expose G.

  if G.!DumpStyle == 'All' then
    say 'Dump style is' G.!DumpStyle '- can not add shared'
  else do
    if pos('shared', G.!DumpStyle) = 0 then
      G.!DumpStyle = G.!DumpStyle 'shared'
    say
    say 'Setting dump style to' G.!DumpStyle
    'pdumpusr shared,update'
    'pdumpusr query'
  end
  return

/* end AddShared */

/*=== AskCommands() Ask for commands ===*/

AskCommands: procedure expose G.

  escKey = x2c('1b')
  enterKey = x2c('0d')

  do forever
    if G.!Pid \== '' then do
      say 'PID 0x' || G.!Pid '('x2d(G.!Pid)') selected'
      say
    end
    else if G.!Proc \== '' then do
      say 'Process' G.!Proc 'selected'
      say
    end
    keys = 'adfhinorsvqxADFHINORSVQX!?[Esc][Enter]'
    key = InKey(keys, 'D)ump N)orm. I)nst. F)ull S)hare X)tend. A)ll R)eset O)ff V)iew H)elp Q)uit')
    key = ToLower(key)
    if key == 'q' | key == escKey then
      leave
    else if key == enterKey then do
      say
      iterate
    end
    else if key == 'a' then
      call SetAll
    else if key == 'd' then
      call ForceDump
    else if key == 'f' then
      call SetFull
    else if key == 'i' then
      call SetInstance
    else if key == 'n' then
      call SetNormal
    else if key == 'o' then
      call SetOff
    else if key == 'r' then
      call Reset
    else if key == 's' then
      call AddShared
    else if key == 'v' then
      call ViewSettings
    else if key == 'x' then
      call SetExtended
    else if key == '!' then do
      /* Shell */
      say
      shell = value('COMSPEC',, G.!Env)
      signal off Error
      shell
      signal on Error
    end
    else if key == 'h' | key == '?' then do
      /* Help */
      say
      say 'D - Force dump using current settings'
      say 'N - Reset to Normal style - summ,mvdm,sem,sysldr,sysfs,sysvm,syssem'
      say 'I - Reset to Instance style - summ,instance,mvdm,sem,sysldr,sysfs,sysvm,syssem'
      say 'F - Select Full style - adds sysldr,sysvm,private,instance,syssem,sysio'
      say 'S - Add Shared - adds shared to current settings'
      say 'X - Select Extended - adds sysldr,syspg,private,instance,syssem,sysio,shared'
      say 'A - Select All style - adds paddr(all) - resets all other settings'
      say 'R - Reset to Default style - selects system default settings'
      say 'O - Turn off dump facility'
      say 'V - View current settings'
      say 'H - Display this screen'
      say 'Q - Quit'
      say '? - Display this screen'
      say '! - Shell'
      say
    end
    else do
      say
      say 'Unexpected key'
      'pause'
      exit 1
    end
  end
  return

/* end AskCommands */

/*=== ChkRequired() check for required executables ===*/

ChkRequired: procedure expose G.
  e = 'PATH'
  x = 'procdump.exe'
  s = SysSearchPath(e, x)
  if s == '' then
    call ScanArgsUsage 'Can not locate' x 'in' e '- please check your installation'
  x = 'pdumpusr.exe'
  s = SysSearchPath(e, x)
  if s == '' then
    call ScanArgsUsage 'Can not locate' x 'in' e '- please check your installation'
  return
  /* end ChkRequired */

/*=== DoCmds() Execute queued commands ===*/

DoCmds: procedure expose G.

  do ndx = 1 to length(G.!Cmds)
    cmd = substr(G.!Cmds, ndx, 1)
    select
    when cmd == 'a' then
      call SetAll
    when cmd == 'd' then
      call ForceDump
    when cmd == 'f' then
      call SetFull
    when cmd == 'i' then
      call SetInstance
    when cmd == 'n' then
      call SetNormal
    when cmd == 'o' then
      call SetOff
    when cmd == 'r' then
      call Reset
    when cmd == 's' then
      call AddShared
    when cmd == 'v' then
      call ViewSettings
    when cmd == 'x' then
      call SetExtended
    otherwise
      call ScanArgsUsage 'Command' cmd 'unexpected'
    end
  end
  return

/* end DoCmds */

/*=== FindDumpDir() Default dump directory and normalize path for procdump ===*/

FindDumpDir: procedure expose G.

  if G.!DumpDir == '' then do

    /* Look for ?:\Dumps directory on local drives
       Optimized for me - sorry
       fixme to check readonly?
       fixme to check hostname?
    */
    lclDrives = SysDriveMap(, 'LOCAL')
    do ndx = words(lclDrives) to 1 by -1
      drv = word(lclDrives, ndx)
      info = SysDriveInfo(drv)
      if info \== '' then do
	/* Drive is accessible */
	fstype = SysFileSystemType(drv)
	if fstype \== 'CDFS' then do
	  dir = drv || '\Dumps'
	  dir = IsDir(dir, 'FULL')
	  if dir \== '' then
	    G.!DumpDir = dir
	end
      end
    end

    if G.!DumpDir == '' then do
      dir = G.!TmpDir || '\Dumps'
      dir = IsDir(dir, 'FULL')
      if dir \== '' then
	G.!DumpDir = dir
    end

    if G.!DumpDir == '' then
      call Fatal 'Can not select dump directory - checked ?:\Dumps and %TMP\Dumps'

  end /* if */

  return

/* end FindDumpDir */

/*=== Force dump ===*/

ForceDump: procedure expose G.

  /* Force dump now */
  say
  if G.!Pid \= '' then do
    say 'Dumping PID' G.!Pid
    signal off Error
    'procdump force /pid:' || G.!Pid
    signal on Error
  end
  else if G.!Proc \= '' then do
    say 'Dumping process' G.!Proc
    signal off Error
    'procdump force /proc:' || G.!Proc
    signal on Error
  end
  else if G.!DumpStyle == 'All' then do
    say 'Dumping all memory'
    /* procdump force /system */
    signal off Error
    'procdump force /pid:all'
    signal on Error
  end
  else do
    say 'Process/pid required for G.!DumpStyle dump style'
    RC = 0
  end
  if RC \= 0 then do
    /* 2013-10-24 SHL FIXME to know why apiret changes to 20548 */
    say 'Procdump failed with error' RC
    say 'Check process/pid running'
  end
  return
  /* end ForceDump */

/*=== SetNormal ===*/

SetNormal: procedure expose G.
  /* Set to normal */
  G.!DumpStyle = 'Normal'
  say
  say 'Resetting dump style to' G.!DumpStyle
  'procdump reset /pid:all'
  'procdump on /l:' || G.!DumpDir
  'pdumpusr reset'
  if G.!Proliant then
    'pdumpusr summ,sysldr,sysfs,syssem,update'
  else
    'pdumpusr summ,sysldr,sysfs,sysvm,syssem,update'
  'procdump query'
  return
  /* end SetNormal */

/*=== SetInstance ===*/

SetInstance: procedure expose G.
  /* Set to normal */
  G.!DumpStyle = 'Instance'
  say
  say 'Resetting dump style to' G.!DumpStyle
  'procdump reset /pid:all'
  'procdump on /l:' || G.!DumpDir
  'pdumpusr reset'
  if G.!Proliant then
    'pdumpusr summ,sysldr,sysfs,syssem,instance,update'
  else
    'pdumpusr summ,sysldr,sysfs,sysvm,syssem,instance,update'
  'procdump query'
  return
  /* end SetInstance */

/*=== Reset ===*/

Reset: procedure expose G.
  /* Reset to default */
  G.!DumpStyle = 'Default'
  say
  say 'Resetting dump style to' G.!DumpStyle
  'procdump reset /pid:all'
  'procdump on /l:' || G.!DumpDir
  'pdumpusr reset'
  'procdump query'
  return
  /* end Reset */

/*=== SetAll ===*/

SetAll: procedure expose G.
  /* All physical memory */
  G.!DumpStyle = 'All'
  say
  say 'Setting dump style to' G.!DumpStyle
  'pdumpusr reset'
  'pdumpusr paddr(all)'
  'pdumpusr query'
  return
  /* end SetAll */

/*=== SetExtended ===*/

SetExtended: procedure expose G.
  /* Full */
  G.!DumpStyle = 'Full Shared'
  say
  say 'Setting dump style to' G.!DumpStyle
  /* pdumpusr reset */
  if G.!Proliant then
    'pdumpusr summ,sysldr,sysfs,syspg,private,instance,syssem,sysio,shared,update'
  else
    'pdumpusr summ,sysldr,sysfs,syspg,sysvm,private,instance,syssem,sysio,shared,update'
  'pdumpusr query'
  return
  /* end SetExtended */

/*=== SetFull ===*/

SetFull: procedure expose G.
  /* Full */
  G.!DumpStyle = 'Full'
  say
  say 'Setting dump style to' G.!DumpStyle
  /* pdumpusr reset */
  if G.!Proliant then
    'pdumpusr summ,sysldr,sysfs,private,instance,syssem,sysio,update'
  else
    'pdumpusr summ,sysldr,sysfs,sysvm,private,instance,syssem,sysio,update'
  'pdumpusr query'
  return
  /* end SetFull */

/*=== SetOff ===*/

SetOff: procedure expose G.
  /* Off */
  G.!DumpStyle = 'Off'
  say
  say 'Turning off Dump Facility'
  'procdump off'
  say
  return
  /* end SetOff */

/*=== ViewSettings ===*/

ViewSettings: procedure expose G.
  say
  say 'Dump directory is' G.!DumpDir
  say 'Dump style is' G.!DumpStyle
  if G.!Pid \== '' then
    say 'PID' G.!Pid 'will be dumped'
  else if G.!Proc \== '' then
    say 'Process' G.!Proc 'will be dumped'
  else
    say 'Process/PID is unknown'
  'procdump query'
  return
  /* end ViewSettings */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose G.
  call GetCmdName
  call LoadRexxUtil
  G.!Env = 'OS2ENVIRONMENT'
  call GetTmpDir
  return

/* end Initialize */

/*=== ScanArgsInit() ScanArgs initialization exit routine ===*/

ScanArgsInit: procedure expose G. cmdTail swCtl keepQuoted

  if cmdTail == '' then
    call ScanArgsHelp

  /* Preset defaults */
  G.!Batch = 1				/* Run in batch mode */
  G.!Proliant = 0			/* Run in batch mode */
  G.!DumpDir = ''			/* Dump directory */
  G.!Cmds = ''				/* Queued commands */
  G.!DumpStyle = 'Unknown'
  G.!Proc = ''				/* Process name */
  G.!Pid = ''				/* Hex pid */

  /* Configure scanner */
  swCtl = ''				/* Switches that take args, append ? if arg optional */
  keepQuoted = 0			/* Set to 1 to keep arguments quoted */

  return

/* end ScanArgsInit */

/*=== ScanArgsSwitch() ScanArgs switch option exit routine ===*/

ScanArgsSwitch: procedure expose G. curSw curSwArg

  select
  when curSw == 'i' then
    G.!Batch = 0
  when curSw == 'h' | curSw == '?' then
    call ScanArgsHelp
  when curSw == 'p' then
    G.!Proliant = 1
  when curSw == 'V' then do
    say G.!CmdName G.!Version
    exit
  end
  otherwise
    call ScanArgsUsage 'switch '''curSw''' unexpected'
  end /* select */

  return

/* end ScanArgsSwitch */

/*=== ScanArgsArg() ScanArgs argument option exit routine ===*/

ScanArgsArg: procedure expose G. curArg

  dir = ''
  pid = ''
  proc = ''

  do 1
    s = ToLower(curArg)
    if length(s) == 1 & s >= 'a' & s <= 'z' then do
      /* Got command */
      if pos(s, 'adfinorsvx') > 0 then do
	G.!Cmds = G.!Cmds || s
	leave
      end
    end

    /* Strip quotes from quoted argement */
    quoted = left(curArg, 1) == '"'

    if quoted then
      s = strip(curArg, '"', 'B')
    else
      s = curArg

    /* Check if looks like directory name */
    isPath = pos('\', s) > 0 | pos('/', s) > 0 | pos(':', s) > 0

    /* Got proc/pid/dir - detect/convert decimal to hex */
    if \ quoted & left(s, 2) == '0x' then do
      s = substr(curArg, 3)
      if datatype(s, 'X') then do
	pid = s
	if G.!Pid == '' then do
	  G.!Pid = s
	  leave
	end
      end
      else
	call ScanArgsUsage curArg 'is not a valid hex PID'
    end

    if \ quoted & left(s, 2) == '0n' then do
      s = substr(curArg,3)
      if datatype(s, 'W') then do
	pid = d2x(s)
	if G.!Pid == '' then do
	  G.!Pid = d2x(s)
	  leave
	end
      end
      else
	call ScanArgsUsage curArg 'is not a valid decimal PID'
    end

    s2 = IsDir(s, 'FULL')
    if s2 \== '' then do
      dir = curArg
      if G.!DumpDir == '' then do
	G.!DumpDir = s2
	leave
      end
    end

    if \ quoted & datatype(s, 'X') then do
      pid = s
      if G.!Pid == '' then do
	G.!Pid = s
	leave
      end
    end

    if \quoted & datatype(s, 'N') then do
      pid = s
      if G.!Pid == '' then do
	G.!Pid = d2x(s)
	leave
      end
    end

    if datatype(s, 'A') then do
      proc = s
      if G.!Proc == '' then do
	G.!Proc = curArg
	leave
      end
    end

    /* Guess what's wrong */
    if isPath then do
      if \ IsDir(s) then
	call ScanArgsUsage curArg 'directory not found'
      else G.DumpDir \== '' then
	call ScanArgsUsage 'Already using dump directory' G.!DumpDir
    end

    if pid \== '' then do
      if G.!Pid \== '' then
	call ScanArgsUsage 'PID' curArg 'unexpected - already have PID' G.!Pid
      else
	call ScanArgsUsage 'PID' curArg 'unexpected - already have process name' G.!Proc
    end

    if proc \== '' then do
      if G.!Proc \== '' then
	call ScanArgsUsage 'Process name' curArg 'unexpected - already have process name' G.!Proc
      else
	call ScanArgsUsage 'Process name' curArg 'unexpected - already have PID' G.!Pid
    end

    call ScanArgsUsage curArg 'unexpected'

  end /* do */

  return

/* end ScanArgsArg */

/*=== ScanArgsTerm() ScanArgs scan end exit routine ===*/

ScanArgsTerm: procedure expose G.
  return

/* end ScanArgsTerm */

/*=== ScanArgsHelp() Display ScanArgs usage help exit routine ===*/

ScanArgsHelp:
  say
  say G.!CmdName G.!Version
  say 'Control Process Dump Facility in batch or interactive mode.'
  say
  say 'Usage:' G.!CmdName '[-h] [-i] [-p] [-V] [-?] [commands...] [procname|pid] [dirname]'
  say
  say ' -h -?     Display this message'
  say ' -i        Run interactive (default is batch mode)'
  say ' -p        Enable Proliant mode, disables sysvm to prevent system traps'
  say ' -V        Display version number and quit'
  say
  say ' pid       Select PID to dump, default radix is hex'
  say '           Prefix with 0x or 0n if amibiguous'
  say ' procname  Select process to dump'
  say '           Quote if name looks like a number'
  say ' dirname   Set Dump directory, quote if name looks like a number'
  say '           Defaults to ?:\Dumps or %TMP\Dumps'
  say ' commands  Batch mode commands'
  say '   a       Select All style - dumps all physical memory'
  say '   d       Force dump, requires PID or process name'
  say '   f       Select Full style - Normal style plus private code and data'
  say '   i       Reset to Instance style - Normal style plus Instance data'
  say '   n       Reset to Normal style - Default style plus useful system details'
  say '   o       Turn off dump facilty'
  say '   r       Reset to Default style - applies system default settings'
  say '   s       Select Shared style - adds shared code and data to current settings'
  say '   v       View dump settings'
  say '   x       Select Extended style - Full style plus shared code and data'

  exit 255

/* end ScanArgsHelp */

/*=== ScanArgsUsage(message) Report Scanargs usage error exit routine ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \== '' then
    say msg
  say 'Usage:' G.!CmdName '[-h] [-i] [-p] [-V] [-?] [commands...] [procname|pid] [dirname]'
  exit 255

/* end ScanArgsUsage */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

/*=== ChopDirSlash(directory) Chop trailing \ from directory name unless root ===*/

ChopDirSlash: procedure
  parse arg dir
  if right(dir, 1) == '\' & right(dir, 2) \== ':\' & dir \== '\' then
    dir = substr(dir, 1, length(dir) - 1)
  return dir

/* end ChopDirSlash */

/*=== InKey(Keys, Prompt) returns key code ===*/

InKey: procedure
  parse arg keys, msg
  /* Convert key names to characters */
  i = pos('[Enter]', keys)
  if i > 0 then
    keys = substr(keys, 1, i - 1) || x2c('0d') || substr(keys, i + 7)
  i = pos('[Esc]', keys)
  if i > 0 then
    keys = substr(keys, 1, i - 1) || x2c('1b') || substr(keys, i + 5)
  call charout 'STDERR', msg '? '
  do forever
    key = SysGetKey('NOECHO')
    i = pos(key, keys)
    if i > 0 then do
      i = pos(key, xrange('20'x, '7e'x))
      if i > 0 then
	call 'LINEOUT' 'STDERR', key
      leave
    end
  end /* forever */
  return key

/* end InKey */

/*=== IsDir(dirName[, full]) return true if directory is valid, accessible directory ===*/

IsDir: procedure
  /* If arg(2) not omitted, return full directory name or empty string */
  parse arg dir, full
  fulldir = ''
  do 1
    if dir == '' then
      leave
    dir = translate(dir, '\', '/')	/* Allow unix slashes */
    s = strip(dir, 'T', '\')		/* Chop trailing slashes unless root */
    if s \== '' & right(s, 1) \== ":" then
      dir = s				/* Chop */
    drv = filespec('D', dir)
    cwd = directory()			/* Remember */
    if drv \== '' & translate(drv) == translate(left(cwd, 2)) then do
      /* Requested directory not on current drive - avoid slow failures and unwanted directory changes */
      drvs = SysDriveMap('A:')
      if pos(translate(drv), drvs) = 0 then
	leave				/* Unknown drive */
      if SysDriveInfo(drv) == '' then
	leave				/* Drive not ready */
      cwd2 = directory(drv)		/* Remember current directory on other drive */
      newdir = directory(dir)		/* Try to change and get full pathname */
      call directory cwd2		/* Restore current directory on other drive */
    end
    else do
      /* No drive letter or same drive */
      newdir = directory(dir)		/* Try to change and get full pathname */
    end
    call directory cwd			/* Restore original directory and drive */
    fulldir = newdir
  end /* 1 */
  if full \== '' then
    ret = fulldir			/* Return full directory name or empty string */
  else
    ret = fulldir \== ''		/* Return true if valid and accessible */
  return ret

/* end IsDir */

/*=== ToLower(s) Convert to lower case ===*/

ToLower: procedure
  parse arg s
  return translate(s, xrange('a', 'z'), xrange('A', 'Z'))

/* end ToLower */

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

/*=== GetTmpDir() Get TMP dir name with trailing backslash, set G. ===*/

GetTmpDir: procedure expose G.
  tmpDir = value('TMP',,G.!Env)
  if tmpDir \= '' & right(tmpDir, 1) \= ':' & right(tmpDir, 1) \== '\' then
    tmpDir = tmpDir'\'			/* Stuff backslash */
  G.!TmpDir = tmpDir
  return

/* end GetTmpDir */

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

/*=== ScanArgs(cmdLine) Scan command line ===*/

ScanArgs: procedure expose G.

  /* Calls user exits to process arguments and switches */

  parse arg cmdTail
  cmdTail = strip(cmdTail)

  call ScanArgsInit

  /* Scan */
  curArg = ''				/* Current arg string */
  curSwList = ''			/* Current switch list */
  /* curSwArg = '' */			/* Current switch argument, if needed */
  noMoreSw = 0				/* End of switches */

  do while cmdTail \== '' | curArg \== '' | curSwList \== ''

    if curArg == '' then do
      /* Buffer empty, refill */
      qChar = left(cmdTail, 1)		/* Remember quote */
      if \ verify(qChar,'''"', 'M') then do
	parse var cmdTail curArg cmdTail	/* Not quoted */
      end
      else do
	/* Arg is quoted */
	curArg = ''
	do forever
	  /* Parse dropping quotes */
	  parse var cmdTail (qChar)quotedPart(qChar) cmdTail
	  curArg = curArg || quotedPart
	  /* Check for escaped quote within quoted string (i.e. "" or '') */
	  if left(cmdTail, 1) \== qChar then
	    leave			/* No, done */
	  curArg = curArg || qChar	/* Append quote */
	  if keepQuoted then
	    curArg = curArg || qChar	/* Append escaped quote */
	  parse var cmdTail (qChar) cmdTail
	end /* do */
	if keepQuoted then
	  curArg = qChar || curArg || qChar	/* requote */
      end /* if quoted */
    end

    /* If switch buffer empty, refill */
    if curSwList == '' then do
      if left(curArg, 1) == '-' & curArg \== '-' then do
	if noMoreSw then
	  call ScanArgsUsage 'switch '''curArg''' unexpected'
	else if curArg == '--' then
	  noMoreSw = 1
	else do
	  curSwList = substr(curArg, 2)	/* Remember switch string */
	  curArg = ''			/* Mark empty */
	  iterate			/* Refill arg buffer */
	end
	parse var cmdTail curArg cmdTail
      end
    end

    /* If switch in progress */
    if curSwList \== '' then do
      curSw = left(curSwList, 1)	/* Next switch */
      curSwList = substr(curSwList, 2)	/* Drop from pending */
      /* Check switch allows argument, avoid matching ? */
      if pos(curSw, translate(swCtl,,'?')) \= 0 then do
	if curSwList \== '' then do
	  curSwArg = curSwList		/* Use rest of switch string for switch argument */
	  curSwList = ''
	end
	else if curArg \== '' & left(curArg, 1) \== '-' then do
	  curSwArg = curArg		/* Arg string is switch argument */
	  curArg = ''			/* Mark arg string empty */
	end
	else if pos(curSw'?', swCtl) = 0 then
	  call ScanArgsUsage 'Switch' curSw 'requires argument'
	else
	  curSwArg = ''			/* Optional arg omitted */
      end

      call ScanArgsSwitch		/* Passing curSw and curSwArg */
      drop curSwArg			/* Must be used by now */
    end /* if switch */

    /* If arg */
    else if curArg \== '' then do
      noMoreSw = 1
      call ScanArgsArg			/* Passing curArg */
      curArg = ''
    end

  end /* while not done */

  call ScanArgsTerm

  return

/* end ScanArgs */

/* The end */
