/* ChkCfg.Cmd: Check CONFIG.SYS semantics

    Copyright (c) 1997 Steven Levine and Associates, Inc.
    All rights reserved.

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

    Revisions	07 Sep 97 SHL - Release
                07 Mar 98 SHL - Add arg logic
                29 Dec 98 SHL - Split ChkDir/ChkDirList logic
                05 Jan 01 SHL - Support Dir/File lists

   TBD  Add %N logic

*/

signal on ERROR
signal on FAILURE name Error
signal on HALT
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

fDebug = 0

call Initialize

parse arg szInFile szRest

if szRest \= '' then do
  say szRest 'unexpected'
  return
end  /* Do */

if szInFile == '' then
  szInFile = 'F:\CONFIG.SYS'

Main:

  say 'Reading' szInFile

  /* Scan and parse */

  cLines = 0

  if stream(szInFile, 'C', 'QUERY EXISTS') = '' then do
    return szInFile 'does not exist.'
  end

  call stream szInFile, 'C', 'OPEN READ'

  drop szCondition

  do while lines(szInFile) \= 0

    cLines = cLines + 1

    call on NOTREADY name CatchError	/* Avoid death on missing NL */
    szLine = linein(szInFile)
    signal on NOTREADY name Error

    call ChkLine szLine

  end /* while lines */

  call stream szInFile, 'C', 'CLOSE'

  say 'Read' cLines 'lines'

  exit

/* end main */

/*=== ChkDir(arg1, ...): Check single directory ===*/

ChkDir: procedure

  parse arg szPath

  /* Chop trailing / */
  if length(szPath) > 2 & right(szPath, 1) == '\' & right(szPath, 2) \== ':\' then
      szPath = substr(szPath, 1, length(szPath) - 1)

  szOld = directory()

  say ' 'szPath

  szNew = directory(szPath)

  call directory szOld

  if szNew == '' then do
    say ' * 'szPath 'is not a directory'
  end

  return

/* end ChkDir */

/*=== ChkDirFile(arg1, ...): Check dir/file name list ===*/

ChkDirFile: procedure

  parse arg sz

  do while length(sz) \= 0

    i = pos(';', sz)
    if i = 0 then do
      szFile = sz
      sz = ''
    end
    else do
      szFile = substr(sz, 1, i - 1)
      sz = substr(sz, i + 1)
    end

    say ' 'szFile

    if stream(szFile, 'C', 'QUERY EXISTS') = '' then do
      szOld = directory()

      szNew = directory(szFile)

      call directory szOld

      if szNew == '' then do
        say ' * 'szFile 'is not a directory or file'
      end
    end

  end

  return

/* end ChkDirFile */

/*=== ChkDirList(arg1, ...): Check directory name list ===*/

ChkDirList: procedure

  parse arg sz

  do while length(sz) \= 0

    i = pos(';', sz)
    if i = 0 then do
      szPath = sz
      sz = ''
    end
    else do
      szPath = substr(sz, 1, i - 1)
      sz = substr(sz, i + 1)
    end

    /* Chop trailing / */
    if length(szPath) > 2 & right(szPath, 1) == '\' & right(szPath, 2) \== ':\' then
        szPath = substr(szPath, 1, length(szPath) - 1)
    /* Chop NLS suffix */
    else if length(szPath) > 3 & right(szPath, 3) == '\%N' then
        szPath = substr(szPath, 1, length(szPath) - 3)

    szOld = directory()

    say ' 'szPath

    szNew = directory(szPath)

    call directory szOld

    if szNew == '' then do
      say ' * 'szPath 'is not a directory'
    end

  end

  return

/* end ChkDirList */

/*=== ChkFile(arg1, ...): Check file name list ===*/

ChkFile: procedure

  parse arg sz

  do while length(sz) \= 0

    i = pos(';', sz)
    if i = 0 then do
      szFile = sz
      sz = ''
    end
    else do
      szFile = substr(sz, 1, i - 1)
      sz = substr(sz, i + 1)
    end

    say ' 'szFile

    if stream(szFile, 'C', 'QUERY EXISTS') = '' then
      say ' * 'szFile 'is not a file'

  end

  return

/* end ChkFile */

/*=== ChkLine: ... ===*/

ChkLine: procedure expose fDebug

  parse arg szLine

  /* Set statements containing single directory name and no semicolon */

  szDirSet = ';BA2_CATALOG_PATH' ||,
             ';BA2_LOG_PATH' ||,
             ';BA2_SET_PATH' ||,
             ';CPE' ||,
             ';CPPHELP_INI' ||,
             ';CPPLOCAL' ||,
             ';CPPMAIN' ||,
             ';CPPWORK' ||,
             ';DMIPATH' ||,
             ';DSPPATH' ||,
             ';DSSDIR' ||,
             ';DSSPATH' ||,
             ';ETC' ||,
             ';GNUPLOT' ||,
             ';GS_LIB' ||,
             ';HOME' ||,
             ';I18NDIR' ||,
             ';IBMAV' ||,
             ';INIT' ||,
             ';IWFOPT' ||,
             ';LANINSTEP' ||,
             ';LOTUS_CLS' ||,
             ';NETVIEW_PATH' ||,
             ';OCRNOTES' ||,
             ';OCTAVE_HOME' ||,
             ';SMTMP' ||,
             ';SNMPDIR' ||,
             ';SVA_PATH' ||,
             ';TEMP' ||,
             ';TMP' ||,
             ';TMPDIR' ||,
             ';TMPS' ||,
             ';'

  /* Set statements containing single directory name and optional semicolon */

  /* fixme to exist */
  szDirOptSemiSet = ';' ||,
                    ';'

  /* Set statements containing directory lists */

  szDirListSet = ';BA2_CATALOG_PATH' ||,
                 ';BA2_LOG_PATH' ||,
                 ';BA2_SET_PATH' ||,
                 ';BHELP' ||,
                 ';BOOKSHELF' ||,
                 ';BPATH' ||,
                 ';CAT_HOST_BIN_PATH' ||,
                 ';CAT_HOST_SOURCE_PATH' ||,
                 ';CODELPATH' ||,
                 ';CPPLOCAL' ||,
                 ';DPATH' ||,
                 ';DSPPATH' ||,
                 ';EPMPATH' ||,
                 ';GLOSSARY' ||,
                 ';GS_FONTPATH' ||,
                 ';GS_LIB' ||,
                 ';HELP' ||,
                 ';I18NDIR' ||,
                 ';IMNDATACL' ||,
                 ';IMNDATASRV' ||,
                 ';IMNNLPSCL' ||,
                 ';IMNNLPSSRV' ||,
                 ';IMNWORKCL' ||,
                 ';IMNWORKSRV' ||,
                 ';INCLUDE' ||,
                 ';INFOPATH' ||,
                 ';IPFC' ||,
                 ';LIB' ||,
                 ';LITE_LOCALES' ||,
                 ';LOCPATH' ||,
                 ';LPATH' ||,
                 ';MMBASE' ||,
                 ';NLSPATH' ||,
                 ';NWDBPATH' ||,
                 ';PATH' ||,
                 ';PERL5LIB' ||,
                 ';PGPPATH' ||,
                 ';READIBM' ||,
                 ';SMINCLUDE' ||,
                 ';SOMBASE' ||,
                 ';SOMDDIR' ||,
                 ';SOMRUNTIME' ||,
                 ';ULSPATH' ||,
                 ';VBPATH' ||,
                 ';'

  /* Set statements containing file lists */
  szFileSet = ';BFILE' ||,
              ';COMSPEC' ||,
              ';OS2_SHELL' ||,
              ';RUNWORKPLACE' ||,
              ';SCFINDUTILITY' ||,
              ';SOMIR' ||,
              ';SYSTEM_INI' ||,
              ';TERMCAP' ||,
              ';TLIBCFG' ||,
              ';USER_INI' ||,
              ';'

  /* Set statements containing dir/file lists */
  szDirFileSet = ';CLASSPATH' ||,
              ';'

  iStart = FindNonWhite(szLine)         /* Skip leading */

  if iStart = 0 then
    return

  szRest = substr(szLine, iStart)

  iEnd = FindDelim(szRest)              /* Find delimiter */

  if iEnd = 0 then do
    szCmd = szRest
    szRest = ''
  end
  else do
    szCmd = substr(szRest, 1, iEnd - 1)
    szDelim = substr(szRest, iEnd, 1)
    szRest = substr(szRest, iEnd + 1)
  end

  szCmd = translate(szCmd)

  if fDebug then
    say 'CMD '''szCmd''''

  select
  when szCmd == 'CALL'  then
    nop                                 /* fixme to check */
  when szCmd == 'REM'  then
    nop
  when szCmd == 'RUN'  then
    nop                                 /* fixme to check */
  when szCmd == 'BASEDEV' then do
    nop                                 /* fixme to check */
  end
  when szCmd == 'DEVICE' then do
    nop                                 /* fixme to check */
  end
  when szCmd == 'LIBPATH' then do
    say
    say 'Checking LIBPATH'
    call ChkDirList szRest
    nop
  end
  when szCmd == 'SET' then do
    iEnd = FindDelim(szRest)
    if iEnd = 0 then do
      say 'Missing delimiter for' szLine
      exit
    end
    szSet = substr(szRest, 1, iEnd - 1)
    if fDebug then
      say '-> DEBUG' ''''szSet''''
    szRest = substr(szRest, iEnd)
    iEnd = FindNonWhite(szRest)
    if iEnd = 0 then do
      say 'Missing delimiter for' szLine
      exit
    end
    szDelim = substr(szRest, iEnd, 1)
    if szDelim \== '=' then do
      say 'Missing = for' szLine
      exit
    end
    szRest = substr(szRest, iEnd + 1)
    iEnd = FindNonWhite(szRest)
    if iEnd = 0 then do
      say 'Missing delimiter for' szLine
      exit
    end
    szRest = substr(szRest, iEnd)
    select
    when pos(';'szSet';', szDirListSet) \= 0
    then do
      say
      say 'Checking' szSet
      call ChkDirList szRest
    end
    when pos(';'szSet';', szDirSet) \= 0
    then do
      say
      say 'Checking' szSet
      call ChkDir szRest
    end
    when pos(';'szSet';', szFileSet) \= 0
    then do
      say
      say 'Checking' szSet
      call ChkFile szRest
    end
    when pos(';'szSet';', szDirFileSet) \= 0
    then do
      say
      say 'Checking' szSet
      call ChkDirFile szRest
    end
    otherwise do
      if fDebug then
        say
        say 'Skipped' szSet
    end /* otherwise */
    end /* select */
  end
  otherwise do
    if fDebug then
      say
      say 'Skipped' szLine
    nop
  end /* otherwise */
  end /* select */

  return

/* end ChkLine */

/*=== FindDelim(arg1, ...): Find blank, tab or = ===*/

FindDelim: procedure

  parse arg sz

  iBlank = pos(' ', sz)
  iTab = pos(x2c(9), sz)
  iEq = pos('=', sz)

  i = max(iBlank, iTab, iEq)
  if iBlank \= 0 then
    i = min(i, iBlank)
  if iTab \= 0 then
    i = min(i, iTab)
  if iEq \= 0 then
    i = min(i, iEq)

  return i

/* end FindDelim */

/*=== FindWhite(arg1, ...): Find blank, tab or = ===*/

FindWhite: procedure

  parse arg sz

  iBlank = pos(' ', sz)
  iTab = pos(x2c(9), sz)

  i = max(iBlank, iTab)
  if iTab \= 0 then
    i = min(i, iTab)

  return i

/* end FindWhite */

/*=== FindNonWhite(arg1, ...): Findnext Non blank or tab ===*/

FindNonWhite: procedure

  parse arg sz

  do i = 1 to length(sz)
    ch = substr(sz, i, 1)
    if ch \= ' ' & ch \= x2c(9) then
      leave
  end

  if i > length(sz) then
    i = 0

  return i

/* end FindNonWhite */

/*=== Help: Display help ===*/

Help:

  say 'Usage: ChkCfg arg....'

  return

/* end Help */

/*=== Usage: ... ===*/

Usage:

  parse arg szMsg

  say szMsg

  call Help

  exit 255

/* end Usage */

/*====================================================== */
/*=== Common Code - Delete unused, but do not modify === */
/*====================================================== */

/*=== AskYNQ(szPrompt): returns 0=No, 1=Yes, 2=Quit ===*/

AskYNQ: procedure

  parse arg sz

  if sz = '' then
    sz = 'Continue'
  call charout ,sz '(y/n/q) ? '
  do forever
    key = translate(SysGetKey('NOECHO'))
    if key = 'Y' | key = 'N' then do
      call charout ,key
      if key = 'Y' then
        x = 0
      else
        x = 1
      leave
    end
    if key = 'Q' | c2x(key) = '1B' then do
      say
      x = 2
    end
  end

  return x

/* end AskYNQ */

/*=== CatchError: Catch condition for user ===*/

CatchError:

  szCondition = condition('C')
  return

/* end CatchError */

/*=== Error: Trap ERROR, FAILURE etc. conditions ===*/

Error:

  /*=== Returns szCondition or Exits ===*/

  say
  parse source . . szThisCmd
  say condition('C') 'signaled at' SIGL 'of' szThisCmd
  drop szThisCmd
  say 'Source =' sourceline(SIGL)
  call SysSleep 2
  if condition('I') = 'CALL' then do
    szCondition = condition('C')
    say 'Returning'
    return
  end
  else do
    trace '?A'
    say 'Exiting'
    call SysSleep 2
    exit 255
  end

/* end Error */

/*=== Halt: Trap HALT condition ===*/

Halt:

  /*=== Returns szCondition or Exits ===*/

  say
  parse source . . szThisCmd
  say condition('C') 'signaled at' SIGL 'of' szThisCmd
  drop szThisCmd
  say 'Source = ' sourceline(SIGL)
  call SysSleep 2
  if condition('I') = 'CALL' then do
    szCondition = condition('C')
    say 'Returning'
    return
  end
  else do
   say 'Exiting'
   exit
  end

/* end Halt */

/*=== Initialize: Intialize globals ===*/

Initialize:

call LoadFuncs

parse source . . szThisCmd

szTmpDir = value('TMP',,'OS2ENVIRONMENT')
if szTmpDir \= '' & right(szTmpDir, 1) \= ':' & right(szTmpDir, 1) \= '\' then
  szTmpDir = szTmpDir'\'

return

/* end Initialize */

/*=== LoadFuncs: Load fuctions ===*/

LoadFuncs:

/* Add all Rexx functions */
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  if RESULT then do
    say 'Cannot load SysLoadFuncs'
    exit
  end
  call SysLoadFuncs
end /* end do */

return

/* end LoadFuncs */

/*=== ReadFile2Stem(FileName, Stem): Read file into stem variable ===*/

ReadFile2Stem:

  if arg() \= 2 | \ arg(1, 'E') | \ arg(2, 'E') then do
    say 'ReadFile2Stem: expected 2 arguments'
    signal Error
  end

  if stream(arg(1), 'C', 'QUERY EXISTS') = '' then do
    return 'ReadFile2Stem:' arg(1) 'does not exist.'
  end

  rf2sPath = arg(1)
  call stream rf2sPath, 'C', 'OPEN READ'

  rf2sStem = arg(2)
  rf2sLine = 0

  drop szCondition
  do while lines(rf2sPath) \= 0
    rf2sLine = rf2sLine + 1
    call on NOTREADY name CatchError	/* Avoid death on missing NL */
    sz = linein(rf2sPath)
    signal on NOTREADY name Error
    interpret rf2sStem'.'rf2sLine' = sz'
    if symbol('szCondition') = 'VAR' then
      leave			/* Last line missing NL */
  end
  interpret rf2sStem'.0 = 'rf2sLine
  call stream rf2sPath, 'C', 'CLOSE'

  drop rf2sPath rf2sStem rf2sLine szCondition

  return ''				/* Say no errors */

/* end ReadFile2Stem */

/* The end */
