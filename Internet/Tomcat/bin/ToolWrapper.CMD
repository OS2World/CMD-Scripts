/*
 *   Wrapper Script for Command Line Tools for the Catalina Server
 *   OS/2 and eComStation Rexx Script
 *
 *   Copyright (c) 2004 Egothor Developers
 *   http://www.egothor.org
 *   mailto:egothor-tech@egothor.org
 *   Author: Jarda Kacer <jkacer@kiv.zcu.cz>
 *
 ************************************************************************************
 *
 *   Environment Variable Prerequisites:
 *
 *
 *   CATALINA_HOME May point at your Catalina "build" directory.
 *
 *   TOOL_OPTS     (Optional) Java runtime options used when the "start",
 *                 "stop", or "run" command is executed.
 *
 *   JAVA_HOME     Must point at your Java Development Kit installation.
 *
 *   JAVA_OPTS     (Optional) Java runtime options used when the "start",
 *                 "stop", or "run" command is executed.
 *
 ************************************************************************************
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

Exists_WrapperScript = FileExists(Tomcat_CatalinaHome || "\bin\ToolWrapper.CMD")
IF Exists_WrapperScript = 0
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
		Tomcat_SetEnvPath = Tomcat_CatalinaHome || "\bin\SetEnv.CMD"
		IF FileExists(Tomcat_SetEnvPath) = 1
			THEN CALL SetEnv.CMD /* TODO: INTERPRET */
	END

IF EverythingOK = 1
	THEN DO
		Tomcat_SetClassPathPath = Tomcat_CatalinaHome || "\bin\SetClassPath.CMD"
		IF FileExists(Tomcat_SetClassPathPath) = 1
			THEN DO
				CALL SetEnvironment "BASEDIR", Tomcat_CatalinaHome
				CALL SetClassPath.CMD /* TODO: INTERPRET */
			END
			ELSE DO
				SAY "-------------------------------------------------------------------------------"
				SAY "Cannot find " || Tomcat_SetClassPathPath
				SAY "This file is needed to run this program."
				SAY "-------------------------------------------------------------------------------"
				EverythingOK = 0
			END
	END

IF EverythingOK = 1
	THEN DO
		Tomcat_BaseDir = GetEnvironment("BASEDIR")
		Tomcat_ClassPath = GetEnvironment("CLASSPATH")
		Tomcat_ClassPath = Tomcat_ClassPath || ";" || Tomcat_CatalinaHome || "\bin\bootstrap.jar"
		Tomcat_ClassPath = Tomcat_ClassPath || ";" || Tomcat_BaseDir || "\common\lib\jmx.jar"

		Command = GetEnvironment("_RUNJAVA")
		Command = Command || " " || GetEnvironment("JAVA_OPTS")
		Command = Command || " " || GetEnvironment("TOOL_OPTS")
		Command = Command || " -Djava.endorsed.dirs=" || GetEnvironment("JAVA_ENDORSED_DIRS")
		Command = Command || " -classpath " || Tomcat_ClassPath
		Command = Command || " -Dcatalina.home=" || Tomcat_CatalinaHome
		Command = Command || " org.apache.catalina.startup.Tool"
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