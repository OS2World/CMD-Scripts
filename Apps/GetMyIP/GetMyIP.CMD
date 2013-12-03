/*****************************************************************************************************/
/*                                        GetMyIP                                                    */
/*                     by Peter Lueersen <Peter@warp-ecs-owl.de>                                     */
/*                                        V 1.0.8                                                    */
/*****************************************************************************************************/
/* Application Module Name : GetMyIP                                                                 */
/* File Name               : getmyip.cmd                                                             */
/* Date                    : 19.11.2006                                                              */
/* Author                  : Peter Lueersen                                                          */
/*****************************************************************************************************/
/* This program is free software                                                                     */
/* you can redistribute it and/or modify it under the terms of the GNU General Public License        */
/* as published by the Free Software Foundation; either version 2 of the License,                    */
/* or (at your option) any later version.                                                            */
/*                                                                                                   */
/* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY          */
/* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.         */
/* See the GNU General Public License for more details.                                              */
/*                                                                                                   */
/* You should have received a copy of the GNU General Public License along with this program         */
/* if not, write to the                                                                              */
/* Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.           */
/*****************************************************************************************************/
/*                                                                                                   */
/* Description:                                                                                      */
/* This REXX script will retrieve an IP address assigned to a host either                            */
/* through an external server. The address is an external IP address which                           */
/* may be dynamically assigned by an ISP.                                                            */
/* By default the script will query a user defined IP echo server and                                */
/* will show the returned IP address.                                                                */
/*****************************************************************************************************/
/*-                                                                                                 -*/
/*- DEFAULT ECHO SERVER: ipid.shat.net                                                              -*/
/*-                                                                                                 -*/
/*- This code is based on getip.cmd by Dariusz Piatkowski                                           -*/
/*-                                                                                                 -*/
/*- Modification History                                                                            -*/
/*-                                                                                                 -*/
/*-   VERSION        DATE         AUTHOR                                                            -*/
/*-                                                                                                 -*/
/*-   V1.0.8      19.11.2006      Peter Lueersen                                                    -*/
/*-     New version number only                                                                     -*/
/*-   V1.0.7      26.08.2006      Peter Lueersen                                                    -*/
/*-     Fix 99% CPU with no end                                                                     -*/
/*-   V1.0.6      26.05.2006      Peter Lueersen                                                    -*/
/*-     New version number only                                                                     -*/
/*-   V1.0.5      19.05.2006      Peter Lueersen                                                    -*/
/*-     Fix error /L: File will not delete                                                          -*/
/*-   V1.0.4      14.05.2006      Peter Lueersen                                                    -*/
/*-     Now only one line in Logfile                                                                -*/
/*-     Fix Help                                                                                    -*/
/*-     New show "ERROR NO IP" if the IP could not be determined.                                   -*/
/*-   V1.0.4·1    07.05.2006      Peter Lueersen                                                    -*/
/*-     New Logfile /l: or /L:                                                                      -*/
/*-     Now uniform version number for all programs                                                 -*/
/*-   V1.0.3      28.04.2006                                                                        -*/
/*-                               Marcus von Cube                                                   -*/
/*-     New /O:PROGRAM     --> Feed output to PROGRAM, default 'host.exe'                           -*/
/*-                               Peter LÅersen                                                     -*/
/*-     New /V:            --> Show version only                                                    -*/
/*-   V1.0.3·1    16.04.2006      Peter LÅersen                                                     -*/
/*-     Fix this:                                                                                   -*/
/*-     RXSOCK 2.0 - REXX FUNCTION PACKAGE FOR TCP/IP SOCKETS @ 19:12:48 10 Apr 2006                -*/
/*-     (C) COPYRIGHT INTERNATIONAL BUSINESS MACHINES CORPORATION 1993, 94 @ 19:17:54 10 Apr 2006   -*/
/*-     ALL RIGHTS RESERVED. @ 19:23:02 10 Apr 2006                                                 -*/
/*-      @ 19:28:10 10 Apr 2006                                                                     -*/
/*-   V1.0.2      08.04.2006      Peter LÅersen                                                     -*/
/*-     New Commanline                                                                              -*/
/*-     New Bugreport                                                                               -*/
/*-     New Help /?  	                                                                            -*/
/*-   V1.0.1      02.04.2006      Peter Lueersen                                                    -*/
/*-   	Fix error in line 32 :-(                                                                    -*/
/*-   V1.0.0      01.04.2006      Peter Lueersen                                                    -*/
/*-   	First version of the code.                                                                  -*/
/*-                                                                                                 -*/
/*---------------------------------------------------------------------------------------------------*/

signal on syntax name error

/* initialize socket package */
IF RxFuncQuery('SysLoadFuncs') <> 0 THEN DO
   CALL RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
   loaded = 1
END
CALL SysLoadFuncs


/* define some globals that we are going to use */

Globalsver=' V 1.0.8 '
parse source . . ScriptFile
inst_drive = filespec("D", ScriptFile)
inst_path = filespec("P", scriptfile)
installpath=inst_drive||inst_path
crlf = "0d0a"x
echo_server = "ipid.shat.net"
echo_dir = "/iponly/"
find_after = "body"
ok = false
No_Del=false

/* output control */
output_to = ''

/* log control */
log_to = ""

/* DEBUG control flag */
debug_on = 0

/*Starttime of main routine */
CALL Time 'E'

/* parse the string for the ARGs */ 
PARSE ARG args

DO i=1 TO words(args)

	arg = word(args,i)

	IF (arg='/?') THEN 
   	DO
   	call SysCls
    	SAY "***************************************************************"
  	SAY "*     GetMyIP     Ver.: " || Globalsver || " by Peter Lueersen 2006      *"  
   	SAY "*            Peter@WARP-ECS-OWL.DE                            *"
   	SAY "***************************************************************"
   	SAY " "
   	SAY "    Syntax         GetMyIP [/E:SERVER [/S:SIDE] /A:STRING] [/D:] [/V:]  [/?]"
        SAY "                           [/O:[PROGRAM]] [[/l:[LOGFILE]]|[/L:[LOGFILE]]]"
   	SAY " "
   	SAY "    /?             --> This Help"
   	SAY "    /A:STRING      --> Find IP after this STRING in the next 160 bytes"
   	SAY "                       do not use '<' , '>' or '/' in STRING"
   	SAY "    /D:            --> Debug on"
   	SAY "    /E:SERVER      --> Echo-SERVER to use"
   	SAY "    /l:LOGFILE     --> Log all IPs and Timestamps to LOGFILE, default 'GetMyIP.LOG'"
   	SAY "    /L:LOGFILE     --> Log only last IP and Timestamp to LOGFILE, default 'GetMyIP.LOG'"
   	SAY "    /O:PROGRAM     --> Feed output to PROGRAM, default 'host.exe'"
   	SAY "    /S:SIDE        --> SIDE on Echoserver"
   	SAY "    /V:            --> Show version only"
   	SAY " "
   	SAY "    GetMyIP        --> will use /E:" || echo_server || " /S:" || echo_dir || " /A:" || find_after 
   	EXIT
   	END

	IF (arg='/V') | (arg='/V:') THEN 
   	DO
   	SAY "GetMyIP     Ver.: " || Globalsver || " by Peter Lueersen 2006"  
   	EXIT
   	END

	IF (arg='/D') | (arg='/D:') THEN 
   	DO
   	debug_on = 1
   	END

	IF (substr(arg,1,3,':')='/O:') THEN 
   	DO
   	output_to = substr(arg,4)
		IF output_to = "" THEN
		DO
		output_to = "host.exe"
		END
   	END

	IF (substr(arg,1,3,':')='/l:') THEN
	DO
	   No_Del = true
        END 
	IF (substr(arg,1,3,':')='/l:') | (substr(arg,1,3,':')='/L:')  THEN
	DO
   	   log_to = substr(arg,4)
	   IF log_to = "" THEN
	   DO
	      log_to = installpath || "GetMyIP.LOG"
	   END
   	END
         
	IF (substr(arg,1,3)='/E:') THEN 
   	DO
   	echo_server = substr(arg,4)
   	echo_dir = ""
   	find_after = ""
   	END

	IF (substr(arg,1,3)='/S:') THEN 
   	DO
   	echo_dir = substr(arg,4)
   	END

	IF (substr(arg,1,3)='/A:') THEN 
   	DO
   	find_after = substr(arg,4)
   	END
END

DO WHILE ok = false

 /* choose port number - http port is normally 80 */
 port = 80

 server = echo_server
 URL = "GET http://"|| echo_server || echo_dir || " HTTP/1.0" || crlf || crlf

 call debug_show "URL START ->" || URL || "<- URL END", debug_on

 /* initialize socket package */
 IF RxFuncQuery("SockLoadFuncs") THEN
   DO
   rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
   rc = SockLoadFuncs()
   END

 /* get server name */
 rc = SockGetHostByName(server,"host.!")
 IF (rc = 0) THEN
   DO
   SAY "ERROR NO IP"
   /* SAY "Error" h_errno "calling SockGetHostByName("server")" */
   IF log_to <> '' THEN
     DO
     final_ip_address = "ERROR NO IP"
     signal log_file
     END
   ELSE
     DO
     exit
     END
   END

 server = host.!addr;

 /* open socket */
 socket  = SockSocket("AF_INET","SOCK_STREAM",0)
 IF (socket = -1) THEN
   DO
   SAY "ERROR NO IP"
   /* SAY "Error on SockSocket:" errno */
   IF log_to <> '' THEN
     DO
     final_ip_address = "ERROR NO IP"
     signal log_file
     END
   ELSE
     DO
     exit
     END
   END

 /* catch breaks */
 SIGNAL on halt

 /* connect socket */
 server.!family = "AF_INET"
 server.!port   = port
 server.!addr   = server

 rc = SockConnect(socket,"server.!")
 IF (rc = -1) THEN
   DO
   SAY "ERROR NO IP"
   /* SAY "Error on SockConnect:" errno */
   IF log_to <> '' THEN
     DO
     final_ip_address = "ERROR NO IP"
     signal log_file
     END
   ELSE
     DO
     exit
     END
   END

 rc = SockSend(socket, URL)
 IF (rc = -1) THEN
   DO
   SAY "ERROR NO IP"
   /* SAY "Error on SockSend URL:" errno */
   IF log_to <> '' THEN
     DO
     final_ip_address = "ERROR NO IP"
     signal log_file
     END
   ELSE
     DO
     exit
     END
   END

 /* receive the result from the server */
 Do UNTIL rc = 0
   rc = SockRecv(socket,"newData",512)
   call debug_show "DATA START ->" || newData || "<- DATA END", debug_on
   returnData = returnData || newData
   /* Timeout after 60 s */
   if Format(Time('E'),,2)>60 then do
    returnData = ""
    rc = 0
   end
 END

 /* now go ahead and retrieve the IP address info from the data sent back */
    location = pos(find_after, returnData) + length(find_after)

 /* return the next 160 bytes to capture the additional HTML formatting along with */
 /* the IP address                                                                 */
 ip_address = substr(returnData, location, 160)

 CALL debug_show "IP SOURCE START ->" || ip_address || "<- IP SOURCE END", debug_on

 /* parse the string for the IP address */
 Parse Var ip_address ip_1 "." ip_2 "." ip_3 "." ip_4 .

 /* strip off the leading junk before the first part of the IP address */
 do WHILE DataType(ip_1) <> "NUM"
   ip_1 = substr(ip_1,2)
 end

 /* strip off the trailing junk after the last part of the IP address */
 do WHILE DataType(ip_4) <> "NUM"
   ip_4 = substr(ip_4, 1, (length(ip_4)-1))
 end

 /* now assemble the complete IP address */
 final_ip_address = ip_1 || '.' || ip_2 || '.' || ip_3 || '.' || ip_4

 /* is this a ip ??? */
 if (length(final_ip_address) > 6) & (length(final_ip_address) < 16) | final_ip_address == "ERROR NO IP" then do
   ok = true
 end	
 else do
    ok = false	
 end

 /* Timeout after 60 s */
 if Format(Time('E'),,2)>60 then do
  final_ip_address = "ERROR NO IP TIMEOUT"
  ok = true
 end
end

/* And say it to the world */
IF output_to = '' THEN
   DO
   CALL debug_show "IP is:", debug_on
   say final_ip_address
   END
ELSE
   DO
   CALL debug_show output_to final_ip_address, debug_on
   ADDRESS CMD '@'output_to final_ip_address
   END

/* And log it ? */
log_file:

IF log_to <> '' THEN
   DO
   /* Del old file */
   CALL debug_show "LOG-FILE START ->", debug_on
   IF No_del=false THEN
     DO
     CALL debug_show "Del " || log_to, debug_on
     call SysFileDelete log_to
     END
   /* Write new file */
   CALL debug_show "Write " || log_to, debug_on
   Ret = STREAM(log_to,'C',"OPEN WRITE")
   call charout log_to, final_ip_address || " @ " || time() || " " || date() || crlf
   Ret = STREAM(log_to,'C',"CLOSE")
   CALL debug_show "<- LOG-FILE END", debug_on
   END
/*----------------------------------------------------------------------------*/

/* close socket (and catch signals) */

halt:

rc = SockSoClose(socket)
if (rc = -1) then
   do
   /* say "Error on SockSoClose:" errno */
   exit
   end

exit

/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
/* DEBUG output wrapper function                                              */
/*----------------------------------------------------------------------------*/

debug_show: PROCEDURE
PARSE ARG message, debug_on

IF debug_on THEN
   SAY message

RETURN

/*----------------------------------------------------------------------------*/
/* If Error :(( then show                                                     */
/*----------------------------------------------------------------------------*/
Error:
        say crlf
        say '-Hoops-'||crlf
        say 'Send this bugreport to :'
        say 'Peter@warp-ecs-owl.de      Subject: GetMyIP Error'
        say ''||crlf
        say 'Version......: ' || Globalsver
        say 'Linenumber...: ' || sigl
        say 'Linetext.....: ' || sourceline(sigl)
        say 'Errorcode....: ' || rc
        say 'Errortext....: ' || errortext(rc)
        say 'Options......: ' || ARG(1)
        say ''||crlf
exit
