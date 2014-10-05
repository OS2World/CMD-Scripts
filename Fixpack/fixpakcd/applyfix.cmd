/* REXX - APPLYFIX.CMD version 1.1
 * Copyright (C) Alex Taylor, 2000
 *
 *  Apply a fixpak from the specified directory, using SERVICE.EXE
 *
 *  If the environment variable CSFUTILPATH is defined, this script
 *  will look for SERVICE.EXE there; if not, it will check the current
 *  directory; finally, if SERVICE.EXE is found nowhere else, it will
 *  assume it resides in the directory '\CSF' on the current drive.
 *
 *  New in v1.1:
 *    - CSFUTILPATH is now set
 *
 *  New in v1.01:
 *    - Reworded/tidied up the output.
 *    - Added warning if no source path specified.
 *
 *  To do (hopefully):
 *    - If source drive is not specified, scan all available drives for
 *      specified source directory.
 *    - If source path is relative (no leading '\'), check the current
 *      directory before defaulting to root.
 *    - Allow use of console-mode FSERVICE as an alternative to GUI
 *      SERVICE.  Maybe detect whether GUI is available...?
 *
 */

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs

                /*
                 *  Query the current working directory, and use that to
                 *  find the current drive.
                 */
cur_loc = DIRECTORY()
cur_drive = ParseDrive( cur_loc )

                /* Now parse the command line for the source directory. */
PARSE UPPER ARG sourcedir

CLS             /* Clear the screen to make things look a bit neater */

                /* If no source specified, print a warning */
IF LENGTH( sourcedir ) = 0 THEN DO
    warning = CENTRE("** No source directory specified. Defaulting to root of current drive ("cur_drive"). **", 80 );
    SAY warning
END

                /* Look for a drive specification in 'sourcedir'. */
src_drive = ParseDrive( sourcedir )
IF LENGTH( src_drive ) = 0 THEN DO
                    /*  If not present, assume the current drive. */
    src_drive = cur_drive
    src_path = sourcedir
END
ELSE
    src_path = SUBSTR( sourcedir, 3 )

                /*
                 *  Set the specified path relative to the root
                 *  directory of the drive (this avoids ambiguity).
                 */
IF POS('\', src_path ) \= 1 THEN
    src_path = '\'src_path

                    /* Save the current environment */
val = SETLOCAL()

                    /* Set the CSFCDROMDIR variable */
fp_dir = src_drive""src_path
val = VALUE('CSFCDROMDIR',fp_dir,'OS2ENVIRONMENT')

                    /* Set the CSFUTILPATH variable */
val = VALUE('CSFUTILPATH',,'OS2ENVIRONMENT')
IF val \= "" THEN
    csfpath = val
ELSE DO
    spec = SysSearchPath( cur_loc, "SERVICE.EXE")
    if spec \= "" THEN
        csfpath = cur_loc

    /* Should I search the system path for it as well? */

    else
       csfpath = cur_drive"\CSF"
END
val = VALUE('CSFUTILPATH',csfpath,'OS2ENVIRONMENT')
val = VALUE('REMOTE_INSTALL_STATE','0','OS2ENVIRONMENT')

SAY "Will apply corrective service from directory:"
val = VALUE('CSFCDROMDIR',,'OS2ENVIRONMENT')
SAY "   " val
SAY "Enter 'Y' to confirm, anything else to cancel..."
val = CHAROUT(," ==> ")
PULL response .
IF response = "Y" THEN DO
    SAY
    SAY "Starting the Corrective Service Facility..."
    if cur_loc \= csfpath THEN
        CD csfpath
    SERVICE
END
ELSE
    SAY "Cancelled."

EXIT



ParseDrive: PROCEDURE
                    /* Look for a drive specification in 'pathspec'. */
    ARG pathspec
    colon = POS(':', pathspec )
    IF colon = 2 THEN
        drive = SUBSTR( pathspec, 1, 2 )
    ELSE
        drive = ''
    RETURN drive


