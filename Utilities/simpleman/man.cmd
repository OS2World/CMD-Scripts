/*****************************************************************************
 * MAN.CMD                                                                   *
 *                                                                           *
 * Simplified 'man' command for viewing Unix-style man pages under OS/2.     *
 *****************************************************************************/
SIGNAL ON NOVALUE

/* --- THESE VARIABLES CAN BE EDITED AS APPROPRIATE FOR YOUR SYSTEM -------- */

/* Terminal type for the pager (e.g. less) to fall back on if the TERM
 * environment variable is not set in the operating system.
 */
termtype = 'os2'

/* Troff-compatible command used to format the man page.  cawf is the default,
 * since it's small and easy to install.  Change to 'groff -man' if you are
 * using GNU groff instead.
 */
troffcmd = 'cawf -man'

/* --- END OF VARIABLES SECTION -------------------------------------------- */

verstr = "1.0"

PARSE ARG manpage
IF manpage == '' THEN DO
    CALL ShowHelp
    RETURN
END

manfile = FindManPage( manpage )
IF manfile == '' THEN DO
    manpath = VALUE('MANPATH',,'OS2ENVIRONMENT')
    SAY 'Cannot find man page "'manpage'", either as literal file or under MANPATH.'
    SAY
    IF manpath == '' THEN SAY 'Current MANPATH = (none)'
    ELSE                  SAY 'Current MANPATH =' TRANSLATE( manpath )
    RETURN
END

CALL DisplayManPage manfile

RETURN


/* ------------------------------------------------------------------------- *
 * ------------------------------------------------------------------------- */
FindManPage: PROCEDURE
    PARSE ARG manpage

    /* First, try the absolute filename. */
    manfile = STREAM( manpage, 'C', 'QUERY EXISTS')

    /* Then we search the current directory and try the extensions .1 - .9,
     * with and without a .gz extension.
     */
    IF manfile == '' THEN DO j = 1 TO 9
        manfile = STREAM( manpage'.'j, 'C', 'QUERY EXISTS')
        IF manfile == '' THEN manfile = STREAM( manpage'.'j'.gz', 'C', 'QUERY EXISTS')
        IF manfile \= '' THEN LEAVE
    END
    IF manfile \= '' THEN RETURN manfile

    /* If that doesn't work, we search the MANPATH */
    manpath = VALUE('MANPATH',,'OS2ENVIRONMENT')
    IF manpath == '' THEN RETURN ''

    CALL StringTokenize manpath, ';', 'dirs.'
    DO i = 1 TO dirs.0

        /*
         * For each directory in %MANPATH%, look for the following:
         *     - man[n]\[manpage].[n]
         *     - man[n]\[manpage].[n].gz
         *     - man[n]\[manpage].gz
         *     - man[n]\[manpage].man
         *     - man[n]\[manpage]
         *     - [manpage].[n]
         *     - [manpage].[n].gz
         *     - [manpage].gz
         *     - [manpage].man
         *     - [manpage]
         * Where [manpage] is the user-requested man page, and [n] is each of
         * the numbers 1 through 9.
         *
         */

        DO j = 1 TO 9
            manfile = STREAM( dirs.i'\man'j'\'manpage'.'j, 'C', 'QUERY EXISTS')
            IF manfile == '' THEN manfile = STREAM( dirs.i'\man'j'\'manpage'.'j'.gz', 'C', 'QUERY EXISTS')
            IF manfile == '' THEN manfile = STREAM( dirs.i'\man'j'\'manpage'.gz', 'C', 'QUERY EXISTS')
            IF manfile == '' THEN manfile = STREAM( dirs.i'\man'j'\'manpage'.man', 'C', 'QUERY EXISTS')
            IF manfile == '' THEN manfile = STREAM( dirs.i'\man'j'\'manpage, 'C', 'QUERY EXISTS')
            IF manfile == '' THEN manfile = STREAM( dirs.i'\'manpage'.'j, 'C', 'QUERY EXISTS')
            IF manfile == '' THEN manfile = STREAM( dirs.i'\'manpage'.'j'.gz', 'C', 'QUERY EXISTS')
            IF manfile \= '' THEN LEAVE
        END
        IF manfile == '' THEN manfile = STREAM( dirs.i'\'manpage'.gz', 'C', 'QUERY EXISTS')
        IF manfile == '' THEN manfile = STREAM( dirs.i'\'manpage'.man', 'C', 'QUERY EXISTS')
        IF manfile == '' THEN manfile = STREAM( dirs.i'\'manpage, 'C', 'QUERY EXISTS')

        IF manfile \= '' THEN LEAVE
    END

RETURN manfile


/* ------------------------------------------------------------------------- *
 * ------------------------------------------------------------------------- */
DisplayManPage: PROCEDURE EXPOSE troffcmd termtype
    PARSE ARG manfile

    CALL SETLOCAL

    term  = VALUE('TERM',,  'OS2ENVIRONMENT')
    pager = VALUE('PAGER',, 'OS2ENVIRONMENT')
    IF pager == '' THEN pager = 'less'
    IF term  == '' THEN CALL VALUE 'TERM', termtype, 'OS2ENVIRONMENT'

    SAY 'Formatting' manfile '...'

    manext = SUBSTR( manfile, LASTPOS('.', manfile ))
    IF TRANSLATE( manext ) == '.GZ' THEN
        '@gzip -cd' manfile '|' troffcmd '|' pager
    ELSE
        '@'troffcmd manfile '|' pager

    CALL ENDLOCAL

RETURN 0


/* ------------------------------------------------------------------------- *
 * ------------------------------------------------------------------------- */
ShowHelp: PROCEDURE EXPOSE verstr
    PARSE SOURCE . . me .
    myname = FILESPEC('NAME', me )
    SAY TRANSLATE( myname ) '- Simplified MAN for viewing Unix-style manual pages'
    SAY 'v'verstr '- (C) 2006 Alex Taylor'
    SAY
    SAY 'Syntax:' SUBSTR( myname, 1, LASTPOS('.',myname) - 1 ) '<manpage>'
RETURN


/* ------------------------------------------------------------------------- *
 * StringTokenize                                                            *
 *                                                                           *
 * Utility function to tokenize a string using the given separator.  Uses a  *
 * 'hidden' inner function to allow passing a stem as a parameter.           *
 * ------------------------------------------------------------------------- */
StringTokenize:
    ARG string, separator, __stem
    CALL __StringTokenize string, separator, __stem
    DROP __stem
RETURN

__StringTokenize: PROCEDURE EXPOSE (__stem)
    PARSE ARG string, separator, tokens

    IF ( string = '') THEN RETURN string
    IF ( separator = '') THEN separator = ' '

    i = 0
    CALL VALUE tokens || '0', i
    string = STRIP( string, 'B', separator )
    DO WHILE LENGTH( string ) > 0
        x = 1
        y = POS( separator, string, x )
        IF y > 0 THEN DO
            current = SUBSTR( string, 1, y-1 )
            x = y + 1
            i = i + 1
            CALL VALUE tokens || 'i', current
        END
        ELSE DO
            current = STRIP( string, 'B', separator )
            i = i + 1
            CALL VALUE tokens || 'i', current
            x = LENGTH( string ) + 1
        END
        string = SUBSTR( string, x )
    END
    CALL VALUE tokens || '0', i

RETURN


/* ------------------------------------------------------------------------- *
 * SIGNAL HANDLERS                                                           *
 * ------------------------------------------------------------------------- */
NOVALUE:
    SAY RIGHT( sigl, 6 ) '+++' STRIP( SOURCELINE( sigl ))
    SAY 'Uninitialized variable.'
EXIT sigl

