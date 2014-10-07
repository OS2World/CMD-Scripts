/*****************************************************************************
 * DSK2RSU.CMD                                                               *
 *                                                                           *
 * Generates zip files for RSU (Remote Software Updates) from a directory    *
 * of FixPak diskette (DSK) images.                                          *
 *                                                                           *
 * (C) 2005 Alex Taylor - public domain software.                            *
 *                                                                           *
 *****************************************************************************/
CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
CALL SysLoadFuncs

/* 
 * Parse the source directory name.
 */
ARG source
source = STRIP( source, 'T', '\')
IF source == '' THEN DO
    SAY 'DSK2RSU.CMD - Generate RSU zipfiles from FixPak diskette images'
    SAY
    SAY 'Syntax:'
    SAY '   DSK2RSU <path>'
    SAY '   where <path> is a directory containing the diskette images.'
    SAY
    RETURN
END
IF source == '.' THEN source = TRANSLATE( DIRECTORY() )

/*
 * Search the source directory for diskette image files.
 */
CALL SysFileTree source'\*.?DK', 'dsks.','FO'
IF dsks.0 == 0 THEN CALL SysFileTree source'\*.DSK', 'dsks.','FO'
IF dsks.0 < 1 THEN DO
    SAY 'No diskette images found under' source'.'
    RETURN 1
END
SAY 'Processing' dsks.0 'diskette images in' source'.'
SAY

/*
 * Generate the common name-stem for the diskette image files.
 * (This will be used when creating the output zip files.)
 */
name = LEFT( FILESPEC('NAME', source ), 7 )
/* Convert it to lowercase (I just prefer it that way) */
name = TRANSLATE( name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') 

/*
 * Pass 1: Unpack the diskette image files to separate subdirectories.
 */
DO i = 1 TO dsks.0
    CALL CHAROUT, 'Unpacking' TRANSLATE( dsks.i ) '... '
    IF ( i > 9 ) & ( i < 36 ) THEN c = d2c( 87 + i )
    ELSE c = i
    ADDRESS CMD '@dskxtrct /s:'dsks.i '/t:'source'\d'c '/q /la /ra >NUL'
    IF rc == 0 THEN SAY 'OK'
    ELSE DO
        SAY 'RC='rc
        SAY 'DSKXTRCT returned an error; see DSKXTRCT.LOG.'
        RETURN 2
    END
    /* Save README.1ST from the first image; we'll need it a bit later. */
    IF ( i == 1 ) & ( STREAM( source'\d1\README.1ST', 'C', 'QUERY EXISTS') \= '') THEN 
        '@copy' source'\d1\README.1ST' source'\README.1ST >NUL'
END

/*
 * Pass 2: Zip the extracted files into corresponding zip files.
 */
od = DIRECTORY()
sd = DIRECTORY( source )
DO i = 1 TO dsks.0
    IF ( i > 9 ) & ( i < 36 ) THEN c = d2c( 87 + i )
    ELSE c = i
    /* Generate the output filename. */
    zipfile = name || c'.zip'
    CALL DIRECTORY 'd'c 
    CALL CHAROUT, 'Creating' zipfile '... '
    ADDRESS CMD '@zip -qmr' zipfile '*'
    IF rc == 0 THEN SAY 'OK'
    ELSE DO
        SAY 'Failed'
        SAY 'ZIP operation failed; rc='rc
        RETURN 3
    END
    '@move' zipfile '.. >NUL'
    CALL DIRECTORY sd 
    CALL SysRmDir('d'c )
END

/*
 * Generate the .TBL (index) file listing all zipfiles and their sizes.
 */
IF STREAM( name'.tbl', 'C', 'QUERY EXISTS') \= '' THEN
    '@del' name'.tbl'
CALL SysFileTree '*.zip', 'zfiles.', 'F'
table = name'.tbl'
SAY 'Writing' table '...'
DO i = 1 TO zfiles.0
    PARSE VAR zfiles.i . . fsize . fname
    CALL LINEOUT table, fsize FILESPEC('NAME', fname )
END
CALL STREAM table, 'C', 'CLOSE'

/*
 * Now zip the .TBL and README.1ST files into FTPINSTL.ZIP (required by
 * the FTPINSTL.EXE program).
 */
SAY 'Creating ftpinstl.zip ...'
ADDRESS CMD '@zip -qm ftpinstl.zip' table 'README.1ST'

/*
 * Create a new subdirectory for the RSU files, and move all the
 * zip files into it.
 */
rsudir = name
CALL SysMkDir rsudir
'@move *.zip' rsudir '>NUL'
SAY 'Done.'
SAY
SAY 'RSU files have been placed under' TRANSLATE( DIRECTORY( rsudir ))'.'

/*
 * Return to the original directory and delete the DSKXTRCT logfile.
 */
CALL DIRECTORY od 

IF STREAM('dskxtrct.log', 'C', 'QUERY EXISTS') \= '' THEN
    '@del dskxtrct.log >NUL'

RETURN 0

