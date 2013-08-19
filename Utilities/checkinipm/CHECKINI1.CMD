/*This REXX program provides a PMREXX user interface, GUI, to the checkini.exe program.*/
/*It uses PMREXX to provide a GUI for instructions on running checkini.exe by selecting one or more of */
/*its options. After the user selects one or more options, the program calls another REXX program,*/
/*CHECKINI2.CMD, to run the checkini.exe program in an OS/2 command window with the*/
/*selected options passed on to checkini.exe*/



/*Begin finding the location of this REXX program, the CHECKINI2.CMD REXX program and the checkini.exe executable file*/
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
/*End finding the location of this REXX program, the CHECKINI2.CMD REXX program and the checkini.exe executable file*/



/*Begin specifying the desired options for checkini.exe*/
ErrorChance = 5
TABLE:
SAY "This REXX program provides a PMREXX graphical user interface, GUI, to the checkini.exe program"
SAY ""
SAY ""
SAY "The following desired commandline options are available for executing checkini.exe:"
SAY ""
SAY "		OPTION DESCRIPTION								OPTION PARAMETER"
SAY "	Write the corrections to the ini-files with confirmations for every change.  (****)		/C"
SAY "	Specify a different location for the ini-files that are to be checked.				/Path"
SAY "	Specify a name (the path) for the logfile (the default is CHECKINI.LOG).			/L:LogFileName"
SAY "	Write all the output to the logfile (normally only problems are written).			/W"
SAY "	Write everything (all the output) to the logfile, but only the errors to the screen.		/W:2"
SAY "	Write everything to the logfile, but (almost) nothing to the screen.				/W:3"
SAY "	Run 'silent' and only write to the errors to the logfile (program runs faster).  (****)		/S"
SAY "	Do not report errors on network drives or removable local drives.  (****)			/R"
SAY "	Manually specify the location of the desktop (use only if checkini asks for it).		/D"
SAY "	Auto answer whether or not to correct each problem with a 'YES' (use only with /C).		/Y"
SAY "	Auto answer ...., with a 'YES' and also no confirmation for any individual tests.  (****)	/Y:2"
SAY "	Enable the disk scan function (do not use, if more than 1 OS/2 version installed).		/T"
SAY "   Only check on PM_Workplace:Handles0/1 (NOTE: could cause UNKNOWN OBJECT errors)			/H"
SAY "	The four (4) preferred options, '/C /S /R /Y:2', the ones with the four (4) asterisks		/P"
SAY "	Show information, or help.									/?"
SAY ""
SAY ""
SAY "If you want more than 1 option, separate each one with a space. Please select the desired commandline option,"
SAY "or options, as given above. Enter it, or them, on the PMREXX Input line, above. Then press the ENTER key."
PARSE UPPER PULL Options
SAY ""
SAY ""
SELECT
	WHEN ErrorChance = 0 THEN DO
		SAY "You have incorrectly entered the option data 5 times. You will not be able to correct"
		SAY "any more errors. Instead, this program will now terminate. Please try again, this time"
		SAY "correctly entering the desired options."
	END	/*Ends "" Section*/

	OTHERWISE DO
		CALL ERRORCHECKING
		NOP
	END	/*Ends "OTHERWISE DO" Section*/
END	/*Ends "SELECT" Section*/

IF TestFailure = "YES" THEN SIGNAL TABLE


/*Begin re-specifying the options in the format that checkini wants and uses*/
Options = ""
SELECT
	WHEN Part.0 = 1 & Part.1 = "/P" THEN
	Options = "/C /S /R /Y:2"

	OTHERWISE DO
		DO M = 1 TO Part.0 BY 1
			Options = Options" "Part.M
		END M	/*Ends "DO M = 1 TO Part.0 BY 1" Section*/
	END	/*Ends "OTHERWISE DO" Section*/
END	/*Ends "SELECT" Section*/
/*End re-specifying the options in the format that checkini wants and uses*/
/*End specifying the desired options for checkini.exe*/



/*Begin calling the CHECKINI2.CMD REXX procedure, which in turn will call the checkini.exe program*/
SAY "You must now open the 'CALL "ProgramLocation"\CHECKINI2.CMD ...,' OS/2 command window, using the"
SAY "OS/2 Window List (CNTRL-ESC). Double left mouse click on 'CALL "ProgramLocation"\CHECKINI2.CMD ...,'"
SAY "in the OS/2 Window List and then press the ENTER key in the OS/2 command window session that results."
SAY "Finally, follow the instructions from checkini.exe."
Commandline = "CALL "ProgramLocation"\CHECKINI2.CMD "Options
INTERPRET "Commandline"
/*End calling the CHECKINI2.CMD REXX procedure, which in turn will call the checkini.exe program*/



/*Begin specifying whether or not you wish to open the checkini log file*/
SAY ""
SAY ""
SAY "Please select whether or not you wish to open the checkini log file. Enter a 'Y' (or, a 'y') if you"
SAY "want to open the log file. Otherwise, just press the ENTER key."
SAY ""
SAY ""
PARSE UPPER PULL Response
SELECT
	WHEN Response = "Y" THEN DO
		CALL OPENLOGFILE
		NOP
	END

	OTHERWISE NOP
END	/*Ends "SELECT" Section*/
/*End specifying whether or not you wish to open the checkini log file*/
FINISH:
EXIT









ERRORCHECKING:
TestFailure = "NO"
LogFileName = ""
Part. = ""
Test. = ""
Remaining = "Harry"
Selections = Options
M = 0
DO UNTIL Remaining = ""
	M = M + 1
	LogFileNameTest = LEFT(Selections,3)
	SELECT
		WHEN LogFileNameTest = "/L:" THEN DO	/*Parse the options, when a log file name is specified*/
			PARSE VAR Selections Part.M Remaining
			Selections = Remaining
			PartLength = LENGTH(Part.M)
			DesiredLength = (PartLength - 3)
			LogFileName = SUBSTR(Part.M,4,DesiredLength)
			Part.M = "/L"LogFileName
		END	/*Ends "WHEN LogFileNameTest = "/L:" THEN DO" Section*/
		
		OTHERWISE DO	/*Parse the options, when a log file is not specified*/
			PARSE VAR Selections Part.M Remaining
			Selections = Remaining
		END	/*Ends "OTHERWISE DO" Section*/
	END	/*Ends "SELECT" Section*/
END	/*Ends "DO UNTIL Remaining = """ Section*/
Part.0 = M
DO M = 1 TO Part.0 BY 1
	Test = LEFT(Part.M,1)
	SELECT
		WHEN Test \= "/" THEN DO
			ErrorChance = (ErrorChance - 1)
			TestFailure = "YES"
			SAY "You did not enter the options correctly. You left out a preceding '/' on one or more of the options."
			SAY "Please re-enter the desired options correctly. If you do not enter the options correctly, you will"
			SAy "have only "ErrorChance "more chances to correct the mistake(s)."
			SAY ""
			SAY ""
			SAY ""
			SAY ""
			LEAVE
		END	/*Ends "WHEN Test \= "/" THEN DO" Section*/

		OTHERWISE NOP
	END	/*Ends "SELECT" Section*/
END M	/*Ends "DO M = 1 TO Part.0 BY 1" Section*/
RETURN









OPENLOGFILE:
SAY "You must now open the log file by selecting the OS/2 System Editor, using the OS/2 Window List."
SAY "Press the CONTROL-ESCAPE keys to open the OS/2 Window List. Double mouse click on the 'E.EXE'"
SAY "choice in the window list."
SELECT
	WHEN LogFileName = "" THEN LogFile = "CHECKINI.LOG"

	OTHERWISE LogFile = LogFileName
END	/*Ends "SELECT" Section*/
LogFilePath = ProgramLocation"\"LogFile
Commandline = 'E.EXE "'LogFilePath'"'
INTERPRET "Commandline"
RETURN
