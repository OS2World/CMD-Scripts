/******************************************************************************
 * RRBACKUP.CMD v1.1                                                          *
 *                                                                            *
 * Backs up files or directories into RAR-format archives.                    *
 *                                                                            *
 * SYNTAX:                                                                    *
 *   RRBACKUP [source] [options]                                              *
 *                                                                            *
 *   <source> is a fully-qualified directory or file name.                    *
 *                                                                            *
 *   <options> are zero or more of the following, in any order:               *
 *                                                                            *
 *   (The following 3 options alter the default behaviour, which is to back   *
 *   up all files and clear their archive bits.)                              *
 *     /COPY          Back up all files but do not clear archive bits.        *
 *     /DIFF          Back up only files changed since last full backup.      *
 *     /INC           Back up only files changed since last backup.           *
 *                                                                            *
 *     /D             Append the current date to the archive name.            *
 *                                                                            *
 *     /L:<filespec>  Filename of log file.                                   *
 *                                                                            *
 *     /N:<name>      String to use for the name of the backup archive(s).    *
 *                    Default is 'backup'.                                    *
 *                                                                            *
 *     /O             Do not recurse subdirectories.                          *
 *                                                                            *
 *     /P:<password>  LAN password to use when target is a UNC share.         *
 *                                                                            *
 *     /S:<size>      Maximum size of each backup file, in MB.                *
 *                                                                            *
 *     /T:<name>      Target directory for writing the backup files.          *
 *                                                                            *
 *     /U:<userid>    LAN user ID to use when target is a UNC share.          *
 *                                                                            *
 *     /V:<type>      LAN logon verification type.  <type> may be:            *
 *                      NONE    Defer verification until LAN access request.  *
 *                      DOMAIN  Verify on default domain controller.          *
 *                      <other> Verify on domain named <other>.               *
 *                    If nothing is specified, your current IBMLAN.INI        *
 *                    authentication default will be used.                    *
 *                                                                            *
 *     /X:<f1[,f2..]> Filename or mask of files to exclude from backup.       *
 *                    Fully-qualified path names must be used.                *
 *                                                                            *
 *     /Y             Do not prompt for confirmation                          *
 *                                                                            *
 *                                                                            *
 * TODO:                                                                      *
 *   * When logfile specified, add -idp switch.                               *
 *   ? Set CWD on drive to root before backing up.                            *
 *   * Eliminate '/MERGE' option (should see if filename exists instead)      *
 *   * Add /D (datestamp) option for -ag switch.                              *
 *   * Make sure only one of /COPY, /DIFF or /INC is specified.               *
 *   o Fix ParseArguments (and /X:, etc.) to handle spaces in filenames       *
 *   * Rewrote CheckOption to be more intelligent.                            *
 *   * Added help if no option specified.                                     *
 *                                                                            *
 ******************************************************************************/
SIGNAL ON SYNTAX

program = "RAR32"                /* Change to RAR if necessary for your setup */

CALL RxFuncAdd "SysLoadFuncs", "REXXUTIL", "SysLoadFuncs"
CALL SysLoadFuncs

PARSE ARG arguments

source = ParseArguments( arguments )
IF source \= "" THEN DO

    exists = 0
    IF ( FILESPEC("DRIVE", source ) \= "") & ( FILESPEC("PATH", source ) = "") & ( FILESPEC("NAME", source ) = "") THEN DO
        fullname = FILESPEC("DRIVE", source )
        exists = 1
        isdir  = 1
    END
    ELSE DO
        CALL SysFileTree source, "paths.", "DO"
        IF paths.0 > 0 THEN DO
            fullname = paths.1
            exists = 1
            isdir  = 1
        END
        CALL SysFileTree source, "files.", "FO"
        IF files.0 > 0 THEN DO
            fullname = files.1
            exists = 1
            isdir  = 0
        END
    END

    IF exists THEN DO

        SAY "Source: " fullname
        allopts = ""
        DO x = 1 to switches.0
            allopts = allopts || "/"switches.x || " "
        END
        SAY "Options:" allopts

        IF isdir THEN sourcepath = fullname"\*"
        ELSE sourcepath = fullname

        reqop   = 0
        IF CheckOption("DIFF") \= "" THEN reqop = reqop + 1
        IF CheckOption("INC")  \= "" THEN reqop = reqop + 1
        IF CheckOption("COPY") \= "" THEN reqop = reqop + 1
        IF reqop > 1 THEN DO
            SAY
            SAY "ERROR: Only one of /COPY, /DIFF, or /INC may be specified."
            RETURN
        END

        runcommand = BuildRarCommand( sourcepath )
        SAY
        SAY "Ready to perform backup using command line:"
        SAY runcommand
        SAY
        IF CheckOption("Y") = "" THEN DO
            SAY "Press 'Y' to confirm, or any other key to cancel..."
            key = SysGetKey("NOECHO")
            SAY
            IF ( TRANSLATE( key ) \= "Y") THEN DO
                SAY "Backup cancelled."
                RETURN
            END
        END

        retcode = RunBackup( runcommand )
        SAY
        SELECT
            WHEN retcode = 255 THEN SAY "RAR: Aborted by user."
            WHEN retcode =   9 THEN SAY "RAR: Create file error."
            WHEN retcode =   8 THEN SAY "RAR: Insufficient memory."
            WHEN retcode =   7 THEN SAY "RAR: Invalid command-line specified."
            WHEN retcode =   6 THEN SAY "RAR: File open error."
            WHEN retcode =   5 THEN SAY "RAR: Disk write error."
            WHEN retcode =   4 THEN SAY "RAR: Locked archive error."
            WHEN retcode =   3 THEN SAY "RAR: CRC error."
            WHEN retcode =   2 THEN SAY "RAR: Fatal error."
            WHEN retcode =   1 THEN SAY "RAR: Non-fatal error."
            WHEN retcode =   0 THEN SAY "Backup completed successfully."
            WHEN retcode =  -1 THEN SAY "LAN: No password specified for user ID."
            WHEN retcode =  -2 THEN SAY "LAN: Network logon was unsuccessful."
            OTHERWISE SAY "Backup return code:" retcode
        END

    END
    ELSE SAY source ": No such file or directory."

END
ELSE
    CALL PrintHelp

RETURN


/******************************************************************************
 * ParseArguments()                                                           *
 *                                                                            *
 * Generate a stem variable containing all user-specified options.            *
 ******************************************************************************/
ParseArguments: PROCEDURE EXPOSE switches.
    ARG arguments

    IF arguments = "" THEN RETURN ""
    ELSE DO
        source = ""
        j      = 0
        DO i = 1 TO WORDS( arguments )
            parm = WORD( arguments, i )
            IF ( LEFT( parm, 1 ) = "/") | ( LEFT( parm, 1 ) = "-") THEN DO
                IF ( LENGTH( parm ) > 1 ) THEN DO
                    j = j + 1
                    switches.j = SUBSTR( parm, 2 )
                END
                ELSE SAY "Ignoring illegal argument:" parm
            END
            ELSE IF source = "" THEN
                source = STRIP( parm, 'T', '\')
            ELSE SAY "Ignoring illegal argument:" parm
        END
        switches.0 = j
    END
RETURN source


/******************************************************************************
 * BuildRarCommand()                                                          *
 *                                                                            *
 * Generate the RAR.EXE command-line from the user-specified options.         *
 ******************************************************************************/
BuildRarCommand: PROCEDURE EXPOSE program switches.
    ARG sourcepath

    flags   = ""
    tail    = ""

    archive = CheckOption("N")
    IF archive = "" THEN archive = "backup"

    IF STREAM( archive, 'C', 'QUERY EXISTS') \= "" THEN            action = "u"
    ELSE IF STREAM( archive'.RAR', 'C', 'QUERY EXISTS') \= "" THEN action = "u"
    ELSE                                                           action = "a"

    IF CheckOption("DIFF") \= "" THEN      flags = flags "-ao"
    ELSE IF CheckOption("INC") \= "" THEN  flags = flags "-ac -ao"
    ELSE IF CheckOption("COPY") \= "" THEN NOP
    ELSE                                   flags = flags "-ac"

    IF CheckOption("O") = "" THEN flags = flags "-r"

    IF CheckOption("D") \= "" THEN flags = flags "-agYYYYMMDD"

    target = CheckOption("T")
    IF target \= "" THEN DO
        target = STRIP( target, "T", "\")
        archive = target"\"archive
    END

    size = CheckOption("S")
    IF size \= "" THEN DO
        flags = flags "-v"size"m"
    END
    ELSE flags = flags "-v630m"

    excl = CheckOption("X")
    IF excl \= "" THEN DO
        excl = TRANSLATE( excl, " ", ",")
        DO i = 1 to WORDS( excl )
            flags = flags "-x" || WORD( excl, i )
        END
    END

    flags = flags "-x""WP ROOT. SF"" -dh -vn"     /* Always use these options */

    log = CheckOption("L")
    IF log \= "" THEN DO
        flags = flags "-idp"
        tail = "2>&1 |tee "log
    END

    flags = STRIP( flags )

    fullcommand = program action flags archive sourcepath tail

RETURN fullcommand


/******************************************************************************
 * CheckOption()                                                              *
 *                                                                            *
 * Check if a given command-line option was specified.  If the option was     *
 * specified with an argument (e.g. /U:user) then return the argument; if     *
 * it was specified with no argument (e.g. /Y) then simply return the         *
 * argument itself.  If it was not specified at all, return an empty string.  *
 ******************************************************************************/
CheckOption: PROCEDURE EXPOSE switches.
    ARG option

    setting = ""
    DO x = 1 to switches.0
        PARSE VAR switches.x switch ':' parm
        IF switch = option THEN DO
            IF parm = "" THEN setting = switch
            ELSE setting = parm
        END
    END

RETURN setting


/******************************************************************************
 * RunBackup()                                                                *
 *                                                                            *
 * Launch RAR.EXE with the generated command-line.                            *
 ******************************************************************************/
RunBackup: PROCEDURE EXPOSE switches.
    PARSE ARG command

    loggedon = 0
    user = CheckOption("U")
    IF user \= "" THEN DO

        password = CheckOption("P")
        IF password = "" THEN RETURN -1
        ELSE DO
            auth = CheckOption("V")
            SELECT
                WHEN auth = "NONE"   THEN logoncmd = "@LOGON" user "/P:"password "/V:NONE"
                WHEN auth = "DOMAIN" THEN logoncmd = "@LOGON" user "/P:"password "/V:DOMAIN"
                WHEN auth = ""       THEN logoncmd = "@LOGON" user "/P:"password
                OTHERWISE                 logoncmd = "@LOGON" user "/P:"password "/V:DOMAIN /D:"auth
            END
            ADDRESS CMD logoncmd
            IF rc \= 0 THEN RETURN -2
            loggedon = 1
        END
    END

    SAY "Starting backup..."
    ADDRESS CMD command
    retcode = rc

    IF loggedon THEN ADDRESS CMD "LOGOFF /Y"

RETURN retcode


/******************************************************************************
 * PrintHelp()                                                                *
 *                                                                            *
 * Display the program help.                                                  *
 ******************************************************************************/
PrintHelp: PROCEDURE
    SAY "RRBACKUP - OS/2 REXX+RAR Backup Procedure v1.1"
    SAY "(C) 2003 Alex Taylor.  Free for use; see LICENSE.TXT for details."
    SAY
    SAY "SYNTAX:     RRBACKUP <parameters>"
    SAY
    SAY "PARAMETERS: (in any order)"
    SAY
    SAY "      <pathspec>      Path to be backed up"
    SAY
    SAY "  Backup Type Options:"
    SAY "      If none of the following three options is specified, the default"
    SAY "      behaviour is to back up all files and clear their archive attributes."
    SAY
    SAY "      /COPY           'Copy'         (Back up all files; do not clear archive"
    SAY "                                     attributes)"
    SAY
    SAY "      /DIFF           'Differential' (Back up only files with archive attribute"
    SAY "                                     set; do not clear archive attributes)"
    SAY
    SAY "      /INC            'Incremental'  (Back up only files with archive attribute"
    SAY "                                     set; clear archive attributes)"
    SAY
    SAY
    SAY "Press 'Enter' to continue or 'Q' to quit..."
    key = SysGetKey("NOECHO")
    IF ( TRANSLATE( key ) = "Q") THEN RETURN
    SAY
    SAY "  Preference Options:"
    SAY "      These options modify the behaviour of the backup operation."
    SAY
    SAY "      /D              Append the current date to the archive name"
    SAY "      /L:<filespec>   Log file name (default: no logging)"
    SAY "      /N:<name>       Name of archive file (default: 'BACKUP')"
    SAY "      /O              Only back up specified directory (do not recurse subdirs)"
    SAY "      /S:<size>       Maximum size of each archive file (default: 630 MB)"
    SAY "      /T:<pathspec>   Target location of archive files (default: current path)"
    SAY "      /X:<f1[,f2..]>  Exclude filemasks from backup"
    SAY "      /Y              Disable confirmation"
    SAY
    SAY "  LAN Options:"
    SAY "      These options apply when the target location (/T parameter) specifies"
    SAY "      a UNC-format network directory, and you are not presently logged on"
    SAY "      with a LAN user ID and password."
    SAY
    SAY "      /P:<password>   LAN password (required if /U is specified)"
    SAY "      /U:<userid>     LAN user ID to log on with"
    SAY "      /V:<type>       Verification type: NONE | DOMAIN | <domain name>"
    SAY
RETURN


/******************************************************************************
 * SIGNAL ON SYNTAX                                                           *
 ******************************************************************************/
SYNTAX:
    SAY "A syntax error was encountered on line" sigl":"
    SAY SOURCELINE( sigl )
EXIT

