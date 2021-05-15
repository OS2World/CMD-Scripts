Option Explicit

' Declare variables
Dim blnQuiet
Dim intValidArgs
Dim colItems, objItem, objWMIService
Dim strBoot, strBootDate, strBootDay, strBootHour, strBootMins
Dim strBootMonth, strBootTime, strBootYear, strComputer, strMsg, strQuery

intValidArgs = 0

' Check command line parameters
With WScript.Arguments
	Select Case .Unnamed.Count
		Case 0
			' Default if none specified is local computer (".")
			Set objWMIService = GetObject( "winmgmts://./root/cimv2" )
			strQuery = "Select * from Win32_ComputerSystem"
			Set colItems = objWMIService.ExecQuery( strQuery, , 48 )
			For Each objItem in colItems
				strComputer = objItem.Name
			Next
		Case 1
			' Command line parameter can either be a computer
			' name or "/?" to request online help
			strComputer = UCase( Wscript.Arguments(0) )
		Case Else
			' Maximum is 1 command line parameter, except for the switch
			Syntax
	End Select
	If .Named.Exists( "Q" ) Then
		blnQuiet = True
		intValidArgs = intValidArgs + 1
	End If
	If intValidArgs <> .Named.Count Then Syntax
End With

' Enable error handling
'On Error Resume Next

' Connect to specified computer
Set objWMIService = GetObject( "winmgmts://" & strComputer & "/root/cimv2" )
' Display error number and description if applicable
If Err Then ShowError

Set colItems = objWMIService.ExecQuery( "Select * from Win32_OperatingSystem", , 48 )
For Each objItem in colItems
	If blnquiet Then
		strMsg = Left( objItem.LastBootUpTime, 12 )
	Else
		strBootYear  = Left( objItem.LastBootUpTime, 4 )
		strBootMonth = Mid( objItem.LastBootUpTime,  5, 2 )
		strBootDay   = Mid( objItem.LastBootUpTime,  7, 2 )
		strBootDate  = DateValue( strBootDay & "-" & strBootMonth & "-" & strBootYear )
		strBootHour  = Mid( objItem.LastBootUpTime,  9, 2 )
		strBootMins  = Mid( objItem.LastBootUpTime, 11, 2 )
		strBootTime  = strBootHour & ":" & strBootMins
		strBoot = strBootDate & ", " & strBootTime
		strMsg  = "Last boot time of " & strComputer & ": " & strBoot
	End If
Next

' Display results
WScript.Echo strMsg

'Done
WScript.Quit(0)


Sub ShowError()
	strMsg = vbCrLf & "Error # " & Err.Number & vbCrLf _
	       & Err.Description & vbCrLf & vbCrLf & vbCrLf
	Syntax
End Sub


Sub Syntax( )
	strMsg = strMsg _
	       & "LastBoot.vbs,  Version 2.00" _
	       & vbCrLf _
	       & "Display last boot time for any WMI enabled computer" _
	       & vbCrLf & vbCrLf _
	       & "Usage:  CSCRIPT  //NoLogo  LASTBOOT.VBS  [ computer_name ]  [ /Q ]" _
	       & vbCrLf & vbCrLf _
	       & "Where:  ""computer_name""  is an optional remote computer name" _
	       & vbCrLf _
	       & "                         (default is the local computer name)" _
	       & vbCrLf _
	       & "        /Q               outputs date/time only, in YYYYMMDDhhmm format" _
	       & vbCrLf _
	       & "                         (default is message and DD-MM-YYYY, hh:mm format)" _
	       & vbCrLf & vbCrLf _
	       & "Written by Rob van der Woude" & vbCrLf _
	       & "http://www.robvanderwoude.com"
	WScript.Echo strMsg
	WScript.Quit 1
End Sub
