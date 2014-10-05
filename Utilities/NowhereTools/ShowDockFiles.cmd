/* ShowDockFolders - Show contents of SmartCenter dock*.cfg files
   $Id: $
   Args are dock file names, default is ?:\os2\dll\dock*.cfg

   Copyright (c) 2009 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   29 Oct 09 SHL Baseline
   07 Dec 09 SHL Correct typos

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Gbl.!Version = '0.3'

Main:

  parse arg cmdLine
  call ScanArgs cmdLine
  drop cmdLine

  Gbl.!FilesProcessed = 0

  do argNum = 1 to Gbl.!ArgList.0
    curArg = Gbl.!ArgList.argNum
    call DoArg curArg
  end

  if Gbl.!FilesProcessed = 0 then
    say 'No dock files selected for processing'


  exit

/* end main */

/*=== DoArg(wildCard) Process matching files ===*/

DoArg: procedure expose Gbl.

  parse arg wildCard

  /* L: MM-DD-YYYY HH:MM Size ADHRS Name */
  call SysFileTree wildCard, 'FileList', 'FL'

  if RESULT \= 0 then
    call Fatal 'SysFileTree failed for' wildCard || '.'
  else if FileList.0 = 0 then
    call Fatal 'SysFileTree found no files matching' wildCard || '.'
  else do
    do fileNum = 1 to FileList.0
      parse value FileList.fileNum with fileDate fileTime fileBytes fileAttrib fileName
      fileName = strip(fileName)
      call DoOneDock fileName, fileBytes
    end /* fileNum */
  end

  return

/* end DoArg */

/*=== DoOneDock(fileName, fileBytes) Show object handles in dock file ===*/

DoOneDock: procedure expose Gbl.

  parse arg fileName, fileBytes

  say
  say 'Checking' fileName

  Gbl.!FilesProcessed = Gbl.!FilesProcessed + 1

  buffer = charin(fileName, 1, fileBytes)
  call stream fileName, 'C', 'CLOSE'

  /* 00000000  00 01 00 00  00 4D 61 69  6E 00 00 00  00 00 00 00  תתתתתMainתתתתתתת
     00000010  00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00  תתתתתתתתתתתתתתתת
     00000020  00 00 00 00  00 00 02 00  00 00 F0 A9  02 00 EF 87  תתתתתתתתתתתתתתתת
				  -----------
     00000030  02 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00  תתתתתתתתתתתתתתתת
     00000040  00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00  תתתתתתתתתתתתתתתת
     00000050  00 00 00 00  00 00                                  תתתתתת
  */

  o = x2d('26') + 1
  s = substr(buffer, o, 4)		/* Count */
  cnt = x2d(c2x(reverse(s)))

  say
  say fileName 'contains' cnt 'object handles.'

  do i = 1 to cnt
    o = x2d('2A') + 1 + (i - 1) * 4
    s = substr(buffer, o, 4)		/* handle */
    h = c2x(reverse(s))
    h = strip(h, 'L', '0')
    if h = 0 then
      h = 0
    h = '#' || h
    call DoOneObject h
  end

  return

/* end DoOneDock */

/*=== DoOneObject() Display one object ===*/

DoOneObject: procedure expose Gbl.

  parse arg objectId

  say
  say 'Checking object' objectId
  say
  ok = WPToolsQueryObject(objectId, 'ClassName', 'Title', 'Setup', 'Location')
  if ok \= 1 then do
    say 'WPToolsQueryObject can not access' objectId || '.'
    say 'The object id or the underlying object may not exist.'
  end
  else do
   say 'Object handle:' objectId
   say 'Class name   :' ClassName
   say 'Title        :' Title
   say 'Location     :' Location
   say 'Setup string :' Setup
  end

  return

/* end DoOneObject */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose Gbl.
  call GetCmdName
  call LoadRexxUtil
  call LoadWPTools
  return

/* end Initialize */

/*=== ScanArgsInit() ScanArgs initialization exit routine ===*/

ScanArgsInit: procedure expose Gbl. cmdTail swCtl keepQuoted
  /* Preset defaults */
  Gbl.!ArgList.0 = 0			/* Reset arg count */
  /* Configure scanner */
  swCtl = ''				/* Switches that take args, append ? if arg optional */
  keepQuoted = 0			/* Set to 1 to keep arguments quoted */
  return

/* end ScanArgsInit */

/*=== ScanArgsSwitch() ScanArgs switch option exit routine ===*/

ScanArgsSwitch: procedure expose Gbl. curSw curSwArg
  select
  when curSw == 'h' | curSw == '?' then
    call ScanArgsHelp
  when curSw == 'V' then do
    say Gbl.!CmdName Gbl.!Version
    exit
  end
  otherwise
    call ScanArgsUsage 'switch '''curSw''' unexpected'
  end /* select */

  return

/* end ScanArgsSwitch */

/*=== ScanArgsArg() ScanArgs argument option exit routine ===*/

ScanArgsArg: procedure expose Gbl. curArg

  argNum = Gbl.!ArgList.0 + 1
  Gbl.!ArgList.argNum = curArg
  Gbl.!ArgList.0 = argNum

  return

/* end ScanArgsArg */

/*=== ScanArgsTerm() ScanArgs scan end exit routine ===*/

ScanArgsTerm: procedure expose Gbl.

  if Gbl.!ArgList.0 = 0 then do
    Gbl.!ArgList.1 = SysBootDrive() || '\os2\dll\Dock*.cfg'
    Gbl.!ArgList.0 = 1
  end
  return

/* end ScanArgsTerm */

/*=== ScanArgsHelp() Display ScanArgs usage help exit routine ===*/

ScanArgsHelp:
  say
  say 'Dump contents of dock*.cfg files.'
  say
  say 'Usage:' Gbl.!CmdName '[-h] [-V] [-?] [fileSpec]...'
  say
  say '  -h -?     Display this message'
  say '  -V        Display version'
  say
  say '  fileSpec  Dock file filespec, wildcards OK'
  exit 255

/* end ScanArgsHelp */

/*=== ScanArgsUsage(message) Report Scanargs usage error exit routine ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \== '' then
    say msg
  say 'Usage:' Gbl.!CmdName '[-h] [-V] [-?] [fileSpec]...'
  exit 255

/* end ScanArgsUsage */


/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== LoadWPTools() Load Henk's WPTools functions ===*/

LoadWPTools:
  if RxFuncQuery('WPToolsLoadFuncs') then do
    call RxFuncAdd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
    if RESULT then
      call Fatal 'Cannot load WPToolsLoadFuncs'
    call WPToolsLoadFuncs
  end
  return

/* end LoadWPTools */

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

/*=== ScanArgs(cmdLine) Scan command line ===*/

ScanArgs: procedure expose Gbl.

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
