/******************  Animation Page Creator v1.3 ***************/

'@ECHO OFF'
say ' *****************  Animation Page Creator v1.3 ***************'
say ' ************ by Sallie Krebs (skrebs@inwave.com) ********'

/***************** User Variables ************************/
/* IMPORTANT!!!!! If you are running an older version of WebExplorer */
/* which does not support Tables, then set the AnimTables variable to 0 */
AnimTables=1
AnimPath=''
/*  AnimPath is the base directory for your animation files. Each
    separate animation must be located in its own subdirectory
    beneath the base directory. Also, there should be NO directories
    other than animations beneath the base directory. If this variable
    is blank, then the current directory will be used for the AnimPath
    variable. (This assumes that animpage.cmd is run from the base
    directory.)
    Example:    Animpath='c:\inet\animate'                   */
AnimBackground='bkgdos2.gif'    /* Background graphic */
AnimHeader='header.gif'         /* Header graphic for top of page */
AnimArc='animarc.gif'           /* 'Animation Archive' header graphic- near */
                                /* the bottom of the page. */
                                /* Under the Animation Archive graphic will */
                                /* be a list of up to 5 sites you can link */
                                /* to. Enter the link and title info below. */
                                /* Leave blank (ie: '') otherwise. */
AnimArcHRef1='http://www.os2forum.or.at/TeamOS2/English/Special/Animations/'
AnimArcTitle1='OS/2 Information Center - Animations'
AnimArcHRef2='http://www.kuwait.net/~morpheus/web-anim.html'
AnimArcTitle2='WebExplorer Animations Archive'
AnimArcHRef3='http://eev11.e-technik.uni-erlangen.de/animationen.html'
AnimArcTitle3='Animation HomePage'
AnimArcHRef4=''
AnimArcTitle4=''
AnimArcHRef5=''
AnimArcTitle5=''
AnimRdButton='rd_pin.gif'       /* Graphic for the AnimArcHRef lines */
AnimDivider='divider.gif'       /* Divider graphic. For link to top of page */
AnimLogo='merlin.gif'           /* Building for Merlin logo graphic for bottom of page */
AnimLogoHRef='http://www.in.net/~mcdonajp/bfos2m.htm'
AnimRibbon='blueribn.gif'       /* Blue Ribbon Logo graphic for bottom of page */
AnimRibbonHRef='http://www.eff.org/blueribbon.html'
                                /* Blue Ribbon Logo HREF for Blue Ribbon logo */
AnimOnward='everonwd.gif'       /* Ever Onward Logo graphic for bottom of page */
AnimOnwardHRef='http://www.aescon.com/innoval/everos2/'
/* the above graphics files should be located in the AnimPath directory.
   You can substitute your own graphics for the above by copying your
   files to the 'AnimPath' directory. You can then either delete the files
   included with AnimPage.cmd and rename your files as above, or edit the
   above variables to correspond to the filenames of your graphics. */
/************** End of User Variables ********************/

signal on error name DIE
signal on failure name DIE
signal on halt name DIE
signal on syntax name DIE

/****** required REXXUTIL initialization ******/
rc = RxFuncAdd(SysLoadFuncs, REXXUTIL, SysLoadFuncs)
if rc \= 0 then do
    say 'Could not load RexxUtil functions. Exiting.'
    exit
end
call SysLoadFuncs

say '********************* NOTE ******************************'
say '*** You must edit the user variables at the start of  ***'
say '*** this file before running this program.            ***'
say ''

address CMD

/*  I wanted to use the following statement, but for some reason it no
    longer works?!?!?! Yet another Fixpack 17 bug, er... feature?!?!? */
/* if RxMessageBox('Run AnimPage Now?',, 'YESNO', 'QUERY') = 7 */

/* I'll have to settle for: */
'pause Press Ctrl-C to abort now, or any other key to continue'
say ''

fspec = AnimPath
if fspec == '' then
    fspec = directory()||'\'
if (lastpos('\', fspec) \= length(fspec)) then
    fspec = fspec||'\'
AnimPath = fspec

/* Make AnimPage.BAK file */
found. = 0
AnimFspec = fspec||AnimPage.htm
rc = SysFileTree(AnimFspec, 'found', 'F')
if found.0 \= 0 then do
    ofspec = left(AnimFspec, length(AnimFspec) - 3) || 'BAK'
    say 'Copying AnimPage.htm to AnimPage.bak'
    'copy 'AnimFspec' 'ofspec
    say ''
    say 'Deleting old AnimPage.htm'
    'del 'AnimFspec
    say ''
end

/* find subdirectories */
AnimDirs. = 0
rc = SysFileTree(fspec, 'AnimDirs', 'SDO')
if (rc \= 0)|(AnimDirs.0 == 0) then do
    say 'Error reading animation subdirectories. Exiting.'
    call SysDropFuncs
    exit
end

do x = 1 to AnimDirs.0     /* check each subdirectory: */
    AnimFiles. = 0
    fspec = AnimDirs.x||'\*.gif'
    rc = SysFileTree(fspec, 'AnimFiles', 'FO')
    if AnimFiles.0 == 0 then do
        fspec = AnimDirs.x||'\*.jpg'
        rc = SysFileTree(fspec, 'AnimFiles', 'FO')
        if AnimFiles.0 == 0 then do
            fspec = AnimDirs.x||'\*.bmp'
            rc = SysFileTree(fspec, 'AnimFiles', 'FO')
            if AnimFiles.0 == 0 then do
                say 'Could not locate any animations. Exiting.'
                call SysDropFuncs
                exit
            end
        end
    end
end

/* do html header */
call stream AnimFspec, 'c', 'open write'

top = '<IMG src="file:///'||AnimPath||AnimHeader'" alt="[AnimPage]">'

call lineout AnimFspec, '<HTML>'
call lineout AnimFspec, ''
call lineout AnimFspec, '<HEAD>'
call lineout AnimFspec, '<TITLE>WebExplorer Animations</TITLE>'
call lineout AnimFspec, '<body background="file:///'||AnimPath||AnimBackground'">'
call lineout AnimFspec, '</HEAD>'
call lineout AnimFspec, ''

call lineout AnimFspec, '<CENTER>'
call lineout AnimFspec, '<A NAME="top"><B>WebExplorer Animations</B></A>'
call lineout AnimFspec, '</CENTER><P>'
call lineout AnimFspec, '<CENTER>'
call lineout AnimFspec, top
call lineout AnimFspec, '</CENTER><P>'
call lineout AnimFspec, ''
call lineout AnimFspec, '<BODY>'
call lineout AnimFspec, ''
if (AnimTables) then do
    call lineout AnimFspec, '<CENTER>'
    call lineout AnimFspec, '<TABLE BORDER=3>'
    call lineout AnimFspec, '<TR>'
    call lineout AnimFspec, '<TH ALIGN="center" VALIGN="middle" NOWRAP>Picture</TH><TH ALIGN="center" VALIGN="middle" NOWRAP>Title</TH><TH ALIGN="center" VALIGN="middle" NOWRAP>Author</TH><TH ALIGN="center" VALIGN="middle" NOWRAP>Size</TH>'
    call lineout AnimFspec, '</TR>'
end
else
    call lineout AnimFspec, '<ul>'

/* get animation subdirectories info: */
ADir. = 0
do x = 1 to AnimDirs.0
    ai = 0
    ad = x
    ADir.0 = x              /* number of animation subdirectories */
    ADir.ad.ai = 0          /* init number of anim files in subdir */
    AnimFiles. = 0
    fspec = AnimDirs.x||'\*.gif'
    afext = '.gif'                  /* anim file extension */
    rc = SysFileTree(fspec, 'AnimFiles', 'FO')
    if AnimFiles.0 == 0 then do
        fspec = AnimDirs.x||'\*.jpg'
        afext = '.jpg'          /* anim file extension */
        rc = SysFileTree(fspec, 'AnimFiles', 'FO')
        if AnimFiles.0 == 0 then do
            fspec = AnimDirs.x||'\*.bmp'
            afext = '.bmp'  /* anim file extension */
            rc = SysFileTree(fspec, 'AnimFiles', 'FO')
        end
    end

    ADir.ad.ai = AnimFiles.0
    do f = 1 to AnimFiles.0
        Adir.ad.f = AnimFiles.f
    end

    ADir.ad.icon = AnimFiles.1  /* icon for main page is first anim file */
    attl = AnimFiles.1          /* get just the subdirectory name ... */
    apath = filespec('P', attl) /* to use for other variables */
    attl = substr(apath, 1, (length(apath) - 1))
    epos = lastpos('\', attl) + 1
    attl = substr(attl, epos)
    ADir.ad.title = attl
    fname = attl||'.htm'        /* append .htm for loader filename */
    ADir.ad.ahtm = fname        /* name for individual anim loader files */
    ADir.ad.aname = attl        /* subdir name only for NAME tag and ...*/
    alitxt = attl               /* default text for animation list items */
    attl = '<TITLE>'||attl||'</TITLE>'  /* default title for loader file */

    /* locate/process original animation loader file(s) */
    fspec = AnimDirs.x||'\*.htm'
    ADir.ad.ahref = 1
    ADir.ad.ahref.1 = 'Source unknown'/* default source for loader file */
    ADir.ad.ahref.1.hrtxt = 'Source unknown'/* default source for loader file */
    rc = SysFileTree(fspec, 'found', 'FSO') /* find original loader- if any */
    if found.0 == 0 then do
        fspec = AnimDirs.x||'\*.html'
        rc = SysFileTree(fspec, 'found', 'FSO')
    end
    if found.0 \= 0 then do
        fspec = found.1
        rc = SysFileSearch('<TITLE>', fspec, 'found.')  /* look for title */
        if ((rc == 0)&(found.0 \= 0)) then do
            attlsave = attl /* <TITLE>...</TITLE> */
            attl = found.1
            alitxt = attl
            epos = lastpos('<', alitxt) - 1
            if epos > 0 then do
                alitxt = substr(alitxt, 1, epos)
                alitxt = strip(alitxt)
                epos = lastpos('>', alitxt) + 1
                alitxt = strip(substr(alitxt, epos))
                if (pos('WEBEXPLORER ANIMATION', translate(alitxt)) \= 0) then do
                    alitxt = strip(substr(alitxt, 22))
                    epos = pos('-', alitxt) + 1
                    if epos \= 0 then
                        alitxt = strip(substr(alitxt, epos))
                end
            end
            else do
                attl = attlsave
                alitxt = attlsave
            end
        end
        rc = SysFileSearch('<A HREF', fspec, 'found.') /* look for href */
        if ((rc == 0)&(found.0 \= 0)) then do
            ADir.ad.ahref = found.0
            do r = 1 to found.0     /* save each found href line */
                ADir.ad.ahref.r = found.r
            end

            ahtmp = ADir.ad.ahref.1     /* just look at first href found */
            epos = lastpos('</A>', translate(ahtmp)) - 1 /* strip the </A> */
            if epos >= 1 then                            /* if it's there */
                ahtmp = strip(substr(ahtmp, 1, epos))
            epos = pos('<A HREF', translate(ahtmp))  /* get the href position */
            if epos >= 1 then
                ahtmp = strip(substr(ahtmp, epos))   /* get href to EOL */
            epos = pos('</H', translate(ahtmp)) - 1 /* strip end header tag, if present */
            if epos >= 1 then do
                ahtmp = strip(substr(ahtmp, 1, epos))
            end
            ADir.ad.ahref.1.hrtxt = ahtmp
        end
    end
    ADir.ad.atitle = attl
    animhref = Adir.ad.ahtm
    epos = lastpos('\', animhref) + 1
    animhref = substr(animhref, epos)
    if (AnimTables) then do
        call lineout AnimFspec, '<TR>'
        call lineout AnimFspec, '<TD ALIGN="center" VALIGN="middle"><A HREF="'||animhref||'" NAME="'ADir.ad.aname'"><IMG src="file:///'||ADir.ad.icon||'" ALIGN="middle" alt="[Load Animation]"></A></td>'
        call lineout AnimFspec, '<TD ALIGN="center" VALIGN="middle">'||alitxt||'</td>'
        call lineout AnimFspec, '<TD ALIGN="center" VALIGN="middle">'||ADir.ad.ahref.1.hrtxt||'</td>'
        call lineout AnimFspec, '<TD ALIGN="center" VALIGN="middle">'||ADir.ad.ai||' frames</td>'
        call lineout AnimFspec, '</TR>'
    end
    else do
        aListItem = '<A HREF="'animhref'" NAME="'ADir.ad.aname'"><IMG src="file:///'ADir.ad.icon'" ALIGN="middle" alt="['ADir.ad.aname']">'alitxt'</A>     Frames: 'ADir.ad.ai
        call lineout AnimFspec, aListItem||'<BR>'   /* done- output the anim line */
    end
end

/* done with all animation lines- do main page footer */
bar = '<A HREF="#top"><IMG src="'||AnimDivider||'" ALIGN="middle" alt="[To Top of Page]"></A><BR>'
hdr = '<IMG src="file:///'||AnimPath||AnimArc'" ALIGN="middle" alt="[Animation Archive Sites]"><BR>'
if AnimArcTitle1 \= '' then
    asite1 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef1||'">'AnimArcTitle1'</A><BR>'
else
    asite1 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef1||'">Animation link #1</A><BR>'
if AnimArcTitle2 \= '' then
    asite2 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef2||'">'AnimArcTitle2'</A><BR>'
else
    asite2 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef2||'">Animation link #2</A><BR>'
if AnimArcTitle3 \= '' then
    asite3 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef3||'">'AnimArcTitle3'</A><BR>'
else
    asite3 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef3||'">Animation link #3</A><BR>'
if AnimArcTitle4 \= '' then
    asite4 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef4||'">'AnimArcTitle4'</A><BR>'
else
    asite4 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef4||'">Animation link #4</A><BR>'
if AnimArcTitle5 \= '' then
    asite5 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef5||'">'AnimArcTitle5'</A><BR>'
else
    asite5 = '<IMG src="file:///'||AnimPath||AnimRdButton'" ALIGN="middle" alt="[ ]"><A HREF="'||AnimArcHRef5||'">Animation link #5</A><BR>'

    if (AnimTables) then do
        call lineout AnimFspec, '</TABLE>'
        call lineout AnimFspec, '</CENTER>'
    end
    else
        call lineout AnimFspec, '</UL>'
call lineout AnimFspec, ''
call lineout AnimFspec, '<CENTER>'
call lineout AnimFspec, bar
call lineout AnimFspec, '</CENTER><P>'
call lineout AnimFspec, ''
call lineout AnimFspec, '<CENTER>'
call lineout AnimFspec, hdr
call lineout AnimFspec, '</CENTER><P>'
if AnimArcHRef1 \= '' then
    call lineout AnimFspec, asite1
if AnimArcHRef2 \= '' then
    call lineout AnimFspec, asite2
if AnimArcHRef3 \= '' then
    call lineout AnimFspec, asite3
if AnimArcHRef4 \= '' then
    call lineout AnimFspec, asite4
if AnimArcHRef5 \= '' then
    call lineout AnimFspec, asite5
call lineout AnimFspec, ''
call lineout AnimFspec, '<HR>'

/* only do Building for Merlin logo if user has it defined */
if ((AnimLogo \= '')&(AnimLogoHRef \= '')) then
    do
        call lineout AnimFspec, ''
        line = '<A HREF="'||AnimLogoHRef||'"><IMG src="file:///'||AnimPath||AnimLogo'" ALIGN="middle" alt="[Building for Merlin]">Building for Merlin</A><BR>'
        call lineout AnimFspec, line
        call lineout AnimFspec, ''
    end

/* only do Ever Onward logo if user has it defined */
if ((AnimOnward \= '')&(AnimOnwardHRef \= '')) then
    do
        call lineout AnimFspec, ''
        line = '<A HREF="'||AnimOnwardHRef||'"><IMG src="file:///'||AnimPath||AnimOnward'" ALIGN="middle" alt="[Ever OS/2]">Ever Onward OS/2 Campaign</A><BR>'
        call lineout AnimFspec, line
        call lineout AnimFspec, ''
    end

/* only do blue ribbon logo if user has it defined */
if ((AnimRibbon \= '')&(AnimRibbonHRef \= '')) then
    do
        call lineout AnimFspec, ''
        line = '<A HREF="'||AnimRibbonHRef||'"><IMG src="file:///'||AnimPath||AnimRibbon'" ALIGN="middle" alt="[Stop Censorship]"><STRONG>Stop censorship on the Internet!</STRONG></A><BR>'
        call lineout AnimFspec, line
        call lineout AnimFspec, ''
    end

call lineout AnimFspec, '<HR>'
call lineout AnimFspec, '<ADDRESS>'
line = 'Page designed by <A HREF="mailto:skrebs@inwave.com">Sallie Krebs.</A><BR>'
call lineout AnimFspec, line
line = '<BR>'
call lineout AnimFspec, line
line = 'Many thanks to <A HREF="mailto:ingo@ibm.net">Ingo Guenther</A> for the <STRONG>beautiful</STRONG> top AnimPage graphic.<BR>'
call lineout AnimFspec, line
line = '<BR>'
call lineout AnimFspec, line
line = 'Other graphics borrowed from miscellaneous sources.<BR>'
call lineout AnimFspec, line
call lineout AnimFspec, ''
call lineout AnimFspec, '</ADDRESS>'
call lineout AnimFspec, '</BODY>'
call lineout AnimFspec, '</HTML>'

call stream AnimFspec, 'c', 'close'
/* done with the AnimPage.htm file */

/* Create individual animation loader files */
/* check each subdirectory: */
do x = 1 to ADir.0
    /* from animation htm, need this link to get back: */
    artn = '<H4><A HREF="file:///'||AnimFspec||'#'||ADir.x.aname||'">Return to AnimPage</A></H4>'
    fspec = AnimDirs.x||'.htm'
    /* if file exists, just delete it */
    rc = SysFileTree(fspec, 'found', 'F')
    if found.0 \= 0 then
        do
            say ''
            say 'Deleting old animation html file'
            'del 'fspec
            say ''
        end

    call stream fspec, 'c', 'open write'

    call lineout fspec, '<HTML>'
    call lineout fspec, '<HEAD>'
    call lineout fspec, ADir.x.atitle   /* ex: <title>Blox Animation</title> */
    call lineout fspec, '</HEAD>'
    call lineout fspec, '<BODY>'
    call lineout fspec, '<CENTER>'
    ah1 = ADir.x.atitle                 /* strip title tags */
    epos = lastpos('<', ah1) - 1
    ah1 = strip(substr(ah1, 1, epos))
    epos = lastpos('>', ah1) + 1
    ah1 = strip(substr(ah1, epos))
    ah1 = '<H1>'ah1'</H1>'
    call lineout fspec, ah1     /*ex: <h1>Blox Animation</h1> */
    call lineout fspec, '<HR>'
    call lineout fspec, '<H3>Loading Animation...Please Wait.</H3>'
    call lineout fspec, '<ANIMATE>'

    do y = 1 to adir.x.0
        afspec = 'file:///'Adir.x.y
        line = '<frame src="'||afspec||'">'
        call lineout fspec, line
    end

    call lineout fspec, '</ANIMATE>'
    call lineout fspec, '<HR>'
    call lineout fspec, '<H3>Your animation should now have changed.</H3>'
    call lineout fspec, '</CENTER>'
    call lineout fspec, '<HR>'

    do n = 1 to Adir.x.ahref    /* write source info to loader file */
        call lineout fspec, ADir.x.ahref.n
    end

    call lineout fspec, '<BR>'
    call lineout fspec, ''
    call lineout fspec, artn    /* return link to AnimPage.htm */
    call lineout fspec, ''

    call stream spec, 'c', 'close'
end
/* done creating individual animation loader files */

call SysDropFuncs
exit

DIE:
cname=condition('C')
say 'A 'cname' error occurred at line number 'sigl'.'
say 'Sourceline = 'sourceline(sigl)'.'
say 'Error 'rc': 'errortext(rc)'.'
call SysDropFuncs
call stream AnimFspec, 'c', 'close'
call stream fspec, 'c', 'close'
exit

