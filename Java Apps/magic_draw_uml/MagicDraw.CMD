/*
 *  Magic Draw UML v. 8.0 CE command line launcher for OS/2 and eComStation
 *
 *  jkacer@kiv.zcu.cz
 *
 *  Tested with Colden Code Java 1.4.1 on eComStation 1.1.
 *  Java\bin or Java\jre\bin must be in your PATH.
 *  JAVA_HOME should also be set.
 *
 *
 *******************************************************************************
 *  This OS/2 startup script does not use 'mduml.properties' to pass arguments
 *  to JVM as its Unix counterpart. If you want to change some arguments, change
 *  them in the file 'MagicDraw.CMD'.
 *  But keep the original 'mduml.properties' in your 'bin' directory!
 *******************************************************************************
 */

IF GetScriptPath() \= GetCurrentDir()
	THEN DO
		SAY "----------------------------------------------------"
		SAY "Please run MagicDraw.CMD from the 'bin' subdirectory"
		SAY "of your MagicDraw installation."
		SAY "----------------------------------------------------"
		EXIT
	END

MagicDraw_MainClass = "com.nomagic.magicdraw.Main"
MagicDraw_Launcher = "com.nomagic.launcher.Launcher"
MagicDraw_PropertiesFile = "mduml.properties"
MagicDraw_AppArgs = ""

Java_ClassPath = " -cp "
Java_ClassPath = Java_ClassPath || "..\lib\patch.jar;..\lib\activation.jar;..\lib\batik.jar;..\lib\cvsclient.jar;"
Java_ClassPath = Java_ClassPath || "..\lib\fop.jar;..\lib\jedit_syntax.jar;..\lib\jgl.jar;..\lib\jhall.jar;"
Java_ClassPath = Java_ClassPath || "..\lib\jide-common.jar;..\lib\jide-dock.jar;..\lib\jimi.jar;..\lib\kunststoff.jar;"
Java_ClassPath = Java_ClassPath || "..\lib\launcher.jar;..\lib\log4j-1.2.7.jar;..\lib\mail.jar;..\lib\tidy.jar;"
Java_ClassPath = Java_ClassPath || "..\lib\xalan.jar;..\lib\xercesImpl.jar;..\lib\xfc.jar;..\lib\xml-apis.jar;"
Java_ClassPath = Java_ClassPath || "..\lib\md.jar;..\lib\y.jar;..\lib\jide-grids.jar;..\lib\CaliberRMSDK65.jar"
Java_BootClassPath = " -Xbootclasspath/p:..\lib\xalan.jar"
/*
  The original value for X-args was '-Xmx400M' which caused that GC Java 1.4.1 was not able to start.
  Not specifying any value works fine, at least for me.
*/
Java_XArguments = " " 
Java_DArguments = " -DMAIN_CLASS=" || MagicDraw_MainClass || " -Dlauncher.properties.file=" || MagicDraw_PropertiesFile

LaunchCommand = "java" || Java_XArguments || Java_BootClassPath || Java_DArguments || Java_ClassPath || " " || MagicDraw_Launcher || MagicDraw_AppArgs || " " || ARG(1)
SAY "Launching MagicDraw UML 8.0 Community Edition..."
LaunchCommand
EXIT


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
 * Returns the current directory, without "\" at the end.
 */
GetCurrentDir: PROCEDURE
RETURN DIRECTORY()
