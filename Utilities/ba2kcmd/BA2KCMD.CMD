/*REXX script for commandline operation of Back Again/2000*/

/*Back Again/2000 is a software backup application from Computer Data Strategies, Incorporated (CDS)*/
/*     Post Office Box 25123, Woodbury, Minnesota 55125; (651) 730-4156 or www.cds-inc.com  for technical support*/




/*Begin registering the REXXUtil Library, if not already registered*/
REXXUtilityFlag = RXFUNCQUERY("SYSLOADFUNCS")
IF REXXUtilityFlag \= 0 THEN DO
	CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
	CALL SysLoadFuncs
END	/*Ends "IF REXXUtilityFlag \= 0 THEN DO" Section*/
/*End registering the REXXUtil Library, if not already registered*/



/*Begin special variables*/
/*Begin variables that concern the viability of the BA2KCMD_CONFIG.CMD subprocedure file*/
BA2KCMD_CONFIGFlag = ""
BA2KCMD_CONFIGErrorMessage. = ""
ErrorCount = 0
ErrorMessage.1 = "No REXX QUEUE commands were found in the BA2KCMD_CONFIG.CMD file."
ErrorMessage.2 = "ClbackCommand.0.0 value is "
ErrorMessage.3 = "ClbackCommand.0."
ErrorMessage.4 = 'ClbackCommand.'
ErrorMessage.5 = 'ClbackCommand.'
/*End variables that concern the viability of the BA2KCMD_CONFIG.CMD subprocedure file*/


/*Begin flag variables and miscellaneous variables*/
UpdateFlag = 0
FileSizeWarningFlag = 0
UpdateDateFlag. = 0
MultipleBackupsFlag = 0
Red_Text = "1B"x || "[1;31;40m"
Ansi_Off = "1B"x || "[0m"
/*End flag variables and miscellaneous variables*/


/*Begin specifying data on the backup types*/
MaxHPFSFileSizeBytes = 2147483648	/*that is, 2GB*/
MaxHPFSFileSizeGBytes = 2
MaxJFSFileSizeBytes = 2147483648	/*that is, 2GB*/
MaxJFSFileSizeGBytes = 2
MaxFATFileSizeBytes = 2147483648	/*that is, 2GB*/
MaxFATFileSizeGBytes = 2
MaxFAT32FileSizeBytes = 2147483648	/*that is, 2GB*/
MaxFAT32FileSizeGBytes = 2
MaxNTFSFileSizeBytes = 2147483648	/*that is, 2GB*/
MaxNTFSFileSizeGBytes = 2
MaxLANFileSizeBytes = 2147483648	/*that is, 2GB*/
MaxLANFileSizeGBytes = 2
/*End specifying data on the backup types*/


/*Begin section names, or titles, for the BA2KCMD_CONFIG.CMD REXX configuration file*/
SectionName.1 = '"Text File List Backup'
SectionName.2 = '"Text File List Of Recursive File Patterns'
SectionName.3 = '"Append To An Existing Backup'
SectionName.4 = '"Backup Changed Files, Only'
SectionName.5 = '"Use Software Compression'
SectionName.6 = '"Perform A Compare'
SectionName.7 = '"Backup To Device'
SectionName.8 = '"Backup Description'
SectionName.9 = '"Eject The Media'
SectionName.10 = '"Erase The Media'
SectionName.11 = '"Exclude Files'
SectionName.12 = '"Exclude Files Recursively In Subdirectories'
SectionName.13 = '"Include Files'
SectionName.14 = '"Include Files Recursively In Subdirectories'
SectionName.15 = '"Move Files To The Backup'
SectionName.16 = '"Name The Backup'
SectionName.17 = '"Backup No Hidden Files'
SectionName.18 = '"Backup No System Files'
SectionName.19 = '"Backup No Empty Files'
SectionName.20 = '"Retension The Media'
SectionName.21 = '"Save The Backup Set'
SectionName.22 = '"Set The Backup Set'
SectionName.23 = '"Backup Type'
SectionName.24 = '"Perform An Unattended Backup'
SectionName.25 = '"Monitor file size of non-tape backups'
SectionName.26 = '"Have updated date in the backup filename'
SectionName.27 = '"Perform multiple backups in sequence'
/*End section names, or titles, for the BA2KCMD_CONFIG.CMD REXX configuration file*/


/*Begin the array elements for changing the commandline options*/
Change.1.Type = "1_CheckFiles"
Change.1.0.Option = ""
Change.1.1.Option = "-@ "
Change.1.0.Text = "Disable the backup of files listed in a text file"
Change.1.1.Text = "Enable the backup of files listed in a text file"
Change.2.Type = "1_CheckFiles"
Change.2.0.Option = ""
Change.2.1.Option = "-@R "
Change.2.0.Text = "Disable the backup from a file list of recursive file patterns"
Change.2.1.Text = "Enable a backup, using a file list of recursive file patterns"
Change.3.Type = "1_CheckFilesAppend"
Change.3.0.Option = ""
Change.3.1.Option = "-append"
Change.3.0.Text = "Do not append this backup to an existing backup"
Change.3.1.Text = "Append this backup to an existing backup"
Change.4.Type = 1
Change.4.0.Option = ""
Change.4.1.Option = "-changed"
Change.4.0.Text = "Disable the backing up of changed files, only"
Change.4.1.Text = "Back up changed files, only"
Change.5.Type = 4
Change.5.0.Option = ""
Change.5.1.Option = "-comp none"
Change.5.2.Option = "-comp fast"
Change.5.3.Option = "-comp small"
Change.5.4.Option = "-comp balanced"
Change.5.0.Text = "Disable the software compression option"
Change.5.1.Text = 'Use "None" software compression in the backup'
Change.5.2.Text = 'Use "Fast" software compression in the backup'
Change.5.3.Text = 'Use "Small" software compression in the backup'
Change.5.4.Text = 'Use "Balanced" software compression in the backup'
Change.6.Type = 1
Change.6.0.Option = ""
Change.6.1.Option = "-compare"
Change.6.0.Text = "Disable the comparison pass after the backup"
Change.6.1.Text = "Enable the comparison pass after the backup"
Change.7.Type = "3_Device"
Change.7.0.Option = ""
Change.7.1.Option = "-d SCSITAPE:"
Change.7.2.Option = "-d EIDETAPE:"
Change.7.3.Option = "-d "
Change.7.0.Text = "Disable the specification of a backup device"
Change.7.1.Text = "Use a SCSI tape backup device"
Change.7.2.Text = "Use an EIDE tape backup device"
Change.7.3.Text = "Use a drive, or logical, backup device"
Change.8.Type = "1_SimpleWrite"
Change.8.0.Option = ""
Change.8.1.Option = "-desc "
Change.8.0.Text = "Disable the option for a backup description string"
Change.8.1.Text = "Create or provide a backup description string"
Change.9.Type = 1
Change.9.0.Option = ""
Change.9.1.Option = "-eject"
Change.9.0.Text = "Disable the option to eject of the media after the backup"
Change.9.1.Text = "Eject of the media after the backup"
Change.10.Type = 1
Change.10.0.Option = ""
Change.10.1.Option = "-erase"
Change.10.0.Text = "Disable the option to erase of the media before the backup"
Change.10.1.Text = "Erase of the media before the backup"
Change.11.Type = "1_CheckFileSpecifications"
Change.11.0.Option = ""
Change.11.1.Option = "-e "
Change.11.2.Option = " -e "
Change.11.0.Text = "Disable the exclusion of files matching a file spec."
Change.11.1.Text = "Exclude files matching a file spec."
Change.11.2.Text = "Exclude additional files matching a file spec."
Change.12.Type = "1_CheckFileSpecifications"
Change.12.0.Option = ""
Change.12.1.Option = "-er "
Change.12.2.Option = " -er "
Change.12.0.Text = "Disable the recursive exclusion of files matching a file spec."
Change.12.1.Text = "Recursively exclude files matching a file spec."
Change.12.2.Text = "Recursively exclude additional files matching a file spec."
Change.13.Type = "1_CheckFileSpecifications"
Change.13.0.Option = ""
Change.13.1.Option = "-i "
Change.13.2.Option = " -i "
Change.13.0.Text = "Disable the inclusion of files matching a file spec."
Change.13.1.Text = "Include files matching a file spec."
Change.13.2.Text = "Include additional files matching a file spec."
Change.14.Type = "1_CheckFileSpecifications"
Change.14.0.Option = ""
Change.14.1.Option = "-ir "
Change.14.2.Option = " -ir "
Change.14.0.Text = "Disable the recursive inclusion of files matching a file spec."
Change.14.1.Text = "Recursively include files matching a file spec."
Change.14.2.Text = "Recursively include additional files matching a file spec."
Change.15.Type = 1
Change.15.0.Option = ""
Change.15.1.Option = "-move"
Change.15.0.Text = "Disable the option to move files to the backup"
Change.15.1.Text = "Move files to the backup (deletes files after backup)"
Change.16.Type = "1_SimpleWrite"
Change.16.0.Option = ""
Change.16.1.Option = "-name "
Change.16.0.Text = "Disable the option for a backup name"
Change.16.1.Text = "Create or provide a backup name"
Change.17.Type = 1
Change.17.0.Option = ""
Change.17.1.Option = "-nohidden"
Change.17.0.Text = "Disable the option not back up hidden files"
Change.17.1.Text = "Do not back up hidden files"
Change.18.Type = 1
Change.18.0.Option = ""
Change.18.1.Option = "-nosystem"
Change.18.0.Text = "Disable the option not back up system files"
Change.18.1.Text = "Do not back up system files"
Change.19.Type = 1
Change.19.0.Option = ""
Change.19.1.Option = "-noempty"
Change.19.0.Text = "Disable the option to not backup empty files"
Change.19.1.Text = "Do not back up empty files"
Change.20.Type = 1
Change.20.0.Option = ""
Change.20.1.Option = "-reten"
Change.20.0.Text = "Disable the option to retension the media before the backup"
Change.20.1.Text = "Retension the media before the backup"
Change.21.Type = "1_SaveBackupSet"
Change.21.0.Option = ""
Change.21.1.Option = "-save "
Change.21.0.Text = "Disable the option to save the backup set"
Change.21.1.Text = "Save the backup set as a specified filename"
Change.22.Type = "1_UseBackupSet"
Change.22.0.Option = ""
Change.22.1.Option = "-set "
Change.22.0.Text = "Disable the option to use a specific backup set"
Change.22.1.Text = "Use a specified backup set"
Change.23.Type = 4
Change.23.0.Option = ""
Change.23.1.Option = "-type full"
Change.23.2.Option = "-type copy"
Change.23.3.Option = "-type diff"
Change.23.4.Option = "-type incr"
Change.23.0.Text = "Disable the option specifying the type of backup"
Change.23.1.Text = 'Make a "Full" backup'
Change.23.2.Text = 'Make a "Copy" backup'
Change.23.3.Text = 'Make a "Differential" backup'
Change.23.4.Text = 'Make an "Incremental" backup'
Change.24.Type = 1
Change.24.0.Option = ""
Change.24.1.Option = "-unattended"
Change.24.0.Text = "Disable the option to back up in unattended mode"
Change.24.1.Text = "Run the backup in unattended mode"
Change.25.Type = "6_CheckBackupFileSize"
Change.25.0.Option = ""
Change.25.1.Option = "-HPFS"
Change.25.2.Option = "-JFS"
Change.25.3.Option = "-FAT"
Change.25.4.Option = "-FAT32"
Change.25.5.Option = "-NTFS"
Change.25.6.Option = "-LAN"
Change.25.0.Text = "Disable the file size overflow warning"
Change.25.1.Text = "Enable warning for HPFS file size overflow (> "MaxHPFSFileSizeGBytes"GB)"
Change.25.2.Text = "Enable warning for JFS file size overflow (> "MaxJFSFileSizeGBytes"GB)"
Change.25.3.Text = "Enable warning for FAT file size overflow (> "MaxFATFileSizeGBytes"GB)"
Change.25.4.Text = "Enable warning for FAT32 file size overflow (> "MaxFAT32FileSizeGBytes"GB)"
Change.25.5.Text = "Enable warning for NTFS file size overflow (> "MaxNTFSFileSizeGBytes"GB)"
Change.25.6.Text = "Enable warning for LAN file size overflow (> "MaxLANFileSizeGBytes"GB)"
Change.26.Type = "1_UpdateDate"
Change.26.0.Option = ""
Change.26.1.Option = "-date"
Change.26.0.Text = "Disable the updating of a date within the backup filename"
Change.26.1.Text = "Enable the updating a date within the backup filename"
Change.27.Type = "1_MultipleBackups"
Change.27.0.Option = ""
Change.27.1.Option = "-m"
Change.27.0.Text = "Disable automatic multiple sequential backups"
Change.27.1.Text = "Enable automatic multiple sequential backups"
/*End the array elements for changing the commandline options*/
/*End special variables*/



/*Begin finding the necessary, user system-specific information*/
/*Begin finding the File Spec information on this REXX program, or script, and assigning its value to the variable, ProgramLocation, here in this program*/
PARSE SOURCE OperatingSystem HowCalled FileSpec
ProgramLocation = ""
FileSpecPortion = FileSpec
DO UNTIL FileSpecPortion = ""
	PARSE Var FileSpecPortion FirstPart "\" SecondPart
	SELECT
		WHEN ProgramLocation = "" & SecondPart \= "" THEN ProgramLocation = FirstPart
		WHEN ProgramLocation \= "" & SecondPart \= "" THEN ProgramLocation = ProgramLocation"\"FirstPart
		OTHERWISE NOP
	END	/*Ends "SELECT" Section*/
	FileSpecPortion = SecondPart
END	/*Ends "DO UNTIL FileSpecPortion = """ Section*/
/*End finding the File Spec information on this REXX program, or script, and assigning its value to the variable, ProgramLocation, here in this program*/


/*Begin verifying that this REXX program is in the same directory as the Back Again/2000 commandline program, CLBACK.EXE*/
FileSearchPath = ProgramLocation"\CLBACK.EXE"
CALL FILESEARCH
SELECT
	WHEN FileSearchPathResults.0 = 0 THEN DO
		RC = SYSCLS()
		SAY ""
		SAY "This REXX script automates the task of creating Back Again/2000 backups,"
		SAY "     using its commandline facility, CLBACK.EXE."
		SAY ""
		SAY "Use http://www.cds-inc.com/, or (651) 730-4156, for Computer Data"
		SAY "     Strategies, Incorporated (CDS) Back Again/2000 technical support."
		SAY ""
		SAY "This program cannot find the Back Again/2000 commandline facility,"
		SAY "     CLBACK.EXE. Two programs have to be in the same directory."
		SAY "     Please find CLBACK.EXE and place this program in that directory."
		SAY "     Then, restart it."
		SAY ""
		SAY "Usually, CLBACK.EXE is in the main directory of your Back Again/2000"
		SAY "     installation (where BAII.EXE is located)."
		SAY ""
		SAY "Press the "Red_Text"ENTER"Ansi_Off" key to now end this program."
		PARSE PULL KeyResponse
		RC = SYSCLS()
		SIGNAL FINISH
	END	/*Ends "WHEN FileSearchPathResults.0 = 1 THEN DO" Section*/

	OTHERWISE NOP
END	/*Ends "SELECT" Section*/
/*End verifying that this REXX program is in the same directory as the Back Again/2000 commandline program, CLBACK.EXE*/


/*Begin finding the installed, or recognized drive information*/
DDrive. = ""
Drive. = ""
Map = SYSDRIVEMAP(, "USED")
J = 0
DO UNTIL Map = ""
	J = J + 1
	PARSE VAR Map First Remainder
	DDrive.J.PPartition = First
	FileSystem = TRANSLATE(SYSFILESYSTEMTYPE(DDrive.J.PPartition))
	DDrive.J.DriveLetter = LEFT(DDrive.J.PPartition, 1)
	DDrive.J.CapDriveLetter = TRANSLATE(DDrive.J.DriveLetter, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz")
	DDrive.J.DriveNumber = J
	DDrive.J.FFileSystem = FileSystem
	Map = Remainder
END	/*Ends "DO UNTIL Map = """ Section*/
DDrive.0 = J


J = 0
DO I = 1 TO DDrive.0 BY 1
	IF DDrive.I.FFileSystem = "HPFS" | DDrive.I.FFileSystem = "JFS" | DDrive.I.FFileSystem = "FAT" | DDrive.I.FFileSystem = "FAT32" | DDrive.I.FFileSystem = "NTFS" | DDrive.I.FFileSystem = "LAN" THEN DO
		J = J + 1
		Drive.J.PPartition = DDrive.I.PPartition
		Drive.J.DriveLetter = DDrive.I.DriveLetter
		Drive.J.CapDriveLetter = DDrive.I.CapDriveLetter
		Drive.J.DriveNumber = J
		Drive.J.FFileSystem = DDrive.I.FFileSystem
	END	/*Ends "IF DDrive.I.FFileSystem = "HPFS" | DDrive.I.FFileSystem = "JFS" | DDrive.I.FFileSystem = "FAT" | DDrive.I.FFileSystem = "FAT32" | DDrive.I.FFileSystem = "NTFS" | DDrive.I.FFileSystem = "LAN" THEN DO" Section*/
END I
Drive.0 = J
/*End finding the installed, or recognized drive information*/


/*Begin getting the date information*/
SortDate = DATE("S")
PARSE VAR SortDate Year 5 Month 7 Day
/*End getting the date information*/



/*Begin setting the user defaults for the CLBACK parameters for each backup*/
DO J = 1 TO Drive.0 BY 1
	Default.1.J = ""
	Default.2.J = ""
	Default.3.J = ""
	Default.4.J = ""
	Default.5.J = "-comp none"
	Default.6.J = ""
	IF Drive.J.FFileSystem = "FAT" THEN Default.7.J = "-d "Drive.J.PPartition"\"Drive.J.CapDriveLetter"_FULL.DAT"
	ELSE Default.7.J = "-d "Drive.J.PPartition"\"Drive.J.CapDriveLetter"_FULL_"Month||Day||Year".DAT"
	Default.8.J = "-desc Full_Backup_of_"Drive.J.PPartition"\*.*"
	Default.9.J = ""
	Default.10.J = ""
	Default.11.J = "-e "Drive.J.PPartition"\*.DAT"
	Default.12.J = ""
	Default.13.J = ""
	Default.14.J = "-ir "Drive.J.PPartition"\*"
	Default.15.J = ""
	Default.16.J = "-name "Drive.J.CapDriveLetter"_FULL"
	Default.17.J = ""
	Default.18.J = ""
	Default.19.J = ""
	Default.20.J = ""
	Default.21.J = ""
	Default.22.J = ""
	Default.23.J = ""
	Default.24.J = ""
	Default.25.J = ""
	Default.26.J = ""
	Default.27.J = ""
	Default.0.J = 27
END J	/*Ends "DO J = 1 TO Drive.0 BY 1" Section*/
/*End setting the user defaults for the CLBACK parameters for each backup*/


/*Begin getting user specific data from the BA2KCMD_CONFIG.CMD REXX script file*/
GETBA2KCMDCONFIG:
RC = SYSCLS()
FileSearchPath = ProgramLocation"\BA2KCMD_CONFIG.CMD"
CALL FILESEARCH
SELECT
	WHEN FileSearchPathResults.0 = 0 THEN DO
		BA2KCMD_CONFIGFlag = 0
		SAY ""
		SAY "This REXX script automates the task of creating Back Again/2000 backups,"
		SAY "     using its commandline facility, CLBACK.EXE."
		SAY ""
		SAY "Use http://www.cds-inc.com/, or (651) 730-4156, for Computer Data"
		SAY "     Strategies, Incorporated (CDS) Back Again/2000 technical support."
		SAY ""
		SAY "Please wait ...,"
		RC = SYSSLEEP(10)
		RC = SYSCLS()
		SAY ""
		SAY "The program cannot find the required subprocedure file, the one that"
		SAY "     contains the user configuration of desired commandline backups. It"
		SAY "     will now create a new subprocedure file with default settings for"
		SAY "     the user, commandline backups."
		SAY ""
		SAY "Don't worry! Later, you will get a chance to change the various defaults"
		SAY "     to the values you want."
		SAY ""
		SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
		PARSE PULL KeyResponse
		RC = SYSCLS()
		DO J = 1 TO Drive.0 BY 1
			DO I = 1 TO Default.0.J BY 1
				Set_ClbackCommand.I.J = '"'Default.I.J'"'
			END I	/*Ends "DO I = 1 TO Default.0.J BY 1" Section*/
			Set_ClbackCommand.0.J = Default.0.J
		END J	/*Ends "DO J = 1 TO Drive.0 BY 1" Section*/
		Set_ClbackCommand.0.0 = Drive.0
		BA2KCMD_CONFIGPath = ProgramLocation"\BA2KCMD_CONFIG.CMD"
		RC = SYSFILEDELETE(BA2KCMD_CONFIGPath)
		CALL CONSTRUCTBA2KCMDCONFIG
		RC = SYSSLEEP(1)
		SAY ""
		SAY "Successfully created the user configuration file:"
		SAY ""
		SAY "     "BA2KCMD_CONFIG_CMD_Path
		SAY ""
		SAY "It presently has "Drive.0" user, commandline backups with default settings."
		SAY "     You can only have up to "Drive.0" commandline backups, the same as the"
		SAY "     the number of non-removable partitions on your system (both local and"
		SAY "     network partitions). You can modify the configuration file to have"
		SAY "     fewer backups, but never more than the total number of partitions."
		SAY ""
		SAY "You must have Object REXX installed to use this program (not Classical"
		SAY "     REXX). You should have a color monitor. Object REXX is necessary,"
		SAY "     because the program contains enhanced code that Classical REXX"
		SAY "     does not provide. A color monitor is needed because the program "
		SAY "     presents color enhanced, text-based instructions and prompts. The"
		SAY "     user responds by pressing a key corresponding to a number or letter."
		SAY "     The choice of selectable numbers or letters is always shown in the"
		SAY "     specific instructions. The ones that can be selected are indicated"
		SAY '     as 'Red_Text'Red'Ansi_Off' characters. For this very reason please run this REXX'
		SAY "     program from a commandline, and not from PMREXX."
		SAY ""
		SAY "Thank you and press the "Red_Text"ENTER"Ansi_Off" key to continue!"
		PARSE PULL KeyResponse
		RC = SYSCLS()
	END	/*Ends "WHEN FileSearchPathResults.0 = 0 THEN DO" Section*/

	WHEN FileSearchPathResults.0 = 1 THEN DO
		/*Begin testing for the viability of the configuration variables*/
		/*Begin establishing the PARSE PULL command to read all of the queued variables from BA2KCMD_CONFIG.CMD*/
		BA2KCMD_CONFIGPath = FileSearchPathResults.1
		I = 0
		DO WHILE LINES(BA2KCMD_CONFIGPath) \= 0
			I = I + 1
			LLine.I = LINEIN(BA2KCMD_CONFIGPath)
		END	/*Ends "DO WHILE LINES(BA2KCMD_CONFIGPath) \= 0" Section*/
		LLine.0 = I
		RC = LINEOUT(BA2KCMD_CONFIGPath, , 1)
		RC = LINEOUT(BA2KCMD_CONFIGPath)
		J = 0
		DO I = 1 TO LLine.0 BY 1
			IF WORDPOS("QUEUE", LLine.I) > 0 THEN DO
				First = ""
				Second = ""
				PARSE VAR LLine.I First Second
				J = J + 1
				PullFromQueue.J = "PARSE PULL "Second
			END	/*Ends "IF WORDPOS("QUEUE", LLine.I) > 0 THEN DO" Section*/
		END I	/*Ends "DO I = 1 TO LLine.0 BY 1" Section*/
		PullFromQueue.0 = J
		/*End establishing the PARSE PULL command to read all of the queued variables from BA2KCMD_CONFIG.CMD*/

		SELECT
			WHEN PullFromQueue.0 = 0 THEN DO
				ErrorCount = ErrorCount + 1
				BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.1
				CALL ERRORFILE
				BA2KCMD_CONFIGFlag = 0
			END	/*Ends "WHEN PullFromQueue.0 = 0 THEN DO" Section*/

			OTHERWISE DO
				/*Begin establishing the QUEUE for BA2KCMD_CONFIG.CMD*/
				NewQueue = RXQUEUE("CREATE","CCONFIG")
				SELECT
					WHEN NewQueue = "CCONFIG" THEN NOP

					OTHERWISE DO
						d = RXQUEUE("DELETE",NewQueue)
						NewQueue = "CCONFIG"
					END	/*Ends "OTHERWISE DO" Section*/
				END	/*Ends "SELECT" Section*/
				BA2KQueue = RXQUEUE("SET",NewQueue)
				/*End establishing the QUEUE for BA2KCMD_CONFIG.CMD*/

				Command = 'CALL "'BA2KCMD_CONFIGPath'"'
				INTERPRET Command
				DO I = 1 TO PullFromQueue.0 BY 1
					INTERPRET PullFromQueue.I
				END I	/*Ends "DO I = 1 TO PullFromQueue.0 BY 1" Section*/
				d = RXQUEUE("DELETE","CCONFIG")

				/*Begin simple integrity checks of the BA2KCMD_CONFIG.CMD file*/
				CALL INTEGRITYCHECK
				SELECT
					WHEN ErrorCount > 0 THEN DO
						CALL ERRORFILE
						ErrorCount = 0
						BA2KCMD_CONFIGFlag = 0
					END	/*Ends "WHEN ErrorCount > 0 THEN DO" Section*/

					OTHERWISE DO
						MultipleBackupsCount = 0 
						DO J = 1 TO ClbackCommand.0.0 BY 1
							DO I = 1 TO ClbackCommand.0.J BY 1
								TempClbackCommand.I.J = ClbackCommand.I.J
							END I	/*Ends "DO I = 1 TO ClbackCommand.0.J BY 1" Section*/
							TempClbackCommand.0.J = ClbackCommand.0.J
							IF TempClbackCommand.26.J = "-date" THEN UpdateDateFlag.J = 1
							IF TempClbackCommand.27.J = "-m" THEN MultipleBackupsCount = MultipleBackupsCount + 1
						END J	/*Ends "DO J = 1 TO ClbackCommand.0.0 BY 1" Section*/
						TempClbackCommand.0.0 = ClbackCommand.0.0
						IF MultipleBackupsCount > 1 THEN MultipleBackupsFlag = 1
					END	/*Ends "OTHERWISE DO" Section*/
				END	/*Ends "SELECT" Section*/
				/*End simple integrity checks of the BA2KCMD_CONFIG.CMD file*/
			END	/*Ends "OTHERWISE DO" Section*/
		END	/*Ends "SELECT" Section*/
		/*End testing for the viability of the configuration variables*/
	END	/*Ends "WHEN FileSearchPathResults.0 = 1 THEN DO" Section*/

	OTHERWISE NOP
END	/*Ends "SELECT" Section*/
/*End getting user specific data from the BA2KCMD_CONFIG.CMD REXX script file*/
IF BA2KCMD_CONFIGFlag = 0 THEN DO
	BA2KCMD_CONFIGFlag = ""
	SIGNAL GETBA2KCMDCONFIG
END	/*Ends "IF BA2KCMD_CONFIGFlag = 0 THEN DO" Section*/
/*End finding the necessary, user system-specific information*/



/*Begin selecting and/or modifying a commandline backup*/
BEGININTRODUCTION:
RC = SYSCLS()
SAY ""
SAY "This REXX script automates the task of creating Back Again/2000"
SAY "     commandline backups (http://www.cds-inc.com/,"
SAY "     or (651) 730-4156 for Back Again/2000 technical support)"
BEGINMAINMENU:
SAY ""
SAY "                        **********MAIN MENU**********"
SAY 'Choose one of the following. Type and enter the 'Red_Text'Red'Ansi_Off' number to select'
SAY "     (in some cases you can enter either a number or a letter):"
SAY ""
DO I = 1 TO ClbackCommand.0.0 BY 1
	PARSE VAR ClbackCommand.8.I First Description
	IF Description = "" THEN DO
		SELECT
			WHEN ClbackCommand.22.I = "" THEN Description = "No User Description Provided!"
			OTHERWISE Description = "Info. Provided In A Backup Set!"
		END	/*Ends "SELECT" Section*/
	END	/*Ends "IF Description = "" THEN DO" Section*/
	SAY "     "Red_Text||I||Ansi_Off".  "Description
END I	/*Ends "DO I = 1 TO ClbackCommand.0.0 BY 1" Section*/
IF MultipleBackupsFlag = 1 THEN DO
	SAY "     "Red_Text||I||Ansi_Off".  "Red_Text||M||Ansi_Off"ultiple backups, sequentially performed"
	I = I + 1
END	/*Ends "IF MultipleBackupsFlag = 1 THEN DO" Section*/
SAY "     "Red_Text||I||Ansi_Off".  "Red_Text"R"Ansi_Off"eview the selected options in a commandline backup"
I = I + 1
SAY "     "Red_Text||I||Ansi_Off".  Change the backup "Red_Text"o"Ansi_Off"ptions for a commandline backup"


IF ClbackCommand.0.0 > 1 THEN DO
	I = I + 1
	DeleteNumber = I
	SAY "     "Red_Text||I||Ansi_Off".  "Red_Text"D"Ansi_Off"elete one of the commandline backups"
END	/*Ends "IF ClbackCommand.0.0 > 1 THEN DO" Section*/


IF ClbackCommand.0.0 < Drive.0 THEN DO
	I = I + 1
	CreateNumber = I
	AvailableRemaining = Drive.0 - ClbackCommand.0.0
	IF AvailableRemaining = 1 THEN DO
		RightWord1 = ""
		RightWord2 = "backup"
	END	/*Ends "" Section*/
	ELSE DO
		RightWord1 = "up to "
		RightWord2 = "backups"
	END	/*Ends "" Section*/
	SAY "     "Red_Text||I||Ansi_Off".  "Red_Text"C"Ansi_Off"reate "RightWord1||AvailableRemaining" new commandline "RightWord2" (you have "ClbackCommand.0.0"; "Drive.0" are allowed)"
END	/*Ends "IF ClbackCommand.0.0 < Drive.0 THEN DO" Section*/
I = I + 1
ExitNumber = I
SAY "     "Red_Text||I||Ansi_Off".  Press the "Red_Text"ENTER"Ansi_Off" key, only, to exit and end this script"
SAY ""
SAY "Please type and enter your choice now!"Red_Text
PARSE UPPER PULL UserChoice
SAY ""Ansi_Off
RC = SYSCLS()

IF MultipleBackupsFlag = 1 THEN TotalBackupChoices = (ClbackCommand.0.0 + 1)
ELSE TotalBackupChoices = ClbackCommand.0.0
SELECT
	WHEN (DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= TotalBackupChoices) | UserChoice = "M" THEN DO
		SELECT
			WHEN UserChoice <= ClbackCommand.0.0 THEN CALL CONSTRUCTCOMMANDLINE

			WHEN (UserChoice = TotalBackupChoices | UserChoice = "M") & MultipleBackupsFlag = 1 THEN DO
				DO R = 1 TO ClbackCommand.0.0 BY 1
					IF ClbackCommand.27.R = "-m" THEN DO
						UserChoice = R
						CALL CONSTRUCTCOMMANDLINE
					END	/*Ends "IF ClbackCommand.27.R "-m" THEN DO" Section*/
				END R	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
			END	/*Ends "WHEN UserChoice = TotalBackupChoices & MultipleBackupsFlag = 1 THEN DO" Section*/

			OTHERWISE NOP
		END	/*Ends "SELECT" Section*/
	END	/*Ends "WHEN (DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= TotalBackupChoices) | UserChoice = "M" THEN DO" Section*/

	WHEN UserChoice = (TotalBackupChoices + 1) | UserChoice = "R" THEN DO
		RC = SYSCLS()
		SAY ""
		SAY "Select a commandline backup to review its options:"
		CALL BACKUPLIST
		SELECT
			WHEN DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= ClbackCommand.0.0 THEN DO
				CALL SELECTEDOPTIONS
				SIGNAL BEGINMAINMENU
			END	/*Ends "WHEN DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= ClbackCommand.0.0 THEN DO" Section*/

			WHEN UserChoice = "" THEN SIGNAL BEGINMAINMENU

			OTHERWISE NOP
		END	/*Ends "SELECT" Section*/
	END	/*Ends "WHEN UserChoice = (TotalBackupChoices + 1) | UserChoice = "R" THEN DO" Section*/

	WHEN UserChoice = (TotalBackupChoices + 2)  | UserChoice = "O" THEN DO
	RC = SYSCLS()
		SAY ""
		SAY "Select a commandline backup to change its options:"
		CALL BACKUPLIST
	SELECT
			WHEN DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= ClbackCommand.0.0 THEN DO
				CALL CHANGEOPTIONS
				SIGNAL BEGINMAINMENU
			END	/*Ends "WHEN DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= ClbackCommand.0.0 THEN DO" Section*/

			WHEN UserChoice = "" THEN SIGNAL BEGINMAINMENU

			OTHERWISE NOP
		END	/*Ends "SELECT" Section*/		
	END	/*Ends "WHEN UserChoice = (TotalBackupChoices + 2)  | UserChoice = "O" THEN DO" Section*/

	WHEN UserChoice = CreateNumber  | UserChoice = "C" THEN DO
		SELECT
			WHEN AvailableRemaining = 1 THEN DO
				NumberOfBackupsToCreate = 1
				CorrectWord1 = "backup"
				CorrectWord2 = "its"
				CALL CREATECOMMANDLINE
				CALL CONSTRUCTBA2KCMDCONFIG
				BA2KCMD_CONFIGFlag = 0
				SAY ""
				SAY "Creation completed!"
				RC = SYSSLEEP(2)
				RC = SYSCLS()
				SIGNAL GETBA2KCMDCONFIG
			END	/*Ends "" Section*/

			OTHERWISE DO
				RC = SYSCLS()
				SAY ""
				SAY "How many (new) commandline backups to you wish? You can have as"
				SAY "     many as "AvailableRemaining"."
				SAY ""
				SAY "Enter your choice now."Red_Text
				PARSE UPPER PULL NumberOfBackupsToCreate
				SAY ""Ansi_Off
				RC = SYSCLS()
				SELECT
					WHEN DATATYPE(NumberOfBackupsToCreate) = "NUM" & NumberOfBackupsToCreate <= AvailableRemaining THEN DO
						SELECT
							WHEN NumberOfBackupsToCreate = 1 THEN DO
								CorrectWord1 = "backup"
								CorrectWord2 = "its"
							END	/*Ends "WHEN NumberOfBackupsToCreate = 1 THEN DO" Section*/

							OTHERWISE DO
								CorrectWord1 = "backups"
								CorrectWord2 = "their"
							END	/*Ends "OTHERWISE DO" Section*/
						END	/*Ends "SELECT" Section*/
						CALL CREATECOMMANDLINE
						CALL CONSTRUCTBA2KCMDCONFIG
						BA2KCMD_CONFIGFlag = 0
						SAY ""
						SAY "Creation completed!"
						RC = SYSSLEEP(2)
						RC = SYSCLS()
						SIGNAL GETBA2KCMDCONFIG
					END	/*Ends "WHEN DATATYPE(NumberOfBackupsToCreate) = "NUM" & NumberOfBackupsToCreate <= AvailableRemaining THEN DO" Section*/

					WHEN DATATYPE(NumberOfBackupsToCreate) = "NUM" & NumberOfBackupsToCreate > AvailableRemaining THEN DO
						SAY ""
						SAY "Sorry, you already have "ClbackCommand.0.0" commandline backups. Only "Drive.0" are allowed!"
						SAY "     Therefore you can only create "AvailableRemaining" more!"
						SAY ""
						SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
						PARSE UPPER PULL KeyResponse
						RC = SYSCLS()
						SIGNAL BEGINMAINMENU
					END	/*Ends "WHEN DATATYPE(NumberOfBackupsToCreate) = "NUM" & NumberOfBackupsToCreate > AvailableRemaining THEN DO" Section*/

					OTHERWISE DO
						SAY ""
						SAY "Sorry, that response is not recognized! Press the "Red_Text"ENTER"Ansi_Off" key to continue."
						PARSE UPPER PULL KeyResponse
						RC = SYSCLS()
						SIGNAL BEGINMAINMENU
					END	/*Ends "OTHERWISE DO" Section*/
				END	/*Ends "SELECT" Section*/
			END	/*Ends "OTHERWISE DO" Section*/
		END	/*Ends "SELECT" Section*/
	END	/*Ends "WHEN UserChoice = CreateNumber  | UserChoice = "C" THEN DO" Section*/

	WHEN UserChoice = DeleteNumber  | UserChoice = "D" THEN DO
		SELECT
			WHEN ClbackCommand.0.0 = 1 THEN DO
				RC = SYSCLS()
				SAY ""
				SAY "Sorry, you only have one (1) commandline backup remaining. You cannot"
				SAY "     delete it."
				SAY ""
				SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue"
				PARSE PULL KeyResponse
				RC = SYSCLS()
				SIGNAL BEGINMAINMENU
			END	/*Ends "WHEN ClbackCommand.0.0 = 1 THEN DO" Section*/

			OTHERWISE DO
				RC = SYSCLS()
				SAY ""
				SAY "Select a commandline backup to delete:"
				CALL BACKUPLIST
				SELECT
					WHEN DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= ClbackCommand.0.0 THEN DO
						CALL DELETECOMMANDLINE
						UpdateFlag = 1
						SIGNAL BEGINMAINMENU
					END	/*Ends "WHEN DATATYPE(UserChoice) = "NUM" & UserChoice >= 1 & UserChoice <= ClbackCommand.0.0 THEN DO" Section*/

					WHEN UserChoice = "" THEN SIGNAL BEGINMAINMENU

					OTHERWISE SIGNAL BEGINMAINMENU
				END	/*Ends "SELECT" Section*/
			END	/*Ends "OTHERWISE DO" Section*/
		END	/*Ends "SELECT" Section*/
	END	/*Ends "WHEN UserChoice = DeleteNumber  | UserChoice = "D" THEN DO" Section*/

	WHEN UserChoice = ExitNumber | UserChoice = "" THEN SIGNAL FINISH

	OTHERWISE SIGNAL FINISH
END	/*Ends "SELECT" Section*/
/*End selecting and/or modifying a commandline backup*/



/*Begin closing out the script and exiting*/
FINISH:	/*End the script*/
/*Begin updating the BA2KCMD_CONFIG.CMD file, if required*/
IF UpdateFlag = 1 THEN DO
	RC = SYSCLS()
	SAY ""
	SAY "Now updating the BA2KCMD_CONFIG.CMD file to include the commandline"
	SAY "     option changes that you made. Please wait ...,"
	RC = SYSSLEEP(2)
	DO J = 1 TO ClbackCommand.0.0 BY 1
		DO I = 1 TO ClbackCommand.0.J BY 1
			Set_ClbackCommand.I.J = '"'ClbackCommand.I.J'"'
		END I	/*Ends "DO I = 1 TO ClbackCommand.0.J BY 1" Section*/
		Set_ClbackCommand.0.J = ClbackCommand.0.J
	END J	/*Ends "DO J = 1 TO ClbackCommand.0.0 BY 1" Section*/
	Set_ClbackCommand.0.0 = ClbackCommand.0.0
	RC = SYSFILEDELETE(BA2KCMD_CONFIGPath)
	CALL CONSTRUCTBA2KCMDCONFIG
	RC = SYSCLS()
	SAY ""
	SAY "Update complete...,"
	SAY ""
	SAY "Please do not destroy or manually alter BA2KCMD_CONFIG.CMD. If you do"
	SAY "     and you change it incorrectly, the consequences are yours!"
	SAY ""
	SAY "Instead, use only this REXX program to update BA2KCMD_CONFIG.CMD."
	SAY "     Thank you! Please wait ...,"
	RC = SYSSLEEP(8)
END	/*Ends "IF UpdateFlag = 1 THEN DO" Section*/
/*End updating the BA2KCMD_CONFIG.CMD file, if required*/


/*Begin deregistering the REXX Utility functions and closing out this script*/
IF REXXUtilityFlag \= 0 THEN CALL SysDropFuncs
/*End deregistering the REXX Utility and closing out this script*/
EXIT
/*End closing out the script and exiting*/









/*NOTE: All subprocedures for CALL statements are below this line*/
/*Begin the call to the SYSFILETREE REXX utility function to test for the existence of a file*/
FILESEARCH:
FileSearchPathResults. = ""
RC = SYSFILETREE(FileSearchPath, "FileSearchPathResults", "FO")
RETURN
/*Begin the call to the SYSFILETREE REXX utility function to test for the existence of a file*/









/*Begin creation of, or updating of the BA2KCMD_CONFIG.CMD file*/
CONSTRUCTBA2KCMDCONFIG:
/*Begin constructing the code for BA2KCMD_CONFIG.CMD line by line*/
OptionStop = Default.0.1
Count = 0
Count = Count + 1
Line.Count = "/******This REXX script provides user-specific configuration information for the BA2K.CMD script******/"


DO I = 1 TO OptionStop BY 1
	DO J = 1 TO 3 BY 1
		Count = Count + 1
		Line.Count = ""
	END J	/*Ends "DO J = 1 TO 3 BY 1" Section*/

	Count = Count + 1
	Line.Count = '/*Begin CLBACK.EXE 'SectionName.I' Command Section"*/'
	DO J = 1 TO Set_ClbackCommand.0.0 BY 1
		Count = Count + 1
		Line.Count = "ClbackCommand."I"."J" = "Set_ClbackCommand.I.J
	END J	/*Ends "DO J = 1 TO Set_ClbackCommand.0.0 BY 1" Section*/
	Count = Count + 1
	Line.Count = '/*End CLBACK.EXE 'SectionName.I' Command Section"*/'
END I	/*Ends "DO I = 1 TO OptionStop BY 1" Section*/



DO J = 1 TO 3 BY 1
	Count = Count + 1
	Line.Count = ""
END J	/*Ends "DO J = 1 TO 3 BY 1" Section*/


Count = Count + 1
Line.Count = "/*Begin establishing various subtotals*/"
DO J = 1 TO Set_ClbackCommand.0.0 BY 1
Count = Count + 1
Line.Count = "ClbackCommand.0."J" = "Set_ClbackCommand.0.J
END J	/*Ends "DO J = 1 TO Set_ClbackCommand.0.0 BY 1" Section*/
Count = Count + 1
Line.Count = "ClbackCommand.0.0 = "Set_ClbackCommand.0.0
Count = Count + 1
Line.Count = "/*End establishing various subtotals*/"


DO J = 1 TO 3 BY 1
	Count = Count + 1
	Line.Count = ""
END J	/*Ends "DO J = 1 TO 3 BY 1" Section*/


Count = Count + 1
Line.Count = "/*Begin QUEUING the user configuration variable data*/"
Count = Count + 1
Line.Count = 'NewQueue = "CCONFIG"'
Count = Count + 1
Line.Count = 'ActiveQueue = RXQUEUE("SET",NewQueue)'
DO J = 1 TO Set_ClbackCommand.0.0 BY 1
	DO I = 1 TO OptionStop BY 1
		Count = Count + 1
		Line.Count = "QUEUE ClbackCommand."I"."J""
	END I	/*Ends "DO I = 1 TO OptionStop" Section*/
	Count = Count + 1
	Line.Count = "QUEUE ClbackCommand.0."J""
END J	/*Ends "DO J = 1 TO Set_ClbackCommand.0.0 BY 1" Section*/
Count = Count + 1
Line.Count = "QUEUE ClbackCommand.0.0"
Count = Count + 1
Line.Count = "/*End QUEUING the user configuration variable data*/"
Count = Count + 1
Line.Count = "RETURN"
Line.0 = Count
/*End constructing the code for BA2KCMD_CONFIG.CMD line by line*/



/*Begin writing the BA2KCMD_CONFIG.CMD file*/
BA2KCMD_CONFIG_CMD_Path = ProgramLocation"\BA2KCMD_CONFIG.CMD"
DO J = 1 TO Line.0 BY 1
	RC = LINEOUT(BA2KCMD_CONFIG_CMD_Path, Line.J)
END J
RC = LINEOUT(BA2KCMD_CONFIG_CMD_Path)
Count = ""
/*End writing the BA2KCMD_CONFIG.CMD file*/
RETURN
/*End creation of, or updating of, the BA2KCMD_CONFIG.CMD file*/









/*Begin simple integrity checks of the BA2KCMD_CONFIG.CMD file*/
INTEGRITYCHECK:
BA2KCMD_CONFIGErrorMessage. = ""
/*Begin the integrity check for the ClbackCommand.0.0 variable*/
SELECT
	WHEN DATATYPE(ClbackCommand.0.0) = "CHAR" THEN DO
		ErrorCount = ErrorCount + 1
		BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.2'"'ClbackCommand.0.0'" (non-numeric).'
		IntegrityStop1 = Drive.0
	END	/*Ends "WHEN DATATYPE(ClbackCommand.0.0) = "CHAR" THEN DO" Section*/

	WHEN ClbackCommand.0.0 > Drive.0 THEN DO
		ErrorCount = ErrorCount + 1
		BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.2||ClbackCommand.0.0", which is greater than the number of partitions you have."
		IntegrityStop1 = Drive.0
	END	/*Ends "WHEN ClbackCommand.0.0 > Drive.0 THEN DO" Section*/

	OTHERWISE IntegrityStop1 = ClbackCommand.0.0
END	/*Ends "SELECT" Section*/
/*End the integrity check for the ClbackCommand.0.0 variable*/



/*Begin the integrity check for the ClbackCommand.J.I variables*/
DO I = 1 TO IntegrityStop1 BY 1
	SELECT
		WHEN DATATYPE(ClbackCommand.0.I) = "CHAR" THEN DO
			ErrorCount = ErrorCount + 1
			BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.3||I' value is "'ClbackCommand.0.I'" (non-numeric).'
			IntegrityStop2 = Default.0.I
		END	/*Ends "WHEN DATATYPE(ClbackCommand.0.0) = "CHAR" THEN DO" Section*/

		WHEN ClbackCommand.0.I \= Default.0.I THEN DO
			ErrorCount = ErrorCount + 1
			BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.3||I" value is "ClbackCommand.0.I", not equal to the number of CLBACK commandline options."
			IntegrityStop2 = Default.0.I
		END	/*Ends "WHEN ClbackCommand.0.0 \= Default.0.I THEN DO" Section*/

		OTHERWISE IntegrityStop2 = Default.0.I
	END	/*Ends "SELECT" Section*/

	DO J = 1 TO IntegrityStop2 BY 1
		IF ClbackCommand.J.I = "CLBACKCOMMAND."J"."I THEN DO
			ErrorCount = ErrorCount + 1
			BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.4||J'.'I' value is incorrect as "CLBACKCOMMAND.'J'.'I'".'
		END	/*Ends "IF ClbackCommand.J.I = "CLBACKCOMMAND."J"."I THEN DO" Section*/

		IntegrityStop3 = LEFT(Change.J.Type, 1)
		IntegrityFlag3 = 0
		DO K = 0 TO IntegrityStop3 BY 1
			SELECT
				WHEN K = 0 & ClbackCommand.J.I = "" THEN DO
					IntegrityFlag3 = 1
					LEAVE K
				END	/*Ends "WHEN K = 0 & ClbackCommand.J.I = "" THEN DO" Section*/

				OTHERWISE DO
					IF POS(Change.J.K.Option, ClbackCommand.J.I) > 0 THEN DO
						IntegrityFlag3 = 1
						LEAVE K
					END	/*Ends "IF POS(Change.J.K.Option, ClbackCommand.J.I) > 0 THEN DO" Section*/
				END	/*Ends "OTHERWISE DO" Section*/
			END	/*Ends "DO K = 0 TO IntegrityStop3 BY 1" Section*/
		END K	/*Ends "SELECT" Section*/
		IF IntegrityFlag3 = 0 THEN DO
			ErrorCount = ErrorCount + 1
			BA2KCMD_CONFIGErrorMessage.ErrorCount = ErrorMessage.5||J'.'I' value should equal "", or include'
			DO K = 1 TO IntegrityStop3 BY 1
				SELECT
					WHEN K = IntegrityStop3 & IntegrityStop3 = 1 THEN
					BA2KCMD_CONFIGErrorMessage.ErrorCount = BA2KCMD_CONFIGErrorMessage.ErrorCount' or "'Change.J.K.Option'".'

					WHEN K = IntegrityStop3 & IntegrityStop3 \= 1 THEN
					BA2KCMD_CONFIGErrorMessage.ErrorCount = BA2KCMD_CONFIGErrorMessage.ErrorCount', "'Change.J.K.Option'".'

					OTHERWISE BA2KCMD_CONFIGErrorMessage.ErrorCount = BA2KCMD_CONFIGErrorMessage.ErrorCount' or "'Change.J.K.Option'"'
				END	/*Ends "SELECT" Section*/
			END K	/*Ends "DO K = 1 TO IntegrityStop3 BY 1" Section*/
		END	/*Ends "IF IntegrityFlag3 = 0 THEN DO" Section*/
	END J	/*Ends "DO J = 1 TO IntegrityStop2 BY 1" Section*/
END I	/*Ends "DO I = 1 TO IntegrityStop1 BY 1" Section*/
/*End the integrity check for the ClbackCommand.J.I variables*/
RETURN
/*End simple integrity checks of the BA2KCMD_CONFIG.CMD file*/









/*Begin constructing and saving the BA2KCMD_CONFIG.ERR file*/
ERRORFILE:
/*Begin the introduction*/
RC = SYSCLS()
SAY ""
SAY "Detected some errors in the BA2KCMD_CONFIG.CMD file. To fix them"
SAY "     this program will do the following:"
SAY ""
SAY "          1. Construct diagnostic error messages"
SAY "          2. Delete the error containing BA2KCMD_CONFIG.CMD file"
SAY "          3. Write and save a new file, BA2KCMD_CONFIG.ERR, that"
SAY "               contains the original, BA2KCMD_CONFIG.CMD file contents,"
SAY "               plus the diagnostic error messages"
SAY "          4. Construct a new BA2KCMD_CONFIG.CMD file with default values"
SAY ""
SAY "Later you can use BA2KCMD_CONFIG.ERR and this program to update the new"
SAY "     BA2KCMD_CONFIG.CMD file with the values you want. Update it, using"
SAY "     the automated facilities of this REXX program, and referring to the"
SAY "     BA2KCMD_CONFIG.ERR file only for the good values that it contains"
SAY "     and that you want. DO NOT manually update BA2KCMD_CONFIG.CMD (using"
SAY "     a text editor, for example)."
SAY ""
SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
PARSE PULL KeyResponse
/*End the introduction*/



Kount = LLine.0
DO J = 1 TO 3 BY 1
	Kount = Kount + 1
	LLine.Kount = ""
END J	/*Ends "DO J = 1 TO 3 BY 1" Section*/
Kount = Kount + 1
LLine.Kount = "/*Begin error messages section for the saved and erroneous BA2KCMD_CONFIG.ERR file*/"
DO J = 1 TO ErrorCount BY 1
	Kount = Kount + 1
	LLine.Kount = BA2KCMD_CONFIGErrorMessage.J
END J	/*Ends "" Section*/
Kount = Kount + 1
LLine.Kount = "/*End error messages section for saved and erroneous BA2KCMD_CONFIG.ERR file*/"



/*Begin writing the BA2KCMD_CONFIG.ERR file*/
BA2KCMD_CONFIG_CMD_Path = ProgramLocation"\BA2KCMD_CONFIG.CMD"
RC = SYSFILEDELETE(BA2KCMD_CONFIGPath)
BA2KCMD_CONFIG_ERR_Path = ProgramLocation"\BA2KCMD_CONFIG.ERR"
RC = SYSFILEDELETE(BA2KCMD_CONFIG_ERR_Path)
DO J = 1 TO Kount BY 1
	RC = LINEOUT(BA2KCMD_CONFIG_ERR_Path, LLine.J)
END J
RC = LINEOUT(BA2KCMD_CONFIG_ERR_Path)
Kount = ""
/*End writing the BA2KCMD_CONFIG.ERR file*/



RC = SYSCLS
SAY ""
SAY "BA2KCMD_CONFIG.ERR successfully written and saved. Please wait...,"
RC = SYSSLEEP(6)
RC = SYSCLS
RETURN
/*End constructing and saving the BA2KCMD_CONFIG.ERR file*/









/*Begin constructing the commandline for CLBACK.EXE to execute the desired backup*/
CONSTRUCTCOMMANDLINE:
CommandLine = "CLBACK.EXE"
CommandLineStop = (TempClbackCommand.0.UserChoice - 3)
DO I = 1 TO 6 BY 1
	SELECT
		WHEN TempClbackCommand.I.UserChoice \= "" THEN
		CommandLine = Commandline" "TempClbackCommand.I.UserChoice

		OTHERWISE NOP
	END	/*Ends "SELECT" Section*/
END	/*Ends "DO I = 1 TO 6 BY 1" Section*/


SELECT
	WHEN UpdateDateFlag.UserChoice = 0 THEN Restart = 7

	OTHERWISE DO
		Today = Month||Day||Year
		CheckUnderScore = ""
		CheckUnderScorePosition = 0
		IF POS(Today, ClbackCommand.7.UserChoice) > 1 THEN DO
			CheckUnderScorePosition = POS(Today, ClbackCommand.7.UserChoice) - 1
			IF SUBSTR(ClbackCommand.7.UserChoice, CheckUnderScorePosition, 1) = "_" THEN CheckUnderScore = "_"
		END	/*Ends "IF POS(Today, ClbackCommand.7.UserChoice) > 0 THEN DO" Section*/
		IF POS(Today, ClbackCommand.7.UserChoice) < 1 | CheckUnderScore = "" THEN DO
			PARSE VAR ClbackCommand.7.UserChoice First "." FileNameExtension
			FileNameRoot = ""
			FFirst = First
			DO UNTIL FFirst = ""
				PARSE VAR FFirst FFFirst "_" Remainder
				SELECT
					WHEN FileNameRoot = "" THEN FileNameRoot = FFFirst
					WHEN FileNameRoot \= "" & Remainder \= "" THEN FileNameRoot = FileNameRoot"_"FFFirst
					OTHERWISE PossibleDate = FFFirst
				END	/*Ends "SELECT" Section*/
				FFirst = Remainder
			END	/*Ends "DO UNTIL FFirst = """ Section*/
			Question1 = "False"	/*Test to see if the "possible date" portion contains 8 numerical digits*/
			Question2 = "False"	/*Test to see if the "year" portion of the possible date equals this year or last year*/
			Question3 = "False"	/*Test to see if the first digit of the month portion of the possible date has an acceptable value (0 or 1)*/
			Question4 = "False"	/*Test to see if the second digit of the month portion of the possible date has an acceptable value*/
			Question5 = "False"	/*Test to see if the possible date equals today's date*/
			IF LENGTH(PossibleDate) = 8 THEN DO
				Question1 = "True"
				IF RIGHT(PossibleDate, 4) = Year | RIGHT(PossibleDate, 4) = (Year - 1) THEN DO
					Question2 = "True"
					IF LEFT(PossibleDate, 1) = 0 THEN DO
						Question3 = "True"
						IF SUBSTR(PossibleDate, 2, 1) \= 0 THEN Question4 = "True"
					END	/*Ends "IF LEFT(PossibleDate, 1) = 0 THEN DO" Section*/
					ELSE DO
						IF LEFT(PossibleDate, 1) = 1 THEN Question3 = "True"
						IF SUBSTR(PossibleDate, 2, 1) < 3 THEN Question4 = "True"
					END	/*Ends "ELSE DO" Section*/
				END	/*Ends "IF RIGHT(PossibleDate, 4) = Year | RIGHT(PossibleDate, 4) = (Year - 1) THEN DO" Section*/
			END	/*Ends "IF LENGTH(PossibleDate) = 8 THEN DO" Section*/
			IF Question1 = "False" | Question2 = "False" | Question3 = "False" | Question4 = "False" THEN FileNameRoot = First
			ELSE DO
				IF PossibleDate = Today THEN Question5 = "True"
				NOP
			END	/*Ends "ELSE DO" Section*/
			SELECT
				WHEN Question5 = "True" THEN NOP

				OTHERWISE DO
					ClbackCommand.7.UserChoice = FileNameRoot"_"Today".DAT"
					TempClbackCommand.7.UserChoice =FileNameRoot"_"Today".DAT"
					IF ClbackCommand.25.UserChoice \= "" THEN DO
						PARSE VAR ClbackCommand.25.UserChoice First Second
						ClbackCommand.25.UserChoice = First" 0"
						TempClbackCommand.25.UserChoice = First" 0"
					END	/*Ends "IF ClbackCommand.25.UserChoice \= "" THEN DO" Section*/
					UpdateFlag = 1
				END	/*Ends "OTHERWISE DO" Section*/
			END	/*Ends "SELECT" Section*/
		END	/*Ends "IF POS(Today, ClbackCommand.7.UserChoice) < 1 | CheckUnderScore = "" THEN DO" Section*/
		CommandLine = Commandline" "TempClbackCommand.7.UserChoice
		Restart = 8
	END	/*Ends "OTHERWISE DO" Section*/
END	/*Ends "SELECT" Section*/

DO I = Restart TO CommandLineStop BY 1
	SELECT
		WHEN TempClbackCommand.I.UserChoice \= "" THEN
		CommandLine = Commandline" "TempClbackCommand.I.UserChoice

		OTHERWISE NOP
	END	/*Ends "SELECT" Section*/
END I	/*Ends "DO I = Restart TO CommandLineStop BY 1" Section*/

SELECT
	WHEN TempClbackCommand.25.UserChoice \= "" THEN DO
		IF TempClbackCommand.7.UserChoice \= "" THEN DO
			PARSE VAR TempClbackCommand.7.UserChoice dVariable TestPath
				IF TestPath \= "SCSITAPE:" & TestPath \= "EIDETAPE:" THEN DO
					FileSearchPathResults. = ""
					RC = SYSFILETREE(TestPath, "FileSearchPathResults", "F")
					IF FileSearchPathResults.0 = 1 THEN
					PARSE VAR FileSearchPathResults.1 BackupFFileDate BackupFFileTime BackupFFileSize1 BackupFileAttributes BackupFFilePath

					ELSE DO
						BackupFFilePath = TestPath
						BackupFFileSize1 = 0
					END	/*Ends "ELSE DO" Section*/
					FileSizeWarningFlag = 1
					PARSE VAR TempClbackCommand.25.UserChoice TempClbackCommand25 BackupFFileSizeIncrease
				END	/*Ends "IF TestPath \= "SCSITAPE:" & TestPath \= "EIDETAPE:" THEN DO" Section*/
		END	/*Ends "IF TempClbackCommand.7.UserChoice \= "" THEN DO" Section*/
	END	/*Ends "WHEN TempClbackCommand.25.UserChoice \= "" THEN DO" Section*/

	OTHERWISE NOP
END	/*Ends "SELECT" Section*/
IF FileSizeWarningFlag = 1 THEN DO
	SELECT
		WHEN TempClbackCommand25 = "-HPFS" THEN EstimatedBackupFFileOverflow = BackupFFileSize1 + BackupFFileSizeIncrease*1.1 - MaxHPFSFileSizeBytes
		WHEN TempClbackCommand25 = "-JFS" THEN EstimatedBackupFFileOverflow = BackupFFileSize1 + BackupFFileSizeIncrease*1.1 - MaxJFSFileSizeBytes
		WHEN TempClbackCommand25 = "-FAT" THEN EstimatedBackupFFileOverflow = BackupFFileSize1 + BackupFFileSizeIncrease*1.1 - MaxFATFileSizeBytes
		WHEN TempClbackCommand25 = "-FAT32" THEN EstimatedBackupFFileOverflow = BackupFFileSize1 + BackupFFileSizeIncrease*1.1 - MaxFAT32FileSizeBytes
		WHEN TempClbackCommand25 = "-NTFS" THEN EstimatedBackupFFileOverflow = BackupFFileSize1 + BackupFFileSizeIncrease*1.1 - MaxNTFSFileSizeBytes
		WHEN TempClbackCommand25 = "-LAN" THEN EstimatedBackupFFileOverflow = BackupFFileSize1 + BackupFFileSizeIncrease*1.1 - MaxLANFileSizeBytes
		OTHERWISE NOP
	END	/*Ends "SELECT" Section*/
	IF EstimatedBackupFFileOverflow > 0 THEN DO
		RC = SYSCLS()
		SAY ""
		SAY "It is likely that this next backup will be too large and will thus"
		SAY "     violate the maximum file size limit. If that occurs, CLBACK.EXE"
		SAY "     will terminate the backup before its completion. It will be"
		SAY "     incomplete."
		SAY ""
		SAY "Proceed with the backup anyway?"
		SAY "     "Red_Text"1"Ansi_Off". "Red_Text"Y"Ansi_Off"es"
		SAY "     "Red_Text"2"Ansi_Off". "Red_Text"N"Ansi_Off"o"
		SAY "Please type and enter your choice now!"Red_Text
		PARSE UPPER PULL ContinueResponse
		SAY ""Ansi_Off
		RC = SYSCLS()
		SELECT
			WHEN ContinueResponse = 1 | ContinueResponse = "Y" THEN DO
				CommandLine = '"'CommandLine'"'
				"ECHO OFF"
				INTERPRET CommandLine
			END	/*Ends "WHEN ContinueResponse = 1 | ContinueResponse = "Y" THEN DO" Section*/

			OTHERWISE SIGNAL BEGINMAINMENU
		END	/*Ends "SELECT" Section*/
	END	/*Ends "IF EstimatedBackupFFileOverflow > 0 THEN DO" Section*/

	ELSE DO
		CommandLine = '"'CommandLine'"'
		"ECHO OFF"
		INTERPRET CommandLine
	END	/*Ends "ELSE DO" Section*/
END	/*Ends "IF FileSizeWarningFlag = 1 THEN DO" Section*/

ELSE DO
	CommandLine = '"'CommandLine'"'
	"ECHO OFF"
	INTERPRET CommandLine
END	/*Ends "ELSE DO" Section*/

IF FileSizeWarningFlag = 1 THEN DO
	FileSearchPathResults. = ""
	RC = SYSFILETREE(BackupFFilePath, "FileSearchPathResults", "F")
	PARSE VAR FileSearchPathResults.1 BackupFFileDate BackupFFileTime BackupFFileSize2 BackupFileAttributes BackupFFilePath
	BackupFFileSizeIncrease = BackupFFileSize2 - BackupFFileSize1
	ClbackCommand.25.UserChoice = TempClbackCommand25" "BackupFFileSizeIncrease
	TempClbackCommand.25.UserChoice = TempClbackCommand25" "BackupFFileSizeIncrease
	UpdateFlag = 1
END	/*Ends "IF FileSizeWarningFlag = 1 THEN DO" Section*/
RETURN
/*End constructing the commandline for CLBACK.EXE to execute the desired backup*/









/*Begin constructing the list of commandline backups for review and/or modification*/
BACKUPLIST:
SAY ""
SAY "              **********LIST OF USER COMMANDLINE BACKUPS**********"
DO I = 1 TO ClbackCommand.0.0 BY 1
	PARSE VAR ClbackCommand.8.I First Description
	IF Description = "" THEN DO
		SELECT
			WHEN ClbackCommand.22.I = "" THEN Description = "No User Description Provided!"
			OTHERWISE Description = "Info. Provided In A Backup Set!"
		END	/*Ends "SELECT" Section*/
	END	/*Ends "IF Description = "" THEN DO" Section*/
	SAY "     "Red_Text||I||Ansi_Off".  "Description
END I	/*Ends "DO I = 1 TO ClbackCommand.0.0 BY 1" Section*/
SAY ""
SAY "Or, press the "Red_Text"ENTER"Ansi_Off" key to turn to the MAIN MENU. Enter your choice now!"Red_Text
PARSE UPPER PULL UserChoice
SAY ""Ansi_Off
RC = SYSCLS()
RETURN
/*End constructing the list of commandline backups for review and/or modification*/









/*Begin constructing the list and description of the selected options for a given commandline backup*/
SELECTEDOPTIONS:
RC = SYSCLS()
PARSE VAR ClbackCommand.8.UserChoice First Description
IF Description = "" THEN DO
	SELECT
		WHEN ClbackCommand.22.I = "" THEN Description = "No User Description Provided!"
		OTHERWISE Description = "Info. Provided In A Backup Set!"
	END	/*Ends "SELECT" Section*/
END	/*Ends "IF Description = "" THEN DO" Section*/
SAY "OPTIONS SELECTED FOR BACKUP # "UserChoice": "Description
SAY ""
SAY "#        Option Description                     Current Option Value"
DO I = 1 TO 16 BY 1
	DescriptionLength = LENGTH(SectionName.I) - 1
	IF I < 10 THEN Entry = I".  "SUBSTR(SectionName.I, 2, DescriptionLength)
	ELSE Entry = I". "SUBSTR(SectionName.I, 2, DescriptionLength)
	EntryLength = LENGTH(Entry)
	SpaceAmount = 50 - EntryLength
	DO J = 1 TO SpaceAmount BY 1
		Entry = Entry" "
	END J	/*Ends "DO J = 1 TO SpaceAmount BY 1" Section*/
	Entry = Entry||ClbackCommand.I.UserChoice
	SAY Entry
END I	/*Ends "DO I = 1 TO 16 BY 1" Section*/
SAY ""
SAY "A blank option value indicates that option is not in the commandline"
SAY "backup (it was not selected). Press the "Red_Text"ENTER"Ansi_Off" key to continue this list."
PARSE PULL KeyResponse

RC = SYSCLS()
SAY "OPTIONS SELECTED FOR BACKUP # "UserChoice": "Description
SAY ""
SAY "#        Option Description                     Current Option Value"
DO I = 17 TO ClbackCommand.0.UserChoice BY 1
	DescriptionLength = LENGTH(SectionName.I) - 1
	IF I < 10 THEN Entry = I".  "SUBSTR(SectionName.I, 2, DescriptionLength)
	ELSE Entry = I". "SUBSTR(SectionName.I, 2, DescriptionLength)
	EntryLength = LENGTH(Entry)
	SpaceAmount = 50 - EntryLength
	DO J = 1 TO SpaceAmount BY 1
		Entry = Entry" "
	END J	/*Ends "DO J = 1 TO SpaceAmount BY 1" Section*/
	Entry = Entry||ClbackCommand.I.UserChoice
	SAY Entry
END I	/*Ends "DO I = 17 TO ClbackCommand.0.UserChoice BY 1" Section*/
SAY ""
SAY "A blank option value indicates that option is not in the commandline"
SAY "backup (it was not selected). Press the "Red_Text"ENTER"Ansi_Off" key to continue."
PARSE PULL KeyResponse
RC = SYSCLS()
RETURN
/*End constructing the list and description of the selected options for a given commandline backup*/









/*Begin constructing the changing of one or more options for a commandline backup*/
CHANGEOPTIONS:
I = 0
CHANGEOPTIONSMENU:
SelectedOptionsFlag = 0
SkipOptionsFlag = 0
DO UNTIL I = ClbackCommand.0.UserChoice
	RC = SYSCLS()
	I = I + 1
	PARSE VAR ClbackCommand.8.UserChoice First Description
	IF Description = "" THEN DO
		SELECT
			WHEN ClbackCommand.22.I = "" THEN Description = "No User Description Provided!"
			OTHERWISE Description = "Info. Provided In A Backup Set!"
		END	/*Ends "SELECT" Section*/
	END	/*Ends "IF Description = "" THEN DO" Section*/
	SAY "CHANGE OPTIONS FOR BACKUP # "UserChoice": "Description
	SAY ""
	SAY "#        Option Description                     Current Option Value" 
	DescriptionLength = LENGTH(SectionName.I) - 1
	IF I < 10 THEN Entry = I".  "SUBSTR(SectionName.I, 2, DescriptionLength)
	ELSE Entry = I". "SUBSTR(SectionName.I, 2, DescriptionLength)
	EntryLength = LENGTH(Entry)
	SpaceAmount = 50 - EntryLength
	DO J = 1 TO SpaceAmount BY 1
		Entry = Entry" "
	END J	/*Ends "DO J = 1 TO SpaceAmount BY 1" Section*/
	Entry = Entry||ClbackCommand.I.UserChoice
	SAY Entry

	SAY ""
	SAY "Available choices:"
	Instruction = ""
	PARSE VAR Change.I.Type Stop "_"Instruction
	K = 0
	K_Total = ""
	K_Stop = ""
	Selection. = ""
	IF ClbackCommand.I.UserChoice \= "" THEN DO
		K = K + 1
		SAY "     "Red_Text||K||Ansi_Off". "Change.I.0.Text
		Selection.K = Change.I.0.Option
		IF I = 11 | I = 12 | I = 13 | I = 14 THEN DO
			K = K + 1
			SAY"     "Red_Text||K||Ansi_Off". "Change.I.2.Text
			Selection.K = Change.I.2.Option
		END	/*Ends "IF I = 11 | I = 12 | I = 13 | I = 14 THEN DO" Section*/
	END	/*Ends "IF ClbackCommand.I.UserChoice \= "" THEN DO" Section*/


	SelectedDDevice = SUBSTR(ClbackCommand.7.UserChoice,1,7)
	SelectedDDeviceDrive = ""
	SelectedDDeviceFileSystem = ""
	IF SelectedDDevice \= "" | SelectedDDevice \= "-d SCSI" | SelectedDDevice \= "-d EIDE" THEN DO
		SelectedDDeviceDrive = TRANSLATE(SUBSTR(SelectedDDevice, 4, 1))
		DO R = 1 TO DDrive.0 BY 1
			IF SelectedDDeviceDrive = DDrive.R.CapDriveLetter THEN DO
				SelectedDDeviceFileSystem = DDrive.R.FFileSystem
				LEAVE R
			END	/*Ends "IF SelectedDDeviceDrive = DDrive.R.CapDriveLetter THEN DO" Section*/
		END R	/*Ends "DO R = 1 TO DDrive.0 BY 1" Section*/
	END	/*Ends "IF SelectedDDevice \= "" | SelectedDDevice \= "-d SCSI" | SelectedDDevice \= "-d EIDE" THEN DO" Section*/


	DO J = 1 TO Stop BY 1
		IF POS(Change.I.J.Option, ClbackCommand.I.UserChoice) = 0 THEN DO
			SELECT
				WHEN (I = 25 | I = 26) & (SelectedDDevice = "" | SelectedDDevice = "-d SCSI" | SelectedDDevice = "-d EIDE") THEN NOP

				WHEN I = 25 & SelectedDDeviceFileSystem = "HPFS" & J \= 1 THEN NOP

				WHEN I = 25 & SelectedDDeviceFileSystem = "JFS" & J \= 2 THEN NOP

				WHEN I = 25 & SelectedDDeviceFileSystem = "FAT" & J \= 3 THEN NOP

				WHEN I = 25 & SelectedDDeviceFileSystem = "FAT32" & J \= 4 THEN NOP

				WHEN I = 25 & SelectedDDeviceFileSystem = "NTFS" & J \= 5 THEN NOP

				WHEN I = 25 & SelectedDDeviceFileSystem = "LAN" & J \= 6 THEN NOP

				OTHERWISE DO
					K = K + 1
					SAY "     "Red_Text||K||Ansi_Off". "Change.I.J.Text
					Selection.K = Change.I.J.Option
				END	/*Ends "OTHERWISE DO" Section*/
			END	/*Ends "SELECT" Section*/

			IF I = 7 & (POS("SCSI", ClbackCommand.I.UserChoice) > 0 | POS("EIDE", ClbackCommand.I.UserChoice) > 0) THEN DO
				K = K + 1
				SAY "     "Red_Text||K||Ansi_Off". "Change.7.3.Text
				Selection.K = Change.7.3.Option
			END	/*Ends "IF I = 7 & (POS("SCSI", ClbackCommand.I.UserChoice) > 0 | POS("EIDE", ClbackCommand.I.UserChoice) > 0) THEN DO" Section*/
		END	/*Ends "IF POS(Change.I.J.Option, ClbackCommand.I.UserChoice) = 0 THEN DO" Section*/
	END J	/*Ends "DO J = 1 TO Stop BY 1" Section*/
	K_Stop = K
	K = K + 1
	SAY "     "Red_Text||K||Ansi_Off". Skip ahead, or back, to another option"
	Selection.K = "Skip Ahead or Back"
	K = K + 1
	SAY "     "Red_Text||K||Ansi_Off". Review the selected options for "Description
	Selection.K = "Review Selected Options"
	K = K + 1
	SAY "     "Red_Text||K||Ansi_Off". End changing the options for "Description" (leave)"
	Selection.K = "End Changing Options"
	K = K + 1
	SAY "     "Red_Text||K||Ansi_Off". Press the "Red_Text"ENTER"Ansi_Off" key to leave the option unchanged. Go to next option"Red_Text
	Selection.K = "Leave Option Unchanged"
	K_Total = K
	PARSE PULL ChangeResponse
	SAY ""Ansi_Off
	RC = SYSCLS()
	SELECT
		WHEN DATATYPE(ChangeResponse) = "NUM" & ChangeResponse >= 1 & ChangeResponse <= K_Stop THEN DO
			SELECT
				WHEN Instruction = "" | Selection.ChangeResponse = "" THEN DO
					SELECT
						WHEN I \= 24 THEN DO	/*Temperarily disable ability to select option 24, unattended backups (it does not work in CLBACK)*/
							ClbackCommand.I.UserChoice = Selection.ChangeResponse
							TempClbackCommand.I.UserChoice = Selection.ChangeResponse
						END	/*Ends "WHEN I \= 24 THEN DO" Section*/

						OTHERWISE NOP	/*Temperarily disable ability to select option 24, unattended backups (it does not work in CLBACK)*/
					END	/*Ends "SELECT" Section*/
					IF I = 26 THEN UpdateDateFlag.UserChoice = 0
					IF I = 27 THEN DO
						MultipleBackupsCount = 0 
						DO R = 1 TO ClbackCommand.0.0 BY 1
							IF ClbackCommand.27.R = "-m" THEN MultipleBackupsCount = MultipleBackupsCount + 1
						END R	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
						IF MultipleBackupsCount < 2 THEN MultipleBackupsFlag = 0
						ELSE MultipleBackupsFlag = 1
					END	/*Ends "IF I = 27 THEN DO" Section*/
					IF I = 7 & Selection.ChangeResponse = "" THEN DO
						ClbackCommand.25.UserChoice = ""
						TempClbackCommand.25.UserChoice = ""
						ClbackCommand.26.UserChoice = ""
						TempClbackCommand.26.UserChoice = ""
						UpdateDateFlag.UserChoice = 0
					END	/*Ends "IF I = 7 & Selection.ChangeResponse = "" THEN DO" Section*/
					UpdateFlag = 1
				END	/*Ends "WHEN Instruction = "" | Selection.ChangeResponse = "" THEN DO" Section*/

				WHEN Instruction = "SimpleWrite" THEN DO
					SAY ""
					IF I = 8 THEN SAY "Enter a description for the commandline backup"
					IF I = 16 THEN SAY "Enter a name for the commandline backup"
					SAY ""
					SAY "Do not put any spaces in anything you write. It will cause the"
					SAY "     commandline option to fail (CLBACK.EXE does not like it) and"
					SAY "     this REXX program will not complete your change!"
					SAY ""
					SAY "Enter your response now"Red_Text
					PARSE PULL SimpleWrite
					SAY ""Ansi_Off
					RC = SYSCLS()
					String1 = " "
					IF POS(String1, SimpleWrite) = 0 THEN DO
						ClbackCommand.I.UserChoice = Selection.ChangeResponse||SimpleWrite
						TempClbackCommand.I.UserChoice = Selection.ChangeResponse||SimpleWrite
						UpdateFlag = 1
					END	/*Ends "IF POS(String1, SimpleWrite) = 0 THEN DO" Section*/
				END	/*Ends "WHEN Instruction = "SimpleWrite" THEN DO" Section*/

				WHEN Instruction = "CheckFiles" THEN DO
					IF I = 1 THEN DO
						RemainingWords1 = "text file that"
						RemainingWords2 = "     lists the files to be backed up."
					END	/*Ends "IF I = 1 THEN DO" Section*/
					IF I = 2 THEN DO
						RemainingWords1 = "text file that"
						RemainingWords2 = "     lists the file patterns for the recursive back up."
					END	/*Ends "IF I = 2 THEN DO" Section*/
					SAY ""
					SAY "Enter the full and complete path to the already existing "RemainingWords1
					SAY RemainingWords2
					SAY ""
					SAY "Do not put any spaces in anything you write. It will cause the"
					SAY "     commandline option to fail (CLBACK.EXE does not like it) and"
					SAY "     this REXX program will not complete your change!"
					SAY ""
					SAY "Enter your response now"Red_Text
					PARSE PULL CheckFile
					SAY ""Ansi_Off
					RC = SYSCLS()
					FileSearchPathResults. = ""
					RC = SYSFILETREE(CheckFile, "FileSearchPathResults", "FO")
					IF FileSearchPathResults.0 = 1 THEN DO
						String1 = " "
						IF I = 1 & POS(String1, CheckFile) = 0 THEN DO
							ClbackCommand.I.UserChoice = Selection.ChangeResponse||CheckFile
							TempClbackCommand.I.UserChoice = Selection.ChangeResponse||CheckFile
						END	/*Ends "IF I = 1 & POS(String1, CheckFile) = 0 THEN DO" Section*/
						IF I = 2 & POS(String1, CheckFile) = 0 THEN DO
							ClbackCommand.I.UserChoice = Selection.ChangeResponse||CheckFile
							TempClbackCommand.I.UserChoice = Selection.ChangeResponse||CheckFile
						END	/*Ends "IF I = 2 & POS(String1, CheckFile) = 0 THEN DO" Section*/
						UpdateFlag = 1
					END	/*Ends "IF FileSearchPathResults. 0 THEN DO" Section*/

					ELSE DO
						SAY "Sorry. The file was not found, or you did not uniquely specify it."
						SAY "     Please try again, this time with a unique, existing filename."
						SAY "     Press the "Red_Text"ENTER"Ansi_Off" key to continue."
						I = I - 1
						PARSE PULL KeyResponse
					END	/*Ends "ELSE DO" Section*/
				END	/*Ends "WHEN Instruction = "CheckFiles" THEN DO" Section*/

				WHEN Instruction = "CheckFileSpecifications" THEN DO
					CheckFileSpecifications = ""
					SELECT
						WHEN I = 11 THEN RemainingWords = "exclude from the backup."
						WHEN I = 12 THEN RemainingWords = "recursively exclude from the backup."
						WHEN I = 13 THEN RemainingWords = "include in the backup."
						WHEN I = 14 THEN RemainingWords = "recursively include in the backup."
						OTHERWISE NOP
					END	/*Ends "SELECT" Section*/
					AdditionalWord = ""
					IF ClbackCommand.I.UserChoice \= "" THEN AdditionalWord = "additional "
					SAY ""
					SAY "Enter the file specification, or file pattern, for the "AdditionalWord"files"
					SAY "     you want to "RemainingWords
					SAY ""
					SAY "Do not put any spaces in anything you write. It will cause the"
					SAY "     commandline option to fail (CLBACK.EXE does not like it) and"
					SAY "     this REXX program will not complete your change!"
					SAY ""
					SAY "Enter your response now"Red_Text
					PARSE PULL CheckFileSpecifications
					SAY ""Ansi_Off
					RC = SYSCLS()

					SELECT
						WHEN CheckFileSpecifications \= "" & POS("\", CheckFileSpecifications) = 0 THEN FileSearchPathResults.0 = 1

						WHEN CheckFileSpecifications \= "" & POS("\", CheckFileSpecifications) > 0 THEN DO
							FileSpecLocation = ""
							FileSpecPortion = CheckFileSpecifications
							DO UNTIL FileSpecPortion = ""
								PARSE Var FileSpecPortion FirstPart "\" SecondPart
								SELECT
									WHEN FileSpecLocation = "" & SecondPart \= "" THEN DO
										FileSpecLocation = FirstPart
										SelectedDDDDevicePartition = FirstPart
									END	/*Ends "WHEN FileSpecLocation = "" & SecondPart \= "" THEN DO" Section*/

									WHEN FileSpecLocation \= "" & SecondPart \= "" THEN FileSpecLocation = FileSpecLocation"\"FirstPart

									OTHERWISE BackupFFFileName = FirstPart
								END	/*Ends "SELECT" Section*/
								FileSpecPortion = SecondPart
							END	/*Ends "DO UNTIL FileSpecPortion = """ Section*/
							FileSpecLocation = FileSpecLocation"\*.*"
							FileSearchPathResults. = ""
							RC = SYSFILETREE(FileSpecLocation, "FileSearchPathResults", "DO")
							DO P = 1 TO Drive.0 BY 1
								IF SelectedDDDDevicePartition = Drive.P.PPartition THEN SelectedDDDDeviceFileSystem = Drive.P.FFileSystem
								IF TRANSLATE(FileSpecLocation) = TRANSLATE(Drive.P.PPartition) THEN FileSearchPathResults.0 = 1
							END P	/*Ends "DO P = 1 TO Drive.0 BY 1" Section*/
						END	/*Ends "WHEN CheckFileSpecifications \= "" & POS("\", CheckFileSpecifications) > 0 THEN DO" Section*/

						OTHERWISE FileSearchPathResults.0 = 0
					END	/*Ends "SELECT" Section*/

					IF SelectedDDDDeviceFileSystem = "FAT" THEN DO	/*This is the test for the 8.3 filename*/
						BackupFFFileNameLength = LENGTH(BackupFFFileName)
						MinimumDotPosition = BackupFFFileNameLength - 3
						SELECT
							WHEN BackupFFFileNameLength > 12 THEN FileSearchPathResults.0 = 0

								OTHERWISE DO
								DotPosition = POS(".", BackupFFFileName)
								IF DotPosition > 0 THEN DO
									IF DotPosition < MinimumDotPosition THEN FileSearchPathResults.0 = 0
									IF DotPosition = MinimumDotPosition & BackupFFFileNameLength > 12 THEN FileSearchPathResults.0 = 0
									IF DotPosition = MinimumDotPosition + 1 & BackupFFFileNameLength > 11 THEN FileSearchPathResults.0 = 0
									IF DotPosition = MinimumDotPosition + 2 & BackupFFFileNameLength > 10 THEN FileSearchPathResults.0 = 0
									IF DotPosition = MinimumDotPosition + 3 & BackupFFFileNameLength > 9 THEN FileSearchPathResults.0 = 0
								END	/*Ends "IF DotPosition > 0 THEN DO" Section*/
								ELSE
								IF BackupFFFileNameLength > 8 THEN FileSearchPathResults.0 = 0
							END
						END	/*Ends "SELECT" Section*/
					END	/*Ends "IF SelectedDDDDeviceFileSystem = "FAT" THEN DO" Section*/

					IF FileSearchPathResults.0 > 0 THEN DO
						String1 = " "
						IF POS(String1, FileSpecLocation) = 0 THEN DO
							ClbackCommand.I.UserChoice = ClbackCommand.I.UserChoice""Selection.ChangeResponse||CheckFileSpecifications
							TempClbackCommand.I.UserChoice = TempClbackCommand.I.UserChoice""Selection.ChangeResponse||CheckFileSpecifications
						END	/*Ends "IF POS(String1, FileSpecLocation) = 0 THEN DO" Section*/
						UpdateFlag = 1
					END	/*Ends "IF FileSearchPathResults. 0 THEN DO" Section*/

					ELSE DO
						SAY "Sorry. The directory path to the file specification cannot be found,"
						SAY "     or perhaps you violated the 8.3 file naming convention for FAT"
						SAY "     partitions (if you provided a file specification on a FAT part-"
						SAY "     ition, check the end of the specification for adherence to the"
						SAY "     FAT file naming convention)."
						SAY ""
						SAY "Please try again, this time using an actual,existing, directory, or"
						SAY "     a correct file specification."
						SAY ""
						SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
						I = I - 1
						PARSE PULL KeyResponse
					END	/*Ends "ELSE DO" Section*/
				END	/*Ends "WHEN Instruction = "CheckFileSpecifications" THEN DO" Section*/

				WHEN Instruction = "Device" | Instruction = "SaveBackupSet" THEN DO
					IF Instruction = "Device" THEN DO
						IF LENGTH(Selection.ChangeResponse) = 12 THEN SelectedDDDevice = SUBSTR(Selection.ChangeResponse, 4, 4)
						ELSE SelectedDDDevice = "LOGICAL"
					END	/*Ends "IF Instruction = "Device" THEN DO" Section*/

					SAY ""	
					SELECT
						WHEN Instruction = "Device" & (SelectedDDDevice = "SCSI" | SelectedDDDevice = "EIDE") THEN DO
							SAY "Enter the number for the tape unit"Red_Text
							PARSE PULL UnitNumber
							SAY ""Ansi_Off
							RC = SYSCLS()
							IF DATATYPE(UnitNumber) = "NUM" THEN DO
								IntegerTest = UnitNumber//1
								IF IntegerTest = 0 & UnitNumber >= 0 THEN DO
									ClbackCommand.I.UserChoice = Selection.ChangeResponse||UnitNumber
									TempClbackCommand.I.UserChoice = Selection.ChangeResponse||UnitNumber
									ClbackCommand.25.UserChoice = ""
									TempClbackCommand.25.UserChoice = ""
									ClbackCommand.26.UserChoice = ""
									TempClbackCommand.26.UserChoice = ""
									UpdateDateFlag.UserChoice = 0
									UpdateFlag = 1
									
									SAY ""
									SAY "You you like to select this tape device for all your backups?"
									SAY ""
									SAY "     "Red_Text"1"Ansi_Off" "Red_Text"Y"Ansi_Off"es"
									SAY "     "Red_Text"2"Ansi_Off" "Red_Text"N"Ansi_Off"o (if you like, just press the "Red_Text"ENTER"Ansi_Off" key)"Red_Text
									PARSE UPPER PULL AllTapeDevice
									SAY ""Ansi_Off
									RC = SYSCLS()
									IF AllTapeDevice = 1 | AllTapeDevice = "Y" THEN DO
										DO R = 1 TO ClbackCommand.0.0 BY 1
											ClbackCommand.I.R = Selection.ChangeResponse||UnitNumber
											TempClbackCommand.I.R = Selection.ChangeResponse||UnitNumber
											ClbackCommand.25.R = ""
											TempClbackCommand.25.R = ""
											ClbackCommand.26.R = ""
											TempClbackCommand.26.R = ""
											UpdateDateFlag.R = 0
										END R	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
									END	/*Ends "IF AllTapeDevice = 1 | AllTapeDevice = "Y" THEN DO" Section*/
								END	/*Ends "IF IntegerTest = 0 & UnitNumber > 0 THEN DO" Section*/
							END	/*Ends "" Section*/
						END/*Ends "WHEN Instruction = "Device" & (SelectedDDDevice = "SCSI" | SelectedDDDevice = "EIDE") THEN DO" Section*/

						WHEN SelectedDDDevice = "LOGICAL" | Instruction = "SaveBackupSet" THEN DO
							RemainingWord = ""
							IF Instruction = "SaveBackupSet" THEN RemainingWord = "set "
							SAY ""
							SAY "Enter the full and complete path to the backup "RemainingWord"file. If that"
							SAY "     file does not yet exist, the next performed backup will create it."
							SAY "     Naturally, the directory path to the file must already exist."
							SAY ""
							SAY "Do not put any spaces in anything you write. It will cause the"
							SAY "     commandline option to fail (CLBACK.EXE does not like it) and"
							SAY "     this REXX program will not complete your change!"
							SAY ""
							SAY "Enter your response now"Red_Text
							PARSE PULL BackupFilePath
							SAY ""Ansi_Off
							RC = SYSCLS()
							FileSpecLocation = ""
							FileSpecPortion = BackupFilePath
							DO UNTIL FileSpecPortion = ""
								PARSE Var FileSpecPortion FirstPart "\" SecondPart
								SELECT
									WHEN FileSpecLocation = "" & SecondPart \= "" THEN DO
										FileSpecLocation = FirstPart
										SelectedDDDDevicePartition = FirstPart
									END	/*Ends "WHEN FileSpecLocation = "" & SecondPart \= "" THEN DO" Section*/

									WHEN FileSpecLocation \= "" & SecondPart \= "" THEN FileSpecLocation = FileSpecLocation"\"FirstPart

									OTHERWISE BackupFFFileName = FirstPart
								END	/*Ends "SELECT" Section*/
								FileSpecPortion = SecondPart
							END	/*Ends "DO UNTIL FileSpecPortion = """ Section*/
							FileSearchPathResults. = ""
							RC = SYSFILETREE(FileSpecLocation, "FileSearchPathResults", "DO")

							SELECT
								WHEN SelectedDDDevice = "LOGICAL" THEN DO
									DO P = 1 TO DDrive.0 BY 1
										IF SelectedDDDDevicePartition = DDrive.P.PPartition THEN SelectedDDDDeviceFileSystem = DDrive.P.FFileSystem
										IF TRANSLATE(FileSpecLocation) = TRANSLATE(DDrive.P.PPartition) THEN FileSearchPathResults.0 = 1
									END P	/*Ends "DO P = 1 TO DDrive.0 BY 1" Section*/
								END	/*Ends "WHEN SelectedDDDevice = "LOGICAL" THEN DO" Section*/

								WHEN Instruction = "SaveBackupSet" THEN DO
									DO P = 1 TO Drive.0 BY 1
										IF SelectedDDDDevicePartition = Drive.P.PPartition THEN SelectedDDDDeviceFileSystem = Drive.P.FFileSystem
										IF TRANSLATE(FileSpecLocation) = TRANSLATE(Drive.P.PPartition) THEN FileSearchPathResults.0 = 1
									END P	/*Ends "DO P = 1 TO Drive.0 BY 1" Section*/
								END	/*Ends "WHEN Instruction = "SaveBackupSet" THEN DO" Section*/

								OTHERWISE NOP
							END	/*Ends "SELECT" Section*/
							
							IF SelectedDDDDeviceFileSystem = "FAT" THEN DO	/*This is the test for the 8.3 filename*/
								BackupFFFileNameLength = LENGTH(BackupFFFileName)
								MinimumDotPosition = BackupFFFileNameLength - 3
								SELECT
									WHEN BackupFFFileNameLength > 12 THEN FileSearchPathResults.0 = 0

									OTHERWISE DO
										DotPosition = POS(".", BackupFFFileName)
										IF DotPosition > 0 THEN DO
											IF DotPosition < MinimumDotPosition THEN FileSearchPathResults.0 = 0
											IF DotPosition = MinimumDotPosition & BackupFFFileNameLength > 12 THEN FileSearchPathResults.0 = 0
											IF DotPosition = MinimumDotPosition + 1 & BackupFFFileNameLength > 11 THEN FileSearchPathResults.0 = 0
											IF DotPosition = MinimumDotPosition + 2 & BackupFFFileNameLength > 10 THEN FileSearchPathResults.0 = 0
											IF DotPosition = MinimumDotPosition + 3 & BackupFFFileNameLength > 9 THEN FileSearchPathResults.0 = 0
										END	/*Ends "IF DotPosition > 0 THEN DO" Section*/
										ELSE
										IF BackupFFFileNameLength > 8 THEN FileSearchPathResults.0 = 0
									END
								END	/*Ends "SELECT" Section*/
							END	/*Ends "IF SelectedDDDDeviceFileSystem = "FAT" THEN DO" Section*/

							IF FileSearchPathResults.0 = 1 THEN DO
								String1 = " "
								IF POS(String1, FileSpecLocation) = 0 THEN DO
									IF TRANSLATE(RIGHT(BackupFilePath, 4)) \= ".DAT" & Instruction = "Device" THEN BackupFilePath = BackupFilePath".DAT"
									IF TRANSLATE(RIGHT(BackupFilePath, 4)) \= ".BST" & Instruction = "SaveBackupSet" THEN BackupFilePath = BackupFilePath".BST"
									ClbackCommand.I.UserChoice = Selection.ChangeResponse||BackupFilePath
									TempClbackCommand.I.UserChoice = Selection.ChangeResponse||BackupFilePath
									IF Instruction = "Device" & ClbackCommand.25.UserChoice \= "" THEN DO
										PARSE VAR ClbackCommand.25.UserChoice First Second
										ClbackCommand.25.UserChoice = First" 0"
										TempClbackCommand.25.UserChoice = First" 0"
									END	/*Ends "IF Instruction = "Device" & ClbackCommand.25.UserChoice \= "" THEN DO" Section*/
								END	/*Ends "IF POS(String1, FileSpecLocation) = 0 THEN DO" Section*/
								UpdateFlag = 1
							END	/*Ends "IF FileSearchPathResults. 0 = 1 THEN DO" Section*/

							ELSE DO
								IF Instruction = "Device" THEN RightWord = "backup file"
								IF Instruction = "SaveBackupSet" THEN RightWord = "backup set file"
								SAY "Sorry. The directory path to the "RightWord" cannot be found, or it"
								SAY "     is not unique, or perhaps you violated the 8.3 file naming"
								SAY "     convention for the FAT file system (check the filename, if you"
								SAY "     designated a file on a FAT partition)."
								SAY ""
								SAY "Please try again, this time using a unique and existing directory."
								SAY "     Press the "Red_Text"ENTER"Ansi_Off" key to continue."
								I = I - 1
								PARSE PULL KeyResponse
							END	/*Ends "ELSE DO" Section*/
						END/*Ends "WHEN SelectedDDDevice = "LOGICAL" | Instruction = "SaveBackupSet" THEN DO" Section*/

						OTHERWISE NOP
					END	/*Ends "SELECT" Section*/
				END	/*Ends "WHEN Instruction = "Device" | Instruction = "SaveBackupSet" THEN DO" Section*/

				WHEN Instruction = "CheckFilesAppend" THEN DO
					IF Selection.ChangeResponse \= "" THEN DO
						SAY ""
						SAY "Please verify (later) that you have specified the correct backup device"
						SAY "     under option #7. If you have a SCSI or EIDE tape backup device, you"
						SAY "     must select it under that option and give the number of the tape unit."
						SAY "     If you have a drive, or logical, backup device, you must select it"
						SAY "     under option #7 and give the full and complete path to an existing"
						SAY "     backup file, or one that will be created by this next backup. The"
						SAY '     "append" option that you are now enabling will not otherwise work.'
						SAY ""
						SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
						PARSE PULL KeyResponse
						ClbackCommand.I.UserChoice = Selection.ChangeResponse
						TempClbackCommand.I.UserChoice = Selection.ChangeResponse
						UpdateFlag = 1
					END	/*Ends "IF Selection.ChangeResponse \= "" THEN DO" Section*/
				END	/*Ends "WHEN Instruction = "CheckFilesAppend" THEN DO" Section*/

				WHEN Instruction = "UseBackupSet" THEN DO
					SELECT
						WHEN Selection.ChangeResponse = "" THEN DO
							RC = SYSCLS()
							SAY ""
							SAY "Careful! If you disable the use of the backup set, this program will"
							SAY "     reset all the other options for this commandline backup to the"
							SAY "     default values."
							SAY ""
							SAY "Proceed with disabling the use of the backup set?"
							SAY "     "Red_Text"1"Ansi_Off". Yes"
							SAY "     "Red_Text"2"Ansi_Off". No"Red_Text
							PARSE PULL UseBackupSetResponse
							SAY ""Ansi_Off
							RC = SYSCLS
							SELECT
								WHEN UseBackupSetResponse = 1 THEN DO
									DO R = 1 TO ClbackCommand.0.UserChoice BY 1
										ClbackCommand.R.UserChoice = Default.R.UserChoice
										TempClbackCommand.R.UserChoice = Default.R.UserChoice
									END R	/*Ends "DO R = 1 TO ClbackCommand.0.UserChoice BY 1" Section*/
									UpdateFlag = 1
								END	/*Ends "WHEN UseBackupSetResponse = 1 THEN DO" Section*/

								WHEN UseBackupSetResponse = 2 THEN NOP

								OTHERWISE DO
									RC = SYSCLS()
									SAY ""
									SAY "Sorry, that response is not recognized, or understood. You must type"
									SAY "     and enter a number between 1 and "ClbackCommand.0.UserChoice", inclusive. Those are the only"
									SAY "     appropriate responses."
									SAY ""
									SAY "Please try again. Press the "Red_Text"ENTER"Ansi_Off" key to continue."
									I = I - 1
									PARSE PULL KeyResponse
								END	/*Ends "OTHERWISE DO" Section*/
							END	/*Ends "SELECT" Section*/
						END	/*Ends "WHEN Selection.ChangeResponse = "" THEN DO" Section*/


						WHEN Selection.ChangeResponse = "-set " THEN DO
							RC = SYSCLS()
							SAY ""
							SAY "Careful! If you enable the use of a backup set, this program will"
							SAY "     disable all the other options for this commandline backup."
							SAY ""
							SAY "Proceed with enabling the use of the backup set?"
							SAY "     "Red_Text"1"Ansi_Off". Yes"
							SAY "     "Red_Text"2"Ansi_Off". No"Red_Text
							PARSE PULL UseBackupSetResponse
							SAY ""Ansi_Off
							RC = SYSCLS
							SELECT
								WHEN UseBackupSetResponse = 1 THEN DO
									RC = SYSCLS()
									SAY ""
									SAY "Enter the full and complete path to the backup set file. The path must"
									SAY "     not contain any spaces. They will cause the commandline option to"
									SAY "     fail (CLBACK.EXE does not like it). Therefore, this REXX program"
									SAY "     will not accept any spaces in the path!"
									SAY ""
									SAY "Enter your response now"Red_Text
									PARSE PULL BackupSetFilePath
									SAY ""Ansi_Off
									RC = SYSCLS()
									FileSearchPathResults. = ""
									RC = SYSFILETREE(BackupSetFilePath, "FileSearchPathResults", "FO")
									IF FileSearchPathResults.0 = 1 THEN DO
										String1 = " "
										IF POS(String1, BackupSetFilePath) = 0 THEN DO
											DO R = 1 TO ClbackCommand.0.UserChoice BY 1
												ClbackCommand.R.UserChoice = ""
												TempClbackCommand.R.UserChoice = ""
											END R	/*Ends "DO R = 1 TO ClbackCommand.0.UserChoice BY 1" Section*/
											ClbackCommand.I.UserChoice = Selection.ChangeResponse||BackupSetFilePath
											TempClbackCommand.I.UserChoice = Selection.ChangeResponse||BackupSetFilePath
											UpdateFlag = 1
										END	/*Ends "IF POS(String1, FileSpecLocation) = 0 THEN DO" Section*/
									END	/*Ends "IF FileSearchPathResults. 0 = 1 THEN DO" Section*/

									ELSE DO
										SAY ""
										SAY "Sorry. The path to the backup set file cannot be found, or it was"
										SAY "     not uniquely specified."
										SAY ""
										SAY "Please try again, this time using a unique and existing file path."
										SAY "     Press the "Red_Text"ENTER"Ansi_Off" key to continue."
										I = I - 1
										PARSE PULL KeyResponse
									END	/*Ends "ELSE DO" Section*/
								END	/*Ends "WHEN UseBackupSetResponse = 1 THEN DO" Section*/

								WHEN UseBackupSetResponse = 2 THEN NOP

								OTHERWISE DO
									RC = SYSCLS()
									SAY ""
									SAY "Sorry, that response is not recognized, or understood. You must type"
									SAY "     and enter a number between 1 and "ClbackCommand.0.UserChoice", inclusive. Those are the only"
									SAY "     appropriate responses."
									SAY ""
									SAY "Please try again. Press the "Red_Text"ENTER"Ansi_Off" key to continue."
									I = I - 1
									PARSE PULL KeyResponse
								END	/*Ends "OTHERWISE DO" Section*/
							END	/*Ends "SELECT" Section*/
						END	/*Ends "WHEN Selection.ChangeResponse = "-set " THEN DO" Section*/

						OTHERWISE NOP
					END	/*Ends "SELECT" Section*/

				END	/*Ends "WHEN Instruction = "UseBackupSet" THEN DO" Section*/

				WHEN Instruction = "CheckBackupFileSize" THEN DO
					
					SELECT
						WHEN Selection.ChangeResponse = "" THEN DO
							ClbackCommand.I.UserChoice = Selection.ChangeResponse
							TempClbackCommand.I.UserChoice = Selection.ChangeResponse
							UpdateFlag = 1
						END	/*Ends "WHEN Selection.ChangeResponse = "" THEN DO" Section*/


						WHEN Selection.ChangeResponse = "-HPFS" | Selection.ChangeResponse = "-JFS" | Selection.ChangeResponse = "-FAT" | Selection.ChangeResponse = "-FAT32" | Selection.ChangeResponse = "-NTFS" | Selection.ChangeResponse = "-LAN" THEN DO
							SELECT
								WHEN Selection.ChangeResponse = "-HPFS" THEN DO
									FileSystem = "HPFS"
									Size = MaxHPFSFileSizeGBytes"GB"
								END	/*Ends "WHEN Selection.ChangeResponse = "-HPFS" THEN DO" Section*/

								WHEN Selection.ChangeResponse = "-JFS" THEN DO
									FileSystem = "JFS"
									Size = MaxJFSFileSizeGBytes"GB"
								END	/*Ends "WHEN Selection.ChangeResponse = "-JFS" THEN DO" Section*/

								WHEN Selection.ChangeResponse = "-FAT" THEN DO
									FileSystem = "FAT"
									Size = MaxFATFileSizeGBytes"GB"
								END	/*Ends "WHEN Selection.ChangeResponse = "-FAT" THEN DO" Section*/

								WHEN Selection.ChangeResponse = "-FAT32" THEN DO
									FileSystem = "FAT32"
									Size = MaxFAT32FileSizeGBytes"GB"
								END	/*Ends "WHEN Selection.ChangeResponse = "-FAT32" THEN DO" Section*/

								WHEN Selection.ChangeResponse = "-NTFS" THEN DO
									FileSystem = "NTFS"
									Size = MaxNTFSFileSizeGBytes"GB"
								END	/*Ends "WHEN Selection.ChangeResponse = "-NTFS" THEN DO" Section*/

								WHEN Selection.ChangeResponse = "-LAN" THEN DO
									FileSystem = "LAN"
									Size = MaxLANFileSizeGBytes"GB"
								END	/*Ends "WHEN Selection.ChangeResponse = "-NTFS" THEN DO" Section*/

								OTHERWISE NOP
							END	/*Ends "SELECT" Section*/
							RC = SYSCLS
							SAY ""
							SAY "Warnings for a potential file size overflow will occur, when needed,"
							SAY "     but only on backups after this next one. When the overflow warning"
							SAY "     is enabled, this program tracks and stores the size of this next"
							SAY "     backup after it has been completed (the increase in the size of the"
							SAY "     backup file, caused by that backup). It uses that information on"
							SAY "     the next backup after that to estmate the size of the backup file"
							SAY "     that will result from that operation. If the estimate is larger"
							SAY "     than the "FileSystem" file size limit, "Size", it issues a warning."
							SAY ""
							SAY "Obviously, if you significantly change the size of your system between"
							SAY "     backups, the warning may be ineffective (fail to warn, if you have"
							SAY "     increased the size of your system; provide a needless warning, if"
							SAY "     you have decreased the size). The program adds 10% to the file size"
							SAY "     increase number (derived at this next backup) to provide a safety"
							SAY "     factor in estimating the file size for the next backup after that."
							SAY ""
							SAY "Also, the file size warning works only, if you are backing up to a drive,"
							SAY "     or logical device, under option #7. It does not work, if you are"
							SAY "     using a tape device or a backup set file. In the case of a backup set"
							SAY "     the details of the backup device are specified in that file, and"
							SAY "     therefore are hidden from this program."
							SAY ""
							SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
							PARSE PULL KeyResponse
							ClbackCommand.I.UserChoice = Selection.ChangeResponse "0"
							TempClbackCommand.I.UserChoice = Selection.ChangeResponse "0"
							UpdateFlag = 1
							RC = SYSCLS()
						END	/*Ends "WHEN Selection.ChangeResponse = "-HPFS" | Selection.ChangeResponse = "-JFS" | Selection.ChangeResponse = "-FAT" | Selection.ChangeResponse = "-FAT32" | Selection.ChangeResponse = "-NTFS" | Selection.ChangeResponse = "-LAN" THEN DO" Section*/

						OTHERWISE NOP
					END	/*Ends "SELECT" Section*/
				END	/*Ends "WHEN Instruction = "CheckBackupFileSize" THEN DO" Section*/

				WHEN Instruction = "UpdateDate" THEN DO
					PARSE VAR ClbackCommand.7.UserChoice First BackupFilePath
					PARSE VAR BackupFilePath BackupFilePartition ":" Second
					DO R = 1 TO DDrive.0 BY 1
						IF DDrive.R.CapDriveLetter = TRANSLATE(BackupFilePartition) THEN DO
							BackupFilePartitionNumber = DDrive.R.DriveNumber
							BackupFileFileSystemType = DDrive.R.FFileSystem
							LEAVE R
						END	/*Ends "IF DDrive.R.CapDriveLetter = TRANSLATE(BackupFilePartition) THEN DO" Section*/
					END R	/*Ends "DO R = 1 TO DDrive.0 BY 1" Section*/
					SELECT
						WHEN BackupFileFileSystemType = "FAT" THEN DO
							RC = SYSCLS
							SAY ""
							SAY "Sorry, the option to include an updated date as part of the name of the"
							SAY "     backup file is not available, The backup file is stored on a "BackupFileFileSystemType
							SAY "     partition. The 8.3 filename convention for these partitions"
							SAY "     precludes the use of a date within the backup filename."
							SAY ""
							SAY "Press the "Red_Text"ENTER"Ansi_Off" key to continue."
							PARSE PULL KeyResponse
							RC = SYSCLS
						END	/*Ends "WHEN BackupFileFileSystemType = "FAT" THEN DO" Section*/

						OTHERWISE DO
							Today = Month||Day||Year
							CheckUnderScore = ""
							CheckUnderScorePosition = 0
							IF POS(Today, ClbackCommand.7.UserChoice) > 1 THEN DO
								CheckUnderScorePosition = POS(Today, ClbackCommand.7.UserChoice) - 1
								IF SUBSTR(ClbackCommand.7.UserChoice, CheckUnderScorePosition, 1) = "_" THEN CheckUnderScore = "_"
							END	/*Ends "IF POS(Today, ClbackCommand.7.UserChoice) > 0 THEN DO" Section*/
							IF POS(Today, ClbackCommand.7.UserChoice) < 1 | CheckUnderScore = "" THEN DO
								PARSE VAR ClbackCommand.7.UserChoice First "." FileNameExtension
									FileNameRoot = ""
									FFirst = First
								DO UNTIL FFirst = ""
									PARSE VAR FFirst FFFirst "_" Remainder
									SELECT
										WHEN FileNameRoot = "" THEN FileNameRoot = FFFirst
										WHEN FileNameRoot \= "" & Remainder \= "" THEN FileNameRoot = FileNameRoot"_"FFFirst
										OTHERWISE PossibleDate = FFFirst
									END	/*Ends "SELECT" Section*/
									FFirst = Remainder
								END	/*Ends "DO UNTIL FFirst = """ Section*/
								Question1 = "False"
								Question2 = "False"
								Question3 = "False"
								Question4 = "False"
								IF LENGTH(PossibleDate) = 8 THEN DO
									Question1 = "True"
									IF RIGHT(PossibleDate, 4) = Year | RIGHT(PossibleDate, 4) = (Year - 1) THEN DO
										Question2 = "True"
										IF LEFT(PossibleDate, 1) = 0 THEN DO
											Question3 = "True"
											IF SUBSTR(PossibleDate, 2, 1) \= 0 THEN Question4 = "True"
										END	/*Ends "IF LEFT(PossibleDate, 1) = 0 THEN DO" Section*/
										ELSE DO
											IF LEFT(PossibleDate, 1) = 1 THEN Question3 = "True"
											IF SUBSTR(PossibleDate, 2, 1) < 3 THEN Question4 = "True"
										END	/*Ends "ELSE DO" Section*/
									END	/*Ends "IF RIGHT(PossibleDate, 4) = Year | RIGHT(PossibleDate, 4) = (Year - 1) THEN DO" Section*/
								END	/*Ends "IF LENGTH(PossibleDate) = 8 THEN DO" Section*/
								IF Question1 = "False" | Question2 = "False" | Question3 = "False" | Question4 = "False" THEN FileNameRoot = First
								ClbackCommand.7.UserChoice = FileNameRoot"_"Today".DAT"
								TempClbackCommand.7.UserChoice =FileNameRoot"_"Today".DAT"
								IF ClbackCommand.25.UserChoice \= "" THEN DO
									PARSE VAR ClbackCommand.25.UserChoice First Second
									ClbackCommand.25.UserChoice = First" 0"
									TempClbackCommand.25.UserChoice = First" 0"
								END	/*Ends "IF ClbackCommand.25.UserChoice \= "" THEN DO" Section*/
							END	/*Ends "IF POS(Today, ClbackCommand.7.UserChoice) < 1 | CheckUnderScore = "" THEN DO" Section*/
						END	/*Ends "OTHERWISE DO" Section*/
					END	/*Ends "SELECT" Section*/
					ClbackCommand.I.UserChoice = Selection.ChangeResponse
					TempClbackCommand.I.UserChoice = Selection.ChangeResponse
					UpdateDateFlag.UserChoice = 1
					UpdateFlag = 1
				END	/*Ends "WHEN Instruction = "UpdateDate" THEN DO" Section*/

				WHEN Instruction = "MultipleBackups" THEN DO
					ClbackCommand.I.UserChoice = Selection.ChangeResponse
					TempClbackCommand.I.UserChoice = Selection.ChangeResponse
					MultipleBackupsCount = 0 
					DO R = 1 TO ClbackCommand.0.0 BY 1
						IF ClbackCommand.27.R = "-m" THEN MultipleBackupsCount = MultipleBackupsCount + 1
					END R	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
					IF MultipleBackupsCount < 2 THEN MultipleBackupsFlag = 0
					ELSE MultipleBackupsFlag = 1
					MultipleBackupsQuitFlag = 0

					DO UNTIL MultipleBackupsQuitFlag = 1 | MultipleBackupsCount = ClbackCommand.0.0
						SELECT
							WHEN MultipleBackupsCount < ClbackCommand.0.0 THEN DO
								MultipleBackupsCountRemaining = ClbackCommand.0.0 - MultipleBackupsCount
								RC = SYSCLS
								SAY ""
								SELECT
									WHEN MultipleBackupsCount = 1 THEN DO
										SAY "You only have one (1) commandline backup selected under the automatic"
										SAY "     multiple sequential backups option. You must select two (2) or"
										SAY "     more backups, otherwise this option will not be enabled."
										SAY ""
									END	/*Ends "WHEN MultipleBackupsCount = 1 THEN DO" Section*/

									OTHERWISE NOP
								END	/*Ends "SELECT" Section*/
								Q = 0
								MultipleBackupsSelection. = ""
								SAY "Include other commandline backups under the automatic multiple backups option?"
								DO R = 1 TO ClbackCommand.0.0 BY 1
									IF TempClbackCommand.27.R = "" THEN DO
										Q = Q + 1
										PARSE VAR ClbackCommand.8.R First Description
										IF Description = "" THEN DO
											SELECT
												WHEN ClbackCommand.22.I = "" THEN Description = "No User Description Provided!"
												OTHERWISE Description = "Info. Provided In A Backup Set!"
											END	/*Ends "SELECT" Section*/
										END	/*Ends "IF Description = "" THEN DO" Section*/
										SAY "    "Red_Text||Q||Ansi_Off".  Include "Description
										MultipleBackupsSelection.Q = R
									END	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
								END R	/*Ends "IF TempClbackCommand.27.R = "" THEN DO" Section*/
								Q = Q + 1
								SAY "    "Red_Text||Q||Ansi_Off".  End the selection of other backups (press the "Red_Text"ENTER"Ansi_Off" key)"
								SAY ""
								SAY "Enter your response now"Red_Text
								PARSE PULL MultipleBackupsResponse
								SAY ""Ansi_Off
								RC = SYSCLS()
								SELECT
									WHEN DATATYPE(MultipleBackupsResponse) = NUM & MultipleBackupsResponse <= MultipleBackupsCountRemaining THEN DO
										S = MultipleBackupsSelection.MultipleBackupsResponse
										ClbackCommand.I.S = Change.27.1.Option
										TempClbackCommand.I.S = Change.27.1.Option
										MultipleBackupsFlag = 1

										MultipleBackupsCount = 0 
										DO R = 1 TO ClbackCommand.0.0 BY 1
											IF TempClbackCommand.27.R = "-m" THEN MultipleBackupsCount = MultipleBackupsCount + 1
										END R	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
										IF MultipleBackupsCount < 2 THEN MultipleBackupsFlag = 0
										ELSE MultipleBackupsFlag = 1
									END	/*Ends "WHEN DATATYPE(MultipleBackupsResponse) = NUM & MultipleBackupsResponse <= MultipleBackupsCountRemaining THEN DO" Section*/

									OTHERWISE MultipleBackupsQuitFlag = 1
								END	/*Ends "SELECT" Section*/
							END	/*Ends "WHEN MultipleBackupsCount < ClbackCommand.0.0 THEN DO" Section*/

							OTHERWISE NOP
						END	/*Ends "SELECT" Section*/
					END	/*Ends "DO UNTIL MultipleBackupsQuitFlag = 1 | MultipleBackupsCount = ClbackCommand.0.0" Section*/
					UpdateFlag = 1
				END	/*Ends "WHEN Instruction = "MultipleBackups" THEN DO" Section*/

				OTHERWISE NOP
			END	/*Ends "SELECT" Section*/
		END	/*Ends "WHEN DATATYPE(ChangeResponse) = "NUM" & ChangeResponse >= 1 & ChangeResponse <= K_Stop THEN DO" Section*/

		WHEN Selection.ChangeResponse = "Skip Ahead or Back" THEN DO
			SAY "Enter the number of the option to which you want to skip"Red_Text
			PARSE PULL ChangeResponse
			SAY ""Ansi_Off
			RC = SYSCLS()
			SELECT
				WHEN DATATYPE(ChangeResponse) = "NUM" & ChangeResponse >= 1 & ChangeResponse <= ClbackCommand.0.UserChoice THEN DO
					SkipOptionsFlag = 1
					I = ChangeResponse - 1
					LEAVE
				END	/*Ends "WHEN DATATYPE(ChangeResponse) = "NUM" & ChangeResponse >= 1 & ChangeResponse <= ClbackCommand.0.UserChoice THEN DO" Section*/

				OTHERWISE DO
					RC = SYSCLS()
					SAY ""
					SAY "Sorry, that response is not recognized, or understood. You must type"
					SAY "     and enter a number between 1 and "ClbackCommand.0.UserChoice", inclusive. Those are the only"
					SAY "     appropriate responses."
					SAY ""
					SAY "Please try again. Press the "Red_Text"ENTER"Ansi_Off" key to continue."
					I = I - 1
					PARSE PULL KeyResponse
				END	/*Ends "OTHERWISE DO" Section*/
			END	/*Ends "SELECT" Section*/
		END	/*Ends "WHEN Selection.ChangeResponse = "Skip Ahead or Back" THEN DO" Section*/

		WHEN Selection.ChangeResponse = "Review Selected Options" THEN DO
				SelectedOptionsFlag = 1
				TemporaryHoldForI = I
				LEAVE
		END	/*Ends "WHEN Selection.ChangeResponse = "Review Selected Options" THEN DO" Section*/

		WHEN Selection.ChangeResponse = "End Changing Options" THEN LEAVE

		WHEN ChangeResponse = "" | Selection.ChangeResponse = "Leave Option Unchanged" THEN NOP

		OTHERWISE DO
			RC = SYSCLS()
			SAY ""
			SAY "Sorry, that response is not recognized, or understood. You must type"
			SAY "     and enter one of the "Red_Text"Red"Ansi_Off" numbers, or press the "Red_Text"ENTER"Ansi_Off" key. Those"
			SAY "     are the only appropriate responses."
			SAY ""
			SAY "Please try again. Press the "Red_Text"ENTER"Ansi_Off" key to continue."
			I = I - 1
			PARSE PULL KeyResponse
		END	/*Ends "OTHERWISE DO" Section*/
	END	/*Ends "SELECT" Section*/
END	/*Ends "DO UNTIL I = ClbackCommand.0.UserChoice" Section*/

IF SelectedOptionsFlag = 1 THEN DO
	CALL SELECTEDOPTIONS
	I = TemporaryHoldForI - 1
	SIGNAL CHANGEOPTIONSMENU
END	/*IF SelectedOptionsFlag = 1 THEN DO*/


IF SkipOptionsFlag = 1 THEN SIGNAL CHANGEOPTIONSMENU
RETURN
/*End constructing the changing of one or more options for a commandline backup*/









/*Begin progress words for creating 1 or more new commandline backups*/
CREATECOMMANDLINE:
SELECT
	WHEN NumberOfBackupsToCreate = 1 THEN DO
		CorrectWord1 = "backup"
		CorrectWord2 = "its"
	END	/*Ends "WHEN NumberOfBackupsToCreate = 1 THEN DO" Section*/

	OTHERWISE DO
		CorrectWord1 = "backups"
		CorrectWord2 = "their"
	END	/*Ends "OTHERWISE DO" Section*/
END	/*Ends "SELECT" Section*/


SAY "The program will now create "NumberOfBackupsToCreate" new commandline "CorrectWord1" with default"
SAY "     settings. After "CorrectWord2" creation you can change the various defaults to"
SAY "     the values you want. Please wait...,"
RC = SYSSLEEP(2)

DO K = 1 TO NumberOfBackupsToCreate BY 1
	J = K + ClbackCommand.0.0
	DO I = 1 TO Default.0.J BY 1
		ClbackCommand.I.J = Default.I.J
	END I	/*Ends "DO I = 1 TO Default.0.J BY 1" Section*/
	ClbackCommand.0.J = Default.0.J
END K	/*Ends "DO K = 1 TO NumberOfBackupsToCreate BY 1" Section*/
ClbackCommand.0.0 = ClbackCommand.0.0 + NumberOfBackupsToCreate

DO J = 1 TO ClbackCommand.0.0 BY 1
	DO I = 1 TO ClbackCommand.0.J BY 1
		Set_ClbackCommand.I.J = '"'ClbackCommand.I.J'"'
	END I	/*Ends "DO I = 1 TO ClbackCommand.0.J BY 1" Section*/
	Set_ClbackCommand.0.J = ClbackCommand.0.J
END J	/*Ends "DO J = 1 TO ClbackCommand.0.0 BY 1" Section*/
Set_ClbackCommand.0.0 = ClbackCommand.0.0
RC = SYSFILEDELETE(BA2KCMD_CONFIGPath)
RETURN
/*End progress words for creating 1 or more new commandline backups*/









/*Begin the process of deleting a specified commandline backup*/
DELETECOMMANDLINE:
SELECT
	WHEN UserChoice < ClbackCommand.0.0 THEN DO
		Start = UserChoice + 1
		Stop = ClbackCommand.0.0
		DO T = 1 TO ClbackCommand.0.UserChoice BY 1
			DO R = Start TO Stop BY 1
				Q = R - 1
				ClbackCommand.T.Q = ClbackCommand.T.R
				TempClbackCommand.T.Q = TempClbackCommand.T.R
			END R	/*Ends "DO R = Start TO Stop BY 1" Section*/
			ClbackCommand.T.Stop = ""
			TempClbackCommand.T.Stop = ""
		END T	/*Ends "DO T = 1 TO ClbackCommand.0.UserChoice BY 1" Section*/
		DO R = Start TO Stop BY 1
			Q = R - 1
			UpdateDateFlag.Q = UpdateDateFlag.R
		END R	/*Ends "DO R = Start TO Stop BY 1" Section*/
		UpdateDateFlag.Stop = 0
	END	/*Ends "WHEN UserChoice < ClbackCommand.0.0 THEN DO" Section*/

	OTHERWISE DO
		DO T = 1 TO ClbackCommand.0.UserChoice BY 1
			ClbackCommand.T.UserChoice = ""
			TempClbackCommand.T.UserChoice = ""
		END T	/*Ends "DO T = 1 TO ClbackCommand.0.UserChoice BY 1" Section*/
		UpdateDateFlag.UserChoice = 0
	END	/*Ends "OTHERWISE DO" Section*/
END	/*Ends "SELECT" Section*/
ClbackCommand.0.0 = ClbackCommand.0.0 - 1
TempClbackCommand.0.0 = TempClbackCommand.0.0 - 1
MultipleBackupsCount = 0 


DO R = 1 TO ClbackCommand.0.0 BY 1
	IF TempClbackCommand.27.R = "-m" THEN MultipleBackupsCount = MultipleBackupsCount + 1
END R	/*Ends "DO R = 1 TO ClbackCommand.0.0 BY 1" Section*/
IF MultipleBackupsCount < 2 THEN MultipleBackupsFlag = 0
ELSE MultipleBackupsFlag = 1
RETURN
/*End the process of deleting a specified commandline backup*/
