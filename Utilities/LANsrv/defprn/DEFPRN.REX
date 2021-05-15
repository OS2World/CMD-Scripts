/* Check for command line arguments (none required) */
If Arg( 1, "E" ) Then Call Syntax

/* Initialize RexxIO's GetDefaultPrinter() function */
Call RxFuncAdd "GetDefaultPrinter", "REXXIO", "GetDefaultPrinter"

/* Retrieve printer name and port from GetDefaultPrinter() function */
Parse Value GetDefaultPrinter() With defprn",".","defport":"

/* Display the result */
Say
Say "Default printer is "||defprn||" on "||defport

/* Normal program termination */
Exit 0


Syntax:
	Say
	Say "DefPrn.rex,  Version 1.01 for Windows"
	Say "Display default printer name and port"
	Say
	Say "Usage:  <REXX>  DEFPRN.REX"
	Say
	Say 'Where:  "<REXX>" is your Rexx interpreter, like REGINA.EXE'
	Say "                 or REXX.EXE, whichever is installed"
	Say
	Say "This script uses LesTec Pty Ltd.'s RexxIO library"
	Say "http://www.lestec.com.au/"
	Say
	Say "Written by Rob van der Woude"
	Say "http://www.robvanderwoude.com"
	Exit 1
Return
