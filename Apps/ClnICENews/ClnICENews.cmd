/* ClnICENews: Clean up ICE news databases

    Copyright (c) 2001, 2003 Steven Levine and Associates, Inc.
    All rights reserved.

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

    Revisions	14 Jun 01 SHL - Baseline
		05 Jun 02 SHL - Disable .txt delete
		05 Jun 02 SHL - Release v0.5
		19 Nov 03 SHL - Sanitize
		27 Nov 03 SHL - Release v0.6

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

Gbl.!Version = 0.6

call Initialize

Main:

  parse arg CmdLine
  call ScanArgs CmdLine
  drop CmdLine

  say

  if \ Gbl.!fTest &,
     \ Gbl.!fJustOld &,
     \ Gbl.!fForce then
    call ChkICERunning

  call FindICEHome

  call FindNewsDirs

  call ClnNewsDirs

  exit

/* end main */

/*=== ChkICERunning: Warn and quit if ICE running ===*/

ChkICERunning: procedure expose Gbl.

  say 'Checking ICE running...'

  '@pstat /c | rxqueue'

  fIsRunning = 0

  do while queued() \= 0 & \ fIsRunning
    pull line
    if pos('MR2I.EXE', line) \= 0 then
      fIsRunning = 1
  end

  if fIsRunning then
    call Fatal 'Please shutdown ICE and try again'

  return

/* end ChkICERunning */

/*=== ClnNewsDirs: Clean news directories ===*/

ClnNewsDirs: procedure expose Gbl.

  do iAcc = 1 to Gbl.!Accounts.0

    account = Gbl.!Accounts.iAcc

    say
    say 'Cleaning' account

    dir = ToLower(Gbl.!ICEHomeDir'\'account'\news')

    call BldFileTree dir'\*.old', 'FileList'

    if \ Gbl.!fJustOld then do

      call BldFileTree dir'\*.idx', 'FileList2'

      /* Combine */
      i = FileList.0
      do j = 1 to FileList2.0
	i = i + 1
	FileList.i = FileList2.j
      end
      FileList.0 = i

      /* fixme to be really gone */
      if 0 then do
	call BldFileTree dir'\n*.txt', 'FileList2'

	/* Combine */
	i = FileList.0
	do j = 1 to FileList2.0
	  i = i + 1
	  FileList.i = FileList2.j
	end
	FileList.0 = i
      end /* if 0 */

    end

    if FileList.0 = 0 then
      say ' * Nothing to delete'
    else do

      say

      call BldFileTree dir'\*.dat', 'DatFileList'

      do iFile = 1 to DatFileList.0
	line = ToLower(DatFileList.iFile)
	say strip(line, 'B')
      end /* iFile */

      say

      do iFile = 1 to FileList.0
	line = ToLower(FileList.iFile)
	say strip(line, 'B')
      end /* iFile */

      say

      do iFile = 1 to FileList.0
	/* : MM-DD-YY HH:MM Size ADHRS Name */
	line = ToLower(FileList.iFile)
	parse var line . . . . fileName .
	say strip(line, 'B')
	if \ Gbl.!fYes & \ Gbl.!fTest then do
	  call AskYNQ 'Delete' fileName
	  if RESULT = 2 then
	    exit
	  say
	  if RESULT = 1 then
	    iterate
	end
	if Gbl.!fTest then
	  say ' * would be deleted'
	else do
	  call SysFileDelete fileName
	  if RESULT \= 0 then
	    call Fatal 'Can not delete' fileName
	  else
	    say ' * deleted'
	end
      end /* iFile */
    end

  end /* iAcc */

  return

/* end ClnNewsDirs */

/*=== FindICEHome: Find ICE home directory ===*/

FindICEHome: procedure expose Gbl.

  do forever

    /* Check if running from ICE home */
    dir = directory()
    if stream(dir'\mr2i.exe', 'C', 'QUERY EXISTS') \= '' then
      leave

    /* Check if running from ./scripts */
    i = lastpos('\', dir)
    if i > 3 then do
      dir = left(dir, i - 1)
      if stream(dir'\mr2i.exe', 'C', 'QUERY EXISTS') \= '' then
	leave
    end

    /* Check if script lives in ICE home */
    parse source . . dir
    i = lastpos('\', dir)
    if i > 3 then do
      dir = left(dir, i - 1)
      if stream(dir'\mr2i.exe', 'C', 'QUERY EXISTS') \= '' then
	leave
      /* Check if script lives in ./subdir */
      i = lastpos('\', dir)
      if i > 3 then do
	dir = left(dir, i - 1)
	if stream(dir'\mr2i.exe', 'C', 'QUERY EXISTS') \= '' then
	  leave
      end
    end

    call Fatal 'Can not find MR/2 ICE home directory'

  end

  Gbl.!ICEHomeDir = dir

  say 'MR/2 ICE home directory is' Gbl.!ICEHomeDir

  return

/* end FindICEHome */

/*=== FindNewsDirs: Find news directories ===*/

FindNewsDirs: procedure expose Gbl.

  if Gbl.!Accounts.0 \= 0 then do

    do iAcc = 1 to Gbl.!Accounts.0

      account = Gbl.!Accounts.iAcc
      dir = ToLower(Gbl.!ICEHomeDir'\'account'\news')
      call BldFileTree dir, 'FileList', 'DO'

      if FileList.0 = 0 then
	call Fatal 'Can not find' dir

    end /* iAcc */

  end

  else do

    say 'Searching for news directories.  Please wait...'

    call BldFileTree Gbl.!ICEHomeDir'\*.cfg', 'CfgFileList', 'FO'

    do iCfg = 1 to CfgFileList.0

      cfgFile =	filespec('N', CfgFileList.iCfg)
      i = lastpos('.', cfgFile)
      account = left(cfgFile, i - 1)

      if Gbl.!fDebug then
	say 'Checking' account

      call BldFileTree Gbl.!ICEHomeDir || '\' || account || '\news', 'DirList', 'DO'

      do i = 1 to DirList.0
	dir = DirList.i
	if Gbl.!fDebug then
	  say 'Found' dir
	dir = substr(dir, length(Gbl.!ICEHomeDir) + 2)	/* Chop d:\mr2i\ */
	j = lastpos('\', dir)
	dir = left(dir, j - 1)		/* Chop \news */
	j = pos('\', dir)
	if j = 0 then do
	  say ' Selected' dir
	  j = Gbl.!Accounts.0 + 1
	  Gbl.!Accounts.j = dir
	  Gbl.!Accounts.0 = j
	end
      end /* iDir */
    end /* iCfg */

    if Gbl.!Accounts.0 = 0 then
      call Fatal 'Can not find any news directories under' Gbl.!ICEHomeDir

  end

  return

/* end FindNewsDirs */

/*=== Initialize: Intialize globals ===*/

Initialize: procedure expose Gbl.

  call LoadRexxUtil
  call GetCmdName
  return

/* end Initialize */

/*=== ScanArgs(cmdLine): scan command line arguments and switches ===*/

ScanArgs: procedure expose Gbl.

  /* Evaluate arguments - override
     Return Gbl.! and Accounts.
     fixme to do quotes
     Uses work stem Z
  */

  parse arg cmdTail
  cmdTail = strip(cmdTail)

  /* Set defaults */
  Gbl.!Accounts.0 = 0			/* No accounts */
  Gbl.!fDebug = 0
  Gbl.!fForce = 0
  Gbl.!fJustOld = 0			/* Delete .old only */
  Gbl.!fTest = 0			/* Test only - no delete */
  Gbl.!fYes = 0				/* Always answer yes */

  /* Prepare scanner */
  SwCtl = ''	/* Switches that take args */

  curArg = ''				/* Current argument string */
  curSwList = ''			/* Current switch list */
  /* curSwArg = '' */			/* Current switch argument, if needed */
  noMoreSw = 0				/* End of switches */

  do while cmdTail \== '' | curArg \== '' | curSwList \== ''

    /* If arg buffer empty, refill */
    if curArg == '' then do
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
	  parse var cmdTail (qChar) cmdTail
	end
      end /* if quoted */
    end

    /* If switch buffer empty, refill */
    if curSwList == '' then do
      if left(curArg, 1) == '-' then do
	if noMoreSw then
	  call Usage 'switch '''curArg''' unexpected'
	else if curArg == '--' then
	  noMoreSw = 1
	else
	  curSwList = substr(curArg, 2)
	parse var cmdTail curArg cmdTail
      end
    end

    /* If switch in progress */
    if curSwList \== '' then do
      curSw = left(curSwList, 1)	/* Next switch */
      curSwList = substr(curSwList, 2)	/* Drop from pending */
      if Gbl.!fDebug then
	say '* Switch' curSw
      /* Check switch requires argument */
      if pos(curSw, SwCtl) \= 0 then do
	if curSwList \== '' then do
	  curSwArg = curSwList
	  curSwList = ''
	end
	else if curArg \== '' & left(curArg, 1) \= '-' then do
	  curSwArg = curArg
	  parse var cmdTail curArg cmdTail
	end
	else
	  call Usage 'Switch' curSw 'requires argument'
      end
      select
      when curSw == '?' then
	signal UsageHelp
      when curSw == 'd' then
	Gbl.!fDebug = 1
      when curSw == 'f' then do
	if Gbl.!fYes then
	  call Usage '-f may not be used with -y'
	Gbl.!fForce = 1
      end
      when curSw == 'h' then
	signal UsageHelp
      when curSw == 'o' then
	Gbl.!fJustOld = 1
      when curSw == 't' then
	Gbl.!fTest = 1
      when curSw == 'y' then do
	if Gbl.!fForce then
	  call Usage '-f may not be used with -y'
	Gbl.!fYes = 1
      end
      when curSw == 'V' then do
	say
	say Gbl.!CmdName Gbl.!Version
	say
	say 'Copyright (c) 2001, 2003 Steven Levine and Associates, Inc.'
	say 'All rights reserved.'
	exit
      end
      otherwise
	call Usage 'switch '''curSw''' unexpected'
      end /* select */
    end /* if switch */

    /* If arg */
    else if curArg \== '' then do
      noMoreSw = 1			/* No more switches */
      if Gbl.!fDebug then
	say '* Arg' curArg
      /* Got non switch arg */
      i = Gbl.!Accounts.0 + 1
      Gbl.!Accounts.i = curArg
      Gbl.!Accounts.0 = i
      curArg = ''
    end

  end /* while cmdTail */

  return

/* end ScanArgs */

/*=== Usage(message): Report Usage Error... ===*/

Usage:

  parse arg msg

  say msg

  say 'Usage:' Gbl.!CmdName '[-h] [-f] [-o] [-t] [-V] [-y] account...'

  exit 255

/* end Usage */

/*=== UsageHelp(): Display help ===*/

UsageHelp:

  say
  say 'Usage:' Gbl.!CmdName '[-h] [-f] [-o] [-t] [-V] [-y] account...'
  say
  say '  -h       This message'
  say '  -f       Force to run with MR2/ICE active (be careful)'
  say '  -o       Delete .old backup files only'
  say '  -t       Test only.  Delete nothing'
  say '  -V       Display version info'
  say '  -y       Answer yes to all questions'
  say
  say '  account  ICE profile account name (i.e. mail, eCS)'
  say

  exit 255

/* end UsageHelp */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== AskYNQ(prompt) returns 0=Yes, 1=No, 2=Quit ===*/

AskYNQ: procedure

  parse arg msg

  if msg == '' then
    msg = 'Continue'
  call charout 'STDERR', msg '(y/n/q) ? '
  do forever
    key = translate(SysGetKey('NOECHO'))
    if key == 'Y' | key == 'N' then do
      call lineout 'STDERR', key
      if key == 'Y' then
	ynq = 0
      else
	ynq = 1
      leave
    end
    if key == 'Q' | c2x(key) == '1B' then do
      call lineout 'STDERR', ''
      ynq = 2
      leave
    end
  end

  return ynq

/* end AskYNQ */

/*=== BldFileTree(wildCard, stemName, options) Run SysFileTree with arguments ===*/

BldFileTree:

  /* Uses work stem Z */

  if arg() < 2 | arg(1, 'O') | arg(2, 'O') then do
    say 'BldFileTree: requires 2 or 3 arguments'
    signal Error
  end

  /* Set defaults */
  Z.wildCard = strip(arg(1), 'B')
  if Z.wildCard == '' then
    Z.wildCard = '*'			/* Default */

  Z.stem = arg(2)

  if arg(3, 'E') then
    Z.opt = arg(3)
  else
    Z.opt = ''

  /* Output format */
  /* : MM-DD-YY HH:MM Size ADHRS Name */
  /* L: MM-DD-YYYY HH:MM Size ADHRS Name */
  /* O: Name */
  /* T: YY/MM/DD/HH/MM Size ADHRS Name */
  /* TL: YYYY-MM-DD HH:MM:SS Size ADHRS Name */

  if Z.opt == '' then
    call SysFileTree Z.wildCard, Z.stem
  else
    call SysFileTree Z.wildCard, Z.stem, Z.opt

  if RESULT \= 0 then do
    say 'SysFileTree' Z.stem 'failed for' Z.opt
    signal Error
  end

  drop Z.

  return

/* end BldFileTree */

/*=== ToLower(sz) Convert to lower case ===*/

ToLower: procedure
  parse arg sz
  return translate(sz, xrange('a', 'z'), xrange('A', 'Z'))

/* end ToLower */

/*========================================================================== */
/*=== SkelRexx standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== Error() Report ERROR, FAILURE etc. - return ErrCondition or exit ===*/

Error:
  say
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' thisCmd
  if 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error' RC':' 'ERRORTEXT'(RC)
  say 'Source =' 'SOURCELINE'(SIGL)
  if 'CONDITION'('I') == 'CALL' then do
    ErrCondition = 'CONDITION'('C')
    drop thisCmd
    say 'Returning'
    return
  end
  trace '?A'
  say 'Exiting'
  call 'SYSSLEEP' 2
  exit 'CONDITION'('C')

/* end Error */

/*=== Fatal(message) Warble and report error and die ===*/

Fatal: procedure
  parse arg msg
  call lineout 'STDERR', msg
  do 10
    f=random(262,1047)
    d=random(100,200)
    call beep f,d
  end
  exit 254

/* end Fatal */

/*=== GetCmdName() Get script name, set Gbl.!CmdName ===*/

GetCmdName: procedure expose Gbl.
  parse source . . cmdName
  cmdName = filespec('N', cmdName)		/* Chop path */
  c = lastpos('.', cmdName)
  if c > 1 then
    cmdName = left(cmdName, c - 1)		/* Chop extension */
  Gbl.!CmdName = translate(cmdName, xrange('a', 'z'), xrange('A', 'Z'))	/* Lowercase */
  return

/* end GetCmdName */

/*=== Halt() Report HALT condition - return ErrCondition or exit ===*/

Halt:
  say
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at' SIGL 'of' thisCmd
  say 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
  if 'CONDITION'('I') == 'CALL' then do
    ErrCondition = 'CONDITION'('C')
    drop thisCmd
    say 'Returning'
    return
  end
  say 'Exiting'
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
