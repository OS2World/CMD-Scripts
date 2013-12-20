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

/* A cursory test to make sure this is an archive file -- I did not bother with any other checking because "it works for me" */

IF FileTest <>'FCUTIL' THEN EXIT

/* Get the number of filing cabinet folders */
/* The order of the chars has to be reversed because REXX wants most significant bit first */

SkipBytes=charin(ArchiveFile,,5)
NumFolders=C2D(REVERSE(charin(ArchiveFile,,2)))

/* The first and second folders are always the inbox and outbox */

	Foldername.1="Inbox"
	Foldername.2="Outbox"
	Foldernumber.1=1
	Foldernumber.2=2

do i=3 to NumFolders+2
	FolderNameNumChars=C2D(charin(ArchiveFile,,1))
	Foldername.i=charin(ArchiveFile,,FolderNameNumChars)

/* If there is a slash or backslash character in the folder name (as in OS/2!) then we can't use it as a filename in REXX */
/* There may be other forbidden characters too, but I didn't check -- "." and "-" are permitted */

	IF Pos('/',Foldername.i)>0 THEN Foldername.i=DELSTR(Foldername.i,POS('/',Foldername.i),1)
	IF Pos('\',Foldername.i)>0 THEN Foldername.i=DELSTR(Foldername.i,POS('\',Foldername.i),1)
	Foldernumber.i=C2D(REVERSE(charin(ArchiveFile,,2)))
end

/* Skip 4 bytes -- unknown purpose */

SkipBytes=charin(ArchiveFile,,4);

/* Header is finished -- here is the start of the actual messages */

StepCount=0

Do Until Chars(ArchiveFile)=0

StepCount=StepCount+1

/* Get the size of the message -- you could use this for a check if you wanted to write the code for it */

	Do Until ObjectSize>0
		ObjectSize=C2D(REVERSE(charin(ArchiveFile,,4)))
	End

/* Skip 4 bytes -- unknown purpose */

	SkipBytes=charin(ArchiveFile,,4)

	DocumentIDValue=C2D(REVERSE(charin(ArchiveFile,,4))) 

/* Read Unique ID -- does this actually mean anything? */

	UniqueIDValue=charin(ArchiveFile,,4)
	ObjectVersionNumber=charin(ArchiveFile,,1)

/* The Object Type is meaningful -- shows either e-mail or forum message */

	ObjectType=C2D(REVERSE(charin(ArchiveFile,,1)))

	ObjectFlags=charin(ArchiveFile,,2)

	FolderID=C2D(REVERSE(charin(ArchiveFile,,2)))

	do i=1 to NumFolders+2
		IF FolderID=Foldernumber.i THEN WriteToFile=Foldername.i
	end

/* Just in case there are some with no Folder ID -- imports from WINCIM appear to have this problem sometimes */

	IF FolderID=0 THEN WriteToFile="Unfiled"

/* Read in date and time and decode them */
/* I am glad Mr. Worboys worked this out because it might have taken me a week */
	
	DateAndTime=REVERSE(charin(ArchiveFile,,4))

	AndVar=X2C('FE000000')
	Placeholder=X2C(C2X(BitAnd(AndVar,DateAndTime)))
	Year=1970+(C2D(Placeholder)%(2**25))

	AndVar=X2C('01E00000')
	Placeholder=X2C(C2X(BitAnd(AndVar,DateAndTime)))
	Month=C2D(Placeholder) % (2**21)

	AndVar=X2C('001F0000')
	Placeholder=X2C(C2X(BitAnd(AndVar,DateAndTime)))

	Day=C2D(Placeholder) % (2**16)
	Day=RIGHT(Day,2)

	AndVar=X2C('0000F800')
	Placeholder=X2C(C2X(BitAnd(AndVar,DateAndTime)))

	Hour=C2D(Placeholder) % (2**11)

	Hour=RIGHT(Hour,2,'0')

	AndVar=X2C('000007E0')
	Placeholder=X2C(C2X(BitAnd(AndVar,DateAndTime)))

	Minute=C2D(Placeholder) % (2**5)
	Minute=RIGHT(Minute,2,'0')

	AndVar=X2C('0000001F')
	Second=C2D(BitAnd(AndVar,DateAndTime))
	Second=RIGHT(Second,2,'0')

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

	Receipt=REVERSE(charin(ArchiveFile,,4))

/* I hardly ever use receipts so I am not going to write the logic for this -- same as date and time above tho */

	SubjectLineSize=C2D(charin(ArchiveFile,,1))
	Subject=charin(ArchiveFile,,SubjectLineSize)

	FromNameSize=C2D(charin(ArchiveFile,,1))
	FromName=charin(ArchiveFile,,FromNameSize)

	FromAddressSize=C2D(charin(ArchiveFile,,1))
	FromAddress=charin(ArchiveFile,,FromAddressSize)

/* I think all e-mail should be either prefixed with INTERNET: or CompuServe internal, but there may be other options that I have not coded for here (from other mail systems for example) */

	IF Left(FromAddress,9)='INTERNET:' Then FromAddress=Right(FromAddress,FromAddressSize-9)
	ELSE FromAddress=(TRANSLATE(FromAddress, '.', ',')"@compuserve.com")

/* If the ObjectType=1 THEN this is an e-mail */
/* If the ObjectType=2 THEN this is a forum message */
/* There is also an obsolete ObjectType=4 which I found an example of */
/* There is apparently one other flavor for ObjectType=9 but I don't know what it is; I have never seen it */

	IF ObjectType=1 THEN Do

	/* E-mail messages can have one of two formats:  One in which 
	 the third byte is the ID length, and the name is the message ID, 
	 and the other in which the third byte is zero and the message ID 
	 is generated internally somehow.  Both cases have to be 
	 accounted for. */

		SkipBytes=charin(ArchiveFile,,2)

		MessageIDSize=C2D(charin(ArchiveFile,,1))

		IF MessageIDSize>0 THEN DO 
			MessageID=charin(ArchiveFile,,MessageIDSize)
			SkipBytes=charin(ArchiveFile,,4)
		END
		ELSE DO 
			SkipBytes=charin(ArchiveFile,,3)
			MessageIDSize=C2D(charin(ArchiveFile,,1))
			MessageID=charin(ArchiveFile,,MessageIDSize)
		END

		SkipBytes=charin(ArchiveFile,,1)

		AttachDescSize=C2D(charin(ArchiveFile,,1))
		IF AttachDescSize>0 THEN AttachDesc=charin(ArchiveFile,,AttachDescSize)

		AttachFileNameSize=C2D(charin(ArchiveFile,,1))
		IF AttachFileNameSize>0 THEN AttachFileName=charin(ArchiveFile,,AttachFileNameSize)

		SkipBytes=charin(ArchiveFile,,1)
		EmptySpace=C2D(charin(ArchiveFile,,1))
		SkipBytes=charin(ArchiveFile,,(EmptySpace+12))

		RecipientCount=C2D(REVERSE(charin(ArchiveFile,,2)))

		do i=1 to RecipientCount
			RecipientNameSize=C2D(charin(ArchiveFile,,1))
			Recipient.i=charin(ArchiveFile,,RecipientNameSize)
			RecipientAddressSize=C2D(charin(ArchiveFile,,1))
			RecipientAddress.i=charin(ArchiveFile,,RecipientAddressSize)
			SkipBytes=charin(ArchiveFile,,2)

/* ccByte tells whether the recipient was a "copy to" or not -- probably the byte before it is for bcc but I didn't check; I didn't bother to do anything with this but if you wanted to code the ccs you would want to know */

			ccByte.i=charin(ArchiveFile,,1)

/* Same as for FromAddress, remove "INTERNET:" from Internet addresses */
/* OR for Compuserve addresses, change the comma to a . and add @compuserve.com */

			IF Left(RecipientAddress.i,9)='INTERNET:' Then RecipientAddress.i=Right(RecipientAddress.i,RecipientAddressSize-9)
			ELSE RecipientAddress.i=(TRANSLATE(RecipientAddress.i, '.', ',')"@compuserve.com")

		end

		ContentSize=C2D(REVERSE(charin(ArchiveFile,,4)))
		Content=charin(ArchiveFile,,ContentSize)

/* Strip out the weird LF sequences that CompuServe uses */

 		CServeLFCR=X2C('40620A')
		RealLFCR=X2C('0D0A')
		do while POS(CServeLFCR,Content)>0
			Content=INSERT(RealLFCR,Content,(POS(CServeLFCR,Content)-1))
			Content=DELSTR(Content,POS(CServeLFCR,Content),3)
		end

/* There are also sometimes @b-CRLFs; change those too -- this ASSuMEs lines don't ever end in @b because there's no way to check */

		CServeLFCR=X2C('40620D0A')
		RealLFCR=X2C('0D0A')
		do while POS(CServeLFCR,Content)>0
			Content=INSERT(RealLFCR,Content,(POS(CServeLFCR,Content)-1))
			Content=DELSTR(Content,POS(CServeLFCR,Content),4)
		end

/* Some LFLFs show up -- delete one */		
		
		LFLF=X2C('0A0A')
		do while POS(LFLF,Content)>0
			Content=DELSTR(Content,POS(LFLF,Content),1)
		end

/* Here is where the Mozilla MBOX format shows its weakness -- if a line begins with From, it is interpreted as the start of a 
new message even if it is in the middle of message content!  Mozilla deals with this by putting a space in before any From at the 
start of a line and simply not displaying the space.  We have to check for this, and then add the critical space before the From 
part, or it screws up everything -- sentences beginning with From are not that uncommon...  The original RFC822 for MBOX 
seems to handle this differently, not recognizing From as a new header unless it is followed by a colon, if I read it correctly */

/* First check to see if the first word of the message is "From" and insert a space if it is */

		If POS("From",Content)=1 THEN Content=INSERT(" ",Content)
		If POS("from",Content)=1 THEN Content=INSERT(" ",Content)
		If POS("FROM",Content)=1 THEN Content=INSERT(" ",Content)

/* Now more common cases, with From following a carriage return */

		RegularFrom=X2C('0A46726F6D')
		MBoxFrom=X2C('0A2046726F6D')
		do while POS(RegularFrom,Content)>0
			Content=INSERT(MBoxFrom,Content,(POS(RegularFrom,Content)-1))
			Content=DELSTR(Content,POS(RegularFrom,Content),5)
		end

/* ... and check for lowercase ... */

		Regularfrom=X2C('0A66726F6D')
		MBoxFrom=X2C('0A2066726F6D')
		do while POS(Regularfrom,Content)>0
			Content=INSERT(MBoxFrom,Content,(POS(Regularfrom,Content)-1))
			Content=DELSTR(Content,POS(Regularfrom,Content),5)
		end

/* ... and all uppercase too, while we're at it. */

		RegularFROM=X2C('0A66524F4D')
		MBoxFrom=X2C('0A2066524F4D')
		do while POS(RegularFROM,Content)>0
			Content=INSERT(MBoxFrom,Content,(POS(RegularFROM,Content)-1))
			Content=DELSTR(Content,POS(RegularFROM,Content),5)
		end

		Success=LINEOUT(WriteToFile,"From - "DayOfWeek Month Day Hour":"Minute":"Second Year)
		Success=LINEOUT(WriteToFile,"Date: "DayOfWeek", "Day Month Year Hour":"Minute":"Second "-0500 (EST)")
		Success=LINEOUT(WriteToFile,"From: "FromName "<"FromAddress">")
		Success=LINEOUT(WriteToFile,"Subject: "Subject)
		Success=LINEOUT(WriteToFile,"To: "Recipient.1 "<"RecipientAddress.1">,")
		IF RecipientCount>1 THEN DO i=2 to RecipientCount
			Success=LINEOUT(WriteToFile,Recipient.i "<"RecipientAddress.i">")
		END
		Success=LINEOUT(WriteToFile,"Priority: Normal")
		Success=LINEOUT(WriteToFile,"Mime-Version: 1.0")
		Success=LINEOUT(WriteToFile,"Content-Type: text/plain; charset=us-ascii")
		Success=LINEOUT(WriteToFile,"Content-Transfer-Encoding: 7bit")
		Success=LINEOUT(WriteToFile,"X-Mozilla-Status: 8001")
/* We need an extra line-out here to terminate the message header properly */
		Success=LINEOUT(WriteToFile,RealLFCR)
		Success=LINEOUT(WriteToFile,Content)

/* Close the file to keep enough free filehandles -- not sure if this is necessary */

		Success=LINEOUT(WriteToFile)

/* Tell the user we are still working */

		SAY StepCount	

	End
	ELSE IF ObjectType=2 THEN Do
		ForumSectionNameLength=C2D(charin(ArchiveFile,,1))
		ForumSectionName=charin(ArchiveFile,,ForumSectionNameLength)

		ForumLength=C2D(charin(ArchiveFile,,1))

/* Filter off the CIS: prefix to forum name */

		IF ForumLength>4 THEN Forum=Right(charin(ArchiveFile,,ForumLength), ForumLength-4)
		ELSE Forum=charin(ArchiveFile,,ForumLength)

/* Skip over unknown bytes */

		SkipBytes=C2D(charin(ArchiveFile,,1))
		SkipBytes=charin(ArchiveFile,,SkipBytes)
		SkipBytes=charin(ArchiveFile,,3)

		ForumNameSize=C2D(charin(ArchiveFile,,1))
		ForumName=charin(ArchiveFile,,ForumNameSize)
		SectionNumber=C2D(charin(ArchiveFile,,1))

/* More unknown bytes */

		SkipBytes=charin(ArchiveFile,,4)

		ToNameSize=C2D(charin(ArchiveFile,,1))
		ToName=charin(ArchiveFile,,ToNameSize)

/* Presumably all forum participants are CompuServe members */

		ToAddressSize=C2D(charin(ArchiveFile,,1))
		ToAddress=charin(ArchiveFile,,ToAddressSize)

		If ToName="all" Then ToAddress="all@compuserve.com"
		Else ToName=(TRANSLATE(ToName, '.', ',')"@compuserve.com")

/* This information could be used to set up a file for a threaded-newsreader format; I didn't download that many forum threads so I haven't bothered with this -- I didn't need it and I'm too lazy!  If you write the code for newsreader format, please post it to Hobbes so everyone can get at it. */

		ThreadID=C2D(REVERSE(charin(ArchiveFile,,4)))
		MessageID=C2D(REVERSE(charin(ArchiveFile,,4)))
		ParentID=C2D(REVERSE(charin(ArchiveFile,,4)))
		NextID=C2D(REVERSE(charin(ArchiveFile,,4)))
		ChildID=C2D(REVERSE(charin(ArchiveFile,,4)))
		Responses=C2D(REVERSE(charin(ArchiveFile,,2)))

		ForumMessageSize=charin(ArchiveFile,,4)
		ForumMessageSize=C2D(REVERSE(ForumMessageSize))
		ForumMessage=charin(ArchiveFile,,ForumMessageSize)

/* Forum message processing needed here for fake cr-lf @b again */

 		CServeLFCR=X2C('40620A')
		RealLFCR=X2C('0D0A')
		do while POS(CServeLFCR,ForumMessage)>0
			ForumMessage=INSERT(RealLFCR,ForumMessage,(POS(CServeLFCR,ForumMessage)-1))
			ForumMessage=DELSTR(ForumMessage,POS(CServeLFCR,ForumMessage),3)
		end

/* This one is for fake lf @l */

		CServeLF=X2C('0A406C')
		RealLF=X2C('0D0A')
		do while POS(CServeLF,ForumMessage)>0
			ForumMessage=INSERT(RealLF,ForumMessage,(POS(CServeLF,ForumMessage)-1))
			ForumMessage=DELSTR(ForumMessage,POS(CServeLF,ForumMessage),3)
		end

/* Here we take care of the From lines */

		RegularFrom=X2C('0A46726F6D')
		MBoxFrom=X2C('0A2046726F6D')
		do while POS(RegularFrom,ForumMessage)>0
			ForumMessage=INSERT(MBoxFrom,ForumMessage,(POS(RegularFrom,ForumMessage)-1))
			ForumMessage=DELSTR(ForumMessage,POS(RegularFrom,ForumMessage),5)
		end

/* ... and check for lowercase ... */

		Regularfrom=X2C('0A66726F6D')
		MBoxFrom=X2C('0A2066726F6D')
		do while POS(Regularfrom,ForumMessage)>0
			ForumMessage=INSERT(MBoxFrom,ForumMessage,(POS(Regularfrom,ForumMessage)-1))
			ForumMessage=DELSTR(ForumMessage,POS(Regularfrom,ForumMessage),5)
		end

/* ... and all uppercase too, while we're at it. */

		RegularFROM=X2C('0A66524F4D')
		MBoxFrom=X2C('0A2066524F4D')
		do while POS(RegularFROM,ForumMessage)>0
			ForumMessage=INSERT(MBoxFrom,ForumMessage,(POS(RegularFROM,ForumMessage)-1))
			ForumMessage=DELSTR(ForumMessage,POS(RegularFROM,ForumMessage),5)
		end

/* If you want a mixed-case check, write it yourself */

		Success=LINEOUT(WriteToFile,"From - "DayOfWeek Month Day Hour":"Minute":"Second Year)
		Success=LINEOUT(WriteToFile,"Date: "DayOfWeek", "Day Month Year Hour":"Minute":"Second "-0500 (EST)")
		Success=LINEOUT(WriteToFile,"From: "FromName "<"FromAddress">")
		Success=LINEOUT(WriteToFile,"Subject: "ForumSectionName ForumName Subject)
		Success=LINEOUT(WriteToFile,"To: "ToName "<"ToAddress">,")
		Success=LINEOUT(WriteToFile,"Priority: Normal")
		Success=LINEOUT(WriteToFile,"Mime-Version: 1.0")
		Success=LINEOUT(WriteToFile,"Content-Type: text/plain; charset=us-ascii")
		Success=LINEOUT(WriteToFile,"Content-Transfer-Encoding: 7bit")
		Success=LINEOUT(WriteToFile,"X-Mozilla-Status: 8001")
		Success=LINEOUT(WriteToFile,RealLFCR)
		Success=LINEOUT(WriteToFile,ForumMessage)
		Success=LINEOUT(WriteToFile)

		SAY StepCount	

	end
	ELSE IF ObjectType=4 THEN Do

/* Yes, Virginia, there is an ObjectType=4 -- I found documentation saying it is "InfoPlex message (obsolete)"; 
my Type 4 message is from 1996  -- probably the last one ever sent -- and it is similar to the FORUM messages 
in format, but it does not include a "To" name or address as it was apparently used as a broadcast to all 
CompuServe members. */

/* Skip over unknown byte */

		SkipBytes=charin(ArchiveFile,,1)
		MessageIDLength=C2D(charin(ArchiveFile,,1))
		MessageID=charin(ArchiveFile,,MessageIDLength)
		
/* More unknown bytes */

		SkipBytes=charin(ArchiveFile,,4)

/* Fake a To name for MBOX purposes */

		ToName="all@compuserve.com"

/* _RemoveBrackets( _ToAddress ); */

		MessageSize=charin(ArchiveFile,,4)
		MessageSize=C2D(REVERSE(MessageSize))
		MessageText=charin(ArchiveFile,,MessageSize)

/* Forum message processing needed here for fake cr-lf again -- this time it is tricky because the LF is only one char */
/* If we knew we were using Object REXX we could just use ChangeStr() but this is more general, though it is ugly... */

 		InfoPlexLF=X2C('0A')
		FakeLFCR=X2C('0D0D')
		RealLFCR=X2C('0D0A')
		do while POS(InfoPlexLF,MessageText)>0
			MessageText=INSERT(FakeLFCR,MessageText,(POS(InfoPlexLF,MessageText)-1))
			MessageText=DELSTR(MessageText,POS(InfoPlexLF,MessageText),1)
		end

		do while POS(FakeLFCR,MessageText)>0
			MessageText=INSERT(RealLFCR,MessageText,(POS(FakeLFCR,MessageText)-1))
			MessageText=DELSTR(MessageText,POS(FakeLFCR,MessageText),1)
		end

		RegularFrom=X2C('0D0A46726F6D')
		MBoxFrom=X2C('0D0A2046726F6D')
		do while POS(RegularFrom,MessageText)>0
			MessageText=INSERT(MBoxFrom,MessageText,(POS(RegularFrom,MessageText)-1))
			MessageText=DELSTR(MessageText,POS(RegularFrom,MessageText),6)
		end

/* ... and check for lowercase ... */

		Regularfrom=X2C('0A66726F6D')
		MBoxFrom=X2C('0A2066726F6D')
		do while POS(Regularfrom,MessageText)>0
			MessageText=INSERT(MBoxFrom,MessageText,(POS(Regularfrom,MessageText)-1))
			MessageText=DELSTR(MessageText,POS(Regularfrom,MessageText),5)
		end

/* ... and all uppercase too, while we're at it. */

		RegularFROM=X2C('0A66524F4D')
		MBoxFrom=X2C('0A2066524F4D')
		do while POS(RegularFROM,MessageText)>0
			MessageText=INSERT(MBoxFrom,MessageText,(POS(RegularFROM,MessageText)-1))
			MessageText=DELSTR(MessageText,POS(RegularFROM,MessageText),5)
		end

		Success=LINEOUT(WriteToFile,"From - "DayOfWeek Month Day Hour":"Minute":"Second Year)
		Success=LINEOUT(WriteToFile,"Date: "DayOfWeek", "Day Month Year Hour":"Minute":"Second "-0500 (EST)")
		Success=LINEOUT(WriteToFile,"From: "FromName "<"FromAddress">")
		Success=LINEOUT(WriteToFile,"Subject: "Subject)
		Success=LINEOUT(WriteToFile,"To: "ToName "<"ToAddress">,")
		Success=LINEOUT(WriteToFile,"Priority: Normal")
		Success=LINEOUT(WriteToFile,"Mime-Version: 1.0")
		Success=LINEOUT(WriteToFile,"Content-Type: text/plain; charset=us-ascii")
		Success=LINEOUT(WriteToFile,"Content-Transfer-Encoding: 7bit")
		Success=LINEOUT(WriteToFile,"X-Mozilla-Status: 8001")
		Success=LINEOUT(WriteToFile,RealLFCR)
		Success=LINEOUT(WriteToFile,MessageText)
		Success=LINEOUT(WriteToFile)

	end

End

/* Eh walla, your messages are ready messieurs et madames */

EXIT