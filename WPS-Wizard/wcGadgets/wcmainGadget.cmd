/* World Clock main gadget */

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
        APPKEY="wcmaingadget"
        APPPOS="wcmainpos"
        APPFONT="wcmainfont"
        APPCOLOR="wcmaincolor"
        defaultPos=system.screen.width-330||" 100 320 200"

        /* Use defaults in the beginning */
        PARSE VAR defaultPos x y cx cy rest

        /* Gadget create info */
        thestem._x=x                    /* x  */
        thestem._y=y                    /* y  */
        thestem._cx=cx                  /* cx */
        thestem._cy=cy                  /* cy */
        thestem._type=HTML_GADGET       /* Gadget type */
        thestem._hwnd=ARG(3)            /* hwnd */
        thestem._flags=GSTYLE_POPUP     /* We want a popup menu */
        thestem._font="9.WarpSans"      /* font */

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
        rc=WizCreateGadget("DESKTOP", "thestem." , "wcmainGadget")

        /* Get saved color if any */
        ret=Sysini(INIFile, APPKEY, APPCOLOR)
        IF  ret <> "ERROR:" THEN DO
            call wcmainGadget.Color ret
        END

        /* Read values from WCLOCK.INI */
        CALL RefreshMe

        /* Start a timer sending a message every 1000 ms  */
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


wcmaingadget.onCommand:
/*
    ARG(1): hwnd of client area
    ARG(2): ID
    ARG(3): source (menu or button)
*/
SELECT
    WHEN ARG(2)=1 THEN CALL RefreshMe
    WHEN ARG(2)=2 THEN DO
        helptext =  'This Gadget displays time and date similar to List View in World Clock. To configure display in Gadget, open Settings window in World Clock and select style, date and time display.'
        IF RxMessageBox(helptext,'World Clock Gadget',,'INFORMATION') = 1 THEN DO
            DROP helptext
        END
    END
    WHEN ARG(2)=4 THEN DO
        call SysIni iniFile, APPKEY, APPPOS,  wcmainGadget.position()
        call SysIni iniFile, APPKEY, APPFONT, wcmainGadget.font()
        call SysIni iniFile, APPKEY, APPCOLOR, wcmainGadget.Color()
        rc=wizDestroyGadget("wcmaingadget")
        exit(0)
    END
    OTHERWISE NOP
END

return


wcmaingadget.onPopUp:
/*
    ARG(1): hwnd of client area
    ARG(2): x
    ARG(3): y
*/
    menu.0=4
    menu.1="Refresh"
    menu.2="Help"
    menu.3="-"
    menu.4="Close Gadget"

    menu._x=ARG(2)
    menu._y=ARG(3)

    ret=WPSWizCallWinFunc("menuPopupMenu", ARG(1), 'menu.')

return

onTimer:

timersec = TIME('S')
IF timersec//60 = 0 THEN DO
    IF STREAM(inifile,'C','QUERY DATETIME') <> initime THEN DO
        CALL RefreshMe
    END
    IF mydisplay = 1 THEN DO
        CALL Dates
    END
END
CALL Times

RETURN

RefreshMe:

initime = STREAM(inifile,'C','QUERY DATETIME')
wc_lng = SysIni(inifile, 'Settings', 'CurrLang')                            /* Selected language        */
lngfile = SUBSTR(inifile,1,LASTPOS('\',inifile))||wc_lng||'.INI'            /* Language file            */
IF STREAM(lngfile,'C','QUERY EXISTS') = '' THEN DO
    lngfile = SUBSTR(inifile,1,LASTPOS('\',inifile))||'ENGLISH.INI'         /* Default language file    */
END
wc_lngm = SysIni(lngfile, 'Hint', '002')                                    /* Month names              */
wc_dlng = SysIni(lngfile, 'Hint', '001')                                    /* Day names                */
wc_lngd = SUBWORD(wc_dlng,2)||' '||WORD(wc_dlng,1)
wc_style = SysIni(inifile, 'Settings', 'Clock')                             /* World Clock style        */
wc_stylt = SysIni(inifile, 'Settings', 'Time')                              /* Time display             */
wc_styld = SysIni(inifile, 'Settings', 'Date')                              /* Date display             */
wc_times = SysIni(inifile, 'Gadget', 'Times')                               /* City times               */
wc_tz = SysIni(inifile, 'Gadget', 'TZ')                                     /* UTC differences          */
wc_cities = SysIni(inifile, 'Gadget', 'Cities')                             /* City names               */

SELECT
    WHEN WORDS(wc_lngm) <> 12 THEN CALL INIerror "Month names"
    WHEN WORDS(wc_lngd) <> 7 THEN CALL INIerror "Day names"
    WHEN WORDS(wc_style) <> 11 THEN CALL INIerror "Clock settings"
    WHEN WORDS(wc_stylt) <> 5 THEN CALL INIerror "Time settings"
    WHEN WORDS(wc_styld) <> 7 THEN CALL INIerror "Date settings"
    WHEN WORDS(wc_times) < WORD(wc_style,4) THEN CALL INIerror "City times"
    WHEN WORDS(wc_tz) <> WORDS(wc_times) THEN CALL INIerror "UTC differences"
    WHEN WORDS(wc_cities) <> WORDS(wc_times) THEN CALL INIerror "City names"
    OTHERWISE NOP
END

DO w = 1 TO 12
    mymonn.w = LEFT(WORD(wc_lngm,w),3)
END
DO w = 1 TO 7
    mydayn.w = LEFT(WORD(wc_lngd,w),3)
END

PARSE VALUE wc_style WITH mydisplay myrows mycols mycitynum mywidth myheight myshowtz mychgmin .
PARSE VALUE wc_stylt WITH mytimedisp mytimesep mytimeampm mytimeutc mytimezero
PARSE VALUE wc_styld WITH mydatedisp mydatesepis mydatesep mydatecc mydatedow mydatezero mydateshort
SELECT
    WHEN mytimesep = 0 THEN tsep = ''
    OTHERWISE tsep = ':'
END
SELECT
    WHEN mydatesepis = 0 THEN dsep = ''
    WHEN mydatesep = 1 THEN dsep = '-'
    WHEN mydatesep = 2 THEN dsep = '.'
    WHEN mydatesep = 3 THEN dsep = '/'
    OTHERWISE dsep = ' '
END

DO w = 1 TO mycitynum
    mycity.w = STRIP(TRANSLATE(WORD(wc_cities,w),' ','_'))
    mymins.w = WORD(wc_times,w)
    myzone.w = WORD(wc_tz,w)
END

DROP wc_style wc_stylt wc_styld wc_cities wc_times wc_tz lngfile wc_lng wc_lngm wc_lngd wc_dlng

IF mydisplay = 1 THEN DO
    CALL Dates
END
CALL Times

RETURN

Dates:

PARSE VALUE DATE('S') WITH dy +4 dm +2 dd
date_ord = DATE('D')
date_bas = DATE('B')
dm = dm/1
dd = dd/1
mymin = TIME('M')
SELECT
    WHEN dy//400 = 0 THEN mm_days = '31 29 31 30 31 30 31 31 30 31 30 31'
    WHEN dy//100 = 0 THEN mm_days = '31 28 31 30 31 30 31 31 30 31 30 31'
    WHEN dy//4 = 0 THEN mm_days = '31 29 31 30 31 30 31 31 30 31 30 31'
    OTHERWISE mm_days = '31 28 31 30 31 30 31 31 30 31 30 31'
END
DO c = 1 TO mycitynum
    citymin = mymin+mymins.c
    SELECT
        WHEN citymin > 1440 THEN DO
            dord = date_ord+1
            dbas = date_bas+1
            SELECT
                WHEN dm = 12 & dd = 31 THEN sortdate = dy+1||'0101'
                WHEN dd = WORD(mm_days,dm) THEN sortdate = dy||RIGHT((dm+1),2,'0')||'01'
                OTHERWISE sortdate = dy||RIGHT(dm,2,0)||RIGHT((dd+1),2,'0')
            END
        END
        WHEN citymin < 0 THEN DO
            dord = date_ord-1
            dbas = date_bas-1
            SELECT
                WHEN dm = 1 & dd = 1 THEN sordtade = dy-1||'1231'
                WHEN dd = 1 THEN sordate = dy||RIGHT((dm-1),2,'0')||RIGHT(WORD(mm_days,mm-1),2,'0')
                OTHERWISE sortdate = dy||RIGHT(dm,2,0)||RIGHT((dd-1),2,'0')
            END
        END
        OTHERWISE DO
            dord = date_ord
            dbas = date_bas
            sortdate = dy||RIGHT(dm,2,0)||RIGHT(dd,2,'0')
        END
    END
    PARSE VALUE sortdate WITH dyy +4 dmm +2 ddd
    mord = dmm/1
    IF mydatecc = 0 THEN DO
        dyy = RIGHT(dyy,2)
    END
    mdow = dbas//7+1
    SELECT
        WHEN mydatedisp = 1 THEN mydate.c = dyy||dsep||dmm||dsep||ddd
        WHEN mydatedisp = 2 THEN mydate.c = dyy||dsep||dmm
        WHEN mydatedisp = 3 THEN mydate.c = dyy
        WHEN mydatedisp = 4 THEN mydate.c = dmm||dsep||ddd
        WHEN mydatedisp = 5 THEN mydate.c = dmm
        WHEN mydatedisp = 6 THEN mydate.c = ddd
        WHEN mydatedisp = 7 THEN mydate.c = dyy||dsep||dord
        WHEN mydatedisp = 8 THEN mydate.c = dord
        WHEN mydatedisp = 13 THEN mydate.c = mdow
        WHEN mydatedisp = 14 THEN mydate.c = ddd||dsep||dmm||dsep||dyy
        WHEN mydatedisp = 15 THEN mydate.c = ddd||dsep||mymonn.mord||dsep||dyy
        WHEN mydatedisp = 16 THEN mydate.c = dmm||dsep||ddd||dsep||dyy
        WHEN mydatedisp = 17 THEN mydate.c = mymonn.mord||dsep||ddd||dsep||dyy
        OTHERWISE mydate.c = dyy||dsep||dmm||dsep||ddd
    END
    IF mydatedow = 1 THEN DO
        mydate.c = mydayn.mdow||', '||mydate.c
    END
END

RETURN

Times:

PARSE VALUE TIME() WITH hh ':' mm ':' ss
mymin = hh*60+mm
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
    SELECT
        WHEN mytimedisp = 1 THEN mytime.c = RIGHT(cityhh,2,'0')||tsep||RIGHT(citymm,2,'0')||tsep||RIGHT(ss,2,'0')
        WHEN mytimedisp = 2 THEN mytime.c = RIGHT(cityhh,2,'0')||tsep||RIGHT(citymm,2,'0')
        WHEN mytimedisp = 3 THEN mytime.c = RIGHT(cityhh,2,'0')
        WHEN mytimedisp = 4 THEN mytime.c = RIGHT(cityhh,2,'0')||tsep||RIGHT(citymm,2,'0')||','||SUBSTR(FORMAT(ss/60,,2),3,1)
        WHEN mytimedisp = 5 THEN mytime.c = RIGHT(cityhh,2,'0')||','||SUBSTR(FORMAT(citymm/60,,2),3,1)
        WHEN mytimedisp = 6 THEN mytime.c = RIGHT(citymm,2,'0')||tsep||RIGHT(ss,2,'0')
        WHEN mytimedisp = 7 THEN mytime.c = RIGHT(citymm,2,'0')
        WHEN mytimedisp = 8 THEN mytime.c = RIGHT(ss,2,'0')
        WHEN mytimedisp = 9 THEN mytime.c = RIGHT(citymm,2,'0')||','||SUBSTR(FORMAT(ss/60,,2),3,1)
        OTHERWISE  mytime.c = RIGHT(cityhh,2,'0')||tsep||RIGHT(citymm,2,'0')||tsep||RIGHT(ss,2,'0')
    END
    IF mytimeampm = 1 THEN DO
        mytime.c = mytime.c||ampm
    END
    IF mytimeutc = 1 THEN DO
        mytime.c = mytime.c||' '||myzone.c
    END
END

myText = ''
DO c = 1 TO mycitynum
    SELECT
        WHEN mydisplay = 2 THEN myText = myText||mytime.c||'   '||mycity.c||'<br>'
        OTHERWISE myText = myText||mytime.c||'   '||mydate.c||'   '||mycity.c||'<br>'
    END
END
CALL wcmainGadget.text SUBSTR(myText,1,LENGTH(mytext)-4)

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

