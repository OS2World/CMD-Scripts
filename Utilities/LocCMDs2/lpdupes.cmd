/* LPDupes - REXX program to search all paths of the 'PATH' statement for possible
          resolutions to the specified argument (program).

   RRC Mon  98-08-24 initial version -
   RRC Tue  98-09-08 Fixed problems with paths which began with '\' and '..'
*/

call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs
call SysLoadFuncs

'@echo off'

PARSE ARG FileName .

if FileName = "?" then
do
    say 'One optional argument.'
    say ''
    say 'LPDupes [FileName]'
    say ''
    say 'Locate "collisions" in your "libpath".  Detects DLLs with the same name in'
    say 'Different directories.  A "*" character will be on the lines describing the'
    say '"active" file - the DLL which would be loaded given the current directory.'
    say 'The placement of "." in the libpath will cause the output to change depending'
    say 'on the current directory.  This may be useful for testing.'
    say ''
    say 'The optional parameter is the first few letters of a filename to search for.'
    say '".dll" is supplied, if you include ".dll" in the search spec it will not work.'
    say ''
    say 'The program outputs errors if there are no DLLs in a given directory.'
    say 'It also outputs information about what it is doing so that you can tell'
    say 'it is in fact doing anything.  You can get rid of many of these messages by'
    say 'redirecting stderr to nul as in "lpdupes 2>nul".  Note that most of the'
    say 'informational or noise messages would not be saved if you redirect output to'
    say 'a file (only stdout will be redirected).  If you really want all of the'
    say 'messages to go to a file you will need to use this form: "lpdupes >file 2>&1"'
    say ''
    say 'The way the root directory is output is a little unusual: "\" is not the last'
    say 'character of the directory as it would be with a "dir" command.  All you get'
    say 'is a drive letter and the colon.'
    say ''
    exit
end

curdir = TRANSLATE(directory())         /* Get current directory in upper case*/
IF RIGHT(curdir,1) = '\' THEN           /* If string ends in '\' (root dir)   */
  curdir = LEFT(curdir, LENGTH(curdir)-1)   /* Strip it       */

say '. = ' curdir
call lineout 'STDERR:'

     /* get boot drive letter from environment */
     /* Other candidates for the env string to get the boot drive from:
          ULSPATH, EPMPATH, DMIPATH, I18NDIR, MMBASE    */
BootDrive=left(value('GLOSSARY',,'OS2ENVIRONMENT'),2)
ProdConfig=BootDrive || '\CONFIG.SYS'
rc = SysFileSearch('LIBPATH', ProdConfig, 'libp.')
/* If file was found, set rc to 0 iff there was at least one occurrence of
   the search string (note that rc = logical compare of libp.0 = 0) */
if rc = 0 then rc = libp.0 = 0
if rc <> 0 then do
        say "Cannot find a libpath statement in "ProdConfig
        pause
        exit
end

lix = libp.0                            /* Point to last occurrence           */
DO FOREVER                              /* Until we find a real one           */

  PARSE UPPER VALUE libp.lix WITH LPCmd '=' CmdTail
  IF LPCmd = 'LIBPATH' THEN DO          /* If this is a LIBPATH command       */
    LEAVE                               /* This was the final LIBPATH -- done */
  END

  lix = lix-1                           /* Check for an earlier statement     */
  IF lix = 0 THEN DO                    /* If we just ran out of candidates   */
    say "Cannot find a legitimate libpath statement in "ProdConfig
    pause
    exit
  END
END

/* CmdTail is everything past the '=' sign in CAPs, libp.lix is original line */
WorkPath=CmdTail
say 'Libpath = 'WorkPath
say ''
call lineout 'STDERR:'

myq = RXQUEUE('Get')                    /* Get our queue name */
'@RXQUEUE 'myq' /CLEAR'       /* Clear the input/keybd queue */

/* We use 'dir | rxqueue' so that we can get the list pre-sorted */
DirCmd = 'dir /A /B /L /On '
IF FileName = '' THEN SearchFiles = '\*.dll'
                 ELSE SearchFiles = '\'||FileName||'*.dll'

DirCmdTail = SearchFiles' | rxqueue'

/* Arrays which we will need */
cDirs = 0

do FOREVER                              /* Until 'leave'                      */

  PARSE UPPER VAR WorkPath SearchPath';'WorkPath  /* Pull consecutive 'path's */

  if SearchPath = '' THEN DO            /* If we've run out                   */
    LEAVE                               /* No more parsing to do              */
  END

  SearchPath = STRIP(SearchPath)        /* Remove blanks (should not be!)     */
  if RIGHT( SearchPath, 1 ) = '\'       /* If this path ends in bs            */
  THEN SearchPath = LEFT(SearchPath, LENGTH(SearchPath)-1)  /* Strip it       */

    /* Remove directories which don't exist */
  IF RIGHT(SearchPath,1) = ':' THEN DO  /* Root directories are special       */
    SearchPath2 = SearchPath            /* Yes they exist                     */
  END
  ELSE IF (SearchPath = '') | (LEFT(SearchPath,1) = '\') THEN
  DO                                    /* Root relative dirs exist by defn   */
    SearchPath2 = LEFT(curdir,2)||SearchPath  /* Add Current drive and ':'    */
  END
  ELSE IF LEFT(SearchPath,2) = '..' THEN DO /* A Parent dir may exist         */
    ParentDir = LASTPOS('\', curdir)    /* Find a backslash                   */
    IF ParentDir = 0 THEN ITERATE       /* If no parent, Get next libpath dir */

      /* Form the full path */
    SearchPath2 = LEFT(curdir,ParentDir-1)||SUBSTR(SearchPath,3)
  END
  ELSE IF LEFT(SearchPath,1) = '.' THEN DO  /* Relative dirs exist by defn    */
    SearchPath2 = curdir||SUBSTR(SearchPath,2)  /* SysFileTree can't be used  */
  END
  ELSE DO
    rc = SysFileTree(SearchPath, 'DirList', 'DO')
    if DirList.0 <> 1 THEN DO           /* If dir does not exist or is odd */
      SAY 'Directory in libpath ('SearchPath') not found!  SysFileTree='DirList.0
      if DirList.0 > 0 THEN
      DO ii=1 to DirList.0              /* If there was a value returned      */
        SAY '-'DirList.ii               /* Share the erroroneous info         */
      END
      ITERATE                           /* Get next dir in libpath            */
    END
    SearchPath2 = TRANSLATE(DirList.1)  /* By fallthrough we have a valid dir */
  END


    /* Remove directories which are specified more than once */
  DO ii=1 to cDirs                      /* For each directory already listed  */
    FullPath = sDirName.ii           /* Make a copy of the directory name  */
    IF LEFT(FullPath,1) = '.' THEN DO  /* Relative dirs need special care  */
      FullPath = curdir||SUBSTR(FullPath,2)  /* SysFileTree can't be used  */
    END
    IF FullPath = SearchPath2 THEN DO   /* If this directory already in list */
      SAY 'Duplicate directory: 'SearchPath' = 'sDirName.ii' -- 'SearchPath' dropped'
      SearchPath = '*'                  /* Flag it so we don't search it      */
      LEAVE                             /* Exit the hunt for duplicate dirs   */
    END
  END
  IF SearchPath = '*' THEN ITERATE      /* If this is a duplicate directory   */


    /* Remove directories with no matching DLLs */
  rc = SysFileTree(SearchPath||SearchFiles, 'DirList', 'FO' )
  if DirList.0 < 1 THEN DO
    call lineout 'STDERR:', 'Directory contains no matching entries: 'SearchPath' removed from search'
    ITERATE
  END


    /* Save directory info */
  cDirs = cDirs+1                       /* We have another directory          */
  sDirName.cDirs = SearchPath           /* The name of the directory          */
  sDirIx.cDirs = 1                      /* Which line to parse next           */

    /* Execute a directory command on the libpath directory */
  call lineout 'STDERR:', DirCmd SearchPath||DirCmdTail
  ' 'DirCmd SearchPath||DirCmdTail

  cFiles = 0                            /* Assume no files                    */

    /* Read the lines into a 2 dimensional array */
  DO WHILE QUEUED() > 0
    cFiles = cFiles+1
    PARSE PULL sFName.cDirs.cFiles      /* Put the filename in stem variable  */
  END
  sFName.cDirs.0 = cFiles               /* Set the count of files             */

END

sDirName.0 = cDirs                      /* Customary (just being compulsive)  */

call lineout 'STDERR:', 'Sort begun'
/* 'pause' */
do FOREVER                              /* Until 'exit'                       */
  smallest = 0                          /* Assume no 'smallest' entry         */
      
    /* Find the first DLL name (lexically) among all the directories */
  DO ii=1 to cDirs                      /* For each directory                 */
    IF sDirIx.ii <= sFName.ii.0 THEN DO /* If still files we watch in this dir*/
      ThisIx = sDirIx.ii                /* Get the index for this directory   */
      StrNext = sFName.ii.ThisIx        /* Next DLL fname in this directory   */
      IF smallest = 0 THEN DO
        smallest = ii                   /* If no contenders yet, it is me   */
        StrSmall = StrNext              /* Compare against this string        */
        matchfound = 0
      END
      ELSE DO                           /* Need to compare against smallest   */
        IF StrNext < StrSmall THEN DO   /* If this string is smaller          */
          smallest = ii                 /* This is the new alphabetic first   */
          StrSmall = StrNext            /* Keep the smallest string handy     */
          matchfound = 0                /* And obviously it has no peers      */
        END
        ELSE IF StrNext = StrSmall THEN matchfound = 1
      END                               /* Finding the first name lexically   */
    END                                 /* If this directory still has names  */
  END                                   /* Searching each directory           */

  IF smallest = 0 THEN LEAVE            /* If no smallest, all dirs exhausted */

  IF matchfound = 0 THEN DO             /* If no matches                      */
    sDirIx.smallest = sDirIx.smallest+1 /* Just skip this filename            */
  END
  ELSE DO                               /* Collision: output all matches      */

      /* Output the known first entry */
    rc = SysFileTree( sDirName.smallest||'\'||StrSmall, 'MatchList', 'F' )
    FileInfo = LEFT(MatchList.1, 35)
    OutDirName = sDirName.smallest
    if LEFT(OutDirName,1) = '.' THEN DO /* Translate relative directory name  */
      OutDirName = OutDirName' ('curdir||SUBSTR(OutDirName,2)')'
    END
    say '*'FileInfo LEFT(StrSmall,14) '*'OutDirName
    sDirIx.smallest = sDirIx.smallest+1 /* Done with this entry               */

    DO ii=smallest+1 to cDirs           /* If this directory may have matched */
      IF sDirIx.ii <= sFName.ii.0 THEN DO   /* If still files this directory  */
        ThisIx = sDirIx.ii              /* Get the index for this directory   */
        StrNext = sFName.ii.ThisIx      /* Next DLL fname in this directory   */
        IF StrNext = StrSmall THEN DO
          rc = SysFileTree( sDirName.ii||'\'||StrSmall, 'MatchList', 'F' )
          FileInfo = LEFT(MatchList.1, 35)
          OutDirName = sDirName.ii
          if LEFT(OutDirName,1) = '.' THEN DO /* Translate relative directory name  */
            OutDirName = OutDirName' ('curdir||SUBSTR(OutDirName,2)')'
          END
          say ' 'FileInfo LEFT(StrSmall,14) ' 'OutDirName
          sDirIx.ii = sDirIx.ii+1       /* Done with this entry too           */
        END                             /* Printing another match             */
      END                               /* Directory with entries             */
    END                                 /* For all the later directories      */
  END                                   /* Print a dll collision              */

END                                     /* While there is a smallest          */

exit 0                                  /* And done                           */
