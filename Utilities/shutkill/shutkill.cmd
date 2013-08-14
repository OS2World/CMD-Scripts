/*
 * SHUTKILL.CMD
 * (C) Alex Taylor
 *
 * Add a process to the eStyler shutdown process kill-list.  All processes 
 * (specified by EXE name) in the kill-list are terminated before the system
 * shuts down.
 * 
 * Version 1.01  2003-08-30
 *
 */
IF RxFuncQuery('SysLoadFuncs') \= 0 THEN DO
    CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    CALL SysLoadFuncs
END
PARSE ARG switches
switches = TRANSLATE( STRIP( switches ))
IF LEFT( switches, 1 ) = '/' THEN DO
    PARSE VAR switches '/'option killprog
    option   = STRIP( option )
    killprog = STRIP( killprog )
END
ELSE DO
    option   = '?'
    killprog = ''
END


/* Locate ESTYLER.INI */
ecspath = VALUE('OSDIR',,   'OS2ENVIRONMENT')
userini = VALUE('USER_INI',,'OS2ENVIRONMENT')
home    = VALUE('HOME',,    'OS2ENVIRONMENT')

estlini = FILESPEC('DRIVE', userini ) || FILESPEC('PATH', userini ) || '\ESTYLER.INI'
IF STREAM( estlini, 'C', 'QUERY EXISTS') = '' THEN
    estlini = home'\ESTYLER.INI'
IF STREAM( estlini, 'C', 'QUERY EXISTS') = '' THEN
    estlini = ecspath'\system\estyler\ESTYLER.INI'
IF STREAM( estlini, 'C', 'QUERY EXISTS') = '' THEN DO
    SAY 'Cannot locate ESTYLER.INI'
    RETURN 1
END

/* Take the requested action */
SELECT
    WHEN option = 'A' THEN DO
        IF killprog = '' THEN retcode = PrintHelp()
        ELSE retcode = AddToList()
    END
    WHEN option = 'D' THEN DO
        IF killprog = '' THEN retcode = PrintHelp()
        ELSE retcode = RemoveFromList()
    END
    WHEN option = 'L' THEN DO
        retcode = ShowList()
    END
    OTHERWISE retcode = PrintHelp()
END

RETURN retcode


/*
 * AddToList
 *   Add requested program name to the kill-list.
 */
AddToList: 

    SAY 'Adding' killprog 'to shutdown kill-list...'

    /* Update the kill-list in ESTYLER.INI */
    list = SysIni( estlini, 'Shutdown', 'KillList')
    IF ( list = 'ERROR:') THEN retcode = 1
    ELSE DO
        CALL StringTokenize list, '00'x

        IF SearchTokens( killprog ) > 0 THEN DO
            SAY killprog 'is already present in the kill-list.'
            retcode = 1
        END

        ELSE DO
            list = STRIP( list, 'T', X2C('00')) || '00'x || killprog || '0000'x
            list = SysIni( estlini, 'Shutdown', 'KillList', list )
            IF ( list = 'ERROR:') THEN DO
                SAY 'Error updating kill-list.'
                retcode = 1
            END
            ELSE DO
                SAY 'Updated kill-list successfully.'
                retcode = 0
            END
        END
        DROP tokens.
    
    END

RETURN retcode


/* 
 * RemoveFromList
 *   Remove the selected program name from the kill-list.
 */
RemoveFromList:
    SAY 'Adding' killprog 'to shutdown kill-list...'

    /* Update the kill-list in ESTYLER.INI */
    list = SysIni( estlini, 'Shutdown', 'KillList')
    IF ( list = 'ERROR:') THEN retcode = 1
    ELSE DO

        CALL StringTokenize list, '00'x
        delidx = SearchTokens( killprog )

        IF delidx = 0 THEN DO
            SAY killprog 'was not found in the kill-list.'
            retcode = 1
        END

        ELSE DO
            list = ''
            DO i = 1 to tokens.0
                IF i \= delidx THEN list = list || tokens.i || '00'x
            END
            list = list || '00'x
            list = SysIni( estlini, 'Shutdown', 'KillList', list )
            IF ( list = 'ERROR:') THEN DO
                SAY 'Error updating kill-list.'
                retcode = 1
            END
            ELSE DO
                SAY 'Updated kill-list successfully.'
                retcode = 0
            END
        END
        DROP tokens.
    
    END
RETURN retcode


/* 
 * ShowList
 *   Display the current kill-list.
 */
ShowList:

    list = SysIni( estlini, 'Shutdown', 'KillList')
    IF ( list = 'ERROR:') THEN retcode = 1
    ELSE DO
        CALL StringTokenize list, '00'x
        IF tokens.0 > 0 THEN DO
            SAY 'The shutdown kill-list contains the following programs ('tokens.0 'total):'
            DO i = 1 to tokens.0
                SAY ' ' tokens.i
            END
        END
        ELSE SAY 'The shutdown kill-list is empty.'
        retcode = 0
    END
    SAY

RETURN retcode


/*
 * PrintHelp
 *   Print the program syntax.
 */
PrintHelp:

    SAY 'SHUTKILL.CMD'
    SAY '    Adds an executable program to the shutdown kill-list.'
    SAY '    Syntax: SHUTKILL <option> [<exe name>]'
    SAY 
    SAY '      Options:'
    SAY '         /A      Add <exe name> to the kill-list; <exe name> is required.'
    SAY '         /D      Delete <exe name> from the kill-list; <exe name> is required.'
    SAY '         /L      List all programs currently in the kill-list.'
    SAY '         /?      Show help.'
    SAY
    RETURN 0

RETURN 0


/*
 * StringTokenize
 *   Utility function to tokenize a string using the given separator.
 */
StringTokenize: PROCEDURE EXPOSE tokens.
    PARSE ARG string, separator

    IF ( string = '') THEN RETURN string
    IF ( separator = '') THEN separator = ' '

    i        = 0
    tokens.0 = i
    string = STRIP( string, 'B', separator )
    DO WHILE LENGTH( string ) > 0
        x = 1
        y = POS( separator, string, x )
        IF y > 0 THEN DO
            current = SUBSTR( string, 1, y-1 )
            x = y + 1
            i = i + 1
            tokens.i = current
        END
        ELSE DO
            current = STRIP( string, 'B', separator )
            i = i + 1
            tokens.i = current
            x = LENGTH( string ) + 1
        END
        string = SUBSTR( string, x )
    END
    tokens.0 = i

RETURN


/*
 * SearchTokens
 *   Utility function to search the 'tokens.' stem and return the index which
 *   contains the requested string, or 0 if the string is not found.
 */
SearchTokens: PROCEDURE EXPOSE tokens.
    PARSE ARG target, matchcase

    IF matchcase = '' THEN matchcase = 0

    found = 0
    DO i = 1 TO tokens.0
        IF matchcase = 0 THEN DO
            IF TRANSLATE( target ) = TRANSLATE( tokens.i ) THEN found = i
        END
        ELSE DO
            IF target = tokens.i THEN found = i
        END
    END

RETURN found

