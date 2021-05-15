' Use custom error handling
On Error Resume Next


' Define constants
Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly       = &h20
Const ForReading                = 1
Const ForWriting                = 2
Const ForAppending              = 8


' Check "named" command line arguments (command line switches)
Select Case WScript.Arguments.Named.Count
	Case 0
		' Default: logging enabled
		boolLog = True
	Case 1
		' /N (No logging) is the only valid switch
		If WScript.Arguments.Named.Exists( "N" ) Then
			boolLog = False
		Else
			Syntax( )
		End If
	Case Else
		' Since /N is the only valid switch, no more than 1 switch is allowed
		Syntax( )
End Select


' Check "unnamed" command line arguments
Select Case WScript.Arguments.Unnamed.Count
	Case 0
		' Default if none specified is local computer (".")
		Set objWMIService = GetObject( "winmgmts://./root/cimv2" )
		' Retrieve computer name
		Set colItems = objWMIService.ExecQuery( "Select * from Win32_ComputerSystem", , _
		               wbemFlagReturnImmediately + wbemFlagForwardOnly )
		For Each objItem in colItems
			strComputer = objItem.Name
		Next
	Case 1
		' Command line argument should not contain "?"
		strComputer = UCase( Wscript.Arguments.Unnamed( 0 ) )
		If InStr( strComputer, "?" ) > 0 Then
			Syntax( )
		End If
	Case Else
		' Maximum is 1 "unnamed" command line parameter
		Syntax( )
End Select


' Initialize variables for message and log headers
strBat = "@ECHO OFF"
strLog = "Computer name: " & strComputer & vbCrLf & "Share name:" & vbTab & "Share path:"
strMsg = "Shares on " & strComputer & ":"


' Create log and batch file if requested
If boolLog Then
	CreateNewLogs( )
End If


' Connect to the specified (or default) computer
Set objWMIService = GetObject( "winmgmts://" & strComputer & "/root/cimv2" )


' Enumerate (non-printer) share info
Set colItems = objWMIService.ExecQuery( "SELECT * FROM Win32_Share WHERE Type = 0", _
               "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly )
For Each objItem In colItems
	' The /GRANT:... part at the end  is required if the shares are to be
	' recreated on Windows Server 2003; remove it for Windows 2000 Servers
	strBat = strBat & "NET SHARE " & Chr(34) & objItem.Name & Chr(34) & "=" _
	       & Chr(34) & objItem.Path & Chr(34) & " /GRANT:Everyone,Full" & vbCrLf
	strLog = strLog & objItem.Name & vbTab & objItem.Path & vbCrLf
	strMsg = strMsg & vbCrLf & objItem.Name & "=" & objItem.Path
Next


' Display result
WScript.Echo strMsg


'Append the results to the log and batch files unless No Logging was specified (/N switch)
If boolLog Then
	' Open File System object
	Set fso = CreateObject( "Scripting.FileSystemObject" )

	' Write result to log file
	Set filOut = fso.OpenTextFile( strComputer & "_shares.csv", ForAppending, True ) 
	filOut.Write( strLog )
	filOut.Close

	' Write result to batch file
	strBat = strBat & "GOTO:EOF" & vbCrLf
	Set filOut = fso.OpenTextFile( strComputer & "_recreate_shares.bat", ForAppending, True ) 
	filOut.Write( strBat )
	filOut.Close

	' Release File System object
	set fso = Nothing
End If


' End of main program
WScript.Quit( 0 )


Sub CreateNewLogs( )
	' Open File System object
	Set fso = CreateObject( "Scripting.FileSystemObject" )
	' Display error number and description if applicable
	If Err Then ShowError( )

	' Create new log file
	Set filOut = fso.OpenTextFile( strComputer & "_shares.csv", ForWriting, True )
	If Err Then ShowError( )
	' Write header
	filOut.WriteLine( strLog )
	If Err Then ShowError( )
	' Close file
	filOut.Close
	If Err Then ShowError( )
	' Reset variable
	strLog = ""

	' Create new batch file
	Set filOut = fso.OpenTextFile( strComputer & "_recreate_shares.bat", ForWriting, True )
	' Write header
	filOut.WriteLine( strBat )
	If Err Then ShowError( )
	' Close file
	filOut.Close
	If Err Then ShowError( )
	' Reset variable
	strBat = ""

	' Release File System object
	set fso = Nothing
End Sub


Sub ShowError( )
	strMsg = vbCrLf & "Error # " & Err.Number & vbCrLf _
	       & Err.Description & vbCrLf & vbCrLf
	Syntax( )
End Sub


Sub Syntax( )
	strMsg = strMsg & vbCrLf _
	       & "ShareMg2.vbs,  Version 2.00" & vbCrLf _
	       & "Prepare to migrate shares from the specified server to a Windows 2003 Server." _
	       & vbCrLf & vbCrLf _
	       & "Usage:  [ CSCRIPT ]  SHAREMG2.VBS  [ servername ]  [ /N ]" _
	       & vbCrLf & vbCrLf _
	       & "Where:  " & Chr(34) & "servername" & Chr(34) _
	       & " is the optional name of the server to be probed" & vbCrLf _
	       & "                     (default is local computer name)" & vbCrLf _
	       & "        /N           Do not log results, nor create the batch file" _
	       & vbCrLf & vbCrLf _
	       & "ShareMg2.vbs creates a batch file named servername_recreate_shares.bat, and" _
	       & vbCrLf _
	       & "a text file listing the original shares. Use servername_recreate_shares.bat" _
	       & vbCrLf _
	       & "to recreate the shares on a new file server. Remove the /GRANT part in" _
	       & vbCrLf _
	       & "servername_recreate_shares.bat to use it with Windows 2000 servers." _
	       & vbCrLf & vbCrLf _
	       & "Written by Rob van der Woude" & vbCrLf _
	       & "http://www.robvanderwoude.com" & vbCrLf & vbCrLf _
	       & "Created with Microsoft's Scriptomatic 2.0 tool" & vbCrLf _
	       & "http://www.microsoft.com/downloads/details.aspx?" & vbCrLf _
	       & "    FamilyID=09dfc342-648b-4119-b7eb-783b0f7d1178&DisplayLang=en"
	WScript.Echo strMsg
	WScript.Quit(1)
End Sub
