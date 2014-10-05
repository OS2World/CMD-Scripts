/* RepointRepository - Rewrite CVS Root and Repository to point at location
		       Usage -? for help

   Copyright (c) 2001, 2008 Steven Levine and Associates, Inc.
   All rights reserved.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

   Based on code
   originally written by Markus Montkowski
   and patched for general use by Ulrich M”ller
   and tweaked more by me

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

   25 May 01 SHL Baseline
   10 May 04 SHL Rework messages
   22 Jul 04 SHL Add ext support
   21 May 06 SHL Avoid spurious Repository rewrites
   19 Jan 07 SHL Make module argument optional
   19 Jan 07 SHL Clean up for public use
   20 Jan 07 SHL Avoid death when module name given
   26 Jun 08 SHL Avoid death by missing NL with Classic REXX

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

Main:

  call Initialize

  Gbl.!Version = '0.2'

  Gbl.!Update = 0
  CvsRoot = ''
  CvsModule = ''

  parse arg cmdTail

  do while cmdTail \= ''

    parse var cmdTail curArg cmdTail

    if left(curArg, 1) = '-' then do
      curArg = ToLower(curArg)
      if curArg = '-h' | curArg = '-?' then
	call ScanArgsHelp
      else if curArg = '-u' then
	Gbl.!Update = 1
      else
	call ScanArgsUsage curArg 'unexpected'
    end
    else do
      if CvsRoot = '' then
	CvsRoot = curArg
      else if CvsModule = '' then
	CvsModule = curArg
      else
	call ScanArgsUsage curArg 'unexpected'
    end
  end

  if CvsRoot = '' then do
      call ScanArgsUsage 'CvsRoot required'
      exit
  end

  i = pos(':', CvsRoot, 2)

  if i = 0 then
    call ScanArgsUsage 'Expected trailing :'

  ServerType = left(CvsRoot, i)
  theRest = substr(CvsRoot, i + 1)

  if ServerType \= ':local:' & ServerType \= ':pserver:' & ServerType \= ':ext:' then
    call ScanArgsUsage 'Expected :pserver: :ext: or :local:'

  i = pos('@', theRest)

  if i \= 0 then do
    UserName = left(theRest, i - 1)
    theRest = substr(theRest, i + 1)
  end
  else do
    UserName = value('USER',,'OS2ENVIRONMENT')
    if UserName \= '' then do
      say 'Please enter UserName:'
      parse pull UserName .
      if length(UserName) = 0 then do
	say 'No Username exiting'
	exit -1
      end
    end
  end

  if ServerType \= ':local:' then do
    i = pos(':', theRest)
    if i \= 0 then do
      CvsHost = left(theRest, i - 1)
      theRest = substr(theRest, i + 1)
    end
    else do
      say 'Please enter CVS hostname:'
      parse pull CvsHost
      if CvsHost = '' then do
	say 'No CvsHost exiting'
	exit -1
      end
    end
  end

  if theRest \= '' then do
    CvsPath = theRest
  end
  else do
      say 'Please enter Respository pathname:'
      parse pull CvsPath
      if CvsPath = '' then do
	say 'No CvsPath exiting'
	exit -1
      end
  end

  if ServerType \= ':local:' then
    CvsRoot = ServerType || UserName'@'CvsHost':'CvsPath
  else
    CvsRoot = ServerType || CvsPath

  say 'New CVSROOT='CvsRoot

  if CvsModule = '' then
    say 'No Module name supplied.  CVS/Repository files will not be scanned.'
  else
    say 'New Module='CvsModule

  call DoRootFiles

  if CvsModule \== '' then
    call DoRepFiles

  say
  if Gbl.!Update then
    say 'CVS control files updated'
  else
    say '* Scan mode.  No files changed. Use -u to enable rewrite *'

  say
  if Gbl.!Update then do
    say RootsChanged 'of' RootFiles.0 'Root files changed'
    if CvsModule \== '' then
      say RepsChanged 'of' RepFiles.0 ' Repository files changed'
  end
  else do
    say 'Need to change' RootsChanged 'of' RootFiles.0 'Root files'
    if CvsModule \== '' then
      say 'Need to change' RepsChanged 'of' RepFiles.0 'Repository files'
  end

  exit 0

  /* end main */

/*=== DoRootFiles() Scan/update Root files ===*/

DoRootFiles: procedure expose Gbl. CvsRoot RootFiles. RootsChanged

  say
  say 'Scanning' directory() 'for Root files'

  call SysFileTree 'Root', 'RootFiles', 'FS'

  say ' Found' Rootfiles.0 'files'
  say

  RootsChanged = 0

  do i = 1 to RootFiles.0
    File = substr(Rootfiles.i,38)
    call on NOTREADY name CatchError	/* Avoid death on missing NL */
    oldRoot = linein(File)
    signal on NOTREADY name Error
    call stream File, 'C', 'CLOSE'

    say 'Checking' File
    if CvsRoot \= oldRoot then do
      if Gbl.!Update then do
	call SysFileDelete File
	call lineout File, CvsRoot
	call lineout File
      end
      say ' rewriting:' oldRoot
      say '        to:' CvsRoot
      say
      RootsChanged = RootsChanged + 1
    end
  end /* do Root */
  return

/* end DoRootFiles */

/*=== DoRepFiles() Scan/update Root files ===*/

DoRepFiles: procedure expose Gbl. CvsModule RepsChanged RepFiles.

  say
  say 'Scanning' directory() 'for Repository files...'

  call SysFileTree 'Repository', 'RepFiles', 'FS'

  say ' Found' Repfiles.0 ' files'
  say

  RepsChanged = 0

  /* Relative repository path is Repository file path name less prefix and suffix
     Prefix is directory path and trailing slash
     Suffix is \CVS\Repository
  */
  PrefixLen = length(directory()'\')
  SuffixLen = length('\CVS\Repository')

  do i = 1 to RepFiles.0

    File = substr(Repfiles.i, 38)
    say 'Checking ' File

    call on NOTREADY name CatchError	/* Avoid death on missing NL */
    oldRepository = linein(File)
    signal on NOTREADY name Error
    call stream File, 'C', 'CLOSE'

    if length(File) > PrefixLen + SuffixLen then
      newDir = CvsModule'\'substr(File, PrefixLen + 1, length(File) - PrefixLen - SuffixLen)
    else
      newDir = CvsModule
    newRepository = UnixSlash(newDir)
    if left(newRepository, 2) == './' then
      newRepository = substr(newRepository, 3)	/* Normalize */

    if oldRepository \= newRepository then do
      if Gbl.!Update then do
	call SysFileDelete File
	call lineout File, newRepository, 1
	call lineout File
      end
      say ' rewriting:' oldRepository
      say '        to:' newRepository
      say
      RepsChanged = RepsChanged + 1
    end

  end /* do Repository */

  return

/* end DoRepFiles */

/*=== Initialize() Intialize globals ===*/

Initialize: procedure expose Gbl.

  call GetCmdName
  call LoadRexxUtil

  Gbl.!Debug = 0
  Gbl.!Verbose = 0

  return

/* end Initialize */

/*=== ScanArgsUsage(message) Report usage error ===*/

ScanArgsUsage:

  parse arg msg
  say msg
  say 'Usage:' Gbl.!CmdName '[-h] [-u] CvsRoot [CvsModule]'
  exit 255

/* end ScanArgsUsage */

/*=== ScanArgsHelp() Display usage help ===*/

ScanArgsHelp:

  say
  say 'Adjust CVS Repository and Root files to point to new'
  say 'repository location.  Run from top of CVS sandbox.'
  say
  say 'Usage:' Gbl.!CmdName '[-h] [-u] CvsRoot [CvsModule]'
  say
  say ' -h         Display this message.'
  say ' -u         Update files.  Otherwise just scan and report.'
  say
  say ' CvsRoot    New repository location in the form'
  say '            :pserver:username@hostname:pathname'
  say '            :pserver:guest@cvs.netlabs.org:/netlabs.cvs/odin32xp'
  say '            :local:pathname'
  say '            :local:d:/DevData/CVSRepository'
  say '            :ext:pathname'
  say '            :ext:/usr/local/cvsroot'
  say '            %CVSROOT%'
  say
  say ' CvsModule  New module name.  Omit to leave module unchanged.'
  say

  exit 255

/* end ScanArgsHelp */

/*=== UnixSlash() convert OS/2 backslash to UNIX slash ===*/

UnixSlash: procedure

 parse arg string
 return translate( string, '/', '\')

/* end UnixSlash */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== CatchError() Catch condition; return ErrCondition ===*/

CatchError:
  ErrCondition = condition('C')
  return

/* end CatchError */

/*=== ToLower(s) Convert to lower case ===*/

ToLower: procedure
  parse arg s
  return translate(s, xrange('a', 'z'), xrange('A', 'Z'))

/* end ToLower */

/*========================================================================== */
/*=== SkelRexx standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== Error() Report ERROR, FAILURE etc. and exit ===*/

Error:
  say
  parse source . . cmd
  say 'CONDITION'('C') 'signaled at' cmd 'line' SIGL'.'
  if 'CONDITION'('D') \= '' then
    say 'REXX reason =' 'CONDITION'('D')'.'
  if 'CONDITION'('C') == 'SYNTAX' & 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error =' RC '-' 'ERRORTEXT'(RC)'.'
  else if 'SYMBOL'('RC') == 'VAR' then
    say 'RC =' RC'.'
  say 'Source =' 'SOURCELINE'(SIGL)

  if 'CONDITION'('I') \== 'CALL' | 'CONDITION'('C') == 'NOVALUE' | 'CONDITION'('C') == 'SYNTAX' then do
    trace '?A'
    say 'Exiting.'
    call 'SYSSLEEP' 2
    exit 'CONDITION'('C')
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
