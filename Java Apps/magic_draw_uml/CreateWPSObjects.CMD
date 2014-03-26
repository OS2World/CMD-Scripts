/*  Magic Draw UML 8.0 CE install program for OS/2 and eComStation
 *
 *  It creates a folder on your desktop, containing an icon for
 *  Magic Draw UML 8.0 Community Edition.
 *
 *  jkacer@kiv.zcu.cz
 */

FolderName = "Magic Draw UML 8.0 Community Edition"
ProgramName = "Magic Draw UML 8.0 Community Edition"
CommandFile1 = "MagicDraw.CMD"
IconFile = "MagicDraw1.ICO"

/* Loading all RexxUtil functions... */
CALL RxFuncAdd "SysLoadFuncs","RexxUtil","SysLoadFuncs"
CALL SysLoadFuncs

/* Really create? */
CALL SysCls
SAY "This install program creates """ || ProgramName || """ program objects"
SAY "on your desktop.  Do you wish to proceed?  (Y/N)"
PULL Answer .
Answer = SUBSTR(Answer, 1, 1)
IF Answer <> 'Y'
	THEN DO
		SAY "Exiting."
		EXIT 1
	END

/* Testing that files exist... */
CurrentDirectory = DIRECTORY()

CALL SysFileTree CurrentDirectory || '\' || CommandFile1, FoundFile, 'F'
IF FoundFile.0 = 0
	THEN DO
		SAY "Cannot locate file" CommandFile1 "--> Exiting."
		EXIT 1
	END

CALL SysFileTree CurrentDirectory || '\' || IconFile, FoundFile, 'F'
IF FoundFile.0 = 0
	THEN DO
		SAY "Cannot locate file" IconFile "--> Exiting."
		EXIT 1
	END

/* Let's create the folder and the program object... */
IF SysCreateObject("WPFolder", FolderName, "<WP_DESKTOP>", "OBJECTID=<MagicDraw_Folder>", "replace")
	THEN SAY 'MagicDraw folder was created on desktop.'
	ELSE SAY 'Failed to create MagicDraw folder on desktop!'

Settings = "PROGTYPE=WINDOWABLEVIO;NOAUTOCLOSE=NO;MINIMIZED=YES;EXENAME=" || CurrentDirectory || "\" || CommandFile1 || ";ICONFILE=" || CurrentDirectory || "\" || IconFile || ";STARTUPDIR=" || CurrentDirectory || ";OBJECTID=<MagicDraw_Program>"
IF SysCreateObject("WPProgram", ProgramName, "<MagicDraw_Folder>", Settings, "replace")
	THEN SAY 'Program object for Magic Draw UML 8.0 CE was created.'
	ELSE SAY 'Failed to create program object for Magic Draw UML 8.0 CE!'

SAY 'Finished, exiting...'
EXIT
