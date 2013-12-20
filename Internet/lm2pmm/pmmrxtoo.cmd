/*
program: pmmrxtoo.cmd
type:    REXXSAA-OS/2, Object Rexx, REXXSAA 6.x
purpose: utilities for dealing with LaMail and PMMail files
version: 0.1.0
date:    1997-02-10
changed: 1997-11-05, ---rgf, determining whether PM-Mail is running, aborts if so

author:  Rony G. Flatscher
         Rony.Flatscher@wu-wien.ac.at

needs:   ObjectRexx and REQUIRES-files

usage:   pmmrxtoo d, or via a call or ::require

         pmmrxtoo 
            ... without an option merely returns (so it and its classes can be 
                required without starting any actions)
         
         pmmrxtoo /option1 [account] [/go]:

           /s [account] [/go]   ... sort files          ... option = 1
           /d [account] [/go]   ... dump files          ... option = 2
           /h [account] [/go]   ... HTML-dump files     ... option = 3 still to implement

           any other argument starts interactive mode   ... option = 0


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


/* initialisation part of this Object Rexx program                              */

        /* PM-Mail 1.9 pre-defined values, store in .local environment          */
.local ~ pmm.Deli  = "DE"x              /* field delimiter                      */
.local ~ pmm.empty = "E1"x              /* empty field indicator                */
.local ~ pmm.LF    = "E2"x              /* LF indicator                         */
.local ~ pmm.CR    = "E3"x              /* CR indicator                         */
.local ~ pmm.CRLF  = .pmm.cr || .pmm.lf


.local ~ pmm.addrFile  = STREAM( "ADDR.DB",  "C", "QUERY EXISTS" )
IF .pmm.addrFile = "" THEN
DO
   SAY "Error: pmmrxtoo.cmd must reside in South Side's Tools directory !"
   SAY "       (did not find file" pp( "ADDR.DB" ) ||", aborting ... )"
   SIGNAL ON SYNTAX                     /* set up catching                      */
   RAISE SYNTAX 44.1 ARRAY ( "STREAM('ADDR.DB', 'C', 'QUERY EXISTS' )" )                         
END

.local ~ pmm.assocFile = STREAM( "ASSOC.DB", "C", "QUERY EXISTS" )
.local ~ pmm.booksFile = STREAM( "BOOKS.DB", "C", "QUERY EXISTS" )
.local ~ pmm.groupFile = STREAM( "GROUP.DB", "C", "QUERY EXISTS" )

.local ~ pmm.drive    = FILESPEC( "D", .pmm.addrFile )
tmpFile = STRIP( FILESPEC( "P", .pmm.addrFile ), "T", "\" )
.local ~ pmm.toolPath = .pmm.drive || tmpFile
.local ~ pmm.MailPath = SUBSTR( .pmm.toolPath, 1, LASTPOS( "\", .pmm.toolPath ) ) || "PMMAIL"



        /* set DB-files in class objects        */
.addr     ~ filename = .pmm.addrFile
.assoc    ~ filename = .pmm.assocFile
.books    ~ filename = .pmm.booksFile
.group    ~ filename = .pmm.groupFile

        /* globally used data           */
tmpDBList = .list ~ of( .accounts, .addr, .assoc, .books, .group )
        /* account related data         */
tmpAccList = .list ~ of( .sigs, .creplies, .filters, .folder.ini )

        /* load DB-definitions, needed e.g. for lm_migr.cmd (LaMail -> PMM1.9 migration) */
DO item OVER tmpDBList
   item ~ newFromFile           /* create appropriate objects from file-definitions     */
END



IF ARG() = 0 THEN RETURN        /* called via a REQUIRES directive or without arguments */


        /* /s [account] [/go]   ... sort files          ... option = 1
           /d [account] [/go]   ... dump files          ... option = 2
           /h [account] [/go]   ... HTML-dump files     ... option = 3 still to implement

           any other argument starts interactive mode   ... option = 0
        */



PARSE ARG "/"option account "/"go       /* parse command line           */

/*
IF TRANSLATE( go ) <> "GO" THEN         /* warn user that PM-Mail *must* not be running !       */
*/
DO
   IF bisPMMailActive() THEN
   DO
      CALL Beep 2500, 250; CALL Beep 2500, 250; CALL Beep 2500, 250
      SAY "PMMRXTOO.CMD: PM-Mail utility package (Object Rexx)"
      SAY
      SAY "ATTENTION !"
      SAY
      SAY "PM-Mail *MUST NOT* be running, otherwise unpredictable *ERRORs* occur !!"
      SAY
      SAY "Please close PM-Mail and restart this program."
      EXIT -1
   END

/*
   answer = "Y"                         /* set default answer   */
   answer  = get_choice( answer, "Is PM-Mail running ? (Y/n)" )
   SAY
   IF answer = "Y" THEN CALL abort
*/
END

option = POS( TRANSLATE( LEFT( option, 1 ) ), "SDH" )   /* determine option     */

/* Bug in ORX-Parser !!!

option = POS( TRANSLATE( LEFT( option ) ), "SDH" )      /* determine option     */
*/



tmpAccObjColl = .accounts ~ ObjectColl       /* get account object collection        */
bInteractive = .false           /* default to batch modus                       */

IF option = 0 THEN              /* interactive mode             */
DO
   bInteractive = .true         /* indicate that interactive modus is run       */
   SAY "PMMRXTOO.CMD: PM-Mail utility package (Object Rexx)"
   SAY
   SAY "PM-Mail drive:         " pp( .pmm.drive )
   SAY "PM-Mail toolPath:      " pp( .pmm.ToolPath )
   SAY "PM-Mail MailPath:      " pp( .pmm.MailPath )
   SAY
   SAY "ADDR.BK         :      " pp( .pmm.addrFile )
   SAY "ASSOC.BK        :      " pp( .pmm.assocFile )
   SAY "BOOKS.BK        :      " pp( .pmm.booksFile )
   SAY "GROUP.BK        :      " pp( .pmm.groupFile )
   SAY
   SAY

   SAY RIGHT( "(1)" , 10 ) "Sort all PM-Mail files"
   SAY RIGHT( "(2)" , 10 ) "Dump content of all PM-Mail files"
/*
   SAY RIGHT( "(3)" , 10 ) "Dump content of all PM-Mail files in HTML"
*/
   SAY
   CALL CHAROUT , "Enter choice: 1-3 or 0, 'q' to quit: "

   option = get_answer( "Q", 3, "F" )
   SAY; SAY
   IF option = 0 | option = "Q" THEN call abort



   IF tmpAccObjColl ~ items = 1 THEN            /* only one account defined, use it     */
   DO
      tmpList = .list ~ of( tmpAccObjColl ~ firstitem )     /* retrieve account object      */
      tmpDir = ( tmpAccObjColl ~ firstitem ) ~ objectData   /* get object data              */
      SAY "using only account by default:" pp( tmpDir ~ acctdiskname ) pp( tmpDir ~ acctname ) 
   END
   ELSE
   DO
      answer = "A"                         /* set default answer   */
      answer  = get_choice( answer, "Which account(s) do you wish to process ? (A/c)",,
                            "Process A(ll) accounts or c(choose), q(uit)  ? (A/c)", "ACQ" )
      bAllAcc = ( answer = "A" )
   
      IF \ bAllAcc THEN                         /* choose an account            */
      DO
         /* ask for all accounts of choosing single account   */
         SAY "Choose the PM-Mail account to work with:"
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
         CALL CHAROUT , "Enter choice: 1-" || i ", a(ll acounts), 0 or q(uit):"
         answer = get_answer( "QA", i, "Force" )        /* ask user which account to use  */
         IF answer = "Q" | answer = 0 THEN CALL abort
         bAllAcc = ( answer = "A" )             /* all accounts or just a few ?         */

         IF \ bAllAcc THEN              /* save single account to process       */
            tmpList = .list ~ of( choice.answer )       /* retrieve account object      */
      END

      IF bAllAcc THEN                   /* work on all account objects  */
         tmpList = tmpAccObjColl
   END
END
ELSE                    /* batch mode: deal with arguments, see whether valid account was given */
DO
   IF account = "" THEN                 /* no account given, work on all accounts       */
      tmpList = tmpAccObjColl
   ELSE                                 /* look up account object               */
   DO
      account = TRANSLATE( STRIP( account ) )
      tmpObj = .accounts ~ lookupTable ~ at( account )  /* retrieve account object      */

      IF tmpObj = .nil THEN 
      DO
         SAY "account" pp( account ) "does not exist, aborting ..."
         CALL abort
      END
      tmpList = .list ~ of( tmpObj )    /* process specific account             */
   END
END




        /* SORT-option                                                          */
IF option = 1 THEN                      /* sort all files ...                   */
DO
        /* globally used data           */
   DO tmpItem OVER tmpDBList            /* loop over DB-files                   */
      tmpItem ~ sortedReplace           /* have class object sort its objects and replace the file */
   END

        /* account related data         */
   DO workAccObj  OVER tmpList          /* loop over account objects    */
      tmpAcctPath = workAccObj ~ ObjectData ~ full_path 
      DO tmpItem OVER tmpAccList        /* loop over collected objects  */
         tmpItem ~ newFromFile( tmpAcctPath )
         tmpItem ~ sortedReplace        /* have class object sort its objects and replace the file */
      END 
   END
END
ELSE

        /* DUMP-option                                                          */
IF option = 2 THEN                      /* dump all relevant infos to STDOUT    */
DO
                /* global data          */
   outFile = "DUMP.TXT"
   IF STREAM( outFile, "C", "QUERY EXISTS" ) <> "" THEN   /* exists already, chosse another name  */
      outFile = SysTempFileName( "DUMP_???.TXT" )

   IF bInteractive THEN
     SAY "dumping all chosen data to file" pp( outFile ) || ", be patient ... ;-)"

        /* set Object Rexx output monitor to the a stream (= file); 
           i.e. all STDOUT-processing (e.g. SAY) will be directed to 
           the file !!! (a real gimmick) */
   tmpStream = .stream ~ new( outfile ) ~~ command( "OPEN WRITE" )

   .output ~ destination( tmpStream )     

   .output ~ SAY( "Dumping globally stored information ..." )
   .output ~ SAY()
   DO item OVER tmpDBList
      item ~ dump                       /* dump all objects             */
   END

                /* account data         */
   .output ~ SAY()
   .output ~ SAY( "Dumping account - related information ..." )

   DO workAccObj  OVER tmpList          /* loop over account objects    */
      .output ~ SAY( LEFT( "", 79, "=" ) )
      .output ~ SAY()
       workAccObj ~ dump                 /* dump account-infos           */
      .output ~ SAY( LEFT( "", 60, "=" ) )

      tmpAcctPath = workAccObj ~ ObjectData ~ full_path
      DO tmpItem OVER tmpAccList        /* loop over collected objects  */
         tmpItem ~ newFromFile( tmpAcctPath )
         tmpItem ~ dump                 /* have class dump its objects  */
      END 
   END

   .output ~ destination                /* restore previous Object Rexx output monitor  */
   tmpStream ~ close                    /* close stream (= file)        */
   SAY "Dumping finished, results in:" pp( outFile )
END


IF option = 3 THEN
DO
   IF bInteractive THEN
     SAY "dumping all chosen data in HTML, be patient ... ;-)"

   CALL BEEP 2500, 250
   SAY "HTML-dump not implemented yet, ..."
END

EXIT

SYNTAX : RAISE PROPAGATE                /* raise error in caller        */


get_choice : PROCEDURE                  /* general procedure to ask for an action       */
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

abort : PROCEDURE 
   CALL BEEP 2000, 250
   SAY "aborting PM-Mail tool 'PMMRXTOO.CMD' (Object Rexx) ..."
   EXIT -1


:: REQUIRES rgf_util                    /* needs some of RGF_UTIL's functions   */
:: REQUIRES get_answ                    /* routine get_answer defined   */


:: ROUTINE PP                           /* cheap pretty-print routine           */
   RETURN "[" || ARG( 1 ) || "]"
                                                                                              








/* ============================================== class definition ==================== */
        /* abstract class, serves for subclassing       */
:: CLASS "PM_Mail"                              

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS

   self ~ ObjectColl = .list ~ new
   self ~ MaxNumber  = 0
   self ~ FileName   = ""
   self ~ LeadInData = ""


:: METHOD DropObjects           CLASS   /* drop all objects, reset to initial state     */
   self ~ init                          /* reinitialize                         */


:: METHOD setLongestProperty    CLASS
   max = 0                              /* determine length of longest property name    */

   DO item OVER self ~ PropertyList
      max = MAX( max, LENGTH( item ) )
   END
   self ~ LongestProperty = max


:: METHOD FileName              CLASS ATTRIBUTE         /* default file name for building objects*/
:: METHOD HeadingTag            CLASS ATTRIBUTE         /* porperty name to be used as heading  */
:: METHOD LongestProperty       CLASS ATTRIBUTE         /* no. chars of longest property name   */
:: METHOD MaxNumber             CLASS ATTRIBUTE         /* maximum surrogate number used        */
:: METHOD ObjectColl            CLASS ATTRIBUTE         /* collection of instantiated objects   */
:: METHOD PropertyList          CLASS ATTRIBUTE         /* list of stored properties            */

:: METHOD leadinData            CLASS ATTRIBUTE         /* store version number if in file      */


:: METHOD sortedReplace         CLASS           /* sort objects and replace file                */

   IF self ~ ObjectColl ~ items = 0 THEN RETURN /* nothing to do                */
   workFile = self ~ FileName

        /* rgf_util sort, define collection, method to send it, arguments to go with method     */
   tmpArray = sortCollection( self ~ ObjectColl, .array ~ of( "SORT", .array ~ of( self ~ HeadingTag ) )  ) 



   CALL STREAM workFile, "C", "OPEN REPLACE"    /* open file for replacement    */

   IF self ~ leadinData <> "" THEN              /* a leadin (PM-Mail version number ?   */
      CALL LINEOUT workFile, self ~ leadinData

   DO i = 1 TO tmpArray ~ items / 2
      CALL LINEOUT workFile, tmpArray[ i, 2 ]   /* MAKESTRING will turn objects into PMMail-format */
   END

   CALL STREAM workFile, "C", "CLOSE"           /* close                        */




        /* use .output environment monitor; it'll print to STDOUT by default, 
           but it is possible to change its destination temporarily, e.g. to a file     */
:: METHOD dump                  CLASS           /* dump entire collection               */

   .output ~ SAY( "dumping all objects of type" pp( self ~ id ) )
   tmpString = "                   total of" pp( self ~ ObjectColl ~ items ) "objects"
   items = self ~ ObjectColl ~ items
   IF items > 0 THEN tmpString = tmpString || ", highest used number" pp( self ~ MaxNumber )
   .output ~ SAY( tmpString )
       

   IF self ~ hasMethod( "FileName" ) THEN       /* is property method "FileName" there? */
      .output ~ SAY( "               created from" pp( self ~ FileName ) )

   .output ~ SAY()

        /* rgf_util sort, define collection, method to send it, arguments to go with method     */
   tmpArray = sortCollection( self ~ ObjectColl, .array ~ of( "SORT", .array ~ of( self ~ HeadingTag ) )  ) 

   DO i = 1 TO tmpArray ~ items / 2
      tmpArray[ i, 2 ] ~ dump
   END
   .output ~ SAY( LEFT( "", 60, "=" ) )


:: METHOD NewFromString         CLASS   /* create instance from string          */
   USE ARG allString

   crlf = "0D0A"x                       /* records delimited by CR-LF           */

   DO WHILE allString <> ""
      PARSE VAR allString tmpString  ( crlf ) allString

      tmpDir = .directory ~ new
      DO property OVER self ~ PropertyList 
         PARSE VAR tmpString tmpValue ( .pmm.Deli ) tmpString
   
         IF tmpValue <> .pmm.empty THEN /* only store non-empty values          */
            tmpDir ~ setentry( property, TRANSLATE( tmpValue, crlf , .pmm.crlf  ) )
   
         IF tmpString = "" THEN LEAVE   /* string exhausted, if so leave        */
      END                                       
                                                
      IF tmpString <> "" THEN           /* save leftovers  untouched            */
         tmpDir ~ xleftover = tmpString
   
      tmpObj = self ~ new( tmpDir )
   END

   IF VAR( "tmpObj" ) THEN RETURN tmpObj        /* return last instance created */




:: METHOD newFromFile        CLASS      /* read file and create instances off of it     */
   USE ARG inFile

   IF \ VAR( "inFile" ) THEN                    /* no argument given ?          */
     inFile = self ~ FileName                   /* use file stored with class   */

   CALL STREAM inFile, "C", "OPEN READ"         /* read entire file             */

   tmpLine = LINEIN( inFile )                   /* read first line              */
   IF DATATYPE( tmpLine, "N" ) THEN
   DO
      self ~ leadinData = tmpLine               /* save leadin                  */
      tmpString = CHARIN( inFile,  , CHARS( inFile ) )  /* read remaining chars */
   END
   ELSE
   DO
      CALL CHARIN inFile, 1, 0  /* set read position to the beginning for CHARS() */
      tmpString = CHARIN( inFile, 1, CHARS( inFile ) )  /* read entire file     */
   END

   CALL STREAM inFile, "C", "CLOSE"

   self ~ NewFromString( tmpString )            /* create objects from file     */








        /* -------------------------------------- method definition (instance) -------- */
:: METHOD INIT                          /* initalisation, storing directory for object  */
   USE ARG tmpDir 

   self ~ ObjectData = tmpDir

   self ~ class ~ ObjectColl   ~ insert( self ) /* add to list stored with class        */

   IF tmpDir ~ hasentry( "NUMBER" ) THEN        /* determine maximum number             */
      self ~ class ~ MaxNumber = MAX( self ~ class ~ MaxNumber, tmpDir ~ number )


:: METHOD ObjectData   ATTRIBUTE        /* allow access to nickName             */

        

        /* use .output environment monitor; it'll print to STDOUT by default, 
           but it is possible to change its destination temporarily, e.g. to a file     */
:: METHOD dump                          /* dump contents of object              */
   objectDir   = self ~ ObjectData
   HeadingTag  = self ~ class ~ HeadingTag
   maxLength   = self ~ class ~ LongestProperty

   .output ~ SAY( HeadingTag pp( objectDir ~ entry( HeadingTag ) ) )
   HeadingTag = TRANSLATE( HeadingTag )


   tmpArray = sortCollection( objectDir )
   DO i = 1 TO objectDir ~ items
      IF tmpArray[ i, 1 ] = HeadingTag THEN ITERATE

      .output ~ SAY( "   " LEFT( tmpArray[ i, 1 ], maxLength ) pp( tmpArray[ i, 2 ] ) )
   END
   SAY
   RETURN



:: METHOD MakeString                    /* render object into string representation     */
   tmpString = ""
   tmpDir = self ~ ObjectData

   crlf = "0d0a"x

   DO property OVER self ~ class ~ PropertyList

      tmpProp = tmpDir ~ entry( property )      /* get property                 */


      IF tmpProp = .nil | tmpProp = "" THEN
         tmpString = tmpString || .pmm.empty || .pmm.Deli
      ELSE
         tmpString = tmpString || TRANSLATE( tmpProp, .pmm.crlf, crlf ) || .pmm.Deli
   END

   IF tmpDir ~ hasentry( "XLEFTOVER" ) THEN     /* trailing fields, if so append        */
      tmpString = tmpString || tmpDir ~ xLeftOver

   RETURN tmpString


:: METHOD unknown                       /* unknown message was received         */
   USE ARG msgName, msgArgArray

   SELECT
      WHEN msgName = "SORTFIELD" THEN   /* return entry stored with HeadingTag in ObjectData */
           RETURN ( self ~ ObjectData ~ entry( self ~ class ~ HeadingTag ) )

      WHEN msgName = "SORT"      THEN   /* return entry of ObjectData, according to 1st msg-argument */
           RETURN ( self ~ ObjectData ~ entry( msgArgArray[ 1 ] ) )

      OTHERWISE 
           DO
              SIGNAL ON SYNTAX          /* set up catching                      */
              RAISE SYNTAX 97.1 ARRAY ( self, msgName ) /* raise appropriate error      */              
           END
   END  
   RETURN

SYNTAX : RAISE PROPAGATE                /* raise syntax error in caller's position      */




/* ============================================== class definition ==================== */
        /* class to handle PM-Mail files in more detail */
:: CLASS pmmail_DB      SUBCLASS "PM_Mail"      /* load definitions from DB-file        */


        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE             /* let super initialize                 */
   self ~ LookupTable = .table ~ new            /* initialize LookupTable               */


:: METHOD DropObjects           CLASS           /* reset class variables                */

   self ~ LookupTable = .table ~ new
   FORWARD CLASS( super )



:: METHOD LookupTable           CLASS   ATTRIBUTE       

:: METHOD newFromFile        CLASS              /* check whether already created        */

   IF self ~ ObjectColl ~ items > 0 THEN        /* already created ?                    */
   DO
      SAY pp( self ~ id || "::newFromFile::Class" ) "file" pp( self ~ fileName ),
          "already used, aborting (no new objects created) ..."
      RETURN
   END

   FORWARD CLASS ( super )              /* let super do the actual work         */



        /* -------------------------------------- method definition (instance) -------- */
:: METHOD INIT                  /* build LookupTable            */

   FORWARD CLASS ( super ) CONTINUE     /* let super initialize first           */
   selfClass = self ~ class             /* get self's class object              */
                /* "LookupTable[ HeadingTag ] = self", use "HeadingTag" as lookup-field:*/
   selfClass ~ LookupTable ~ put( self, self ~ ObjectData ~ entry( selfClass ~ HeadingTag ) )





/* ============================================== class definition ==================== */
         /* class for addresses */
:: CLASS "Addr"                 SUBCLASS pmmail_DB PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */
   self ~ FileName = .pmm.addrFile      /* set filename                         */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "E_MAIL", "ALIAS", "TRUENAME", "SHOW_ON_RMB", "COMPANY", "TITLE",,
       "H_STREET", "H_BLDG", "H_CITY", "H_STATE", "H_ZIP", "H_PHONE", "H_EXT", "H_FAX",,
       "B_STREET", "B_BLDG", "B_CITY", "B_STATE", "B_ZIP", "B_PHONE", "B_EXT", "B_FAX",,
       "NOTES", "IN_BOOK_NR",,
       "H_COUNTRY", "B_COUNTRY" )

   self ~ setLongestProperty

   self ~ HeadingTag = "ALIAS"          /* Tag to be shown                      */






/* ============================================== class definition ==================== */
         /* class for addresses */
:: CLASS "Assoc"                SUBCLASS pmmail_DB      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */
   self ~ FileName = .pmm.assocFile     /* set filename                         */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "TITLE", "MIME_TYPE", "MIME_EXT",,
                                      "PROGRAM", "ARGS", "WORKING_DIR", "SESSIONTYPE" )
   self ~ setLongestProperty

   self ~ HeadingTag = "TITLE"          /* Tag to be shown                      */




/* ============================================== class definition ==================== */
         /* class for books     */
:: CLASS "Books"                SUBCLASS pmmail_DB      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */
   self ~ FileName = .pmm.booksFile     /* set filename                         */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "NAME", "SORT_DESCE", "SORT_FIELD_NR", "NUMBER" )
   self ~ setLongestProperty

   self ~ HeadingTag = "NAME"           /* Tag to be shown                      */
        /* sort fields: 0 ... Alias
                        1 ... Real Name
                        2 ... E-Mail
                        3 ... Phone Number
        */






/* ============================================== class definition ==================== */
         /* class for groups    */
:: CLASS "Group"                SUBCLASS pmmail_DB      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */
   self ~ FileName = .pmm.groupFile     /* set filename                         */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "SHOW_ON_RMB", "NAME", "ALIAS", "DESCRIPTION",,
                                      "PATH", "IN_BOOK_NR" )
   self ~ setLongestProperty

   self ~ HeadingTag = "ALIAS"          /* Tag to be shown                      */






        /* ******************************************** */
        /* account related classes ....                 */
        /* ******************************************** */

/* ============================================== class definition ==================== */
         /* class for *all* accounts    */
:: CLASS "Accounts"             SUBCLASS pmmail_db      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "ACCTNAME", "ACCTDISKNAME", "FROMEMAIL", "FROMREAL",, 
                         "POPRECVSERV", "POPSENDSERV", "SMTPPATH", "SMTPSENDSERV", "EDITOR",,
/* MSG-Send Exit     */  "REXXSEND",    "SENDEXIT",     "SENDBG",,
/* MSG-Receive Exit  */  "REXXRECV",    "RECVEXIT",     "RECVBG",,
/* Cust-REXX-Send    */  "REXXCUSTS",   "CUSTS",        "CUSTSBG",,
/* Cust-REXX-Fetch   */  "REXXCUSTF",   "CUSTF",        "CUSTFBG",,
/* Dialer Start Exit */  "REXXBEGD",    "BEGDIAL",      "BEGDIALBG",,
/* Dialer End Exit   */  "REXXENDD",    "ENDDIAL",      "ENDDIALBG" )  
                      /* Rexx-file      Activated ?     Background execution ?  */
                                     
   self ~ setLongestProperty
   self ~ HeadingTag = "ACCTNAME"       /* Tag to be shown                      */



:: METHOD newFromFile        CLASS

   self ~ dropObjects                   /* make sure to start on a clean sheet  */
   filePattern = .pmm.MailPath || "\*.act"
   self ~ filename = filePattern


   CALL SysFileTree  filePattern, "files.", "DO"


   lookupTable = self ~ LookupTable             /* get lookup table             */
   DO i = 1 TO files.0                  /* loop over individual accounts        */
      tmpObj = self ~ new( parse_file( self, files.i ) )        /* create an instance   */
                /* add an additional lookup entry (allowing lookups on physical name of acctdir */
      lookupTable ~ put( tmpObj, TRANSLATE( tmpObj ~ objectdata ~ acctdiskname ) )
   END
   RETURN

parse_file : PROCEDURE
   USE ARG classObj, path

   file  = path || "\acct.cfg"
   fileInfo = CHARIN( file, 1, CHARS( file ) )  /* read entire file             */
   CALL STREAM file, "C", "CLOSE"


   tmpDir = .directory ~ new                   
   tmpDir ~ setentry( "full_path", path )       /* save path to ACCT-file               */
   x00 = "00"x                                  

   DO property OVER classObj ~ PropertyList         /* extract desired infos from account   */
      tmpProperty = x00 || property || x00
      PARSE VAR fileInfo ( tmpProperty ) value (x00) .

      tmpDir ~ setentry( property, value )
   END

   CALL deal_with_rexx_exits classObj, tmpDir   /* deal with REXX-exits (make them readable) */

        /* now it is safe to remove empty entries       */
   DO index OVER tmpDir
      IF tmpDir ~ entry( index ) = "" THEN      /* remove empty entries */
         tmpDir ~ setentry( index )
   END


   RETURN tmpDir


        /* render Rexx-exits into a more readable form  */
Deal_with_rexx_exits : procedure                     /* check for exits, replace entries in Dir      */
   USE ARG classObj, tmpDir


    specArr = .array ~ of( ,                            /* replacement array            */
/* --> */ "REXXSEND",  '_Rx10_MSG_Send_Exit',,
          "SENDEXIT",  '_Rx11_MSG_Send_Active',,
          "SENDBG",    '_Rx11_MSG_Send_exec_FG',,
/* --> */ "REXXRECV",  '_Rx20_MSG_Rec_Exit'     ,,  
          "RECVEXIT",  '_Rx21_MSG_Rec_Active'         ,,
          "RECVBG",    '_Rx21_MSG_Rec_exec_FG',,
/* --> */ "REXXCUSTS", '_Rx30_Cst_RX_Send'   ,,  
          "CUSTS",     '_Rx31_Cst_RX_Send_Active'  ,,    
          "CUSTSBG",   '_Rx31_Cst_RX_Send_exec_FG',,
/* --> */ "REXXCUSTF", '_Rx40_Cst_RX_Fetch'  ,,  
          "CUSTF",     '_Rx41_Cst_RX_Fetch_Active' ,,    
          "CUSTFBG",   '_Rx41_Cst_RX_Fetch_exec_FG',,
/* --> */ "REXXBEGD",  '_Rx50_Dial_Start_Exit',,  
          "BEGDIAL",   '_Rx51_Dial_Start_Active'    ,,    
          "BEGDIALBG", '_Rx51_Dial_Start_exec_FG',,
/* --> */ "REXXENDD",  '_Rx60_Dial_End_Exit'  ,,  
          "ENDDIAL",   '_Rx61_Dial_End_Active'      ,,    
          "ENDDIALBG", '_Rx61_Dial_End_exec_FG'    )
                                                                                                                  

   max = classObj ~ LongestProperty             /* get maximum number   */
   DO i = 2 TO specArr ~ items BY 2
      max = MAX( max, LENGTH( specArr[ i ] ) )
   END
   classObj ~ LongestProperty = max             /* set maximum number   */


   items = 6                                    /* items to handle per rexx-exit  */
   nrElements = specArr ~ items 
   increment = nrElements / items
   DO i = 1 TO nrElements BY increment
      IF tmpDir ~ entry( specArr[ i ] ) <> "" THEN
      DO
         value = tmpDir ~ entry( specArr[ i ] )         /* get value    */
         tmpDir ~ setentry( specArr[ i ] )              /* remove entry */
         tmpDir ~ setentry( specArr[ i + 1 ], value )   /* store under new name */
   
         bIsBG = .false                           /* second is background */
         DO k = i + 2 TO nrElements FOR 2 BY 2       /* deal with flags      */
            value = tmpDir ~ entry( specArr[ k ] )              /* get value    */

            tmpDir ~ setentry( specArr[ k ] )                   /* remove entry */
            IF bIsBG THEN
               tmpDir ~ setentry( specArr[ k + 1 ], (\C2D( value )) ) /* store under new name */
            ELSE
               tmpDir ~ setentry( specArr[ k + 1 ], C2D( value ) ) /* store under new name */
            bIsBg = \ bIsBg                         /* switch logical value */
         END
      END
      ELSE
      DO
                /* no REXX-file in Rexx-exit            */
         DO k = i TO nrElements FOR 3 BY 2              /* delete this set of entries   */
            tmpDir ~ setentry( specArr[ k ] )
         END
      END
   END
   RETURN







:: METHOD sortedReplace         CLASS   /* intercept, not allowed to write directly to ACCT.CFG ! */




/* ============================================== class definition ==================== */
         /* class for signatures                */
:: CLASS "PM_Mail_Account"      SUBCLASS "PM_Mail"      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD DeterminePath         CLASS   /* determine path for newFromFile       */
   USE ARG PATH

   IF \ VAR( "PATH" ) | ARG( 1 ) = "PATH" THEN
      path = .pmm.MailPath      /* default to FOLDER.INIs of all accounts       */
   ELSE 
      IF IsA( path, .accounts ) THEN            /* an account object ?          */
         path = path ~ ObjectData ~ full_path   /* replace with path of account */          

   RETURN path





/* ============================================== class definition ==================== */
         /* class for mail.ini's        */
:: CLASS "Folder.Ini"           SUBCLASS "PM_Mail_Account"      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "NAME", "NUMBER", "USER_DEFINED", "SORT_FIELDS",,
                                     "SORT_DESCE", "INDICATE_UNREAD_MAIL", "INDICATE_HAS_MAIL",,
                                     "FOLDER_ICON" )
/* FOLDER_ICON values:                                     

                   Folder   DownArrow   Color-meaning
        yellow       0          3       don't indicate any mail or (all mail read and not any mail indicator)
        red          1          4       indicate, if any mail, but all mail read
        green        2          5       indicate, if any unread mail

Hint: super-folders will turn to an arrow, if subfolders hava triggering mail indicators
      super-folders color will tell the mail-state of that super-folder
      super-folders folder value (=its state) will be added to DownArrow, if necessary
*/


   self ~ setLongestProperty
   self ~ HeadingTag = "NAME"           /* Tag to be shown                      */


:: METHOD sortedReplace         CLASS   /* intercept this method, doesn't apply to folders ! */


:: METHOD newFromFile        CLASS
   USE ARG path

   path = self ~ determinePath( path )  /* set path for this instance           */
   self ~ DropObjects
   self ~ fileName = path

   filePattern = path || "\FOLDER.INI"
   CALL SysFileTree  filePattern, "files.", "FOS"

   bInboxFound = .false
   DO i = 1 TO files.0                  /* loop over individual accounts        */
      tmpString = LINEIN( files.i )     /* read content of file == 1 line       */

      IF DATATYPE( tmpString, "N" ) THEN        /* a PM-Mail version line in hand ?     */
         tmpString = LINEIN( files.i )          /* if so, read second line              */

      CALL STREAM files.i, "C", "CLOSE"

      tmpObj = self ~ NewFromString( tmpString )   /* create instance from String          */
      tmpObj ~ ObjectData ~ Xfull_path = files.i   /* save full path for file              */

      IF \ bInboxFound THEN             /* look for PM-Mail's "Inbox" object */
      DO
         IF tmpObj ~ ObjectData ~ number = 1 THEN 
         DO
            inboxObj = tmpObj
            bInboxFound = .true
         END
      END
   END
   RETURN inboxObj


/* ============================================== class definition ==================== */
         /* class for signatures                */
:: CLASS "Sigs"                 SUBCLASS "PM_Mail_Account"      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "NAME", "PATH_TO_FILE", "IS_DEFAULT" )
                                     
   self ~ setLongestProperty

   self ~ HeadingTag = "NAME"           /* Tag to be shown                      */
          


:: METHOD newFromFile        CLASS
   USE ARG path

   path = self ~ determinePath( path )  /* set path for this instance           */
   self ~ DropObjects

   inFile = path || "\SIGS\SIGS.LST"  
   self ~ fileName = inFile 
   self ~ newFromFile : super( inFile ) /* use PM_MAIL's newFromFile */




/* ============================================== class definition ==================== */
         /* class for canned replies, could be subclassed from "SIGS", but left it for clearity */
:: CLASS "Creplies"             SUBCLASS "PM_Mail_Account"      PUBLIC

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "NAME", "PATH_TO_FILE" )
                                     
   self ~ setLongestProperty

   self ~ HeadingTag = "NAME"           /* Tag to be shown                      */



:: METHOD newFromFile        CLASS
   USE ARG path

   path = self ~ determinePath( path )  /* set path for this instance           */
   self ~ DropObjects

   inFile = path || "\CREPLIES\CREPLIES.LST"
   self ~ fileName = inFile 

   self ~ newFromFile : super( inFile ) /* use PM_MAIL's newFromFile */







/* ============================================== class definition ==================== */
         /* class for canned replies, could be subclassed from "SIGS", but left it for clearity */
:: CLASS "Filters"              SUBCLASS "PM_Mail_Account"      PUBLIC

:: METHOD sortedReplace         CLASS   /* intercept this method, must not apply to filters,
                                           as order of filters maybe significant        */

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD INIT                  CLASS
   FORWARD CLASS ( super ) CONTINUE     /* let super initialize                 */

        /* pattern for parsing                                  */
   self ~ PropertyList = .list ~ of( "NAME", "IS_ENABLED", "IS_COMPLEX", "CONNECT_TYPE",,
                                     "TRIGGERED_WHEN", "SEARCH1", "SEARCH1_FOR",,
                                     "SEARCH2", "SEARCH2_FOR", "COMPL_STRING",,
                                     "ACTION1", "ACTION2", "ACTION3", "ACTION4",,
                                     "ACTION5", "ACTION6" )

        /* 
           SEARCH :             "free text"



            CONNECT_TYPE :      0 ... not connected
                                1 ... AND
                                2 ... OR
                                3 ... UNLESS

            TRIGERRED_WHEN :    add values:

                                1 ... INCOMING
                                2 ... OUTGOING (pre-send)
                                4 ... OUTGOING (post-send)
                                8 ... MANUAL

            ACTION


        */
                                     
   self ~ setLongestProperty
   self ~ HeadingTag = "NAME"           /* Tag to be shown                      */


:: METHOD newFromFile           CLASS
   USE ARG path

   path = self ~ determinePath( path )  /* set path for this instance           */
   self ~ DropObjects

   inFile = Path || "\FILTERS.LST"      /* build file-name              */
   self ~ fileName = inFile 

   self ~ newFromFile : super( inFile ) /* use PM_MAIL's newFromFile */




/* check whether PMMail is running, i.e. whether "PMMail" is found in the task-list;
   this routine uses the *undocumented* RexxUtil-function "SysQuerySwitchList()";            
   returns .true, if PMMail runs, .false if it is not running   */
:: ROUTINE bisPMMailActive      PUBLIC        
   
   needle = "PMMAIL"                    /* ignore case          */
   CALL SysQuerySwitchList  "tasks." 
   
   DO i = 1 TO tasks.0; 
      IF POS( needle, TRANSLATE( tasks.i ) ) > 0 THEN RETURN .true
   END
   RETURN .false




