/* MergeConfigSys - merge old config.sys into new config.sys
   writes output to config.sys-merged without prompting

   Copyright (c) 2010, 2012 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   2010-09-23 SHL Baseline
   2010-09-29 SHL Show id in MergePaths messages
   2012-07-29 SHL Update
   2012-08-10 SHL Update
   2012-10-29 SHL Sync with templates

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call SetLocal

call Initialize

G.!Version = '0.1'

Main:
  parse arg cmdLine
  call ScanArgs cmdLine
  drop cmdLine

  NewCS.0 = 0
  call MergeFiles
  call WriteOut

  exit

/* end main */

/*
  err = SysStemCopy(fromstem, tostem, [from], [to], [count] [,insert])
  err = SysStemDelete(stem, startitem [,itemcount])
  err = SysStemInsert(stem, position, value)
*/

/*=== MergeFiles() Process argument; return rc ===*/

MergeFiles: procedure expose G. NewCS.

  call VerboseMsg1, 'Merging' G.!OldConfigSys, 'into' G.!NewConfigSys

  call ReadFileToWrkStem G.!OldConfigSys
  call SysStemCopy 'Wrk', 'OldCS'
  call WarnMsg1 'Read' OldCS.0 'lines from' G.!OldConfigSys
  call ReadFileToWrkStem G.!NewConfigSys
  call SysStemCopy 'Wrk', 'NewCS'
  call WarnMsg1 'Read' NewCS.0 'lines from' G.!NewConfigSys
  drop Wrk.

  firstRem = 0
  needSeparator = 1

  /* FIXME to report progress every 2 seconds or so - code is slowish */
  do oldLineNum = 1 to OldCS.0

    oldLine = OldCS.oldLineNum
    s = DecodeType(oldLine)
    parse var s oldType oldSubType

    if oldType == '*BLANK*' then iterate

    if oldType \== 'REM' & oldType \== 'SET' then call DbgMsg1 2, 'Detected' strip(oldType oldSubType) 'for' oldLine
    newLineNum = FindMatchingLine(oldType, oldSubType, oldLine)

    if newLineNum = 0 then do
      /* Not matched */
      if oldType == 'REM' then do
	/* Cache REMs for insert later */
	if firstRem = 0 then
	  firstRem = oldLineNum
	lastRem = oldLineNum
      end
      else do
	call DbgMsg1 'No match found for' oldLine
	if needSeparator then do
	  needSeparator = 0
	  s = 'Unmatched lines from' G.!OldConfigSys
	  lineNum = NewCS.0 + 1
	  do ndx = 1 to 5
	    select
	    when ndx = 2 | ndx = 4 then
	      NewCS.lineNum = 'REM' copies('=', length(s))
	    when ndx = 3 then
	      NewCS.lineNum = 'REM' s
	    otherwise
	      NewCS.lineNum = ''
	    end /* select */
	    lineNum = lineNum + 1
	  end /* do */
	  NewCS.0 = lineNum - 1
	end /* if needSeparator */
	/* Append cached REMs */
	if firstRem > 0 then do
	  call InsertCachedRems 0	/* Append */
	end /* if cached REMs */
	/* Append unmatched line */
	lineNum = NewCS.0 + 1
	NewCS.lineNum = oldLine
	NewCS.0 = lineNum
      end
    end /* if not matched */
    else do
      /* Found match */
      if 0 then call DbgMsg1 'Found match for' oldLine
      cnt = InsertCachedRems(newLineNum)	/* Insert cached REMs */
      newLineNum = newLineNum + cnt
      newLine = newCs.newLineNum
      /* If exact match, we are done for now */
      if translate(space(oldLine)) == translate(space(newLine)) then iterate
      call DbgMsg 'Found altered match at' newLineNum, 'old line:' oldLine, 'new line:' newLine
      /* Merge path like statment */
      if oldType == '*PATH*' | oldType == 'LIBPATH' then do
	if oldType == '*PATH*' then
	  id = oldSubType
	else
	  id = oldType
	mergedLine = MergePaths(oldLine, newLine, id)
	if translate(space(mergedLine)) == translate(space(newLine)) then do
	  call DbgMsg1 'Merged line matches new line'
	  iterate
	end
	/* Replace original with REM */
	call VerboseMsg1 'Merge result is' mergedLine
	/* Insert merged Line */
	NewCS.newLineNum = mergedLine
      end
      else do
	/* FIXME to optionally insert old line as comment - DbgLvl? */
      end

    end
  end /* oldLineNum */

  /* Append cached REMs - assume trailer comments */
  call InsertCachedRems 0		/* Append */

  return

/* end MergeFiles */

/*=== DecodeType(line) Decode line type return type and subtype ===*/

DecodeType: procedure expose G.

  parse arg line

  /* Tabs to spaces, collapse white space */
  line = strip(translate(line, ,'09'x))
  if line == '' then
    return '*BLANK*'
  i = verify(line, ' =', 'M')		/* Find delimter */
  if i > 0 then do
    ch = substr(line, i, 1)
    parse var line cmd(ch)parms
  end
  else
    parms = ''
  cmd = translate(cmd)

  if cmd == 'REM' then return cmd

  if cmd == 'SET' then do
    parse var parms name'='value
    name = translate(name)
    match = '' name ''
    matches = '',
	      'BOOKSHELF CLASSPATH CODELPATH DPATH EPMPATH HELP INCLUDE',
	      'INFOPATH LIB LOCPATH MANPATH NLSPATH PATH READIBM SMINCLUDE',
	      'SOMBASE SOMIR SOMRUNTIME',
	      ''
    if pos(match, matches) > 0 then return '*PATH*' name
    return cmd name			/* Plain SET */
  end

  if cmd == 'LIBPATH' then
    parm = ''
  else do
    parse var parms parm .		/* 1st word is subtype */
    parm = translate(parm)
  end

  match = '' cmd ''
  matches = '',
	    'AUTOFAIL BASEDEV BREAK BUFFERS CALL CLOCKSCALE',
	    'CODEPAGE COUNTRY DEVICE DEVINFO DISKCACHE',
	    'DLLBASING DOS DUMPPROCESS FCBS FILES IFS IOPL LIBPATH MAXWAIT MEMMAN',
	    'PRINTMONBUFSIZE PRIORITY_DISK_IO PROMPT PROTECTONLY',
	    'PROTSHELL RESERVEDRIVELETTER RMSIZE RUN SHELL',
	    'SUPPRESSPOPUPS SWAPPATH THREADS TRAPDUMP VIRTUALADDRESSLIMIT',
	    ''

  if pos(match, matches) > 0 then return strip(cmd parm)

  call Fatal 'Can not decode' line

/* end DecodeType */

/*=== FindMatchingLine(line) Find matching line in new config.sys ===*/

FindMatchingLine: procedure expose G. NewCS.

  parse arg oldType, oldSubType, oldLine

  /* Find closely matching line */

  do newLineNum = 1 to NewCS.0

    newLine = NewCS.newLineNum
    s = DecodeType(newLine)
    parse var s newType newSubType

    if newType == '*BLANK*' then iterate	/* Never match */

    if oldType == 'REM' then do
      if translate(strip(oldLine)) \== translate(strip(newLine)) then iterate	/* REMs must match exactly */
    end

    /* 2010-09-24 SHL FIXME to support multiple calls with differing args */
    if oldType == newType & oldSubType == newSubType then
      leave				/* Have at least partial match */

    if 0 then if newType \== 'REM' & newType \== 'SET' then call DbgMsg1 'Detected' newType 'for' newLine

  end /* newLineNum */

  if newLineNum > NewCS.0 then newLineNum = 0

  return newLineNum

/* end FindMatchingLine */

/*=== InsertCachedRems(lineNum) Insert/append cached REMs, return insert count ===*/

InsertCachedRems: procedure expose G. OldCs. NewCs. firstRem LastRem

  parse arg insertLineNum		/* 0 requests append */

  cnt = 0

  /* Insert cached REMs */
  if firstRem > 0 then do
    /* If looks like header comment, insert after existing header comments
       otherwise insert before requested line
    */
    cnt = lastRem - firstRem + 1
    if firstRem > 0 then
      lineNum = insertLineNum		/* Insert at request location */
    else do
      /* Looks like header comment - insert after existing header comments */
      /* Find end of existing header comments */
      do for lineNum = 1 to NewCS.0
	lineNum = NewCS.0
	type = DecodeType(line)
	if type \= '*BLANK*' & type \= 'REM' then leave
      end /* do */
    end
    if lineNum = 0 then
      lineNum = NewCS.0 + 1		/* Append requested */
    if 0 then call DbgMsg1 'Inserting REMs from' firstRem 'to' lastRem 'at' lineNum
    err = SysStemCopy('OldCS', 'NewCS', firstRem, lineNum, cnt, 'I')
    if err then call Fatal 'SysStemCopy failed'
    firstRem = 0
  end /* if have REMs */

  return cnt

/* end InsertCachedRems */

/*=== MergePaths(oldLine, newLine, id) Merge path like statements ===*/

MergePaths: procedure expose G.

  parse arg oldLine, newLine, id

  oldLine = strip(translate(oldLine, '', '09'x))	/* Normalize whitespace */
  newLine = strip(translate(newLine, '', '09'x))

  hadSemi = right(newLine, 1) == ';'

  parse var oldLine cmd'='paths
    parse var oldLine cmd'='paths
  if paths = '' then
    call Fatal 'Can not parse' oldLine

  /* Build oldPaths stem */
  oldPaths.0 = 0
  do while paths \== ''
    i = pos(';', paths)
    if i = 0 then do
      path = paths
      paths = ''
    end
    else
      parse var paths path';'paths

    if path \= '' then do
      if id == 'SOMIR' then do
	if \ IsFile(path) then do
	  call VerboseMsg1 'Skipping non-existant file' path 'in' id
	  iterate
	end
      end
      else if id == 'NLSPATH' then do
	i = pos('\%N', path)
	if i > 0 then
	  s = substr(path, 1, i - 1)
	else
	  s = path
	if \ IsDir(s) then do
	  call VerboseMsg1 'Skipping non-existant file' path 'in' id
	  iterate
	end
      end
      else if \ IsDir(path) then do
	call VerboseMsg1 'Skipping non-existant path' path 'in' id
	iterate
      end
    end

    i = oldPaths.0 + 1
    oldPaths.i = path
    oldPaths.0 = i
  end /* while */

  parse var newLine cmd'='paths
  if paths = '' then
    call Fatal 'Can not parse' newLine

  /* Build newPaths stem */
  newPaths.0 = 0
  do while paths \== ''
    i = pos(';', paths)
    if i = 0 then do
      path = paths
      paths = ''
    end
    else
      parse var paths path';'paths
    /* Assume new exist paths OK even if not the case */
    i = newPaths.0 + 1
    newPaths.i = path
    newPaths.0 = i
  end /* while */


  /* If not matched, insert after last insert
     If before 1st match, insert at start
  */
  lastNewNdx = 0
  do oldNdx = 1 to oldPaths.0

    path = oldPaths.oldNdx

    do newNdx = 1 to newPaths.0
      if path == newPaths.newNdx then leave
    end /* do newNdx */
    if newNdx <= newPaths.0 then do
      lastNewNdx = newNdx
      iterate				/* Matched */
    end
    lastNewNdx = lastNewNdx + 1
    call VerboseMsg1 'Inserting' path 'at index' lastNewNdx
    err = SysStemInsert('newPaths', lastNewNdx, path)
    if err then call Fatal 'SysStemInsert failed'

  end /* oldNdx */

  /* Rebuild statement */
  paths = ''
  do newNdx = 1 to newPaths.0
    if paths \= '' then
      paths = paths || ';'
    paths = paths || newPaths.newNdx
  end /* newNdx */

  if hadSemi then
    paths = paths || ';'

  mergedLine = cmd || '=' || paths	/* SET PATH= or LIBPATH= */

  return mergedLine

/* end MergePaths */

/*=== WriteOut() Write out merged config.sys ===*/

WriteOut: procedure expose G. NewCS.

  fn = 'config.sys-merged'

  call WarnMsg1 'Writing' NewCS.0 'lines to' fn
  if NewCS.0 > 600 then
    call WarnMsg1 'Edit' fn 'to be less than 600 lines for INSCFG32'
  call SysFileDelete fn

  do ndx = 1 to NewCS.0
    call lineout fn, NewCS.ndx
  end
  call lineout fn

  return

/* end WriteOut */

/*=== Z(curArg) TBD ===*/

Z: procedure expose G.

  parse arg curArg

  return

/* end Z */

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
  G.!DbgLvl = 0				/* Display debug messages */
  G.!Verbose = 0			/* Verbose messages */
  G.!OldConfigSys = ''
  G.!NewConfigSys = ''

  /* Configure scanner */
  swCtl = ''				/* Switches that take args, append ? if arg optional */
  keepQuoted = 0			/* Set to 1 to keep arguments quoted */

  return

/* end ScanArgsInit */

/*=== ScanArgsSwitch() ScanArgs switch option exit routine ===*/

ScanArgsSwitch: procedure expose G. curSw curSwArg

  select
  when curSw == 'd' then
    G.!DbgLvl = G.!DbgLvl + 1
  when curSw == 'h' | curSw == '?' then
    call ScanArgsHelp
  when curSw == 'v' then
    G.!Verbose = 1
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

  if \ IsFile(curArg) then
    call Fatal curArg 'not found'

  if G.!OldConfigSys == '' then
    G.!OldConfigSys = curArg
  else if G.!NewConfigSys == '' then
    G.!NewConfigSys = curArg
  else
    call ScanArgsUsage 'Only two files allowed'

  return

/* end ScanArgsArg */

/*=== ScanArgsTerm() ScanArgs scan end exit routine ===*/

ScanArgsTerm: procedure expose G.

  if G.!NewConfigSys == '' then
    call ScanArgsUsage 'required arguments missing'
  return

/* end ScanArgsTerm */

/*=== ScanArgsHelp() Display ScanArgs usage help exit routine ===*/

ScanArgsHelp:
  say
  say 'Merge old config.sys into new config.sys'
  say
  say 'Usage:' G.!CmdName '[-d] [-h] [-v] [-V] [-?] old-config.sys new-config.sys'
  say
  say '  -d           Enable debug logic, repeat for more verbosity'
  say '  -h -?        Display this message'
  say '  -v           Enable verbose output'
  say '  -V           Display version number and quit'
  say
  say '  old-config.sys  old config.sys (unchanged)'
  say '  new-config.sys  new config.sys (overwritten)'
  say
  say 'new config.sys backed up with saveverd before overwritten'
  exit 255

/* end ScanArgsHelp */

/*=== ScanArgsUsage(message) Report Scanargs usage error exit routine ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \== '' then
    say msg
  say 'Usage:' G.!CmdName '[-d] [-h] [-v] [-V] [-?] old-config.sys new-config.sys'
  exit 255

/* end ScanArgsUsage */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

/*=== AddDirSlash(directory) Append trailing \ to directory name unless just drive ===*/

AddDirSlash: procedure
  parse arg dir
  ch = right(dir, 1)
  if dir \== '' & ch \== '\' & ch \== ':' then
    dir = dir || '\'
  return dir

/* end AddDirSlash */

/*=== AskYNQ(prompt) returns 0=Yes, 1=No, 2=Quit ===*/

AskYNQ: procedure
  parse arg msg, skip

  /* If line skip requested */
  if skip \= '' & skip \= 0 then
    call 'LINEOUT' 'STDERR', ''

  if msg == '' then
    msg = 'Continue'
  call charout 'STDERR', msg '(y/n/q) ? '
  do forever
    key = translate(SysGetKey('NOECHO'))
    if key == 'Y' | key == 'N' then do
      call 'LINEOUT' 'STDERR', key
      if key == 'Y' then
	ynq = 0
      else
	ynq = 1
      leave
    end
    if key == 'Q' | c2x(key) == '1B' then do
      call 'LINEOUT' 'STDERR', ''
      ynq = 2
      leave
    end
  end /* forever */
  return ynq

/* end AskYNQ */

/*=== ChopDirSlash(directory) Chop trailing \ from directory name unless root ===*/

ChopDirSlash: procedure
  parse arg dir
  if right(dir, 1) == '\' & right(dir, 2) \== ':\' & dir \== '\' then
    dir = substr(dir, 1, length(dir) - 1)
  return dir

/* end ChopDirSlash */

/*=== DbgMsg1([level, ]message) Write single-line message to STDERR if debugging ===*/

DbgMsg1: procedure expose G.

  dbgLvl = arg(1)
  if dataType(dbgLvl, 'W') then
    start = 2
  else do
    dbgLvl = 1
    start = 1
  end
  if dbgLvl <= G.!DbgLvl then do
    msg = arg(start)
    if msg \== '' then
      msg = ' *' msg
    call 'LINEOUT' 'STDERR', msg
  end
  return

/* end DbgMsg1 */

/*=== DbgMsg([level, ]message) Write multi-line message to STDERR if debugging ===*/

DbgMsg: procedure expose G.

  dbgLvl = arg(1)
  if dataType(dbgLvl, 'W') then
    start = 2
  else do
    dbgLvl = 1
    start = 1
  end
  if dbgLvl <= G.!DbgLvl then do
    do i = start to arg()
      msg = arg(i)
      if msg \== '' then
	msg = ' *' msg
      call 'LINEOUT' 'STDERR', msg
    end
  end
  return

/* end DbgMsg */

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

/*=== IsFile(fileSpec) return true if arg is file ===*/

IsFile: procedure expose G.
  parse arg fileSpec
  if fileSpec == '' then
    yes = 0
  else do
    call SysFileTree fileSpec, 'fileList', 'F'
    if RESULT \= 0 then
      call Fatal 'IsFile' wildCard 'failed'
    /* Assume caller knows if arg contains wildcards */
    yes = fileList.0 \= 0
  end
  return yes

/* end IsFile */

/*=== ReadFileToWrkStem(fileName) Fast read file into Wrk. stem ===*/

ReadFileToWrkStem: procedure expose G. Wrk.

  parse arg fileName

  if stream(fileName, 'C', 'QUERY EXISTS') == '' then
    call Fatal fileName 'does not exist.'

  call stream fileName, 'C', 'OPEN READ'

  Wrk.0 = 0
  drop ErrCondition
  do while lines(fileName) \= 0
    call on NOTREADY name CatchError	/* Avoid death on missing NL */
    s = linein(fileName)
    signal on NOTREADY name Error
    i = Wrk.0 + 1
    Wrk.i = s
    Wrk.0 = i
    if symbol('ErrCondition') == 'VAR' then
      leave				/* Last line missing NL */
  end
  call stream fileName, 'C', 'CLOSE'

  return

/* end ReadFileToWrkStem */

/*=== VerboseMsg1(message) Write single-line message to STDERR if verbose ===*/

VerboseMsg1: procedure expose G.
  if G.!Verbose then do
    parse arg msg
    call 'LINEOUT' 'STDERR', msg
  end
  return

/* end VerboseMsg1 */

/*=== WarnMsg1(message) Write single-line warning message to STDERR ===*/

WarnMsg1: procedure
  parse arg msg
  call 'LINEOUT' 'STDERR', msg
  return

/* end WarnMsg1 */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

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
  s = value('TMP',,G.!Env)
  if s \= '' & right(s, 1) \= ':' & right(s, 1) \== '\' then
    s = s'\'				/* Stuff backslash */
  G.!TmpDir = s
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
