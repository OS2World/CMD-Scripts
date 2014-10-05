/* REXX - FIX.CMD version 2.0
 * (C) 2003 Alex Taylor
 * ReadSysLevel function is (C) IBM (AFAIK).
 *
 * Apply the specified OS/2 fixpak using the OS2SERV.EXE graphical interface.
 *
 * Usage:
 *    FIX  [ [ product | fixpak ]  [ drive ] ]
 *
 * where
 *    product = Name of the OS/2 subsystem to service; may be one of:
 *                  BASE or OS : The base operating system
 *                  MPTS or NET : The base networking product (MPTS)
 *                  PEER, LAN or SERVER : LAN Services (client or server)
 *                  TCP or INET : TCP/IP application services
 *
 *    fixpak  = Directory name of a specific fixpak to install.
 *
 *    (If neither product nor fixpak is specified, BASE is assumed.)
 *
 *    drive   = Drive to search for products to be serviced.  The current
 *              boot drive is used by default if this is not specified.
 *
 * Examples:
 *    FIX BASE C:
 *    FIX MPTS
 *    FIX XR_W042 F:
 *
 */
CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs
CALL SysCls
SAY


/*
 * Default fixpaks for the various products:
 */

defp.warp3   = "XR_W040"     /* Warp 3 or Connect */
defp.warpsrv = "XR_W043"     /* Warp Server v4 & SMP */
defp.warp4   = "XR_M015"     /* Warp 4 */
defp.warpseb = "XR_E003"     /* Warp Server for e-business */
defp.warpcp  = "XR_C003"     /* Warp Convenience Package */
defp.mpts510 = "WR_8423"     /* MPTS v5.1 (Warp 4 initial version) */
defp.mpts512 = "WR_8425"     /* MPTS v5.12 (WR_8423 already installed) */
defp.mpts52  = "WR_8506"     /* MPTS v5.2 (Warp Server SMP) */
defp.mpts53  = "WR_8610"     /* MPTS v5.3 - 5.4 */
defp.mpts55  = "WR_8621"     /* MPTS v5.5 (WR_8610 already installed) */
defp.mpts60  = "WR_8706"     /* MPTS v6.0 */
defp.tcp30   = "UN_0959"     /* TCP/IP v3.0 - 3.1 */
defp.tcp35   = "UN_0965"     /* TCP/IP v3.5 (Warp Server SMP) */
defp.tcp40   = "UN_0980"     /* TCP/IP v4.0 (Warp 4) */
defp.tcp41   = "UN_2001"     /* TCP/IP v4.1 */
defp.tcp42   = "UN_2101"     /* TCP/IP v4.2 - 4.21 (WSOD/WSeb) */
defp.tcp43   = "UN_2207"     /* TCP/IP v4.3 */
defp.peer1   = "IP_8196"     /* Peer v1.0 */
defp.peer4   = "IP_8414"     /* Peer v4.0 */
defp.lan4    = "IP_8230"     /* LAN Server or Requester v4.0 */
defp.lan5    = "IP_8532"     /* LAN Server v5.0 */
defp.lan52   = "IP_8607"     /* LAN Server or Peer v5.20 */

/* These FixPaks use standalone installers instead of the CSF */
standalone = "WR_8421 WR_8423 WR_8600 WR_8610 IP_8233"


/*
 * Parse the requested parameters...
 */

PARSE UPPER ARG service volume

service = STRIP( service )
IF service = "" THEN
    service = "BASE"
IF volume = "" THEN
            /* Can't use SysBootDrive(), it's not available on Warp 3 */
    volume = FILESPEC("DRIVE", VALUE('OS2_SHELL',,'OS2ENVIRONMENT'))
ELSE
    volume = STRIP( volume )
volume = STRIP( volume,'T',':')

fixdata.product   = ""      /* Name of product being serviced */
fixdata.verstring = ""      /* Human-readable product version */
fixdata.version   = ""      /* Numeric product version code */
fixdata.csdprefix = ""      /* Product prefix tag (e.g. 'XR') */
fixdata.csdlevel  = ""      /* Current numeric service level */
fixdata.fixpak    = ""      /* Full name of fixpak being applied */
fixdata.fixtag    = ""      /* FixPak prefix tag (e.g. 'XR') */
fixdata.fixlevel  = ""      /* FixPak numeric service level */
fixdata.source    = ""      /* Location of FixPak files */
fixdata.csf       = ""      /* Location of CSF files */
fixdata.installer = ""      /* Name of standalone FixPak install program */


/*
 * Now we determine:
 *   The component requested for service (OS/2, MPTS, LAN, or TCP/IP)
 *   The currently-installed service level of that component
 *   The fixpak to install (if none specified, default to the latest)
 */

CALL GetSelections service volume

fixdata.fixtag = TRANSLATE( SUBSTR( fixdata.fixpak, 1, 2 ))
fixdata.fixlevel = SUBSTR( fixdata.fixpak, 4 )

IF fixdata.product \= "" THEN DO
    SAY "Product to update:    " fixdata.product
    SAY "Installed version:    " fixdata.verstring
    SAY "Current service level:" fixdata.csdprefix || fixdata.csdlevel
    SAY "FixPak to apply:      " fixdata.fixpak
END
SAY


/*
 * Determine the location of the requested fixpak files.
 */

CALL SysFileTree fixdata.fixpak, "fixpath", "DSO"
IF fixpath.0 > 0 THEN
DO idx = 1 TO fixpath.0
    IF POS("DISKIMGS", TRANSLATE( fixpath.idx )) = 0 THEN
        fixdata.source = TRANSLATE( fixpath.idx )
END
IF fixdata.source = "" THEN DO
    SAY "No source directory for FixPak" fixdata.fixpak "was found."
    RETURN -1
END

SAY "FixPak files will be installed from:" fixdata.source


/*
 * If this is not a CSF FixPak, look for a standalone install program.
 */

IF POS( fixdata.fixpak, standalone ) > 0 THEN DO
    CALL SysFileTree fixdata.source"\INSTALL.CMD", "instprog.", "FO"
    IF instprog.0 = 0 THEN DO
        SAY "This FixPak uses a standalone installer."
        SAY
        SAY "For installation instructions, refer to the FixPak documentation under"
        SAY fixdata.source
        RETURN 0
    END
    ELSE fixdata.installer = instprog.1
END


/*
 * Determine the location of the Corrective Service Facility.
 */

/* Look for the %CSFUTILPATH% environment first. */
fixdata.csf = VALUE("CSFUTILPATH",,"OS2ENVIRONMENT")

/* Next, recursively search the current path for a "CSF" directory. */
IF fixdata.csf = "" THEN DO
    CALL SysFileTree "CSF", "csfpath", "DSO"
    IF csfpath.0 > 0 THEN fixdata.csf = TRANSLATE( csfpath.1 )
END

/* Finally, search the system PATH. */
IF fixdata.csf = "" THEN DO
    val = SysSearchPath("PATH","FSERVICE.EXE")
    IF val \= "" THEN
        fixdata.csf = FILESPEC("DRIVE",val) || FILESPEC("PATH",val)
END

IF fixdata.csf = "" THEN DO
    SAY "The Corrective Service Facility could not be located."
    RETURN -2
END

IF fixdata.installer = "" THEN
    SAY "The Corrective Service Facility is located in:" fixdata.csf


/*
 * We have all we need, so prompt the user for confirmation.
 */

SAY
IF fixdata.fixlevel = fixdata.csdlevel THEN DO
    SAY "It looks as though this FixPak has already been installed."
    SAY "You may continue anyway, in which case your current service level"
    SAY "will be refreshed."
    SAY
END

SAY
SAY "Ready to apply service."
SAY
SAY "Enter 'Y' to confirm, or any other key to cancel..."
key = SysGetKey("NOECHO")


/*
 * Now launch the FixPak installation.
 */

retcode = 0
IF ( TRANSLATE( key ) = "Y") THEN DO
    IF fixdata.installer \= "" THEN DO
        SAY "Launching standalone installer for" fixdata.fixpak "..."
        "CMD /C" fixdata.installer
    END
    ELSE DO
        CALL SETLOCAL
        val = VALUE("CSFDRIVEAPPLY", volume, "OS2ENVIRONMENT")
        val = VALUE("REMOTE_INSTALL_STATE", "0", "OS2ENVIRONMENT")
        SAY
        SAY "Launching graphical interface for service installation ..."
        "@OS2SERV.EXE" fixdata.csf fixdata.source
    END
    retcode = rc
    SAY "The service program completed with return code" rc"."
END
ELSE SAY "Service cancelled."
SAY

RETURN retcode



/* -------------------------------------------------------------------------- */
GetSelections: PROCEDURE EXPOSE defp. fixdata.
    ARG service volume

    SELECT
        WHEN ( SUBSTR(service,1,2) = "OS"  | service = "BASE" ) THEN
            DO
                CALL DetermineVersion volume":\OS2\INSTALL\SYSLEVEL.OS2"
                CALL DetermineLevel volume":\OS2\INSTALL\SYSLEVEL.FPK"
                SELECT
                    WHEN fixdata.version = "3000" THEN fixdata.fixpak = defp.warp3
                    WHEN fixdata.version = "3001" THEN fixdata.fixpak = defp.warpsrv
                    WHEN fixdata.version = "3002" THEN fixdata.fixpak = defp.warpsrv
                    WHEN fixdata.version = "4000" THEN fixdata.fixpak = defp.warp4
                    WHEN fixdata.version = "4500" THEN fixdata.fixpak = defp.warpseb
                    WHEN fixdata.version = "4501" THEN fixdata.fixpak = defp.warpcp
                    WHEN fixdata.version = "4502" THEN fixdata.fixpak = defp.warpcp
                    OTHERWISE fixdata.fixpak = defp.warpcp
                END
            END
        WHEN ( SUBSTR(service,1,3) = "NET" | service = "MPTS" ) THEN
            DO
                CALL DetermineVersion volume":\IBMCOM\SYSLEVEL.TRP"
                SELECT
                    WHEN fixdata.version = "2600" THEN fixdata.fixpak = defp.mpts510
                    WHEN fixdata.version = "5000" THEN fixdata.fixpak = defp.mpts510
                    WHEN fixdata.version = "5100" THEN fixdata.fixpak = defp.mpts510
                    WHEN fixdata.version = "5101" THEN fixdata.fixpak = defp.mpts512
                    WHEN fixdata.version = "5102" THEN fixdata.fixpak = defp.mpts512
                    WHEN fixdata.version = "5200" THEN fixdata.fixpak = defp.mpts52
                    WHEN fixdata.version = "5300" THEN fixdata.fixpak = defp.mpts53
                    WHEN fixdata.version = "5400" THEN fixdata.fixpak = defp.mpts53
                    WHEN fixdata.version = "5500" THEN fixdata.fixpak = defp.mpts55
                    WHEN fixdata.version = "6000" THEN fixdata.fixpak = defp.mpts60
                    WHEN fixdata.version = "6001" THEN fixdata.fixpak = defp.mpts60
                    OTHERWISE fixdata.fixpak = defp.mpts60
                END
            END
        WHEN ( SUBSTR(service,1,3) = "LAN" | SUBSTR(service,1,4) = "SERV" | service = "PEER" ) THEN
            DO
                peer = DetermineVersion( volume":\IBMLAN\SYSLEVEL.PER")

                IF peer THEN DO
                    CALL DetermineLevel volume":\IBMLAN\SYSLEVEL.REQ"
                    SELECT
                        WHEN fixdata.version = "1000" THEN fixdata.fixpak = defp.peer1
                        WHEN fixdata.version = "4000" THEN fixdata.fixpak = defp.peer4
                        WHEN fixdata.version = "5200" THEN fixdata.fixpak = defp.lan52
                        OTHERWISE fixdata.fixpak = defp.lan52
                    END
                END
                ELSE DO
                    CALL DetermineVersion volume":\IBMLAN\SYSLEVEL.REQ"
                    CALL DetermineVersion volume":\IBMLAN\SYSLEVEL.SRV"
                    SELECT
                        WHEN fixdata.version = "4000" THEN fixdata.fixpak = defp.lan4
                        WHEN fixdata.version = "4006" THEN fixdata.fixpak = defp.lan4
                        WHEN fixdata.version = "5000" THEN fixdata.fixpak = defp.lan5
                        WHEN fixdata.version = "5003" THEN fixdata.fixpak = defp.lan5
                        WHEN fixdata.version = "5200" THEN fixdata.fixpak = defp.lan52
                        OTHERWISE fixdata.fixpak = defp.lan52
                    END
                END
            END
        WHEN ( SUBSTR(service,1,3) = "TCP" | service = "INET" ) THEN
            DO
                CALL DetermineVersion volume":\TCPIP\BIN\SYSLEVEL.TCP"
                SELECT
                    WHEN fixdata.version = "3000" THEN fixdata.fixpak = defp.tcp30
                    WHEN fixdata.version = "3100" THEN fixdata.fixpak = defp.tcp30
                    WHEN fixdata.version = "3500" THEN fixdata.fixpak = defp.tcp35
                    WHEN fixdata.version = "4000" THEN fixdata.fixpak = defp.tcp40
                    WHEN fixdata.version = "4100" THEN fixdata.fixpak = defp.tcp41
                    WHEN fixdata.version = "4200" THEN fixdata.fixpak = defp.tcp42
                    WHEN fixdata.version = "4201" THEN fixdata.fixpak = defp.tcp42
                    WHEN fixdata.version = "4300" THEN fixdata.fixpak = defp.tcp43
                    WHEN fixdata.version = "4301" THEN fixdata.fixpak = defp.tcp43
                    WHEN fixdata.version = "4302" THEN fixdata.fixpak = defp.tcp43
                    OTHERWISE fixdata.fixpak = defp.tcp43
                END
            END
        OTHERWISE       /* User requested a specific fixpak */
            fixdata.fixpak = service
    END

RETURN


/* -------------------------------------------------------------------------- */
DetermineVersion: PROCEDURE EXPOSE fixdata.
    ARG syslevel

    r = ReadSysLevel( syslevel )
    IF ( r = 1 ) THEN DO
        currentCSD = STRIP( st.achCsdLevel, "T", "_")
        fixdata.version   = st.bSysVersion || st.bSysModify
        fixdata.csdprefix = SUBSTR( currentCSD, 1, 3 )
        fixdata.csdlevel  = SUBSTR( currentCSD, 4 )

        major      = SUBSTR( st.bSysVersion, 1, 1 )
        minor      = SUBSTR( st.bSysVersion, 2, 1 )
        modify     = ABS("0."st.bSysModify )
        refresh    = ABS( st.bRefreshLevel )
        version    = ABS( major"."minor ) + modify
        IF refresh = 0 THEN fixdata.verstring = version
        ELSE fixdata.verstring = version"."refresh

        PARSE VAR st.achSysName fixdata.product '00'x junk
        fixdata.product = STRIP( fixdata.product )

    END

RETURN r


/* -------------------------------------------------------------------------- */
/* DetermineLevel
 *
 * Returns the 'current CSD level' from the specified syslevel file.
 * Used by some products which keep this information in a separate file from
 * the main product syslevel file (e.g. SYSLEVEL.FPK).
 */
DetermineLevel: PROCEDURE EXPOSE fixdata.
    ARG syslevel

    r = ReadSysLevel( syslevel )
    IF ( r = 1 ) THEN DO
        currentCSD = STRIP( st.achCsdLevel, "T", "_")
        fixdata.csdprefix = SUBSTR( currentCSD, 1, 3 )
        fixdata.csdlevel  = SUBSTR( currentCSD, 4 )
    END

RETURN r


/* -------------------------------------------------------------------------- */
ReadSysLevel: procedure expose slfh. st.
call Trace OFF
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
/* -------------------------------------------------------------------------- */
