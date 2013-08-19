/*REXX script to determine the file system types on local and remote partitions*/



/*Begin registering the REXXUtil Library, if not already registered*/
REXXUtilityFlag = RXFUNCQUERY("SYSLOADFUNCS")
IF REXXUtilityFlag \= 0 THEN DO
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
	CALL SysLoadFuncs
END	/*Ends "IF REXXUtilityFlag \= 0 THEN DO" Section*/
/*End registering the REXXUtil Library, if not already registered*/



/*Begin miscellaneous variables*/
Red_Text = "1B"x || "[1;31;40m"
Ansi_Off = "1B"x || "[0m"
/*End miscellaneous variables*/


/*Begin finding the necessary, user system-specific information*/
/*Begin finding the File Spec information on this REXX program, or script, and assigning its value to the variable, ProgramLocation, here in this program*/
PARSE SOURCE OperatingSystem HowCalled FileSpec
ProgramLocation = ""
FileSpecPortion = FileSpec
DO UNTIL FileSpecPortion = ""
	PARSE Var FileSpecPortion FirstPart "\" SecondPart
	SELECT
		WHEN ProgramLocation = "" & SecondPart \= "" THEN ProgramLocation = FirstPart
		WHEN ProgramLocation \= "" & SecondPart \= "" THEN ProgramLocation = ProgramLocation"\"FirstPart
		OTHERWISE NOP
	END	/*Ends "SELECT" Section*/
	FileSpecPortion = SecondPart
END	/*Ends "DO UNTIL FileSpecPortion = """ Section*/
/*End finding the File Spec information on this REXX program, or script, and assigning its value to the variable, ProgramLocation, here in this program*/



/*Begin finding the installed, or recognized drive information*/
DDrive. = ""
Drive. = ""
DDrive.0 = 0
Drive.0 = 0
Map = SYSDRIVEMAP(, "LOCAL")
J = 0
DO UNTIL Map = ""
	J = J + 1
	PARSE VAR Map First Remainder
	DDrive.J.PPartition = First
	FileSystem = TRANSLATE(SYSFILESYSTEMTYPE(DDrive.J.PPartition))
	DDrive.J.DriveLetter = LEFT(DDrive.J.PPartition, 1)
	DDrive.J.CapDriveLetter = TRANSLATE(DDrive.J.DriveLetter, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz")
	DDrive.J.DriveNumber = J
	DDrive.J.FFileSystem = FileSystem
	Map = Remainder
END	/*Ends "DO UNTIL Map = """ Section*/
DDrive.0 = J


Map = SYSDRIVEMAP(, "REMOTE")
J = 0
SELECT
	WHEN Map \= "" THEN DO
		DO UNTIL Map = ""
			J = J + 1
			PARSE VAR Map First Remainder
			Drive.J.PPartition = First
			FileSystem = TRANSLATE(SYSFILESYSTEMTYPE(Drive.J.PPartition))
			Drive.J.DriveLetter = LEFT(Drive.J.PPartition, 1)
			Drive.J.CapDriveLetter = TRANSLATE(Drive.J.DriveLetter, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz")
			Drive.J.DriveNumber = J
			Drive.J.FFileSystem = FileSystem
			Map = Remainder
		END	/*Ends "DO UNTIL Map = """ Section*/
		Drive.0 = J
	END	/*Ends "WHEN Map \= "" THEN DO" Section*/

	OTHERWISE NOP
END	/*Ends "SELECT" Section*/
/*End finding the installed, or recognized drive information*/



/*Begin stating and writing what the installed file systems are*/
Count = 0
Line. = ""
IF DDrive.0 > 0 THEN DO
	DO J = 1 TO DDrive.0 BY 1
		SAY "The installed file system type for the "DDrive.J.PPartition" local partition is: "DDrive.J.FFileSystem
		Count = Count + 1
		Line.Count = "The installed file system type for the "DDrive.J.PPartition" local partition is: "DDrive.J.FFileSystem
	END J	/*Ends "DO J = 1 TO DDrive.0 BY 1" Section*/
END	/*Ends "IF DDrive.0 > 0 THEN DO" Section*/

SAY ""
Count = Count + 1
Line.Count = " "
IF Drive.0 > 0 THEN DO
	DO J = 1 TO Drive.0 BY 1
		SAY "The installed file system type for the "Drive.J.PPartition" local partition is: "Drive.J.FFileSystem
		Count = Count + 1
		Line.Count = "The installed file system type for the "Drive.J.PPartition" remote partition is: "Drive.J.FFileSystem
	END J	/*Ends "DO J = 1 TO Drive.0 BY 1" Section*/
END	/*Ends "IF Drive.0 > 0 THEN DO" Section*/
ELSE DO
	SAY "You have no remote partitions!"
	Count = Count + 1
	Line.Count = "You have no remote partitions!"
END	/*Ends "ELSE DO" Section*/
SAY ""
SAY 'Please E-Mail the ASCII text file, "HELP.TXT", to me at: hmotin@attglobal.net'
SAY ""
SAY "You will find it in the same directory where you saved/stored this REXX script."
SAY "It contains only the above information, the installed file system types on your"
SAY "computer (local and remote partitions)."
SAY ""
SAY "Thank you very much for your help!"
SAY ""
SAY "Press the "Red_Text"ENTER"Ansi_Off" key to end this program."
PARSE PULL KeyResponse
RC = SYSCLS()
Line.0 = Count
/*End stating and writing what the installed file systems are*/



/*Begin writing the HELP.TXT text file*/
HELP_File_Path = ProgramLocation"\HELP.TXT"
RC = SYSFILEDELETE(HELP_File_Path)
DO J = 1 TO Line.0 BY 1
	RC = LINEOUT(HELP_File_Path, Line.J)
END J
RC = LINEOUT(HELP_File_Path)
Count = ""
/*End writing the HELP.TXT text file*/



/*Begin deregistering the REXX Utility functions and closing out this script*/
IF REXXUtilityFlag \= 0 THEN CALL SysDropFuncs
/*End deregistering the REXX Utility and closing out this script*/
EXIT
/*End closing out the script and exiting*/
