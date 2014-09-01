/* Program name:  WPS_NOWH.CMD  Title: Figure 10             */
/* REXX Report              Issue: Summer '95, page 42-51    */
/* Article title: The Workplace Shell: Objects to the Core   */
/* Author: Rony G. Flatscher                                 */
/* Description: utilizing REXX to communicate with the       */
/*              Workplace Shell                              */
/* Program requirements: OS/2 Warp                           */
/*                                                           */


/* WPS_NOWH.CMD: demo setting and starting DOS-programs from nowhere*/

/* change the location to "<WP_DESKTOP>" to check the settings-page */
location = "<WP_NOWHERE>"               /* the "NOWHERE"-location   */

title    = "Test of a DOS-Program from nowhere :-)"
objectid = "<RGF TEST_DOS_IN_NOWHERE>"
setup    = "PROGTYPE=WINDOWEDVDM;"                              ||,
           "EXENAME=*;"                                         ||,
           "PARAMETERS=/k mem.exe;"                             ||,
           "STARTUPDIR=?:\;"                                    ||,
           "SET COM_RECEIVE_BUFFER_FLUSH=SWITCH TO FOREGROUND;" ||,
           "SET DOS_DEVICE=\os2\mdos\ANSI.SYS;"                 ||,
           "SET DOS_VERSION=NETX.EXE^,5^,00^,255,"              ||,
                           "WIN200.BIN^,10^,10^,4;"             ||,
           "SET DOS_UMB=1;"                                     ||,
           "SET EMS_MEMORY_LIMIT=0;"                            ||,
           "SET IDLE_SECONDS=1;"                                ||,
           "SET IDLE_SENSITIVITY=10;"                           ||,
           "SET XMS_MEMORY_LIMIT=4096;"                         ||,
           "OPEN=DEFAULT;"                                      ||,
           "OBJECTID=" || objectid || ";"

ok = SysCreateObject("WPProgram", title, location, setup,,
                     "R")         /* replace, if object exists      */

SAY "creating:" ojbectid "-" worked(ok)
"@PAUSE"

SAY "Cleaning up ..."
ok = SysDestroyObject(objectid)   /* OBJECTID of object             */
SAY "destroying (deleting):" objectid "-" worked(ok)

EXIT

/* procedure to indicate successful/not successful                  */
WORKED: PROCEDURE
   IF ARG(1) THEN RETURN "successful."
             ELSE RETURN "*** NOT succesful ***"
