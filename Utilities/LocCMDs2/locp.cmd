/* LocP - REXX program to search all paths of the 'PATH' statement for possible
          resolutions to the specified argument (program).

   RRC 02/11/97 initial version - Note: should look for '.cmd' & '.exe'
*/

call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs
call SysLoadFuncs

'@echo off'

PARSE ARG What .

if What = "" then
do
    say 'No arguments given.'
    say ''
    say 'locp FileName'
    say ''
    say 'Locate where in your "path" string a file exists.  Requires one parameter.'
    say 'The first parameter must be a filename to search for.'
    say ''
    exit
end

WorkPath=value('PATH',,'OS2ENVIRONMENT')  /* Pick up current %PATH%           */

do FOREVER                              /* Until 'exit'                       */

  PARSE VAR WorkPath SearchPath';'WorkPath  /* Pull consecutive 'path's       */

  if SearchPath = '' THEN DO            /* If we've run out                   */

    exit 0                              /* And done                           */
  END

  SearchPath = STRIP(SearchPath)        /* Remove blanks (should not be!)     */
  if RIGHT( SearchPath, 1 ) = '\'       /* If this path ends in bs            */
  THEN SearchPath = LEFT(SearchPath, LENGTH(SearchPath)-1)  /* Strip it       */

  rc = SysFileTree( SearchPath||'\'||What||'*', 'MatchList', 'F' )
  if rc <> 0 then do
    say 'Serious error: insufficient memory to run SysFileTree.  Error 'rc
    exit 3
  END

  DO ii=1 to MatchList.0
    say MatchList.ii
  END

END
