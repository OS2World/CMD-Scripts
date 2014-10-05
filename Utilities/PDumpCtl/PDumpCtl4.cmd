@echo off
:: PDumpCtl - ProcDump control front-end

:: Dump named process/pid or run interactive
:: OK to exit to shell and update options
:: fixme to configure multiple apps
:: fixme to allow full command line control

:: Copyright (c) 2001, 2011 Steven Levine and Associates, Inc.
:: All rights reserved.

:: 2001-06-27 SHL Baseline
:: 2008-08-16 SHL Tweak dump directory search
:: 2009-02-05 SHL Check 4OS2; sync with standards
:: 2009-11-08 SHL Report selected dump directory
:: 2009-11-10 SHL Rework command line to match interactive
:: 2009-12-03 SHL Use if defined
:: 2010-01-24 SHL Correct == typo
:: 2010-12-23 SHL Correct pid detect
:: 2011-01-08 SHL Comments

if "%@eval[0]" == "0" goto is4xxx
  echo Must run in 4OS2/4DOS session
  pause
  goto eof
:is4xxx

loadbtm on
on errormsg pause
on break @goto Halted
setlocal

if "%_DOS%" != "OS2" ( echo Must run in 4OS2 session %+ beep %+ cancel )

:: Scan args, I=num A=value X=scratch

set DUMPDIR=	%+ :: Dump directory
set CMDS=	%+ :: Command list
set BATCH=1	%+ :: Batch mode 0/1
set TYPE=	%+ :: Dump type, A)ll F)ull S)hared
set PROC=	%+ :: Process name
set PID=	%+ :: Process id

:: PROC and PID mutually exclusive

do I = 1 to %[#]
  set A=%[%I]
  set X=%@substr[%A,0,1]
  iff "%X" eq "/" .or. "%X" eq "-" then
    :: Got switch
    set X=%@lower[%@substr[%A,1,1]]
    iff "%X" == "h" .or. "%X" == "?" then
      goto Help
    elseiff "%X" == "i" then
      set BATCH=0
    else
      echo Switch %X unexpected
      goto Usage
    endiff
  else
    :: Got arg
    iff %@len[%A] == 1 .and. "%A" ge "A" .and. "%A" le "Z" then
      :: Got command
      iff %@index[adforsvx,%A] != -1 then
	set CMDS=%[CMDS]%A
      else
	echo Command %A unexpected
	goto usage
      endiff
    elseiff '%@left[1,%A]' == '%="' then
      :: Strip quotes from quoted process or dump directory name
      set X=%@strip[%=",%A]
      iff isdir %X then
	set DUMPDIR=%X
      else
	set PROC=%X
      endiff
    :: Got proc/pid/dir - detect/convert decimal to hex
    elseiff "%@left[2,%A]" == "0x" then
      set PID=%@substr[%PID,2,100]
      set X=%@convert[16,16,%PID]
      if "%PID" != "%X" ( echo %A is not a valid PID %+ goto usage )
    elseiff "%@left[2,%A]" eq "0n" then
      set PID=%@substr[%A,2,100]
      set X=%@convert[10,10,%PID]
      if "%PID" != "%X" ( echo %A is not a valid PID %+ goto usage )
      set PID=%@convert[10,16,%PID]
    else
      :: Try for hex PID or directory or process name
      set X=%@convert[16,16,%A]
      iff "%A" == "%X" then
	set PID=%A
      elseiff isdir %A then
	set DUMPDIR=%A
      else
	:: Assume process name
	set PROC=%A
      endiff
    endiff
  endiff
enddo

set CMDS=%@trim[%CMDS]
if %BATCH == 1 if not defined CMDS ( echo Batch mode requires commands %+ cancel )

:: Set defaults

:: Look for ?:\Dumps directory on drive d:..k:
:: Optimized for me - sorry
:: fixme to check readonly?
:: fixme to check hostname
set X=d
do while not defined DUMPDIR
  iff %@ready[%X] == 1 then
    iff %@remote[%X] == 0 .and. %@cdrom[%X] == 0 then
      if isdir %X:\Dumps set DUMPDIR=%X:\Dumps
    endiff
  endiff
  if %X == k leave
  if %X == z set X=b
  set X=%@char[%@eval[%@ascii[%X]+1]]
enddo

if not defined DUMPDIR if isdir %TMP\Dumps set DUMPDIR=%TMP\Dumps

iff not defined DUMPDIR then
  echo Can not find dump directory - checked ?:\Dumps and %TMP\Dumps
  goto usage
endiff

echo.
echo Dump files will be written to %DUMPDIR

if %BATCH == 0 gosub Reset

:: pdumpusr option summary - see \OS2\SYSTEM\RAS\PROCDUMP.DOC
:: summ		Summary for dumped threads (default)
:: syssumm	Summary for all threads
:: idt		Interrupt descriptor table
:: laddr	Linear address range(s)
:: paddr(all)	Add physical memory
:: sysldr	Loader data for all processes
:: sysfs	File System data for all processes (default)
:: sysvm	Virtual Memory data for all processes
:: systk	Task Management related data for all processes
:: private	Private code and data referenced by process
:: shared	Shared code and data referenced by process
:: idt		Interrupt descriptor table
:: instance	Instance data referenced by the process.
:: mvdm		MVDM instance data for process (default)
:: sysmvdm	MVDM data for all VDM and the kernel resident heap
:: sem		Semaphore data for all blocked threads in process (default)
:: syssem	SEM data for all blocked threads in system
:: krheaps	Kernel Resident Heaps
:: ksheaps	Kernel Swappable Heaps
:: smp		???
:: syspg	Physical and Page Memory management records (PF, VP, PTE, PDE)
:: sysio	IO subsystem structures (AIRQI, DIRQ, PDD eps, PDD chain)
:: trace	System trace buffers
:: strace	STRACE buffer

:: pdumpsys defaults are
::    smp, syssumm, idt, sysfs, systk, sysvm, syssem, syspg, sysio, trace, strace

:: pdumpusr defaults are
::    summ, sysfs, mvdm, sem

:: Run requested batch commands

do while defined CMDS
  set X=%@substr[%CMDS, 0, 1]
  iff %X == a then
    gosub SetAll
  elseiff %X == f then
    gosub SetFull
  elseiff %X == d then
    gosub ForceDump
  elseiff %X == o then
    gosub SetOff
  elseiff %X == r then
    gosub Reset
  elseiff %X == s then
    gosub AddShared
  elseiff %X == v then
    gosub ViewSettings
  elseiff %X == x then
    gosub SetExtended
  else
    say Command %X unexpected
    goto usage
  endiff
  set CMDS=%@substr[%CMDS,1,260]
enddo

if %BATCH == 1 quit

:: Interactive

do forever
  iff defined PID then
    echo PID 0x%PID (0n%@convert[16,10,%PID]) selected
    echo.
  elseiff defined PROC then
    echo Process %PROC selected
    echo.
  endiff
  inkey /k"adfhorsvqx!?[Esc][Enter]" `D)ump F)ull S)hared X)tended A)ll R)eset O)ff V)iew H)elp Q)uit ? ` %%Z
  iff "%Z" == "q" .or. "%Z" == "" then
    leave
  elseiff "%Z" == "@28" then
    echo.
    iterate
  elseiff %Z == a then
    gosub SetAll
  elseiff %Z == d then
    gosub ForceDump
  elseiff %Z == f then
    :: Full
    gosub SetFull
  elseiff %Z == o then
    gosub SetOff
  elseiff %Z == r then
    gosub Reset
  elseiff %Z == v then
    gosub ViewSettings
  elseiff %Z == x then
    gosub SetExtended
  elseiff %Z == s then
    gosub AddShared
  elseiff "%Z" == "!" then
    :: Shell
    echo.
    %comspec
  elseiff "%Z" == "h" .or. "%Z" == "?" then
    :: Help
    echo.
    echo D - Force dump using current settings
    echo F - Set up for full dump - adds summ,sysldr,sysfs,private,instance,syssem,sysio
    echo S - Add shared code/data to current settings
    echo X - Set up for extended dump - full plus shared
    echo A - Set up to dump all physical memory with paddr(all) - resets other settings
    echo R - Reset to default settings
    echo O - Turn off dump facility
    echo V - View current settings
    echo H - Display this screen
    echo Q - Quit
    echo ? - Display this screen
    echo ! - Shell
    echo.
  else
    echo.
    pause Unexpected %Z
    cancel
  endiff
enddo

:quit

:: Show exit state
gosub ViewSettings

quit

:: === AddShared ===

:AddShared
  iff %TYPE == All then
    echo Dump type is %TYPE - can not add shared
  else
    if %@index[%TYPE,shared] == -1 set TYPE=%TYPE shared
    echo.
    echo Setting dump type to %TYPE
    echo on
    pdumpusr shared,update
    pdumpusr query
    @echo off
  endiff
  return
  :: end AddShared

::=== Force dump ===

:ForceDump
  :: Force dump now
  echo.
  iff defined PID then
    echo Dumping PID %PID
    echo on
    procdump force /pid:%PID
    @echo off
  elseiff defined PROC then
    echo Dumping process %PROC
    echo on
    procdump force /proc:%PROC
    @echo off
  elseiff %TYPE == All then
    echo Dumping all memory
    echo on
    :: procdump force /system
    procdump force /pid:all
    @echo off
  else
    echo Process/pid required for type %TYPE dump
  endiff
  return
  :: end ForceDump

::=== Reset ====

:Reset
  :: Reset to default
  set TYPE=Default
  echo.
  echo Resetting dump type to %TYPE
  echo on
  procdump reset /pid:all
  procdump on /l:%DUMPDIR
  pdumpusr reset
  procdump query
  @echo off
  return
  :: end Reset

::=== SetAll ===

:SetAll
  :: All physical memory
  set TYPE=All
  echo.
  echo Setting dump type to %TYPE
  echo on
  pdumpusr reset
  pdumpusr paddr(all)
  pdumpusr query
  @echo off
  return
  :: end SetAll

::=== SetExtended ===

:SetExtended
  :: Full
  set TYPE=Full Shared
  echo.
  echo Setting dump type to %TYPE
  echo on
  :: pdumpusr reset
  pdumpusr summ,sysldr,sysfs,syspg,sysvm,private,instance,syssem,sysio,shared,update
  pdumpusr query
  @echo off
  return
  :: end SetExtended

::=== SetFull ===

:SetFull
  :: Full
  set TYPE=Full
  echo.
  echo Setting dump type to %TYPE
  echo on
  :: pdumpusr reset
  pdumpusr summ,sysldr,sysfs,sysvm,private,instance,syssem,sysio,update
  pdumpusr query
  @echo off
  return
  :: end SetFull

::=== SetOff ===

:SetOff
  :: Off
  set TYPE=Off
  echo.
  echo Turning off Dump Facility
  echo on
  procdump off
  @echo off
  echo.
  return
  :: end SetOff

::=== ViewSettings ===

:ViewSettings
  echo.
  echo Dump type is %TYPE
  echo on
  procdump query
  @echo off
  return
  :: end ViewSettings

::=== Halted() Handle break ===

:Halted
  @echo off
  echo Halted by user
  goto quit
  :: end Halted

::=== Usage: Report usage error ===

:Usage
  beep
  echo Usage: %@lower[%0] `[-?] [-i] [commands...] [procname|pid] [dirname]`
  cancel

::=== Help: Show usage help ===

:Help
  echo.
  echo Control Process Dump Facility in batch or interactive mode
  echo.
  echo Usage: %@lower[%0] `[-?] [-i] [commands...] [procname|pid] [dirname]`
  echo.
  echo ` -h -?     Display this message`
  echo ` -i        Run interactive (default is batch mode)`
  echo.
  echo ` pid       Select PID to dump, default radix is hex`
  echo `           Prefix with 0x or 0n if amibiguous`
  echo ` procname  Select process to dump`
  echo `           Quote if name looks like a number`
  echo ` dirname   Set Dump directory, quote if name looks like a number`
  echo `           Defaults to ?:\Dumps or %TMP\Dumps`
  echo ` commands  Batch mode commands`
  echo `   a       Set up to dump all memory`
  echo `   d       Force dump, requires PID or process name`
  echo `   f       Set up for full dump, system default plus system details`
  echo `   o       Turn off dump facilty`
  echo `   r       Reset dump settings to system default values`
  echo `   s       Add shared memory to dump settings`
  echo `   v       View dump settings`
  echo `   x       Set up for extended dump - full plus shared memory`
  cancel

:eof
