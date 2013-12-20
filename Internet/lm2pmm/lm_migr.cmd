/*
program: lm_migr.cmd  
type:    REXXSAA-OS/2, Object Rexx, REXXSAA 6.x
purpose: utilities for dealing with LaMail files
version: 1.0
date:    1997-02-10
changed: 1997-11-05, ---rgf, determining whether PM-Mail is running, aborts if so

author:  Rony G. Flatscher
         Rony.Flatscher@wu-wien.ac.at

needs:   lmrxtool, pmmrxtoo

usage:   "lm_migr"

All rights reserved, copyrighted 1997, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything (money
etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.
*/


.local ~ work.NewRootFolder = "LaMail.FLD"      
.local ~ work.DateTime = DATE( "S" ) TIME()


        /* main menu    */
SAY "LaMail e-mail --> PM-Mail 1.9 migration tool"
SAY
SAY
SAY "HINT: for newly created PM-Mail folders the settings of the present"
SAY "      PM Mail 'Inbox' folder will be used as a template; therefore"
SAY "      set the 'Inbox' folder properties the way you want the migrated"
SAY "      folders to be set to (e.g. sort fields, sorting order, read mail"
SAY "      indicator, ...)."
SAY
SAY "ATTENTION !"
SAY
SAY "PM-Mail MUST NOT be running, otherwise unpredictable *ERRORs* occur !!"
SAY
IF bisPMMailActive() THEN
DO
   SAY
   SAY "[PM-Mail is running, please close it and re-start migration.]"
   EXIT -1
END
"@PAUSE"

SAY
SAY "LaMail e-mail --> PM-Mail 1.9 migration tool"
SAY
SAY
SAY "LaMail related information:"
SAY
SAY " - INI-file:        " pp( .lam.IniPath  )
SAY " - NickName file:   " pp( .lam.Nickname )
SAY " - Signature file:  " pp( .lam.Signature )
SAY " - folder directory:" pp( .lam.Folders )
SAY " - inbox directory: " pp( .lam.Inbox ) 
SAY

SAY "PM-Mail 1.9 related information:"
SAY
SAY " - toolPath:        " pp( .pmm.ToolPath )
SAY " - MailPath:        " pp( .pmm.MailPath )
SAY
SAY
SAY RIGHT( "(1)" , 10 ) "Migrate LaMail e-mail"
SAY RIGHT( "(2)" , 10 ) "Delete  LaMail e-mail (final step of migration)"
SAY
CALL CHAROUT , "Enter choice: 1-2 or 0, 'q' to quit: "

answer = get_answer( "Q", 2, "F" )
SAY; SAY

                /* delete LaMail e-mails in LaMail folders      */
IF answer = 2 THEN  
DO
   CALL Beep 2500, 250; CALL Beep 2500, 250; CALL Beep 2500, 250
   SAY "Hint: deleting affects all subfolders too !"
   SAY "      (should have been migrated in step # 1)"
   
   answer = "N"
   answer  = get_choice( answer, "Do you really want to delete LaMail e-mail in the (old) LaMail folders ? (y/N)" )
   IF answer = "N" THEN CALL abort
   
   answer = "Y"
   answer  = get_choice( answer, "Should empty (old) LaMail-subdirectories be removed ? (Y/n)" )
   bRemoveDirs = ( answer = "Y" )

   answer  = "P"
   answer  = get_choice( answer, "Decide which (old) LaMail e-mail folders to delete ? (a/P/s/q)",,
                            "Choose: a(ll folders), P(rompt for), s(kip), q(uit)", "APSQ" )

   bTmpSkip = ( answer <> "A" )
   
   IF answer = "A" | answer = "P" THEN
   DO
      SAY 
      SAY "Deleting (old) LaMail e-mail folders ..."
      SAY
      
      DO item OVER .lam.FolderList              /* get a directory      */
   
         IF bTmpSkip THEN
         DO
            answer = "N"                        
            answer  = get_choice( answer, "Delete folder" pp( item ) "? (y/N/g/s/q)",,
                                  "Choose: y(es), g(o ahead, migrate all left), N(o), s(kip all), q(uit)", "YNGSQ" )
   
            IF answer = "N" THEN ITERATE        /* not this one, maybe the next ?       */
            ELSE IF answer = "S" THEN LEAVE     /* skip all             */
   
            bTmpSkip = ( answer = "Y" )         /* continue to ask ?    */
         END
   
         CALL Delete_Dirs item, bRemoveDirs     /* copy, rename LaMail e-mail           */
      END
   END

                     /* delete LaMail-Inbox ?        */
   CALL Beep 2500, 250
   SAY
   SAY "ATTENTION: If you defined the LaMail-Inbox directory" pp( .lam.inbox )
   SAY "           as your SMTPPATH in PM-View, then you might not want to delete the"
   SAY "           LaMail-Inbox ! This is because e-mail sent thru sendmail.exe"
   SAY "           is stored in this path, if set up thru OS/2's TCP/IP configuration."
   SAY 
   SAY "           (With other words, you receive your e-mail via SMTP and have OS/2"
   SAY "           place it first into LaMail's InBox-directory from which PM-Mail"
   SAY "           will fetch the e-mail on its next fetch/read-cycle.)"
   SAY 
   SAY "Warning:   If you delete the e-mails in such a case, then you mostlikely"
   SAY "           loose any new mail sent directly via SMTP to you !!"
   SAY 
   "@PAUSE"

   answer = "N"
   answer  = get_choice( answer, "Delete LaMail InBox-folder" pp( .lam.inbox, ) "? (y/N)" )

   IF answer = "Y" THEN                      /* no, finished            */
      CALL Delete_Dirs .lam.inbox, .false    /* copy, rename LaMail e-mail           */


   SAY
   CALL LINEOUT STDERR, "Migration LaMail ---> PM-Mail 1.9:" 
   CALL LINEOUT STDERR, "" 
   .logError ~ dump                /* dump any errors that occurred (from LMRXTOOL.CMD)    */
   
   
   SAY
   SAY
   SAY "Deleting (old) LaMail e-mail finished."
   SAY
   SAY "Good luck, that everything worked out ! ;-)"
   SAY "---rgf"
   
   EXIT
END


                /* Migrate LaMail e-mail ...    */

SAY "Migrate LaMail e-mail ..."
answer = "Y"                        /* default to yes       */
answer  = get_choice( answer, "Allow for skipping migration steps (interactive migration) ? (Y/n/q)",,
                      "Choose: Y(es), n(o, do entire migration automatically), q(uit)", "YNQ" )

bSkip = ( answer = "Y" )                /* allow for skipping steps ?           */







        /* migrating LaMail e-mails     */

        /* pmmrxtoo     */
        /* let user choose account to copy E-Mail-stuff to      */

SAY "Choose the PM-Mail account to which to attach the LaMail E-Mails:"
SAY
i = 0
choice. = ""
DO item OVER .accounts ~ ObjectColl
   i = i + 1
   choice.i = item 
   tmpDir = item ~ objectData 
   SAY RIGHT( "(" || i || ")", 10 ) pp( tmpDir ~ acctdiskname ) pp( tmpDir ~ acctname ) 
END 
choice.0 = i                            /* save nr of items in stem             */

SAY
CALL CHAROUT , "Enter choice: 1-" || i "or 0, 'q' to quit: "

IF .accounts ~ ObjectColl ~ items = 1 THEN      /* only one account, then use it        */
DO
   answer = 1                                   /* choose single account        */
   SAY answer "(using only account by default)" /* display feedback             */
END
ELSE
   answer = get_answer( "Q", i, "Force" )       /* ask user which account to use        */

SAY; SAY
IF answer = "Q" THEN CALL abort

.local ~ work.AcctObj  = choice.answer    /* save object representing the target account  */

.local ~ work.AcctPath = .work.AcctObj ~ objectData ~ full_path       /* save account-path    */
.local ~ work.Acct.DiskName = .work.AcctObj ~ objectData ~ AcctDiskName





        /* read files, determine respective maximum Numbers     */

/* .accounts, .addr, .assoc, .books are read in PMMRXTOO.CMD already    */
.local ~ work.maxNumbers = .directory ~ new
.work.maxNumbers ~ setentry( "BOOKS", .books ~ maxNumber )

inFolderObj = .folder.ini ~ newFromFile /* use PM-Mail's Inbox settings as a template   */
.work.maxNumbers ~ setentry( "FOLDERS", .folder.ini ~ maxNumber )


                /* create stub for FOLDER.INIs according to PM-Mails Inbox folder (#1)  */
                /* determine value for icon, assume that unread mail is present now     */
IF inFolderObj ~ ObjectData ~ indicate_Unread_Mail THEN 
   inFolderObj ~ ObjectData ~ folder_icon = 2           /* green folder */
ELSE IF inFolderObj ~ ObjectData ~ indicate_AnyMail THEN
   inFolderObj ~ ObjectData ~ folder_icon = 1           /* red folder   */
ELSE
   inFolderObj ~ ObjectData ~ folder_icon = 0           /* yellow folder*/

inFolderObj ~ ObjectData ~ user_defined = 1     /* indicate that not a system FOLDER.INI        */

                /* remove name and number from ini-folder-string*/
PARSE VALUE ( inFolderObj ~ makestring ) WITH . ( .pmm.deli ) . ( .pmm.deli ) rest

.local ~ work.folder.template = rest            /* save in .local environment   */
                                                




        /* does LaMail folder to be created exist already ?     */

bCreate = .true
tmpTargetFolder = .work.AcctPath || "\" || .work.NewRootFolder
CALL SysFileTree tmpTargetFolder, "files.", "DO"

IF files.0 > 0 THEN                     /* oops LaMail exists already, ask user */
DO
   CALL BEEP 2000, 250
   SAY
   SAY "Problem: Default Target folder exists already !"
   SAY "       " pp( tmpTargetFolder )
   SAY
   SAY "Choices: c(reate new one), u(se existing one), q(uit)"
   SAY 
   CALL CHAROUT , "Enter your choice: "
   answer = get_answer( "CUQ", "", "F" )
   SAY; SAY


   IF answer = "Q" THEN CALL abort
   ELSE IF answer = "U" THEN bCreate = .false   /* don't attempt to create      */
   ELSE IF answer = "C" THEN            /* get name for a new folder    */
   DO
      tmpTargetFolder = SysTempFileName( .work.AcctPath || "\" || "LaMail??.FLD" )
      IF tmpTargetFolder = "" THEN
      DO
         SAY "It is not possible to create a unique LaMail folder."
         CALL abort
      END
   END
END


IF bCreate THEN                         /* create subdirectory                  */
DO
   IF SysMkDir( tmpTargetFolder ) <> 0 THEN
   DO
      SAY "Could not create target directory:" pp( tmpTargetFolder )
      CALL abort
   END
END

.local ~ work.TargetPath = tmpTargetFolder      /* save target dir              */




/* copy e-mails                 */
        /* copy signature  - file       */
                /* build target name    */

answer = "Y"                                     /* default to Yes               */
IF bSkip THEN
   answer  = get_choice( answer, "Migrate LaMail signature file ? (Y/n)" )

IF answer = "Y" THEN
DO
   SAY
   SAY "Copying LaMail's signature file ..."
   
   bCreate = .true                         /* copy LaMail signature file   */
   
   acctSigPath = .work.acctPath || "\SIGS"
   signFileName = FILESPEC( "N", .lam.Signature )
   tmpTarget = acctSigPath || "\" || signFileName
   IF STREAM( tmpTarget, "C", "QUERY EXISTS" ) <> "" THEN  /* it exists !  */
   DO
      CALL BEEP 2000, 250
      SAY
      SAY "Problem: LaMail signature file exists already !"
      SAY "       " pp( tmpTarget )
      SAY
      SAY "Choices: c(reate new file), s(kip this step), q(uit)"
      SAY 
      CALL CHAROUT , "Enter your choice: "
      answer = get_answer( "CSQ", "", "F" )
      SAY; SAY
   
      IF answer = "Q" THEN CALL abort
      ELSE IF answer = "C" THEN            /* get name for a new folder    */
      DO
         tmpTarget = SysTempFileName( acctSigPath || "\SIG_LM??.TXT" )
         IF tmpTarget = "" THEN
         DO
            SAY "It is not possible to create a unique signature name in" pp( acctSigPath )
            CALL abort
         END
      END
      ELSE IF answer = "S" THEN bCreate = .false   /* don't attempt to create      */
   END
   
   
   IF bCreate THEN
   DO
      ADDRESS CMD "copy" .lam.Signature tmpTarget
      IF RC <> 0 THEN
      DO
         SAY "Copying" pp( .lam.Singature ) "to" pp( tmpTarget ) "failed!"
         CALL abort
      END

                      /* add entry to signature list          */
      .sigs ~ newFromFile( .work.acctPath )          /* read all signatures          */

      tmpDir = .directory ~ new                       /* set-up a signature object    */
      tmpDir ~~ setentry( "NAME", "LaMail signature") ~~ setentry( "IS_DEFAULT", 0 )
      tmpDir ~~ setentry( "PATH_TO_FILE", .work.Acct.DiskName || "\SIGS\" || FILESPEC( "N", tmpTarget ) )
      .sigs ~~ new( tmpDir ) ~ sortedReplace    /* create new signature-object, sort and replace signature file */
   END
END




answer = "Y"                                    /* default to Yes               */
IF bSkip THEN
   answer  = get_choice( answer, "Migrate LaMail e-mail files ? (Y/n)" )

IF answer = "Y" THEN
DO
   /* note: copying returns a list of the new folder-names *with* appended backslash !!    */
   
           /* copy all LaMail folders to target    */

   answer = "A"                                    /* default to Yes               */
   IF bSkip THEN
      answer  = get_choice( answer, "Which LaMail e-mail folders to migrate ? (A/p/s/q)",,
                            "Choose: A(ll folders), p(rompt for), s(kip), q(uit)", "APSQ" )

   IF answer = "A" | answer = "P" THEN
   DO
      SAY 
      SAY "Copying LaMail e-mail folders ..."
      SAY
      IF bSkip THEN
         bTmpSkip = ( answer = "P" )
      ELSE
         bTmpSkip = .false
      
      DO item OVER .lam.FolderList              /* get a directory      */

         IF bTmpSkip THEN
         DO
            answer = "Y"                        /* default to yes       */
            answer  = get_choice( answer, "Migrate" pp( item ) "? (Y/n/g/s/q)",,
                                  "Choose: Y(es), g(o ahead, migrate all left), n(o), s(kip all), q(uit)", "YNGSQ" )

            IF answer = "N" THEN ITERATE        /* not this one, maybe the next ?       */
            ELSE IF answer = "S" THEN LEAVE     /* skip all             */

            btmpSkip = ( answer = "Y" )         /* continue to ask ?    */
         END
   
         targDirName = REVERSE( item )
         targDirName = REVERSE( SUBSTR( targDirName, 1, POS( "\", targDirName ) ) ) || ".FLD"
         targDir     = .work.TargetPath || targDirName 
   
         CALL Replicate_EMAIL item, targDir        /* copy, rename LaMail e-mail           */
         CALL make_folder_ini targDir              /* create PM-Mail FOLDER.INI file       */
      END
   END


                /* copying LaMail's inbox file  */
   CALL Beep 2500, 250
   SAY "ATTENTION: If you defined LaMail-Inbox directory" pp( .lam.inbox )
   SAY "           as your SMTPPATH in PM-View, then there is *NO* need to delete"
   SAY "           the LaMail-Inbox ! This is because e-mail sent thru sendmail.exe"
   SAY "           is stored in this path, if set up thru OS/2's TCP/IP configuration."
   SAY 
   SAY "           (With other words, you receive your e-mail via SMTP and have OS/2"
   SAY "           place it first into LaMail's InBox-directory from which PM-Mail"
   SAY "           will fetch the e-mail on its next read-cycle.)."
   SAY 
   SAY "           If you migrate LaMail's InBox e-mails, they will get stored "
   SAY "           underneath e.g." 
   SAY "         " pp( .work.TargetPath || "\INBOX???.FLD" ) 
   SAY "           (hint: the '????' may be filled with blanks or numbers)."
   SAY 
   SAY "           *NEVERTHELESS* if you fetch new e-mail from LaMail's InBox-Folder"
   SAY "           then all the e-mail will get moved over to *PM-Mail*'s Inbox-Folder" 
   SAY "           unless you run immediately step # 2 'Delete LaMail e-mail' right"
   SAY "           after this run."
   SAY
   SAY "           RECOMMENDATION: do *not* migrate LaMail's InBox folder in this case"
   SAY "                     (PM-Mail SMTTPATH pointing to LaMail's InBox), rather"
   SAY "                     fetch all the e-mail with PM-Mail's fetch feature."
   SAY
   "@PAUSE"

   answer = "Y"                                    /* default to Yes               */
   answer  = get_choice( answer, "Migrate LaMail's inbox e-mail ? (Y/n)" )

   IF answer = "Y" THEN
   DO
      SAY
      SAY "Copying LaMail's inbox-directory ..."
      SAY
      
              /* copy from inbox-dir          */
      
      tmpTargetDir = .work.TargetPath || "\INBOX.FLD"
      CALL SysFileTree tmpTargetDir, "folder.", "DO"
      
      IF folder.0 > 0 THEN            /* exists already !             */
      DO
         tmpTargetDir = SysTempFileName( .work.TargetPath || "\INBOX???.FLD" )
         IF tmpTargetDir = "" THEN
         DO
            SAY "It is not possible to create a unique LAMail INBOX name in" pp( .work.TargetPath )
            CALL abort
         END
      END

      CALL Replicate_EMAIL .lam.Inbox, tmpTargetDir     /* copy LaMail IN-folder        */
      CALL make_folder_ini tmpTargetDir                 /* create FOLDER.INIs   */
      
                /* delete LaMail's INBOX.NDX-index, which got renamed to INBOX.MSG      */
      ADDRESS CMD "DEL" tmpTargetDir || "\INBOX.MSG"
   END
END


answer = "Y"                                    /* default to Yes               */
IF bSkip THEN
   answer  = get_choice( answer, "Migrate LaMail address-book ? (Y/n/q)" )

IF answer = "Y" THEN
DO
   SAY
   SAY "Creating address books and addresses from LaMail definitions ..."
   SAY
           /* create Addresses, in the course create books, if necessary   */
   CALL create_accounts                         /* create accounts              */
END


SAY "Sorting and replacing address groups ..."
.group ~~ sortedReplace                 /* sort and replace groups      */
SAY "Sorting and replacing address books ..."
.books ~~ sortedReplace                 /* sort and replace books       */
SAY "Sorting and replacing addresses ..."
.addr  ~~ sortedReplace                 /* sort and replace addresses   */



        /* all error information will be written to STDERR              */
SAY
CALL LINEOUT STDERR, "Migration LaMail ---> PM-Mail 1.9:" 
CALL LINEOUT STDERR, "" 
.logError ~ dump                /* dump any errors that occurred (from LMRXTOOL.CMD)    */


SAY
SAY
SAY "Migration LaMail ---> PM-Mail 1.9 finished."
SAY
SAY "You need to reindex every migrated LaMail folder from"
SAY "within PM-Mail 1.9 (Menu: Folder ---> Re-Index)."
SAY
SAY "Good luck, that everything worked out ! ;-)"
SAY "---rgf"

EXIT



get_choice : PROCEDURE          /* general procedure to ask for an action       */
   USE ARG answer, prompt, choice_prompt, choose_string

   IF \ VAR( "choice_prompt" ) THEN choice_prompt = "Choices: y(es), n(o), q(uit)"
   IF \ VAR( "choose_string" ) THEN choose_string = "YNQ"

   SAY; SAY; SAY
   SAY LEFT( prompt || " ", 79, "=" )
   SAY
   SAY choice_prompt 
   SAY 
   CALL CHAROUT , "Enter your choice: "
   tmpAnswer = get_answer( choose_string )

   IF POS( tmpAnswer, choose_string) = 0 THEN           /* use default  */
   DO
      tmpAnswer = answer
      SAY answer "(default)"
   END

   IF tmpAnswer = "Q" THEN CALL abort                   /* abort        */

   RETURN tmpAnswer




        /* creates addresses from LaMail-NickName file,
           creates address-books in the process, if necessary   */
create_accounts : PROCEDURE

   /* loop over nicknames               */
   .nickNames ~ NewFromFile             /* read nickname-file, build nickname-objects   */

   DefaultBook = "Default Book" 
   tmpLMGroups = .list ~ new            /* for storing LaMail-addresses which are aliases       */
   tmpLMAlias  = .directory ~ new       /* to store LaMailAliases pointing to PM-Mail address objects   */

   workCRLF = .pmm.CR || .pmm.LF        /* create a short-cut for CR-LF encoding        */

   DO nickObj OVER .nickNames ~ nickNameList
      tmpDir    = nickObj ~ ObjectData 

                /* retrieve standard nick-names */
      tmpNick   = tmpDir ~ nick

      tmpName   = tmpDir ~ name
      IF tmpName = .nil THEN tmpName = ""       /* no name given !                      */

      tmpUserId = tmpDir ~ userid
      tmpNode   = tmpDir ~ node
      tmpPhone  = tmpDir ~ Phone
      tmpFolder = tmpDir ~ folder
      IF tmpFolder = .nil THEN tmpFolder = ""   /* no folder given !                    */

                /* Build Alias and real name    */
      lastName  = ""
      firstName = ""
      IF POS( ",", tmpName ) > 0 THEN           /* assume "Lastname, title First Names" */
      DO
         PARSE VAR tmpName lastName "," firstName
      END
      ELSE IF tmpName <> "" THEN
      DO                                        /* assume "title FirstNames LASTNAME"   */
         words = WORDS( tmpName )               /* get number of words in string        */
         IF words > 1 THEN
         DO
            lastName  = WORD( tmpName, words )          /* get last token as lastname   */
            firstName = SUBWORD( tmpName, 1, words - 1)
         END
         ELSE 
            lastName = tmpName
      END

      IF lastName = "" THEN                     /* no name given, use nick-name         */
         newAlias = tmpNick                     
      ELSE
      DO
         newAlias = lastName "(" || tmpNick || ")"
         IF firstName <> "" THEN
            newAlias = newAlias || "," firstName
      END


                                /* determine book this address belongs to       */
      IF tmpFolder = "" THEN workBook = DefaultBook
                        ELSE workBook = tmpFolder       /* use folder name      */


      nr = get_book_nr( workBook "(from LaMail)" )     /* find book-number     */


                /* handle alias-addresses, i.e. turn them into a PM-Mail group  */
      IF WORDS( tmpUserid ) > 1 THEN            /* process later                */
      DO
         newAlias = "Group:" newAlias           /* Hint at group                */
         tmpDir ~ nr = nr                       /* store retrieved book_number  */
         tmpDir ~ alias = newAlias        
         tmpLMGroups ~ insert( tmpDir )         /* store, process later         */
         tmpLMAlias ~ setentry( tmpNick, newAlias )     /* remember this alias  */
         ITERATE
      END



                /* check whether address exists already, using ALIAS as primary key     */
      tmpAObj = .addr ~ lookupTable ~ at( newAlias )
      IF tmpAObj <> .nil THEN                   /* don't add existing address           */
      DO
         .logError ~ new( "Address with alias" pp( newAlias ) "exists already!" )
         ITERATE
      END


                /* create address entry */
      tmpADir = .directory ~ new
      tmpADir ~ in_book_nr = nr
      tmpADir ~ e_mail     = tmpUserid || "@" || tmpNode
      tmpADir ~ alias      = newAlias
      tmpADir ~ truename   = tmpName
      IF tmpPhone <> "" THEN
      DO
         tmpAdir ~ H_phone    = tmpPhone        /* put phone number into both areas     */
         tmpAdir ~ B_phone    = tmpPhone
      END
      tmpAdir ~ SHOW_ON_RMB   = 1               /* show on right mouse button           */

                /* add all nick-name entries into note-field            */
      tmpArr = sortCollection( tmpDir )

      tmpString = "LaMail Nickname entry:" || workCRLF || workCRLF
      tmpString = tmpString || ":nick." || tmpNick || workCRLF
      DO i = 1 TO tmpDir ~ items
         IF tmpArr[ i, 1 ] = "NICK" THEN ITERATE
         tmpString = tmpString || workCRLF || "    :" || tmpArr[ i, 1 ] || "." || tmpArr[ i, 2 ]
      END
      DROP tmpArr

      tmpAdir ~ notes = tmpString

      tmpAddrObj = .addr ~ new( tmpADir )       /* create a new address         */
      tmpLMAlias ~ setentry( tmpNick, newAlias )/* used while building groups   */

      DROP tmpADir
      DROP tmpDir
   END


        /* create groups for LaMail addresses containing aliases        */
   DO tmpDir OVER tmpLMGroups                   /* iterate over list    */
      tmpGroupObj = .group ~ lookUpTable ~ at( tmpDir ~ Alias )
      IF tmpGroupObj <> .nil THEN 
      DO
         .logError ~ new( "Group with alias" pp( newAlias ) "exists already!" )
         ITERATE    /* exists already               */
      END

             /* create new, unique file              */
      newGrpFile = SysTempFileName( "GROUPS\LaM_????.GRP" )
      IF newGrpFile = "" THEN
      DO
         .logError ~ new( "Error creating group-file for" pp( tmpNick ) )
         ITERATE
      END

      tmpGDir = .directory ~ new
      tmpGDir ~~ setentry( "SHOW_ON_RMB",  1 ) ~~ setentry( "NAME", tmpDir ~ name  )
      tmpGDir ~~ setentry( "ALIAS", tmpDir ~ alias ) ~~ setentry( "IN_BOOK_NR", tmpDir ~ nr )
      tmpGDir ~~ setentry( "PATH", "..\TOOLS\" || newGrpFile )
      tmpGDir ~~ setentry( "DESCRIPTION", "Migrated from LaMail on" pp( .work.DateTime ) )
      tmpGObj = .group ~ new( tmpGDir )         /* create new group-object      */
      DROP tmpGDir

      tmpUserId = tmpDir ~ UserId

      DO WHILE tmpUserID <> ""                  /* create group file addresses  */
         PARSE VAR tmpUserID tmpEntry tmpUserID

         IF POS( "@", tmpEntry ) > 0 THEN tmpValue = tmpEntry   /* a true e-mail address        */
                                     ELSE tmpValue = tmpLMAlias ~ entry( tmpEntry )

         IF tmpValue = .nil THEN                /* outdated entries, nick-name does not exist! */
         DO
            .LogError ~ new( "Error while creating group" pp( tmpDir ~ alias ) "for LaMail nickname",
                             pp( tmpDir ~ nick ) || ", definition for" pp( tmpEntry ) ,
                             "not available in LaMail's nickname file !" )
         END
         ELSE
            CALL LINEOUT newGrpFile, tmpValue   /* MAKESTRING will render it accordingly        */
      END
      CALL STREAM newGrpFile, "C", "CLOSE"
   END


   RETURN


get_book_nr : PROCEDURE                 /* find the book, create it, if necessary       */
   USE ARG workBook

   tmpBookObj = .books ~ LookupTable ~ at( workBook ) 

   IF tmpBookObj = .nil THEN
   DO                          /* not available, hence create it       */
      tmpBDir = .directory ~ new
      tmpBDir ~ setentry( "NAME", workBook )
      nr = .work.MaxNumbers ~ books + 1      /* generate a new book number   */
      .work.MaxNumbers ~ books = nr
      tmpBDir ~~ setentry( "NUMBER", nr ) ~~ setentry( "SORT_DESCE", 0 )
      tmpBDir ~  setentry( "SORT_FIELD_NR", 0 )
      tmpBookObj = .books ~ new( tmpBDir )   /* create a new book-object     */

      DROP tmpBDir
   END
   ELSE
      nr = tmpBookObj ~ objectData ~ number  /* book nr to put address into  */
      
   RETURN nr


make_folder_ini : PROCEDURE             /* create FOLDER.INI files in all new PM-Mail folders   */
   USE ARG item     

   max = MAX( 1000, .work.maxNumbers ~ folders )        /* determine starting number for folders */
   max = max + 1

        /* extract folder name  */
   tmp = REVERSE( item )             
   PARSE VAR tmp . "." folder_name "\" .
   folder = REVERSE( folder_name ) "from LaMail" pp( .work.DateTime )

        /* setup FOLDER.INI-string      */
   tmpString =  folder || .pmm.deli || max || .pmm.deli || .work.folder.template

   tmpFile = item || "\FOLDER.INI"              /* define name for INI-file     */
   CALL STREAM tmpFile, "C", "OPEN REPLACE"
   CALL LINEOUT tmpFile, tmpString              /* create FOLDER.INI file       */
   CALL STREAM tmpFile, "C", "CLOSE"

   .work.maxNumbers ~ folders = max             /* store actual high number     */
   RETURN



abort : PROCEDURE 
   CALL BEEP 2000, 250
   SAY "aborting LaMail ---> PM-Mail 1.9 migration ..."
   EXIT -1






:: REQUIRES     pmmrxtoo                /* PM-Mail Rexx tool    */
:: REQUIRES     lmrxtool                /* LaMail Rexx tool     */

