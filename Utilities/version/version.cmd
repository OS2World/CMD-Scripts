/******************************************************************************
 * VERSION.CMD                                                                *
 *                                                                            *
 * Displays the major installed components, their versions, service levels,   *
 * and install drives, of the active OS/2 system.                             *
 *                                                                            *
 * Syntax:  VERSION [ /v | /? | <file> ]                                      *
 *                                                                            *
 * Returns:    0  normal exit                                                 *
 *             1  error                                                       *
 *                                                                            *
 * This program is (C) 2005 Alex Taylor.  All rights reserved.                *
 * ReadSysLevel procedure is (C) IBM Corporation.                             *
 ******************************************************************************/
SIGNAL ON SYNTAX
SIGNAL ON NOVALUE
ver = '1.21'

IF RxFuncQuery('SysLoadFuncs') == 1 THEN DO
    CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    CALL SysLoadFuncs
END

/*
 * Determine the various product paths.
 */
IF RxFuncQuery('SysBootDrive') == 1 THEN
    bootvol = FILESPEC('DRIVE', VALUE('OS2_SHELL',,'OS2ENVIRONMENT'))
ELSE
    bootvol = SysBootDrive()
mmbase  = STRIP( VALUE('MMBASE',,'OS2ENVIRONMENT'), 'T', ';')
ibmlvl  = bootvol'\IBMLVL.INI'
nappath = STRIP( SysIni( ibmlvl, 'IBM_LANX', 'PATH'), 'T', '00'x )
mugpath = STRIP( SysIni( ibmlvl, 'IBM_UPM',  'PATH'), 'T', '00'x )
lanpath = STRIP( SysIni( ibmlvl, 'IBM_LS',   'PATH'), 'T', '00'x )
tcppath = FILESPEC('DRIVE', SysSearchPath('PATH', 'INETD.EXE')) || '\TCPIP'

CALL GetNames

PARSE UPPER ARG option
IF LEFT( option, 2 ) == '/V' THEN
    CALL ShowFull
ELSE IF LEFT( option, 2 ) == '/?' THEN
    CALL ShowHelp
ELSE IF option \= '' THEN
    CALL ShowFile option
ELSE
    CALL ShowSummary

RETURN 0


/******************************************************************************
 * ShowSummary                                                                *
 *                                                                            *
 * Default output: display a short summary of various installed products.     *
 ******************************************************************************/
ShowSummary:

    SAY
    SAY 'Installed Component Name                          Version  Service Level  Drive'
    SAY '-------------------------------------------------------------------------------'

    /* Basic OS files */
    CALL OpenSysLevel bootvol'\OS2\INSTALL\SYSLEVEL.ECS', titles.ecs, bootvol
    CALL OpenSysLevel bootvol'\OS2\INSTALL\SYSLEVEL.OS2', titles.os2, bootvol
    /* Multimedia information, if present (Warp 3 only) */
    CALL OpenSysLevel mmbase'\INSTALL\SYSLEVEL.MPM',      titles.mpm, mmbase
    /* Base device drivers */
    CALL OpenSysLevel bootvol'\OS2\INSTALL\SYSLEVEL.BDD', titles.bdd, bootvol

    /* Networking components */
    CALL OpenSysLevel nappath'\SYSLEVEL.TRP',          titles.trp, nappath
    CALL OpenSysLevel tcppath'\BIN\SYSLEVEL.TCP',      titles.tcp, tcppath
    CALL OpenSysLevel lanpath'\SYSLEVEL.PER',          titles.per, lanpath
    CALL OpenSysLevel lanpath'\SYSLEVEL.SRV',          titles.srv, lanpath
    CALL OpenSysLevel lanpath'\SYSLEVEL.REQ',          titles.req, lanpath
    CALL OpenSysLevel mugpath'\SYSLEVEL.MUG',          titles.mug, mugpath
    CALL OpenSysLevel bootvol'\IBM386FS\SYSLEVEL.HFS', titles.hfs, bootvol

RETURN


/******************************************************************************
 * ShowFile                                                                   *
 *                                                                            *
 * Display a multi-line summary of a single user-specified SYSLEVEL file.     *
 ******************************************************************************/
ShowFile:
    ARG target

    IF POS('SYSLEVEL', target ) > 0 THEN
        syslevel = STREAM( target, 'C', 'QUERY EXISTS')
    ELSE DO
        CALL ShowHelp
        RETURN
    END

    IF syslevel == '' THEN
        SAY target': not found'.
    ELSE
        CALL OpenSysLevel syslevel,,, 1

RETURN


/******************************************************************************
 * ShowFull                                                                   *
 *                                                                            *
 * Display a multi-line summary of various installed products (/V option).    *
 ******************************************************************************/
ShowFull:

    test.0  = 11
    /* Basic OS files */
    test.1  = bootvol'\OS2\INSTALL\SYSLEVEL.ECS'
    test.2  = bootvol'\OS2\INSTALL\SYSLEVEL.OS2'
    /* Multimedia information, if present (Warp 3 only) */
    test.3  = mmbase'\INSTALL\SYSLEVEL.MPM'
    /* Base device drivers */
    test.4  = bootvol'\OS2\INSTALL\SYSLEVEL.BDD'
    /* Networking components */
    test.5  = nappath'\SYSLEVEL.TRP'
    test.6  = tcppath'\BIN\SYSLEVEL.TCP'
    test.7  = lanpath'\SYSLEVEL.PER'
    test.8  = lanpath'\SYSLEVEL.SRV'
    test.9  = lanpath'\SYSLEVEL.REQ'
    test.10 = mugpath'\SYSLEVEL.MUG'
    test.11 = bootvol'\IBM386FS\SYSLEVEL.HFS'

    show = 0
    DO i = 1 TO test.0
        IF STREAM( test.i, 'C', 'QUERY EXISTS') \= '' THEN DO
            IF show == 0 THEN CALL SysCls
            show = show + 1
            CALL OpenSysLevel test.i,, bootvol, 2
            IF show == 2 THEN DO
                SAY ' ------------------------------------------------------------------------------'
                '@pause'
                show = 0
            END
        END
    END

RETURN


/******************************************************************************
 * ShowHelp                                                                   *
 *                                                                            *
 * Display program version and usage information (/? option).                 *
 ******************************************************************************/
ShowHelp:
    SAY 'VERSION.CMD - Display SYSLEVEL version information'
    SAY 'V'ver '- (C) 2005 Alex Taylor'
    SAY
    SAY 'Syntax: '
    SAY '    version [ <option> | <SYSLEVEL file> ]'
    SAY
    SAY 'Options:'
    SAY '    /V   Verbose output'
    SAY '    /?   Show help'
RETURN



/******************************************************************************
 * GetNames                                                                   *
 *                                                                            *
 * Read the product name table, if present.                                   *
 ******************************************************************************/
GetNames:

    titles.ecs = ''
    titles.os2 = ''
    titles.bdd = ''
    titles.mpm = ''
    titles.trp = ''
    titles.tcp = ''
    titles.srv = ''
    titles.per = ''
    titles.req = ''
    titles.mug = ''
    titles.hfs = ''

    PARSE SOURCE . . srcspec
    srcpath   = FILESPEC('DRIVE', srcspec ) || FILESPEC('PATH', srcspec )
    nametable = STREAM( srcpath'\version.tbl', 'C', 'QUERY EXISTS')
    IF nametable \= '' THEN DO WHILE LINES( nametable )
        entry = LINEIN( nametable )
        PARSE VAR entry 'SYSLEVEL.'sle';'text
        IF sle \= '' & text \= '' THEN titles.sle = text
    END

RETURN


/******************************************************************************
 * OpenSysLevel                                                               *
 *                                                                            *
 * Read the specified SYSLEVEL file and display certain fields from it.       *
 ******************************************************************************/
OpenSysLevel: PROCEDURE
    PARSE ARG syslevel, title, location, verbose

    slfh.0 = 0
    st.0 = 0
    r = ReadSysLevel( syslevel )
    IF r = 1 THEN DO

        major      = SUBSTR( st.bSysVersion, 1, 1 )
        minor      = SUBSTR( st.bSysVersion, 2, 1 )
        modify     = ABS("0."st.bSysModify )
        refresh    = ABS( st.bRefreshLevel )
        version    = ABS( major"."minor ) + modify
        IF refresh = 0 THEN
            fullver = version
        ELSE
            fullver = version"."refresh
        PARSE VALUE STRIP( st.achCsdLevel, "T", "_") WITH currentCSD '00'x .
        PARSE VALUE STRIP( st.achCsdPrev, "T", "_")  WITH priorCSD   '00'x .

        slfile = TRANSLATE( FILESPEC("NAME", syslevel ))
        IF title == '' THEN DO
            PARSE VAR st.achSysName title '00'x .
            title = STRIP( title )
        END

        IF verbose < 1 THEN DO
            IF LENGTH( title ) > 48 THEN title = LEFT( title, 46 ) || '...'
            SAY LEFT( title, 49 ) LEFT( fullver, 8 ) LEFT( currentCSD, 14 ) FILESPEC('DRIVE', location )
        END
        ELSE DO
            PARSE VAR st.usSysId    subsystem '00'x .
            PARSE VAR st.achCompId  component '00'x .
            PARSE VAR st.achType    type      '00'x .
            IF verbose > 1 THEN
                SAY ' ------------------------------------------------------------------------------'
            ELSE
                SAY
            SAY ' ' TRANSLATE( syslevel )
            SAY ' ' title
            SAY
            SAY '  Subsystem ID.......: ' subsystem
            SAY '  Component ID.......: ' component
            SAY '  Type...............: ' type
            SAY
            SAY '  Version............: ' fullver
            SAY '  Current CSD Level..: ' currentCSD
            SAY '  Prior CSD Level....: ' priorCSD
        END
    END

RETURN r


/******************************************************************************
 * ReadSysLevel                                                               *
 *                                                                            *
 * This procedure is (probably) (C) IBM.  Parses a SYSLEVEL file.             *
 ******************************************************************************/
ReadSysLevel: procedure expose slfh. st.
parse arg fs

   res = 0
   if stream(fs,"C","Query Exists") <> "" then do
      data = charin(fs,1,chars(fs))
      slfh.usSignature   = c2x(reverse(substr(data,1,2)))     /* special # for id of syslevel file */
      slfh.achSignature  = substr(data,3,8)                   /* string to id slf file, must be 'SYSLEVEL' */
      slfh.achJulian     = substr(data,11,5)                  /* date of version */
      slfh.usSlfVersion  = c2x(reverse(substr(data,16,2)))    /* version of syslevel file, must be 1 */
      slfh.ausReserved   = c2x(substr(data,18,16))            /* reserved */
      slfh.ulTableOffset = c2d(reverse(substr(data,34,4)))    /* offset of SYSTABLE */

      /* Calculate table start
      */
      tblst = slfh.ulTableOffset+1

      st.usSysId       = c2x(reverse(substr(data, tblst+0,2))) /* identifies system /subsytem */
      st.bSysEdition   = c2x(substr(data, tblst+2,1))          /* edition of system, eg SE=00, EE=01 */
      st.bSysVersion   = c2x(substr(data, tblst+3,1))          /* version, eg 1.00=10, 1.10=11 */
      st.bSysModify    = c2x(substr(data, tblst+4,1))          /* modify, eg 1.00=00, 1.01=01 */
      st.usSysDate     = c2x(reverse(substr(data, tblst+5,2))) /* date of system */
      st.achCsdLevel   = substr(data, tblst+7,8)               /* subsytem CSD level, eg, XR?0000_ */
      st.achCsdPrev    = substr(data, tblst+15,8)              /* as above, except for prev system */
      st.achSysName    = substr(data, tblst+23,80)             /* Title of system / subsytem (ASCIIZ) */
      st.achCompId     = substr(data, tblst+103,9)             /* component ID of subsytem */
      st.bRefreshLevel = c2x(substr(data, tblst+112,1))
      st.achType       = substr(data, tblst+113,9)             /* Null terminated type (8 chars +'\0') */
      st.usReserved    = substr(data, tblst+122,12)            /* reserved, must be 0 */
      res = 1
      call stream fs,"C","Close"
   end
return res


/******************************************************************************
 * CONDITION HANDLERS                                                         *
 ******************************************************************************/
NOVALUE:
    SAY
    SAY ' Reference to non-initialized variable.'
    SAY '' sigl':' SOURCELINE( sigl )
    SAY
EXIT sigl

SYNTAX:
    SAY
    SAY ' Syntax error.'
    SAY '' sigl':' SOURCELINE( sigl )
    SAY
EXIT sigl

