/*-----------------------------------------*
 *-------- DnsALIAS.cmd for OS/2 ----------*
 * 
 * See www.dyndns.org about setting up a dynamic DNS
 *
 * 25th January 2004, Bruce Dudley, os2box@transit.homeip.net
 * 
 * Allow upto a total of 5 host names to be updated. See the hostname.#
 * in the USER config area.
 * 
 * Command line switches used by the program. Both optional.
 *
 * DnsAlias.Cmd offline
 *                        Updates the dyndns IP to 255.255.255.255
 *                        which indicates that your offline.
 * DnsAlias.Cmd change
 *                        Forces a IP update.
 *---------------------------------------------------------------*
 * 29th August 2002  Bruce Dudley
 *
 * Incorporated the USER setting into dyndns.cmd file. See the section where
 *
 * it says: --------------- START of USER config area ------------
 *
 * Added additional options from the command line to alter the defaults
 * Fixed:  Error reporting. Was badly broken.
 * Cleaned the code up a bit.
 *
 * Modified by Bruce Dudley os2box@transit.homeip.net on 05-12-2001
 * Adapted to suit the new DYNDNS update format
 * Changed the method in obtaining the local ppp interface IP number
 * Added return code reporting from the DYNDNS server
 * Only the update.cmd file required, no need for suspend.cmd any
 * longer (see dns-on.cmd/dns-off.cmd) for details.
 *
 * Requires: rxsock.dll
 * 
 * Modified by Vinicius Beltrao on 07-23-2000
 * in order to work properly with DYNDNS.ORG domains/update system
 *
 * Original by Dennis Peterson on 7-27-97 for usage with the old ml.org
 *
 * Archive includes b64rx.dll which encodes the userid:password string
 * The b64rx.dll code was created by Teet Kõnnussaar (teet@aetec.estnet.ee)
 *
 * Requires rxsock.dll
 * Requires registation with www.dyndns.org which is free for now
 *
 * This code is free to everyone.
 * --------------------------------------------------------------*
 *
 * Basic Info from www.dyndns.org:
 *
 * The host to connect to is: members.dyndns.org.
 * The protocol to use is HTTP or HTTPS.
 * The port number is 80 (HTTP) or (HTTPS).
 * The path is /nic/update?
 * Both PUT and GET methods can be used.
 * The arguments are (these are examples, but they're reasonable defaults):
 *
 * This is an example of a line that could be sent to the ML server to
 * update a host artur.dyn.ml.org:
 *
 * GET /nic/update?system=dydns&hostname=YES&hostname=yourhost.ourdomain.ext&myip=ipaddress&wildcard=OFF&mx=mail.exchanger.ext&backmx=NO HTTP/1.0
 *
 * That line should be followed by the authorization data on one line, and
 * an empty line.
 *
 * Authorization
 * The authorization line mentioned above is:
 * Authorization: Basic ENCODED_MID_AND_PASSWORD
 * Eg if artur1 is the MID and password is the password, then it is
 * formatted as "artur1:password" (w/o the qoutes) and encoded using
 * base64 (Authorization: Basic YXJ0dXIxOnBhc3N3b3Jk).
 * -------------------------------------------------------------*/

/*---------------------------------*
 *--- Initialize REXX utilities ---*
 *---------------------------------*/
if RxFuncQuery("SysLoadFuncs") then
  do
    Call RxFuncAdd "Sysloadfuncs","RexxUtil","Sysloadfuncs"
    Call SysLoadFuncs
  end

/*------------------------------------*
 *--- Initialize md5rx API package ---*
 *------------------------------------*/

call rxfuncadd 'B64encode','md5rx','B64encode'
call rxfuncadd 'B64decode','md5rx','B64decode'

/*---------------------------------*
 *--- Initialize socket package ---*
 *---------------------------------*/
if RxFuncQuery("SockLoadFuncs") then
    do
      rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
      rc = SockLoadFuncs(NoCopyright)
    end
/*---------------------------------------------------------------*
 *----------------- START of USER config area -------------------*
 *---------------------------------------------------------------*/

/* ---------------------------------------- *
 * ---- Your DynDNS account Login name ---- *
 * ---------------------------------------- */
loginname = "test"

/* -------------------------------------- *
 * ---- Your DynDNS account Password ---- *
 * -------------------------------------- */
password = "test"

/*---------------------------------------------------*
 *---- If your using a DYNAMIC IP set to "dyndns" ---*
 *---- If using a STATIC IP set to "statdns" --------*
 *---------------------------------------------------*/
system = "dyndns"

/*--------------------------------------------------*
 *--- The number of HOSTnames being defined below --*
 *---------------- 1 to 5 allowed ------------------*
 *--------------------------------------------------*/
numberofhosts = 1

/*---------------------------------------------------------------*
 *--------------- The hostname(s) to be updated -----------------*
 *---------------------------------------------------------------*
 *--- Just put in the hostname(s) in here. One hostname per -----*
 *--- line. Dont't change the labels though. Just what is -------*
 *--- within the quotes, otherwise use a NULL string  eg.. ""  --*
 *---------------------------------------------------------------*/
hostname.1 = "test.dyndns.org"
hostname.2 = ""
hostname.3 = ""
hostname.4 = ""
hostname.5 = ""

/*---------------------------------*
 *--- Wildcard ON, OFF or NOCHG ---*
 *---------------------------------*/
wildcard = "off"

/*----------------------------------------------------------------------*
 *---- Set the MX record. Needs to be a FQHN to function correctly -----*
 *---- otherwise use a NULL string eg. ""  -----------------------------*
 *----------------------------------------------------------------------*/
mx = ""

/*------------------------------------------------------*
 *---- Make the mx a backup mailexchanger YES or NO ----*
 *------------------------------------------------------*/
backmx = "no"

/*-----------------------------------------------------------------*
 *--- PPP or LAN interface number that points to the real world ---*
 *------ NB. Some earlier versions of the OS/2 tcpip stack --------*
 *---------- need the ppp0 or lan0 to be in upper case ------------* 
 *------------- eg PPP0 or LAN0 as the case me be -----------------*
 *-----------------------------------------------------------------*/
interface = "ppp0"

/*-----------------------------------------------------------*
 *---- HTTP port is normally 80 or 8245 to bypass proxys ----*
 *-----------------------------------------------------------*/
port = "80"

/*-----------------------------------------------------------------------*
 *------------------- END of USER config area ---------------------------*
 *-----------------------------------------------------------------------*/
hostlist = ""
crlf = "0d0a"x

/*-------------------------------------------------------------------*
 *--- Obtain switch from command line and decide if we are to -------*
 *--- update the IP to DYNDNS or set to 255.255.255.255 = offline ---*              *
 *-------------------------------------------------------------------*/
parse arg status

     if (status = "offline") then mydip = '255.255.255.255'
   
     else
     
/*----------------------------------------------*
 *--- Get IP from IFCONFIG for the interface ---*
 *----------------------------------------------*/
 '@ifconfig' interface' | find /i "inet" | rxqueue'
       if queued() <> 0 then do
           Parse Pull lin
           Parse Var lin "." -5 . mydip . remoteip .
       end

/*-------------------------------------------------------*
 *--- Get the number of HOSTnames to update and build ---*
 *-------- a string to place in the URL update ----------*
 *-------------------------------------------------------*/
call dohosts 
hosts = result

/*------------------------------------------------------------*
 *--- Initialize http variables - Yes -- rexx can to HTML! ---*
 *------------------------------------------------------------*/
server = "members.dyndns.org"
security = "Host: " || server || crlf || "Authorization: Basic " B64Encode(loginname || ":" || password) || crlf || "User-Agent: DnsAlias for OS/2" || crlf || crlf

URL = "GET /nic/update?"
URL = URL || "system=" || system
URL = URL || "&hostname=" || hosts
URL = URL || "&myip=" || mydip
URL = URL || "&wildcard=" || wildcard
URL = URL || "&mx=" || mx
URL = URL || "&backmx=" || backmx
URL = URL || " HTTP/1.0" || crlf

say "Updating the DynDns to the following"
say "Current "interface" IP -----: "mydip

showstring = "Updateing Hostname --:"
call displayhosts

say "Wildcard ------------: "wildcard
say "MX record -----------: "mx
say "Backup MX record ----: "backmx || crlf

/*------------------------*
 * --- Get server name ---*
 *------------------------*/
rc = SockGetHostByName(server,"host.!")
if (rc = 0) then
   do
      say "Error" h_errno "calling SockGetHostByName("server")"
      exit
   end

server = host.!addr;

/*-------------------*
 *--- Open socket ---*
 *-------------------*/
socket  = SockSocket("AF_INET","SOCK_STREAM",0)
if (socket = -1) then
   do
      say "Error on SockSocket:" errno
      exit
   end

/*--------------------*
 *--- Catch breaks ---*
 *--------------------*/
signal on halt

/*----------------------*
 *--- Connect socket ---*
 *----------------------*/
server.!family = "AF_INET"
server.!port   = port
server.!addr   = server

rc = SockConnect(socket,"server.!")
if (rc = -1) then
   do
      say "Error on SockConnect:" errno
      exit
   end

rc = SockSend(socket, URL)
if (rc = -1) then
   do
      say "Error on SockSend URL:" errno
      exit
   end

rc = SockSend(socket, security)
if (rc = -1) then
   do
      say "Error on SockSend security:" errno
      exit
   end

/*------------------------------------------*
 *--- Receive the result from the server ---*
 *------------------------------------------*/
do until rc = 0
   rc = SockRecv(socket,"newData",256)
   returnData = returnData || newData
end

/*--------------------------------------*
 *--- Check results sent from DynDNS ---*
 *--------------------------------------*/
   if pos('badauth',returnData) > 0 then do
        say 'Bad authorization (Username and/or Password).'crlf
   end

   if pos('badsys',returnData) > 0 then do
        say 'The system parameter was not valid.'crlf
   end

   if pos('badagent',returnData) > 0 then do
      say 'The useragent your client sent has been blocked at the access level.'crlf
   end

   if pos('good',returnData) > 0 then do
        allok = SubStr(returnData,(pos('good',returnData) + 5),15)
        showstring = "Update for Hostname ------------:"
        call displayhosts
        say 'The DynDNS has been updated to -: 'allok||crlf
   end

   if pos('nochg',returnData) > 0 then do
        showstring = "No change for Hostname -:"
        call displayhosts
        say 'Update considered abusive.'crlf
        say 'NOTE: To force an update use the `change` switch'
        say '      eg: dyndns.cmd change'crlf

   end

   if pos('notfqdn',returnData) > 0 then do
        say 'A Fully-Qualified Domain Name was not provided.'crlf
   end

   if pos('nohost',returnData) > 0 then do
        say 'The hostname specified does not exist.'crlf
   end

   if pos('abuse',returnData) > 0 then do
        say 'The hostname specified is blocked for abuse. Contact support to be unblocked.'crlf
   end

   if pos('!donator',returnData) > 0 then do
        say 'The offline setting was set, when the user is not a donator, this is only returned once.'crlf
   end

   if pos('!yours',returnData) > 0 then do
        say 'The hostname specified exists, but not under the username currently being used.'crlf
   end

   if pos('numhost',returnData) > 0 then do
        say 'Too many or too few hosts found.'crlf
   end

   if pos('dnserr',returnData) > 0 then do
        say 'DNS error encounted.'crlf
   end

   if pos('wxxh',returnData) > 0 then do
        wxxh = SubStr(returnData,(pos('wxxh',returnData) + 12),2)
        say 'DynDns has told me to wait for 'wxxh' hours. ZZzzzz'crlf
        call syssleep wxxh
   end

   if pos('wxxm',returnData) > 0 then do
        wxxm = SubStr(returnData,(pos('wxxm',returnData) + 12),2)
        say 'DynDns has told me to wait for 'wxxm' minutes. ZZzzzz'crlf
        call syssleep wxxm
   end

   if pos('wxxs',returnData) > 0 then do
        wxxs = SubStr(returnData,(pos('wxxs',returnData) + 12),2)
        say 'DynDns has told me to wait for 'wxxs' seconds. ZZzzzz'crlf
        call syssleep wxxs
   end

   if pos('911',returnData) > 0 then do
        say 'Shutdown until notified.'crlf
   end

   if pos('999',returnData) > 0 then do
        say 'Shutdown until notified.'crlf
   end

/*----------------------------------------*
 *--- Close socket (and catch signals) ---*
 *----------------------------------------*/
halt:
   rc = SockSoClose(socket)
     if (rc = -1) then
       do
        say "Error on SockSoClose:" errno
        exit
     end

rc = SockDropFuncs()
exit 0    /* Exit the Program */

/*--------------------------------------------------*
 *--- Create a string of hostnames to be updated ---*
 *--------------------------------------------------*/
dohosts:
   hostnumber = 1
   dynhosts = numberofhosts

      do until dynhosts  <  1
         hostlist = hostlist || hostname.hostnumber
         hostnumber = hostnumber + 1
           if dynhosts > 1 then hostlist = hostlist || ","
              dynhosts = dynhosts - 1
      end
 return (hostlist)

/*------------------------------------------*
 *--- Display the HOSTname being updated ---*
 *------------------------------------------*/
displayhosts:
   hostnumber = 1
   dynhosts = numberofhosts

      do until dynhosts  <  1
         say showstring hostname.hostnumber
         hostnumber = hostnumber + 1
         dynhosts = dynhosts - 1
     end
 return
