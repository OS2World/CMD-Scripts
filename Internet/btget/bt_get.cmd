/*****************************************************************************
 * BT_GET.CMD  -  OS/2 BitTorrent Commandline Launcher                       *
 * By Alex Taylor (2006)                                                     *
 *                                                                           *
 * This version is for BitTorrent 3.4.2 and below.  DO NOT use this script   *
 * with BitTorrent 4.0x or higher (use BT4_GET.CMD instead).                 *
 *****************************************************************************/

/* ------------------------------------------------------------------------- *
 * DIRECTORY CONSTANTS - EDIT AS APPROPRIATE FOR YOUR SYSTEM                 *
 * ------------------------------------------------------------------------- */

/* Directory where Python/2 files are installed, e.g.:                       */
/*  pythdir = 'c:\usr\local\python235'                                       */
pythdir = ''

/* Directory where BitTorrent files are installed, e.g.:                     */
/* btdir   = 'e:\programs\bittorrent-3.4.2'                                  */
btdir   = ''

/* Directory where downloaded files will be placed, e.g.:                    */
/* savedir = 'f:\downloads'                                                  */
savedir = ''


/* ------------------------------------------------------------------------- *
 * BITTORRENT CONSTANTS - EDIT AS APPROPRIATE FOR YOUR SYSTEM                *
 * ------------------------------------------------------------------------- */

/* Maximum upload speed when sending to peers */
uploadspeed = 50

/* IP port range to listen on.  If you have a firewall or NAT router, this   */
/* entire port range must be open and forwarded to the local PC.             */
minport = 6881
maxport = 6999


/* ------------------------------------------------------------------------- *
 * CHANGES BELOW THIS POINT ARE NOT GENERALLY NECESSARY                      *
 * ------------------------------------------------------------------------- */

IF RxFuncQuery('SysSetExtLIBPATH') == 1 THEN
    CALL RxFuncAdd 'SysSetExtLIBPATH', 'REXXUTIL', 'SysSetExtLIBPATH'

IF RxFuncQuery('SysSetExtLIBPATH') == 1 THEN DO
    SAY
    SAY 'Your system does not appear to support the SysSetExtLIBPATH() function.'
    SAY 'You may have to install a more recent FixPak before you can use this script.'
    SAY
    RETURN
END

IF ( pythdir == '') | ( btdir == '') | ( savedir == '') THEN DO
    SAY 'BT_GET.CMD - REXX wrapper for BitTorrent (version 3.4x and below).'
    SAY
    SAY 'You must edit this script and define the three variables at the top of'
    SAY 'the file ("pythdir", "btdir", & "savedir") before use.'
    SAY
    RETURN
END


/* Check the torrent filename */
PARSE ARG torrent
torrent = STRIP( torrent )
torrent = STRIP( torrent, 'B', '"')
IF torrent = '' THEN DO
    SAY 'A .torrent file was not specified.'
    RETURN
END
torrent = STREAM( torrent, 'C', 'QUERY EXISTS')

/* Determine the name of the actual file to download (for saving to) */
savename = TargetFileName( torrent )
IF savename \= '' THEN
    saveas = '--saveas "'savedir'\'savename'"'
ELSE
    saveas = ''

/* Print some notices */
SAY 'Python files:    ' pythdir
SAY 'BitTorrent files:' btdir
SAY 'Save directory:  ' savedir

/* Now set up the environment */
CALL SETLOCAL
CALL DIRECTORY btdir

/* Add Python to the system PATH and LIBPATH */
CALL SysSetExtLIBPATH pythdir, 'B'
path = VALUE('PATH',,'OS2ENVIRONMENT')
CALL VALUE 'PATH', pythdir';'path, 'OS2ENVIRONMENT'

/* Set the variables required by Python */
CALL VALUE 'PYTHONHOME', pythdir, 'OS2ENVIRONMENT'
CALL VALUE 'PYTHONPATH', pythdir'/Lib;'pythdir'/Lib/plat-os2emx;'pythdir'/Lib/lib-dynload;'pythdir'/Lib/site-packages;', 'OS2ENVIRONMENT'
CALL VALUE 'TERMINFO',   pythdir'/terminfo', 'OS2ENVIRONMENT'
CALL VALUE 'TERM',       'ansi', 'OS2ENVIRONMENT'

/* Launch the command-line BitTorrent downloader */
SAY
ADDRESS CMD 'python btdownloadcurses.py --minport' minport '--maxport' maxport '--max_upload_rate' uploadspeed saveas '"'torrent'"'

/* Restore the environment */
CALL ENDLOCAL

RETURN


/*****************************************************************************
 * TargetFileName()                                                          *
 *                                                                           *
 * Does a quick-and-dirty parse of the .torrent file to determine the        *
 * recommended save filename.                                                *
 *                                                                           *
 * INPUT:  filename of the .torrent file                                     *
 * OUTPUT: save filename parsed from .torrent, or '' if a problem occurred   *
 *****************************************************************************/
TargetFileName: PROCEDURE
    PARSE ARG torrent
    IF torrent = '' THEN RETURN ''

    CALL LINEIN torrent, 1, 0
    DO WHILE LINES( torrent ) > 0
        in = LINEIN( torrent )
        PARSE VAR in . '4:name' size ':' data
        IF ( size \= '') & ( data \= '') THEN
            fndata = SUBSTR( data, 1, size )
        ELSE
            fndata = ''
        IF fndata \= '' THEN LEAVE
    END
    CALL STREAM torrent, 'C', 'CLOSE'

RETURN fndata

