/*This REXX program provides a command line user interface to the checkini.exe program*/
/*It accepts option parameters from the CHECKINI1.CMD program and*/
/*then executes, or calls, checkini.exe with those parameters*/



/*Begin finding the location of this REXX program, the CHECKINI1.CMD REXX program and the checkini.exe executable file*/
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
/*End finding the location of this REXX program, the CHECKINI1.CMD REXX program and the checkini.exe executable file*/



/*Begin running the checkini.exe program in another OS/2 windowed session*/
ARG Options	/*Get the value of the argument passed to CHECKINI2.CMD and assign it to the variable, Options*/
Commandline = "CD "ProgramLocation
INTERPRET "CommandLine"		/*Change to the checkini.exe subdirectory*/
Commandline = "Checkini.exe "Options	/*Start checkini.exe with the selected options*/
INTERPRET "CommandLine"
/*End running the checkini.exe program in another OS/2 windowed session*/
EXIT
