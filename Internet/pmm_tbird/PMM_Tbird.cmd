/****************************************************************/
/*                                                              */
/*       Migrate mail from PMMail to Thunderbird                */
/*                                                              */
/*      Author:       Peter Moylan (peter@ee.newcastle.edu.au)  */
/*      Started:      22 February 2005                          */
/*      Last revised: 5 January 2006                            */
/*                                                              */
/*      STATUS:       Working                                   */
/*                                                              */
/*  Usage:                                                      */
/*         PMM_Tbird                                            */
/*     (no arguments are used or expected)                      */
/*                                                              */
/*  Installation:                                               */
/*     No special installation requirements.  This script       */
/*     can be run from any directory.  You will be              */
/*     prompted for directory names as required.                */
/*                                                              */
/****************************************************************/

CALL RxFuncAdd SysLoadFuncs, rexxutil, sysloadfuncs
CALL SysLoadFuncs

/* Tell the user what we're going to do. */

SAY
SAY 'Script to migrate your mail from PMMail to Thunderbird.  Mail from'
SAY 'PMMail accounts is copied to Thunderbird mail folders, but the'
SAY 'original files are not destroyed in case you change your mind.'
SAY
SAY 'Note that this script can have a long execution time if you have'
SAY 'a lot of mail to copy.  Don''t panic, just let it keep running in'
SAY 'the background while you do other things.  You can safely'
SAY 'run Thunderbird while the migration is happening.'
SAY

Globals = 'MonthStart. DayName. MonthName. ConfirmEach'
CALL CreateDateTables
OurDir = Directory()

/* Get the two directories we're working on. */

Nul = '00'X
TBirdDir = STRIP(SysIni('USER', 'Mozilla', 'Home'),,'0'X)||'\Thunderbird'
f = TBirdDir'\profiles.ini'
DO WHILE CHARS(f) > 0
    line = LINEIN(f)
    IF LEFT(line,5) = 'Path=' THEN DO
        line = RIGHT(line, LENGTH(line)-5)
        line = TRANSLATE(line, '\', '/')
        TBirdDir = TBirdDir'\'line'\Mail'
        LEAVE
    END
END
TBirdDir = GetDirectoryName('Temporary output directory', TBirdDir||'\TempDir')
CALL SysMkDir TBirdDir
PMMDir = GetDirectoryName('PMMail', 'G:\southsde\PMMail')

/* Check whether the user wants to confirm each account. */

SAY "If you answer 'N' to the following question, mail from all PMMail"
SAY "accounts will be copied.  If you answer 'Y', you will be asked to"
SAY "confirm the migration of each account individually."
SAY "Do you want to be asked about each account [Y/N] ?"

ConfirmEach = 0
IF TRANSLATE(SysGetKey()) = 'Y' THEN ConfirmEach = 1
SAY ''

/* Work through the account directories. */

rr = SysFileTree(PMMDir'\*.ACT','stem','OD')
If rr<>0 Then stem.0=0
count = 0
Do x=1 to stem.0
  count = count + ProcessAccount(stem.x, TBirdDir)
End

IF count = 0 THEN DO
    SAY "No PMMail accounts were found."
    SAY "This probably means you specified the wrong directory for PMMail."
END
ELSE DO
    SAY ''
    SAY count" account(s) processed."
    SAY 'Finished.  You may now move the new files to your Thunderbird migration account.'
    SAY 'At present those files are in the temporary directory'
    SAY '      'TBirdDir
END

CALL Directory OurDir
EXIT

/****************************************************************/
/*          Procedure to process one PMMail account             */
/****************************************************************/

ProcessAccount: PROCEDURE EXPOSE (Globals)

    PARSE ARG AcctDir, TBirdDir
    filename = AcctDir'\ACCT.INI'

    /* Get the account name.  It is up to 256 characters long,  */
    /* followed by nulls, and starts 512 or 513 bytes from the  */
    /* start of the ACCT.INI file.                              */

    CALL STREAM AcctINI, 'C', 'OPEN'
    AcctName = CHARIN(filename, 513, 257)
    IF LEFT(AcctName, 1) = 'DE'X THEN AcctName = RIGHT(AcctName, 256)
    ELSE AcctName = LEFT(AcctName, 256)
    AcctName = STRIP(AcctName,,'00'X)
    CALL STREAM filename, 'C', 'CLOSE'
    SAY 'Account name is "'AcctName'"'
    IF ConfirmEach THEN DO
        SAY "Do you want to migrate this account [Y/N] ?"
        IF TRANSLATE(SysGetKey()) \= 'Y' THEN DO
            SAY ''
            RETURN 0
        END
        SAY ''
    END

    /* We can in principle find filters and signatures in the   */
    /* account directory, but for now I'm leaving those in the  */
    /* 'too hard' category.                                     */

    Target = TBirdDir'\'AcctName

    /* Since I haven't worked out how to create a new account   */
    /* in Thunderbird, that step will have to be done manually. */
    /* For now, I am going to produce one empty file and one    */
    /* directory for each account.  When these are moved        */
    /* manually into an account directory created manually      */
    /* from inside Thunderbird, the result will be one mail     */
    /* folder per account, with the migrated folders looking    */
    /* like subfolders of that folder.                          */

    CALL STREAM Target, 'c', 'open write'
    CALL STREAM Target, 'c', 'close'           /* empty file */
    Target = Target'.sbd'                      /* directory  */

    CALL ProcessFolders '""' AcctDir Target
    RETURN 1

/****************************************************************/
/*         Process all folders in a given directory             */
/****************************************************************/

ProcessFolders: PROCEDURE EXPOSE (Globals)

    PARSE ARG '"'FPrefix'"' AcctDir DstDir
    rc = SysMkDir(DstDir)
    rr = SysFileTree(AcctDir||'\*.FLD','stem','OD')
    IF rr <> 0 THEN stem.0 = 0
    DO k = 1 TO stem.0
        CALL ProcessFolder '"'FPrefix'"' stem.k DstDir
    END
    RETURN

/****************************************************************/
/*         Process a single folder and its subfolders           */
/****************************************************************/

ProcessFolder: PROCEDURE EXPOSE (Globals)

    PARSE ARG '"'FPrefix'"' FolderDir DstDir
    Folder = FolderName(FolderDir)
    pos = LASTPOS('\', FolderDir)

    /* Watch out for characters that can't be part of a file    */
    /* name.                                                    */

    FullTargetFileName = DstDir'\'TRANSLATE(Folder, '_________', '\/:*?"<>|')

    /* Even if there aren't any messages in this folder, we      */
    /* still need to start with an empty file.                   */

    CALL STREAM FullTargetFileName, 'c', 'open write'
    CALL STREAM FullTargetFileName, 'c', 'close'           /* empty file */

    /* The *.MSG files are the ones we need to copy over. */

    rr = SysFileTree(FolderDir||'\*.MSG','stem','F')
    IF rr <> 0 THEN stem.0 = 0
    DO k = 1 TO stem.0
        CALL ProcessMessage stem.k'0'X||FullTargetFileName
    END
    SAY '    Folder 'FPrefix||Folder': 'stem.0' messages copied'

    /* Now look after the subfolders. */

    IF FPrefix = "" THEN FPrefix = Folder'/'
    ELSE FPrefix = FPrefix||Folder'/'
    CALL ProcessFolders '"'FPrefix'"' FolderDir FullTargetFileName'.sbd'
    RETURN

/****************************************************************/
/*              Process a single message file                   */
/****************************************************************/

ProcessMessage: PROCEDURE EXPOSE (Globals)

    PARSE ARG src'0'X Target
    PARSE VAR src mmddyy 9 time 17 size 30 rubbish 38 src

    /* Date is in format mm/dd/yy, time is 99:99a.  What we     */
    /* want is the line "From - Tue Jan 29 09:35:00 2002".      */
    /* We can't assume Object Rexx, so we have to work out the  */
    /* details the hard way.                                    */

    PARSE VAR mmddyy mm'/'dd'/'yy
    yy = yy + 2000
    IF yy > 2079 THEN yy = yy - 100
    time = STRIP(time)
    PARSE VAR time hh':'mma
    ap = RIGHT(mma, 1)
    mma = LEFT(mma, LENGTH(mma)-1)
    IF ap = 'p' THEN mma = mma+12

    /* Open the target file at its end. */

    CALL STREAM Target, 'c', 'open write'
    CALL STREAM Target, 'c', 'seek <0'
    CALL LINEOUT Target, 'From - 'DayMonth(mmddyy)' 'NN(dd)' 'NN(hh)':'NN(mma)':00 'NNNN(yy)
    CALL LINEOUT Target, 'X-Mozilla-Status: 0000'
    CALL LINEOUT Target, 'X-Mozilla-Status2: 00000000'
    CALL STREAM Target, 'c', 'close'

    '@copy "'Target'" /B + "'src'" "'Target'" >nul'

    RETURN

/****************************************************************/
/*           Initialisation of the date tables                  */
/****************************************************************/

CreateDateTables: PROCEDURE EXPOSE (Globals)

    MonthStart.1 = 0
    MonthStart.2 = 31
    MonthStart.3 = 59
    MonthStart.4 = 90
    MonthStart.5 = 120
    MonthStart.6 = 151
    MonthStart.7 = 181
    MonthStart.8 = 212
    MonthStart.9 = 243
    MonthStart.10 = 273
    MonthStart.11 = 304
    MonthStart.12 = 334

    MonthName.1 = 'Jan'
    MonthName.2 = 'Feb'
    MonthName.3 = 'Mar'
    MonthName.4 = 'Apr'
    MonthName.5 = 'May'
    MonthName.6 = 'Jun'
    MonthName.7 = 'Jul'
    MonthName.8 = 'Aug'
    MonthName.9 = 'Sep'
    MonthName.10 = 'Oct'
    MonthName.11 = 'Nov'
    MonthName.12 = 'Dec'

    DayName.0 = 'Mon'
    DayName.1 = 'Tue'
    DayName.2 = 'Wed'
    DayName.3 = 'Thu'
    DayName.4 = 'Fri'
    DayName.5 = 'Sat'
    DayName.6 = 'Sun'

    RETURN

/****************************************************************/
/*Work out the day and month codes for a date in mm/dd/yy format*/
/****************************************************************/

DayMonth: PROCEDURE EXPOSE (Globals)

    PARSE ARG mm'/'dd'/'yy

    /* Change yy to years since 1980 */

    yy = yy + 20
    IF yy > 100 THEN yy = yy - 100

    /* Calculate day of week on 1 Jan of the given year. */

    dow = (5*(yy % 4)) // 7
    IF (yy // 4) <> 0 THEN dow = (dow + (yy // 4) + 1) // 7;

    /* Advance to the actual date within the year. */

    mm = STRIP(mm)
    dow = (dow + MonthStart.mm + dd) // 7

    /* The rest is by table lookup. */

    RETURN DayName.dow' 'MonthName.mm

/****************************************************************/
/*                Two-digit numeric to string                   */
/****************************************************************/

NN: PROCEDURE

    PARSE ARG val
    IF val > 9 THEN RETURN val
    ELSE RETURN '0'val

/****************************************************************/
/*                Four-digit numeric to string                  */
/****************************************************************/

NNNN: PROCEDURE

    PARSE ARG val
    RETURN NN(val%100)||NN(val//100)

/****************************************************************/
/*      Translate a folder directory into a folder name         */
/****************************************************************/

FolderName: PROCEDURE

    PARSE ARG FolderDir
    FolderINI = FolderDir||'\Folder.INI'
    CALL STREAM FolderINI, 'C', 'OPEN'
    PARSE VALUE LINEIN(FolderINI) WITH name'Þ'.
    FolderName = STRIP(FolderName,,'00'X)
    CALL STREAM FolderINI, 'C', 'CLOSE'
    RETURN name

/****************************************************************/
/* Procedure to invite user to type in a directory name, or     */
/*                    accept a default                          */
/****************************************************************/

GetDirectoryName: PROCEDURE

    PARSE ARG name, default
    SAY name' directory is 'default
    SAY 'Type the <Enter> key to accept this default, or type another directory name.'
    PARSE PULL Dir
    IF Dir = '' THEN Dir = default
    ELSE SAY ''
    ch = RIGHT(Dir,1);
    IF ch = '/' | ch = '\' THEN Dir = LEFT(Dir, LENGTH(Dir)-1)
    RETURN Dir

/****************************************************************/

