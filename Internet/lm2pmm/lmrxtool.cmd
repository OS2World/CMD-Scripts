/*
program: lmrxtoo.cmd  
type:    REXXSAA-OS/2, Object Rexx, REXXSAA 6.x
purpose: utilities for dealing with LaMail files
version: 0.0.9
date:    1997-02-10
changed: ---

author:  Rony G. Flatscher
         Rony.Flatscher@wu-wien.ac.at

needs:   ObjectRexx, installed WPS-support 

usage:   "lmmrxtool d", or via a call or ::require

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


        /* LaMail values, store in .local environment   */
inifile = "USER"; app = "LAM"
inifile = strip_0( SysIni( inifile, app, "LAMIniPath" ) )
.local ~ lam.bFound    = ( inifile <> "ERROR:" )

IF .lam.bFound THEN                  /* LaMail not found                     */
DO
   .local ~ lam.IniPath   = inifile
   .local ~ lam.NickName  = strip_0( SysIni( inifile, app, "NAMES"      ) )
   .local ~ lam.Signature = strip_0( SysIni( inifile, app, "NOTESIG"    ) )
   .local ~ lam.Folders   = strip_0( SysIni( inifile, app, "FoldersDir" ) )
   .local ~ lam.Inbox     = strip_0( SysIni( inifile, app, "InboxDir"   ) )
   .local ~ lam.zone      = strip_0( SysIni( inifile, app, "ZONE"       ) )

   .local ~ lam.FolderList = get_lamail_folders()
END

IF ARG() > 0 THEN                       /* any argument will show LaMail settings found */
DO
   SAY "LaMail - found ? (0 = no):" pp( .lam.bFound   )
   IF .lam.bFound THEN
   DO
      SAY "LaMail - INI-file:        " pp( .lam.IniPath  )
      SAY "LaMail - NickName file:   " pp( .lam.Nickname )
      SAY "LaMail - Signature file:  " pp( .lam.Signature )
      SAY "LaMail - folder directory:" pp( .lam.Folders )
      SAY "LaMail - inbox directory: " pp( .lam.Inbox ) 
      CALL rgf_util
      CALL dump .lam.FolderList

      IF ARG( 1 ) > 1 THEN
      DO
         .nickNames ~ NewFromFile               /* read NickName file, create NN-objects        */
         .nickNames ~ dump                      /* dump all nicknames                           */
      END
   END
END

EXIT 


STRIP_0 : PROCEDURE                     /* remove trailing "00"x                */
   RETURN STRIP( ARG( 1 ), "Trailing", "00"x )


:: REQUIRES rgf_util                    /* needs some of RGF_UTIL's functions   */


:: ROUTINE PP                           /* cheap pretty-print routine           */
   RETURN "[" || ARG( 1 ) || "]"
                                                                                              


:: ROUTINE GET_LAMAIL_FOLDERS           /* find out what LaMail folders there are       */

   pattern = .lam.Folders || "\*.ndx"        /* look for index files         */
   CALL SysFileTree pattern, "folders.", "FO"

   list    = .list ~ new
   DO i = 1 TO folders.0
      PARSE VAR folders.i filestem "." .        /* PARSE filestem               */
      CALL SysFileTree filestem, "aha.", "DO"   /* check for directory itself   */
      IF aha.0 = 1 THEN list ~ insert( aha.1 )  /* save directory for processing */
   END
   RETURN list





:: ROUTINE Delete_EMail         /* delete e-mail in given directory     */
   USE ARG targDir, bRemoveDir

   bRemoveDir = ( bRemoveDir = .true )  /* only remove dir, if flag was explicitly set  */

   tmpPattern = targDir || "\*.*"

   SAY "Deleting files:" pp( tmpPattern )

   CALL SysFileTree tmpPattern, "todelete.", "FO"
   SAY "    total of" pp( todelete.0 ) "files."

   DO j = 1 TO todelete.0                 /* delete files                 */
      IF SysFileDelete( todelete.j ) <> 0 THEN
         .logError ~ new( "Error deleting:" pp( todelete.j ) )
   END

   IF bRemoveDir THEN                           /* remove directory ?   */
   DO
      SAY "Removing dir:  " pp( targDir )
      IF SysRmDir( targDir ) <> 0 THEN
         .logError ~ new( "Error removing directory:" pp( targDir ) )
   END
   SAY
   RETURN



        /* delete e-mail in directory and subdirectories        */
:: ROUTINE Delete_Dirs          PUBLIC
   USE ARG targDir, bRemoveDir

   CALL SysFileTree targDir || "\*", "aha.", "DOS"      /* check for directory itself   */

   DO i = aha.0 TO 1 BY -1                              /* walk the dir-list in reverse order   */
      CALL Delete_EMail aha.i, .true
   END

   CALL Delete_EMail targDir, bRemoveDir                /* delete e-mail in starting folder too */





:: ROUTINE Replicate_EMAIL      PUBLIC          /* xcopy directory, rename target       */
   USE ARG source, targDir

   /* create targDir directory           */
   IF SysMkDir( targDir ) = 0 THEN              /* create targDir directory      */
      SAY "dir" pp( targDir ) "created."
   ELSE                                         
   DO
      CALL SysFileTree targDir, "files.", "DO"  /* check, whether it exists     */
      IF files.0 = 0 THEN
      DO
         .logError ~ new( "creating dir" pp( targDir ) "FAILED !" )
         RETURN
      END
      SAY "dir" pp( targDir ) "exists already, no need to create it."
   END
   SAY

                /* xcopy                */
   command = "xcopy" source targDir "/s"
   SAY command
   ADDRESS CMD command
   IF rc <> 0 THEN
      .logError ~ new( "Error RC=" || pp( rc ) "while" pp( command ) )

                /* rename               */
   command = "ren" ( targDir || "\*.*" ) ( "*.MSG" )
   ADDRESS CMD command
   IF rc <> 0 THEN
      .logError ~ new( "Error RC=" || pp( rc ) "while" pp( command ) )
   SAY

   RETURN








        /* class for nick-name entries                                          */
:: CLASS NickNames              PUBLIC

:: METHOD INIT                  CLASS 
   EXPOSE nickNameList
   nickNameList = .list ~ new

:: METHOD nickNameList           CLASS ATTRIBUTE

:: METHOD NewFromFile            CLASS          /* create nickNames from nick-name file         */

   self ~ init                                  /* reinitialize                 */
   CALL STREAM .lam.nickName, "C", "OPEN READ"
   bDirty = .false
   DO WHILE CHARS( .lam.nickName ) > 0       /* loop over nickname file              */
      tmpLine = LINEIN( .lam.nickName )      /* read a line                          */
      PARSE VAR tmpLine ":" tag "." value

      IF TRANSLATE( tag ) = "NICK" THEN         /* a new nickname arrived               */
      DO
         IF bDirty THEN                         /* an older nickname to be created      */
         DO
            self ~ new( tmpDir )                /* create a nickname object             */
            DROP tmpDir
         END

         tmpDir = .directory ~ new              /* create a directory to store nickname entries */
         bDirty = .true
         tmpDir ~ setentry( tag, value )
         ITERATE
      END


      tmpDir ~ setentry( tag, value )
   END

   IF bDirty THEN self ~ new( tmpDir )          /* a leftover :) ?                      */

   CALL STREAM .lam.nickName, "C", "CLOSE"

:: METHOD dump                  CLASS
   EXPOSE nickNameList

   SAY "Dumping all NickName objects, total of" pp( nickNameList ~ items )

   DO item OVER nickNameList                    /* loop over list of nicknames          */
      item ~ dump
      SAY
   END



:: METHOD INIT                                  /* initalisation, storing directory for object  */
   EXPOSE  ObjectData 
   USE ARG ObjectData 

   self ~ class ~ nickNameList ~ insert( self )     /* add to set stored with class         */


:: METHOD ObjectData   ATTRIBUTE               /* allow access to nickName             */

:: METHOD dump
   EXPOSE ObjectData

   SAY LEFT( "NICK", 12) pp( ObjectData ~ nick )
   tmpArray = sortCollection( ObjectData )
   DO i = 1 TO ObjectData ~ items
      IF tmpArray[ i, 1 ] = "NICK" THEN ITERATE

      SAY "   " LEFT( tmpArray[ i, 1 ], 8 ) pp( tmpArray[ i, 2 ] )
   END
   RETURN






:: CLASS LogError       PUBLIC  /* class to log noted errors            */

        /* -------------------------------------- method definition (class) ----------- */
:: METHOD Init                  CLASS
   EXPOSE ObjectColl

   ObjectColl = .list ~ new

:: METHOD ObjectColl            CLASS   ATTRIBUTE       /* gathers errors       */

:: METHOD dump                  CLASS
   EXPOSE ObjectColl

   IF ObjectColl ~ items = 0 THEN RETURN                /* no errors to show    */

   CALL BEEP 2000, 250; CALL BEEP 2000, 250; CALL BEEP 2000, 250

   CALL LINEOUT STDERR, "Total of" pp( ObjectColl ~ items ) "*ERRORS* noted:"
   CALL LINEOUT STDERR, ""

   DO item OVER ObjectColl
      CALL LINEOUT STDERR, "***" item
   END

   CALL LINEOUT STDERR, CENTER( " End of dumping all errors ", 60, "-" )


        /* -------------------------------------- method definition (instance) -------- */
:: METHOD Init          /* save error text with class attribute */
   USE ARG errorTxt

   self ~ class ~ ObjectColl ~ insert( errorTxt )

