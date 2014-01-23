/*
 *   Set CLASSPATH and Java Options
 *   OS/2 and eComStation Rexx Script
 *
 *   Copyright (c) 2004 Egothor Developers
 *   http://www.egothor.org
 *   mailto:egothor-tech@egothor.org
 *   Author: Jarda Kacer <jkacer@kiv.zcu.cz>
 *
 */

EverythingOK = 1
CALL RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
CALL SysLoadFuncs

Tomcat_JavaHome = GetEnvironment("JAVA_HOME")
IF Tomcat_JavaHome \= ""
	THEN DO
		Exists_Java  = FileExists(Tomcat_JavaHome || "\bin\java.exe")
		Exists_JavaW = FileExists(Tomcat_JavaHome || "\bin\javaw.exe")
		Exists_JDB   = FileExists(Tomcat_JavaHome || "\bin\jdb.exe")
		Exists_JavaC = FileExists(Tomcat_JavaHome || "\bin\javac.exe")
	END
	ELSE DO
		SAY "-------------------------------------------------------------------------------"
		SAY "The JAVA_HOME environment variable is not defined."
		SAY "This environment variable is needed to run this program."
		SAY "JAVA_HOME should point to a JDK, not a JRE."
		SAY "-------------------------------------------------------------------------------"
		EverythingOK = 0
	END

IF (Tomcat_JavaHome \= "") & ((Exists_Java = 0) | (Exists_JavaW = 0) | (Exists_JDB = 0) | (Exists_JavaC = 0))
	THEN DO
		SAY "-------------------------------------------------------------------------------"
		SAY "The JAVA_HOME environment variable is not defined correctly."
		SAY "This environment variable is needed to run this program."
		SAY "JAVA_HOME should point to a JDK, not a JRE."
		SAY "Please check that the following files exist:"
		SAY "    " || Tomcat_JavaHome || "\bin\java.exe"
		SAY "    " || Tomcat_JavaHome || "\bin\javaw.exe"
		SAY "    " || Tomcat_JavaHome || "\bin\jdb.exe"
		SAY "    " || Tomcat_JavaHome || "\bin\javac.exe"
		SAY "-------------------------------------------------------------------------------"
		EverythingOK = 0
	END


Tomcat_BaseDir = GetEnvironment("BASEDIR")
IF Tomcat_BaseDir \= ""
	THEN DO
		Exists_ThisScript = FileExists(Tomcat_BaseDir || "\bin\SetClassPath.CMD")
		IF Exists_ThisScript = 0
			THEN DO
				SAY "-------------------------------------------------------------------------------"
				SAY "The BASEDIR environment variable is not defined correctly."
				SAY "This environment variable is needed to run this program."
				SAY "-------------------------------------------------------------------------------"
				EverythingOK = 0
			END
	END
	ELSE DO
		SAY "-------------------------------------------------------------------------------"
		SAY "The BASEDIR environment variable is not defined."
		SAY "This environment variable is needed to run this program."
		SAY "-------------------------------------------------------------------------------"
		EverythingOK = 0
	END

IF EverythingOK = 1
	THEN DO
		CALL SetEnvironment "JAVA_ENDORSED_DIRS", Tomcat_BaseDir || "\common\endorsed"
		CALL AddEnvironment "CLASSPATH", Tomcat_JavaHome || "\lib\tools.jar"
		CALL SetEnvironment "_RUNJAVA",  Tomcat_JavaHome || "\bin\java.exe"
		CALL SetEnvironment "_RUNJAVAW", Tomcat_JavaHome || "\bin\javaw.exe"
		CALL SetEnvironment "_RUNJDB",   Tomcat_JavaHome || "\bin\jdb.exe"
		CALL SetEnvironment "_RANJAVAC", Tomcat_JavaHome || "\bin\javac.exe"
	END
	ELSE DO
		SAY ""
		SAY "Sorry, something went wrong. Please consult the above message,"
		SAY "remove the source of the problem and then try again."
		SAY ""
	END

RETURN (1-EverythingOK)


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
 * Returns True if the given file exists.
 */
FileExists: PROCEDURE
PARSE ARG FileName
CALL SysFileTree FileName, Result
RETURN Result.0 > 0
