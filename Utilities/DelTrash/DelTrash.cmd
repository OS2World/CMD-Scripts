/* DelTrash: Delete items moved to trash more than X days ago

   Copyright (c) 1999, 2003 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

   Revisions	28 Dec 99 SHL - Baseline
		02 Jan 00 SHL - Tweak date math and debug output
		07 May 03 SHL - Make drive independent
		19 Nov 03 SHL - Rework for speed using ClnICENews logic

*/

signal on ERROR
signal on FAILURE name Error
signal on HALT
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Gbl.!Version = '0.2'

Main:
  parse arg CmdLine
  call ScanArgs cmdLine
  drop cmdLine

  call FindICEHome
  call FindTrashDirs
  call ClnTrashDirs

  exit

/* end main */

/*=== Initialize: Intialize globals ===*/

Initialize:
  call GetCmdName
  call LoadRexxUtil
  return

/* end Initialize */

/*=== ClnTrashDirs(): ... ===*/

ClnTrashDirs: procedure expose Gbl.

  /* Calc cutoff date in SysFileTree format */
  cutDate = date(, date('B') - Gbl.!LimitDays, 'B')
  cutTime = time()
  cutDateTimeSX = 'X'date('S', cutDate) cutTime

  say
  say 'Checking Trash for files older than' cutDate cutTime
  if Gbl.!fDebug then
    say '*' cutDateTimeSX

  do iAcc = 1 to Gbl.!Accounts.0
    account = Gbl.!Accounts.iAcc
    if Gbl.!fDebug then
      say '*'iAcc':' account
    TrashDir = Gbl.!ICEHomeDir || '\' || account || '\Trash'
    call ClnOneDir
  end /* iAcc */

  say
  say 'Checked Trash for files older than' cutDate cutTime

  if \ Gbl.!fTest then
    call SysSleep 5

  return

/*=== ClnOneDir(): check szTrashDir ===*/

ClnOneDir:

  /* Find all files in directory */

  say
  say 'Checking' TrashDir

  /* Just check files with extensions */
  /* TL: YYYY-MM-DD HH:MM:SS Size ADHRS Name */
  call BldFileTree TrashDir'\*.*', 'FileList', 'FTL'

  cFiles = 0
  cDeleted = 0

  do iFile = 1 to FileList.0

    cFiles = cFiles + 1

    line = FileList.iFile

    if Gbl.!fDebug then
      say '*'iFile':' line

    /* Format: YYYY-MM-DD HH:MM:SS Size ADHRS Filename */
    parse var line fileDate fileTime . . pathName
    pathName = strip(pathName)

    fileDateTimeS = FileTreeDateTimeToSorted(fileDate, fileTime)
    fileDate = date(, word(fileDateTimeS, 1), 'S')
    fileDateTimeSX = 'X'fileDateTimeS

    fileName = filespec('N', pathName)

    c = lastpos('.', fileName)
    baseName = left(fileName, c - 1)
    ext = translate(substr(fileName, c + 1))

    if ext == 'NDX' then
      iterate

    if ext == 'NDX-BAK' then
      iterate

    if Gbl.!fDebug then
      say ' *' fileDateTimeSX

    /* Delete files older than cutoff */
    if fileDateTimeSX < cutDateTimeSX then do
      cDeleted = cDeleted + 1
      if \ Gbl.!fTest then do
	call SysFileDelete pathName
	if RESULT \= 0 then do
	  say 'Can not delete' pathName RESULT
	  exit 1
	end
	if Gbl.!fVerbose then
	  say ' Deleted' pathName fileDate fileTime
      end
      else if Gbl.!fVerbose then
	say ' * Deleted' pathName fileDate fileTime '(TEST)'
    end
    else if Gbl.!fVerbose then
      say ' * Kept' pathName fileDate fileTime

  end /* do iFile */

  if Gbl.!fTest then
    sz = ' (TEST)'
  else
    sz = ''

  say 'Checked' cFiles 'files,' cDeleted 'deleted,' cFiles - cDeleted 'remaining' || sz

  return

/* end ClnTrashDirs */

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

FindTrashDirs: procedure expose Gbl.

  if Gbl.!Accounts.0 \= 0 then do

    /* Verify accounts from command line */
    do iAcc = 1 to Gbl.!Accounts.0
      account = Gbl.!Accounts.iAcc
      dir = ToLower(Gbl.!ICEHomeDir'\'account'\Trash')
      call BldFileTree dir, 'FileList', 'DO'
      if FileList.0 = 0 then
	call Fatal 'Can not find' dir
    end /* iAcc */

  end

  else do

    /* Hunt for trash directories */
    say 'Searching for Trash directories.  Please wait...'
    call BldFileTree Gbl.!ICEHomeDir'\*.cfg', 'CfgFileList', 'FO'

    do iCfg = 1 to CfgFileList.0

      cfgFile = filespec('N', CfgFileList.iCfg)
      i = lastpos('.', cfgFile)
      account = left(cfgFile, i - 1)

      if Gbl.!fVerbose then
	say 'Checking' account

      call BldFileTree Gbl.!ICEHomeDir || '\' || account || '\Trash', 'DirList', 'DO'

      do i = 1 to DirList.0
	dir = DirList.i
	if Gbl.!fDebug then
	  say ' * Found' dir
	dir = substr(dir, length(Gbl.!ICEHomeDir) + 2)	/* Chop d:\mr2i\ */
	j = lastpos('\', dir)
	dir = left(dir, j - 1)		/* Chop \Trash */
	j = pos('\', dir)
	if j = 0 then do
	  if Gbl.!fVerbose then
	    say ' * Selected' dir
	  j = Gbl.!Accounts.0 + 1
	  Gbl.!Accounts.j = dir
	  Gbl.!Accounts.0 = j
	end
      end /* iDir */
    end /* iCfg */

    if Gbl.!Accounts.0 = 0 then
      call Fatal 'Can not find any Trash directories under' Gbl.!ICEHomeDir

  end

  return

/* end FindTrashDirs */

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
  Gbl.!fVerbose = 0			/* Verbose messages */
  Gbl.!fTest = 0			/* Test only - no delete */
  Gbl.!LimitDays = 3

  /* Prepare scanner */
  SwCtl = ''				/* Switches that take args */

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
      when curSw == 'h' then
	signal UsageHelp
      when curSw == 't' then
	Gbl.!fTest = 1
      when curSw == 'v' then
	Gbl.!fVerbose = 1
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
      /* Got non switch arg */
      noMoreSw = 1			/* No more switches */
      if verify(curArg, '0123456789') = 0 then
	Gbl.!LimitDays = curArg
      else do
	i = Gbl.!Accounts.0 + 1
	Gbl.!Accounts.i = curArg
	Gbl.!Accounts.0 = i
      end
      curArg = ''
    end

  end /* while cmdTail */

  return

/* end ScanArgs */

/*=== Usage(message) Report usage error ===*/

Usage:
  parse arg msg
  say msg
  say 'Usage:' Gbl.!CmdName '[-d] [-h] [-t] [-v] [-V] [days] [accounts]'
  exit 255

/* end Usage */

/*=== UsageHelp() Display usage help ===*/

UsageHelp:
  say
  say 'Usage:' Gbl.!CmdName '[-d] [-h] [-t] [-v] [-V] days'
  say
  say ' -d            Debug messasges'
  say ' -h            Display this message'
  say ' -t            Test mode'
  say ' -v            Verbose messages'
  say ' -V            Display version'
  say
  say ' days          cutoff days (default=3)'
  say ' accounts      accounts (default=all)'
  exit 255

/* end UsageHelp */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

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

/*=== FileTreeDateTimeToSorted(d t) Convert SysFileTree TL date time to rexx sorted (yyyymmdd hh:mm:ss) ===*/

FileTreeDateTimeToSorted: procedure

  d = arg(1)
  t = arg(2)

  /* Dates passed in SysFileTree TL format
       YYYY-MM-DD HH:MM:SS
     Returned in REXX sortable (S) date/time format
       YYYYMMDD HH:MM:SS
  */

  /*             YYYYMMDD       YYYY-MM-DD */
  d = translate('ABCDFGIJ', d, 'ABCDEFGHIJ')

  return d t

/* end FileTreeDateTimeToSorted */

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

/*=== Fatal(message) Report fatal error and exit ===*/

Fatal:
  parse arg msg
  say
  say Gbl.!CmdName':' msg
  call Beep 200, 300
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
