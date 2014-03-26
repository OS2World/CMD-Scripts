/****************************** Module Header *******************************
*
* Module Name: RmDesktopFolderPos.cmd
*
* Syntax: RmDesktopFolderPos [RUN] [QUIET]
*
*         Options (not case-sensitive):
*            RUN    don't ask at startup, only error messages
*            QUIET  no output messages, check RC for the result
*
* This REXX script deletes the ini key of the desktop's FolderPos in icon
* view. It helps to work around following OS/2 bug which happens from time
* to time if a toolbar is configured to reduce the desktop's workarea:
*
* After system restart all desktop objects moved by the height of the
* toolbar. For a toolbar at the top of the desktop the objects move upwards.
* For a toolbar at the bottom they move downwards.
*
* Example for a desktop handle:
*    0x3BE66 = 24 53 50
*
* Example for an ini key in PM_Workplace:FolderPos:
*    245350@10
*
* ===========================================================================
*
* Andreas Schnellbacher 2014
*
****************************************************************************/
/* Some header lines are used as help text */
HelpStartLine = 11
HelpEndLine   = 17


/* ----------------- Standard REXX initialization follows ---------------- */
SIGNAL ON HALT NAME Halt

IF ADDRESS() <> 'EPM' THEN
   '@ECHO OFF'

env   = 'OS2ENVIRONMENT'
TRUE  = (1 = 1)
FALSE = (0 = 1)
CrLf  = '0d0a'x
Redirection = '>NUL 2>&1'
PARSE SOURCE . . ThisFile
GlobalVars = 'env TRUE FALSE Redirection ERROR. ThisFile RC'

/* some OS/2 Error codes */
ERROR.NO_ERROR           =   0
ERROR.INVALID_FUNCTION   =   1
ERROR.FILE_NOT_FOUND     =   2
ERROR.PATH_NOT_FOUND     =   3
ERROR.ACCESS_DENIED      =   5
ERROR.NOT_ENOUGH_MEMORY  =   8
ERROR.INVALID_FORMAT     =  11
ERROR.INVALID_DATA       =  13
ERROR.NO_MORE_FILES      =  18
ERROR.WRITE_FAULT        =  29
ERROR.READ_FAULT         =  30
ERROR.SHARING_VIOLATION  =  32
ERROR.GEN_FAILURE        =  31
ERROR.INVALID_PARAMETER  =  87
ERROR.ENVVAR_NOT_FOUND   = 204

RC = ERROR.NO_ERROR

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs
/* ----------------- Standard REXX initialization ends ------------------- */

GlobalVars = GlobalVars 'fQuiet'

/* Get Name of inf file in dir of current file */
InfFileName = 'MovingDesktopObjects.inf'
lp = LASTPOS( '\', ThisFile)
InfFile = SUBSTR( ThisFile, 1, lp)InfFileName
IF (STREAM( InfFile, 'c', 'query exists') = '') THEN
   InfFile = InfFileName  /* Let view search in BOOKSHELF */


/* Get Args */
PARSE ARG Args
Args = STRIP( Args)

fQuiet = 0
fAsk   = 1
IF WORDPOS( TRANSLATE( Args), 'RUN') > 0 THEN
  fAsk = 0
IF WORDPOS( TRANSLATE( Args), 'QUIET') > 0 THEN
DO
  fQuiet = 1
  fAsk = 0
END

IF fAsk THEN
DO
   SAY
   DO l = HelpStartLine TO HelpEndLine
      CALL SayText( SUBSTR( SOURCELINE( l), 3))
   END
   SAY
   CALL SayText( 'Type C to continue, H for help or any other key for cancel:')
   PULL Answer
   Answer = STRIP( Answer)
   SELECT
      WHEN Answer = 'C' THEN
         NOP
      WHEN Answer = 'H' THEN
      DO
         /* Show INF file */
         'start view' InfFile
         EXIT( RC)
      END
   OTHERWISE
      SIGNAL Halt
   END
END


/* Get desktop's object handle */

ObjectId = '<WP_DESKTOP>'
DecObjHandle = GetDecObjHandle( ObjectId)
IF RC <> ERROR.NO_ERROR THEN
DO
   CALL SayError( 'Error:' IniKey 'was not found in' IniApp'.')
   EXIT( RC)
END

/* Query desktop's FolderPos entry for icon view */

IniApp   = 'PM_Workplace:FolderPos'
ViewId   = 10  /* Icon View */
IniKey   = DecObjHandle'@'ViewId

IniVal = QueryIniKey( IniApp, IniKey)
IF RC <> ERROR.NO_ERROR THEN
DO
   CALL SayError( 'Error:' IniKey 'was not found in' IniApp'.')
   EXIT( RC)
END

/* Delete desktop's FolderPos entry for icon view */

CALL DeleteIniKey IniApp, IniKey
IF RC <> ERROR.NO_ERROR THEN
DO
   CALL SayError( 'Error:' IniKey 'was not deleted from' IniApp'.')
   EXIT( RC)
END

CALL SayText( IniKey 'for' ObjectId 'was successfully deleted from' IniApp'.')
EXIT(  ERROR.NO_ERROR)


/* ----------------------------------------------------------------------- */
GetDecObjHandle:
   PARSE ARG ObjectId

   RC = ERROR.NO_ERROR
   IniApp = 'PM_Workplace:Location'
   IniKey = ObjectId

   DecObjHandle = ''
   next = QueryIniKey( IniApp, IniKey)

   IF RC <> ERROR.NO_ERROR THEN
      RC = ERROR.READ_FAULT
   ELSE
   DO
      HexObjHandle = REVERSE( next)
      DecObjHandle = C2D( HexObjHandle)
   END

   RETURN( DecObjHandle)

/* ----------------------------------------------------------------------- */
QueryIniKey: PROCEDURE EXPOSE (GlobalVars)
   PARSE ARG IniApp, IniKey

   RC = ERROR.NO_ERROR
   IniVal = ''
   next = SysIni( 'USER', IniApp, IniKey)

   IF next = 'ERROR:' THEN
      RC = ERROR.READ_FAULT
   ELSE
      IniVal = next

   RETURN( IniVal)

/* ----------------------------------------------------------------------- */
DeleteIniKey: PROCEDURE EXPOSE (GlobalVars)
   PARSE ARG IniApp, IniKey

   RC = ERROR.NO_ERROR
   next = SysIni( 'USER', IniApp, IniKey, 'DELETE:')

   IF next = 'ERROR:' THEN
      RC = ERROR.WRITE_FAULT
   ELSE
      RC = ERROR.NO_ERROR

   RETURN

/* ----------------------------------------------------------------------- */
SayText: PROCEDURE EXPOSE (GlobalVars)
   PARSE ARG Message
   IF \fQuiet THEN
      SAY Message
   RETURN( '')

/* ----------------------------------------------------------------------- */
SayError: PROCEDURE EXPOSE (GlobalVars)
   PARSE ARG Message
   IF \fQuiet THEN
      SAY Message
   RETURN( '')

/* ----------------------------------------------------------------------- */
Halt:
   CALL SayError( 'Interrupted by user.')
   EXIT( ERROR.GEN_FAILURE)

