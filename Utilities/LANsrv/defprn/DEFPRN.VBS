' Check for command line arguments (none required)
If WScript.Arguments.Count Then Syntax

' Connect to shell
Set WshShell = WScript.CreateObject("WScript.Shell")

' Read printer info from registry
strPrn = WshShell.RegRead("HKCU\Printers\DeviceOld")

' Format printer info
arrPrn   = Split( strPrn, ",", -1, vbTextCompare )
strDescr = arrPrn(0)
arrPort  = Split( arrPrn(2), ":", -1, vbTextCompare )
strPort  = arrPort(0)

' Display the result
strMsg = vbCrLf & "Default printer is " _
       & strDescr & " on " & strPort
WScript.Echo strMsg


Sub Syntax()
	strMsg = vbCrLf _
	       & "DefPrn.vbs,  Version 1.00" & vbCrLf _
	       & "Display default printer and port" _
	       & vbCrLf & vbCrLf _
	       & "Usage:  CSCRIPT.EXE  DEFPRN.VBS" _
	       & vbCrLf & vbCrLf _
	       & "Written by Rob van der Woude" & vbCrLf _
	       & "http://www.robvanderwoude.com"
	WScript.Echo strMsg
	WScript.Quit(1)
End Sub
