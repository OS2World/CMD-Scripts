/*********************************************************************/
/* IceBerg IRC REXX Command Script for GTirc.  V 2.00  25 Feb 1996   */
/*                  Copyright 1996 - Stephen Berg                    */
/*********************************************************************/
/* This file sets up all the commands that I have created, or stolen */
/* from other scripts and changed to work with REXX.  It works in    */
/* conjunction with the IBERGMSG.CMD script to customize your IRC    */
/* client, add functionality and bring GTirc to a point where it more*/
/* than competes with any other IRC client out there for OS/2.       */
/*********************************************************************/
/* This pair of REXX scripts and the ICESTART.TXT startup file are   */
/* my creation and I retain all copyrights to the files.  They are   */
/* however freely distributable, but I do ask that you email if you  */
/* are using them.  sberg@southwind.com                              */
/*********************************************************************/

Parse Upper Arg Win Us Verb Parm1 Parms
Parse Arg xWin xUs xVerb xParm1 xParms
Parse Arg yWin yUs yVerb yParm1 yParm2 yParms

Pool = 'OS2ENVIRONMENT'

ErStr1 = '+++ Syntax +++++'
ErStr2 = '++++ Error +++++'
ErStr3 = '++++++++++++++++'
titlline = '+------------------------IceBerg V 2.00------------------------+'

/*********************************************************************/
/* We implement an /iceberg command to set and check global rexx     */
/* variables for the scripts to examine for various purposes.        */
/*********************************************************************/

if (Verb = '/ICEBERG') then do
 	if (Parm1 <> '') then do
		if (Parms <> '') then do
			VALUE(Parm1,Parms,Pool)
			ircrexxdisplay(Parm1 'Set to: ' || Parms || '.', win)
			Return ''
		end
		else do
			TempStr = Value(Parm1,,Pool)
			IrcRexxDisplay(Parm1 'Is currently: ' || TempStr || '.', win)
			Return ''
		end
	end
	else do
		IrcRexxDisplay("Once I figure out a way to get and display all",Win)
		IrcRexxDisplay("the defined variables in the Pool.  I'll add",Win)
		IrcRexxDisplay("it in here.",Win)
		Return ''
	end
end

/*********************************************************************/
/* The /WHOM command simply executes a /VERSION and /USERINFO on the */
/* specified nickname.                                               */
/*                            Syntax:  /WHOM nickname                */
/*********************************************************************/

if (Verb = '/WHOM') then do
   if (Parm1 <> '') then do
      OutStr = "/VERSION "  Parm1
      IrcRexxCommand(OutStr,Win)
      OutStr = "/USERINFO " Parm1
      IrcRexxCommand(OutStr,Win)
   end

   else do
      IrcRexxDisplay(ErStr1 "You must provide a users nick that",Win)
      IrcRexxDisplay(ErStr2 "you wish to get info about",Win)
   end

   Return ""
end

/*  Check a users idle time  */

if (Verb = '/IDLE') then do
   if (Parm1 <> '') then do
      OutStr = "/whois"  Parm1 Parm1
      IrcRexxCommand(OutStr,Win)
   end

   else do
      IrcRexxDisplay(ErStr1 "You must provide a users nick that",Win)
      IrcRexxDisplay(ErStr2 "you wish to get idle info about",Win)
   end

   Return ""
end


/*********************************************************************/
/* Help screens - on-line help for IceBerg                           */
/*********************************************************************/

if (Verb = '/ICEHELP') then do
	IrcRexxDisplay(titlline,Win)
	IrcRexxDisplay("                 +------Icehelp Page One------+", Win)
	IrcRexxDisplay('/iceberg <variable> [Value] - To set or view a variable',Win)
	IrcRexxDisplay('/whom <nick> -                Get Version and Userinfo for nick',Win)
	IrcRexxDisplay('/idle <nick> -                Get idle time for nick',Win)
	IrcRexxDisplay('/icehelp -                    This help display',Win)
	IrcRexxDisplay('/icehelp2 -                   Page 2 of the help display',Win)
	IrcRexxDisplay('/icehelp3 -                   Page 3 of the help display',Win)
	IrcRexxDisplay('/msghlp -                     Help display for the message logging functions',Win)
	IrcRexxDisplay('/dw <hostname|IP address> -   /who on the hostname/IP address',Win)
	IrcRexxDisplay('/wall <#channel> <text> -     /msg all channel occupants with text',Win)
	IrcRexxDisplay('/wallop <#channel> <text> -   /msg all channel ops with text',Win)
	IrcRexxDisplay('/xdccadv -                    advertise your available XDCC files to the',Win)
	IrcRexxDisplay("                              current channel",Win)
	IrcRexxDisplay('/cstat <#channel> -           Get statistics for #channel',Win)
	IrcRexxDisplay('/crypt <text> -               Send text with encryption to current channel',Win)
	IrcRexxDisplay('/revsay <text> -              Reverse text and send to channel',Win)
	IrcRexxDisplay('/revmsg <nick> <text> -       Reverse text and msg to nick',Win)
	IrcRexxDisplay('/revme <text> -               Reverse text and say as a /me',Win)
	IrcRexxDisplay(titlline,Win)
Return ''
end

if (Verb = '/ICEHELP2') then do
	IrcRexxDisplay(titlline,Win)
	IrcRexxDisplay("                 +------Icehelp Page Two------+", Win)
	IrcRexxDisplay('/nsl <hostname|IP adress> -   Do an OS/2 nslookup on <hostname> or <IP address>',Win)
	IrcRexxDisplay('/host <hostname|IP adress> -  Run OS/2s host command',Win)
	IrcRexxDisplay('/osping <hostname|IP adress>- Do an OS/2 ping on hostname or IP',Win)
	IrcRexxDisplay('/ossend <command> -           Run an OS/2 command and send to the channel',Win)
	IrcRexxDisplay('/osmsg <command> -            Run an OS/2 command and send as a msg to nick',Win)
	IrcRexxDisplay('/exec <command> -             Run an OS/2 command',Win)
	IrcRexxDisplay('/getservers -                 Get a new "servers.lst" listing',Win)
	IrcRexxDisplay('/findsplit -                  Find any split servers (see IBreadme.txt)',Win)
	IrcRexxDisplay('/addnew -                     Add any new servers found to "servers.lst"',Win)
	IrcRexxDisplay('/calc <text> -                get a calc for <text> from OS2Bot on #os/2',Win)
	IrcRexxDisplay('/phone <company name> -       get a phone # for <company name> from OS2Bot',Win)
	IrcRexxDisplay("                              on #os/2 (EFNet)",Win)
	IrcRexxDisplay(titlline,Win)
Return ''
end

   /* *** Normal IRC commands that I have shortened/enhanced *** */   

if (Verb = '/ICEHELP3') then do
	IrcRexxDisplay(titlline,Win)
	IrcRexxDisplay("                +------Icehelp Page Three------+", Win)
	IrcRexxDisplay('/k <nick> -                   kicks nick from the current channel',Win)
	IrcRexxDisplay('/kb <#channel> <nick> -       bans and then kicks nick from the current',Win)
	IrcRexxDisplay("                              channel, a reason may be supplied.",Win)
	IrcRexxDisplay('/j <#channel> -               /JOIN #channel',Win)
	IrcRexxDisplay('/q <nick> -                   start a private query with <nick>',Win)
	IrcRexxDisplay('/lv [#channel] -              Leave the current or specified channel',Win)
	IrcRexxDisplay('/not <nick|#channel> <text> - /NOTICE the nick or channel with text',Win)
	IrcRexxDisplay("/t [text] -                   Display the current channel's topic or",Win)
	IrcRexxDisplay("                              change it to text",Win)
	IrcRexxDisplay('/wi <nick> -                  /WHOIS on nick',Win)
	IrcRexxDisplay('/ww <nick> -                  /WHOWAS on nick',Win)
	IrcRexxDisplay('/inv <nick> -                 Invite nick to current channel',Win)
	IrcRexxDisplay("/cm [[+|-] modes] -           Change current channel's mode setting",Win)
	IrcRexxDisplay('/um [[+|-] modes] -           Change users mode setting',Win)
	IrcRexxDisplay(titlline,Win)
Return ''
end
        /* *** Message logging related commands *** */

if (Verb = '/MSGHELP') then do
	IrcRexxDisplay(titlline,Win)
	IrcRexxDisplay("                   +------Message Help------+", Win)
	IrcRexxDisplay('/reset -                      Reset the message logger (Please Refer to readme.txt)',Win)
	IrcRexxDisplay('/play -                       Displays the messages stored',Win)
	IrcRexxDisplay('/playlong -                   Displays the messages stored with full ID of sender',Win)
	IrcRexxDisplay('/msgchk -                     Display the current number of messages stored',Win)
	IrcRexxDisplay('/gone [awaymsg] -             Turn on the message logger and set the away',Win)
	IrcRexxDisplay('                              flag using the default awaymsg unless',Win)
	IrcRexxDisplay('                              one is specified',Win)
	IrcRexxDisplay('/back -                       Turn off the message logger, unset the away flag',Win)
	IrcRexxDisplay('                              and display any messages saved',Win)
	IrcRexxDisplay('/awaymsg <text> -             Change the default awaymsg (not permanent, use the ',Win)
	IrcRexxDisplay('                              Startup Command and IceStart.txt file to make a',Win)
	IrcRexxDisplay('                              permanent default awaymsg',Win)
	IrcRexxDisplay(titlline,Win)
Return ''
end

/* Domain who  */

if (Verb = '/DW') then do
     if (Parm1 <> '') then do
	OutStr = "/who *" || xParm1 || "*"
	IrcRexxCommand(OutStr,Win)
     end

     else do
      IrcRexxDisplay(ErStr1 'You must provide a domain that you',Win)
      IrcRexxDisplay(ErStr2 'wish to get user info from',Win)
     end

     Return ""
end

/*********************************************************************/
/* Wall (msg all channel members or ops) - Abuse this one and you'll */
/*                    probably get a swift boot.                     */
/*********************************************************************/

if (Verb = '/WALL') then do
	if (Parm1 <> '') then do
		Value('walling','ON',Pool)
		Value('wallmsg',xParms,Pool)
		IrcRexxSend("NAMES" xParm1,Win)
		Return
	end
	else do
		IrcRexxDisplay(erstr1 'You must provide a target channel to',Win)
		IrcRexxDisplay(erstr2 'get all the nicks that you want to msg',Win)
		IrcRexxDisplay(erstr3 'and the message to be sent',Win)
		Return
	end
	Return
end

/* Wall (msg all channel operators) - Abuse this  */
/* one and you'll probably get a swift boot.      */

if (Verb = '/WALLOP') then do
	if (Parm1 <> '') then do
		Value('walloping','ON',Pool)
		Value('wallmsg',xParms,Pool)
		IrcRexxSend("NAMES" xParm1,Win)
		Return
	end
	else do
		IrcRexxDisplay(erstr1 'You must provide a target channel to',Win)
		IrcRexxDisplay(erstr2 'get all the ops-nicks that you want to',Win)
		IrcRexxDisplay(erstr3 'msg and the message to be sent',Win)
		Return
	end
end

/*  Advertise files available via XDCC                               */
if (Verb = '/XDCCADV') then do
	FileList = "filelist.txt"
	LineNo=0
	IrcRexxCommand("/me XDCC File offerings:", Win)
	do while Lines(FileList)
		Fileline = LineIn(FileList)
		if Fileline = "" then leave
		LineNo = LineNo + 1
		Parse Var Fileline Filename Filedesc
		FileName2 = FileSpec("N",FileName)
		FileSize = Stream(FileName,"C","QUERY SIZE")
		IrcRexxCommand("/me " LineNo || ":" FileDesc "|" Filename2 "[" || FileSize || " bytes]", Win)
	End
	IrcRexxCommand("/me type: /msg" Us "Send #  where '#' is the file number.", WIn)
	Return ""
end

/*********************************************************************/
/* Get and display statistics about a particular channel             */
/*********************************************************************/

if (Verb = '/CSTAT') then do
	if (Parm1 <> '') then do
		Value('cstating','ON',Pool)
		IrcRexxSend('NAMES' xParm1,Win)
		IrcRexxSend('MODE' xParm1,Win)
		IrcRexxSend('LIST' xParm1,Win)
	end
	else do
		Value('cstating','OFF',Pool)
		IrcRexxDisplay(ErStr1 "You must provide a channel that you wish",Win)
		IrcRexxDisplay(ErStr2 "to retreive stats for.",Win)
	end
	Return ""
end

/*********************************************************************/
/*        Normal IRC commands shortened for ease of use             */
/*********************************************************************/

if (Verb = '/K') then do
	if (Parm1 <> '') then do
		if (xParms <> '') then do
			IrcRexxCommand('/kick' xParm1 xParms
			Return ''
		end
		else do
			IrcRexxCommand('/kick' xParm1 'IceBerg Kick!', Win)
			Return ''
		end
	end
	else do
		IrcRexxDisplay(ErStr3 'You must specify a nick to be kicked', Win)
		Return ''
	end
end

/*********************************************************************/
/* Kick/Ban start routine, the rest is handled in ibergmsg.cmd       */
/*********************************************************************/

if (Verb = '/KB') then do
	if yParm1 <> '' then do
		if yParm2 <> '' then do
			Value('kbanning', 'ON', Pool)
			Value('kbanchan', yParm1, Pool)
			Parse Upper Var yParm2 Nick
			Value('kbannick', Nick, Pool)
			Value('kbanreason', yParms, Pool)
			IrcRexxCommand('/userhost' yParm2, Win)
			Return ''
		end
		else do
			IrcRexxDisplay(erstr1 'You must provide a channel and a nick', Win)
			IrcRexxDisplay(erstr2 'for the kick ban command', Win)
			IrcRexxDisplay(erstr3 'A reason may be provided if you wish.', Win)
			IrcRexxDisplay(erstr3 "eg:  /kb #os/2 os2bot I'm sick of your calcs!", Win)
			Return ''
		end
	end
	else do
		IrcRexxDisplay(erstr1 'You must provide a channel and a nick', Win)
		IrcRexxDisplay(erstr2 'for the kick ban command', Win)
		IrcRexxDisplay(erstr3 'A reason may be provided if you wish.', Win)
		IrcRexxDisplay(erstr3 "eg:  /kb #os/2 os2bot I'm sick of your calcs!", Win)
		Return ''
	end
end

if (Verb = '/J') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/join' xParm1,Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr3 'You must specify a channel name with /j',Win)
		Return ''
	end
end

if (Verb = '/Q') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/query' xParm1, Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr1 'You must specify a user that you wish to', Win)
		IrcRexxDisplay(ErStr2 'start a private query with', Win)
		Return ''
	end
end

if (Verb = '/LV') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/leave' Parm1,Win)
		Return ''
	end
	else do
		IrcRexxCommand('/leave',Win)
		Return ''
	end
end

/* this makes up for an unsupported /NOTICE command in GTirc */

if (Verb = '/NOT') then do 
	if (Parm1 <> '') then do
		OutStr = "NOTICE" xParm1 ":" || xParms
		IrcRexxSend(OutStr,Win)
		IrcRexxDisplay("+" || xParm1 || "+" xParms, Win)
	end
	else do
		IrcRexxDisplay(ErStr1, 'You must provide a nick or channel',Win)
		IrcRexxDisplay(ErStr2, 'and some text to be sent to that',Win)
		IrcRexxDisplay(ErStr3, 'nick or channel as a notice',Win)
	end
	Return ""
end

if (Verb = '/T') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/topic' xParm1 xParms,Win)
		Return ''
	end
	else do
		IrcRexxCommand('/topic',Win)
		Return ''
	end
end

if (Verb = '/WI') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/whois' xParm1,Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr3 'You must specify a nick with /wi',Win)
		Return ''
	end
end

if (Verb = '/WW') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/whowas' xParm1,Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr3 'You must specify a nick with /ww',Win)
		Return ''
	end
end

if (Verb = '/INV') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/invite' xParm1,Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr3 'You must specify a nick with with /inv',Win)
		Return ''
	end
end

if (Verb = '/CM') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/mode *' xParm1 xParms,Win)
		Return ''
	end
	else do
		IrcRexxCommand('/mode *',Win)
		Return ''
	end
end

if (Verb = '/UM') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/mode' Us xParm1,Win)
		Return ''
	end
	else do
		IrcRexxDisplay('A mode change must be specified with /um',Win)
		Return ''
	end
end

/* End of short versions of normal commands  */


/*********************************************************************/
/*               Beginning of the message logger functions           */
/*                  I got this code from Wease on EFNet              */
/*********************************************************************/

/*    Simple command to reset my message queue   */

if (Verb = '/RESET') then do
hdrline = '+------------------IceBerg V 2.00 Message Log------------------+'
	IrcRexxCommand('/exec del messages.log', Win)
	LineOut(messages.log, hdrline, 1)
	LineOut(messages.log)
	IrcRexxDisplay('Message log file reset', Win)
   Return ""
end

/* View the Message Queue */

if (Verb = '/PLAY') then do
msglog = Value(msglog,,Pool)
counter = 0
hdrline = '+------------------IceBerg V 2.00 Message Log------------------+'
	if (msglog \= 'ON') then ircrexxdisplay("Message Log DISABLED", Win)	
	Do While Lines(messages.log)
		message = LineIn(messages.log)
		Parse Var message nick id msg
		if nick = '+------------------IceBerg' then do
			IrcRexxDisplay(hdrline, Win)
		end
		else do
			counter = counter + 1
			IrcRexxDisplay(counter || ':' '*' || nick || '*'  msg, Win)
		end
	end
	ircrexxdisplay(titlline, win)
	Return ""
end

/* View the Message Queue with user@host info instead of just */
/* Nick for the from address                                  */

if (Verb = '/PLAYLONG') then do
msglog = Value(msglog,,Pool)
counter = 0
hdrline = '+------------------IceBerg V 2.00 Message Log------------------+'
	if (msglog \= 'ON') then ircrexxdisplay("Message Log DISABLED", Win)	
	Do While Lines(messages.log)
		message = LineIn(messages.log)
		Parse Var message nick id msg
		if nick = '+------------------IceBerg' then do
		IrcRexxDisplay(hdrline, Win)
		end
		else do
			counter = counter + 1
			IrcRexxDisplay(counter || ':' '*' || nick || '*' || '' id '' || msg, Win)
		end
	end
	ircrexxdisplay(titlline, win)
	Return ""
end


/* Check the number of messages in the buffer */
if (Verb = '/MSGCHK') then do
msglog = Value(msglog,,Pool)
counter = 0
	if (msglog \= 'ON') then ircrexxdisplay("Message Log DISABLED", Win)	
	Do While Lines(messages.log)
		message = LineIn(messages.log)
		Parse Var message nick id msg
		if nick = '+------------------IceBerg' then do
		end
		else do
			counter = counter + 1
		end
	end
	if (counter = 0) then IrcRexxDisplay('Currently there are no messages saved.', Win)
	if (counter = 1) then IrcRexxDisplay('1 message logged', Win)
	if (counter > 1) then IrcRexxDisplay(counter 'messages logged', Win)
	Return ''
end

if (Verb = '/GONE') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/away' xParm1 xParms,Win)
		IrcRexxCommand('/iceberg msglog on',Win)
		Return ''
	end
	else do
		awaymsg = Value(awaymsg,,Pool)
		IrcRexxCommand('/away' awaymsg,Win)
		IrcRexxCommand('/iceberg msglog on',Win)
		Return ''
	end
	Return ''
end

if (Verb = '/BACK') then do
	IrcRexxCommand('/iceberg msglog off',Win)
	IrcRexxCommand('/play',Win)
	IrcRexxCommand('/away',Win)
	Return ''
end

/*    End of the message logger functions  */

/*  Change the default away statement  */

if (Verb = '/AWAYMSG') then do
	if (Parm1 <> '') then do
		Value('awaymsg',xParm1 xParms,Pool)
		TempVar = Value('awaymsg',,Pool)
		IrcRexxDisplay('Away statement changed to:' TempVar,Win)
		Return ''
	end
	else do
		TempVar = Value('awaymsg',,Pool)
		IrcRexxDisplay('Current away statement is:' TempVar,Win)
		Return ''
	end
end

/* Encryption Routines */

if (Verb = '/CRYPT') then do
	if (xParm1 <> '') then do
		xice = "abcdefghijklmnopqrstuvwxyz1234567890,.-('"
		yice = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ )?@!#$*&=+\/"'
		icex = "Q2W* (J'K9aFs=df)gz7cE,mR/TltC+vb#yZu6UI@"
		icey = 'OHP!L.N4xM?qw"e3Gr5-A1SnD$B\YiX&o8pVhj0k'
		cryptin = xice || yice
		cryptout = icex || icey
		instr = xParm1 xParms 
		outstr = Translate(instr, cryptout, cryptin)
			IrcRexxCommand("#IB2.0#" outstr,Win)
	end
	else do
		IrcRexxDisplay(ErStr1 "You must provide some text to be sent to the",Win)
		IrcRexxDisplay(ErStr2 "current channel or query.",Win)
	end		
	Return ""
end

/* Reverse it! */

if (Verb = '/REVSAY') then do
     if (Parm1 <> '') then do
	OutStr = Reverse(xParm1 xParms)
	IrcRexxCommand(OutStr,Win)
     end

     else do
      IrcRexxDisplay(ErStr1 "You must provide a string of input",Win)
      IrcRexxDisplay(ErStr2 "to be reversed and then sent",Win)
     end
     Return ""
end

/* Reverse in /msg!!  */

if (Verb = '/REVMSG') then do
     if (Parm1 <> '') then do
	OutStr = "/msg" xParm1 Reverse(xParms)
	IrcRexxCommand(OutStr,Win)
     end

     else do
	IrcRexxDisplay(ErStr1, 'You must provide a nick and some text',Win)
	IrcRexxDisplay(ErStr2, 'to be sent to that nick',Win)
     end

     Return ""
end

/* Reverse in a /me!!  */

if (Verb = '/REVME') then do
     if (Parm1 <> '') then do
	OutStr = "/me" Reverse(xParm1 xParms)
	IrcRexxCommand(OutStr,Win)
     end

     else do
      IrcRexxDisplay(ErStr1 'You must provide a string of text that you',Win)
      IrcRexxDisplay(ErStr2 'wish sent as a /me command.',Win)
     end

     Return ""
end

/*********************************************************************/
/*                   OS/2 interface commands                         */
/*********************************************************************/

/* Host function (doing an NSLOOKUP (shortened to /nsl)) */

if (Verb = '/NSL') then do
   CMD = "C:\OS2\CMD.EXE"
   if (Parm1 <> '') then do
       ADDRESS CMD 'nslookup' xParm1 '| rxqueue'
       nr = queued()
       do i=1 to nr
          Parse pull line
          if line <> ' ' Then IrcRexxDisplay(line,Win)
       end
   end
   else do
      IrcRexxDisplay(ErStr1 "You must provide a hostname or IP",Win)
      IrcRexxDisplay(ErStr2 "address that you wish to look up.",Win)
   end

   Return ""
end

/* Host function (doing a HOST command) */
if (Verb = '/HOST') then do
   CMD = "C:\OS2\CMD.EXE"
   if (Parm1 <> '') then do
       ADDRESS CMD 'host' xParm1 '| rxqueue'
       nr = queued()
       do i=1 to nr
          Parse pull line
          if line <> ' ' Then IrcRexxDisplay(line,Win)
       end
   end
   else do
      IrcRexxDisplay(ErStr1 "You must provide a hostname or IP",Win)
      IrcRexxDisplay(ErStr2 "address that you wish to look up.",Win)
   end

   Return ""
end

/* OS ping function (doing an OS/2 ping) */
if (Verb = '/OSPING') then do
	CMD = "C:\OS2\CMD.EXE"
	if (Parm1 <> '') then do
		ADDRESS CMD 'ping' xParm1 '25 2 | rxqueue'
		nr = queued()
		do i=1 to nr
		Parse pull line
		if line <> ' ' Then IrcRexxDisplay(line,Win)
		end
	end
	else do
		IrcRexxDisplay(ErStr1 "You must provide a hostname or IP",Win)
		IrcRexxDisplay(ErStr2 "address that you wish to ping.",Win)
	end
	Return ""
end

/* OS command send function */
if (Verb = '/OSSEND') then do
	CMD = "C:\OS2\CMD.EXE"
	if (Parm1 <> '') then do
		ADDRESS CMD xParm1 xParms '| rxqueue'
		nr = queued()
		do i=1 to nr
			Parse pull line
			if line <> ' ' Then IrcRexxCommand('*OS/2*' line,Win)
		end
	end
	else do
		IrcRexxDisplay(ErStr1 "You must provide a command and any appropriate",Win)
		IrcRexxDisplay(ErStr2 "parameters that you wish to run.",Win)
	end
	Return ""
end

/* OS command send function */
if (Verb = '/OSMSG') then do
	CMD = "C:\OS2\CMD.EXE"
	if (Parm1 <> '') & (Parms <> '') then do
		ADDRESS CMD yParm2 yParms '| rxqueue'
		nr = queued()
		do i=1 to nr
			Parse pull line
			if line <> ' ' Then IrcRexxCommand('/msg' yParm1 line,Win)
		end
	end
	else do
		IrcRexxDisplay(ErStr1 "You must provide a command and any appropriate",Win)
		IrcRexxDisplay(ErStr2 "parameters that you wish to run.",Win)
	end
	Return ""
end

/* OS/2 execute function (doing an OS/2 command) */
if (Verb = '/EXEC') then do
	CMD = "C:\OS2\CMD.EXE"
	if (Parm1 <> '') then do
		ADDRESS CMD xParm1 xParms '| rxqueue'
		nr = queued()
		do i=1 to nr
			Parse pull line
			if line <> ' ' Then IrcRexxDisplay(line,Win)
		end
	end
	else do
		IrcRexxDisplay(ErStr1 "You must provide a command and any appropriate",Win)
		IrcRexxDisplay(ErStr2 "parameters that you wish to run.",Win)
	end
	Return ""
end

/*********************************************************************/
/* Split Finder routines - Now we get into some real functionality!  */
/* Some of these routines are called by other processes in these two */
/* scripts and aren't really for the user.                           */
/*********************************************************************/

if (Verb = '/GETSERVERS') then do
	Value('srvrget','ON',Pool)
	Value('srvrs.','',Pool)
	Value('srvrs.0','0',Pool)
	Value('cnt','0',Pool)
	IrcRexxDisplay('**** Getting list of active servers from the current server',Win)
	IrcRexxSend('LINKS',Win)
	IrcRexxDisplay('**** This may take a few moments, please be patient.',Win)
	Return
end

if (Verb = '/FINDSPLIT') then do
	Value('getcurr','ON',Pool)
	Value('currsvrs.','',Pool)
	Value('currsvrs.0','0',Pool)
	Value('currcnt','0',Pool)
	IrcRexxDisplay('**** Getting list of active servers from the current server',Win)
	IrcRexxSend('LINKS',Win)
	IrcRexxDisplay('**** This may take a few moments, please be patient.',Win)
	Return
end

if (Verb = '/WRITESVR') then do
	CALL library
	rc = SysFileDelete('servers.lst')
	LineOut('servers.lst', '#Begin_List#', 1)
	cnt = Value('cnt',,Pool)
	do s = 1 to cnt
		tempword = Value('srvrs.'s,,Pool)
		LineOut('servers.lst', tempword)
	end
	LineOut('servers.lst')
	IrcRexxDisplay(Value('cnt',,Pool) "Servers written to 'servers.lst'",Win)
	Return ''
end

if (Verb = '/WRITECURRSVR') then do
	CALL library
	rc = SysFileDelete('current.lst')
	LineOut('current.lst', '#Begin_List#', 1)
	cnt = Value('currcnt',,Pool)
	do s = 1 to cnt
		tempword = Value('currsvrs.'s,,Pool)
		LineOut('current.lst', tempword)
	end
	LineOut('current.lst')
	IrcRexxDisplay(Value('cnt',,Pool) "Servers written to 'current.lst'",Win)
	IrcRexxCommand('/SPLITTERS',Win)
	Return
end

if (Verb = '/SPLITTERS') then do
	IrcRexxDisplay('Looking for any split servers.',Win)
	Do While (Lines(servers.lst) = 1)
		tmpline = LineIn(servers.lst)
		if (SysFileSearch(tmpline, current.lst, 'aresult.') = 0) then do
			if (aresult.0 = 0) then do
				IrcRexxDisplay("IB: Currently Split:" tmpline "",Win) 
			end
		end
	end
	IrcRexxCommand('/ADDNEW',Win)
	Return
end

if (Verb = '/ADDNEW') then do
	IrcRexxDisplay('Looking for any new servers',Win)
	Do While (Lines(current.lst) = 1)
		tmpline = LineIn(current.lst)
		if (SysFileSearch(tmpline, servers.lst, 'aresult.') = 0) then do
			if (aresult.0 = 0) then do
				IrcRexxDisplay("IB: New server found & added:" tmpline "",Win) 
				junk = LineOut('servers.lst', tmpline)
				junk = LineOut('servers.lst')
			end
		end
	end
	Return
end


/*********************************************************************/
/*           Commands to simplify use of OS2Bot on #OS/2             */
/*********************************************************************/

if (Verb = '/CALC') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/msg os2bot calc' xParm1 xParms,Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr1 'You must specify a string to be sent',Win)
		IrcRexxDisplay(ErStr2 'to OS2Bot for evaluation',Win)
		Return ''
	end
end

if (Verb = '/PHONE') then do
	if (Parm1 <> '') then do
		IrcRexxCommand('/msg os2bot phone' xParm1, Win)
		Return ''
	end
	else do
		IrcRexxDisplay(ErStr1 'You must specify a string to be sent',Win)
		IrcRexxDisplay(ErStr2 'to OS2Bot for look up',Win)
		Return ''
	end
end

/*********************************************************************/
/* This isn't a command we care about so we pass a non-null string   */
/* so that it will be processed normally                             */
/*********************************************************************/

Return 'OK'

library:
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
	CALL SysLoadFuncs
Return