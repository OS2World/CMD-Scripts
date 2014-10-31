/* MR/2 ICE - MSGUTIL.CMD

   Copyright (c) 1996 2008 AlphaCat Solutions, Inc.
   Copyright (c) 1996 2011 Steven Levine and Associates, Inc.
   All Rights Reserved.

   Author:         Nick Knight
   Created:        03/03/96
   Usage:          msgutil subcommand MessageFile

   msgutil.cmd allows for special processing of message	files.
   It is called by MR/2 ICE adn passed a subcommand number based on the Fkey
   used	to invoke the script (F1 == 1, F12 = 12) and the current message file name.

   Messages should be sent to STDERR because STDOUT is redirected to the mr/2 log.
   Use lineout, not say.

   ** Major Update: 04/16/96, gutted/rewritten using wonderful examples by:

   Author:	Jason Gottschalk, Internet: os2@tir.com
   Date:	March 15, 1996

1998-05-11 SHL Rework view html to use tmp directory
2004-10-07 SHL F12 - add simple menu
2004-11-04 SHL F5 - find unique name
2004-12-30 SHL Sanitize intiaization and error code some more
2004-12-31 SHL F3 - rework work file location logic
2005-08-24 SHL F3 - delete mime
2005-11-12 SHL F3 - Avoid missing header head
2007-11-29 SHL F3 - Correct boundery handling
2008-06-03 SHL F13 - Sync with newsutil
2008-09-07 SHL Send messages to STDERR
2008-11-14 SHL Drop fNT logic
2008-11-24 SHL Correct seamonkey!.exe start
2010-01-11 SHL F3 - better html detect
2010-04-20 SHL F1 - Use download dir
2010-09-01 SHL F3 - Support mutlipart-related
2011-10-12 SHL F3 - Warn if no html body
2012-04-15 SHL F3 - Comments

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call SetLocal

if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  call SysLoadFuncs
end

env = 'OS2ENVIRONMENT'			/* Allow access to environment */

/* USER SELECTABLE OPTIONS */

/* if set to 0, Ctrl-F1 will NOT attempt to load viewer */
EnableMimeViewers = 0

BitmapViewer = 'ib.exe'
AviViewer = 'vb.exe'
WavPlayer = 'ab.exe'
INFViewer = 'view.exe'
MPGViewer = 'pmmpeg.exe'

HTML_File = 'mail.htm'

/**********************************************************************/
/**   Parameter Section - Message Information Passed from MR/2 ICE   **/
/**********************************************************************/
/* The section below is COMMENTED OUT to save resources.  If you      */
/* wish to use one or more of these variables, just uncomment them    */
/**********************************************************************/
/*

Mail and news

Account     = value("MR2I.ACCOUNT",,env)
Browser     = value("MR2I.BROWSER",,env)
Column      = value("MR2I.CURRENTCOLUMN",,env)
CurrentWord = value("MR2I.CURRENTWORD",,env)
Date        = value("MR2I.DATE",,env)
Editor = value("MR2I.EDITOR",,env)
FTPClient   = value("MR2I.FTPCLIENT",,env)
From        = value("MR2I.FROM",,env)
InReplyTo   = value("MR2I.IN-REPLY-TO",,env)
Line        = value("MR2I.CURRENTLINE",,env)
MarkedBlock = value("MR2I.CURRENTBLOCK",,env)
MessageID   = value("MR2I.MESSAGE-ID",,env)
ReplyTo     = value("MR2I.REPLYTO",,env)
SerialNumber= value("MR2I.SERIALNUMBER",,env)
Subject     = value("MR2I.SUBJECT",,env)
To          = value("MR2I.TO",,env)
Version     = value("MR2I.VERSION",,env)

News Only

FirstReference = value("MR2I.FIRSTREFERENCE",,env)
LastReference  = value("MR2I.LASTREFERENCE",,env)
NewsGroups      = value("MR2I.NEWSGROUPS",,env)
References      = value("MR2I.REFERENCES",,env)
*/

Editor = value("MR2I.EDITOR",,env)
if 0 then Editor = 'd:\cpe\bin\cpe.exe'	/* 2012-04-15 SHL Localize */
Browser = value("MR2I.BROWSER",,env)
/* In case running from command line */
if 0 then if Browser == '' then Browser = 'd:\cmd\mymozilla.cmd' /* 2012-04-15 SHL Localize */

/* NOTE that if markedBlock = "@rexx$txt.tmp", then the block was
   too big to pass in the environment, and it was instead saved to
   the file "rexx@txt.tmp".
*/

/**********************************************************************/

/* Run through some standard setup - fixme to be gone someday */

'@echo off'	/* turn off display of OS/2 commands */
crlf='0d0a'x	/* Set Carriage Return with LineFeed */

parse value SysCurPos() with row col	/* Get current cursor position */

esc  = '1b'x    /* ESC character */
P = esc'[35m'   /* ANSI.SYS-control for purple foreground */
r = esc'[31m'   /* ANSI.SYS-control for red foreground */
g = esc'[32m'   /* ANSI.SYS-control for green foreground */
y = esc'[33m'   /* ANSI.SYS-control for yellow foreground */
cy = esc'[36m'  /* ANSI.SYS-control for cyan foreground */
wh = esc'[0m'   /* ANSI.SYS-control for resetting attributes to normal */
bl = esc'[5m'   /* ANSI.SYS-control for blinking */
hl = esc'[1m'   /* ANSI.SYS-control for highlight */

Main:

  cmdLine = translate(arg(1))	/* Snag 1st command line arg - fixme someday */
  /* FKey is numeric; file name is fully qualified */
  parse value cmdLine with FKey FileName

  select

  when FKey = 1 then do
    /* Semi-smart external unpack interface, SHL */
    oldDir = directory()
    if IsDir('j:\downloads') \= '' then
      call directory 'j:\downloads'
    else if IsDir('d:\downloads') \= '' then
      call directory 'd:\downloads'
    else do
      call lineout 'STDERR', 'Can not find \downloads dir'
      call lineout 'STDERR'
      call Beep 200, 300
      pull ans
      exit
    end

    'echo on'
    signal off Error
    'grep -i -s -q "^MIME" <' FileName
    if RC = 0 then
      'munpack' FileName '>&2'
    else do
      'grep -s -q begin <' FileName
      if RC = 0 then
	'start /wait pmuue -d' FileName
      else do
	'grep -s -q xbin <' FileName
	if RC = 0 then
	  'xbin' FileName '>&2'
	else do
	  call lineout 'STDERR', 'Don''t know how to decode' FileName
	  call lineout 'STDERR'
	  pull ans
	  RC = 0
	end
      end
    end
    signal on Error

    if RC \= 0 then do
      call lineout 'STDERR', 'Decoder returned' RC
      call lineout 'STDERR'
      call Beep 200, 300
      pull ans
    end
    else
      call SysSleep 3

    '@echo off'

    if (EnableMimeViewers = 1) then do
      /* Do simple decode of file content to determine viewer type */
      do while Lines(FileName) > 0
	InRec = LineIn(FileName)
	If pos('FILENAME="',translate(InRec)) > 0 then do
	  do while left(translate(InRec),10) <> 'FILENAME="'
	     InRec = strip(InRec,'L',left(InRec,1))
	  end
	  parse value InRec with file '"' DFile '"'
	  DFile = translate(DFile)
	  parse value DFile with Name '.' Ext
	  if ext = 'TXT' | ext = 'DOC' | ext = 'ME' then
	    'start 'Editor' 'dfile
	  if ext = 'GIF' | ext = 'JPG' | ext = 'BMP' | ext = 'TIF' then
	    'start 'BitmapViewer' 'dfile
	  if ext = 'MPG' then 'start 'MPGViewer' 'dfile
	  if ext = 'AVI' then 'start 'AviViewer' 'dfile
	  if ext = 'WAV' then 'start 'WavPlayer' 'dfile
	  if ext = 'INF' then 'start 'INFViewer' 'dfile
	end
      end
      call stream FileName, 'C', 'CLOSE'
    end
    call directory oldDir
  end

  when FKey = 2 then do
    /* Run editor */
    'start' Editor FileName
  end

  when FKey = 3 then do
    /* View as HTML without message header */
    /* Put work file in TMP directory or current directory */
    tmpDir = value('TMP',,env)
    if tmpDir == '' then
      tmpDir = directory()
    if right(tmpDir, 1) \= '\' then
      tmpDir = tmpDir'\'

    HTML_File = tmpDir || HTML_File
    call SysFileDelete HTML_File

    /* Strip header, clean up QP */
    state = 'msghdr'		/* boundary mimehdr mimebody msgbody */
    nextstate = 'msgbody'
    isQP = 0
    needNL = 1
    isMIME = 0
    haveHTMLBody = 0
    boundary = ''
    drop header

    do while lines(FileName) > 0

      iline = linein(FileName)

      /* Linein will strip reasonable line endings
       * Strip oddballs ourself
       */
      iline = strip(iline, 'T', x2c('0d'))

      if state == 'msghdr' | state == 'mimehdr' then do

	/* Need lookahead to fold whitespace */
	if symbol('header') \== 'VAR' then do
	  header = iline		/* Capture 1st line of header */
	  iterate
	end
	else if length(header) \= 0 then do
	  /* Check for continuation */
	  i = verify(iline, ' 'x2c('09'), 'N')
	  if i > 1 then do
	    /* Has leading whitespace - must be continued header line */
	    /* Fold leading whitespace and append to partial header */
	    header = header substr(iline, i)
	    iterate
	  end
	end

      end /* if ...hdr */

      if state == 'msghdr' then do

	if length(header) = 0 then
	  state = ''			/* Blank line ends header */
	else do
	  /* Be case-insensitive */
	  headerU = translate(header)
	  if pos('CONTENT-TRANSFER-ENCODING: QUOTED-PRINTABLE', headerU) = 1 then
	    isQP = 1
	  else if pos('MIME-VERSION:', headerU) = 1 then
	    isMIME = 1
	  else if isMIME &,
		    (pos('CONTENT-TYPE: MULTIPART/MIXED;', headerU) = 1 |,
		     pos('CONTENT-TYPE: MULTIPART/ALTERNATIVE;', headerU) = 1 |,
		     pos('CONTENT-TYPE: MULTIPART/RELATED;', headerU) = 1) then do
	    s = 'BOUNDARY="'
	    i = pos(s, headerU)
	    if i > 0 then do
	      boundary = substr(header, i + length(s))
	      i = pos('"', boundary)
	      if i > 0 then do
		boundary = left(boundary, i - 1)
		nextstate = 'boundary'
	      end
	    end
	  end

	  header = iline		/* Capture 1st line of header */
	end

      end /* if msghdr */

      if state == 'mimehdr' then do

	if length(header) = 0 then
	  state = ''			/* Blank line ends header */
	else do
	  /* be case-insensitive */
	  headerU = translate(header)
	  if pos('CONTENT-TRANSFER-ENCODING: QUOTED-PRINTABLE', headerU) = 1 then
	    isQP = 1
	  else if pos('CONTENT-TYPE:', headerU) = 1 & pos('TEXT/HTML', headerU) > 0 then do
	    nextstate = 'mimebody'
	    haveHTMLBody = 1		/* Some generators omit <html> */
	  end
	  header = iline		/* Capture 1st line of next header */
	end

      end /* if mimehdr */

      if state == '' then do
	if nextstate \= '' then do
	  state = nextstate
	  nextstate = ''
	end
	else
	  state = 'boundary'		/* Must be MIME section to be skipped */
	drop header
      end

      if state == 'boundary' then do
	l = length(boundary) + 2
	if left(iline, l) == '--'boundary then do
	  if left(iline, l + 2) == '--'boundary'--' then
	    leave			/* End marker found */
	  state = 'mimehdr'
	  iterate
	end
      end

      if state == 'mimebody' then do
	l = length(boundary) + 2
	if left(iline, l + 2) == '--'boundary'--' then
	  leave				/* End marker found */
	if left(iline, l) == '--'boundary then do
	  state = 'mimehdr'
	end
      end

      if state \== 'mimebody' & state \== 'msgbody' then
	iterate

      /* mimebody or msgbody */
      if isQP then do
	l = length(iline)
	i = pos('=', iline)
	do while i > 0
	  if i = l then do
	    iline = left(iline, l - 1)	/* Chop trailing = */
	    needNL = 0
	  end
	  else do
	    x = substr(iline, i + 1, 2)
	    if datatype(x, 'X') then do
	      iline = left(iline, i - 1) || x2c(x) || substr(iline, i + 3)
	      l = length(iline)
	    end
	  end
	  i = pos('=', iline, i + 1)
	end
      end /* if QP */

      if \ haveHTMLBody then do
	s = translate(iline)
	i = pos('<HTML', s)
	j = pos('>', s, i + 5)
	if i > 0 & j > i then
	  haveHTMLBody = 1
      end /* haveHTMLBody */

      if needNL then
	call lineout HTML_File, iline
      else do
	call charout HTML_File, iline
	needNL = 1
      end

    end /* while */

    call stream FileName, 'C' ,'CLOSE'
    call stream HTML_File, 'C', 'CLOSE'

    if \ haveHTMLBody then do
      call lineout 'STDERR', ''
      call lineout 'STDERR', FileName 'does not contain an html body'
      call lineout 'STDERR', 'Press any key to continue...'
      call lineout 'STDERR', ''
      call lineout 'STDERR'
      call SysGetKey 'NOECHO'
      exit
    end
    else if pos('.CMD', translate(Browser)) > 0 then
      Browser 'file:///'HTML_File '>&2'
    else
      'cmd /c start' Browser 'file:///'HTML_File '>&2'	/* 2008-11-24 SHL */

  end /* FKey = 3 */

  when FKey = 4 then do
    /* Simple PGP interface, SHL */
    oldDir = directory()
    /* Put work file in TMP directory or current directory */
    tmpDir = value('TMP',,env)
    if tmpDir \= '' then
      call directory tmpDir
    MsgInFile = 'TMPPGP.MSG'
    MsgOutFile = 'TMPPGP'
    'copy' FileName MsgInFile
    call SysFileDelete(MsgOutFile)
    signal off Error
    'pgp' MsgInFile
    signal on Error
    'pause'
    'list' MsgOutFile MsgInFile
    ComSpec = value('COMSPEC',,env)
    ComSpec '/k echo Message names are' MsgInFile MsgOutFile'.  Type exit to quit.'
    call directory oldDir
  end

  when FKey = 5 then do
    /* Move message to inbox, assume in standard message folder
       fixme to work from trash someday
     */
    iSlash = lastpos('\', FileName)
    /* Ignore badly formed file names */
    if iSlash \= 0 then do
      sNewFile = left(FileName, iSlash) || '..\' || substr(FileName, iSlash + 1)
      do 100
	s = stream(sNewFile, 'C', 'QUERY EXISTS')
	if s = '' then
	  leave
	/* If have hexname.ext, try for better name */
	node = substr(sNewFile, iSlash + 4)
	i = pos('.', node)
	if i = 0 then
	  leave
	ext = substr(node, i)
	node = left(node, i - 1)
	l = length(node)
	if \ datatype(node, 'X') then
	  leave
	numeric digits 12
	node = d2x(x2d(node) + 1, l)
	sNewFile = left(FileName, iSlash) || '..\' || node || ext
      end /* do 100 */
      if s \= '' then do
	call lineout 'STDERR', sNewFile 'exists'
	call lineout 'STDERR'
	call SysSleep 2
      end
      else do
	call lineout 'STDERR', ''
	call lineout 'STDERR', ''
	call charout 'STDOUT',  'Move '
	'move /p' FileName sNewFile
	s = stream(sNewFile, 'C', 'QUERY EXISTS')
	if s \= '' then
	  call lineout 'STDERR', 'Please reindex Inbox'
	call lineout 'STDERR'
	call SysSleep 1
      end
    end
  end /* F5 */

  when FKey = 6 then do
    /* Open shell */
    value("COMSPEC",,env)
  end

  when FKey = 7 then do
    /* Show filename and passed variables */
    call lineout 'STDERR', ''
    call lineout 'STDERR', 'directory:' directory()
    call lineout 'STDERR', 'filename:' FileName
    call lineout 'STDERR', 'MR2I.SUBJECT:' value("MR2I.SUBJECT",,env)
    call lineout 'STDERR', 'MR2I.REPLYTO:' value("MR2I.REPLYTO",,env)
    call lineout 'STDERR', 'MR2I.TO:' value("MR2I.TO",,env)
    call lineout 'STDERR', 'MR2I.FROM:' value("MR2I.FROM",,env)
    call lineout 'STDERR', 'MR2I.DATE:' value("MR2I.DATE",,env)
    call lineout 'STDERR', 'MR2I.MESSAGE-ID:' value("MR2I.MESSAGE-ID",,env)
    call lineout 'STDERR', 'MR2I.IN-REPLY-TO:' value("MR2I.IN-REPLY-TO",,env)
    call lineout 'STDERR', 'MR2I.CURRENTLINE:' value("MR2I.CURRENTLINE",,env)
    call lineout 'STDERR', 'MR2I.CURRENTCOLUMN:' value("MR2I.CURRENTCOLUMN",,env)
    call lineout 'STDERR', 'MR2I.CURRENTWORD:' value("MR2I.CURRENTWORD",,env)

    call lineout 'STDERR', 'MR2I.EDITOR:' value("MR2I.EDITOR",,env)
    call lineout 'STDERR', 'MR2I.BROWSER:' value("MR2I.BROWSER",,env)
    call lineout 'STDERR', 'MR2I.FTPCLIENT:' value("MR2I.FTPCLIENT",,env)
    call lineout 'STDERR', 'MR2I.CURRENTWORD:' value("MR2I.CURRENTWORD",,env)
    call lineout 'STDERR', 'MR2I.ACCOUNT:' value("MR2I.ACCOUNT",,env)
    call lineout 'STDERR', 'MR2I.VERSION:' value("MR2I.VERSION",,env)
    call lineout 'STDERR', 'MR2I.SERIALNUMBER:' value("MR2I.SERIALNUMBER",,env)

    call lineout 'STDERR', ''
    call lineout 'STDERR'
    call SysGetKey 'NOECHO'
  end

  when FKey = 8 then do
    nop					/* Unused */
  end

  /* Ctrl-F9 owned by PM - can not use here */

  when FKey = 10 then do
    nop					/* Unused */
  end

  /* Ctrl-F11 owned by PM - can not use here */

  when FKey = 12 then do
    /* Display help to stderr - log captures stdout */
    call lineout 'STDERR', ''
    call lineout 'STDERR', 'Msgutil Ctrl-Function Key Reference'
    call lineout 'STDERR', ''
    call lineout 'STDERR', '  1: Detach files using external utilities, SHL'
    call lineout 'STDERR', '  2: Edit the file with' Editor
    call lineout 'STDERR', '  3: View embedded HTML via Browser, SHL'
    call lineout 'STDERR', '  4: Simple PGP interface, SHL'
    call lineout 'STDERR', '  5: Move to Inbox, SHL'
    call lineout 'STDERR', '  6: Open shell'
    call lineout 'STDERR', '  7: List ICE environment, SHL'
    call lineout 'STDERR', ' 12: This cheat sheet, SHL'
    call lineout 'STDERR', ''
    call lineout 'STDERR'

    /* Select from menu or quit */
    FKey = SysGetKey('NOECHO')
    if datatype(FKey, 'W') then do
      if FKey >= 1 & FKey <= 7 then do
	parse source . . thisCmd
	thisCmd FKey FileName
      end
    end
  end /* F12 */

  otherwise
      call lineout 'STDERR', 'Invalid Function Key passed by MR/2: 'FKey
      call lineout 'STDERR'

  end /* select */

  exit

/* end Main */

/*=== Error() Report ERROR, FAILURE etc. and exit ===*/

Error:
  say
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' thisCmd
  if 'CONDITION'('D') \= '' then say 'REXX reason =' 'CONDITION'('D')'.'
  if 'CONDITION'('C') == 'SYNTAX' & 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error =' RC '-' 'ERRORTEXT'(RC)'.'
  else if 'SYMBOL'('RC') == 'VAR' then
    say 'RC =' RC'.'
  say 'Source =' 'SOURCELINE'(SIGL)
  if 'CONDITION'('I') \== 'CALL' | 'CONDITION'('C') == 'NOVALUE' | 'CONDITION'('C') == 'SYNTAX' then do
    trace '?A'
    say 'Enter REXX commands to debug failure.  Press enter to exit script.'
    call 'SYSSLEEP' 2
    if 'SYMBOL'('RC') == 'VAR' then exit RC; else exit 255
  end
  return

/* end Error */

/*=== Halt() Report HALT condition and exit ===*/

Halt:
  parse source . . thisCmd
  call lineout 'STDERR', ''
  call lineout 'STDERR', 'CONDITION'('C') 'signaled at' SIGL 'of' thisCmd
  call lineout 'STDERR', 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
  call lineout 'STDERR', 'Exiting'
  exit 'CONDITION'('C')

/* end Halt */

/*=== IsDir(dirName) return normalized directory name with trailing \ or empty string ===*/

IsDir: procedure expose Gbl.

  parse arg Dir

  if Dir \= '' then do
    if \ IsDrvRdy(Dir) then
      Dir = ''
    else do
      oldDir = directory()
      Dir = directory(Dir)
      call directory(oldDir)
      if Dir \== '' & right(Dir, 1) \= '\' then
	Dir = Dir'\'
    end
  end

  return Dir

/* end IsDir */

/*=== IsDrvRdy(driveSpec) return 1 if ready, accepts pathnames ===*/

IsDrvRdy: procedure expose Gbl.

  Drv = arg(1)

  if length(Drv) < 2 | substr(Drv, 2, 1) \= ':' then
    f = 1				/* If no drive spec, assume ready */
  else do
    Drv = translate(substr(Drv, 1, 1))
    /* If not a drive letter, say not ready */
    if Drv < 'A' | Drv > 'Z' then
      f = 0				/* If bad drive spec, not ready */
    else do
      Info = SysDriveInfo(Drv)
      f = Info \= ''			/* If not blank, ready */
    end
  end

  return f

/* end IsDrvRdy */

/* The end */
