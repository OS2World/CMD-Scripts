/*************************************************************************
 RDX V2.00 (C) 1994 James Brombergs

   RDX /L
        Edit lookup table

   RDX [/+] [/B] [/T] [[-]drivelist:]dirname

        /+ = Include drives A: and B: in search (excluded by default)
        /B = Accept first matching directory without prompting
        /T = Search lookup table only

        drivelist = drives to search
            *: search all drives starting at C:
          ddd: search only drives ddd
         -ddd: search all drives except ddd, starting at C:

        dirname = directory name (with optional wildcards) to search for
 
   <SPACE> continue search
   <ESC>   cancel search, revert to original directory
   any other key to accept directory
 *************************************************************************/
/* The text above is displayed as the help screen */

'@ECHO OFF'
SAY "RDX v2.00"
SAY

/* -----------------------------------------------------------------------
   Load REXXUTIL
   ----------------------------------------------------------------------- */
IF( RxFuncQuery( "SysLoadFuncs" ) <> 0 ) THEN
     IF( RxFuncAdd( "SysLoadFuncs", "RexxUtil", "SysLoadFuncs" ) <>0 ) THEN
          CALL Error "Unable to load REXX Utility functions.";
CALL SysLoadFuncs

/* -----------------------------------------------------------------------
   Set exception handlers
   ----------------------------------------------------------------------- */
SIGNAL ON FAILURE NAME Terminate
SIGNAL ON HALT NAME Terminate
SIGNAL ON SYNTAX NAME SyntaxTrap
SIGNAL ON ERROR NAME ErrorTrap
SIGNAL ON NOVALUE NAME NoValueTrap

/* -----------------------------------------------------------------------
   Lookup Table
   Entries are of form eg
    lookUp.1.key = "WIN"
    lookUp.1.dir = "E:\OS2\MDOS\WINOS2"
    lookUp.0 contains the number of entries in the table and is put at the 
             end of the table.

   Use quotation marks around key and dir entries. 
   Entries are not case-sensitive
   ----------------------------------------------------------------------- */
/* !!! DO NOT CHANGE THE NEXT LINE !!! */
/*LOOKUP*/
lookUp.0 = 0
/*ENDLOOKUP*/
/* !!! DO NOT CHANGE THE LAST LINE EITHER !!! */

/* -----------------------------------------------------------------------
   save environment to allow restoring cwd in case of errors
   ----------------------------------------------------------------------- */
n = SETLOCAL();           

/* -----------------------------------------------------------------------
   check command line arguments
   ----------------------------------------------------------------------- */
ARG arg.1 arg.2 arg.3 arg.4 .

IF( arg.1 = "" ) THEN SIGNAL Help;
IF( arg.1 = "/L" ) THEN DO
    CALL EditLookupTable;
    EXIT;
END

searchParam = ""; /* set to string containing <drivelist>:<dirname> if found */
acceptFirst = 0;  /* set to 1 if /B switch found */
includeAB = 0;    /* set to 1 if /+ switch found */
lookupOnly = 0;   /* set to 1 if /Q switch found */

DO i = 1 TO 4
    SELECT
        WHEN( arg.i = "" ) THEN NOP;
        WHEN( ( arg.i = "/?" ) | ( arg.i = "/H" ) ) THEN SIGNAL Help;
        WHEN( arg.i = "/B" ) THEN acceptFirst = 1;
        WHEN( arg.i = "/+" ) THEN includeAB = 1;
        WHEN( arg.i = "/T" ) THEN lookupOnly = 1;
        OTHERWISE IF( searchParam = "" ) THEN searchParam = arg.i;
    END
END
DROP i

IF( searchParam = "" ) THEN SIGNAL Help; /* no target specified */

/* -----------------------------------------------------------------------
   Main procedure                                           
   ----------------------------------------------------------------------- */
PARSE UPPER VAR searchParam drivelist ":" pathTemplate .

IF( pathTemplate = "" ) THEN DO  /* if there wasn't a colon we have */
    pathTemplate = drivelist;    /* to swap the variables and */
    drivelist = "";              /* just search current drive */
END
ELSE
    drivelist = MakeDriveList( drivelist, includeAB );

DROP searchParam

/* search the lookup table first */
newPath  = SearchIt( "LOOKUP", pathTemplate, (acceptFirst*2) );

IF( ( newPath = 0 ) & ( lookupOnly = 0 ) ) THEN DO
    /* check for illegal chars, note * and ? are legal as wildcards */
    IF( VERIFY( pathTemplate, '/\":|', "MATCH" ) \= 0 ) THEN 
        CALL Error( "Invalid path" );

    /* add wildcard, no problem if theres already one so dont need to check */
    pathTemplate = pathTemplate || '*';
    numDrives = LENGTH( driveList );

    IF( numDrives = 0 ) THEN DO     /* search current drive only */
        newPath = SearchIt( "CURRENT", pathTemplate, (acceptFirst+1) );
    END
    ELSE DO
        flag = acceptFirst * 2;

        DO i = 1 TO numDrives
            IF( flag = 0 ) THEN flag = ( i = numDrives );
            newPath = SearchIt( SUBSTR( driveList, i, 1 ), pathTemplate, flag );
            IF( newPath \= 0 ) THEN LEAVE;
        END

    END

END

/* restore environment before changing path or original directory will be 
   restored on termination */
n = ENDLOCAL();

IF( newPath \= 0 ) THEN 
    IF( DIRECTORY( newPath ) \= newPath ) THEN
        SAY "Cannot locate the directory " newPath;

DROP driveList numDrives newPath pathTemplate
EXIT

/* ----------------------------------------------------------------------------------- 
   MakeDriveList
    Puts letters of drives to search in a string, and returns the string. Drives not 
    recognised by the system or not responding (eg empty floppy drives) are ignored. 
    If <addAB> is 1 and <drvlist> is * or -ddd then drives A: and B: are added to the 
    list.
   <drvlist> = drive list from command line, one or more letters, no spaces.
    If * or - are given, they must be the first character.
   ----------------------------------------------------------------------- */
MakeDriveList: PROCEDURE
ARG drvlist, addAB

if( drvlist = "" ) THEN RETURN drvlist;

firstchar = SUBSTR( drvlist, 1, 1 );

/* get drives recognised by system */
if( firstchar = '*' | firstchar = '-' ) THEN 
    IF( addAB = 1 ) THEN
        /* include A: and B: according to command line option */
        drvmap = SysDriveMap( "A:" );   
    ELSE
        /* omit A: and B: by default when searching multiple drives */
        drvmap = SysDriveMap();         
ELSE
    drvmap = SysDriveMap( "A:", "USED" );

maplen = LENGTH( drvmap );

validlist = "";  /* string to put valid drive letters in */
pchar = 1;       /* pointer to drive letter in drvmap */

DO WHILE( pchar < maplen )
    drvletter = SUBSTR( drvmap, pchar, 1 );  /* get the drive letter */
    pchar = pchar + 3;                       /* point to next drvmap entry */

    IF( firstchar = '-' ) THEN DO            /* ignoring listed drives */
        IF( POS( drvletter, drvlist ) \= 0  ) THEN 
            ITERATE;                         /* skip it if its on list */
    END
    ELSE                                     /* searching listed drives only */
        IF( ( firstchar \= '*' ) & ( POS( drvletter, drvlist ) = 0 ) ) THEN 
            ITERATE;                         /* skip if its not on list */

    /* check that drive is responding by trying to open a file called "*" in root directory
       NOTREADY:2 means file not found as we would expect, anything else would indicate
       a hard fail eg CD-ROM or floppy drive with no disk, etc */
    IF( STREAM( drvletter || ":*", 'C', "OPEN" ) \= "NOTREADY:2" ) THEN ITERATE;

    IF( POS( drvletter, validlist ) = 0 ) THEN  /* check drive is not already listed */
        validlist = validlist || drvletter;     /* add drive to the string if its all OK */
END

DROP drvlist firstchar drvmap maplen pchar drvletter
RETURN validlist

/* ----------------------------------------------------------------------- 
   SearchIt
     Searches <what> for directory names matching <template>.
     <what> may be a drive letter, "CURRENT" to search the current
     drive or "LOOKUP" to search the lookup table.
     Returns selected path or 0 if none is found.
     If <firstmatch> = 1 and only one matching path is found, it is
     automatically selected. User is asked to select if there is a
     choice. 
     if <firstmatch> = 2 the first matching path is accepted without
     asking, even if there is a choice.
   ----------------------------------------------------------------------- */
SearchIt: PROCEDURE EXPOSE lookUp.
Arg what, template, firstmatch

count = 0;
IF( what = "LOOKUP" ) THEN DO
    nChars = LENGTH( template );

    DO index = 1 TO lookUp.0
        PARSE UPPER VAR lookUp.index.key lookupKey .

        IF( template = SUBSTR( lookupKey, 1, nChars ) ) THEN DO
            count = count + 1;
            path.count = lookUp.index.dir;
        END
    END

    path.0 = count;
    DROP nChars count lookupKey
END
ELSE DO
    /* set cwd to root dir of drive depending on <what>, search for files
       matching template, put matches into array 'path', scan recursively, 
       directories only, report paths only */
    IF( what = "CURRENT" ) THEN DO
        CALL DIRECTORY( "/" );
        CALL SysFileTree template, "path", "SDO"
    END
    ELSE DO
        curDir = DIRECTORY( what || ":" );   /* save cwd */
        CALL DIRECTORY( what || ":/" );      /* switch to root */
        CALL SysFileTree template, "path", "SDO"
        CALL DIRECTORY( curDir );            /* restore cwd */
    END
END

IF( path.0 = 0 ) THEN RETURN 0;          /* no matching paths */

IF( firstmatch = 2 ) THEN RETURN path.1; /* take first without asking */

/* if theres only 1 match and firstmatch = 1 then dont bother asking */
IF( ( path.0 = 1 ) & ( firstmatch = 1 ) ) THEN 
    found = path.1;
ELSE DO
    found = 0   /* init success flag */ 
    index = 1   /* init index to path array */

    DO WHILE( ( index <= path.0 ) & ( found = 0 ) )
        IF( SuggestPath( path.index ) = 0 ) THEN
            index = index + 1;
        ELSE
            found = path.index;
    END

    DROP index
END

DROP what template firstmatch path.

RETURN found;

/* -------------------------------------------------------------------------------- 
   SuggestPath
    Displays a path name followed by a question mark and waits for a key. 
    Exits directly on <ESCAPE>. Returns 0 for <SPACE> or 1 otherwise.
   ----------------------------------------------------------------------- */
SuggestPath: PROCEDURE
PARSE ARG pathname

SAY pathname"?"

accept = C2X( SysGetKey( "NOECHO" ) );

IF( accept = '1B' ) THEN CALL Error( "Search cancelled" ); /* ESCAPE */
IF( accept = '20' ) THEN                                   /* SPACE  */
    pathOK = 0;
ELSE
    pathOK = 1;

DROP accept pathname

RETURN pathOK;

/* -----------------------------------------------------------------------
   Help
    Displays command line syntax. Since this is not speed-
    critical, the text is read from the top of the source
    file, which saves updating it in two places. Not a 
    procedure because it is called using SIGNAL and needs
    access to SOURCE variable.
   ----------------------------------------------------------------------- */
Help: 
    PARSE SOURCE . . self
    SAY self
    CALL STREAM self, 'C', "OPEN READ";
    CALL LINEIN self;   /* first line is a comment */

    helpLine = "";
    DO WHILE( POS( "*/", helpLine ) = 0 )
        SAY helpLine;
        helpLine = LINEIN( self );
    END

    CALL STREAM self, 'C', "CLOSE";
EXIT

/************************************************************
                    ERROR  HANDLERS
 ************************************************************/

/* -----------------------------------------------------------------------
   Error
     Called by the program to terminate precipitately.
     Displays <errormsg> string, then exits.
   ----------------------------------------------------------------------- */
Error: PROCEDURE
PARSE ARG errormsg
SAY errormsg;
EXIT

/* -----------------------------------------------------------------------
   ErrorTrap
     Traps errors in library functions, displays return code.
   ----------------------------------------------------------------------- */
ErrorTrap:
SAY ERRORTEXT( rc );
EXIT

/* -----------------------------------------------------------------------
   NoValueTrap
    Traps uninitialised variables and reports line number.
    Shouldn't be any now of course.
   ----------------------------------------------------------------------- */
NoValueTrap:
SAY "Uninitialised variable in line "SIGL;
EXIT

/* -----------------------------------------------------------------------
   SyntaxTrap
    Traps syntax error and reports line number. The interpreter
    will trap syntax errors but won't restore the environment 
    which could leave the wrong drive or directory.
   ----------------------------------------------------------------------- */
NoValueTrap:
SAY "Syntax error in line "SIGL;
EXIT

/* -----------------------------------------------------------------------
   Terminate : General exit and error trap
   ----------------------------------------------------------------------- */
Terminate:
EXIT;

/************************************************************
       LOOKUP TABLE EDITING ROUTINES

  If you don't intend to use the lookup table facilities,
  you can delete the rest of the file.
 ************************************************************/

/* -----------------------------------------------------------------------
   EditLookupTable :
   ----------------------------------------------------------------------- */
EditLookupTable: PROCEDURE EXPOSE lookUp.

/* useful ASCII formatting chars */
CRLF = X2C( '0D' ) || X2C( '0A' );  /* carriage return / line feed */
TAB = X2C( 9 );                     /* tab char */

cancelled = 0;
finished = 0;
modified = 0;

DO WHILE( ( cancelled = 0 ) & ( finished = 0 ) )
    legal = 0;

    DO WHILE( legal = 0 )
        CALL SysCls;
        SAY " (A)dd Entry" CRLF" (D)elete Entry" CRLF" (V)iew Entries" 
        SAY CRLF" (C)ancel and Exit" CRLF" (S)ave and Exit" CRLF;
        PARSE UPPER VALUE SysGetKey( "NOECHO" ) WITH choice

        legal = 1;
        SELECT
            WHEN( choice = 'A' ) THEN 
                IF( AddLookupEntry() \= 0 ) THEN modified = 1;

            WHEN( choice = 'D' ) THEN DO
                delIndex = DisplayLookupTable( 1 );
                IF( delIndex \= 0 ) THEN DO
                    CALL DeleteLookupEntry delIndex;
                    modified = 1;
                END
            END

            WHEN( choice = 'V' ) THEN CALL DisplayLookupTable( 0 );
            WHEN( choice = 'C' ) THEN cancelled = 1;
            WHEN( choice = 'S' ) THEN finished = 1;
            OTHERWISE legal = 0;
        END

    END

END

IF( ( cancelled = 0 ) & ( modified = 1 ) ) THEN 
    CALL RewriteLookupTable;
ELSE
    SAY "No changes were recorded.";

DROP cancelled finished modified legal
RETURN;

/* -----------------------------------------------------------------------
   GetNumber
   ----------------------------------------------------------------------- */
GetNumber: PROCEDURE
ARG upper

inputOK = 0;
number = "";

DO WHILE( inputOK = 0 )
    ch = C2X( SysGetKey( "NOECHO" ) );

    SELECT
        WHEN( ch = '1B' ) THEN DO              /* ESCAPE */
            inputOK = 1;
            number = 0;
        END
        WHEN( ch = '0D' ) THEN inputOK = 1;    /* ENTER */
        WHEN( ( ch < '30' ) | ( ch > '39' ) ) THEN CALL BEEP 2500, 200;
        OTHERWISE DO
            ch = X2C( ch );
            IF( ( number || ch ) <= upper ) THEN DO
                CALL CHAROUT "STDOUT:", ch;
                number = number || ch;
            END
            ELSE
                CALL BEEP 2500, 200;
        END
    END

END

DROP inputOK ch
RETURN number

/* -----------------------------------------------------------------------
   DisplayLookupTable
   ----------------------------------------------------------------------- */
DisplayLookupTable: PROCEDURE EXPOSE lookUp. TAB CRLF
ARG active

IF( lookUp.0 = 0 ) THEN DO
    SAY "No entries in table. Press a key."
    CALL SysGetKey( "NOECHO" );
    RETURN "";
END

PARSE VALUE SysTextScreenSize() WITH screenRows screenCols

IF( active = 1 ) THEN
    screenRows = screenRows - 8;   /* leave room for menu */
ELSE
    screenRows = screenRows - 2;   /* or just for <Press a key> message */

indexLU = 0;
choice = "";

DO WHILE( (choice = "" ) & ( indexLU < lookUp.0 ) )
    CALL SysCls;
    row = 0;

    DO WHILE( ( row < screenRows ) & ( indexLU < lookUp.0 ) )
        indexLU = indexLU + 1;
        row = row + 1;
        outstr = indexLU TAB lookUp.indexLU.key " = " lookUp.indexLU.dir;
        SAY outstr
    END

    SAY;
    IF( active = 0 ) THEN DO
        SAY " <Press a key>";
        CALL SysGetKey( "NOECHO" );
    END
    ELSE DO
        SAY "Choose a number" CRLF"<ENTER> for next screen" CRLF"<ESC> to quit";
        choice = GetNumber( lookUp.0 );
    END

END

DROP active screenCols screenRows indexLU outstr row
RETURN choice;

/* -----------------------------------------------------------------------
   AddLookupEntry
    Prompts for a new lookup key and checks that it doesn't
    include any spaces, then prompts for a path name, checks
    for illegal characters then tries to CD to it. Note that
    it is not an error if the path does not exist - the user
    may intend to create it later or it may be on a drive that
    is currently inaccessible.
   ----------------------------------------------------------------------- */
AddLookupEntry: PROCEDURE EXPOSE lookUp.

inputOK = 0;
DO WHILE( inputOK = 0 )
    SAY "Enter a lookup key :";
    PULL newKey junk .       
    IF( junk \= "" ) THEN 
        SAY "Do not embed spaces!";
    ELSE
        inputOK = 1;
END
DROP junk

inputOK = 0;
DO WHILE( inputOK = 0 )
    SAY "Enter the fully-qualified pathname :";
    PULL newPath .
    PARSE VAR newPath drive ":" path 
 
    /* check for illegal chars in <path>, and that <drive> is a single letter */
    IF( ( VERIFY( path, '":*?|', "MATCH" ) \= 0 ) | ( LENGTH( drive ) > 1 ) | ( DATATYPE( drive, 'M' ) = 0 ) ) THEN
        SAY " The path is illegal";
    ELSE DO
        /* first check that the drive responds, then try to change to the directory */
        IF( STREAM( drive || ":*", 'C', "OPEN" ) = "NOTREADY:2" ) THEN DO
            curDir = DIRECTORY( drive || ":" ); /* save cwd for this drive */
            IF( DIRECTORY( newPath ) = newPath ) THEN inputOK = 1;
            CALL DIRECTORY( curDir );           /* restore the cwd */
            DROP curDir
        END

        IF( inputOK = 0 ) THEN DO
            SAY " Cannot locate the directory. Is that OK (Y/N)?";
            PARSE UPPER VALUE SysGetKey( "NOECHO" ) WITH response
            IF( response = 'Y' ) THEN inputOK = 1;
        DROP response
        END

    END
DROP drive path
END

last = lookUp.0 + 1;          /* add the new entry to the table */
lookUp.last.key = newKey;
lookUp.last.dir = newPath;
lookUp.0 = last;

DROP newKey newPath last
RETURN inputOK

/* -----------------------------------------------------------------------
   DeleteLookupEntry
    Removes entry <deleteAt> and packs the remaining entries
    then adjusts lookUp.0 to reflect the new size.
   ----------------------------------------------------------------------- */
DeleteLookupEntry: PROCEDURE EXPOSE lookUp.
ARG deleteAt

DO index = deleteAt TO ( lookUp.0 - 1 )
    nIndex = index + 1;
    lookUp.index.key = lookUp.nIndex.key;
    lookUp.index.dir = lookUp.nIndex.dir;
END

lookUp.0 = lookUp.0 - 1;

DROP index nIndex deleteAt
RETURN;

/* -----------------------------------------------------------------------
   RewriteLookupTable
    Copies the entire file to a temp file, filling in the
    lookup table section with the new entries, then deletes
    the old file and renames the temp file.
    "source directory" refers to the one where RDX.CMD resides.
   ----------------------------------------------------------------------- */
RewriteLookupTable: PROCEDURE EXPOSE lookUp.
 
PARSE SOURCE . . rdxFile;

/* locate the directory containing the source file */
srcDrive = FILESPEC( "DRIVE", rdxFile );
srcPath = FILESPEC( "PATH", rdxFile );
sourceDir = srcDrive || srcPath;

/* if source dir is a root we need terminating backslash, otherwise it must go */
IF( srcPath \= "\" ) THEN srcPath = SUBSTR( srcPath, 1, LENGTH( srcPath )-1 );

curDir = DIRECTORY( srcDrive );         /* find and save the cwd for the drive */
CALL DIRECTORY( srcDrive || srcPath );  /* then change to the source directory */
DROP srcDrive srcPath

/* drop the path from source file name for convenience */
rdxFile = FILESPEC( "NAME", rdxFile );
CALL STREAM rdxFile, 'C', "OPEN READ";

/* create the temporary file in the source directory so it can be renamed */
tempFile = SysTempFileName( "RDX?????.CMD" );
IF( STREAM( tempFile, 'C', "OPEN WRITE" ) \= "READY:" ) THEN
    CALL Error( "Cannot create temporary file" );

/* Copy lines from source file to temp file until we find the start
   of the lookup table */
fline = "";
DO WHILE( ( LINES( rdxFile ) = 1 ) & ( fline \= "/*LOOKUP*/" ) )
    fline = LINEIN( rdxFile );
    CALL LINEOUT tempFile, fline;
END
 
/* Write new lookup table to the temp file */
DO index = 1 TO lookUp.0
    CALL LINEOUT tempFile, "lookUp." || index || ".key = '" || lookUp.index.key || "'";
    fline = "lookUp." || index || ".dir = '" || lookUp.index.dir || "'";
    CALL LINEOUT tempFile, fline;
END

/* Write size of lookup table to temp file */
fline = "lookUp.0 = " || lookUp.0;
CALL LINEOUT tempFile, fline;

/* Search source file for the end of the lookup table */
fline = "";
DO WHILE( ( LINES( rdxFile ) = 1 ) & ( fline \= "/*ENDLOOKUP*/" ) )
    fline = LINEIN( rdxFile );
END

/* Write the ENDLOOKUP flag to the temp file */
CALL LINEOUT tempFile, fline;

/* Copy the rest of the source to the temp file */
DO WHILE( LINES( rdxFile ) = 1 )
    CALL LINEOUT tempFile, LINEIN( rdxFile );
END

CALL STREAM tempFile, 'C', "CLOSE";
CALL STREAM rdxFile, 'C', "CLOSE";

/* Delete the source file and rename the temp file */
IF( SysFileDelete( rdxFile ) \= 0 ) THEN DO
    SAY "Cannot replace original file " rdxFile;
    SAY "New file was saved as " sourceDir tempFile;
    SIGNAL Terminate;
END

"REN" tempFile rdxFile;

CALL DIRECTORY( curDIr );
DROP curDir sourceDir index fline rdxFile tempFile
RETURN

/************************************************************
   end
  ************************************************************/

