/*
 * Ant.CMD
 * OS/2 and eComStation command file that runs Ant
 *
 * Copyright (C) 2003 Egothor Developers
 */

/*
 * Activate RexxUtil function
 */
CALL RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
CALL SysLoadFuncs

Home = GetEnvironment("HOME")
PreFile = Home || "\AntRC_Pre.CMD"
IF FileExists(PreFile)
        THEN DO
                SAY "Calling user pre-file " PreFile
                ThisDir = DIRECTORY()
                CALL DIRECTORY Home
                CALL AntRC_Pre.CMD
                CALL DIRECTORY ThisDir
                SAY "Back in Ant.CMD"
        END


OldLocal = SETLOCAL()

/*
 * Set Ant Home Directory
 */
DefaultAntHome = GetScriptPath() || "\.."
AntHome = GetEnvironment("ANT_HOME")
IF AntHome = "" THEN CALL SetEnvironment "ANT_HOME", DefaultAntHome
DefaultAntHome = ""
AntHome = GetEnvironment("ANT_HOME")
 
/*
 * Grab all arguments
 */
AntCommandLineArguments = ARG(1)

/*
 * Check Java
 */
_JavaCMD = GetEnvironment("JAVACMD")
LocalClassPath = GetEnvironment("CLASSPATH")

/*
 * Add all Ant JARs to local class path; Search for files only; Return only fully qualified names
 */
CALL SysFileTree AntHome||"\lib\*.jar", FilesFound, "FO"
DO I=1 to FilesFound.0
        LocalClassPath = LocalClassPath || ";" || FilesFound.I
END I
 
JavaHome = GetEnvironment("JAVA_HOME")
IF JavaHome \= ""
        THEN DO
                /*
                 * IBM JDK 1.3: java.exe is in "Java13\jre\bin\"
                 * JAVA_HOME should be set to "Java13\jre"
                 */
                IF _JavaCMD = "" THEN _JavaCMD = JavaHome || "\bin\java" 
                IF (\(FileExists(_JavaCMD || ".exe")))
                        THEN DO
                                SAY "Error: 'java.exe' not found. Please check JAVA_HOME."
                                ShallWeRunAnt = False
                        END /* then */
                        ELSE ShallWeRunAnt = True
                IF FileExists(JavaHome || "\..\lib\tools.jar") THEN LocalClassPath = LocalClassPath || ";" || JavaHome || "\..\lib\tools.jar"
                IF FileExists(JavaHome || "\..\lib\classes.zip") THEN LocalClassPath = LocalClassPath || ";" || JavaHome || "\..\lib\classes.zip"
        END /* then */
        ELSE DO
                IF _JavaCMD = "" THEN _JavaCMD = "java"
                ShallWeRunAnt = True
                SAY ""
                SAY "Ant Warning: JAVA_HOME environment variable is not set."
                SAY "   If build fails because sun.* classes could not be found"
                SAY "   you will need to set the JAVA_HOME environment variable"
                SAY "   to the installation directory of Java."
                SAY ""
        END /* else */

/*
 * Run Ant
 */
IF ShallWeRunAnt = True
        THEN DO
                JikesPath = GetEnvironment("JIKESPATH")
                IF JikesPath = ""
                        THEN _JavaCMD || " -classpath " || LocalClassPath || " -Dant.home=" || AntHome || " " || GetEnvironment("ANT_OPTS") || " org.apache.tools.ant.Main " || GetEnvironment("ANT_ARGS") || " " || AntCommandLineArguments 
                        ELSE _JavaCMD || " -classpath " || LocalClassPath || " -Dant.home=" || AntHome || " -Djikes.class.path=" || JikesPath || " " || GetEnvironment("ANT_OPTS") || " org.apache.tools.ant.Main " || GetEnvironment("ANT_ARGS") || " " || AntCommandLineArguments
        END /* then */

/*
 * Cleanup
 */
LocalClassPath = ""
_JavaCMD = ""
AntCommandLineArguments = ""

OldLocal = ENDLOCAL()

PostFile = Home || "\AntRC_Post.CMD"
IF FileExists(PostFile)
        THEN DO
                SAY "Calling user post-file " PostFile
                ThisDir = DIRECTORY()
                CALL DIRECTORY Home
                CALL AntRC_Post.CMD
                CALL DIRECTORY ThisDir
                SAY "Back in Ant.CMD"
        END


EXIT
/* End of program */





/*
 * Procedures and functions
 */


/*
 * Sets an environment variable or appends a value to it
 */
AddEnvironment: PROCEDURE
PARSE ARG VarName, VarValue
IF (Value(VarName, , "OS2ENVIRONMENT")="")
     THEN CALL SetEnvironment VarName, VarValue
     ELSE CALL Value VarName, GetEnvironment(VarName) || ";" || VarValue, "OS2ENVIRONMENT"
RETURN


/*
 * Sets an environment variable
 */
SetEnvironment: PROCEDURE
PARSE ARG VarName, VarValue
CALL Value VarName, VarValue, "OS2ENVIRONMENT"
RETURN


/*
 * Returns the value of an environment variable
 */
GetEnvironment: PROCEDURE
PARSE ARG VarName
RETURN Value(VarName,,"OS2ENVIRONMENT")


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
 * Returns True if the given file exists
 */
FileExists: PROCEDURE
PARSE ARG FileName
CALL SysFileTree FileName, Result
RETURN Result.0 > 0

