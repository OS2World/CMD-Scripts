/*****************************************************************************************************/
/*                                           WPGetMyIP_all5m                                         */
/*                     by Peter Lueersen <Peter.Lueersen@warp-ecs-owl.de>                            */
/*                                              V 1.0.8                                              */
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
/*- Modification History                                                                            -*/
/*-                                                                                                 -*/
/*-   VERSION        DATE         AUTHOR                                                            -*/
/*-                                                                                                 -*/
/*-   V1.0.8      19.11.2006      Peter Lueersen                                                    -*/
/*-     New version number only                                                                     -*/
/*-   V1.0.7      04.08.2006      Peter Lueersen                                                    -*/
/*-     New version number only                                                                     -*/
/*-   V1.0.6      26.05.2006      Peter Lueersen                                                    -*/
/*-     New version number only                                                                     -*/
/*-   V1.0.5      19.05.2006      Peter Lueersen                                                    -*/
/*-     New Version                                                                                 -*/
/*-   V1.0.4        09.05.2006    Peter Lueersen                                                    -*/
/*-     Fix Queue, clear queue and linein("QUEUE:")                                                 -*/
/*-   V1.0.4á1      07.05.2006    Peter Lueersen                                                    -*/
/*-     Now uniform version number for all programs                                                 -*/
/*-     New give commandline / options to GetMyIP                                                   -*/
/*-   V1.0.1        19.04.2006    Peter Lueersen                                                    -*/
/*-     New Bugreport                                                                               -*/
/*-     New Show GetMyIP-Version                                                                    -*/
/*-   	Fix Time error                                                                              -*/
/*-   V1.0.0        08.04.2006    Peter Lueersen                                                    -*/
/*-   	First version of the code.                                                                  -*/
/*-                                                                                                 -*/
/*---------------------------------------------------------------------------------------------------*/

signal on syntax name error

parse source . . ScriptFile
inst_drive = filespec("D", ScriptFile)
inst_path = filespec("P", scriptfile)
installpath=inst_drive||inst_path
crlf = "0d0a"x
Globalsver = ' 1.0.8 '

/* init RexxUtil */
if rxfuncquery('SysLoadFuncs') then do
 call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs
end

call SysCls
SAY "WPGetMyIP_all5m     Ver.: " || Globalsver || " by Peter Lueersen 2006"  
SAY "            Peter@WARP-ECS-OWL.DE"
SAY "                    USE: "
/*Clear RXQUEUE*/
DO WHILE LINES("QUEUE:") > 0
 objecttext = linein("QUEUE:")
END

/*Get Version from GeiMyIP.EXE*/
"@GetMyIP /V | RXQUEUE"
objecttext = linein("QUEUE:")
SAY objecttext 
/*Clear RXQUEUE*/
DO WHILE LINES("QUEUE:") > 0
 objecttext = linein("QUEUE:")
END
SAY " "
SAY " "

GetMyIPicon=installpath||"GetMyIP.ICO"
object_id="<WP_GETMYIP>"

/* parse the string for the ARGs */ 
ARG1=""
PARSE ARG args
SAY args
DO i=1 TO words(args)
	arg = word(args,i)
        IF (arg='ALL5M') then DO
          SAY 'With automatic update every 5 minutes'
	  ARG1=arg	
        END
END
SAY " "

DO FOREVER
 objecttext=""
 /*Get IP with GeiMyIP.EXE*/
 pulltime = Time()
 IF args <> "" then
  "@GetMyIP " || args || " | RXQUEUE"
 IF args = "" then
  "@GetMyIP | RXQUEUE"
 objecttext = linein("QUEUE:")
 SAY objecttext || ' @ ' || pulltime || ' ' || Date()   
 objecttext = objecttext || crlf || pulltime || crlf || Date()
 /* create or upgrade object */
 RC=SysCreateObject('WPProgram',objecttext,'<WP_DESKTOP>','OBJECTID='||object_id||';EXENAME='||ScriptFile||';TITLE='||ObjectText||';ICONFILE='||GetMyIPicon||';PARAMETERS=' || args || ';MINIMIZED=YES;','Update')
 IF (ARG1<>'ALL5M') then DO
    RC=SysCreateObject('WPProgram',objecttext,'<WP_DESKTOP>','OBJECTID='||object_id||';EXENAME='||ScriptFile||';TITLE='||ObjectText||';ICONFILE='||GetMyIPicon||';PARAMETERS=ALL5M ' || args || ';MINIMIZED=YES;','Update')
    exit 
 END 
 /*Clear RXQUEUE*/
 DO WHILE LINES("QUEUE:") > 0
  objecttext = linein("QUEUE:")
 END
 /*Wait 300s */
 waitTime = 300 - (time("s") // 300)
 RC = SysSleep(waitTime)
END
exit

/*----------------------------------------------------------------------------*/
/* If Error :(( then show                                                     */
/*----------------------------------------------------------------------------*/
Error:
        say crlf
        say '-Hoops-'||crlf
        say 'Send this bugreport to :'
        say 'Peter@warp-ecs-owl.de      Subject: WPGetMyIP_all5m Error'
        say ''||crlf
        say 'Version......: ' || Globalsver
        say 'Linenumber...: ' || sigl
        say 'Linetext.....: ' || sourceline(sigl)
        say 'Errorcode....: ' || rc
        say 'Errortext....: ' || errortext(rc)
        say 'Options......: ' || ARG(1)
        say ''||crlf
exit
