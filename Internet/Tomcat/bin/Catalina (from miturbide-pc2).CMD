/*
 *   Start/Stop Script for the Catalina Server
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
 *   CATALINA_HOME   May point at your Catalina "build" directory.
 *
 *   CATALINA_BASE   (Optional) Base directory for resolving dynamic portions
 *                   of a Catalina installation.  If not present, resolves to
 *                   the same directory that CATALINA_HOME points to.
 *
 *   CATALINA_OPTS   (Optional) Java runtime options used when the "start",
 *                   "stop", or "run" command is executed.
 *
 *   CATALINA_TMPDIR (Optional) Directory path location of temporary directory
 *                   the JVM should use (java.io.tmpdir).  Defaults to
 *                   %CATALINA_BASE%\temp.
 *
 *   JAVA_HOME       Must point at your Java Development Kit installation.
 *
 *   JAVA_OPTS       (Optional) Java runtime options used when the "start",
 *                   "stop", or "run" command is executed.
 *
 *   JSSE_HOME       (Optional) May point at your Java Secure Sockets Extension
 *                   (JSSE) installation, whose JAR files will be added to the
 *                   system class path used to start Tomcat.
 *
 *   JPDA_TRANSPORT  (Optional) JPDA transport used when the "jpda start"
 *                   command is executed. The default is "dt_shmem".
 *
 *   JPDA_ADDRESS    (Optional) Java runtime options used when the "jpda start"
 *                   command is executed. The default is "jdbconn".
 *
 ************************************************************************************
 */


OuterEnv = SetLocal()
EverythingOK = 1
CALL RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
CALL SysLoadFuncs

Tomcat_CatalinaHome = GetEnvironment("CATALINA_HOME")
Tomcat_JSSEHome = GetEnvironment("JSSE_HOME")
Tomcat_CatalinaBase = GetEnvironment("CATALINA_BASE")
Tomcat_CatalinaTmpDir = GetEnvironment("CATALINA_TMPDIR")
Tomcat_JavaHome = GetEnvironment("JAVA_HOME")

IF Tomcat_CatalinaHome = ""
	THEN DO
		Tomcat_CatalinaHome = GetScriptPath() || "\.."
		CALL SetEnvironment "CATALINA_HOME", Tomcat_CatalinaHome
	END

Exists_ThisScript = FileExists(Tomcat_CatalinaHome || "\bin\Catalina.CMD")
IF Exists_ThisScript = 0
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
				Tomcat_ClassPath = GetEnvironment("CLASSPATH")
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
		IF Tomcat_JSSEHome \= ""
			THEN DO
				Tomcat_ClassPath = Tomcat_ClassPath || ";" || Tomcat_JSSEHome || "\lib\jcert.jar"
				Tomcat_ClassPath = Tomcat_ClassPath || ";" || Tomcat_JSSEHome || "\lib\jnet.jar"
				Tomcat_ClassPath = Tomcat_ClassPath || ";" || Tomcat_JSSEHome || "\lib\jsse.jar"
			END

		Tomcat_ClassPath = Tomcat_ClassPath || ";" || Tomcat_CatalinaHome || "\bin\bootstrap.jar"
		CALL SetEnvironment "CLASSPATH", Tomcat_ClassPath

		IF Tomcat_CatalinaBase = ""
			THEN DO
				Tomcat_CatalinaBase = Tomcat_CatalinaHome
				CALL SetEnvironment "CATALINA_BASE", Tomcat_CatalinaBase
			END

		IF Tomcat_CatalinaTmpDir = ""
			THEN DO
				Tomcat_CatalinaTmpDir = Tomcat_CatalinaBase || "\temp"
				CALL SetEnvironment "CATALINA_TMPDIR", Tomcat_CatalinaTmpDir
			END

		SAY "Using CATALINA_BASE:   " || Tomcat_CatalinaBase
		SAY "Using CATALINA_HOME:   " || Tomcat_CatalinaHome
		SAY "Using CATALINA_TMPDIR: " || Tomcat_CatalinaTmpDir
		SAY "Using JAVA_HOME:       " || Tomcat_JavaHome

		CALL SetEnvironment "_EXECJAVA", GetEnvironment("_RUNJAVA")
		CALL SetEnvironment "MAINCLASS", "org.apache.catalina.startup.Bootstrap"
		CALL SetEnvironment "ACTION", "start"
		CALL SetEnvironment "SECURITY_POLICY_FILE", ""
		CALL SetEnvironment "DEBUG_OPTS", ""
		CALL SetEnvironment "JPDA", ""

		Arguments = ARG(1)
		NoOfArgsUsed = 0
		Done = 0

		IF (WORD(Arguments, NoOfArgsUsed+1) = "jpda") | (WORD(Arguments, NoOfArgsUsed+1) = "JPDA")
			THEN DO
				CALL SetEnvironment "JPDA", "jpda"
				IF GetEnvironment("JPDA_TRANSPORT") = ""
					THEN CALL SetEnvironment "JPDA_TRANSPORT", "dt_shmem"
				IF GetEnvironment("JPDA_ADDRESS") = ""
					THEN CALL SetEnvironment "JPDA_ADDRESS", "jdbconn"
				NoOfArgsUsed = NoOfArgsUsed+1
			END

		IF (Done = 0) & ((WORD(Arguments, NoOfArgsUsed+1) = "debug") | (WORD(Arguments, NoOfArgsUsed+1) = "DEBUG"))
			THEN DO
				NoOfArgsUsed = NoOfArgsUsed+1
				CALL DoDebug Arguments, NoOfArgsUsed
				Done = 1
			END
		IF (Done = 0) & ((WORD(Arguments, NoOfArgsUsed+1) = "run") | (WORD(Arguments, NoOfArgsUsed+1) = "RUN"))
			THEN DO
				NoOfArgsUsed = NoOfArgsUsed+1
				CALL DoRun Arguments, NoOfArgsUsed
				Done = 1
			END
		IF (Done = 0) & ((WORD(Arguments, NoOfArgsUsed+1) = "start") | (WORD(Arguments, NoOfArgsUsed+1) = "START"))
			THEN DO
				NoOfArgsUsed = NoOfArgsUsed+1
				CALL DoStart Arguments, NoOfArgsUsed
				Done = 1
			END
		IF (Done = 0) & ((WORD(Arguments, NoOfArgsUsed+1) = "stop") | (WORD(Arguments, NoOfArgsUsed+1) = "STOP"))
			THEN DO
				NoOfArgsUsed = NoOfArgsUsed+1
				CALL DoStop Arguments, NoOfArgsUsed
				Done = 1
			END
		IF Done = 0
			THEN CALL DisplayUsage
	END /* If everything OK after SetClassPath */

CALL EndLocal
EXIT /* End of program */


/***********************************************************************************************/


/*
 * Starts Tomcat in debug mode.
 */
DoDebug: PROCEDURE
PARSE ARG AllCmdLineArgs, NoOfArgsUsed
CALL SetEnvironment "_EXECJAVA", GetEnvironment("_RUNJDB")

SAY "-------------------------------------------------------------------------------"
SAY "Note for OS/2 and eCS users:"
SAY "Please check whether " || GetEnvironment("CATALINA_HOME") || "\..\..\jakarta-tomcat-catalina\catalina\src\share"
SAY "is a valid path on your system. If not, modify the Catalina.CMD script."
SAY "-------------------------------------------------------------------------------"

CALL SetEnvironment "DEBUG_OPTS", "-sourcepath " || GetEnvironment("CATALINA_HOME") || "\..\..\jakarta-tomcat-catalina\catalina\src\share"
IF WORD(AllCmdLineArgs, NoOfArgsUsed+1) = "-security"
	THEN DO
		NoOfArgsUsed = NoOfArgsUsed + 1
		SAY "Using Security Manager"
		CALL SetEnvironment "SECURITY_POLICY_FILE", GetEnvironment("CATALINA_BASE") || "\conf\catalina.policy"
	END
CALL ExecuteCommand AllCmdLineArgs, NoOfArgsUsed
RETURN


/*
 * Runs Tomcat in the current session.
 */
DoRun: PROCEDURE
PARSE ARG AllCmdLineArgs, NoOfArgsUsed
IF WORD(AllCmdLineArgs, NoOfArgsUsed+1) = "-security"
	THEN DO
		NoOfArgsUsed = NoOfArgsUsed + 1
		SAY "Using Security Manager"
		CALL SetEnvironment "SECURITY_POLICY_FILE", GetEnvironment("CATALINA_BASE") || "\conf\catalina.policy"
	END
CALL ExecuteCommand AllCmdLineArgs, NoOfArgsUsed
RETURN


/*
 * Runs Tomcat in a separate session.
 */
DoStart: PROCEDURE
PARSE ARG AllCmdLineArgs, NoOfArgsUsed
CALL SetEnvironment "_EXECJAVA", "start " || GetEnvironment("_RUNJAVA")
IF WORD(AllCmdLineArgs, NoOfArgsUsed+1) = "-security"
	THEN DO
		NoOfArgsUsed = NoOfArgsUsed + 1
		SAY "Using Security Manager"
		CALL SetEnvironment "SECURITY_POLICY_FILE", GetEnvironment("CATALINA_BASE") || "\conf\catalina.policy"
	END
CALL ExecuteCommand AllCmdLineArgs, NoOfArgsUsed
RETURN


/*
 * Stops Tomcat.
 */
DoStop: PROCEDURE
PARSE ARG AllCmdLineArgs, NoOfArgsUsed
CALL SetEnvironment "ACTION", "stop"
CALL ExecuteCommand AllCmdLineArgs, NoOfArgsUsed
RETURN


/*
 * Prepares command-line arguments and calls a real start-up procedure.
 */
ExecuteCommand: PROCEDURE
PARSE ARG AllCmdLineArgs, NoOfArgsUsed
Arguments = ""
DO I = (NoOfArgsUsed+1) TO WORDS(AllCmdLineArgs)
	Arguments = Arguments || " " || WORD(AllCmdLineArgs, I)
END I
CALL SetEnvironment "CMD_LINE_ARGS", Arguments

IF GetEnvironment("JPDA") \= ""
	THEN DO
		IF GetEnvironment("SECURITY_POLICY_FILE") \= ""
			THEN CALL RunTomcat_SecurityJPDA
			ELSE CALL RunTomcat_JPDA
	END
	ELSE DO
		IF GetEnvironment("SECURITY_POLICY_FILE") \= ""
			THEN CALL RunTomcat_Security
			ELSE CALL RunTomcat_Classic
	END
RETURN


/*
 * Starts Tomcat with classic setting.
 */
RunTomcat_Classic: PROCEDURE
Command = GetEnvironment("_EXECJAVA")
Command = Command || " " || GetEnvironment("JAVA_OPTS")
Command = Command || " " || GetEnvironment("CATALINA_OPTS")
Command = Command || " " || GetEnvironment("DEBUG_OPTS")
Command = Command || " -Djava.endorsed.dirs=" || GetEnvironment("JAVA_ENDORSED_DIRS")
Command = Command || " -classpath " || GetEnvironment("CLASSPATH")
Command = Command || " -Dcatalina.base=" || GetEnvironment("CATALINA_BASE")
Command = Command || " -Dcatalina.home=" || GetEnvironment("CATALINA_HOME")
Command = Command || " -Djava.io.tmpdir=" || GetEnvironment("CATALINA_TMPDIR")
Command = Command || " " || GetEnvironment("MAINCLASS")
Command = Command || " " || GetEnvironment("CMD_LINE_ARGS")
Command = Command || " " || GetEnvironment("ACTION")
Command
RETURN


/*
 * Starts Tomcat with extra security setting.
 */
RunTomcat_Security: PROCEDURE
Command = GetEnvironment("_EXECJAVA")
Command = Command || " " || GetEnvironment("JAVA_OPTS")
Command = Command || " " || GetEnvironment("CATALINA_OPTS")
Command = Command || " " || GetEnvironment("DEBUG_OPTS")
Command = Command || " -Djava.endorsed.dirs=" || GetEnvironment("JAVA_ENDORSED_DIRS")
Command = Command || " -classpath " || GetEnvironment("CLASSPATH")
Command = Command || " -Djava.security.manager"
Command = Command || " -Djava.security.policy==" || GetEnvironment("SECURITY_POLICY_FILE")
Command = Command || " -Dcatalina.base=" || GetEnvironment("CATALINA_BASE")
Command = Command || " -Dcatalina.home=" || GetEnvironment("CATALINA_HOME")
Command = Command || " -Djava.io.tmpdir=" || GetEnvironment("CATALINA_TMPDIR")
Command = Command || " " || GetEnvironment("MAINCLASS")
Command = Command || " " || GetEnvironment("CMD_LINE_ARGS")
Command = Command || " " || GetEnvironment("ACTION")
Command
RETURN


/*
 * Starts Tomcat with extra JPDA setting.
 */
RunTomcat_JPDA: PROCEDURE
Command = GetEnvironment("_EXECJAVA")
Command = Command || " " || GetEnvironment("JAVA_OPTS")
Command = Command || " " || GetEnvironment("CATALINA_OPTS")
Command = Command || " -Xdebug"
Command = Command || " -Xrunjdwp:transport=" || GetEnvironment("JPDA_TRANSPORT") || ",address=" || GetEnvironment("JPDA_ADDRESS") || ",server=y,suspend=n"
Command = Command || " " || GetEnvironment("DEBUG_OPTS")
Command = Command || " -Djava.endorsed.dirs=" || GetEnvironment("JAVA_ENDORSED_DIRS")
Command = Command || " -classpath " || GetEnvironment("CLASSPATH")
Command = Command || " -Dcatalina.base=" || GetEnvironment("CATALINA_BASE")
Command = Command || " -Dcatalina.home=" || GetEnvironment("CATALINA_HOME")
Command = Command || " -Djava.io.tmpdir=" || GetEnvironment("CATALINA_TMPDIR")
Command = Command || " " || GetEnvironment("MAINCLASS")
Command = Command || " " || GetEnvironment("CMD_LINE_ARGS")
Command = Command || " " || GetEnvironment("ACTION")
Command
RETURN


/*
 * Starts Tomcat with extra security and JPDA setting.
 */
RunTomcat_SecurityJPDA: PROCEDURE
Command = GetEnvironment("_EXECJAVA")
Command = Command || " " || GetEnvironment("JAVA_OPTS")
Command = Command || " " || GetEnvironment("CATALINA_OPTS")
Command = Command || " -Xrunjdwp:transport=" || GetEnvironment("JPDA_TRANSPORT") || ",address=" || GetEnvironment("JPDA_ADDRESS") || ",server=y,suspend=n"
Command = Command || " " || GetEnvironment("DEBUG_OPTS")
Command = Command || " -Djava.endorsed.dirs=" || GetEnvironment("JAVA_ENDORSED_DIRS")
Command = Command || " -classpath " || GetEnvironment("CLASSPATH")
Command = Command || " -Djava.security.manager"
Command = Command || " -Djava.security.policy==" || GetEnvironment("SECURITY_POLICY_FILE")
Command = Command || " -Dcatalina.base=" || GetEnvironment("CATALINA_BASE")
Command = Command || " -Dcatalina.home=" || GetEnvironment("CATALINA_HOME")
Command = Command || " -Djava.io.tmpdir=" || GetEnvironment("CATALINA_TMPDIR")
Command = Command || " " || GetEnvironment("MAINCLASS")
Command = Command || " " || GetEnvironment("CMD_LINE_ARGS")
Command = Command || " " || GetEnvironment("ACTION")
Command
RETURN


/*
 * Diplays instructions on how to use this script.
 */
DisplayUsage: PROCEDURE
SAY "Usage:  Catalina.CMD <commands>"
SAY "Commands:"
SAY "   debug             Start Catalina in a debugger."
SAY "   debug -security   Debug Catalina with a security manager."
SAY "   jpda start        Start Catalina under JPDA debugger."
SAY "   run               Start Catalina in the current window."
SAY "   run -security     Start in the current window with security manager."
SAY "   start             Start Catalina in a separate window."
SAY "   start -security   Start in a separate window with security manager."
SAY "   stop              Stop Catalina."
RETURN


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