/* DumpTrapScreen.cmd: Dump trap registers screens from dump image.
   Dump image may be diskette 1 of a trap set or a trapdump file on disk

   Copyright (c) 2000, 2004 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   $TLIB$: $ &(#) %n - Ver %v, %f $
   TLIB: $ $

   Revisions	14 Nov 00 SHL Baseline
		11 Dec 00 SHL Avoid dummy screen
		22 Dec 00 SHL Relax locate logic
		26 Dec 01 SHL Report internal revision
		26 Mar 03 SHL Look for ##[0-9A-F]
		10 Apr 03 SHL Handle truncated dumps nicer
		12 Oct 04 SHL Show version with dump output
*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Gbl.!Version = '0.4'

Main:

  parse arg cmdTail

  if cmdTail = '' then
    call ScanArgsHelp

  Gbl.!fDebug = 0
  Gbl.!fCapture = 0
  Gbl.!DumpFile = ''

  do while cmdTail \= ''
    parse var cmdTail s cmdTail
    cmdTail = strip(cmdTail)
    if left(s, 1) = '-' then do
      s = substr(s, 2)
      select
      when s = '?' | s = 'h' then
	call ScanArgsHelp
      when s = 'd' then
	Gbl.!fDebug = 1
      when s = 'c' then
	Gbl.!fCapture = 1
      when s == 'V' then do
	say Gbl.!CmdName Gbl.!Version
	exit
      end
      otherwise
	call ScanArgsUsage 'Option' s ' unknown'
      end
    end
    else
      Gbl.!DumpFile = s
  end

  if Gbl.!DumpFile = '' then
    call ScanArgsUsage 'Dump file name required'

  Gbl.!Printables = xrange(' ', '7e'x) || '0d'x || '0a'x
  Gbl.!HexDigits = xrange('0', '9') || xrange('A', 'F')
  Gbl.!CrLf = '0d'x || '0a'x
  Gbl.!LfCr = '0a'x || '0d'x

  call ScanDumpFile

  exit

/* end main */

/*=== ScanDumpFile() Read dump file; find trap screens; write to stdout. ===*/

ScanDumpFile:

  if stream(Gbl.!DumpFile, 'C', 'QUERY EXISTS') == '' then do
    call Fatal Gbl.!DumpFile 'not found'
  end

  say Gbl.!CmdName 'v'Gbl.!Version' reading' Gbl.!DumpFile stream(Gbl.!DumpFile, 'C', 'QUERY DATETIME')

  /* Read in 1st 512KB of dump image */

  call stream Gbl.!DumpFile, 'C', 'OPEN READ'

  cBufMax = 512 * 1024

  signal off NOTREADY
  Gbl.!Buf = charin(Gbl.!DumpFile,, cBufMax)
  signal on NOTREADY name Error
  call stream Gbl.!DumpFile, 'C', 'CLOSE'

  cBufMax = length(Gbl.!Buf)		/* In case file short */

  /* If requested capture buffer image and quit */

  if Gbl.!fCapture then do
    sOutFile = 'tmpdump.out'
    call SysFileDelete sOutFile
    call charout sOutFile, Gbl.!Buf
    call charout sOutFile
    say 'Dump file header captured to' sOutFile'.  Exiting.'
    exit
  end

  do forever

    /* Find next tag */
    cSelect = cBufMax
    cPound = pos("##", Gbl.!Buf)
    if cPound > 0 then do
      ch = substr(Gbl.!Buf, cPound + 2, 4)
      if verify(ch, Gbl.!HexDigits) = 0 then
	cSelect = min(cPound, cSelect)
    end
    cException = pos('Exception in', Gbl.!Buf)
    if cException > 0 then
      cSelect = min(cException, cSelect)
    cP1Eq = pos("P1=", Gbl.!Buf)
    if cP1Eq > 0 then
      cSelect = min(cP1Eq, cSelect)
    cC000 = pos("c000", Gbl.!Buf)
    if cC000 > 0 then
      cSelect = min(cC000, cSelect)
    cIRevision = pos("Internal revision", Gbl.!Buf)
    if cIRevision > 0 then
      cSelect = min(cIRevision, cSelect)

    if cSelect = cBufMax then
      leave				/* No more tags */

    Gbl.!Buf = substr(Gbl.!Buf, cSelect)	/* Dump non-printable prefix */

    if Gbl.!fDebug then
      say 'Selected 'cSelect':' """"substr(Gbl.!Buf, 1, 4)""""

    /* Dump line and format special as needed */
    select
    when cSelect = cPound then do
      say
      call DumpLines ''
    end
    when cSelect = cIRevision then do
      say
      call DumpLines ''
    end
    when cSelect = cException then do
      call FixLfCr
      call DumpLines ''
    end
    when cSelect = cC000 then do
      call DumpLines ''
      call DumpLines ''
    end
    otherwise
      call DumpLines ''
    end /* select */

  end /* forever */

  return

/* end ScanDumpFile */

/*=== DumpLines() Write printable area to stdout and find next printable ===*/

DumpLines: procedure expose Gbl.

  c = verify(Gbl.!Buf, Gbl.!Printables)	/* Find next non-printable */

  c = c - 1				/* Size printable range */

  if c < 1 then
   call Fatal 'Can not size print area'

  Gbl.!Area = substr(Gbl.!Buf, 1, c)	/* Isolate printable area */

  /* Ignore empty trap screens */
  if substr(Gbl.!Area, 1, 4) \= 'P1=X' then do
    if pos('CS:EIP', Gbl.!Area) \= 0 then do
      say				/* Give some separation */
    end
    say Gbl.!Area
  end

  Gbl.!Buf = substr(Gbl.!Buf, c + 1)	/* Drop printable area */

  c = verify(Gbl.!Buf, Gbl.!Printables, 'M')	/* Find next printable */
  if c \= 0 then
    Gbl.!Buf = substr(Gbl.!Buf, c)	/* Drop non-printable area */

  return

/* end DumpLines */

/*=== FixLfCr() Correct backwards Lf/Cr ===*/

FixLfCr: procedure expose Gbl.

  c = pos(Gbl.!LfCr, Gbl.!Buf)
  do while c \= 0
    Gbl.!Buf = delstr(Gbl.!Buf, c, 2)
    Gbl.!Buf = insert(Gbl.!CrLf, Gbl.!Buf, c - 1)
    c = pos(Gbl.!LfCr, Gbl.!Buf, c + 2)
  end

  return

/* end FixLfCr */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose Gbl.

  call LoadRexxUtil
  call GetCmdname
  return

/* end Initialize */

/*=== ScanArgsUsage(message) Report usage error ===*/

ScanArgsUsage:

  parse arg szMsg
  say szMsg
  say 'ScanArgsUsage:' Gbl.!CmdName '[-h] [-d] [-c] [-V] trapdumpfile'
  exit 255

/* end ScanArgsUsage */

/*=== ScanArgsHelp() Display usage help ===*/

ScanArgsHelp:
  say
  say 'Usage:' Gbl.!CmdName '[-h] [-d] [-c] [-V] trapdumpfile'
  say
  say ' -c            Write dump header to tmpdump.out'
  say ' -d            Display debug info'
  say ' -h            Display this message'
  say ' -V            Display version'
  say
  say ' trapdumpfile  Trap dump file to parse'
  exit 255

/* end ScanArgsHelp */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*========================================================================== */
/*=== SkelRexx standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== Error() Report ERROR, FAILURE etc. and exit ===*/

Error:
  say
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' thisCmd
  if 'CONDITION'('C') == 'SYNTAX' & 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error' RC':' 'ERRORTEXT'(RC)
  say 'Source =' 'SOURCELINE'(SIGL)
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
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at' SIGL 'of' thisCmd
  say 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
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
