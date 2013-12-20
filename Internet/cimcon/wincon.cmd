/* This utility will convert OS2CIM archive files to a set of MBOX format files usable by Mozilla. */
/* A big thank you goes to Geoff Worboys, who sent me code containing the vast majority of the archive format information! */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* We need ten digits to process some of the data */

NUMERIC DIGITS 10;

/* Get the name of the archive file from the command line -- the . means further vars are ignored */

PARSE ARG ArchiveFile .

/* Get the name of the archive file from the command line -- the . means further vars are ignored */

FileTest = charin(ArchiveFile, 1, 6)

IF FileTest <>'VIS000' THEN EXIT

SAY "Working"
SkipBytes=charin(ArchiveFile,,4)

Seconds=C2D(charin(ArchiveFile,,1))
Minutes=C2D(charin(ArchiveFile,,1))
Hours=C2D(charin(ArchiveFile,,1))
Day=C2D(charin(ArchiveFile,,1))
Month=C2D(charin(ArchiveFile,,1))
Year=1970+(C2D(charin(ArchiveFile,,1)))

Day=RIGHT(Day,2)
Hours=RIGHT(Hours,2,'0')
Minutes=RIGHT(Minutes,2,'0')
Seconds=RIGHT(Seconds,2,'0')

Placeholder=TRUNC((14-Month)/12)
Placeholder2=TRUNC(Year-Placeholder)
Placeholder3=TRUNC(Month+(12*Placeholder)-2)

DayOfWeek=TRUNC((Day+Placeholder2+(Placeholder2/4)-(Placeholder2/100)+(Placeholder2/400)+((31*Placeholder3)/12)))

DayOfWeek=DayOfWeek // 7

	IF DayOfWeek=0 THEN DayOfWeek="Sun"
	IF DayOfWeek=1 THEN DayOfWeek="Mon"
	IF DayOfWeek=2 THEN DayOfWeek="Tue"
	IF DayOfWeek=3 THEN DayOfWeek="Wed"
	IF DayOfWeek=4 THEN DayOfWeek="Thu"
	IF DayOfWeek=5 THEN DayOfWeek="Fri"
	IF DayOfWeek=6 THEN DayOfWeek="Sat"

	IF Month=1 THEN Month="Jan"
	IF Month=2 THEN Month="Feb"
	IF Month=3 THEN Month="Mar"
	IF Month=4 THEN Month="Apr"
	IF Month=5 THEN Month="May"
	IF Month=6 THEN Month="Jun"
	IF Month=7 THEN Month="Jul"
	IF Month=8 THEN Month="Aug"
	IF Month=9 THEN Month="Sep"
	IF Month=10 THEN Month="Oct"
	IF Month=11 THEN Month="Nov"
	IF Month=12 THEN Month="Dec"

SkipBytes=charin(ArchiveFile,,10)

Subject=charin(ArchiveFile,,(C2D(charin(ArchiveFile,,1))))

FromName=charin(ArchiveFile,,(C2D(charin(ArchiveFile,,1))))


FromAddress=charin(ArchiveFile,,(C2D(charin(ArchiveFile,,1))))

BytesInHeader=C2D(charin(ArchiveFile,,2))

SkipBytes=charin(ArchiveFile,,13)
BytesInHeader=BytesInHeader-13

BytesToSkip=C2D(charin(ArchiveFile,,1))
BytesInHeader=BytesInHeader-1
SkipBytes=charin(ArchiveFile,,BytesToSkip)
BytesInHeader=BytesInHeader-BytesToSkip

BytesToSkip=C2D(charin(ArchiveFile,,1))
BytesInHeader=BytesInHeader-1
SkipBytes=charin(ArchiveFile,,BytesToSkip)
BytesInHeader=BytesInHeader-BytesToSkip

BytesToSkip=C2D(charin(ArchiveFile,,1))
BytesInHeader=BytesInHeader-1
SkipBytes=charin(ArchiveFile,,BytesToSkip)
BytesInHeader=BytesInHeader-BytesToSkip

ToNames=C2D(charin(ArchiveFile,,1))
BytesInHeader=BytesInHeader-1

Do i=1 to ToNames

BytesInName=C2D(charin(ArchiveFile,,1))
BytesInHeader=BytesInHeader-1
ToName.i=charin(ArchiveFile,,BytesInName)
BytesInHeader=BytesInHeader-BytesInName

BytesInAddress=C2D(charin(ArchiveFile,,1))
BytesInHeader=BytesInHeader-1
ToAddress.i=charin(ArchiveFile,,BytesInAddress)
BytesInHeader=BytesInHeader-BytesInAddress

IF Left(ToAddress.i,9)='INTERNET:' Then ToAddress.i=Right(ToAddress.i,BytesInAddress-9)
			ELSE ToAddress.i=(TRANSLATE(ToAddress.i, '.', ',')"@compuserve.com")

End

SkipBytes=charin(ArchiveFile,,BytesInHeader+1)

BytesToSkip=C2D(charin(ArchiveFile,,1))

SkipBytes=charin(ArchiveFile,,2)
BytesToSkip=BytesToSkip-2

CCList=C2D(charin(ArchiveFile,,1))
BytesToSkip=BytesToSkip-1

IF CCList>0 THEN DO i=1 to CCList

	BytesInName=C2D(charin(ArchiveFile,,1))
	BytesToSkip=BytesToSkip-1
	CCName.i=charin(ArchiveFile,,BytesInName)
	BytesToSkip=BytesToSkip-BytesInName

	BytesInAddress=C2D(charin(ArchiveFile,,1))
	BytesToSkip=BytesToSkip-1
	CCAddress.i=charin(ArchiveFile,,BytesInAddress)
	BytesToSkip=BytesToSkip-BytesInAddress

IF Left(CCAddress.i,9)='INTERNET:' Then CCAddress.i=Right(CCAddress.i,BytesInAddress-9)
			ELSE CCAddress.i=(TRANSLATE(CCAddress.i, '.', ',')"@compuserve.com")

	SkipBytes=charin(ArchiveFile,,4)
	BytesToSkip=BytesToSkip-4

End

SkipBytes=charin(ArchiveFile,,BytesToSkip-16)

CharsInMsg=C2D(REVERSE(charin(ArchiveFile,,2)))

SkipBytes=charin(ArchiveFile,,15)

Body=charin(ArchiveFile,,CharsInMsg)

RealLFCR=X2C('0D0A')

OutFile='OldMail'

Success=LINEOUT(OutFile,"From - "DayOfWeek Month Day Hours":"Minutes":"Seconds Year)
Success=LINEOUT(OutFile,"Date: "DayOfWeek", "Day Month Year Hours":"Minutes":"Seconds "-0500 (EST)")
Success=LINEOUT(OutFile,"From: "FromName "<"FromAddress">")
Success=LINEOUT(OutFile,"Subject: "Subject)
Success=LINEOUT(OutFile,"To: "ToName.1 "<"ToAddress.1">,")
IF ToNames>1 THEN DO i=2 to ToNames
	Success=LINEOUT(OutFile,ToName.i "<"ToAddress.i">")
END
IF CCList>1 THEN DO i=1 to CCList
	Success=LINEOUT(OutFile,CCName.i "<"CCAddress.i">")
END

Success=LINEOUT(OutFile,"Priority: Normal")
Success=LINEOUT(OutFile,"Mime-Version: 1.0")
Success=LINEOUT(OutFile,"Content-Type: text/plain; charset=us-ascii")
Success=LINEOUT(OutFile,"Content-Transfer-Encoding: 7bit")
Success=LINEOUT(OutFile,"X-Mozilla-Status: 8001")
Success=LINEOUT(OutFile,RealLFCR)
Success=LINEOUT(OutFile,Body)
