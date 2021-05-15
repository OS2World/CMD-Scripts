Option Explicit

Dim strKey, wshShell

' Create WScript Shell object to read the registry
Set wshShell = CreateObject( "WScript.Shell" )

' Read the current default printer from registry
strKey = "HKEY_CURRENT_USER\Software\Microsoft" _
       & "\Windows NT\CurrentVersion\Windows\Device"
WScript.Echo "Current Default printer : " _
           & Trim( Split( wshShell.RegRead( strKey ), "," )(0) )

' Call the Print Dialog to change the default printer
WScript.Echo "Choose a new default printer..."
ChangePrinterSettings

' Read the new default printer from registry
WScript.Echo "New Default printer     : " _
           & Trim( Split( wshShell.RegRead( strKey ), "," )(0) )

' Release the Shell object
Set wshShell = Nothing


Sub ChangePrinterSettings( )
' Interactively change your printer settings, including the default
' printer. Click the "Print" button to confirm the new printer settings.
'
' Written by Rob van der Woude
' http://www.robvanderwoude.com

	Dim objPrnDlg, strPrompt, strTitle

	Const vbOK     = 1
	Const vbCancel = 2
	Const vbAbort  = 3
	Const vbRetry  = 4
	Const vbIgnore = 5
	Const vbYes    = 6
	Const vbNo     = 7
 
	' Explain there will be no OK button, the Print button must be
	' clicked instead.
	strPrompt = "In the next dialog, choose which printer will " _
	          & "be the new Default Printer and press the " _
	          & """Print"" button to confirm." & vbCrLf & vbCrLf _
	          & "Note that any changes you make in the printer " _
	          & "settings will be permanent, i.e. they will be " _
	          & "the new default settings."
	strTitle  = "Choose New Default Printer and/or Printer Settings"
	If MsgBox( strPrompt, vbOKCancel, strTitle ) = vbOK Then
		' Create a dialog object
		Set objPrnDlg = CreateObject( "MSComDlg.CommonDialog.1" )
		' Make selections permanent
		objPrnDlg.PrinterDefault = True
		' Open the Print dialog
		objPrnDlg.ShowPrinter
		' Release the object
		Set objPrnDlg = Nothing
	End If
End Sub
