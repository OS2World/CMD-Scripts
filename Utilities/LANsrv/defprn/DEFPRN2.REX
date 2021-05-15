/* Check for command line arguments (none required) */
If Arg( 1, "E" ) Then Call Syntax

/* Initialize W32Funcs */
Call RxFuncAdd "w32loadfuncs", "W32Util", "w32loadfuncs"
Call w32loadfuncs

/* Read default printer and port from registry */
handle  = w32RegOpenKey( "HKEY_CURRENT_USER", "Printers" )
printer = w32RegQueryValue( handle, "DeviceOld" )
Call w32RegCloseKey handle

/* Parse printer name and port from registry string */
Parse Value printer With defprn",".","defport":".

/* Display the result */
Say
Say "Default printer is "||defprn||" on "||defport

/* Normal program termination */
Exit 0


Syntax:
	Say
	Say "DefPrn.rex,  Version 2.00 for Windows"
	Say "Display default printer name and port"
	Say
	Say "Usage:  <REXX>  DEFPRN.REX"
	Say
	Say 'Where:  "<REXX>" is your Rexx interpreter, like REGINA.EXE'
	Say "                 or REXX.EXE, whichever is installed"
	Say
	Say "This script uses Patrick McPhee's W32Funcs library"
	Say "http://www.interlog.com/~ptjm/"
	Say
	Say "Written by Rob van der Woude"
	Say "http://www.robvanderwoude.com"
	Exit 1
Return
