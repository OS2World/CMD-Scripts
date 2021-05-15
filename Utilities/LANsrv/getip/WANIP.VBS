Option Explicit

Dim objRequest, strMsg

If WScript.Arguments.Count > 0 Then Syntax

Set objRequest = CreateObject( "Microsoft.XMLHTTP" )

objRequest.open "GET", "http://www.robvanderwoude.com/wanip.php", False
objRequest.send vbNull

WScript.Echo objRequest.responseText

Set objRequest = Nothing


Sub Syntax( )
	strMsg = "WANIP.vbs, Version 2.00" _
	       & vbCrLf _
	       & "Display your WAN IP address" _
	       & vbCrLf & vbCrLf _
	       & "Usage:  CSCRIPT.EXE  //NoLogo  WANIP.VBS" _
	       & vbCrLf & vbCrLf _
	       & "Original idea: Isaac Zelf" _
	       & vbCrLf _
	       & """Translated"" to VBScript by Rob van der Woude" _
	       & vbCrLf _
	       & "http://www.robvanderwoude.com"
	WScript.Echo strMsg
	WScript.Quit 1
End Sub
