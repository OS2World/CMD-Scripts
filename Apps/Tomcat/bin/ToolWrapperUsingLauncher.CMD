/*
 *   Script for Running the Catalina Tool Wrapper Using the Launcher
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
		Tomcat_SetEnvPath = Tomcat_CatalinaHome || "\bin\SetEnv.CMD"
		IF FileExists(Tomcat_SetEnvPath) = 1
			THEN CALL SetEnv.CMD /* TODO: INTERPRET */
	END

IF EverythingOK = 1
	THEN DO
		Tomcat_JavaHome = GetEnvironment("JAVA_HOME")
		IF Tomcat_JavaHome = ""
			THEN DO
				SAY "-------------------------------------------------------------------------------"		
				SAY "The JAVA_HOME environment variable is not defined."
				SAY "This environment variable is needed to run this program."
				SAY "-------------------------------------------------------------------------------"		
				EverythingOK = 0
			END
	END

IF EverythingOK = 1
	THEN DO
		Command = Tomcat_JavaHome || "\bin\java.exe"
		Command = Command || " -classpath " || GetScriptPath() || ";" || GetEnvironment("PATH") || ";." 
		Command = Command || " LauncherBootstrap -launchfile catalina.xml -verbose tool-wrapper"
		Command = Command || " " || ARG(1)

		Command
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
