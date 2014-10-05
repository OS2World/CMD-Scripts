/* IPFormatToText - Convert IPFormat output to more readable text
   Read named file or stdin.  Write stdout

   Copyright (c) 2001, 2013 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   2001-09-07 SHL Baseline
   2002-03-19 SHL Update help
   2003-03-29 SHL Update license
   2013-03-22 SHL Sync with templates

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

G.!Version = '0.3'

Main:

  parse arg cmdLine
  call ScanArgs cmdLine
  drop cmdLine

  cLinesRead = 0
  cLinesWritten = 0
  fInPacket = 0
  outLine = ''
  CR = x2c('0d')
  LF = x2c('0a')
  nonPrintables = xrange('00'x, '1f'x) || xrange('80'x, 'ff'x)

  do argNum = 1 to G.!ArgList.0

    inFile = G.!ArgList.argNum

    call lineout 'STDERR', 'IPFormatToText reading' inFile

    if inFile \= 'STDIN' then do

      if stream(inFile, 'C', 'QUERY EXISTS') == '' then do
	call Fatal inFile 'does not exist.'
      end

      call stream inFile, 'C', 'OPEN READ'
    end

    drop ErrCondition			/* Set by CatchError */

    do while lines(inFile) \= 0

      cLinesRead = cLinesRead + 1

      call on NOTREADY name CatchError	/* Avoid death on missing NL */
      inLine = linein(inFile)
      signal on NOTREADY name Error

      l = length(inLine)

      select
      when l = 0 then do
	if fInPacket then do
	  if outLine \= '' then do
	    call lineout ,outLine
	    cLinesWritten = cLinesWritten + 1
	  end
	  fInPacket = 0
	end
	call lineout ,''
	cLinesWritten = cLinesWritten + 1
      end
      when pos('----', inLine) = 1 &,
	   (pos('PACKET', inLine) \= 0 | pos('DATA', inLine) \= 0) then do
	fInPacket = 1
	outLine = ''
	call lineout ,inLine
	cLinesWritten = cLinesWritten + 1
      end
      when fInPacket then do
	work = strip(substr(inLine, 6, 50))
	do while work \== ''
	  ch = x2c(left(work, 2))
	  work = strip(substr(work, 3))
	  if pos(ch, nonPrintables) = 0 then do
	    outLine = outLine || ch
	    if length(outLine) >= 72 then do
	      call lineout ,outLine
	      outLine = ''
	      cLinesWritten = cLinesWritten + 1
	    end
	  end
	  else do
	    /* fixme to not ignore other non-printables */
	    if ch = CR | ch = LF then do
	      if length(outLine) > 0 then do
		call lineout ,outLine
		outLine = ''
		cLinesWritten = cLinesWritten + 1
	      end
	    end
	  end
	end /* while */
      end /* fInPacket */
      otherwise
	call lineout ,inLine
	cLinesWritten = cLinesWritten + 1
      end

    end /* while lines */

    if inFile \= 'STDIN' then
      call stream inFile, 'C', 'CLOSE'

  end /* iArgs */

  call lineout 'STDERR', 'Read' cLinesRead 'lines'

  exit

/* end main */

/*=== Initialize: Intialize globals ===*/

Initialize: procedure expose G.
  call GetCmdName
  call LoadRexxUtil
  return

/* end Initialize */

/*=== ScanArgsInit() ScanArgs initialization exit routine ===*/

ScanArgsInit: procedure expose G. cmdTail swCtl keepQuoted

  /* Preset defaults */
  G.!ArgList.0 = 0			/* Reset arg count */

  /* Configure scanner */
  swCtl = ''				/* Switches that take args, append ? if arg optional */
  keepQuoted = 0			/* Set to 1 to keep arguments quoted */

  return

/* end ScanArgsInit */

/*=== ScanArgsSwitch() ScanArgs switch option exit routine ===*/

ScanArgsSwitch: procedure expose G. curSw curSwArg

  select
  when curSw == 'h' | curSw == '?' then
    call ScanArgsHelp
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

  i = G.!ArgList.0 + 1
  G.!ArgList.i = curArg
  G.!ArgList.0 = i

  return

/* end ScanArgsArg */

/*=== ScanArgsTerm() ScanArgs scan end exit routine ===*/

ScanArgsTerm: procedure expose G.

  if G.!ArgList.0 = 0 then do
    G.!ArgList.1 = 'STDIN'
    G.!ArgList.0 = 1
  end
  return

/* end ScanArgsTerm */

/*=== ScanArgsHelp() Display ScanArgs usage help exit routine ===*/

ScanArgsHelp:
  say
  say 'Convert ipformat output to more readable text.'
  say
  say 'Usage:' G.!CmdName '[-h] [-V] [-?] [filename...]'
  say
  say '  -h -?     Display this message'
  say '  -V        Display version number and quit'
  say
  say '  filename  File containing ipformat output'
  exit 255

/* end ScanArgsHelp */

/*=== ScanArgsUsage(message) Report Scanargs usage error exit routine ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \== '' then
    say msg
  say 'Usage:' G.!CmdName '[-h] [-V] [-?] [filename...]'
  exit 255

/* end ScanArgsUsage */

/*==============================================================================*/
/*=== SkelRexxFunc standards - Delete unused - Move modified above this mark ===*/
/*==============================================================================*/

/*=== CatchError() Catch condition; return ErrCondition ===*/

CatchError:
  ErrCondition = condition('C')
  return
/* end CatchError */

/*==========================================================================*/
/*=== SkelRexx standards - Delete unused - Move modified above this mark ===*/
/*==========================================================================*/

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
