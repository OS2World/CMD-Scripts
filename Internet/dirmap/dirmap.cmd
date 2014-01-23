/* REXX - DIRMAP - Make a drive snapshot of files for browsing */
/* 
   (C) 1996/2001 by Oliver Heidelbach
   Send bugs, comments etc. to: ohei@snafu.de

   History:
   ## Version 1.03 ##
   07.07.01 - Fixed a severe bug left over from copied code: Files 
              attributed 'read only' had been be ignored, leading to 
              cd-roms being not mapped at all.
   05.07.01 - Deleted debugging info still shouted out to the screen.
   ## Version 1.02 ##
   08.03.01 - Added commandline option to make drive range access
              for /a option variable. You now are able to choose either 
              local drives (default), net drives only or all accessible
              drives.
            - Made internal parsing for html files for document title
              fetching more flexible: Before only .htm and .html files
              were recognized, now any file which has a file extension
              matching a substring included in the variable 'htmlext' is
              recognized as html. You may extend the 'htmlext' variable
              for your own needs. However please remember: it's only
              use is for document title fetching. It wouldn't make much
              sense to try fetching the HTML document title from a
              .jpeg file.
   ## Version 1.01 ##
   13.11.98 - Made help switch parsing more variable
   12.08.98 - Fixed a missing END statement obviously only visible
              to Object REXX. My classic REXX interpreter didn't
              complain.
            - Fixed some minor oddities (one language string
              still wasn't variable etc.)
   ## Version 1.00 ##
   11.08.98 - Fixed a bug with the short links: when only full
              qualified path(s) were given the current drive
              was added to the link list anyway
   09.08.98 - added drive short links if only one output file
            - made file name in HTML header variable
   20.05.98 - decided not to release this thingy without
              the ability to process multiple file masks from
              the command line.
   19.05.98 - implemented javascript for all links
            - made output acceptable for other eyes (somehow)
            - added ability to handle file names with spaces
              (not via the commandline, but internal if found)
   18.05.98 - fixed a bug in title fetching: only html files
              with lower case file extension were investigated
   16.05.98 - fixed an severe bug I had no mind to
              investigate over the last months
   17.08.97 - made all language output variable
   14.08.97 - added ability to have different output files
              for each drive (option /2)
            - added ability to have different output files
              for each directory (option /3)
   10.08.97 - added ability to skip certain drives
   08.08.97 - beautified HTML output
            - rediscovered this file on my disk and decided to
              enhance it
   15.03.96 - added ability to fetch title from html documents
            - began writing dirmap

 to do: 
       - Force non-Javascript syntax
       - Drive links are added to header even if no files found
*/

_initvars:
version = 1.03
loaded = 0; qset = 0; 
crlf = '0d0a'x; yes = ''
files = 0; dirs = 0; total = 0; skip = 0
args. = ''; javascr = 0
fileidx = 0; oldfidx = 0; fullspec = 0; skipdrive = 0
actdrive = 'ACTDRV'; lastdrive = 'LASTDRV'
lastdir = 'LASTDIR'; actdir = 'ACTDIR'
drvfile = 'DRVFILE'; dirfile = 'DIRFILE'
cdrom = ''; fmasks = ''
                            /* Substring(s) to match html file extensions,  */
                           /* e.g. HTM will match *.html, *.shtml and *.htm */
                                                   /* Please use upper case */
htmlext = 'HTM ASP PHP'

SIGNAL on halt name _userbreak       /* Install error handling on userbreak */
/* SIGNAL on novalue */

_starttimer:
CALL Time 'E'

_load:                            /* If not loaded, load RexxUtil functions */
IF RxFuncQuery('SysLoadFuncs') <> 0 THEN DO
   CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   loaded = 1
END
CALL SysLoadFuncs

_checkenv:                            /* Fetch country code from os2sys.ini */
lval = SysIni('User','PM_National','iCountry')
IF Chk4Netscape() = 1 THEN javascr = 1

_getcommandline:                                /* Check if user wants help */
PARSE ARG opt1
IF Pos('/?', opt1) | Pos('-?', opt1) > 0 THEN SIGNAL _usage
Call SetInput(lval)                   /* If not, set input language strings */

                                   /* Parse command line input and separate */
                                            /* into options and other input */
PARSE ARG cline
n. = ''; i = 1
DO while cline <> ''
   PARSE var cline n.i cline
   i = i + 1
END
n.0 = i - 1

opts. = ''; pars. = ''          /* Store options and other input into stems */
j = 1; k = 1
DO i = 1 to n.0               /* Know about dos-like and unix-like switches */
   IF SubStr(n.i,1,1) = '/' | SubStr(n.i,1,1) = '-' THEN DO
      opts.j = n.i; j = j + 1                                    /* Options */
   END
   ELSE IF n.i <> '' THEN DO
      pars.k = n.i; k = k + 1                                /* Other input */
   END
END
opts.0 = j - 1         /* Store # of options and other input into stems too */
pars.0 = k - 1

_checkoptions:                           /* Parse options to see what to do */
unknown. = ''; root = 0; j = 0
short = 0; all = 0; mid = 0; long = 0; 
DO i = 1 to opts.0
   IF Pos(args.1,opts.i,1) = 2 THEN short = 1       /* All in one file      */
   ELSE IF Pos(args.0,opts.i,1) = 2 THEN all = 1    /* Scan all local drvs  */
   ELSE IF Pos(args.2,opts.i,1) = 2 THEN mid = 1    /* Files per drive      */
   ELSE IF Pos(args.3,opts.i,1) = 2 THEN long = 1   /* Files per directory  */
   ELSE IF Pos(args.4,opts.i,1) = 2 THEN DO         /* Name of root file    */
       root = 1
       rfile = Substr(opts.i, 3, Length(opts.i))
   END
   ELSE IF Pos(args.5,opts.i,1) = 2 THEN DO         /* Drives not to scan   */
       skip = 1
       PARSE UPPER Value(Substr(opts.i, 3, Length(opts.i))) WITH skiplist
   END
   ELSE IF Pos(args.7,opts.i,1) = 2 THEN DO         /* drive range to scan  */
     PARSE UPPER Value(Substr(opts.i, 3, Length(opts.i))) WITH rangeopt
     IF rangeopt = 'L' THEN range = 'LOCAL'
     ELSE IF rangeopt = 'N' THEN range = 'REMOTE'
     ELSE IF rangeopt = 'A' THEN range = 'USED'
   END
   ELSE IF Pos('b',opts.i,1) = 2 THEN a = opts.i    /* xxxxxxxxxxxxxxxxxx   */
   ELSE DO 
      j = j + 1; unknown.j = opts.i
   END
END

unknown.0 = j

IF j > 0 THEN DO                         /* Tell user about unknown options */
   SAY ''; CALL SetLangue 12; 
   DO i = 1 to unknown.0
      CALL CharOut,  unknown.i||' '
   END
   CALL CharOut, crlf
   SIGNAL _usage
END
IF pars.0 = 0 THEN DO
    SAY ''
    CALL SetLangue 9
    SIGNAL _usage
END

_openfile:
IF root <> 1 THEN
    rootfile = 'dirmap.htm'
ELSE
    rootfile = rfile

CALL OpenFile(rootfile)
CALL MakeHeader rootfile 'Dir Map'
CALL SetLangue 4                                 /* Write title to rootfile */
CALL SetLangue 7                              /* Write subtitle to rootfile */

_getdrives:
startdrive = 'C:'
IF range = 'RANGE' THEN range = 'LOCAL'          /* set default drive range */
d. = ''; total = 0
IF all = 1 THEN DO                                       /* Scan all drives */
   ldrives = SysDriveMap(startdrive, range)
   i = 1; d.0 = 0
   DO while ldrives <> ''
      PARSE var ldrives d.i ldrives
      IF skip = 1 THEN           /* Reset stem if current drive in skiplist */
          IF Pos(Substr(d.i,1,1), skiplist) > 0 THEN i = i - 1
      i = i + 1
   END
   d.0 = i - 1                 /* Store # of local drives present on system */
END
ELSE DO 
   d.0 = 1
   d.1 = SubStr(Directory(),1,2)            /* Determine current disk drive */
END

SAY ''
k = d.0

_getfiles:
n = 0
files.0 = 0

DO j = 1 to pars.0                                     /* Process filemasks */
   DO i = 1 to d.0                                  /* Process local drives */
      IF d.i <> '' & Pos(d.i, cdrom, 1) = 0 THEN DO       /* but no CD-ROMS */
	 IF Pos(':',pars.j,1) = 2 THEN DO 
	    spec = pars.j                       /* Drive letter in filemask */
	    fullspec = 1
	    IF all <> 1 THEN DO                  /* Get drive for diskusage */
	       drive = Translate(Left(pars.j,2)); noadd = 0
	       DO l = 1 to k               /* Is drive already in disklist? */
		  IF drive = d.l THEN noadd = 1
	       END
	       IF noadd <> 1 THEN DO 
		  k = k + 1; d.k = drive               /* If not in, add it */
	       END
	    END
	    CALL SetLangue 1; CALL CharOut, pars.j||crlf
	 END
	 ELSE DO 
	    IF Left(pars.j,1) \= '.' THEN 
	       spec = d.i || '\' || pars.j        /* Drive not in file mask */
	    ELSE spec = pars.j                    /* relative path . or ..  */
	    CALL SetLangue 1; CALL CharOut, pars.j
	    CALL SetLangue 2; CALL CharOut, d.i
	 END
         IF SysFileTree(spec, 'searches', 'FS') <> 0 THEN DO 
	    CALL SetLangue 3; CALL CharOut, d.i||crlf
	 END
         DO idx = 1 to searches.0       /* Store found items into the queue */
            LINE = searches.idx
            PARSE value LINE WITH x1 x2 x3 x4 x5

                          /* Make a dummy file name entry in upper case     */
                          /* and without spaces to sort array by file name  */
                          /* Further split into path (x_tmp1) and file name */
                          /* (x_tmp2) to have it sorted correctly later     */
            x_tmp = STRIP(x5)
            IF Pos(' ', x_tmp) > 0 THEN
               x_tmp = Translate(x_tmp, '*', ' ')
            x_tmp = Translate(x_tmp)
            x_tmp1 = SubStr(x_tmp, 1, LastPos('\', x_tmp))
            x_tmp2 = Dbrleft(x_tmp, LastPos('\', x_tmp))
            n = n + 1
            files.n = x_tmp1||' '||x_tmp2||' '||x1||' '||x2||' '||x3||,
             ' '||x4||' 'x5
            files.0 = files.0 + 1
         END
         total = total + searches.0
	 IF fullspec = 1 THEN ITERATE j
         CALL CharOut, ' ('Format(searches.0,5,0)')'||crlf
      END
   END
   SAY ''
END
d.0 = k                                   /* Update number of actual drives */

                                       /* Write used file masks to rootfile */
DO i = 1 TO pars.0
    fmasks = fmasks||'['pars.i'] '
END
CALL CharOut rootfile, fmasks||'</H3>'||crlf
IF mid = 1 | long = 1 THEN
    CALL CharOut rootfile, '<HR>'||crlf

                          /* Write drive links to rootfile if one file only */
drvidx = 1
IF fullspec = 1 THEN drvidx = 2
IF mid  \= 1 & long \= 1 & d.0 > 1 THEN DO
   DO i = drvidx to d.0
       CALL SetLangue 24
   END
   CALL CharOut rootfile, crlf
END

_parsefilestem:        /* Tell the user what was found and how long it took */
IF pars.0 > 0 THEN DO 
   SAY ''; CALL CharOut, files.0; CALL SetLangue 5
   CALL CharOut, 'in 'Format(Time('E'),,2); CALL SetLangue 6
END

_sortfiles:          /* Sort stem of found files if more than one file mask */
IF pars.0 > 1 THEN DO
    CALL SetLangue 25
    CALL qqsort 1, files.0
END

_writefiles:
/* Scheme for output: (just in case you want to hack my code)
 * - with opt. /1 everything goes into 'rootfile' (main overview)
 * - with opt. /2 file entries found go into 'drvfile' (drives overview)
 *   and drives found go into 'rootfile'
 * - with opt. /3 file entries found go into 'dirfile' (dirs overview),
 *   directories found go into 'drvfile' and drives found go
 *   into 'rootfile'
 *
 * The part of next do-loop valid for all three options (default, mid
 * and long) processes a file variable 'outfile', so you need to make 
 * sure this variable is set to the appropriate output file *before* 
 * writing to it.
 *
 */

drvidx = 0
DO i = 1 to files.0
                  /* Forget about the first both temp. entries inserted  */
                  /* previously for sorting puposes and handle entries   */
                  /* as if these would be directly in SysFileTree format */
  PARSE value files.i WITH . . x1 x2 x3 x4 x5
  /* say x1' 'x2' 'x3' 'x4' 'x5 */
  it = STRIP(x5)
  actdrive = substr(it,1, 2)

  IF x1 = '' & x2 = '' THEN DO 
     SAY ''; ITERATE 
  END
  ELSE DO                             /* Handle files                    */
     actdir = substr(it,1, LastPos('\',it))

                                      /* Current drive has changed       */
     IF lastdrive <> actdrive THEN DO
        CALL SetLangue 20
        diridx = 0                 /* Reset directory index on new drive */
        IF mid = 1 | long = 1 THEN DO
             IF drvfile \= 'DRVFILE' THEN DO
                 IF long = 1 THEN DO     /* Don't forget last file index */
                     CALL CharOut drvfile, ' <I>['fileidx']</I><P>'crlf
                     oldfidx = fileidx; fileidx = 0
                 END
                 CALL CharOut drvfile, '<P><HR>'
                 CALL SetLangue 17
                 CALL CharOut drvfile, crlf
                 CALL MakeFooter drvfile
             END
             drvnam = substr(actdrive,1, 1)
             drvfile = drvnam||'.htm'
             CALL OpenFile(drvfile)
             CALL SetLangue 21
             IF mid = 1 THEN DO
                 CALL SetLangue 23
                 CALL CharOut drvfile, fmasks||'</H3><HR>'||crlf
             END
             CALL SetLangue 17
             CALL CharOut drvfile, '<HR><P>'crlf
             CALL SetLangue 18
        END
        ELSE           
             CALL CharOut rootfile, '<P><A Name="'||Translate(actdrive)||,
              '"><HR></A>'
     END

                                 /* Current directory has changed        */
     IF lastdir <> actdir THEN DO
        dirs = dirs + 1
	IF long = 1 THEN DO
            SAY actdir
            IF dirfile \= 'DIRFILE' THEN DO
                CALL CharOut dirfile, '<P><HR>'
                CALL SetLangue 19
                CALL CharOut dirfile, crlf
                CALL MakeFooter dirfile
                oldfidx = fileidx; fileidx = 0
                IF diridx > 0 THEN
                    CALL CharOut drvfile, ' <I>['oldfidx']</I></P>'crlf
            END

            diridx = diridx + 1
            dirfile = drvnam||diridx||'.htm'

            CALL OpenFile(dirfile)
            CALL SetLangue 22
            CALL CharOut dirfile, fmasks||'</H3><HR>'||crlf
            CALL SetLangue 19
            CALL CharOut dirfile, '<HR><P>'crlf
            CALL SetLangue 15
            outfile = dirfile
        END
        ELSE IF mid = 1 THEN
            outfile = drvfile
        ELSE
            outfile = rootfile

        CALL CharOut outfile, '<H3>['actdir']</H3>'crlf
     END

     itfname = Dbrleft(it, LastPos('\', it))
     linkstat = x1'&nbsp;-&nbsp;'x2'&nbsp;-&nbsp;'x3'&nbsp;Bytes'

     it_upper = Translate(it)                /* Get title if HTML file */
     extyes = Lastpos('.', it_upper)
     IF extyes > 0 THEN DO
         ext = SubStr(it_upper, extyes, length(it_upper))
         extlist = htmlext
         DO while extlist <> ''
             PARSE var extlist thisext extlist
             IF Pos(thisext, ext) > 0 THEN thisfile = 'HTML'
         END
         IF thisfile = 'HTML' THEN DO
            title = GetTitle(it)
            cleantitle = DelHtmlTags(title)
            thisfile = ''
         END
         ELSE cleantitle = ''
     END
     ELSE cleantitle = ''

     /* Replace all spaces in file name to let it look like one string */
     IF Pos(' ', it) > 0 THEN DO
        it = Translate(it, '*', ' ')
        itfname = Translate(itfname, '*', ' ')
     END

     IF long = 1 THEN fileidx = fileidx + 1
     files = files + 1
     CALL MakeLink outfile it linkstat itfname cleantitle 

  END
  lastdrive = actdrive; lastdir = actdir
END                           

_addhtmlfooter:
IF long = 1 THEN DO                /* Don't forget very last file index */
    CALL CharOut drvfile, ' <I>['fileidx']</I><P>'crlf
    CALL CharOut drvfile, '<P><HR>'
    CALL SetLangue 17
    CALL CharOut drvfile, crlf
    CALL MakeFooter drvfile
    CALL CharOut dirfile, '<P><HR>'
    CALL SetLangue 19
    CALL CharOut dirfile, crlf
    CALL MakeFooter dirfile
END
IF mid = 1 THEN DO
    CALL CharOut drvfile, '<P><HR>'
    CALL SetLangue 17
    CALL CharOut drvfile, crlf
    CALL MakeFooter drvfile
END
CALL MakeFooter rootfile

_getelapsedtime:        /* Tell user what happened and how long it took */
IF pars.0 > 0 THEN DO 
   SAY ''; CALL SetLangue 13; CALL CharOut, files
   CALL SetLangue 14; CALL CharOut, dirs||crlf
   CALL SetLangue 16; CALL Charout, Format(Time('E'),,2)
   CALL SetLangue 6
END

_housekeeping:
SIGNAL _unload

_usage:                                    /* Output help text to screen */
PARSE SOURCE . . filen                      /* Determine source filename */
PARSE upper var filen fn'.'
fn = dbrleft(fn, LastPos('\', fn))
CALL SetUsage lval, fn, version
SAY ''
DO i = 1 to 13                                   /* Show all usage lines */
   IF i = 2 | i = 4 | i = 11 THEN SAY ''            /* Insert blank line */
   SAY Value('use'i)
END

_unload:
IF loaded = 1 THEN CALL SysDropFuncs
EXIT 0                                            /* End of main routine */

_userbreak:
SAY ''; SAY 'Bye bye...'
SIGNAL _housekeeping

/*************************/
/* Additional functions */
/***********************/

/* Check whether Netscape is installed */
Chk4Netscape:
penv = Value('path', , 'OS2ENVIRONMENT')
PARSE UPPER Value(penv) WITH npath
IF Pos('NETSCAPE', npath) > 0 THEN
    ns = 1
ELSE
    ns = 0

RETURN ns

MakeHeader:
    PARSE ARG outfile title

    PARSE SOURCE . . filen
    PARSE upper var filen fn'.'
    fn = dbrleft(fn, LastPos('\', fn))

    CALL CHAROUT outfile, '<HTML> <HEAD>'crlf
    CALL CHAROUT outfile, '<!-- File automatically generated by '||fn||' on '
    CALL CHAROUT outfile, DATE()' at 'TIME('N')' -->'crlf
    CALL CHAROUT outfile, '<TITLE>'title'</TITLE></HEAD><BODY',
     'BGCOLOR="#FFFFFF">'crlf
RETURN

MakeFooter:
    ARG outfile
    CALL CHAROUT outfile, '<HR>'crlf'[<I>'DATE() TIME('N')'</I>]'crlf
    CALL CHAROUT outfile, '</BODY> </HTML>'crlf
    CALL stream outfile,'c','close'
RETURN

/* Make a link for current entry (file) */
MakeLink: PROCEDURE EXPOSE javascr crlf
    parse ARG outfile url jlink rstr title

    /* Put spaces in file name back where these belong */
    IF Pos('*', url) > 0 THEN DO
        url = Translate(url, ' ', '*')
        rstr = Translate(rstr, ' ', '*')
    END

    IF javascr = 1 THEN DO
        j1 = ' onMouseOver="window.status='||"'"||jlink||" ';return true"||'" '
        j2 = 'onMouseOut="window.status='||"' '"||';return true" '
        java1 = j1||j2
        IF title <> '' THEN
	    CALL CHAROUT outfile, '<A'java1'HREF="file:///'url'">'title'</A>',
             ' <I>['rstr']</I><BR>'
        ELSE
	    CALL CHAROUT outfile, '<A'java1'HREF="file:///'url'">'url'</A><BR>'
    END
    ELSE DO
        IF title <> '' THEN
	    CALL CHAROUT outfile, '<A HREF="file:///'url'">'title'</A>',
             ' <I>['rstr',&nbsp;'jlink']</I><BR>'
        ELSE
	    CALL CHAROUT outfile, '<A HREF="file:///'url'">'url'</A>',
             ' <I>['jlink']</I><BR>'
    END
    CALL CHAROUT outfile, crlf
RETURN

/* Fetch title line from from file */
GetTitle: PROCEDURE expose lval crlf
   PARSE ARG htmlfile
   titleline = ''
   IF Stream(htmlfile,'c','query exists') = '' THEN DO
      IF Pos('49',lval,1) = 1 THEN DO
          SAY 'Kann Datei 'htmlfile' nicht finden.'
          RETURN 'Datei nicht gefunden: 'htmlfile
      END
      ELSE DO
          SAY 'File 'htmlfile' not found.'
          RETURN 'File not found: 'htmlfile
      END
   END
   IF Stream(htmlfile,'c','open read') \= 'READY:' THEN DO
      CALL SetLangue 11
      CALL CharOut, htmlfile||crlf
      RETURN htmlfile
   END
   DO while Stream(htmlfile,'s') \= 'NOTREADY' 
      line = LineIn(htmlfile)
      PARSE UPPER VALUE(line) WITH buffer
      buffer = STRIP(buffer)

      /* Title string on this line */
      IF POS('<TITLE>', buffer) > 0 & Length(buffer) > 8 THEN DO
          titleline = line
          LEAVE
      END
      /* Title string probably on next line */
      ELSE IF POS('<TITLE>', buffer) > 0 THEN DO
          titleline = LineIn(htmlfile)
          LEAVE
      END

   END
   CALL Stream htmlfile,'c','close'
RETURN titleline

/* Delete HTML tags from input line */
DelHtmlTags:
   PARSE ARG line
   DO while POS('<', line) > 0
      p = POS('<', line)
      q = POS('>', line, p)
      IF q = 0 THEN
         q = POS(' ', line, p)
      IF p < q THEN
        line = DELSTR(line,p,q - p + 1)
      ELSE
        line = DELSTR(line,p,length(line))
   END
RETURN line

/* Open a file and check whether it's accesible */
OpenFile:
parse arg file
IF Stream(file,'c','query exists') <> '' THEN DO
    CALL SetLangue 10
    CALL CharOut, file
    CALL SetLangue 8
    rc = SysFileDelete(file)
    CALL Rsp_SysFileDelete rc
END
IF Stream(file,'c','open') \= 'READY:' THEN DO
    CALL SetLangue 11   
    CALL CharOut, file||crlf
END
RETURN

/* ------------------------------------------------------------------ */
/* function: quick sort routine                                       */
/*                                                                    */
/* call:     qqsort first_element, last_element                       */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/* notes:    You must save the elements to sort in the stem "a."      */
/*           a.0 must contain the number of elements in the stem.     */
/*                                                                    */
/*                                                                    */
/* This function worked out of the box - I just have changed          */
/* the name of the stem - and is directly taken from                  */
/* Rexx Tips & Tricks (rxtt26.zip), Copyright (c) 1994 - 1997,        */
/* by Bernd Schemmer <100104.613@compuserve.com>                      */
/* (You'll find it on Hobbes (http://hobbes.nmsu.edu))                */

qqsort: procedure expose files.

  arg lf, re

  IF re -lf < 9 THEN
    DO lf = lf TO re -1
      m = lf
      DO j = lf +1 TO re
        IF files.j < files.m THEN
          m = j
      END
      t = files.m; files.m = files.lf; files.lf = t
   END
   ELSE
     DO
       i = lf
       j = re
       k = (lf + re)%2
       t = files.k
       DO UNTIL i > j
         DO WHILE files.i < t
           i = i + 1
         END
         DO WHILE files.j > t
           j = j - 1
         END
         IF i <= j THEN
         DO
           xchg = files.i
           files.i = files.j
           files.j = xchg
           i = i + 1
           j = j - 1
         END
      END
      CALL qqsort lf, j
      CALL qqsort i, re
   END

RETURN

/********************************/
/* Language specific functions */
/******************************/
/*
 * Use these for your own language if it is neither german nor english.
 * I suggest to replace the german and to leave the english language.
 * Just change the country code and the appropriate output strings.
 */
/* Set input strings according to current country code                   */
SetInput: PROCEDURE expose args. yes
   PARSE ARG country
   IF Pos('49',country,1) = 1 THEN DO
       yes = 'J'
       args.0 = 'a'; args.1 = '1'
       args.2 = '2'; args.3 = '3'
       args.4 = 'n'; args.5 = '-'
       args.6 = 's'; args.7 = 'b'
   END
   ELSE DO
       yes = 'Y'
       args.0 = 'a'; args.1 = '1'
       args.2 = '2'; args.3 = '3'
       args.4 = 'n'; args.5 = '-'
       args.6 = 's'; args.7 = 'r'
   END
RETURN

/* Set usage strings according to current country code                   */
SetUsage:
   PARSE ARG country, file, vers
   IF Pos('49',country,1) = 1 THEN DO 
      use1a = ' '||'1b5b376d'x||file vers
      use1b = ' - Erstellen von VerzeichnisÅbersichten als HTML-Datei',
              '1b5b306d'x
      use1 = use1a||use1b
      use2 = '   Aufruf:                                                                '
      use3 = '   'file' [/a /b<lna> /1 /2 /3 /n<map.htm> /-<def...>] <dateimaske> [...] '
      use4 = '     /a: Alle Laufwerke durchsuchen                                       '
      use5 = '     /1: Eine HTML-Seite fÅr alle Dateien (Standard)                      '
      use6 = '     /2: Eine HTML-Seite pro Laufwerk                                     '
      use7 = '     /3: Eine HTML-Seite pro Verzeichnis                                  '
      use8 = '     /n: Name der Hauptseite (Standard: dirmap.htm)                       '
      use9 = '     /-: Laufwerke, die nicht durchsucht werden sollen                    '
     use10 = '     /b: Laufwerksbereich: [l]okal (Standard), [n]etz, [a]lle             '
     use11 = '   Beispiele:                                                             '
     use12 = '   'file' c:\netscape\cache\*.*htm?                                       '
     use13 = '   'file' /a /3 /-ij *.*htm? *.gif *.jp*g                                 '
   END
   ELSE DO 
      use1a = ' '||'1b5b376d'x||file vers
      use1b = ' - compile directory overviews as HTML file '||'1b5b306d'x
      use1 = use1a||use1b
      use2 = '   Usage:                                                               '
      use3 = '   'file' [/a /r<lna> /1 /2 /3 /n<map.htm> /-<def...>] <filemask> [...] '
      use4 = '     /a: scan all disk drives                                           '
      use5 = '     /1: one HTML page for all files (default)                          '
      use6 = '     /2: one HTML page per drive                                        '
      use7 = '     /3: one HTML page per directory                                    '
      use8 = '     /n: name of root page (default: dirmap.htm)                        '
      use9 = '     /-: drives which are not to be scanned                             '
     use10 = '     /r: drive range: [l]ocal (default), [n]et, [a]ll                   '
     use11 = '   Examples:                                                            '
     use12 = '   'file' c:\netscape\cache\*.*htm?                                     '
     use13 = '   'file' /a /3 /-ij *.*htm? *.gif *.jp*g                               '
   END
RETURN 

/* Output strings according to current country code                      */
SetLangue: PROCEDURE expose lval crlf rootfile drvfile dirfile,
            actdrive actdir javascr pars. d. i

   PARSE ARG out
   IF Pos('49',lval,1) = 1 THEN DO 
      SELECT 
       WHEN out = 1 THEN 
	  CALL CharOut, 'Suche nach '
       WHEN out = 2 THEN
          CALL CharOut, ' auf Laufwerk '
       WHEN out = 3 THEN
          CALL CharOut, 'Fehler beim Zugriff auf Laufwerk '
       WHEN out = 4 THEN
          CALL CharOut rootfile, '<H1>Snapshot der vorhandenen',
           'Dateien</H1>'||crlf
       WHEN out = 5 THEN
          CALL CharOut, ' Datei(en) gefunden '
       WHEN out = 6 THEN
          CALL CharOut, ' Sekunden.'||crlf
       WHEN out = 7 THEN
          CALL CharOut rootfile, '<H3>Verwendete Dateimaske(n): '
       WHEN out = 8 THEN
          CALL CharOut, ' wird Åberschrieben.'||crlf||crlf
       WHEN out = 9 THEN
          CALL CharOut, ' Keine Dateimaske angegeben.'||crlf
       WHEN out = 10 THEN 
	  CALL CharOut, 'Datei existiert bereits: '
       WHEN out = 11 THEN 
	  CALL CharOut, 'Fehler beim ôffnen von '
       WHEN out = 12 THEN 
	  CALL CharOut, ' Unbekannte(r) Kommandozeilenschalter: '
       WHEN out = 13 THEN 
	  CALL CharOut, 'Dateien: '
       WHEN out = 14 THEN 
	  CALL CharOut, ' und Verzeichnisse: '
       WHEN out = 15 THEN DO
          IF javascr = 1 THEN DO
              j1 = ' onMouseOver="window.status='||"'"||"&Uuml;bersicht",
              "der Dateien dieses Verzeichnisses"||" ';return true"||'" '
              j2 = 'onMouseOut="window.status='||"' '"||';return true" '
              java1 = j1||j2
              CALL CharOut drvfile, '<P><A'java1'HREF="'dirfile'">'actdir'</A>'
          END
          ELSE
              CALL CharOut drvfile, '<P><A HREF="'dirfile'">'actdir'</A>'
       END
       WHEN out = 16 THEN
	  CALL CharOut, 'bearbeitet in '
       WHEN out = 17 THEN DO
          IF javascr = 1 THEN DO
              j1 = ' onMouseOver="window.status='||"'"||"&Uuml;bersicht",
              "der Laufwerke"||" ';return true"||'" '
              j2 = 'onMouseOut="window.status='||"' '"||';return true" '
              java1 = j1||j2
              CALL CharOut drvfile, '[<A'java1'HREF="'rootfile'">Zur&uuml;ck',
               'zur &Uuml;bersicht</A>]'
          END
          ELSE
              CALL CharOut drvfile, '[<A HREF="'rootfile'">Zur&uuml;ck',
               'zur &Uuml;bersicht</A>]'
       END
       WHEN out = 18 THEN DO
          IF javascr = 1 THEN DO
             j1 = ' onMouseOver="window.status='||"'"||,
              "Verzeichnis&uuml;bersicht dieses Laufwerks",
               ||" ';return true"||'" '
             j2 = 'onMouseOut="window.status='||"' '"||';return true" '
             java1 = j1||j2
             CALL CharOut rootfile, '<P><A'java1'HREF="'drvfile||,
              '">Laufwerk 'actdrive'</A></P>'crlf
          END
          ELSE
              CALL CharOut rootfile, '<P><A HREF="'drvfile'">Laufwerk',
               actdrive'</A></P>'crlf
       END
       WHEN out = 19 THEN DO
          IF javascr = 1 THEN DO
             j1 = ' onMouseOver="window.status='||"'"||"&Uuml;bersicht",
             "der Laufwerke"||" ';return true"||'" '
             j2 = 'onMouseOut="window.status='||"' '"||';return true" '
             java1 = j1||j2
             j3 = ' onMouseOver="window.status='||"'"||,
              "Verzeichnis&uuml;bersicht dieses Laufwerks",
               ||" ';return true"||'" '
             j4 = 'onMouseOut="window.status='||"' '"||';return true" '
             java2 = j3||j4
             CALL CharOut dirfile, '[<A'java1' HREF="'rootfile'">Zur&uuml;ck',
              'zur &Uuml;bersicht</A>] [<A'java2' HREF="'drvfile||,
              '">Zur&uuml;ck zum aktuellen Laufwerk</A>]'          
          END
          ELSE
              CALL CharOut dirfile, '[<A HREF="'rootfile'">Zur&uuml;ck',
               'zur &Uuml;bersicht</A>] [<A HREF="'drvfile'">Zur&uuml;ck',
               'zum aktuellen Laufwerk</A>]'
       END
       WHEN out = 20 THEN
          CALL CharOut, crlf'Bearbeite Laufwerk 'actdrive||crlf
       WHEN out = 21 THEN
          CALL MakeHeader drvfile 'Laufwerk 'actdrive
       WHEN out = 22 THEN
          CALL MakeHeader dirfile 'Verzeichnis 'actdir
       WHEN out = 23 THEN
          CALL CharOut drvfile, '<H3>Verwendete Dateimaske(n): '
       WHEN out = 24 THEN DO
          IF javascr = 1 THEN DO
              j1 = ' onMouseOver="window.status='||"'"||,
                "Gehe zu Laufwerk "||d.i||" ';return true"||'" '
              j2 = 'onMouseOut="window.status='||"' '"||';return true" '
              java1 = j1||j2
              CALL CharOut rootfile, '[<A'java1' HREF="#'||d.i||,
                 '">Laufwerk&nbsp;'||d.i||'</A>] '
          END
          ELSE DO
              CALL CharOut rootfile, '[<A HREF="#'||d.i||'">Laufwerk '||,
                d.i||'</A>] '
          END
       END 
       WHEN out = 25 THEN
          CALL CharOut, crlf||'Sortiere gefundene Dateien...'||crlf
      END
   END
   ELSE DO 
      SELECT 
       WHEN out = 1 THEN
          CALL CharOut, 'Searching for '
       WHEN out = 2 THEN
          CALL CharOut, ' on drive '
       WHEN out = 3 THEN
          CALL CharOut, 'Error accessing drive '
       WHEN out = 4 THEN
          CALL CharOut rootfile, '<H1>Snapshot of files found</H1>'||crlf
       WHEN out = 5 THEN
          CALL CharOut, ' file(s) found in '
       WHEN out = 6 THEN
          CALL CharOut, ' seconds.'||crlf
       WHEN out = 7 THEN
          CALL CharOut rootfile, '<H3>File mask(s) used: '
       WHEN out = 8 THEN
          CALL CharOut, ' will be overwritten.'||crlf||crlf
       WHEN out = '9' THEN
          CALL CharOut, ' No file mask given.'||crlf
       WHEN out = '10' THEN 
          CALL CharOut, 'File already exists: '
       WHEN out = '11' THEN 
	  CALL CharOut, 'Error opening file '
       WHEN out = '12' THEN 
	  CALL CharOut, ' Unknown commandline switch(es): '
       WHEN out = '13' THEN 
	  CALL CharOut, 'Files: '
       WHEN out = '14' THEN 
	  CALL CharOut, ' and directories: '
       WHEN out = '15' THEN DO
          IF javascr = 1 THEN DO
              j1 = ' onMouseOver="window.status='||"'"||"Overview",
              "of the files in this directory"||" ';return true"||'" '
              j2 = 'onMouseOut="window.status='||"' '"||';return true" '
              java1 = j1||j2
              CALL CharOut drvfile, '<P><A'java1'HREF="'dirfile'">'actdir'</A>'
          END
          ELSE
              CALL CharOut drvfile, '<P><A HREF="'dirfile'">'actdir'</A>'
       END
       WHEN out = '16' THEN 
	  CALL CharOut, 'processed in '
       WHEN out = '17' THEN DO
          IF javascr = 1 THEN DO
              j1 = ' onMouseOver="window.status='||"'"||"Overview",
              "of drives"||" ';return true"||'" '
              j2 = 'onMouseOut="window.status='||"' '"||';return true" '
              java1 = j1||j2
              CALL CharOut drvfile, '[<A'java1'HREF="'rootfile'">Back to',
               'content overview</A>]'
          END
          ELSE
              CALL CharOut drvfile, '[<A HREF="'rootfile'">Back to',
               'content overview</A>]'
       END
       WHEN out = '18' THEN DO
          IF javascr = 1 THEN DO
             j1 = ' onMouseOver="window.status='||"'"||,
              "Directory overview of this drive",
               ||" ';return true"||'" '
             j2 = 'onMouseOut="window.status='||"' '"||';return true" '
             java1 = j1||j2
             CALL CharOut rootfile, '<P><A'java1'HREF="'drvfile||,
              '">Drive 'actdrive'</A></P>'crlf
          END
          ELSE
              CALL CharOut rootfile, '<P><A HREF="'drvfile'">Drive',
               actdrive'</A></P>'crlf
       END
       WHEN out = '19' THEN DO
          IF javascr = 1 THEN DO
             j1 = ' onMouseOver="window.status='||"'"||"Overview",
             "of drives"||" ';return true"||'" '
             j2 = 'onMouseOut="window.status='||"' '"||';return true" '
             java1 = j1||j2
             j3 = ' onMouseOver="window.status='||"'"||,
              "Directory overview of this drive",
               ||" ';return true"||'" '
             j4 = 'onMouseOut="window.status='||"' '"||';return true" '
             java2 = j3||j4
             CALL CharOut dirfile, '[<A'java1' HREF="'rootfile'">Back to',
              'content overview</A>] [<A'java2' HREF="'drvfile||,
              '">Back to current drive</A>]'          
          END
          ELSE
              CALL CharOut dirfile, '[<A HREF="'rootfile'">Back to',
               'content overview</A>] [<A HREF="'drvfile'">Back to',
               'current drive</A>]'
       END
       WHEN out = '20' THEN
          CALL CharOut, crlf'Processing drive 'actdrive||crlf
       WHEN out = '21' THEN
          CALL MakeHeader drvfile 'Drive 'actdrive
       WHEN out = '22' THEN
          CALL MakeHeader dirfile 'Directory 'actdir
       WHEN out = 23 THEN
          CALL CharOut drvfile, '<H3>File mask(s) used: '
       WHEN out = 24 THEN DO
          IF javascr = 1 THEN DO
              drive = substr(d.i,1,1)
              j1 = ' onMouseOver="window.status='||"'"||,
                "Go to drive "||drive||" ';return true"||'" '
              j2 = 'onMouseOut="window.status='||"' '"||';return true" '
              java1 = j1||j2
              CALL CharOut rootfile, '[<A'java1' HREF="#'||d.i||,
                 '">drive&nbsp;'||d.i||'</A>] '
          END
          ELSE DO
              CALL CharOut rootfile, '[<A HREF="#'||d.i||'">drive '||,
                d.i||'</A>] '
          END
       END
       WHEN out = 25 THEN
          CALL CharOut, crlf||'Now sorting files found...'||crlf
      END 
   END
RETURN 

/* Puts return code from SysFileDelete into human language               */
/* and chooses output depending on actual language code                  */
Rsp_SysFileDelete: PROCEDURE expose lval
   PARSE ARG ret_code
   IF Pos('49',lval,1) = 1 THEN DO 
      SELECT 
       WHEN ret_code = 0 THEN RETURN 
       WHEN ret_code = 2 THEN 
          SAY 'Fehler. Datei nicht gefunden.'
       WHEN ret_code = 3 THEN 
          SAY 'Pfad bereits gelîscht. (Fehler. Pfad nicht gefunden)'
       WHEN ret_code = 5 THEN 
          SAY 'Fehler. Zugriff verweigert.'
       WHEN ret_code = 26 THEN 
          SAY 'Fehler. Kein DOS-DatentrÑger.'
       WHEN ret_code = 32 THEN 
          SAY 'Fehler. Konflikt bei gemeinsamem Zugriff.'
       WHEN ret_code = 36 THEN 
          SAY 'Fehler. öberlauf im Puffer fÅr gemeinsamen Zugriff.'
       WHEN ret_code = 87 THEN 
          SAY 'Fehler. UngÅltiger Parameter.'
       WHEN ret_code = 206 THEN 
          SAY 'Fehler. Dateiname oder -erweiterung zu lang.'
       OTHERWISE SAY 'Unbekannter Fehler beim Lîschen einer Datei.'
      END
      SAY ''
   END
   ELSE DO 
      SELECT 
       WHEN ret_code = 0 THEN RETURN 
       WHEN ret_code = 2 THEN 
          SAY 'Error. File not found.'
       WHEN ret_code = 3 THEN 
          SAY 'Path already deleted. (Error. Path not found.)'
       WHEN ret_code = 5 THEN 
          SAY 'Error. Access denied.'
       WHEN ret_code = 26 THEN 
          SAY 'Error. Not DOS disk.'
       WHEN ret_code = 32 THEN 
          SAY 'Error. Sharing violation.'
       WHEN ret_code = 36 THEN 
          SAY 'Error. Sharing buffer exceeded.'
       WHEN ret_code = 87 THEN 
          SAY 'Error. Invalid parameter'
       WHEN ret_code = 206 THEN 
          SAY 'Error. Filename exceeds range error'
       OTHERWISE SAY 'Unknown error when deleting file.'
      END
      SAY ''
   END
RETURN
  
