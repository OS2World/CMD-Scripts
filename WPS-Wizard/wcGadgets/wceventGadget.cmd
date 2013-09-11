/* World Clock event gadget */

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
        exefile =  SUBSTR(theScript,1,LASTPOS('\',theScript)-1)||"\Wclock.exe"

        /* Info for storing data in WPS-wizard ini file */
        APPKEY="wceventgadget"
        APPPOS="wceventpos"
        APPFONT="wceventfont"
        APPCOLOR="wceventcolor"
        APPSTYLE="wceventstyle"
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
        /* Get saved style if any */
        mystyle=Sysini(INIFile, APPKEY, APPSTYLE)
        IF WORDS(mystyle) <> 2 THEN DO
            mystyle = '0 0'
        END
        PARSE VALUE mystyle WITH myActive myTitle .

        /* Create gadget on the desktop */
        rc=WizCreateGadget("DESKTOP", "thestem." , "wceventGadget")

        /* Get saved color if any */
        ret=Sysini(INIFile, APPKEY, APPCOLOR)
        IF  ret <> "ERROR:" THEN DO
            call wceventGadget.Color ret
        END

        /* Read values from WCLOCK.INI */
        CALL RefreshMe
        CALL Events

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


wceventgadget.onCommand:
/*
    ARG(1): hwnd of client area
    ARG(2): ID
    ARG(3): source (menu or button)
*/
SELECT
    WHEN ARG(2)=1 THEN DO
        myActive = 1-myActive
    END
    WHEN ARG(2)=2 THEN DO
        myTitle = 1-myTitle
        CALL ShowMe
    END
    WHEN ARG(2)=3 THEN DO
        CALL RefreshMe
        CALL Events
    END
    WHEN ARG(2)=4 THEN DO
        helptext =  'This Gadget displays list of upcoming events in World Clock: Time -Remaining Location: Message [Object]'||'0d0a0d0a'x||,
					'Options:'||'0d'x||,
					'Active - on event time, message will be displayed and object will be opened. Warning: do not select this option if World Clock is running!'||'0d'x||,
					'Title - display number of upcoming events in next 24 hours.'||'0d'x||,
					'Refresh - reload list of upcoming events in WCLOCK.INI.'
        IF RxMessageBox(helptext,'World Clock Event Gadget') = 1 THEN DO
            DROP helptext
        END
    END
    WHEN ARG(2)=6 THEN DO
        call SysIni iniFile, APPKEY, APPPOS,  wceventGadget.position()
        call SysIni iniFile, APPKEY, APPFONT, wceventGadget.font()
        call SysIni iniFile, APPKEY, APPCOLOR, wceventGadget.Color()
        call SysIni iniFile, APPKEY, APPSTYLE, myActive||' '||myTitle
        rc=wizDestroyGadget("wceventgadget")
        exit(0)
    END
    OTHERWISE NOP
END

return


wceventgadget.onPopUp:
/*
    ARG(1): hwnd of client area
    ARG(2): x
    ARG(3): y
*/
    menu.0=6
    menu.1="Active"
    menu.2="Title"
    menu.3="Refresh"
    menu.4="Help"
    menu.5="-"
    menu.6="Close Gadget"

    menu._x=ARG(2)
    menu._y=ARG(3)

    ret=WPSWizCallWinFunc("menuPopupMenu", ARG(1), 'menu.')
    IF myActive = 1 THEN DO
        ret=WPSWizCallWinFunc("menuCheckItem", ret, 1, 0, 1)
    END
    IF myTitle = 1 THEN DO
        ret=WPSWizCallWinFunc("menuCheckItem", ret, 2, 0, 1)
    END

return

onTimer:

timersec = TIME('S')
IF timersec//60 = 0 THEN DO
    IF STREAM(inifile,'C','QUERY DATETIME') <> initime THEN DO
        CALL RefreshMe
    END
    CALL Events
END

RETURN

RefreshMe:

initime = STREAM(inifile,'C','QUERY DATETIME')
sndfile = SUBSTR(inifile,1,LASTPOS('\',inifile))||'alarm.wav'               /* Sound file              */
SELECT
    WHEN STREAM(sndfile,'C','QUERY EXISTS') = '' THEN snd_is = 0
    OTHERWISE snd_is = 1
END
wc_lng = SysIni(inifile, 'Settings', 'CurrLang')                            /* Selected language        */
lngfile = SUBSTR(inifile,1,LASTPOS('\',inifile))||wc_lng||'.INI'            /* Language file            */
IF STREAM(lngfile,'C','QUERY EXISTS') = '' THEN DO
    lngfile = SUBSTR(inifile,1,LASTPOS('\',inifile))||'ENGLISH.INI'         /* Default language file    */
END
lng_title = SysIni(lngfile,'Hint','501')                                    /* Title                    */
lng_sun1 = SysIni(lngfile,'Button','021')                                   /* Sunrise                  */
lng_sun2 = SysIni(lngfile,'Button','022')                                   /* Sunset                   */
lng_cal = SysIni(lngfile,'Button','2016')                                   /* Calendar                 */
wc_style = SysIni(inifile, 'Settings', 'Clock')                             /* World Clock style        */
wc_stylt = SysIni(inifile, 'Settings', 'Time')                              /* Time display             */
wc_times = SysIni(inifile, 'Gadget', 'Times')                               /* City times               */
wc_cities = SysIni(inifile, 'Gadget', 'Cities')                             /* City names               */
wc_city1 = SysIni(inifile, 'Gadget', 'City1')                               /* City 1                   */

SELECT
    WHEN WORDS(wc_style) <> 11 THEN CALL INIerror "Clock settings"
    WHEN WORDS(wc_stylt) <> 5 THEN CALL INIerror "Time settings"
    WHEN WORDS(wc_times) < WORD(wc_style,4) THEN CALL INIerror "City times"
    WHEN WORDS(wc_cities) <> WORDS(wc_times) THEN CALL INIerror "City names"
    WHEN WORDS(wc_city1) < 4 THEN CALL INIerror "City 1"
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
PARSE VALUE wc_city1 WITH city1lon city1lat city1sun1 city1sun2
DROP wc_style wc_stylt wc_cities wc_times wc_city1 wc_lng lngfile

RETURN

Events:

mymin = TIME('M')
mysort = DATE('S')
CALL SysIni inifile, 'Event', 'ALL:', 'events.'
en = 0
event.0 = 0
IF events.0 > 0 THEN DO
    DO e = 1 TO events.0
        PARSE VALUE events.e WITH edate etime
        SELECT
            WHEN edate > 30 THEN DO                             /* Calendar */
                SELECT
                    WHEN mysort-edate > 1 THEN NOP
                    WHEN edate<=mysort & Hhmm2min(etime)<mymin THEN NOP
                    WHEN edate>mysort & Hhmm2min(etime)>=mymin THEN NOP
                    OTHERWISE DO
                        en = en+1
                        event.en = Eventtime(Hhmm2min(etime))||'01'x||lng_cal||'01'x||SysIni(inifile,'Event',events.e)
                    END
                END
            END
            OTHERWISE DO                                        /* Cities */
                en = en+1
                event.en =Eventtime(Hhmm2min(etime)-mymins.edate)||'01'x||mycity.edate||'01'x||SysIni(inifile,'Event',events.e)
            END
        END
    END
END
ev_sun1 = SysIni(inifile,'Events','5')                          /* Sunrise */
IF ev_sun1 <> 'ERROR:' THEN DO
    en = en+1
    event.en = Eventtime(city1sun1-mymins.1)||'01'x||lng_sun1||' - '||mycity.1||'01'x||'0'||'01'x||ev_sun1
END
ev_sun2 = SysIni(inifile,'Events','6')                          /* Sunset */
IF ev_sun2 <> 'ERROR:' THEN DO
    en = en+1
    event.en = Eventtime(city1sun2-mymins.1)||'01'x||lng_sun2||' - '||mycity.1||'01'x||'0'||'01'x||ev_sun2
END
event.0 = en
e2l = 0
event2list.0 = 0
e2r = 0
event2run.0 = 0
IF event.0 > 0 THEN DO
    CALL SysStemSort 'event.'
    DO e = 1 TO event.0
        SELECT
            WHEN LEFT(event.e,4)/1 = 0 THEN DO                  /* run event */
                e2r = e2r+1
                event2run.e2r = event.e
            END
            OTHERWISE DO                                        /* show event */
                e2l = e2l+1
                event2list.e2l = event.e
            END
        END
    END
    event2list.0 = e2l
    event2run.0 = e2r
END
DROP event.
SELECT
    WHEN event2list.0 = 0 THEN CALL wceventGadget.text '<h1>0 '||lng_title||'</h1>'
    OTHERWISE CALL ShowMe
END
IF myActive = 1 THEN DO
    IF event2run.0 > 0 THEN DO
        CALL RunMe
    END
END

RETURN

ShowMe:

SELECT
    WHEN myTitle = 0 THEN myText = ''
    OTHERWISE myText = '<h1>'||event2list.0||' '||lng_title||'</h1><br>'
END
DO e = 1 TO event2list.0
    PARSE VALUE event2list.e WITH e_rest '01'x e_time '01'x e_city '01'x e_del '01'x e_msg '01'x e_prg '01'x e_snd .
    IF e_prg <> '' THEN DO
        e_prg = '['||e_prg||']'
    END
    myText = myText||Hhmm12(Min2hhmm(e_time))||' -'||Min2hhmm(e_rest)||'  '||e_city||':  '||e_msg||'  '||e_prg||'<br>'
END
CALL wceventGadget.text SUBSTR(myText,1,LENGTH(myText)-4)

DROP e_rest e_time e_city e_del e_msg e_prg

RETURN

RunMe:

DO e = 1 TO event2run.0
    PARSE VALUE event2run.e WITH r_rest '01'x r_time '01'x r_city '01'x r_del '01'x r_msg '01'x r_prg '01'x r_snd .
    IF r_snd = 1 THEN DO
        SELECT
            WHEN snd_is = 1 THEN dummy = SysOpenObject(sndfile,'DEFAULT','1')
            OTHERWISE DO
                DO i = 1 TO 8
                    alsnd = BEEP(WORD('262 294 330 349 392 440 494 524',i),125)
                END
            END
        END
    END
    IF STRIP(r_prg) <> '' THEN DO
        dummy = SysOpenObject(r_prg,'DEFAULT','1')
    END
    IF STRIP(r_msg) <> '' THEN DO
        IF RxMessageBox(r_msg,r_city,,'INFORMATION') = 1 THEN DO
        END
    END
END
DROP event2run. r_rest r_time r_city r_del r_msg r_prg
event2run.0 = 0

RETURN

Hhmm2min:

PARSE ARG myhhmm
PARSE VALUE myhhmm WITH myhh ':' mymm
RETURN myhh*60+mymm

Hhmm12:

PARSE ARG myhhmm
SELECT
    WHEN mytimeampm = 0 THEN RETURN myhhmm
    OTHERWISE DO
        PARSE VALUE myhhmm WITH myhh ':' mymm
        SELECT
            WHEN myhh = 0 THEN DO
                myhh = 12
                ampm = 'am'
            END
            WHEN myhh < 12 THEN ampm = 'am'
            WHEN myhh = 12 THEN ampm = 'pm'
            OTHERWISE DO
                myhh = myhh-12
                ampm = 'pm'
            END
        END
        RETURN RIGHT(myhh,2,'0')||':'||RIGHT(mymm,2,'0')||ampm
    END
END

RETURN

Min2hhmm:

PARSE ARG myevmin
RETURN RIGHT(myevmin%60,2,'0')||':'||RIGHT(myevmin//60,2,'0')

Eventtime:

PARSE ARG eventmins
SELECT
    WHEN eventmins < 0 THEN eventmins = eventmins+1440
    WHEN eventmins > 1339 THEN eventmins = eventmins//1440
    OTHERWISE NOP
END
SELECT
    WHEN eventmins > mymin THEN eventrest = eventmins-mymin
    WHEN eventmins < mymin THEN eventrest = 1440+eventmins-mymin
    OTHERWISE eventrest = 0
END
RETURN RIGHT(eventrest,4,'0')||'01'x||RIGHT(eventmins,4,'0')

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

