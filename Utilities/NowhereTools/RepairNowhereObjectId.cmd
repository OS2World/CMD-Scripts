/* RepairNowhereObjectId - Try to repair Nowhere folder object id
   $Id: $

   Copyright (c) 2009 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   27 Oct 09 SHL Baseline

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Gbl.!Version = '0.1'

Main:

  parse arg cmdLine
  call ScanArgs cmdLine
  drop cmdLine

  dirName = SysBootDrive() || '\Nowhere'

  /* L: MM-DD-YYYY HH:MM Size ADHRS Name */
  call SysFileTree dirName, 'FileList', 'DL'

  if RESULT \= 0 then
    say 'SysFileTree' dirName 'failed'
  else if FileList.0 = 0 then
    say 'SysFileTree can not find' dirName
  else do
    say
    /* Try to allow EA update */
    if Is4OS2() then
      'attrib /D -r -s -h' dirName
    else
      'attrib -r -s -h' dirName
    objectId = '<WP_NOWHERE>'
    setup = 'OBJECTID=' || objectId || ';'
    ok = SysSetObjectData(dirName, setup)
    if Is4OS2() then
      'attrib /D +s +h' dirName
    else
      'attrib +s +h' dirName
    if \ ok then
      say 'Can not set' dirName 'object id to' objectId || '.  Get help.'
    else do
      say 'SysSetObjectData claims to have set the' dirName 'object id to' objectId || '.'
      ok = WPToolsQueryObject(objectId, 'className', 'title', 'setup', 'location')
      if ok \= 1 then do
	say 'WPToolsQueryObject still can not access' objectId || '.'
	say 'The object id change appears to have failed.'
      end
      else do
        say
        say '<WP_NOWHERE> now has the current settings:'
        say 'Object handle:' objectId
        say 'Class name   :' className
        say 'Title        :' title
        say 'Location     :' location
        say 'Setup string :' setup
      end
    end
  end

  exit

/* end main */

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
  call ScanArgsUsage 'option '''curArg''' unexpected'
  return

/* end ScanArgsArg */

/*=== ScanArgsTerm() ScanArgs scan end exit routine ===*/

ScanArgsTerm: procedure expose Gbl.
  return

/* end ScanArgsTerm */

/*=== ScanArgsUsage(message) Report Scanargs usage error exit routine ===*/

ScanArgsUsage:
  parse arg msg
  say
  if msg \== '' then
    say msg
  say 'Usage:' Gbl.!CmdName '[-h] [-V] [-?]'
  exit 255

/* end ScanArgsUsage */

/*=== ScanArgsHelp() Display ScanArgs usage help exit routine ===*/

ScanArgsHelp:
  say
  say 'Repaire Nowhere folder object id.'
  say
  say 'Usage:' Gbl.!CmdName '[-h] [-V] [-?]'
  say
  say '  -h -?         Display this message'
  say '  -V            Display version'
  exit 255

/* end ScanArgsHelp */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== Is4OS2(alwaysReturn) Return true if 4OS2 running ===*/

Is4OS2: procedure expose Gbl.
  call setlocal
  '@set X=%@eval[0]'
  yes = value('X',, 'OS2ENVIRONMENT') = 0
  call endlocal
  return yes				/* if running under 4OS2 */

/* end Is4OS2 */

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
