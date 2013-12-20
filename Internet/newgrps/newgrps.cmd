/* NEWGROUPS.CMD V1.4 */

settings.version   = "NEWGROUPS V1.4 (C) 1995 M.F. van Loon (mfvl@xs4all.nl)";
settings.target    = "YARN";
/* settings.target    = "SOUP2SQ"; */

/*

Written by Michiel van Loon (C) 1995
Based on rnr.cmd by Patrick J. Muller

V1.4 SOUP2SQ support added with thanks to Joost Vocke)
     All groups listed if no newsdate file is found.
V1.3 Footer added
V1.2 Correct reaction if initial statuscode <> 200
V1.1 Small modification when host does not accept connection
V1.0 First release

This program is freeware. This program can be freely copied and changed as
long as credits for the original program are given to me.

I can be reached for comments, suggestions for improvement, bugs and cheers at

            mfvl@xs4all.nl

This Command script is written to be used with SOUPER  and YARN and has been 
tested only with SOUPER version 12 and Yarn version 0.83. 
By uncommenting the settings.target = "SOUP2SQ" line the support will be for 
SOUP2SQ (tested only for version 1.0).

This program connects to the newsserver and issues the NEWGROUPS command. If 1 
or more newsgroups are reported a message is posted in a newsgroup named
'control.newgroups' (This name can be changed by the user by changing the line
starting with

settings.newsgroup =

A special setting can be Email in whoich case the message is treated as an 
Email message.

After creating the message the YARN import utility is used to make the
message available.

This program requires RxSOCK which can be downloaded from many OS/2 software 
archives.

Call: NEWGROUPS

Required environment variables:
ETC         --  pointing to the TCPIP\ETC directory (already set by IAK)
YARN        --  pointing to the YARN directory (must be set for YARN)
NNTPSERVER  --  the name of the news host (must be set for SOUPER to
                retrieve news)

The SOUP2SQ requires the following settings too

USER        --  your UserId
REALNAME    --  your Full Name
MAILER      --  sendmail -t -f UserId@organisation
POSTER      --  inews

Required files:
%ETC%\newsdate -- This file contains 1 line with date and time of last query. 
                  e.g. 950516 081330 This file gets updated after every run. 
                  Change this file on your own risk.
                  If this file is missing then a complete list of NEWSGROUPS 
                  will be loaded.


Some temporary files are created in the current directory, but should be cleaned
up after finishing. Just in 1 case of normal execution a file may be left over. 
This will happen when YARN is active while this script is running. In that case 
IMPORT shall not be able to add the message to YARN message base. In a future (?)
version I will change that, for now make sure that when this happens you do this 
yourself with the command

IMPORT soup.zip

in the case of YARN or

soup2sq -r

in the case of SOUP2SQ

in the same directory as this script was running. The temporary files that can
be removed have the form X???.TMP and Y???.TMP.

*/

"@echo off";

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

host = value( 'nntpserver',,'OS2ENVIRONMENT');
if host ='' then do /* Do */
  say 'You have to set environment variable NNTPSERVER to the name or address'
  say 'of your USENET news server'
  exit -1
end  /* Do */

settings.server    = host;
settings.port      = 119;
settings.newsgroup = 'control.newgroups';

cr='0d'x
lf='0a'x
crlf='0d0a'x
tab='09'x

if settings.target = "YARN" then do
  yarn = value( 'yarn',,'OS2ENVIRONMENT');
  if yarn = '' then do
    say 'The YARN environment variable should be set. It should point to the'
    say 'directory where the YARN programs are located'
    exit -1;
  end
end

etcDrivePath = value( 'etc',,'OS2ENVIRONMENT');
if etcDrivePath = '' then do
  say 'The ETC environment variable should be set. Normally this variable is'
  say 'set by the TCPIP or IAK package'
  exit -1
end  /* Do */

say settings.version

DateFile = etcDrivePath || '\newsdate';
DF = DateFile;

DateFile = stream( DateFile, 'C', 'QUERY EXISTS' )
if DateFile = '' then do
    say 'DateFile not found.'
    say 'All known groups are loaded'
    opdracht = 'LIST';
    dateline = 'beginning';
end 
else do
    dateline = linein(DateFile);
    call stream DateFile,'C','CLOSE'
    opdracht = 'NEWGROUPS '||dateline;
end

if RXFuncQuery("SockLoadFuncs") then
  do
  rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
  if rc\= 0 then
    do
      say "NEWGROUPS needs RxSock to make the connection with the Internet."
      say "RxSock can be found at hobbes.nmsu.edu"
      exit -1
    end
  rc = SockLoadFuncs(0);
  end

say 'Connecting to' settings.server 'on port' settings.port

rc = SockGetHostByName(settings.server,"host.!");
if  rc = 0 then
  do 
  say "Unable to resolve servername: " settings.server
  exit -1
  end

server = host.!addr

sock = SockSocket("AF_INET","SOCK_STREAM",0)
if (sock = -1) then
  do
  say "Unable to create socket. Error =" errno
  exit -1
  end

server.!family = "AF_INET"
server.!port   = settings.port
server.!addr   = server

rc = SockConnect(sock,"server.!")
if (rc = -1) then
  Error(sock,rc,"Connection to news server failed. Error = "||errno)

l = GetResponse(sock);
say l;
if substr(l,1,3) \= '200' then
  do
  say "Exiting....."
  exit 0
  end

say opdracht;
rc = SendMessage(sock,opdracht)

count = 0;
line = GetResponse(sock);
if substr(line,1,1)='2' then
do
  xf = SysTempFileName('X???.TMP')
  call charout xf,'Newsgroups: '||settings.newsgroup||lf,1;
  call charout xf,'From: nobody'||lf;
  call charout xf,'Path: localhost'||lf;
  call charout xf,'NNTP-Posting-Host: localhost'||lf
  call charout xf,'Subject: New groups since '||dateline||lf;
  call charout xf,'Message-Id: <newgroups.'||date('s')||'.'||time('s')||'>'||lf;
  call charout xf,'Date: '||date('n')||' '||time('n')||lf||lf;
  do forever
    line = GetResponse(sock)
    if line = "." then
      leave
    say line
    call charout xf,line||lf
    count = count + 1;
  end
end
call charout xf,lf||lf||'List compiled by '||settings.version||lf
call charout xf,lf||lf
call stream xf,'C','CLOSE'

if count>0 then do
  rc = SendMessage(sock,'DATE');
  line = GetResponse(sock);

  d = substr(line,7,6);
  t1 = substr(line,13,6);

  call lineout DF,d||' '||t1||' GMT',1
  call stream DF,'C','CLOSE'
end

rc = SendMessage(sock,'QUIT');
rc = SockSoClose(sock)

if count > 0 then do
  size = stream(xf,'C','QUERY SIZE');

  yf = SysTempFileName('Y???.TMP')
  call charout yf,'#! rnews '||size||lf
  call stream yf,'C','CLOSE'

  'copy/b'||yf||'+'||xf||' 0000000.MSG'
  call lineout AREAS,'0000000'||tab||settings.newsgroup||tab||'un',1
  call stream AREAS,'C','CLOSE';
  'del '||yf;
  if settings.target = "YARN" then do
      'zip -0m soup.zip areas 0000000.msg';
      import = yarn||'\import.exe'
      import 'soup.zip';
  end
  else do /* implies SOUP2SQ */
      'Soup2Sq -r'
  end  /* Do */
end
else
  say 'No new groups'

'del '||xf;
exit 0

GetResponse: procedure expose !. closed
  sock = arg(1)
  
  crlf = d2c(13) || d2c(10)

  if (symbol('!.buff') = "LIT") then
    !.buff = ""

  do while (pos(crlf,!.buff) = 0)
    rc = SockRecv(sock,"data",8000)
    if errno <> 0 then
      do
      closed = 1
      return ""
      end
    !.buff = !.buff || data
  end

  p = pos(crlf,!.buff)

  line = substr(!.buff,1,p-1)
  !.buff = substr(!.buff,p+2)

  return line

SendMessage: procedure expose !.
  sock = arg(1)
  data = arg(2) || d2c(13) || d2c(10)

  len = length(data)
  do while (len > 0)
    i = SockSend(sock,data)
    if (errno <> 0) then
      Error(-1,rc,"Sending data to server failed")

    if (i <= 0) then
      Error(sock,100,"Connection closed by server")

    data = substr(data,len+1)
    len  = length(data)
  end
  return 0


Error: procedure
  sock = arg(1)
  retc = arg(2)
  msg  = arg(3)

  if sock <> -1 then
    rc = SockSoClose(sock)

  say msg
  exit retc
