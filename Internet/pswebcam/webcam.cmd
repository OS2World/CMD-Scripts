/******************************************************************************
Pille's Streaming WebCam for OS/2 in REXX                            v0.4.15b

This is EMailware - write me a message with location of your running cam !

Usage:  http://your.host.blah/cgi-bin/webcam.cmd?contrast=[0-255]&delay=[seconds]&quality=[poor | low | high | superb] 
        http://your.host.blah/cgi-bin/webcam.cmd?status=1

You can block access if a file "lock.stream" exists, the offlinepic
is sent, this even stops currently running cgi's.

?status=1 delivers on/offline picture f.e. as link to the webcam.

Needs: 
  * IBM OS/2 w/ ReXX installed
  * an OS/2 webserver capable of running CGI's (I use Apache v1.2.4)
  * an <IMG SRC="/cgi-bin/webcam.cmd" WIDTH=320 HEIGHT=240>
    so that the smaller pic is blown up, looks better than a stamp ;)
  * EMX Runtime environment
    ftp://ftp.leo.org/pub/comp/os/os2/leo/02-emx-runtime.zip
  * cjpeg.exe from the jpeg group 
    http://hobbes.nmsu.edu/pub/os2/apps/graphics/imagepro/jpeg6a_os2a.zip
  * gbmsize.exe from gbm 
    http://hobbes.nmsu.edu/pub/os2/apps/graphics/gbm.zip
  * qv2snap.exe QV/2
    http://www.compulink.co.uk/~elad/qv2.htm
  
Bugs/notes:
  * rexx has a bad signal handling while executing files
    signal may not be caught resulting in blocking lockfile (no fix?)
  * my ReXX is far away from good
  * you need HPFS (for the files ;)
  * please contribute code! I'm bad with ReXX and C.
    a faster grabber would be nice !
  * found a communicator bug, mixed graphics crash comunicator ;(

History:
  * 19980130: security issues (datatype on cgi.contrast, it was possible to format
              your drive ;)
              Communicator crashes after calibrating pic, commented out until
              Netscape fixes this (works with 2.02(3)/OS2 though)
              Status now integrated
  * 19980127: New QV2SNAP now works - and is pretty fast thats why
              I dumped qframe & alchemy
              gbm/cjpeg convertion is faster than alchemy
              "multiuser" back again
              autocalibrating!
              time-terminated
              new quality: "superb" with no converter-run                           
              cgiparse 1.07
  * 19980122: JPEG stream support (less bandwidth)
              adjusted the default settings to high,180,60
  * 19980114: Latest ver now on Server
  * 19971223: reverted to "single user mode"
  * 19971220: 1st Public release
  * 19971220: hm my IF loops suck(ed?)

Future:
  * better param parsing
  * maybe a named pipe server an cgi-clients will do better (multi)?
  * same in C ;)
  * better cgi-abort via socket snooping (SIGNALs from apache?)

You have to write your controller yourself or take a look at mine at 
http://www.chillout.org/cam-extreme.html (write email for HTML source).
I wrote my controller in RXML (RoXen Macro Language) running under
Roxen Challenger v1.2 Webserver (http://www.roxen.com/). It won't work 
for you if you are not running this fine thing but you may get a clue.

Latest Version: http://www.chillout.org/auswurf/software.html

Credits: --Ryan C. Gordon (mailto:warped42@ix.netcom.com) for this nice small VIO
         wav player which I included here 
         ftp://ftp.leo.org/pub/comp/os/os2/leo/sound/pmaud11.zip
         --Sacha Prins, sacha@prins.net for CGIParse 1.07
         
Thanks go out to: rhoenie, #os/2ger

Have phun...
                      Pille <pille@chillout.org>  -  http://www.chillout.org/
                      Pille@IRCnet
******************************************************************************/
Call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
Call 'SysLoadFuncs'
SIGNAL ON HALT NAME die
SIGNAL ON FAILURE NAME die
SIGNAL ON SYNTAX NAME die
SIGNAL ON ERROR NAME die

/*
** Settings & defaults
*/

_maxtime    = 60              /* how long we should run and send video [seconds] */
_path       = ''              /* path for temp files hint: use ramdisk.ifs ! 
                                 note: needs trailing slash or leave empty for current cgi-path */

default.contrast   =  60      /* Default contrast */
default.delay      =   0      /* Default grabdelay [seconds] */
default.quality    = 'high'   /* Default quality [poor | low | high | superb] */
default.brightness = 180      /* Whitebalance, 180 works best for me with autoexposure */

_pq_x       = 160             /* Poor quality width  [pixel] */
_pq_y       = 120             /* Poor quality width  [pixel] */
_pq_bpp     =   6             /* Poor quality bits per pixel [4 | 6] */
_lq_x       = 160             /* Low  quality width  [pixel] */
_lq_y       = 120             /* Poor quality width  [pixel] */
_lq_bpp     =   6             /* Low  quality bits per pixel [4 | 6] */
_hq_x       = 200             /* High quality width  [pixel] */
_hq_y       = 170             /* Poor quality width  [pixel] */
_hq_bpp     =   6             /* High quality bits per pixel [4 | 6] */

_online     = 'online.gif'     /* Pic displayed when offline/lock.stream exists */
_onlinetype = 'gif'            /* Offline Pic type [jpeg | gif] */
_offline    = 'offline.gif'   /* Pic displayed when offline/lock.stream exists */
_offlinetype= 'gif'           /* Offline Pic type [jpeg | gif] */
_calibrate  = 'calibrate.gif'
_calibratetype= 'gif'

/*
** End of settings
*/

_lockfile   = 'lock.stream'
_picturein  = _path || SysTempFileName('quickcam-???.jpg')
_pictureout = _path || SysTempFileName('quickcam-converted-???.pgm')
_lf         = x2c(0a)
_startup    = 0

call CGIParse

IF \DATATYPE(cgi.delay,'N') THEN cgi.delay=default.delay ; ELSE NOP
IF \DATATYPE(cgi.contrast,'N') THEN cgi.contrast=default.contrast ; ELSE NOP
IF cgi.quality='CGI.QUALITY' THEN cgi.quality=default.quality ; ELSE NOP
IF cgi.status = 1 THEN
 DO
  IF exists(_lockfile) THEN 
    DO
      rc = Charout(,'Content-type: image/' || _offlinetype || _lf || _lf)
      rc = Rxcat(_offline)
      exit 0
    END
  ELSE
    DO
      rc = Charout(,'Content-type: image/' || _onlinetype || _lf || _lf)
      rc = Rxcat(_online)
      exit 0
    END
 END
ELSE NOP

SELECT
	WHEN cgi.quality='poor' THEN DO
          _grabber='@qv2snap /q /s /j /b' || _pq_bpp '/C' || cgi.contrast '/f' || _picturein '>nul'
	  _converter='@gbmsize -w' _pq_x '-h' _pq_y _picturein _pictureout ' & cjpeg -optimize -quality 40 -baseline' _pictureout
        END
	WHEN cgi.quality='low' THEN DO
          _grabber='@qv2snap /q /s /j /b' || _lq_bpp '/C' || cgi.contrast '/f' || _picturein '>nul'
          _converter='@gbmsize -w' _lq_x '-h' _lq_y _picturein _pictureout ' & cjpeg -optimize -quality 50 -baseline' _pictureout
	END
	WHEN cgi.quality='high' THEN DO
	  _grabber='@qv2snap /q /s /j /b' || _hq_bpp '/C' || cgi.contrast '/f' || _picturein '>nul'
	  _converter='@gbmsize -w' _hq_x '-h' _hq_y _picturein _pictureout ' & cjpeg -optimize' _pictureout
	END
        WHEN cgi.quality='superb' THEN DO
	  _grabber='@qv2snap /q /s /j /b' || _hq_bpp '/C' || cgi.contrast '/f' || _picturein '>nul'
	  _converter=''
          _pictureout=_picturein
	END
        OTHERWISE SIGNAL die
END
/*
** Begin server push and dump out grabbed pictures until I'm running longer _maxtime 
*/

'@start /min /n playwav klaxon.wav'

Call Time 'E'

rc = Charout(,"Content-type: multipart/x-mixed-replace;boundary=webcam_boundary" || _lf) 

DO UNTIL TIME('E') > _maxtime
  IF exists(_lockfile) THEN 
    DO
      rc = Charout(,_lf || '--webcam_boundary' || _lf)
      rc = Charout(,'Content-type: image/' || _offlinetype || _lf || _lf)
      rc = Rxcat(_offline)
      SIGNAL die
    END
  ELSE nop

  IF _startup = 0 THEN
    DO
      _startup = 1
/* Communicator would crash here **
      rc = Charout(,_lf || '--webcam_boundary' || _lf)
      rc = Charout(,'Content-type: image/' || _calibratetype || _lf || _lf)
      rc = rxcat(_calibrate)
*/
      rc = Charout(,_lf || '--webcam_boundary' || _lf)
      rc = Charout(,'Content-type: image/jpeg' || _lf || _lf)
      '@qv2snap /q /a /d /B' || default.brightness '/j /C' || cgi.contrast '/f' || _picturein '>nul'
      IF RC \= 0 THEN SIGNAL die ; ELSE NOP
      IF _converter \= '' THEN _converter ; ELSE rxcat(_pictureout)
      IF RC \= 0 THEN SIGNAL die ; ELSE NOP
    END
  ELSE nop

  rc = Charout(,_lf || '--webcam_boundary' || _lf)
  rc = Charout(,'Content-type: image/jpeg' || _lf || _lf)
  _grabber
  IF RC \= 0 THEN SIGNAL die ; ELSE NOP
  IF _converter \= '' THEN _converter ; ELSE rc = rxcat(_pictureout)
  IF RC \= 0 THEN SIGNAL die ; ELSE NOP
  rc = Syssleep(cgi.delay)
END

Die:
rc = sysfiledelete(_picturein)
rc = sysfiledelete(_pictureout)

quit:
rc = charout(,_lf || '--webcam_boundary--' || _lf)
exit 0

/******************************** procedures **********************************/

RxCat: procedure
parse arg file1
 rc=STREAM(file1,'C','OPEN READ')
 rc=CHAROUT(,CHARIN(file1,,STREAM(file1,'c','QUERY SIZE')))
 rc=STREAM(file1,'C','CLOSE')
return 0

exists: procedure
parse arg stream
IF STREAM(stream, 'C', 'QUERY EXISTS') = '' THEN RETURN 0
        ELSE RETURN 1

/* CGIPARSE 1.0.7, public release 1.0, build 7 */
/*********************************************************************/
CGIParse:PROCEDURE EXPOSE cgi.

queryString=''

IF getEnv('REQUEST_METHOD') = 'POST' THEN
 DO
    IF getEnv('CONTENT_TYPE') \= 'application/x-www-form-urlencoded' THEN RETURN 1
    j= getEnv('CONTENT_LENGTH')
    IF DATATYPE(j, 'W') \= 1 THEN queryString=''
    ELSE queryString= LINEIN()
 END
ELSE /* GET */
DO
 queryString= getEnv('QUERY_STRING')
END

queryString= TRANSLATE(queryString, ' ', '+')

DO WHILE LENGTH(queryString) > 0
 varCouple= ''
 PARSE VAR queryString varCouple'&'queryString
 PARSE VAR varCouple varName'='varVal
 IF varName = '' | varVal= '' THEN ITERATE
 varName= 'cgi.' || urlDecode(varName)
 varVal=  urlDecode(varVal)
 IF SYMBOL(varName) = 'BAD' THEN ITERATE
 IF VALUE(varName) \= TRANSLATE(varName) THEN call VALUE varName, VALUE(varName) || '0d'x || varVal
 ELSE call VALUE varName, varVal
END

RETURN 0

/*********************************************************************/
URLDecode:PROCEDURE EXPOSE cgi.

IF ARG()\=1 THEN RETURN ''
line= ARG(1)
lineLen= LENGTH(line)
newLine= ''

i=1
DO WHILE i <= lineLen
 c= SUBSTR(line, i, 1)
 IF c \= '%' THEN newLine = newLine || c
 ELSE IF i+2 <= lineLen THEN
                        DO
                           newLine= newLine || x2c(SUBSTR(line, i+1, 2))
                           i=i+2
                        END
 i= i+1
END
RETURN newLine


/*********************************************************************/
getEnv:PROCEDURE
RETURN VALUE(ARG(1),, 'OS2ENVIRONMENT')

/*********************************************************************/
putEnv:PROCEDURE
RETURN VALUE(ARG(1), ARG(2), 'OS2ENVIRONMENT')