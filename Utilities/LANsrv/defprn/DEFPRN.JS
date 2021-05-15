// Define CR/LF
jsCrLf = String.fromCharCode( 13, 10 );

// Check for command line arguments (none required)
objArgs = WScript.Arguments;
if ( objArgs.length != 0 ) {
	strMsg = jsCrLf;
	strMsg = strMsg + "DefPrn.js,  Version 1.00" + jsCrLf;
	strMsg = strMsg + "Display default printer and port";
	strMsg = strMsg + jsCrLf + jsCrLf;
	strMsg = strMsg + "Usage:  CSCRIPT.EXE  DEFPRN.JS";
	strMsg = strMsg + jsCrLf + jsCrLf;
	strMsg = strMsg + "Written by Rob van der Woude" + jsCrLf;
	strMsg = strMsg + "http://www.robvanderwoude.com";
	WScript.Echo( strMsg );
	WScript.Quit(1);
}

// Connect to shell
var WshShell = WScript.CreateObject ( "WScript.Shell" );

// Read printer info from registry
strPrn = WshShell.RegRead ( "HKCU\\Printers\\DeviceOld" );

// Format printer info
arrPrn  = strPrn.split( "," );
arrPort = arrPrn[2].split( ":" );

// Display the result
strMsg = jsCrLf + "Default printer is " + arrPrn[0] + " on " + arrPort[0];
WScript.Echo( strMsg );
