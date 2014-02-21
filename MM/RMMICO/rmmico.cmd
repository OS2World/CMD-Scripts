/*
 *      RMMICO.CMD - V1.0 C.Langanke 1999 - C.Langanke@TeamOS2.DE
 *
 *      Syntax: RMMICO
 *
 *      This rexx script restores the diverse icons, which bring
 *      up MMPM.EXE for digital audio, digital video, compact disc
 *      play and midi play.  These icons may be lost during the
 *      installation of some sound drivers.
 */

 TitleLine = STRIP(SUBSTR(SourceLine(2), 3));
 PARSE VAR TitleLine CmdName'.CMD 'Info
 Title     = CmdName Info

 /* RexxUtil laden */
 CALL RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
 CALL SysLoadFuncs;

 /* default values */
 env = 'OS2ENVIRONMENT';

 /* determine where MMOS2 is installed */
 MMDrive = GetInstDrive('\MMOS2');
 IF (MMDrive = '') THEN
 DO
    SAY CmdName': error: OS/2 Multimedia Presentation Manager not installed.';
    EXIT(87);
 END;
 IconDir = MMDrive'\MMOS2\INSTALL';

 /* do the job */
 SAY;
 SAY Title;
 SAY;
 CALL CHAROUT, 'Restoring MMOS2 icons ';
 Count = 0;
 DO i = 1 TO 5
    Count = Count + SetIcon( '<MMPM_CDPLAYER'i'>', 'CDPLAYER.ICO');
    Count = Count + SetIcon( '<MMPM_DAPLAYER'i'>', 'AUDPLAY.ICO');
    Count = Count + SetIcon( '<MMPM_MIDIPLAYER'i'>', 'MIDIPLAY.ICO');
    Count = Count + SetIcon( '<MMPM2_SOFTWARE_MOTION_VIDEO'i'>', 'VIDPLAY.ICO');
 END;
 SAY ' Ok.';
 SAY Count 'icons restored.';

 EXIT(0);

/* ------------------------------------------------------------------------- */
SetIcon: PROCEDURE EXPOSE env IconDir
 ARG ObjectId, IconFile

 IF (SysSetObjectData( ObjectId, ';')) THEN
 DO
    CALL CHAROUT, '.';
    rc = SysSetObjectData(ObjectId, 'ICONFILE='IconDir'\'IconFile';');
    RETURN( 1);
 END;

 RETURN( 0);

/* ------------------------------------------------------------------------- */
GetInstDrive: PROCEDURE EXPOSE env
 ARG DirName, EnvVarName

 /* Default: OS2-Verzeichnis -> ermittelt BootDrive */
 IF (DirName = '') THEN DirName = '\OS2';

 /* Default: PATH  */
 IF (EnvVarName = '') THEN EnvVarName = 'PATH';

 /* Wert holen */
 PathValue = TRANSLATE(VALUE(EnvVarName,,env));

 /* Eintrag suchen und Laufwerk zurÅckgeben */
 DirName = TRANSLATE(':'DirName';');
 EntryPos = POS(DirName, PathValue) - 1;
 IF (EntryPos = -1) THEN
    RETURN('');
 InstDrive = SUBSTR(PathValue, EntryPos, 2);
 RETURN(InstDrive);

