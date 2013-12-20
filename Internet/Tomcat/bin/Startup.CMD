/*
 *   Startup Script for the Catalina Server
 *   OS/2 and eComStation Rexx Script
 *
 *   Copyright (c) 2004 Egothor Developers
 *   http://www.egothor.org
 *   mailto:egothor-tech@egothor.org
 *   Author: Jarda Kacer <jkacer@kiv.zcu.cz>
 *
 */

OuterEnv = SetLocal()
EverythingOK = 1
CALL RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
CALL SysLoadFuncs

Tomcat_CatalinaHome = GetEnvironment("CATALINA_HOME")

IF Tomcat_CatalinaHome = ""
	THEN DO
		Tomcat_CatalinaHome = GetScriptPath() || "\.."
		CALL SetEnvironment "CATALINA_HOME", Tomcat_CatalinaHome
	END

Exists_CatalinaScript = FileExists(Tomcat_CatalinaHome || "\bin\Catalina.CMD")
IF Exists_CatalinaScript = 0
	THEN DO
		SAY "-------------------------------------------------------------------------------"
		SAY "The CATALINA_HOME environment variable is not defined correctly."
		SAY "This environment variable is needed to run this program."
		SAY "-------------------------------------------------------------------------------"
		EverythingOK = 0
	END

IF GetScriptPath() \= GetCurrentDir()
	THEN DO
		SAY "-------------------------------------------------------------------------------"
		SAY "Sorry, running Catalina from another directory than its `bin' is not supported."
		SAY "Please do `CD " || GetScriptPath() || "' and try again. Thank you."
		SAY "-------------------------------------------------------------------------------"		
		EverythingOK = 0
	END

IF EverythingOK = 1
	THEN DO
		Executable = Tomcat_CatalinaHome || "\bin\Catalina.CMD"
		IF FileExists(Executable) = 0
			THEN DO
				SAY "-------------------------------------------------------------------------------"		
				SAY "Cannot find " || Executable
				SAY "This file is needed to run this program."
				SAY "-------------------------------------------------------------------------------"		
				EverythingOK = 0
			END

	END

IF EverythingOK = 1
	THEN DO
		CALL Catalina.CMD " start " || ARG(1)
	END

CALL EndLocal
EXIT

/***********************************************************************************************/


/*
 * Sets an environment variable or appends a value to it.
 */
AddEnvironment: PROCEDURE
PARSE ARG VarName, VarValue
IF (Value(VarName, , "OS2ENVIRONMENT")="")
     THEN CALL SetEnvironment VarName, VarValue
     ELSE CALL Value VarName, GetEnvironment(VarName) || ";" || VarValue, "OS2ENVIRONMENT"
RETURN


/*
 * Sets an environment variable, overwriting its previous value.
 */
SetEnvironment: PROCEDURE
PARSE ARG VarName, VarValue
CALL Value VarName, VarValue, "OS2ENVIRONMENT"
RETURN


/*
 * Returns the value of an environment variable.
 */
GetEnvironment: PROCEDURE
PARSE ARG VarName
RETURN Value(VarName, , "OS2ENVIRONMENT")


/*
 * Returns the current script name.
 */
GetScriptName: PROCEDURE
PARSE SOURCE Result
RETURN WORD(Result, 3)


/*
 * Returns the current script path, without "\" at the end.
 */
GetScriptPath: PROCEDURE
Name = GetScriptName()
RETURN SUBSTR(Name, 1, LASTPOS("\", Name)-1)


/*
 * Returns True if the given file exists.
 */
FileExists: PROCEDURE
PARSE ARG FileName
CALL SysFileTree FileName, Result
RETURN Result.0 > 0


/*
 * Returns the current directory, without "\" at the end.
 */
GetCurrentDir: PROCEDURE
RETURN DIRECTORY()
