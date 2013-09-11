/* Installation of World Clock gadgets */

IF RxFuncQuery('SysLoadFuncs') THEN DO
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    CALL SysLoadFuncs
END
CALL SysCls

/* Check if WPSwiz is installed */
is_wpswiz = 0
wpswizhnt = ''
CALL SysQueryClassList "clist."
DO i = 1 TO clist.0
    PARSE VALUE clist.i WITH clist1 clist2
    IF TRANSLATE(clist1) = 'CWOBJECT' THEN DO
        is_wpswiz = 1
        CALL SysFileTree SUBSTR(clist2,1,LASTPOS('\',clist2))||'OBJHINTS.INI', 'wpswizfile.', 'FSO'
        IF wpswizfile.0 > 0 THEN DO
            wpswizhnt = wpswizfile.1
        END
        LEAVE i
    END
END
IF is_wpswiz = 0 THEN DO
    dummy = BEEP(450,250)
    SAY "Error: WPS-Wizard is not installed! Press any key to exit"
    ans = SysGetKey('NOECHO')
    EXIT
END

/* Check for source file WCLOCK.INI - must be in same directory as gadgets */
PARSE SOURCE . . theScript
inifile =  SUBSTR(theScript,1,LASTPOS('\',theScript)-1)||"\WCLOCK.INI"
IF STREAM(inifile,'C','QUERY EXISTS') = '' THEN DO
    dummy = BEEP(450,250)
    SAY "Error: WCLOCK.INI does not exist in current directory! Press any key to exit"
    ans = SysGetKey('NOECHO')
    EXIT
END

SAY 'World Clock Gadgets Installation:'
SAY '- creates Folder and Program objects for Gadgets'
SAY '- creates shadow of Gadgets Folder in WPS-Wizard Gadgets'
SAY 'Continue (y/n)?'
ans = SysGetKey('NOECHO')
IF TRANSLATE(ans) <> 'Y' THEN DO
    EXIT
END

dummy = SysDestroyObject('<WCLOCK_GADGETFOLDER>')
InstallDir = Directory()

FoldTitle='World Clock Gadgets'
Icon1=InstallDir||'\Folder1.ico'
Icon2=InstallDir||'\Folder2.ico'
Icon='ICONFILE='Icon1||';ICONNFILE=1,'||Icon2
Setup='OBJECTID=<WCLOCK_GADGETFOLDER>;'||Icon||''
Action = 'U'
SAY ' '
SAY 'Installing '||FoldTitle
SAY ' '
dummy = SysCreateObject('WPFolder',FoldTitle,'<WCLOCK140_FOLDER>',Setup,'U')
IF wpswizhnt <> '' THEN DO
    CALL SysIni wpswizhnt, '<WCLOCK_GADGETFOLDER>', 'hint', FoldTitle||' for WPS-Wizard'
END
SAY FoldTitle||' Folder'

title.1 = "World Clock Gadget"
setup.1 = 'OBJECTID=<WCLOCK_GADGETMAIN>;EXENAME='InstallDir'\wcmainGadget.cmd;MINIMIZED=YES;MINVIEW=HIDE;CCVIEW=YES;ICONFILE='InstallDir'\WClock.ico;STARTUPDIR='InstallDir''
hint.1 = '<WCLOCK_GADGETMAIN> This Gadget displays time and date'||'0a'x||'similar to List View in World Clock'
title.2 = "World Clock Mini Gadget"
setup.2 = 'OBJECTID=<WCLOCK_GADGETMINI>;EXENAME='InstallDir'\wcminiGadget.cmd;MINIMIZED=YES;MINVIEW=HIDE;CCVIEW=YES;ICONFILE='InstallDir'\WClock.ico;STARTUPDIR='InstallDir''
hint.2 = '<WCLOCK_GADGETMINI> This Gadget displays time and date'||'0a'x||'similar to Minimized View in World Clock'
title.3 = "World Clock Banner Gadget"
setup.3 = 'OBJECTID=<WCLOCK_GADGETBANNER>;EXENAME='InstallDir'\wcbannerGadget.cmd;MINIMIZED=YES;MINVIEW=HIDE;CCVIEW=YES;ICONFILE='InstallDir'\WClock.ico;STARTUPDIR='InstallDir''
hint.3 = '<WCLOCK_GADGETBANNER> This Gadget displays time'||'0a'x||'similar to Banner View in World Clock'
title.4 = "World Clock Events Gadget"
setup.4 = 'OBJECTID=<WCLOCK_GADGETEVENT>;EXENAME='InstallDir'\wceventGadget.cmd;MINIMIZED=YES;MINVIEW=HIDE;CCVIEW=YES;ICONFILE='InstallDir'\WClock.ico;STARTUPDIR='InstallDir''
hint.4 = '<WCLOCK_GADGETEVENT> This Gadget displays'||'0a'x||'list of upcoming events in World Clock'
title.0 = 4
DO i = 1 TO title.0
    dummy = SysCreateObject('WPProgram',title.i,'<WCLOCK_GADGETFOLDER>',setup.i,'U')
    IF wpswizhnt <> '' THEN DO
        PARSE VALUE hint.i WITH hntapp hntval
        CALL SysIni wpswizhnt, STRIP(hntapp), 'hint', STRIP(hntval)
    END
    SAY title.i
END
dummy = SysCreateShadow('<WCLOCK_GADGETFOLDER>','<WPSWIZ_GADGETFOLDER>')

SAY ' '
SAY 'Installation finished. Press any key to exit ...'
ans = SysGetKey('NOECHO')
Exit
