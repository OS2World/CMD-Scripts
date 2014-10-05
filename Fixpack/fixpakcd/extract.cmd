/* EXTRACT.CMD - v1.0
 * Copyright (C) Alex Taylor, 2000
 *
 * REXX script to extract SAVEDSKF-type diskette images, such as FixPak files.
 * Requires that DSKXTRCT.EXE be in the current directory or the system PATH.
 */

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs

PARSE UPPER ARG filemask

IF filemask \= '' THEN DO
    IF DXFind() THEN DO
        rcdir = SysMkDir("csdfiles")
        IF rcdir = 0 THEN ExtractFiles( filemask )
        ELSE SAY "Could not create output directory:" DirRC( rcdir )
    END
    ELSE say "Cannot locate DSKXTRCT.EXE!"
END
ELSE say "Please specify files to extract, e.g. 'EXTRACT *.?DK'"

EXIT


DXFind: PROCEDURE
    found = 0;
    dxpath = SysSearchPath( DIRECTORY(), 'DSKXTRCT.EXE')
    IF dxpath = '' THEN
        dxpath = SysSearchPath('PATH', 'DSKXTRCT.EXE')
    IF dxpath \= '' THEN found = 1
    RETURN found


DirRC: PROCEDURE
    ARG code;
    IF code = 2 THEN mesg = "file not found"
    ELSE IF code = 3 THEN mesg = "path not found"
    ELSE IF code = 5 THEN mesg = "access denied (directory may exist already)"
    ELSE IF code = 26 THEN mesg = "not a DOS disk"
    ELSE IF code = 87 THEN mesg = "invalid parameter"
    ELSE IF code = 108 THEN mesg = "drive is locked"
    ELSE IF code = 206 THEN mesg = "filename exceeds range"
    ELSE msg = "undefined error"
    return mesg


ExtractFiles: PROCEDURE
    ARG source
    cmdline = "DSKXTRCT /S:"source "/T:csdfiles /RA /LA"
    RETURN cmdline

