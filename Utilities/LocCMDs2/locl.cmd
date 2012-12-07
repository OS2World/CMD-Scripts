/* LocL - REXX program to search all paths of the 'PATH' statement for possible
          resolutions to the specified argument (program).

   RRC 02/11/97 initial version - Note: should look for '.cmd' & '.exe'
*/

call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs
call SysLoadFuncs

'@echo off'

PARSE ARG FileName .

if FileName = "" then
do
    say 'No arguments given.'
    say ''
    say 'LocL FileName'
    say ''
    say 'Locate where in your "libpath" string a file exists.  Requires one parameter.'
    say 'The first parameter must be the first few letters of a filename to search for.'
    say ''
    exit
end

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


do FOREVER                              /* Until 'exit'                       */

  PARSE VAR WorkPath SearchPath';'WorkPath  /* Pull consecutive 'path's       */

  if SearchPath = '' THEN DO            /* If we've run out                   */

    exit 0                              /* And done                           */
  END

  SearchPath = STRIP(SearchPath)        /* Remove blanks (should not be!)     */
  if RIGHT( SearchPath, 1 ) = '\'       /* If this path ends in bs            */
  THEN SearchPath = LEFT(SearchPath, LENGTH(SearchPath)-1)  /* Strip it       */

  rc = SysFileTree( SearchPath||'\'||FileName||'*', 'MatchList', 'F' )
  if rc <> 0 then do
    say 'Serious error: insufficient memory to run SysFileTree.  Error 'rc
    exit 3
  END

  DO ii=1 to MatchList.0
    say MatchList.ii
  END

END
