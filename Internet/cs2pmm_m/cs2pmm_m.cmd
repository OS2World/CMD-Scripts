/* GCP saved message to PMMail/2 format converter in REXX */
/* For all machines
		Purpose      :		Opens an existing Golden CommPass saved message file, extracts the message
											records, and writes them out as a text file in the format anticipated
											by PMMail/2.  User can then move the files to the appropriate PMMail/2
											directory and 'import' them using the menu item
											Folder->Re-Index
		Filename     :		cs2PMM_m.cmd
		Fileversion  :		0, 9-Nov-1999
		OS & version :		OS/2 v 3.0, v 4.0
		Author       :		[Bruce M. Judd] Bruce.Judd@innovative-engineering.com
		      ------------------------------
	- COMMAND-LINE PARAMETERS -
		Arg (1) = "-f"filename			/* Filename of message file, including extension */
		- required - not case sensitive
		Arg (1) = "-c"							/* Starting value for output filenames */
		- optional - not case sensitive
		Arg (1) = "-d"							/* Display debugging information during processing */
		- optional - not case sensitive
		Arg (2) = "-q"							/* Quiet mode */
		- optional - not case sensitive
		Arg (2) = "-h"							/* Display help text */
		- optional - not case sensitive

	- ERROR HANDLING -
		NONE

	- RETURN CODES -
		NONE

	- DEPENDENCIES -
		REXX utilities (REXXUTIL.dll)
		CCALJUL.CMD     3880   4-02-96   9:52 Jaime C. Cruz REXX script, (public domain)
		CDOW.CMD        2827   4-01-96  15:43 Jaime C. Cruz REXX script, (public domain)
		CLEPYER.CMD     1239   3-28-96  15:20 Jaime C. Cruz REXX script, (public domain)

	- REVISION HISTORY -
		 9-Nov-1999 . BMJ: Created
*/
/*======================================================================
	Define constants for this procedure
	====================================================================*/
_lineOutTerm = "0D0A"x					/* <lf> <cr> */
fhelpTemp = "cs2PMM_h.txt"
logFile = "cs2PMM_m.log"
helpFile = "cs2pmm_m.inf"

sDOW.0 = 7											/* DOW conversion table */
sDOW.1 = "Sun,"
sDOW.2 = "Mon,"
sDOW.3 = "Tue,"
sDOW.4 = "Wed,"
sDOW.5 = "Thu,"
sDOW.6 = "Fri,"
sDOW.7 = "Sat,"

iMOY.0 = 12											/* MOY conversion table */
iMOY.Jan = 01
iMOY.Feb = 02
iMOY.Mar = 03
iMOY.Apr = 04
iMOY.May = 05
iMOY.Jun = 06
iMOY.Jul = 07
iMOY.Aug = 08
iMOY.Sep = 09
iMOY.Oct = 10
iMOY.Nov = 11
iMOY.Dec = 12

/*======================================================================
	Define globals for this procedure and initialize
	====================================================================*/
arg1 = 1												/* Seed the command-line parameter parsing loop */
bdebug = 0											/* Operate in debug mode? */
bHelpOnError = 0								/* Flag to control amount of help text displayed */
bnoisy = 1											/* Query, prompt, and pamper the user? */
bprogIndicator = 1							/* Travel direction */
bTOF = 0												/* Flag that allows us to remove blank lines at the top of a msg */
exitCode = 0										/* O.k. to begin with */
fdestNameSeed = 0								/* Default if caller supplies none */
fsrcMsgsBase = ""								/* Base of caller-supplied filename */
fsrcMsgsExt = ""								/* Extension of caller-supplied filename */
ifilCount = 1										/* No. of GCP msg files found */
irecCount = 1										/* No. of GCP msg records found in the file - seeded so first prompt msg will work */
outDir = ""											/* Name of directory where .msg files will be written */
smsg = "="											/* Seed for progress indicator */

/*======================================================================
	Request external functions we will need and verify all needed
	components are present.
	====================================================================*/
Call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
If rc = 0 Then
	Signal HELPREXXU
Call SysLoadFuncs

Parse Upper Value SysSearchPath( "PATH", "jccaljul.cmd" ) With progDir "JCCALJUL.CMD"
	If progDir = "" Then
		Signal HelpJCCALJULDIR
Parse Upper Value SysSearchPath( "PATH", "jcdow.cmd" ) With progDir "JCDOW.CMD"
	If progDir = "" Then
		Signal HelpJCDOWDIR
Parse Upper Value SysSearchPath( "PATH", "jclepyer.cmd" ) With progDir "JCLEPYER.CMD"
	If progDir = "" Then
		Signal HelpJCLEPYERDIR

/* Parse the command-line parameters passed in by the caller */
Parse Upper Arg argRemainder
Do While argRemainder <> ""
	Parse Var argRemainder "-"arg1 argRemainder
	flagType = Left( arg1, 1 )
	arg1 = SubStr( arg1, 2 )			/* Allows caller to use space between flag and data - or not */
	Select
		When flagType = "C" Then
			Parse Var arg1 fdestNameSeed .

		When flagType = "D" Then Do
			bdebug = 1
		End /* Do */

		When flagType = "F" Then Do
			If arg1 = "" Then					/* Caller used a space */
				Parse Var argRemainder arg1 argRemainder
			Parse Var arg1 fsrcMsgsBase "." fsrcMsgsExt .
		End /* Do */

		When flagType = "H" Then
			Signal HELPSYNTAX

		When flagType = "Q" Then
			bnoisy = 0

		Otherwise
			NOP												/* It was some argument we don't respect */

	End /* Select */
End /* While */

/* Apply assumptions to the sourcefile name */
If fsrcMsgsExt = "" Then
	fsrcMsgsExt = "sav"
fsrcMsgs = fsrcMsgsBase || "." || fsrcMsgsExt	/* Assemble the filename */
If fsrcMsgsBase = "" Then
	Signal HELPSOURCE

/* Validate the seed counter */
If fdestNameSeed = "" | Verify( fdestNameSeed, "0123456789" ) Then
	Signal HELPCOUNT

/* Give the caller confirmation that we interpreted the command-line correctly */
If bnoisy Then Do
	msgText = "Searching for messages in '" || fsrcMsgs || "'"
	If bdebug <> 0 Then
		msgText = msgText "in debug mode"
	Call GenOutFileName
	msgText = msgText _lineOutTerm || "First output file will be '" || fdestMsg ||"'"
	Say msgText
	rc = CharOut( , "__?__  O.k.? (Y) or N " )
	Pull 1 answer 2 .
	If answer = "N" Then					/* If it's not o.k. to proceed, bail */
		Signal ExitMsg
End /* Do */

/* Build stem of available files to process */
rc = SysFileTree( fsrcMsgs, findSrc, "F" ) 	/* Get names of matching files */
If findSrc.0 = 0 Then
	Signal HELPSOURCE							/* Nothing to do */

/*======================================================================
	Main
	====================================================================*/
Address Cmd
Do While ifilCount <= findSrc.0
	bnoSkip = 1										/* We don't plan on skipping the current input file */
	bgetHeader = 0								/* Collecting header information? */
	bgotRecord = 0								/* Found a GCP msg record? */
	irecCount = 0									/* No. of GCP msg records found in the file */
	irecWritten = 0								/* No. of PMMail/2 txt msg files written */

	fsrcMsgs = FileSpec( "name", SubStr( findSrc.ifilCount, 39 ) )
	Parse Var fsrcMsgs outDir "."
	outDir = outDir || ".FLD\"

	/* Check to see if any files exist already. */
	rc = SysFileTree( outDir || "C*.msg", ctemp, "F" ) 	/* Get names of matching files */
	If ctemp.0 <> 0 Then 					/* Will be = 0 if no files or direcotry doesn't exist yet */
		If bnoisy Then Do
			Say "The output directory '" || outDir || "' contains .msg files."
			rc = CharOut( , "__?__  OverWrite them (Y) or N " )
			Pull 1 answer 2 .
			If answer = "N" Then			/* If it's not o.k. to proceed, bail */
				bnoSkip = 0
		End /* Do */
	/* Directory *may* not be there. */
	'MkDir' outDir

	/* Find out where on the screen we are going to display our progress indicator */
	Parse Value SysCurPos() With row col

	Call ClearFields							/* Initialize */

	/* Open data file and reset pointer.  Note that if another REXX script has this file open we
		may get nothing but blank, 0 length strings back from the LineIn routines ... don't know
		why . BMJ . 2-Jun-96 */
	rc = LineIn( fsrcMsgs, 1, 0 )

	Do While bnoSkip & lines( fsrcMsgs ) <> 0
		Parse Value LineIn( fsrcMsgs ) With lineBuf
		/* Get what might be a tag - insist that the tag start in col 1 - else we would catch
			quoted msgs also. */
		lineBufTag = Left( lineBuf, 3 )
		Select
			/* Check for the msg start flag and grab date if one is found */
			When Compare( lineBufTag, "#: " ) = 0 Then Do
				/* Msgs which contain full quotations of other msgs will have lines that 'look like' they
					belong in the header - we use this flag to prevent these tripping us up. */
				bgetHeader = 1
				If bgotRecord Then
					Call CloseMsg						/* End of present msg is implied */
				irecCount = irecCount + 1	/* Keep counter up-to-date */
				bgotRecord = 1						/* Set flag - found at least 1 msg */
				Parse Var lineBuf (lineBufTag) smsgNo "S" ssection	/* Grab the msg No. and forum section No./name */
				Parse Var smsgNo smsgNo smsgType	/* Catches (P) rivate flags and the like */
				Parse Value LineIn( fsrcMsgs ) With lineBuf /* Grab Date & Time */
				lineBuf = Strip( lineBuf, "Both" )
				Parse Var lineBuf idateDay "-" sdatemonth "-" idateYear sdateTime .
				Call FormatDate

				/* Test for index out of range */
				If fdestNameSeed - 1 + irecCount > 9999999 Then Do
					msgText = ,
						"Filename index has exceeded 9,999,999 which is the maximum allowed." _lineOutTerm || ,
						"Processing cannot continue - exiting."
					rc = LineOut( "STDERR", msgText )	/* Ensure that error is diaplayed if redirection is in effect */
					Leave										/* Do While */		
				End /* Do */
			End	/* Do */

			When bgetHeader & lineBufTag = "Sb: " Then Do	/* Found subject */
				Parse Var lineBuf (lineBufTag) ssubject
				ssubject = Strip( ssubject )				/* Can't do this in the Parse */
				/* If the message is part of a thread, replace the previously acquired msg No. with the
					thread no., allowing us to sort by thread in PMMail/2. */
				If Left( ssubject, 1 ) = "#" Then Do			/* Msg is part of a thread */
					Parse Var ssubject "#" sthreadNew "-" ssubjectNew
					/* To be a real thread ID, it must be numeric and be followed by a '-' */
					If Verify( sthreadNew, "0123456789" ) = 0 Then
						If SubStr( ssubject, Length( sthreadNew ) + 2, 1 ) = "-" Then Do
							sthread = sthreadNew
							ssubject = ssubjectNew
						End /* Do */
				End /* Do */
			End /* Do */

			When bgetHeader & lineBufTag = "Fm: " Then Do	/* Found From ID */
				Parse Var lineBuf (lineBufTag) lineBuf	/* Strip the tag and any following whitespace */
				lineBuf = Translate( lineBuf, , '>"' )	/* These are often, but not always, present */
				Parse Var lineBuf srealFrom "INTERNET:" sfrom .
				srealFrom = Strip( srealFrom, )		/* Get rid of whitespace */
				If sfrom = "" Then							/* Swap 'em */
					Parse Value srealFrom || "00"x || sfrom With sfrom "00"x srealFrom
				End /* Do */

			When bgetHeader & lineBufTag = "To: " Then Do	/* Found To ID */
				Parse Var lineBuf (lineBufTag) lineBuf	/* Strip the tag and any following whitespace */
				lineBuf = Translate( lineBuf, , '>"' )	/* These are often, but not always, present */
				Parse Var lineBuf srealTo "INTERNET:" sto .
				srealTo = Strip( srealTo, )			/* Get rid of whitespace */
				If sto = "" Then								/* Swap 'em */
					Parse Value srealTo || "00"x || sto With sto "00"x srealTo
				End /* Do */

			When bgetHeader & lineBufTag = "" Then Do
				bgetHeader = 0					/* That's it - we have everything we want now */
				Call WriteHeader				/* Start a new msg file */
				bTOF = 1								/* Start cleaning */
				End /* Do */

			Otherwise
				If bgotRecord & bgetHeader = 0 Then		/* Part of the msg - just pass it through */
					If bTOF & Length( linebuf ) = 0 Then
						Iterate
					bTOF = 0							/* We're into the msg meat now */
					If LineOut( fdestMsg, linebuf ) <> 0 Then
						rc = LineOUt( "STDERR", "Failed on attempt to write message header" irecCount "to output file:" fdestMsg )

		End /* Select */

	End	/* Do While */

	/* Close last file also - assuming one was started */
	If bgotRecord Then 						/* Clear our buffer */
		Call CloseMsg								/* End of present msg is implied */
	rc = SysCurPos( row, 0 )			/* Reset to beginning of line on which we displayed the progress indicator */
	msgText = " - We wrote" irecWritten "record"
	If irecWritten <> 1 Then				/* Long live Strunk & White */
		msgText = msgText || "s to .msg files"
	Else
		msgText = msgText "to a .msg file"
	Say msgText
	ifilCount = ifilCount + 1			/* Next file in stem */
End	/* Do While */

rc = SysCurPos( row, 0 )				/* Reset to beginning of line on which we displayed the progress indicator */

ExitMsg:
Call ShowTrailer
Exit( exitCode )

/*======================================================================
	Local Functions
	====================================================================*/
ClearFields:
	Parse Value "" With ,
	1 smsgNo,
	1 sthread,
	1 smsgType,
	1 ssection,
	1 sfrom,
	1 srealFrom,
	1 sto,
	1 srealTo,
	1 ssubject,
	1 sdateDay,
	1 idateDay,
	1 sdateMonth,
	1 idateYear,
	1 sdateTime
Return /* ClearFields */

WriteHeader:
	Call ShowProgress							/* Let user know something is going on */
	Call GenOutFileName						/* Build based on seed, etc. */	

	/* Remove any existing output file.  A bit of error checking on the rc here would be nicer ..... */
	rc = SysFileDelete( fdestMsg )

	/* Format the msg No. & (if it's not received Mail) the threadID - ASCII sorting w/in
		PMMail/2 is assumed.  Mail isn't threaded, so msgNo.'s there provide no information. */
	If Compare( Translate( Left( ssection, 17 ) ), "0/COMPUSERVE MAIL" ) > 0 Then Do
		If sthread = ""	Then					/* Use the msg No. if not part of a thread so that sorting will work */
			sthread = smsgNo
		sthread = Right( sthread, 6, "." )
		srealFrom = '"S' || ssection || '"'
		srealTo = '"' || sthread || '"'
	End /* Do */

	/* Write the message header out in PMMail-recognized txt format.  The trailing blank line is
		the trigger to PMMail/2 that there is no more header information. The CSI msg No. and msg
		'Type' is scrap data, but we keep everything. */
	hdrText = ,
		"From -"																	|| _lineOutTerm || ,
		"From:" srealFrom "<" || sfrom || ">"					|| _lineOutTerm || ,
		"To:" srealTo "<" || sto || ">"						|| _lineOutTerm || ,
		"Subject:" ssubject												|| _lineOutTerm || ,
		"Date:" sdateDay idateDay sdateMonth idateYear sdateTime	|| _lineOutTerm || ,
		"CSI_Msg_No:" smsgNo smsgType							|| _lineOutTerm
	rc = LineOut( fdestMsg, hdrText )
	If rc <> 0 Then
		rc = LineOut( "STDERR", "Failed on attempt to write message header" irecCount "to output file:" fdestMsg )
	Else
		irecWritten = irecWritten + 1

	/* Line termination is not handled correctly by the LineIn above.  The function seems to get
		hung on the <cr> and not advance to the next line .....? The following will move it to the
		beginning of the next line. */
	if C2D( CharIn( fnsAddrFile ) ) = 13 Then
		rc = LineIn( fnsAddrFile )

	/* Display debugging info if requested */
	If bdebug Then Do
		msgText = ,
			"Found msg From: '" || sfrom || "'"							_lineOutTerm || ,
			"  to addressee: '" || sto || "'" 							_lineOutTerm || ,
			"            re: '" || ssubject || "'" 						_lineOutTerm || ,
			"  No. / thread: '" || sthread || "'" 						_lineOutTerm || ,
			"         dated: '" || sdateDay sdateMonth idateYear sdateTime || "'"
		Say msgText
		rc = SysSleep( 0.25 )				/* Just enough for user to glimpse the report */
	End /* Do */
	Call ClearFields							/* Reset data fields */
Return /* WriteRecord */

FormatDate:
	If sdateYear < 31 Then				/* Make Y2k ready *;-[] */
		idateYear = "20" || idateYear	
	Else
		idateYear = "19" || idateYear

	/* Late in 1998 CSI stopped padding the day value with 0,s - fix that */
	idateDay = Right( idateDay, 2, "0" )

	/* Determine the Day-of-week for the message date - CSI doesn't supply this */

	rc = JCDOW( JCCALJUL( Value( iMOY.sdateMonth ) idateDay idateYear ) )
	sdateDay = sDOW.rc

	/* A real PMMail/2 sneak - if the time value is imcomplete, the displayed Msg Date is
		the file date instead of what's stored in the header.  Test the time value and repair
		if incomplete. */
	Parse Var sdateTime ihrs ":" imin ":" isec
	If ihrs = "" Then ihrs = "00"
	If imin = "" Then imin = "00"
	If isec = "" Then isec = "00"
	sdateTime = ihrs || ":" || imin || ":" || isec
Return /* FormatDate */

CloseMsg:
rc = Lineout( fdestMsg )				/* Close current output file */
Return /* CloseMsg */

ShowProgress:
	iprogIndicator = irecCount // 10
	If iprogIndicator = 0 Then
		bprogIndicator = -bprogIndicator
	If bprogIndicator = 1 Then
		smsg = "=>"
	Else Do
		smsg = "< "
		iprogIndicator = 10 - iprogIndicator
	End /* Do */	
	rc = SysCurPos( row, iprogIndicator )
	rc = CharOut( "STDERR", smsg )
	If bdebug & bnoisy Then
		rc = SysSleep( 0.15 )				/* Just enough that user can tell conversion is progressing */
Return /* ShowProgress */

GenOutFileName:
fdestMsg = outDir || "C" || Right( fdestNameSeed + irecCount - 1, 7, "0" ) || ".msg"
Return

ShowTrailer:
	msgText = ,
		"                    "										_lineOutTerm || ,
		"==== End of run ===="										_lineOutTerm || ,
		"We processed" ifilCount - 1 "input message file"
		If ifilCount <> 2 Then					/* Long live Strunk & White */
			msgText = msgText || "s"
	msgText = msgText 													_lineOutTerm || ,
		"===================="										_lineOutTerm || ,
		"cs2pmm_m GCP to PMMail/2 saved message conversion utility"	_lineOutTerm || ,
		"  Freeware by Bruce M. Judd, v 0, 9-Nov-1999"			_lineOutTerm || ,
		"  eMail: Bruce.Judd@innovative-engineering.com"			_lineOutTerm || ,
		"===================="
	rc = LineOut( "STDERR", msgText )
Return /* ShowTrailer */

HELPINFDIR:
	msgText = ,
		"-Could not locate the helpfile Cs2PMM-m.inf.  Either         " _lineOutTerm
	Signal HELPPATHDIR
HelpJCCALJULDIR:
	msgText = ,
		"-Could not locate the required file JCCALJUL.cmd.  Either    " _lineOutTerm
	Signal HELPPATHDIR
HelpJCDOWDIR:
	msgText = ,
		"-Could not locate the required file JCDOW.cmd.  Either       " _lineOutTerm
	Signal HELPPATHDIR
HelpJCLEPYERDIR:
	msgText = ,
		"-Could not locate the required file JCLEPYER.CMD.  Either    " _lineOutTerm
	Signal HELPPATHDIR
HELPPATHDIR:
	msgText = msgText || ,
		"the file is missing, or it and Cs2PMM_m.cmd are not in a     " _lineOutTerm || ,
		"directory which is listed in the system PATH statement.      " _lineOutTerm || ,
		"The current path is:"
	rc = LineOut( "STDERR", msgText )
	'@echo %path%'
	Signal HELPEND
HELPREXXU:
	Say "-Could not find the OS/2 REXX Utilities"
	Signal HELPEND
HELPSOURCE:
	bHelpOnError = 1
	Say "-Could not find any GCP message file(s) to match, '" || fsrcMsgs || "'"
	Say " in the current directory."
	Signal HELPSYNTAX;
HELPCOUNT:
	bHelpOnError = 1
	Say "-The supplied -c[out] value, '" || fdestNameSeed || "', is not numeric."
	Say " The value must be in the range 0 to 9,999,998"
	Signal HELPSYNTAX;
HELPSYNTAX:
	shelpPhrase = ,								/* Speed up the I/O */
		"-The syntax at the command-line is:                                     " _lineOutTerm || ,
		"     cs2pmm_m -f[ ]sourceFile [-c#######] [-d[ebug]] [-q[uiet] [-h[elp]]"
	If bHelpOnError Then Do
		rc = LineOut( "STDERR", shelpPhrase )
		If bnoisy Then Do
			rc = CharOut( , "__?__  Show more help? Y or (N) " )
			Pull 1 answer 2 .	
			If answer <> "Y" Then
				Signal HELPEND
		End /* Do */
		Else
			Signal HELPEND
	End /* Do */

	Parse Upper Value SysSearchPath( "PATH", "cs2pmm_m.cmd" ) With progDir "CS2PMM_M.CMD"
	If progDir = "" Then
		Signal HELPINFDIR
	Else Do
		'@start view' progDir || helpFile
		Signal HELPEND
	End /* Do */
HELPTEXT:
	shelpPhrase = shelpPhrase _lineOutTerm || _lineOutTerm || ,
		"================= F3 or Alt-F4 to Exit this screen =================" _lineOutTerm || _lineOutTerm || ,
		"-This program reads GCP saved message files only.                   " _lineOutTerm || _lineOutTerm || ,
		"-The program must be executed from within the directory containing  " _lineOutTerm ,
		" the source file(s) 'sourceFile'.  If no extension is supplied with " _lineOutTerm ,
		" the 'sourcefile', '.sav' is assumed.  The output will be text      " _lineOutTerm ,
		" file(s) named in the pattern 'C#######.msg' which will be placed in" _lineOutTerm ,
		" a directory with the same base name as the 'sourcefile'.           " _lineOutTerm || _lineOutTerm || ,
		"-For the benefit of 4OS2 users, a space is permitted between the -f " _lineOutTerm ,
		" and the filename (that TAB key is fantastic! no?)                  " _lineOutTerm || _lineOutTerm || ,
		"-The optional '-c#######' will be the value that the program uses to" _lineOutTerm ,
		" construct the ####### portion of the filename of the output text   " _lineOutTerm ,
		" file(s).  ####### is a numeric value starting at the supplied      " _lineOutTerm ,
		" '-c#######'.  If 'count' is omitted, 0 is assumed.                 " _lineOutTerm || _lineOutTerm || ,
		"-The optional '-d[ebug]' will cause the program to spout out a copy " _lineOutTerm ,
		" of some of the header data fields for each found message record as " _lineOutTerm ,
 		" the program executes.  You can use the Pause / Enter keys to       " _lineOutTerm ,
		" pause / continue program execution when running in debug mode.     " _lineOutTerm || _lineOutTerm || ,
		"-The optional '-q[uiet]' will suppress all program output except for" _lineOutTerm ,
		" error messages.                                                    " _lineOutTerm || _lineOutTerm || ,
		"-The optional '-h[elp]' will cause the program to output this help  " _lineOutTerm ,
		" text                                                               " _lineOutTerm ,
		"====================================================================" _lineOutTerm || _lineOutTerm || ,
		" The steps to import the output '.msg' files to PMMail/2 follow:    " _lineOutTerm || _lineOutTerm || ,
		" 1. - Open PMMail/2 and create a new folder in the PMMail/2 account " _lineOutTerm ,
		" to receive the new messages.  If you want the messages to be placed" _lineOutTerm ,
		" in an existing folder, I still recommend creating this 'temporary' " _lineOutTerm ,
		" folder; you can 'drag-n-drop', sort, filter, etc. the new messages " _lineOutTerm ,
		" to any location and any account after they are imported.           " _lineOutTerm || _lineOutTerm || ,
		" 2. - Go to the command-line, drill down to the PMMail/2 folder you " _lineOutTerm ,
		" just created and then move all of the new 'C#######.msg' files     " _lineOutTerm ,
		" into it.                                                           " _lineOutTerm || _lineOutTerm || ,
		" 3. - Return to PMMail/2 and select the new folder; use             " _lineOutTerm ,
		" Folder->Re-Index                                                   " _lineOutTerm ,
		" to add the msg file(s) generated by this script to the folder.     " _lineOutTerm ,
		"====================================================================" _lineOutTerm || _lineOutTerm || ,
		"-Example Usage:                                                     " _lineOutTerm ,
		"     cs2pmm_m -fos2user -c500 -d                                    " _lineOutTerm ,
		" would translate the GCP saved message file named 'os2user.sav' from" _lineOutTerm ,
		" the directory, would generate output message files starting with   " _lineOutTerm ,
		" the name 'C0000500.msg', and would display debugging information   " _lineOutTerm ,
		" for each message found during the process.                         "
	If LineOut( fhelpTemp, shelpPhrase ) Then
		Say "Failed on attempt to create helpfile '" || fhelpTemp || "' in the current directoory"
	Else Do
		rc = LineOut( fhelpTemp )				/* Close the file, else we can't open for reading! */
		'@e' fhelpTemp
		rc = SysFileDelete( fhelpTemp )
	End /* Do */
HELPEND:
	Say _lineOutTerm "Cs2PMM_m: Exiting"
	exitcode = 8		/* Made up value to indicate incorrect command line parameter was passed */
	Exit( exitcode )
Return /* Help */

/* End ============================================== Local Functions */

/* End ================================================= cs2PMM_m.cmd */
