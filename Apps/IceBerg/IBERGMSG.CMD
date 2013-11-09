/*********************************************************************/
/* IceBerg IRC REXX Command Script for GTirc.  V 2.00  25 Feb 96     */
/*                  Copyright 1996 - Stephen Berg                    */
/*********************************************************************/
/* This file sets up all the commands that I have created, or stolen */
/* from other scripts and changed to work with REXX.  It works in    */
/* conjunction with the IBERGCMD.CMD script to customize your IRC    */
/* client, add functionality and bring GTirc to a point where it more*/
/* than competes with any other IRC client out there for OS/2.       */
/*********************************************************************/
/* This pair of REXX scripts and the ICESTART.TXT startup file are   */
/* my creation and I retain all copyrights to the files.  They are   */
/* however freely distributable, but I do ask that you email if you  */
/* are using them.  sberg@southwind.com                              */
/*********************************************************************/

Parse Upper Arg Win Us Prefix Cmd Chan Nick Rest
Parse Arg xWin xUs xPrefix xCmd xChan xNick xRest 
Parse Arg yWin yUs yPrefix yCmd yChan yNick yRest yWall yWall1 

Pool = 'OS2ENVIRONMENT'
ErStr1 = '+++ Syntax +++++'
ErStr2 = '++++ Error +++++'
ErStr3 = '++++++++++++++++'
titlline = '+------------------------IceBerg V 2.00------------------------+'
/*********************************************************************/
/* We see if this is a kick message for us. If so we format and      */
/* display a message in the window and rejoin the channel.           */
/*                                                                   */
/* We send the join command directly to the server because if we     */
/* send it as a normal command using IrcRexxCommand() it will be     */
/* ignored because the kick has not been processed and it thinks     */
/* we are still on the channel.                                      */
/*                                                                   */
/* We return a null string to suppress the kick message so that the  */
/* window for the channel will not be closed.                        */
/*                                                                   */
/*********************************************************************/

if (Cmd = 'KICK' & Nick = Us) then do
   By = substr(Prefix,2)
   Posex = pos('!',By)
   By = substr(By,1,posex - 1)

   Posex = pos(':',xRest)
   Reason = substr(xRest,2)

   Disp = "*** Kicked by" By "(" || Reason || ")"
   IrcRexxDisplay(Disp,Win)

   OutStr = "JOIN" Chan
   IrcRexxSend(OutStr)
   Return ""
End

/*********************************************************************/
/* AutoGreets are lame and obnoxious. So I removed them from         */
/* the script that came with GTirc =:-)                              */
/*********************************************************************/
/* Begin a log file when we join a channel. This feature is disabled */
/* by default. To enable it set the following variable:              */
/*                                            /iceberg autolog on    */
/*********************************************************************/

if (Cmd = 'JOIN' & VALUE('autolog',,Pool) = 'ON') then do
   OutStr = "/LOG ON"
   IrcRexxCommand(OutStr,Win)
End

/*********************************************************************/
/* MSG Logger, taken from Wease on IRC                               */
/*********************************************************************/
msglog = value('msglog',,Pool)

if(cmd='PRIVMSG' & CHAN = Us & msglog = 'ON') then do
	Flag = Pos('', xNick)
	if (Flag = 0) then do
		xPrefix = Strip(xPrefix, L, ':')
		xNick = Strip(xNick, L, ':')
		message = xNick xRest
		Posex = Pos('!', xPrefix)
		fromnick = Substr(xPrefix, 1, Posex - 1)
		fromid = Substr(xPrefix, Posex + 1)
		logtext = fromnick fromid message
		LineOut(messages.log, logtext)
		LineOut(messages.log)
		IrcRexxSend('NOTICE' fromnick ':Your msg has been logged by IceBerg 2.00',Win)
	end
	else do
	end
end

/*********************************************************************/
/* Add-on to CTCP requests cause I wanted IceBerg to announce itself.*/
/* Also: responses to things such as CTCP VERSION requests should    */
/* never respond with MSG's, GTirc was on some CTCP functions.       */
/* These bring GTirc more in line with RFC1459.                      */
/*********************************************************************/

if(Cmd='PRIVMSG' & Chan = Us & Nick = ':VERSION') then do
	verresp = ':VERSION GTirc running IceBerg V 2.00, author SSgt, sberg@southwind.com'
	fromid = Strip(xPrefix, L, ':')
	Posex = Pos('!', fromid)
	nick = Substr(fromid, 1, Posex - 1)
	IrcRexxSend('NOTICE' nick verresp, Win)
	Return 'OK'
end

if(Cmd='PRIVMSG' & Chan = Us & Nick = ':FINGER') then do
	fingerresp = ":FINGER IceBerg V2.00 default finger response.  I'm too lazy to change it."
	fromid = Strip(xPrefix, L, ':')
	Posex = Pos('!', fromid)
	nick = Substr(fromid, 1, Posex - 1)
	IrcRexxSend('NOTICE' nick fingerresp, Win)
	Return 'OK'
end

if(Cmd='PRIVMSG' & Chan = Us & Nick = ':CLIENTINFO') then do
	fingerresp = ":CLIENTINFO GammaTech IRC SuperChilled by IceBerg V2.00."
	fromid = Strip(xPrefix, L, ':')
	Posex = Pos('!', fromid)
	nick = Substr(fromid, 1, Posex - 1)
	IrcRexxSend('NOTICE' nick fingerresp, Win)
	Return ''
end

if(Cmd='PRIVMSG' & Chan = Us & Nick = ':ECHO') then do
	echoresp = ":ECHO" xRest || ""
	fromid = Strip(xPrefix, L, ':')
	Posex = Pos('!', fromid)
	nick = Substr(fromid, 1, Posex - 1)
	IrcRexxSend('NOTICE' nick echoresp, Win)
	Return ''
end

if(Cmd='PRIVMSG' & Chan = Us & Nick = ':PING') then do
	fromid = Strip(xPrefix, L, ':')
	Posex = Pos('!', fromid)
	nick = Substr(fromid, 1, Posex - 1)
	IrcRexxSend('NOTICE' nick "PONG!", Win) /* Change the "PONG!" to personalize your ping response. */
	Return 'OK'
end

if(Cmd='PRIVMSG' & Chan = Us & Nick = ':TIME') then do
	timenow = Date("N") Time("C") 
	timeresp = ":TIME" timenow "(shouldn't you get your own watch??)"|| ""
	fromid = Strip(xPrefix, L, ':')
	Posex = Pos('!', fromid)
	nick = Substr(fromid, 1, Posex - 1)
	IrcRexxDisplay("*** CTCP TIME (" || nick || ")", Win)
	IrcRexxSend('NOTICE' nick timeresp, Win)
	Return ''
end

/*********************************************************************/
/* Here we're getting all the nicks for channel that we previously   */
/* specified, writing those nicks to an array and then send the msg  */
/* to those nicks                                                    */
/*********************************************************************/

if(yCmd='353' & Value('walling',,Pool) = 'ON') then do
	names. = ''
	names.0 = 0
	cnt = 0
		   nickone = Strip(yWall,L,':')
		   nickpool = nickone yWall1
	do until Nickpool = ''
		   parse var Nickpool tmpWord Nickpool
		   cnt = cnt + 1
		   names.cnt = tmpWord
		   names.0 = cnt
	end
	do cnt = 1 to cnt
		if (Pos("@",names.cnt) = 1) then do   
		   names.cnt = Strip(names.cnt,L,'@')
		end
	end
	nickstr = names.1
	do cnt = 2 to cnt
		nickstr = nickstr || ',' || names.cnt
	end
		   Tempvar = Value('wallmsg',,Pool)
		   Strip(nickstr,B,",")
		   IrcRexxCommand('/msg' nickstr TempVar,Win)
	Value(walling,'OFF',Pool)
	Return 
end

/*********************************************************************/
/* Here we're getting all the channel operators for the channel that */
/* we previously specified, writing their nicks to an array and      */
/* then send the msg to those nicks                                  */
/*********************************************************************/

if(yCmd='353' & Value('walloping',,Pool) = 'ON') then do
	names. = ''
	names.0 = 0
	cnt = 0
	nickone = Strip(yWall,L,':')
	nickpool = nickone yWall1
	do until Nickpool = ''
		   parse var Nickpool tmpWord Nickpool
		   cnt = cnt + 1
		   names.cnt = tmpWord
		   names.0 = cnt
	end
nickstr = ''
	do cnt = 1 to cnt
		if (Pos("@",names.cnt) = 1) then do   
		   cleannick = Strip(names.cnt,L,'@')
		   nickstr = nickstr || cleannick || ','
		end
	end
	Tempvar = Value('wallmsg',,Pool)
	Strip(nickstr,B,",")
	IrcRexxCommand('/msg' nickstr TempVar,Win)
	Value(walloping,'OFF',Pool)
	Return 
end

/*********************************************************************/
/* Handling the incoming channel stats info for display              */
/*********************************************************************/

if (Cmd='353' & Value('cstating',,Pool) = 'ON') then do
	Parse Var xRest channel nicks
	nickcount = Words(nicks)
	opcount = '0'
	marker = Pos('@', nicks)
	if (marker = '0') then do
		opcount = 'None'
	end
	else do
		do until marker = '0'
			marker = Pos('@', nicks, marker + 1)
			opcount = opcount + 1
		end
	end
	IrcRexxDisplay(Copies('*',60),Win)
	IrcRexxDisplay('*' Center('Stats for' channel ':',58) '*',Win)
	IrcRexxDisplay('*' Center('' nickcount 'visible People',58) '*',Win)
	IrcRexxDisplay('*' Center('' opcount 'Channel Operators',58) '*',Win)
	IrcRexxDisplay(Copies('*',60),Win)
	Return ""
end

if (Cmd = '324' & Value('cstating',,Pool) = 'ON') then do
	modes = Strip(yRest,L,'+')
	IrcRexxDisplay('*' Center('Modes for' yNick ':' modes,58) '*',Win)
	Return ""
end

if (Cmd = '321' & Value('cstating',,Pool) = 'ON') then do
	Junk = yRest
	Return ""
end


/*********************************************************************/
/* This was added to suppress the Created Time stamp on Undernet till */
/* I can figure out how to convert that time code to something more   */
/* readable by humans                                                 */
/*********************************************************************/

if (Cmd = '329' & Value('cstating',,Pool) = 'ON') then do
	Junk = yRest
	Return ""
end

if (Cmd = '322' & Value('cstating',,Pool) = 'ON') then do
	nicktotal = yRest
	topic = yWall yWall1
	topic = Strip(topic, L, ':')
	if (topic = '') then do
		IrcRexxDisplay('*' Center('' yRest 'Total people',58) '*',Win)
		IrcRexxDisplay('*' Center('Topic for' yNick 'is:',58) '*',Win)
		IrcRexxDisplay('*' Center(' No topic has been set!',58) '*',Win)
		IrcRexxDisplay(Copies('*',60),Win)
	end
	else do
		if (Length(topic) > 56) then do
			wordcount = Words(topic)
			halfcount = wordcount % 2
			firsthalf = SubWord(topic, 1, halfcount)
			secondhalf = Subword(topic, halfcount + 1) 
			IrcRexxDisplay('*' Center('' yRest 'Total people',58) '*',Win)
			IrcRexxDisplay('*' Center('Topic for' yNick 'is:',58) '*',Win)
			IrcRexxDisplay('*' Center(firsthalf,56) '*',Win)
			IrcRexxDisplay('*' Center(secondhalf,58) '*',Win)
			IrcRexxDisplay(Copies('*',60),Win)
		end
		else do
			IrcRexxDisplay('*' Center('' yRest 'Total people',58) '*',Win)
			IrcRexxDisplay('*' Center('Topic for' yNick 'is:',58) '*',Win)
			IrcRexxDisplay('*' Center(topic,56) '*',Win)
			IrcRexxDisplay(Copies('*',60),Win)
		end
	end
	Value('cstating','OFF',Pool)
	Return ""
end

/*********************************************************************/
/* Decrypt incoming /crypt messages from other IceBerg users         */
/*********************************************************************/

if (Cmd = 'PRIVMSG' & Nick = ":#IB2.0#") then do
		By = substr(xPrefix,2)
		Posex = pos('!',By)
		By = substr(By,1,posex - 1)
	xice = "abcdefghijklmnopqrstuvwxyz1234567890,.-('"
	yice = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ )?@!#$*&=+\/"'
	icex = "Q2W* (J'K9aFs=df)gz7cE,mR/TltC+vb#yZu6UI@"
	icey = 'OHP!L.N4xM?qw"e3Gr5-A1SnD$B\YiX&o8pVhj0k'
		cryptout = icex || icey
		cryptin = xice || yice
	instr = xRest
		result = Translate(instr, cryptin, cryptout)
		IrcRexxDisplay("#IB2.0# *" || By || "-->" result,Win)
	Return ''
end

/*********************************************************************/
/* Here we're getting all the servers, stopping the process at the   */
/* the 365 message and then writing the array out to a file.         */
/* This creates a servers.lst file for later use with /findsplit     */
/*********************************************************************/

if (Cmd = '364' & Value('srvrget',,Pool) = 'ON') then do
	tempcnt = Value('cnt',,Pool) + 1
	Value('cnt',tempcnt,Pool)
	Value('srvrs.'tempcnt,yNick,Pool)
	Return ''
end

if (Cmd = '365' & Value('srvrget',,Pool) = 'ON') then do
	Value('srvrget','OFF',Pool)
	IrcRexxCommand('/WRITESVR',Win)
	Return ''
end

/*********************************************************************/
/* Here we're getting all the current servers, stopping the process  */
/* at the the 365 message and then writing the array out to a file.  */
/* This creates a current.lst file for later use with /findsplit     */
/*********************************************************************/

if (Cmd = '364' & Value('getcurr',,Pool) = 'ON') then do
	tempcnt = Value('currcnt',,Pool) + 1
	Value('currcnt',tempcnt,Pool)
	Value('currsvrs.'tempcnt,yNick,Pool)
	Return ''
end

if (Cmd = '365' & Value('getcurr',,Pool) = 'ON') then do
	Value('getcurr','OFF',Pool)
	IrcRexxCommand('/WRITECURRSVR',Win)
	Return ''
end

/*********************************************************************/
/* Handle all Auto-op'ing functions for any JOIN msgs received.      */
/*********************************************************************/

if (Cmd = 'JOIN' & Value('autoop',,Pool) = 'ON') then do
	userId = Prefix
	Posex = Pos('!', userId)
	nickname = SubStr(userId, 2, Posex - 2)
	Strip(nickname, T, '!')
	do while (Lines('autoop.lst') = 1)
		userline = LineIn('autoop.lst')
		Parse Upper Var userline user channel
		Chan = Strip(Chan, L, ':')
		opok = IrcRexxWildCard(user, Prefix)
		chanok = IrcRexxWildCard(channel, Chan)
		if (opok = 'MATCH') & (chanok = 'MATCH') then do
			IrcRexxSend('MODE' Chan '+o' nickname, Win)
		end
	end 
	Return 'OK'
end

/*********************************************************************/
/* XDCC by Armin Kunaschik (ADC) frequently on #os/2ger and #os/2    */
/* 12.1.1996 Version 1.2 Freeware                                    */
/* NO WARRANTY    Use at your own risk!                              */
/* you need the following files:                                     */
/* fileist.txt - list of available files (syntax below)              */
/* users       - list of users who don't need to enter the password  */
/*               1 line = 1 user!                                    */
/* password    - the password for XDCC access                        */
/*                                                                   */
/* History:                                                          */
/* 1.0 initial release                                               */
/* 1.2 Authorization added                                           */
/* 1.0 Problems with EXPOSE removed                                  */
/* normal XDCC with authorization: set SecureXDCC =1                 */
/*********************************************************************/
/* I have adapted this code to integrate it with IceBerg.  During    */
/* that process I decided to leave off the secure functions until I  */
/* can figure them out myself.  The code here absolutely belongs to  */
/* Armin.  I should have the secure side of things figured out soon. */
/* and will add it into the next release of IceBerg.  I also tweaked */
/* the code to my style of writing REXX and to clean up what I       */
/* personally consider to be somewhat of extra work in the code.     */
/*********************************************************************/

if (Cmd = 'PRIVMSG' & Chan = Us & Nick = ':XDCC') then do
	FileList = "FileList.txt" 
	IrcRexxDisplay("XDCC" yRest "received from" xPrefix, Win)
	parse upper arg Win Us Prefix Cmd Chan Nick Func Num Passwd
	From = Substr(Prefix,2)
	posex = pos('!',From)
	From = Substr(From,1, posex - 1)
Select
When Func = 'LIST' then do  /*  *** LIST command ***  */
	IrcRexxDisplay("LIST "From,Win)
	LineNo=0
	do while Lines(FileList)
		Fileline = LineIn(FileList)
		if Fileline = "" then leave
		LineNo = LineNo + 1
		Parse Var Fileline Filename Filedesc
		FileName2 = FileSpec("N",FileName)
		FileSize = Stream(FileName,"C","QUERY SIZE")
		IrcRexxCommand("/msg" From "" LineNo || ":" FileDesc "|" Filename2 "[" || FileSize || " bytes]", Win)
	End
	IrcRexxCommand("/MSG "From" To get a file type /MSG "Us" XDCC SEND number", Win)
	Return ""
end
/* SEND command */
When Func = 'SEND' then do
	If Num = "" then do
		IrcRexxCommand("/MSG" From "Ooops, you forgot the file number", Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC SEND N to get file with number N",Win)
		Return ""
	End
	else do
		LineNo = 0
		do while Lines(FileList)
			Fileline = LineIn(FileList)
			if Fileline = "" then leave
			LineNo = LineNo + 1
			Parse Var Fileline Filename Filedesc
			if LineNo = Num then do
				IrcRexxCommand("/DCC SEND" From FileName, Win)
				logentry = Date('N') Time('C') FileName "sent to" xPrefix 
				Lineout("xdcc.log", logentry)
				Lineout("xdcc.log")
				Return ""
			End
		End
		IrcRexxCommand("/MSG" From "This File is not available! Range:[1.." LineNo "]", Win)
		Return ""
	end
end

/* HELP routine */
	When Func = 'HELP' then do
		IrcRexxCommand("/MSG" From "Available Commands are:",Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC LIST for available files",Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC SEND N to get file with number N",Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC HELP for help",Win)
		Return ""
	end

	When Func = "" then do
		IrcRexxCommand("/MSG" From "Available Commands are:",Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC LIST for file list",Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC SEND N to get file with number N",Win)
		IrcRexxCommand("/MSG" From "/MSG" Us "XDCC HELP for help",Win)
		Return ""
	end

	Otherwise do
		IrcRexxCommand("/MSG" From "Unknown Command! Try: XDCC HELP",Win)
		Return ""
	end
	Return "OK"
End
end
/*********************************************************************/
/* Handle the kick/ban so get rid of people we don't want in the     */
/* the current channel.                                              */
/*********************************************************************/

if Cmd = '302' & Value('kbanning',,Pool) = 'ON' then do
	channel = Value('kbanchan',, Pool)
	reason = Value('kbanreason',, Pool)
	if (reason = '') then do
		reason = 'IceBerg V 2.00 KickBan'
	end
	testnick = Nick
	testnick = Strip(Nick, L, ':')
	Posit = Pos('=', testnick)
	testnick = SubStr(testnick, 1, Posit - 1)
	if testnick = Value('kbannick',,Pool) then do
		Posex = Pos('=', xNick)
		userId = Substr(xNick, Posex + 2)
		userId = Strip(userId, L, '~')
		Posex1 = LastPos('.', userId)
		Posex2 = LastPos('.', userId, Posex1 - 1)
		if (Posex2 = '0') then do
			Posex2 = Pos('@', userId)
		end
		Posex3 = Pos('@', userId)
		user = SubStr(userId, 1, Posex3)
		host = SubStr(userId, Posex2 + 1)
		banId = "*!*" || user || "*" || host
		IrcRexxCommand('/mode' channel '+b' banId, Win)
		IrcRexxCommand('/kick' channel testnick reason, Win) 
		Value('kbanning','OFF',Pool)
		Value('kbannick', '', Pool)
		Value('kbanchan', '', Pool)
		Value('kbanreason', '', Pool)
	end
	else do
	end
	Return
end

/*********************************************************************/
/* Handle NOTICE's so they are descernable versus PRIVMSG's          */
/*********************************************************************/

if (Cmd = 'NOTICE' & Chan = Us) then do
	Flag = Pos('', xNick)
	if (Flag = 0) then do
		fromid = Strip(xPrefix, L, ':')
		Posex = Pos('!', fromid)
		fromnick = Substr(fromid, 1, Posex - 1)
		xNick = Strip(xNick, L, ":")
		IrcRexxDisplay("+" || fromnick || "+" xNick xRest, Win)
		Return
	end
	else do
	end
end

/*********************************************************************/
/* We don't care about this message so return a non-null string so   */
/* that it will be processed normally.                               */
/*********************************************************************/

Return "OK"


