/* ShowNowhereFolders - Show contents of NoWhere directories
   $Id: $

   Copyright (c) 2002, 2009 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   03 Oct 02 SHL Baseline
   16 Apr 04 SHL Show <WP_NOWHERE>
   16 Apr 04 SHL Use SysBootDrive
   26 Oct 09 SHL Just warn if <WP_NOWHERE> does not exist
   27 Oct 09 SHL Tweak output format

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

  /* Show WP_NOWHERE object */
  call DoOneObject '<WP_NOWHERE>'

  say
  say '-------------------------------------------------------------'

  /* Show extra nowhere directories */

  fileSpec = SysBootDrive() || '\Nowhere*'
  /* L: MM-DD-YYYY HH:MM Size ADHRS Name */
  call SysFileTree fileSpec, 'FileList', 'DL'

  if RESULT \= 0 then
    call Fatal 'SysFileTree failed for' fileSpec || '.'
  else if FileList.0 = 0 then
    call Fatal 'SysFileTree found no directories matching' fileSpec || '.'
  else do
    do fileNdx = 1 to FileList.0
      say
      say 'Checking folder' FileList.fileNdx
      parse value FileList.fileNdx with dirDate dirTime dirBytes dirAttrib dirName
      dirName = strip(dirName)
      /* Sanity check */
      s = substr(dirAttrib, 2, 1)
      if s \= 'D' then
	call Fatal 'SysFileTree return non-directory for' fileSpec || '.'
      call ShowFolderContents dirName
    end /* fileNdx */
  end

  exit

/* end main */

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

/*=== ShowFolderContents() Show objects in object ===*/

ShowFolderContents: procedure expose Gbl.

  parse arg obj

  ok = WPToolsFolderContent(obj, 'Objects.')
  if ok \= 1 then
    say 'WPToolsFolderContent can not find the content of' obj || '.'
  else do
    do objNum = 1 to Objects.0
      call DoOneObject Objects.objNum
    end
  end

  return

/* end ShowFolderContents */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose Gbl.
  call GetCmdName
  call LoadRexxUtil
  call LoadWPTools
  return

/* end Initialize */

/*=== ScanArgs(Args) scan command line arguments and switches ===*/

ScanArgs: procedure expose Gbl.

  /* Evaluate arguments - override
     Return Gbl.!f*. and Gbl.!aArgs. etc.
  */

  parse arg szRest
  szRest = strip(szRest)

  /* Set defaults */
  Gbl.!fDebug = 0
  Gbl.!fTest = 0
  Gbl.!fVerbose = 0			/* Verbose messages */
  Gbl.!aArgs.0 = 0			/* Init arg count */

  /* Prepare scanner */
  szSwCtl = ''				/* Switches that take args */
  szArg = ''				/* Current argument string */
  szSw = ''				/* Current switch list */
  fSwEnd = 0				/* End of switches */

  do while szRest \== '' | szArg \== '' | szSw \== ''

    if szArg == '' then do
      /* Buffer empty, refill */
      szQ = left(szRest, 1)		/* Remember quote */
      if \ verify(szQ,'''"', 'M') then do
	parse var szRest szArg szRest	/* Not quoted */
      end
      else do
	/* Arg is quoted */
	szArg = ''
	do forever
	  /* Parse dropping quotes */
	  parse var szRest (szQ)szArg1(szQ) szRest
	  szArg = szArg || szArg1
		/* Check for escaped quote within quoted string (i.e. "" or '') */
	  if left(szRest, 1) \== szQ then
	    leave			/* No, done */
	  szArg = szArg || szQ		/* Append quote */
	  parse var szRest (szQ) szRest
	end /* do */
      end /* if quoted */
    end

    /* If switch buffer empty, refill */
    if szSw == '' then do
      if left(szArg, 1) == '-' then do
	if fSwEnd then
	  call ScanArgsUsage 'switch '''szArg''' unexpected'
	else if szArg == '--' then
	  fSwEnd = 1
	else
	  szSw = substr(szArg, 2)
	parse var szRest szArg szRest
      end
    end

    /* If switch in progress */
    if szSw \== '' then do
      sz = left(szSw, 1)		/* Next switch */
      szSw = substr(szSw, 2)		/* Drop from pending */
      if Gbl.!fDebug then
	say '* Switch' sz
      /* Check switch requires argument */
      if pos(sz, szSwCtl) \= 0 then do
	if szSw \== '' then do
	  szOpt = szSw
	  szSw = ''
	end
	else if szArg \== '' & left(szArg, 1) \= '-' then do
	  szOpt = szArg
	  parse var szRest szArg szRest
	end
	else
	  call ScanArgsUsage 'Switch' sz 'requires argument'
	if Gbl.!fDebug then
	  say '* Opt' szOpt
      end
      select
      when sz == 'd' then
	Gbl.!fDebug = 1
      when sz == 'h' | sz == '?' then
	call ScanArgsHelp
      when sz == 't' then
	Gbl.!fTest = 1
      when sz == 'V' then do
	say Gbl.!CmdName Gbl.!Version
	exit
      end
      otherwise
	call ScanArgsUsage 'switch '''sz''' unexpected'
      end /* select */
    end /* if switch */

    /* If arg */
    else if szArg \== '' then do
      fSwEnd = 1			/* No more switches */
      if Gbl.!fDebug then
	say '* Arg' szArg
      /* Got non switch arg */
      i = Gbl.!aArgs.0 + 1
      Gbl.!aArgs.i = szArg
      Gbl.!aArgs.0 = i
      szArg = ''
    end

  end /* while szRest */

  return

/* end ScanArgs */

/*=== ScanArgsUsage(message) Report usage error ===*/

ScanArgsUsage:
  parse arg msg
  say msg
  say 'ScanArgsUsage:' Gbl.!CmdName '[-d] [-h] [-t] [-v] [-V]'
  exit 255

/* end ScanArgsUsage */

/*=== ScanArgsHelp() Display usage help ===*/

ScanArgsHelp:

  say
  say 'ScanArgsUsage:' Gbl.!CmdName '[-d] [-h] [-t] [-v] [-V]'
  say
  say ' -d     Debug'
  say ' -h     Show this message'
  say ' -t     Test only'
  say ' -v     Verbose messages'
  say ' -V     Show version'

  exit 255

/* end ScanArgsHelp */

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

/* The end */
