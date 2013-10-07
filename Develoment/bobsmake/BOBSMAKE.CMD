/* This REXX Procedure processes my own type of make file
   because the NMAKE command is too screwed up
*/

SAY 'This is an unregistered copy of BobsMake.cmd'

Verbose = 'No'
IterateUntilDone = 'No'

 /* These lines are inserted in the generated REXX Command */

REXXProcLine = '/* This REXX Proce, BMAKETMP.CMD, is used by BOBSMAKE */'
PullArgLine = 'ARG TargetFile TargetDrive TargetPath TargetFullName TargetName TargetSuffix'
REXXCommentLine = '/* End of Automatic REXX, Remainder From MakeFile */'

 /* Get the make file name */
parse ARG MakeFile

If MakeFile = '' then Do
    SAY 'Make File Name Not Specified'
    SAY 'Using Default MakeFile name of "BobsMake.MAK"'
    end

If LINES(MakeFile) = 0 then Do
    SAY MakeFile ' Does Not Exist'
    Return
    end

/*  Get the currrent directory and drive information */

StartingDirectory = DIRECTORY()

If Verbose = 'Yes' then SAY 'Current Directory = ' StartingDirectory

StartingDrive = FILESPEC("drive",StartingDirectory)

If Verbose = 'Yes' then SAY 'Current Drive     = ' StartingDrive

/*  Load in all of the REXX System Support Functions */

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

IF RxFuncQuery('HLLAPI') THEN
   CALL RxFuncAdd 'HLLAPI','SAAHLAPI','HLLAPISRV';

IF RxFuncQuery('SQLDBS') THEN
   CALL RxFuncAdd 'SQLDBS','SQLAR','SQLDBS';

IF RxFuncQuery('SQLEXEC') THEN
   CALL RxFuncAdd 'SQLEXEC','SQLAR','SQLEXEC';

If RxFuncQuery('SQLDBS') <> 0 then
   rcy = RxFuncAdd( 'SQLDBS',  'DB2AR', 'SQLDBS'  )

If RxFuncQuery('SQLEXEC') <> 0 then
   rcy = RxFuncAdd( 'SQLEXEC', 'DB2AR', 'SQLEXEC' )

SAY 'Rexx Functions Loaded'

TookAction = 'Starting'
SetVar.0 = 0
Pass = 0
Do While (TookAction <> 'No')
    Pass = Pass + 1
    SAY 'Starting Pass ' Pass
    TookAction = 'No'
    Do while (LINES(MakeFile) = 1)
        CurrentLine = LINEIN(MakeFile)
        If Verbose = 'Yes' then SAY 'Processing Line = ' CurrentLine
        PARSE UPPER VAR CurrentLine CommandName RemainderOfLine
        If Verbose = 'Yes' then SAY 'CommandName = ' CommandName
        If CommandName = 'SETDIR'  then Call SetAndGetDirectory
          Else
            If CommandName = 'IFCOND'  then Call ProcessIfCondition
          Else
            If CommandName = 'SETLIST' then Call ProcessSetList
          Else
            If WORDS(CurrentLine) > 0 then Do
                ExecutionLines = STRIP(CurrentLine)
                If Verbose = 'Yes' then SAY 'ExecutionLines = ' ExecutionLines
                INTERPRET ExecutionLines
                end

          If IterateUntilDone = 'No' then TookAction = 'No'

        End
    rc = STREAM(MakeFile, 'C', 'CLOSE')
    End

SAY 'Finished Passing The Make File'

ADDRESS CMD StartingDrive
ADDRESS CMD 'CD ' StartingDirectory
Return

SetAndGetDirectory:
    If Verbose = 'Yes' then SAY 'Entered SetAndGetDirectory'

/* The format of this command is :

    "SETDIR = directoryname"

    Technically this command is not required because the
    user can code their own drive and CD commands in the
    makefile

*/


    If WORD(CurrentLine,2) <> '=' then Return
    Directory = WORD(CurrentLine,3)
    If LENGTH(Directory) = 0 then Return

    If SUBSTR(Directory, LENGTH(Directory), 1) ª= '\' then Directory = Directory || '\'

    Drive    = FILESPEC("drive",Directory)
    NewPath  = FILESPEC("path",Directory)

    If Verbose = 'Yes' then SAY 'NewPath = ' NewPath

    NewPath = SUBSTR(NewPath, 1, LENGTH(NewPath) - 1)
    If Verbose = 'Yes' then SAY 'NewPath = ' NewPath

    ADDRESS CMD Drive
    ADDRESS CMD 'CD ' NewPath
    Return


ProcessIfCondition:
    If Verbose = 'Yes' then SAY 'Entered ProcessIfCondition'

/* The format of this command is :

    "IFCOND targetname < sourcename then DOCOND
         your REXX commands
         ENDCOND"

    Although the '<' and 'then DOCOND' are not explicitly parsed
    they are required parameters. This is so that the command
    can be enhanced later.
*/

    If Verbose = 'Yes' then SAY 'Number of words in line = ' WORDS(CurrentLine)
    If WORDS(CurrentLine) < 4 then DO
        If Verbose = 'Yes' then SAY 'Returning because there are less then 4 words'
        Return
        End

    DROP TargetFiles
    DROP TargetFilesDates
    DROP SourceFiles
    DROP SourceFilesDates
    
    TargetFile = WORD(CurrentLine,2)
    rc = SysFileTree(TargetFile, TargetFiles, 'FT' )

    If Verbose = 'Yes' then SAY 'Number of Target files = ' TargetFiles.0
    TargetFilesDates.0 = TargetFiles.0
    Do I = 1 to TargetFiles.0
        If Verbose = 'Yes' then SAY 'TargetFiles.'||I|| ' = ' || TargetFiles.I
        SourceFileWorkLine = TargetFiles.I
        Call GetSourceFileCreationDate
        TargetFilesDates.I = FileCreationDate
        end

    TempSourceFile = WORD(CurrentLine, 4)
    PARSE UPPER VAR TempSourceFile SourceFile SourceFileRemainder

    If Verbose = 'Yes' then SAY 'SourceFile = ' SourceFile

/* Check the SourceFile to see if it is a ListName */

    SourceFileCount = 0

    If Verbose = 'Yes' then SAY 'ListNames to review = ' SetVar.0

    If SetVar.0 > 0 then Do I = 1 to SetVar.0

        If Verbose = 'Yes' then SAY 'Checking for a match on ' WORD(SetVar.I, 1)

        If SourceFile = WORD(SetVar.I, 1) then Do

            SourceFileCount = WORD(SetVar.I, 2)
            Do J = 1 to SourceFileCount

                If Verbose = 'Yes' then SAY 'Adding file to end = ' WORD(SetVar.I, 2 + J)

                SourceFileName.J = WORD(SetVar.I, 2 + J)
                End
            If SourceFileCount > 0 then Leave
            End
        End
      Else Do

        If Verbose = 'Yes' then SAY 'Processing Only 1 File Name'

        SourceFileCount = 1
        SourceFileName.1 = SourceFile
        End

/*
   Now iterate through the list of names, retrieving the tree information
   for each entry and building a 'SUPER' tree containing all of the files
*/

    SourceFiles.0 = 0
    Do I = 1 to SourceFileCount
        If Verbose = 'Yes' then SAY 'Getting the file tree for ' SourceFileName.I
        rc = SysFileTree(SourceFileName.I, TempFiles, 'FT')
        If Verbose = 'Yes' then SAY 'Found ' TempFiles.0 ' Files to check'
        Do J = 1 to TempFiles.0
            If Verbose = 'Yes' then SAY 'Adding ' TempFiles.J ' To SourceFiles'
            SourceFiles.0 = SourceFiles.0 + 1
            K = SourceFiles.0
            SourceFiles.K = TempFiles.J
            If Verbose = 'Yes' then SAY 'Number of Source Files = ' SourceFiles.0
            End
        End

    If Verbose = 'Yes' then SAY 'Number of Source files = ' SourceFiles.0
    SourceFilesDates.0 = SourceFiles.0
    Do I = 1 to SourceFiles.0
        If Verbose = 'Yes' then SAY 'SourceFiles.'||I|| ' = ' || SourceFiles.I
        SourceFileWorkLine = SourceFiles.I
        Call GetSourceFileCreationDate
        SourceFilesDates.I = FileCreationDate
        end

    'DEL BMAKEF.CMD'

    rc = LINEOUT('BMAKEF.CMD', REXXProcLine)
    rc = LINEOUT('BMAKEF.CMD', PullArgLine)
    rc = LINEOUT('BMAKEF.CMD', REXXCommentLine)

    Continue = 'Yes'
    Do While ((Continue = 'Yes') & (LINES(MakeFile) = 1))
        IfLine = LINEIN(MakeFile)
        PARSE UPPER VAR IfLine IfCommand IfRemainder
        If IfCommand = 'ENDCOND' then Do
            Continue = 'No'
            Iterate
            End
          Else Do
            If Verbose = 'Yes' then SAY 'IFCommand = '
            rc = LINEOUT('BMAKEF.CMD', IfLine)
            End
        end

    rc = STREAM('BMAKEF.CMD','C','CLOSE')

 /*  Iterate through the TargetFiles and execute the users commands */
 
    Do I = 1 to TargetFiles.0
        If Verbose = 'Yes' then SAY 'Processing Target File ' I ' file = ' TargetFiles.I
        ActivateREXXProc = 'No'
        Do J = 1 to SourceFiles.0
            If Verbose = 'Yes' then SAY 'Checking Source File ' I ' file = ' SourceFiles.I
            If Verbose = 'Yes' then SAY 'Target Date = ' TargetFilesDates.I 'Source Date = ' SourceFilesDates.J
            If SourceFilesDates.J > TargetFilesDates.I then ActivateREXXProc = 'Yes'
            end
        If ActivateREXXProc = 'Yes' Then Do
             TempTargetFile = WORD(TargetFiles.I, 4)
             TempTargetDrive     = FILESPEC("drive", TempTargetFile)
             TempTargetPath      = FILESPEC("path",  TempTargetFile)
             TempTargetFullName  = FILESPEC("name",  TempTargetFile)
             FirstPeriod = POS('.', TempTargetFullName)
             TempTargetName = SUBSTR(TempTargetFullName, 1, FirstPeriod - 1)
             TempTargetSuffix = SUBSTR(TempTargetFullName, FirstPeriod + 1, LENGTH(TempTargetFullName) - FirstPeriod)

             If Verbose = 'Yes' then SAY 'Target file parms = ' TempTargetFile TempTargetName TempTargetSuffix

            'CALL BMAKEF.CMD' TempTargetFile TempTargetDrive TempTargetPath TempTargetFullName TempTargetName TempTargetSuffix
            End
        end

    DROP TargetFiles
    DROP TargetFilesDates
    DROP SourceFiles
    DROP SourceFilesDates
    
    Return


ProcessSetList:
    If Verbose = 'Yes' then SAY 'Entered ProcessSetList'


/* The format of this command is :

    "SETLIST listname = (name1, name2, ..., namen)"

    Although the '='is not explicitly parsed it is a required
    parameter. This is so that the command can be enhanced later.

*/

    SetVar.0 = SetVar.0 + 1
    NumberOfSetVars = SetVar.0

/*  take the command apart. First extract the list name, then extract the
    names from the list. Combine them again in the following form:

    ListName NumberOfNames Name1 Name2 Name3 ... NameN

    Then place them into the setvar structure as one string.
*/

    WorkLine = STRIP(CurrentLine)

/* Remove the SETLIST and any trailing blanks */

    WorkLine = STRIP(SUBSTR(WorkLine, 9, LENGTH(WorkLine)-8))

    If Verbose = 'Yes' then SAY 'Stripped SETLIST Command = ' WorkLine

/* Find the End of the ListName by searching for the '=' */

    EqualPosition = POS('=', WorkLine)

/* Extract the ListName */

    WorkListName = STRIP(SUBSTR(WorkLine, 1, EqualPosition - 1))

    PARSE UPPER VAR WorkListName ListName LNRemainder


    If Verbose = 'Yes' then SAY 'ListName = ' ListName

/* Point to the first character of the list of variables */

    WorkLine = STRIP(SUBSTR(WorkLine, EqualPosition + 1, LENGTH(WorkLine) - EqualPosition))

/* Look for a left paren. If one exists then process a list, if one does not exist
   process a single variable
*/

    If Verbose = 'Yes' then SAY 'Name List = ' WorkLine

    If SUBSTR(WorkLine, 1, 1) = '(' then do

/*
    Names must be separated by spaces, so if commas are being use
    then replace them with spaces so that the parsing can be by word.
    Also remove the parens.
*/

        WorkLine = SUBSTR(WorkLine, 2, LENGTH(WorkLine) - 2) /*remove the parens*/

        If Verbose = 'Yes' then SAY 'Name List without Parens = ' WorkLine

        CommaPosition = POS(',', WorkLine)                   /* remove the commas */
        Do While (CommaPosition > 0)

            If Verbose = 'Yes' then SAY 'Comma Position = ' CommaPosition

            WorkLine = OVERLAY(' ', WorkLine, CommaPosition, 1)

            If Verbose = 'Yes' then SAY 'New Name List = ' WorkLine

            CommaPosition = POS(',', WorkLine)
            End

        NumberOfNames = WORDS(WorkLine)
        NameString = WorkLine
 
        End
      Else Do
        NumberOfNames = 1
        NamesString = WORD(WorkLine, 1)
        End

    If Verbose = 'Yes' then SAY 'Number Of Names = ' NumberOfNames
    If Verbose = 'Yes' then SAY 'NameString = ' NameString

    SetVar.NumberOfSetVars = ListName NumberOfNames NameString

    If Verbose = 'Yes' then SAY 'Number of ListNames = ' SetVar.0
    If Verbose = 'Yes' then SAY 'ListName string = ' SetVar.NumberOfSetVars

    Return

GetSourceFileCreationDate:
    If Verbose = 'Yes' then Say 'Entered GetSourceFileCreationDate'

    FileCreationDate = WORD(SourceFileWorkLine, 1)

    Return

