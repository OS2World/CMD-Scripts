/* start160.cmd */

/* T.J. Steen - Mijdrecht The Netherlands							*/
/* e-mail : tom@steensoft.demon.nl									*/
/* 20 february 2000													*/
/* This REXX program reads all WAV Files in the source directory	*/
/* and encodes them with LAME.EXE to the destination directory.		*/
/*																	*/
/* Usage : Start160.cmd SourceDir DestinationDir					*/
/* Without parameters the default settings will be used.			*/
/*																	*/
/* Modify the next 3 lines according your needs.					*/

LameOptions 			= '-b160 -h'
DefaultSourceDir 		= 'H:\WAVE'
DefaultDestinationDir 	= 'M:\'

IF LoadRexxUtil() Then Exit

Call SysCls

Parse ARG SourceDir DestinationDir

Say

If (SourceDir = '/?') | (SourceDir = '?')
	Then 
	Do
	Say "Usage : Start160.cmd 'SourceDir' 'DestinationDir'"
	Exit
	End		

If SourceDir 		= '' Then SourceDir = DefaultSourceDir 		
If DestinationDir 	= '' Then DestinationDir = DefaultDestinationDir

SourceDir 		= Strip(SourceDir)
SourceDir 		= Strip(SourceDir,'B',"'")
SourceDir 		= Strip(SourceDir,'T','\')
DestinationDir 	= Strip(DestinationDir)
DestinationDir 	= Strip(DestinationDir,'B',"'")
DestinationDir 	= Strip(DestinationDir,'T','\')

Say '  Source Directory      =' SourceDir
Say '  Destination Directory =' DestinationDir
Say

rc=SysMkDir(DestinationDir)
 
If rc=0 Then Say '  Directory' DestinationDir 'created.'
If rc=3 Then Say '  No destination directory found. Using root of' DestinationDir 'as destination.'
If rc=5 Then Say '  Directory' DestinationDir 'exists.'
If rc>5 Then 
		Do Say	 '  Error creating Directory - Program halted.' 
		Exit
		End


Call SysFileTree SourceDir||'\*.wav', 'Files.', 'FO'

Say
Say ' ' Files.0 'file(s) in directory' SourceDir 'to encode.'
Say

BeginTime = Time()
ElapsedTime = Time('E')

Do i=1 TO Files.0
	TempFileName = Reverse(Files.i)
	Parse Var TempFileName extention '.' FileName '\'
	FileName  = Reverse(FileName)
	DestFile  = DestinationDir||'\'||FileName||'.mp3'
	StartLame = '@LAME.EXE' LameOptions '"'Files.i'"' '"'DestFile'"'
	StartLame
	Say
End

EndTime = Time()
ElapsedTime = Trunc(Time('E'),1)

Hours = Trunc(ElapsedTime/3600)
Min   = Trunc(ElapsedTime/60) - Hours*60
Sec   = ElapsedTime - Hours*3600 - Min*60

Say
Say '  End     time : ' EndTime
Say '  Begin   time : ' BeginTime
Say
Say '  Elapsed time : ' Hours' hours 'Min' minutes 'Sec' seconds' 
Say

Exit

LoadRexxUtil : Procedure
If RxFuncQuery('SysLoadFuncs') Then
	Do
	If RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs') Then
		Do
		Say "Error : Could NOT Load RexxUtil Library."
		Return 1
		End
	Call SysLoadFuncs
	End
Return 0

	