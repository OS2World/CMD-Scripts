/* World Clock banner gadget */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* Check if the script was directly started */
IF ARG() = 0 THEN DO
    /* Start the gadget */
    PARSE SOURCE . . theScript
    IF ARG(1)="" THEN
        CALL SysSetObjectdata "<WP_DESKTOP>", "WIZLAUNCHGADGET="theScript
        Exit(0)
END

NUMERIC DIGITS 15 /* We need this for calculating with hex numbers */
drawBorder=0
NORMAL_BORDER=1
SUNKEN_BORDER=2
COLOR_BORDER=3

SELECT
    WHEN ARG(1)="/GADGETSTARTED" THEN DO
        theObject=ARG(2)
        SIGNAL ON SYNTAX NAME errorHandler
        SIGNAL ON ERROR NAME errorHandler
        SIGNAL ON FAILURE NAME errorHandler

        /* Check for source file WCLOCK.INI - must be in same directory as gadget */
        PARSE SOURCE . . theScript
        inifile =  SUBSTR(theScript,1,LASTPOS('\',theScript)-1)||"\WCLOCK.INI"

        /* Info for storing data in WPS-wizard ini file */
        APPKEY="wcbannergadget"
        APPPOS="wcbannerpos"
        APPFONT="wcbannerfont"
        APPCOLOR="wcbannercolor"
        APPSTYLE="wcbannerstyle"
        defaultPos="100 "||system.screen.height-130||" "||system.screen.width-200||" 30"


        /* Use defaults in the beginning */
        PARSE VAR defaultPos x y cx cy rest

        /* Gadget create info */
        thestem._x=x                    /* x  */
        thestem._y=y                    /* y  */
        thestem._cx=cx                  /* cx */
        thestem._cy=cy                  /* cy */
        thestem._type=BAR_GADGET        /* Gadget type */
        thestem._hwnd=ARG(3)            /* hwnd */
        thestem._flags=GSTYLE_POPUP     /* We want a popup menu */
        thestem._font="9.WarpSans Bold" /* font */

        /* Get saved position if any */
        ret=Sysini(INIFile, APPKEY, APPPOS)
        IF  ret <> "ERROR:" THEN DO
            PARSE VAR ret thestem._x thestem._y thestem._cx thestem._cy rest
        END
        /* Get saved font if any */
        ret=Sysini(INIFile, APPKEY, APPFONT)
        IF  ret <> "ERROR:" THEN DO
            thestem._font=ret
        END

        /* Create gadget on the desktop */
        rc=WizCreateGadget("DESKTOP", "thestem." , "wcbannerGadget")

        /* Get saved color if any */
        ret=Sysini(INIFile, APPKEY, APPCOLOR)
        IF  ret <> "ERROR:" THEN DO
            call wcbannerGadget.Color ret
        END
        /* Get saved style if any */
        ret=Sysini(INIFile, APPKEY, APPSTYLE)
        IF  ret <> "ERROR:" THEN DO
            PARSE VALUE ret WITH drawBorder .
            SELECT
                WHEN drawBorder = 0 THEN CALL wcbannerGadget.style 0, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
                WHEN drawBorder = 1 THEN CALL wcbannerGadget.style GSTYLE_BORDER, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
                WHEN drawBorder = 2 THEN CALL wcbannerGadget.style GSTYLE_SUNKENBORDER, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
                WHEN drawBorder = 3 THEN CALL wcbannerGadget.style GSTYLE_COLORBORDER, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
                OTHERWISE NOP
            END
        END

        /* Read values from WCLOCK.INI */
        CALL RefreshMe

        /* Start a timer sending a message every 1000ms  */
        ret=WPSWizCallWinFunc("winStartTimer", ARG(3), 10, 1000)

        /* Gadget message loop */
        DO FOREVER
            ret=WIZGETMESSAGE(ARG(3))
            IF ret<>'' THEN
                INTERPRET "call "ret
        END

        EXIT(0)
    END
    OTHERWISE
        /* We shouldn't end here... */
        Exit(0)
END
exit(0)


wcbannergadget.onCommand:
/*
    ARG(1): hwnd of client area
    ARG(2): ID
    ARG(3): source (menu or button)
*/
SELECT
    WHEN ARG(2)=1 THEN DO
        drawBorder=0
        call wcbannerGadget.style 0, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
    END
    WHEN ARG(2)=2 THEN DO
        drawBorder=1
        call wcbannerGadget.style GSTYLE_BORDER, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
    END
    WHEN ARG(2)=3 THEN DO
        drawBorder=2
        call wcbannerGadget.style GSTYLE_SUNKENBORDER, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
    END
    WHEN ARG(2)=4 THEN DO
        drawBorder=3
        call wcbannerGadget.style GSTYLE_COLORBORDER, GSTYLE_SUNKENBORDER + GSTYLE_BORDER + GSTYLE_COLORBORDER
    END
    WHEN ARG(2)=6 THEN CALL RefreshMe
    WHEN ARG(2)=7 THEN DO
        helptext =  'This Gadget displays time similar to Banner View in World Clock. To configure display in Gadget, open Settings window in World Clock and select style, date and time display.'
        IF RxMessageBox(helptext,'World Clock Banner Gadget',,'INFORMATION') = 1 THEN DO
            DROP helptext
        END
    END
    WHEN ARG(2)=9 THEN DO
        call SysIni iniFile, APPKEY, APPPOS,  wcbannerGadget.position()
        call SysIni iniFile, APPKEY, APPFONT, wcbannerGadget.font()
        call SysIni iniFile, APPKEY, APPCOLOR, wcbannerGadget.Color()
        call SysIni iniFile, APPKEY, APPSTYLE, drawBorder
        rc=wizDestroyGadget("wcbannergadget")
        exit(0)
    END
    OTHERWISE NOP
END

return


wcbannergadget.onPopUp:
/*
    ARG(1): hwnd of client area
    ARG(2): x
    ARG(3): y
*/
    menu.0=9
    menu.1="~No Border"
    menu.2="~Border"
    menu.3="~Sunken Border"
    menu.4="~Color Border"
    menu.5="-"
    menu.6="Refresh"
    menu.7="Help"
    menu.8="-"
    menu.9="Close Gadget"

    menu._x=ARG(2)
    menu._y=ARG(3)

    ret=WPSWizCallWinFunc("menuPopupMenu", ARG(1), 'menu.')
    SELECT
        WHEN drawBorder=NORMAL_BORDER THEN ret=WPSWizCallWinFunc("menuCheckItem", ret, 2, 0, 1)
        WHEN drawBorder=SUNKEN_BORDER THEN ret=WPSWizCallWinFunc("menuCheckItem", ret, 3, 0, 1)
        WHEN drawBorder=COLOR_BORDER THEN ret=WPSWizCallWinFunc("menuCheckItem", ret, 4, 0, 1)
        OTHERWISE ret=WPSWizCallWinFunc("menuCheckItem", ret, 1, 0, 1)
    END

return

onTimer:

timersec = TIME('S')//60
IF timersec = 0 THEN DO
	SELECT
		WHEN STREAM(inifile,'C','QUERY DATETIME') <> initime THEN CALL RefreshMe
		OTHERWISE CALL Times
	END		
END
mysec = mysec+1
IF mysec > myLen THEN DO
    mysec = 1
END
CALL wcbannerGadget.text SUBSTR(myText,mysec+1)||LEFT(myText,mysec)

RETURN

RefreshMe:

initime = STREAM(inifile,'C','QUERY DATETIME')
wc_style = SysIni(inifile, 'Settings', 'Clock')                             /* World Clock style        */
wc_stylt = SysIni(inifile, 'Settings', 'Time')                              /* Time display             */
wc_times = SysIni(inifile, 'Gadget', 'Times')                               /* City times               */
wc_cities = SysIni(inifile, 'Gadget', 'Cities')                             /* City names               */

SELECT
    WHEN WORDS(wc_style) <> 11 THEN CALL INIerror "Clock settings"
    WHEN WORDS(wc_stylt) <> 5 THEN CALL INIerror "Time settings"
    WHEN WORDS(wc_times) < WORD(wc_style,4) THEN CALL INIerror "City times"
    WHEN WORDS(wc_cities) <> WORDS(wc_times) THEN CALL INIerror "City names"
    OTHERWISE NOP
END

PARSE VALUE wc_style WITH mydisplay myrows mycols mycitynum mywidth myheight myshowtz mychgmin .
PARSE VALUE wc_stylt WITH mytimedisp mytimesep mytimeampm mytimeutc mytimezero
SELECT
    WHEN mytimesep = 0 THEN tsep = ''
    OTHERWISE tsep = ':'
END
DO w = 1 TO mycitynum
    mycity.w = STRIP(TRANSLATE(WORD(wc_cities,w),' ','_'))
    IF mydisplay = 1 THEN DO
        mycity.w = STRIP(SUBSTR(mycity.w,1,LASTPOS(',',mycity.w)-1))
    END
    mymins.w = WORD(wc_times,w)
END

DROP wc_style wc_stylt wc_cities wc_times

CALL Times

RETURN

Times:

PARSE VALUE TIME() WITH hh ':' mm ':' ss
mymin = hh*60+mm
myText = ''
DO c = 1 TO mycitynum
    citymin = mymin+mymins.c
    SELECT
        WHEN citymin > 1440 THEN citymin = citymin-1440
        WHEN citymin < 0 THEN citymin = citymin+1440
        OTHERWISE NOP
    END
    cityhh = citymin%60
    citymm = citymin//60
    IF mytimeampm = 1 THEN DO
        SELECT
            WHEN cityhh = 0 THEN DO
                cityhh = 12
                ampm = 'am'
            END
            WHEN cityhh < 12 THEN ampm = 'am'
            WHEN cityhh = 12 THEN ampm = 'pm'
            OTHERWISE DO
                cityhh = cityhh-12
                ampm = 'pm'
            END
        END
    END
    mytime = RIGHT(cityhh,2,'0')||tsep||RIGHT(citymm,2,'0')
    IF mytimeampm = 1 THEN DO
        mytime = mytime||ampm
    END
    myText = myText||mycity.c||' '||mytime||'   '
END
myText = COPIES(myText,5)	/* create long string to fill complete banner, if number of cities is small */
myLen = LENGTH(myText)
CALL wcbannerGadget.text myText
mysec = 1

RETURN

INIerror:

PARSE ARG inierr
IF RxMessageBox("Error in configuration file "||FILESPEC('N',inifile)||', section '||inierr,,,"ERROR") = 1 THEN DO
    Exit(0)
END

RETURN


quit:
exit(0)

errorHandler:
    PARSE SOURCE . . theScript

    ret=WPSWizGadgetFunc("cwDisplayRexxError", "")
    ret=WPSWizGadgetFunc("cwDisplayRexxError", theScript||": ")
    ret=WPSWizGadgetFunc("cwDisplayRexxError", "Error in line "||SIGL)

exit(0)

