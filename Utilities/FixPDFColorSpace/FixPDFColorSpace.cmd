/* FixPDFColorSpace: Fix up PDFs to avoid Color Space error reports

   Copyright (c) 2002, 2003 Julian Thomas
   Copyright (c) 2002, 2003 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

   Revisions	15 Feb 02 SHL - Baseline
		08 Apr 03 SHL - Adapt from Julian Thomas's fixpdf.cmd
		01 Aug 03 SHL - Show offsets in hex too
		01 Aug 03 SHL - Ensure matched on correct object
		02 Aug 03 SHL - Ensure cmd.exe compatible
		04 Aug 03 SHL - Correct -V and usage

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Gbl.!Version = '0.5'

Main:

  parse arg CmdLine
  call ScanArgs CmdLine
  drop CmdLine

  do iArg = 1 to Gbl.!aArgs.0

    WildCard = Gbl.!aArgs.iArg

    /* Format options */
    /* O: Name */
    /* TL: YYYY-MM-DD HH:MM:SS Size ADHRS Name */
    call SysFileTree WildCard, 'aFiles', 'FTL'
    if RESULT \= 0 then
      call Fatal 'SysFileTree' WildCard 'failed'

    if aFiles.0 = 0 then do
      call Fatal WildCard 'not found'
    end
    else do
      do iFile = 1 to aFiles.0
	call DoOne aFiles.iFile
      end /* iFile */
    end

  end /* iArg */

  exit

/* end main */

/*=== DoOne(fileInfo) Read PDF file.  Drop colorspace stuff ===*/

DoOne:

  parse arg FileInfo
  /* TL: YYYY-MM-DD HH:MM:SS Size ADHRS Name */
  parse var FileInfo fileDate fileTime fileBytes fileAttrib fileName
  drop FileInfo

  fileName = strip(fileName)

  if stream(fileName, 'C', 'QUERY EXISTS') == '' then
    call Fatal fileName 'not found'

  cBufMax = stream(fileName, 'C', 'QUERY SIZE')

  if Gbl.!fVerbose then do
    say 'Reading' fileName stream(fileName, 'C', 'QUERY DATETIME'),
	'0x'd2x(cBufMax) 'bytes'
  end

  call stream fileName, 'C', 'OPEN READ'

  Buf = charin(fileName,, cBufMax)

  call stream fileName, 'C', 'CLOSE'

  /* Scan and edit colorspace settings
     1. find each "[ /ICCBased xxx yyy R ]",
     2. find object xxx yyy obj<< /N ? /Alternate /DeviceRGB ...
     3. If /N 1, replace "[ /ICCBased xxx yyy R ]" with "/DeviceGray"
	If /N 3, replace "[ /ICCBased xxx yyy R ]" with "/DeviceRGB"
	If /N 4, replace "[ /ICCBased xxx yyy R ]" with "/DeviceCMYK"
     4. Use enough blanks to exactly preserve length, thus no need to update xref table

     support whitespace equivalency
 */

  iccb='/ICCBased '

  fix. = ''
  fix.1="/DeviceGray"
  fix.3="/DeviceRGB"
  fix.4="/DeviceCMYK"

  icc.0 = 0				/* Number of hits */

  /* Search for /ICCBased */
  i = 1
  do forever
    slash = pos(iccb,Buf,i)
    if slash = 0 then
      leave

    j = icc.0 + 1
    icc.0 = j

    fixpoint = pos('[', Buf, slash-8)
    icc.j = fixpoint		/* Record [ location */
    k = pos(']', Buf, slash + 10)
    i = k
    len.j = k - fixpoint + 1	/* Record length */
    stuff = substr(Buf, fixpoint, len.j)
    obj.j = stuff		/* Record command string */
    icc.0 = j
    j = j + 1
  end

  if icc.0 = 0 then do
    say 'Warning: found nothing to change in' fileName
    return
 end

  if Gbl.!fVerbose then
    say 'Found' icc.0 '/ICCBased instances to edit'

  do j = 1 to icc.0

    if Gbl.!fVerbose then
      say 'Processing /ICCBased at 0x'd2x(icc.j)

    /* Have:
	 [ /ICCBased xxx yyy R ]
       Extract object id xxx yyy
     */
    z = pos('/',obj.j)
    obj = substr(obj.j, z + 10, 12)
    z = pos('R',obj)
    /* Find obj definition of form:
	 xxx yyy obj<< /N 3 /Alternate /DeviceRGB ...
    */
    obj = left(obj, z - 1) || 'obj'
    k = 1
    do forever
      k = pos(obj, Buf, k)
      if k = 0 then
	call Fatal obj 'definition not found'
      /* Ensure at start of object definition */
      if k = 1 then
	leave
      c = substr(Buf,k - 1, 1)
      if c <= ' ' then
	leave
      k = k + 1
    end
    n = pos('/N', Buf, k)
    if n = 0 then
      call Fatal 'expected to find /N in' obj' definition at' d2x(k)
    nx = substr(Buf, n + 3, 1)

    if fix.nx = '' then
      call Fatal 'don''t know how to translate /N' nx 'at 0x'd2x(n)

    if Gbl.!fVerbose then do
      say 'Found' obj 'at 0x'd2x(n)
    end

    fix = left(fix.nx,len.j)
    Buf = left(Buf,icc.j - 1) || fix || substr(Buf,icc.j + len.j)
    if Gbl.!fVerbose then do
      sz = translate(obj.j, '', x2c('0a0d'))
      say 'Replaced' sz 'with' fix 'at 0x'd2x(n)
    end

  end /* icc.0 */

  baseName = filespec('N', fileName)

  if Gbl.!TmpDir = '' then
    call Fatal 'TMP must be defined in environment'

  tmpFileName = Gbl.!TmpDir || 'Tmp' || baseName
  backupFileName = Gbl.!TmpDir || baseName

  if translate(backupFileName) = translate(fileName) then
    call Fatal fileName 'found in TMP directory - please move elsewhere'

  if stream(tmpFileName, 'C', 'QUERY EXISTS') == '' then
    call SysFileDelete tmpFileName

  call charout tmpFileName, Buf
  call stream tmpFileName, 'C', 'CLOSE'

  if Gbl.!fTest then do
      say '* Original' fileName 'unchanged'
      say '* Test results are in' tmpFileName
  end
  else do
    if Gbl.!fVerbose then do
      '@echo on'
      redirect = ''
    end
    else do
      '@echo off'
      redirect = '>nul 2>&1'
    end
    'copy' fileName backupFileName redirect
    'copy' tmpFileName fileName redirect
    if Gbl.!fVerbose then
      say 'call SysFileDelete' tmpFileName
    call SysFileDelete tmpFileName
    if Gbl.!fVerbose then do
      say '     1 files(s) deleted.'
      '@echo off'
    end
  end

  return

/* end DoOne */

/*=== DspObj(offset) Display object ===*/

DspObj: procedure expose Gbl.

  return

/* end DspObj */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose Gbl.

  call GetCmdName
  call LoadRexxUtil
  call GetTmpDir

  return

/* end Initialize */

/*=== ScanArgs(args) scan command line arguments and switches ===*/

ScanArgs: procedure expose Gbl.

  /* Evaluate arguments - override
     Return Gbl.!f*. and Gbl.!aArgs. etc.
  */

  parse arg szRest
  szRest = strip(szRest)

  if szRest == '' then
    call UsageHelp

  /* Set defaults */
  Gbl.!fDebug = 0			/* Debug messages */
  Gbl.!fTest = 0			/* Run in test mode */
  Gbl.!fVerbose = 0			/* Verbose messages */
  Gbl.!aArgs.0 = 0			/* Init arg count */

  /* Prepare scanner */
  szSwCtl = ''				/* Switches that take args */
  fKeepQuoted = 0			/* Set to 1 to keep arguments quoted */
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
	    leave				/* No, done */
	  szArg = szArg || szQ		/* Append quote */
	  if fKeepQuoted then
	    szArg = szArg || szQ		/* Append escaped quote */
	  parse var szRest (szQ) szRest
	end /* do */
	if fKeepQuoted then
	  szArg = szQ || szArg || szQ	/* requote */
      end /* if quoted */
    end

    /* If switch buffer empty, refill */
    if szSw == '' then do
      if left(szArg, 1) == '-' & szArg \== '-' then do
	if fSwEnd then
	  call Usage 'switch '''szArg''' unexpected'
	else if szArg == '--' then
	  fSwEnd = 1
	else do
	  szSw = substr(szArg, 2)	/* Remember switch string */
	  szArg = ''			/* Mark empty */
	  iterate			/* Refill arg buffer */
	end
	parse var szRest szArg szRest
      end
    end

    /* If switch in progress */
    if szSw \== '' then do
      sz = left(szSw, 1)		/* Next switch */
      szSw = substr(szSw, 2)		/* Drop from pending */
      /* Check switch requires argument */
      if pos(sz, szSwCtl) \= 0 then do
	if szSw \== '' then do
	  szOpt = szSw			/* Use rest of switch string for switch argument */
	  szSw = ''
	end
	else if szArg \== '' & left(szArg, 1) \= '-' then do
	  szOpt = szArg			/* Use arg string for switch argument */
	  szArg = ''			/* Mark empty */
	end
	else
	  call Usage 'Switch' sz 'requires argument'
      end
      select
      when sz == 'd' then
	Gbl.!fDebug = 1
      when sz == 'h' | sz == '?' then
	call UsageHelp
      when sz == 't' then
	Gbl.!fTest = 1
      when sz == 'v' then
	Gbl.!fVerbose = 1
      when sz == 'V' then do
	say Gbl.!CmdName Gbl.!Version
	exit
      end
      otherwise
	call Usage 'switch '''sz''' unexpected'
      end /* select */
    end /* if switch */

    /* If arg */
    else if szArg \== '' then do
      fSwEnd = 1			/* No more switches */
      /* Got non switch arg */
      i = Gbl.!aArgs.0 + 1
      Gbl.!aArgs.i = szArg
      Gbl.!aArgs.0 = i
      szArg = ''
    end

  end /* while szRest */

  if Gbl.!aArgs.0 = 0 then
    call Usage 'PDF file name missing'

  return

/* end ScanArgs */

/*=== Usage(message) Report usage error ===*/

Usage:

  parse arg msg
  say msg
  say 'Usage:' Gbl.!CmdName '[-c] [-h] [-d] [-c] [-V] pdffile'
  exit 255

/* end Usage */

/*=== UsageHelp() Display usage help ===*/

UsageHelp:

  say
  say 'Usage:' Gbl.!CmdName '[-h] [-d] [-c] [-V] pdffile...'
  say
  say ' -d            Display debug messages'
  say ' -h            Display this message'
  say ' -t            Test mode - orginal unchanged'
  say ' -v            Display progress messages'
  say ' -V            Display version'
  say
  say ' pdffile       PDF file to edit'
  say '               Backup of original saved to %TMP% directory'

  exit 255

/* end UsageHelp */

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
  parse arg Msg
  call lineout 'STDERR', Msg
  do 10
    f=random(262,1047)
    d=random(100,200)
    call beep f,d
  end
  exit 254

/* end Fatal */

/*=== GetCmdName() Get script name, set Gbl.!CmdName ===*/

GetCmdName: procedure expose Gbl.
  parse source . . CmdName
  CmdName = filespec('N', CmdName)		/* Chop path */
  c = lastpos('.', CmdName)
  if c > 1 then
    CmdName = left(CmdName, c - 1)		/* Chop extension */
  Gbl.!CmdName = translate(CmdName, xrange('a', 'z'), xrange('A', 'Z'))	/* Lowercase */
  return

/* end GetCmdName */

/*=== GetTmpDir() Get TMP dir name with trailing backslash, set Gbl. ===*/

GetTmpDir: procedure expose Gbl.
  TmpDir = value('TMP',,'OS2ENVIRONMENT')
  if TmpDir \= '' & right(TmpDir, 1) \= ':' & right(TmpDir, 1) \= '\' then
    TmpDir = TmpDir'\'				/* Stuff backslash */
  Gbl.!TmpDir = TmpDir
  return

/* end GetTmpDir */

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

/*=== ToLower(sz) Convert to lower case ===*/

ToLower: procedure
  parse arg sz
  return translate(sz, xrange('a', 'z'), xrange('A', 'Z'))

/* end ToLower */

/* The end */
