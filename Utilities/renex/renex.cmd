/******************************************************************************
 * RENEX.CMD                                                                  *
 ******************************************************************************/
version = '0.94'

CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL.DLL', 'SysLoadFuncs'
CALL SysLoadFuncs
CALL RxFuncAdd 'RELOADFUNCS',  'REXXRE.DLL',   'reloadfuncs'
CALL ReLoadFuncs

SIGNAL ON NOVALUE
SIGNAL ON SYNTAX

rever = ReVersion()
IF rever == '' | rever < '1' THEN DO
    SAY 'This program requires REXXRE.DLL version 1.0 or above.'
    RETURN 1
END

PARSE ARG options '"'fspec1'"' . '"'fspec2'"' .

IF fspec1 == '' THEN DO
    CALL PrintHelp
    RETURN 0
END


/*
 * Compile the source regular expression.
 */
srcflags = 'x'
IF POS('C', TRANSLATE( options )) > 0 THEN srcflags = srcflags || 'c'

re_src = ReComp( fspec1, srcflags )
SAY 'Source filespec:' fspec1
IF LEFT( re_src, 1 ) \= 0 THEN DO
    SAY 'Regular expression error in' fspec1':' ReError( re_src )
    RETURN 2
END

/*
 * If a target template was defined, we're doing rename operations.
 * Parse the target template string into tokens; also do some necessary
 * validations before we start renaming.
 */
IF fspec2 \= '' THEN DO
    SAY 'Target filespec:' fspec2
    re_dest = ReComp('^([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?([^\]*)(\\.)?(.*)$', 'x')
    IF LEFT( re_dest, 1 ) \= 0 THEN DO
        SAY 'Regular expression compile error:' ReError( re_dest )
        RETURN 3
    END
    rc = ReExec( re_dest, fspec2, 'tokens.')

    /*
     * Do some quick and dirty sanity checks on the templates.
     * These aren't intelligent enough to detect all problems, but they
     * might help avoid a couple of common pitfalls.
     */
    problems = 0
    IF POS('(', fspec1 ) == 0 THEN DO
        problems = 1
        SAY
        SAY 'WARNING: No substitution groups were defined in the source template.'
        SAY '         Any variable substitutions specified in the target template'
        SAY '         will be ignored!'
    END
    IF POS('\', fspec2 ) == 0 THEN DO
        problems = 2
        SAY
        SAY 'WARNING: No variable substitutions were specified in the target template.'
        SAY '         This means that all rename operations have the same target filename!'
    END
    IF problems > 0 THEN DO
        SAY
        CALL CHAROUT, 'Continue (y/N)?'
        PARSE PULL confirm
        IF LEFT( TRANSLATE( confirm ), 1 ) \= 'Y' THEN RETURN
    END

END


/*
 * Get a list of all files in the directory.
 */
SAY
SAY 'Reading directory...'
SAY
current = STRIP( DIRECTORY(), 'T', '\')
rc = SysFileTree( current'\*', 'files.', 'FO')
IF rc \= 0 THEN RETURN rc

/*
 * Now do the rename for any file that matches our source template.
 */
DO i = 1 TO files.0
    file = FILESPEC('NAME', files.i )
    rc   = ReExec( re_src, file, 'matches.')
    IF rc == 1 THEN DO
        CALL CHAROUT, file
        IF fspec2 \= '' THEN DO
            new = ''
            DO j = 1 TO tokens.0
                t = tokens.j
                IF LEFT( t, 1 ) == '\' THEN DO
                    subst = SUBSTR( t, 2, 1 )
                    IF DATATYPE( subst ) == 'NUM' THEN DO
                        IF SYMBOL('matches.'subst ) == 'VAR' THEN new = new || matches.subst
                        ELSE new = new || subst
                    END
                    ELSE
                        new = new || subst
                END
                ELSE
                    new = new || t
            END
            CALL CHAROUT, '  --> ' new
            IF POS('Y', TRANSLATE( options )) == 0 THEN DO
                SAY
                CALL CHAROUT, ' Rename ([y]es/[N]o/[a]bort)? '
                PARSE PULL answer
                IF LEFT( TRANSLATE( answer ), 1 ) == 'A' THEN DO
                    SAY
                    SAY 'Aborted.'
                    RETURN
                END
                ELSE IF LEFT( TRANSLATE( answer ), 1 ) \= 'Y' THEN DO
                    SAY ' (Skipped)'
                    ITERATE
                END

            END
            '@rename "'file'" "'new'"'
            IF rc == 0 THEN CALL CHAROUT, ' (OK)'
            ELSE            CALL CHAROUT, ' (Failed)'
        END
        SAY
    END

END

CALL ReFree re_src

RETURN 0



/* ------------------------------------------------------------------------- *
 * PrintHelp                                                                 *
 *                                                                           *
 * Displays the program help.                                                *
 * ------------------------------------------------------------------------- */
PrintHelp: PROCEDURE EXPOSE version
    PARSE SOURCE . . fqn
    program = TRANSLATE( FILESPEC('NAME', fqn ))
    command = SUBSTR( program, 1, LASTPOS('.', program ) - 1 )
    SAY 'REName by EXpression ('program') v'version '- (C) 2005 Alex Taylor'
    SAY 'Uses REXXRE Library (C) 2003 Patrick TJ McPhee'
    SAY
    SAY 'Syntax:' command '[options] "source template" ["target template"]'
    SAY
    SAY 'Available options:'
    SAY '    /Y  Don''t prompt for confirmation (default is to prompt for each file)'
    SAY '    /C  Case-sensitive matching (default is case-insensitive)'
    SAY
    SAY '"source template" (quotes are required) is an extended regular expression'
    SAY 'that matches filenames to be listed and/or renamed.'
    SAY
    SAY '"target template" (quotes are required) is the string to which the matched'
    SAY 'filenames will be renamed.  This is a normal string, except that you may use'
    SAY 'the substitution variables \1, \2, \3, ... up to \9 to indicate substitution'
    SAY 'of groups defined in the source template (as per basic regular expression'
    SAY 'rules).  You may specify up to nine such substitutions (including duplicates)'
    SAY 'in the target template.  Any \ character which is not followed by a number'
    SAY 'that refers to a defined group will be discarded.'
    SAY
RETURN


/* ------------------------------------------------------------------------- *
 * CONDITION HANDLERS                                                        *
 * ------------------------------------------------------------------------- */
NOVALUE:
    SAY
    SAY RIGHT( sigl, 6 ) '+++' STRIP( SOURCELINE( sigl ))
    SAY 'Reference to non-initialized variable.'
    SAY
EXIT sigl

SYNTAX:
    SAY
    SAY RIGHT( sigl, 6 ) '+++' STRIP( SOURCELINE( sigl ))
    SAY 'Syntax error.'
    SAY
EXIT sigl

