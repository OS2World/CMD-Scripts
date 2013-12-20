/* PM2POSTR.CMD -- Convert PmMail address book to Post Road Mailer           */
/*                 address book.                                             */
/* Parameters: PmMail subdirectory.  If no parameter is used, utility prompts*/
/*             user to enter PmMail subdirectory.                            */
/* (c) Copyright, 1995, InnoVal System Solutions, Inc., Luis Reyes           */

 /* Possible code values: */
 X.SAVE_FILECARDS        = X2C('0700'); X.SAVE_GROUPS           = X2C('0800')
 X.SAVE_GNAME            = X2C('2000'); X.SAVE_ADDRESSES        = X2C('2200')
 X.SAVE_GADDRESS         = X2C('2400'); X.SAVE_BOOK_NAME        = X2C('3000')
 X.SAVE_FIRST            = X2C('3500'); X.SAVE_CNAME            = X2C('4000')
 X.SAVE_COMPANY          = X2C('4500'); X.SAVE_EMAIL1           = X2C('5000')
 X.SAVE_PHONE1           = X2C('8000'); X.SAVE_PHONE2           = X2C('8500')
 X.SAVE_FAX              = X2C('9000'); X.SAVE_ADDRESS          = X2C('9500')

 Signal on HALT

 If LoadRexxUtil() then Do
    Say 'Err: Could not load Rexx Library...'
    Exit
 end  /* Do */

 If Arg() <> 0 then Do
     Arg subdir
     If subdir = '?' then Signal Help
 end /* If */
 Else Do
       Say "Enter PmMail subdirectory: "
       Pull subdir
 end  /* Else */

 If Right( subdir, Length( subdir ) ) = '\' then
   subdir = Left( subdir, Length( subdir ) - 1 )
 
 Call SysCls
 Call GreetingMsg

 PostDir = Directory()
 If Stream( PostDir|| '\POSTROAD.EXE','C','QUERY EXISTS') = '' then Signal Err
 If Stream( subdir || '\PMMAIL.EXE','C', 'QUERY EXISTS') = '' then Signal Err1
 If Stream( subdir || '\ADDRESS\ADDRBOOK.INI','C','QUERY EXISTS') = '' then Signal Err1
 If Stream( subdir || '\FOLDERS.INI', 'C', 'QUERY EXISTS') = '' then Signal Err1
 
 inBas = '\' || GetInbasketName( PostDir ) || '\'
 
 Call SetUpAll

 Exit
/*------------------------------------------------------------------------*/

SETUPALL: Procedure Expose subdir X. inBas PostDir 

 fldCount = 0
 BkCount = 0

 menu.0 = 3
 menu.1.txt = 'Convert Address Books'
 menu.1.row = 9; menu.1.col = 39 - Length( menu.1.txt ) % 2
 menu.1.act = 'Call BookStart'

 menu.2.txt = 'Convert Folders'
 menu.2.row = 10; menu.2.col = 39 - Length( menu.2.txt ) % 2
 menu.2.act = 'Call ConvertFolders'

 menu.3.txt = 'Exit'
 menu.3.row = 11; menu.3.col = 39 - Length( menu.3.txt ) % 2
 menu.3.act = 'Call Exiting'

 Call DoMenu

 Return
/*----------------------------------------------------------------------*/

DOMENU:
  colorNormal = '1B'x || '[37;40m'
  colorReverse = '1B'x || '[30;47m'
  keyEnter = '0D'x
  keyUp = '48'x
  keyDown = '50'x
  keyPrefix1 = '00'x
  keyPrefix2 = 'E0'x

  Call BringUpMenu

  Do Forever
     Call SysCurPos menu.r.row, menu.r.col
     Call CharOut 'CON:', colorReverse || menu.r.txt
     Call CharOut 'CON:', colorNormal
     key = SysGetKey('NoEcho' )
     next = r
     Select
        When key == keyEnter then
           Interpret menu.r.act
        When key == keyPrefix1 | key == keyPrefix2 then Do
           key = SysGetKey( 'NoEcho' )
           Select
              When key == keyUp then
                If r > 1 then next = r - 1
                Else next = menu.0
              When key == keyDown then
                If r < menu.0 then next = r + 1
                Else next = 1
             Otherwise Nop
           end /* Select */
        end /* When Do */
        Otherwise Nop
     end  /* Select */
     If next <> r then Do
        Call SysCurPos menu.r.row, menu.r.col
        Call CharOut 'CON:', menu.r.txt
        r = next
     end /* If Do */
  end /* Do Forever */

  Return
/*--------------------------------------------------------------------------*/
/*            Address Book Conversion Procedures and Functions              */
/*--------------------------------------------------------------------------*/

BOOKSTART: Procedure Expose X. subdir BkCount menu. colorNormal r
 /* Start Address Book Conversion */

  Call SysCurPos 13,0
  Call SysCurState( 'ON' )

  PmAddrFile = subdir || '\ADDRESS\ADDRBOOK.INI'
  Do while lines( PmAddrFile ) > 0
     PmBookName = LineIn( PmAddrFile )
     infile = subdir || '\' || LineIn(PmAddrFile )
     Say;Say 'Do you wish to convert PmMail' Strip( PmBookName ) 'address book? (Y/n)'
     Pull ans
     If Left(ans,1) = 'Y' then Call convertBook
  end /* Do while */

  Call LineOut( PmAddrFile )
  Call BringUpMenu
 
  Return
/*------------------------------------------------------------------------*/

 CONVERTBOOK: Procedure Expose infile PmBookName X. BkCount

 outfile = infile || '.ASC'
 Num = Length( infile ) - LastPos( '\', infile )

 PostDir = Directory()
 FileName = PostDir || '\' || Right( infile, Num )
 NewBkName = Right( infile, Num ) || '.ADR'

 If Stream(FileName || '.ADR','C','QUERY EXISTS') <> '' then Do
   Say newBkName || ' already exists. Do you want to replace it?(Y/n)'
   Pull ans
   If Left( ans,1) = 'Y' then 
      '@ERASE' FileName || '.ADR'
   Else Do
      Say 'Do you wish to rename destination file? (Y/n)'
      Pull ans
         If Left( ans, 1 ) = 'Y' then
               outfile = CheckFileName( outfile )
         Else Return
   end /* Else Do */
 end /* Main If Do */
 
 /* Write address book name and write to output file */
 Call LineOut outfile, '<BOOK_NAME>' || PmBookName
 Call LineOut outfile, '*Created from PmMail '||PmBookName || ' addressbook'
 Call LineOut outfile, ''

 i = 1
 /* Read in entire input file to memory. */
 Do While Lines(infile) > 0

   If i = 6 then i = 1
   lin = LineIn(infile)
   Select
      When i = 1 then
        Call NameSave
      When i = 2 then
        Call LineOut outfile, '<EMAIL1>' || lin 
      When i = 3 then
        Call LineOut outfile, '<ORGANIZATION>' || lin
      When i = 4 then
        Call LineOut outfile, '<PHONE1>' || lin
      When i = 5 then do
        Call LineOut outfile, '<COMMENTS>' || lin
        Call LineOut outfile, ''
      end /* When do */
   end /* Select */
  i = i + 1
 end /* Do while */

 Call LineOut infile  /* Close infile file */
 Call CharOut outfile /* Close output file */
 Call Asc2Adr

 If Stream( outfile, 'C', 'QUERY EXISTS') <> '' then
   '@ERASE' outfile

 BkCount = BkCount + 1

 Return
/*--------------------------------------------------------------------------*/

ASC2ADR: Procedure Expose X. outfile PostDir
 /* Writing to output file. */
 /* Based on code written by Tom Springall, Innoval Systems Solutions, Inc */

 CRLF = X2C('0D0A')
 filespec = outfile
 Num = Length( outfile ) - LastPos( '\', outfile )
 AdrFile = Right( outfile, Num )
 AdrFile = PostDir || '\' || Left( AdrFile, LastPos('.', AdrFile) ) ||'ADR'
 Lin = LineIn(filespec)

 /* Must be in the first row */
 If Left(lin,11) <> '<BOOK_NAME>' then Signal Err2
 Call SaveIt X.SAVE_BOOK_NAME, Substr(lin,12)
                                                                    
 i = 1 ; activity = 0 ; cards = 0 ; groups = 0 ; data. = ''         
                                                                    
 /* Read in entire input file to memory. */                         
 Do While Lines(filespec) > 0                                       
                                                                    
   lin = LineIn(filespec)                                           
   first = Left(lin,1)                                              
   Select                                                           
     /* blank line means new address or existence of a group */
     When first = ' ' & activity > 0 then do                        
       /* check values since last blank, if any */                  
       Call CheckI                                                  
       activity = 0                                                 
       end /* of When */                                            
     When first = '<' then do                /* it's a tag */       
       Parse var lin '<' tag '>' valu                                                                            
         If tag = 'COMMENTS' then do       /* gotta append these */
           If data.i.COMMENTS <> '' then                            
              data.i.COMMENTS = data.i.COMMENTS || CRLF             
           data.i.COMMENTS = data.i.COMMENTS || valu                
           end                                                      
         Else do                           /* otherwise, just save value */
           /* assign valu to data.i.field */                        
           V = Value('data.i.' || tag, valu)
         end /* of Else Do */
       activity = 1    /* indicate that something has been saved at level i */
       end                                                          
     Otherwise Nop                          /* skip comments, etc. */
     end /* of Select */                                            
   end /* of Do While */                                            
 Call LineOut filespec                      /* close input file */  
                                                                    
 /* entire file read in. check if last i has anything in it */      
 If i <> 0 & activity > 0 then Call CheckI                          
                                                                    
 /* save card and group counts */                                   
 Call SaveIt X.SAVE_FILECARDS, MakeNum(cards)
 Call SaveIt X.SAVE_GROUPS, MakeNum(groups)
                                                                    
 /* write out each level (each level contains an address page) */
 Do j = 1 to i - 1                                                                                                 
     If typ.j = 'CARD' then do
       /* address page must start with last name field */           
       Call SaveIt X.SAVE_CNAME, data.j.LAST_NAME  /* must be 1st */
       Call SaveIt X.SAVE_FIRST, data.j.FIRST_NAME
       Call SaveIt X.SAVE_COMPANY, data.j.ORGANIZATION
       Call SaveIt X.SAVE_EMAIL1, data.j.EMAIL1
       Call SaveIt X.SAVE_PHONE1, data.j.PHONE1
       Call SaveIt X.SAVE_ADDRESS, data.j.COMMENTS
     end /* of If Do */                                                      
 end /* of Do */
 
 Call CharOut AdrFile                /* close output files */

 Return
/*--------------------------------------------------------------------------*/

NAMESAVE:
/* Extract name */

  NameNum = words(lin)
  Select
     When NameNum >= 4 then Do
        first = word( lin, 1 ) || ' ' || word( lin, 2 )
        last = word( lin, NameNum - 1) || ' ' || word( lin, NameNum )
     end  /* Do */
     When NameNum = 3 then Do
        first = word( lin, 1 ) || ' ' || word( lin, 2 )
        last = word( lin, NameNum )
     end  /* Do */
     otherwise Do
       first = word(lin,1)
       last = word( lin, NameNum )
     end /* Do */
  end  /* select */

  Call LineOut outfile, '<LAST_NAME>' || last 
  Call LineOut outfile, '<FIRST_NAME>' || first 
  Return
/*--------------------------------------------------------------------------*/

SAVEIT: Procedure Expose AdrFile
  /* write field to output file */
  code = Left(Arg(1),4,D2C(0))
  valu = Arg(2)
  len = MakeNum(Length(valu)) 

  If 0 <> CharOut(AdrFile, code || len || valu) then Signal Err3

  Return
/*--------------------------------------------------------------------------*/

MAKENUM: Procedure
 /* Convert integer into 4-byte Intel format */

  Return Intel(D2C(Arg(1),4))
/*---------------------------------------------------------------------------*/

INTEL:  Procedure
/* Swaps bytes in an Intel 2 or 4 byte number. */

  Parse arg x

 If Length(x) = 2 then
   Return Right(x,1) || Left(x,1)
 Else
   Return Intel(Right(x,2)) || Intel(Left(x,2))
/*----------------------------------------------------------------------*/

CHECKI: Procedure Expose i data. cards typ.                     
                                                                       
  /* Check to see if any real stuff collected at the current level (i) */
  /* is it a card? */                                                  
  If data.i.LAST_NAME <> '' | data.i.ORGANIZATION <> '' then do        
    typ.i = 'CARD'                                                     
    cards = cards + 1                                                  
    i = i + 1                                                          
    end                                                                
  Else                                                               
    data.i. = ''               /* false alarm. reset */              
  Return                                                               
/*--------------------------------------------------------------------------*/

CHECKFILENAME: Procedure

  Arg outfile
  Do while nfn = ''
    Say 'Enter new file name: '
    Pull nfn
  end /* Do while */
  nfnsav = nfn

  If LastPos( '\', nfn ) <> 0 then
     nfn = Right( nfn, Length( nfn ) - LastPos( '\', nfn ) )
  If LastPos( '.', nfn ) <> 0 then
     nfn = Left( nfn, LastPos( '.', nfn ) - 1 )
  If Length( nfn ) > 8 then
     nfn = Left( nfn, 8 )
  nfn = Directory() || '\' || nfn

  If Stream( nfn || '.ADR', 'C', 'QUERY EXISTS' ) <> '' then Do
     Say;Say Strip( nfnsav ) 'already exists.'
     nfn = CheckFileName( nfn || '.ADR' )
  If LastPos( '.', nfn ) <> 0 then
     nfn = Left( nfn, LastPos( '.', nfn ) - 1 )
  end  /* Do */

  Return( nfn || '.ASC')
/*-------------------------------------------------------------------------*/
/*                  Folder Conversion Procedures and Functions             */
/*-------------------------------------------------------------------------*/

CONVERTFOLDERS: Procedure Expose subdir inBas fldCount menu. colorNormal r

  curdir = Directory()
  PmFolderLst = subdir || '\FOLDERS.INI'

  Call SysCurPos 13,0
  Call SysCurState( 'ON' )
  Say; Say 'Converting folders from PmMail to PostRoad Mailer...'

  Do while lines( PmFolderLst ) > 0
     folder = LineIn( PmFolderLst )
     foldsubdir = LineIn( PmFolderLst )
     outfile = curdir || inBas || foldsubdir || '.NLG'
     foldsubdir = subdir || '\folders\' || foldsubdir || '\*.*'
     dummy = LineIn( PmFolderLst )

     If Stream( foldsubdir, 'C', 'QUERY EXISTS' ) <> '' then Do
      /* Get the names of the PmMail msgs */

        Call SysFileTree foldsubdir, infile, 'FO'
        outfile = CheckFoldName( outfile )
        Call LineOut outfile, D2C(4) || folder || ' PmMail Folder'
                                                                              
        Do y = 1 to infile.0
           To_Flag = 0
           UserTo = ''

           Do While Word( Lin,1 ) <> 'Subject:'
              Lin = LineIn( infile.y )
              If To_Flag == 1 & LastPos( ':', Word( Lin, 1 ) ) > 0 then
                 To_Flag = 0
              If To_Flag == 1 then Lin = 'To:' Lin
              Select
                 When Word( Lin,1 ) = 'To:' then Do
                    To_Flag = 1
                    UserTo = UserTo || Right( lin, Length( lin ) - 4 ) || ' '
                 end /* When Do */
                 When Word( Lin,1 ) = 'From:' then
                    UserFrom = Word( Lin, 2 )
                 When Word( Lin,1 ) = 'Subject:' then
                    SubjLine = Right( lin, Length( lin ) - 9 )
                 When Word( Lin,1 ) = 'Date:' then
                    DateLin = Right( lin, Length( lin ) - 6 )
                 When Word( Lin,1 ) = 'Reply-To:' then
                    ReplyLine = Word( Lin, 2 )
                 Otherwise Nop
              end  /* select */
           end /* Do While */
       
           Parse Var UserTo RUser ' ' .
           num = 49 - Length( RUser )

           Call LineOut outfile, ''
           Call CharOut outfile, '<<NEW NOTE>> ' || D2C(1) || RUser
           Call CharOut outfile, Copies( ' ', num )
           Call CharOut outfile, DateSwitch(DateLin)
           Call CharOut outfile, Copies( ' ', 12 )
           Call CharOut outfile, '0   ' || UserFrom || D2C(1) || SubjLine
           Call CharOut outfile, D2C(1)|| D2C(1) || UserFrom||D2C(2)||UserTo
           Call LineOut outfile, D2C(3) || ReplyLine
           Call LineOut outfile, 'To: ' || UserTo
           Call LineOut outfile, 'Date: ' || DateLin
           Call LineOut outfile, 'From: ' || UserFrom
           Call LineOut outfile, 'Reply-To: <' ||  ReplyLine || '>'
           Call LineOut outfile, ''
           Call LineOut outfile, 'Subject: ' || SubjLine
           Call LineOut outfile, ''
                                                                                     
           Do While lines( infile.y ) > 0
              Lin = LineIn( infile.y )
              Call LineOut outfile, Lin
           end /* Do While */
                                                                                     
           Call LineOut infile.y  /* Close input file */
           Call LineOut outfile, D2C( 254 ) || D2C( 4 ) || SubjLine
        end /* Do While */

        fldCount = fldCount + 1
        Call LineOut outfile, ''
        Call Charout outfile
     end /* If Stream Do */
  end /*Do While */

  Call LineOut PmFolderLst

  Say;Say fldCount 'Folders converted.'
  '@PAUSE'

  Call BringUpMenu

  Return
/*-------------------------------------------------------------------------*/        

CHECKFOLDNAME: Procedure

 Arg outfile

 fn = Right( outfile, Length(outfile) - LastPos( '\',outfile ) )
 folddir = Left( outfile, LastPos( '\', outfile ) )
 i = 0
 tokenName = folddir || 'Pm2Post'

 If Stream( outfile, 'C', 'QUERY EXISTS') <> '' then Do
    Say;Say fn 'already exists. Rename folder: '
    Pull folderName
    If folderName = '' then Do
      Do until Stream( tokenName || i || '.NLG', 'C', 'QUERY EXISTS') = ''
        i = i +1
        outfile = tokenName || i || '.NLG'
      end /* Do Until */
    end /* If Do */
    Else Do
       Num = Length( folderName ) - LastPos( '\', folderName )
       folderName = Right( folderName, Num )

       If folderName > 8 then
          folderName = Left( folderName, 8 )

       If LastPos( '.', folderName ) <> 0 then
         Num = LastPos( '.', folderName ) - 1
       Else Num = Length( folderName )
       outfile = folddir || Strip( Left( folderName, Num ) ) || '.NLG'
    end  /* Else Do */
 
 outfile = CheckFoldName( outfile )
 end  /* If Do */

 Return( outfile )
/*------------------------------------------------------------------------*/

DATESWITCH: Procedure                                                                
/* Function returns a numeric equivalent from the abbreviated month */               
                                                                                     
 Arg Date                                                                            
                                                                                     
 Week = Word( Date, 1 )                                                              
 Day = Word( Date, 2 )                                                               
 Month = Word( Date, 3 )                                                             
 Year = Word( Date, 4 )                                                              
 Time = Word( Date, 5 )                                                              
 Stand = Word( Date, 6 )                                                             
 num = LastPos( ':', Time ) - 1                                                      
 Time = Left( Time, num )                                                            
 If Length( Time ) < 5 then                                                          
    Time = '0' || Time                                                               
                                                                                     
 Select                                                                              
    When Month = 'JAN' then                                                          
       Month = '01'                                                                  
    When Month = 'FEB' then                                                          
       Month = '02'                                                                  
    When Month = 'MAR' then                                                          
       Month = '03'                                                                  
    When Month = 'APR' then                                                          
       Month = '04'                                                                  
    When Month = 'MAY' then                                                          
       Month = '05'                                                                  
    When Month = 'JUN' then                                                          
       Month = '06'                                                                  
    When Month = 'JUL' then                                                          
       Month = '07'                                                                  
    When Month = 'AUG' then                                                          
       Month = '08'                                                                  
    When Month = 'SEP' then                                                          
       Month = '09'                                                                  
    When Month = 'OCT' then                                                          
       Month = '10'                                                                  
    When Month = 'NOV' then                                                          
       Month = '11'                                                                  
    Otherwise Month = '12'                                                           
 end  /* select */                                                                   
 DateString = '0'|| Year || '/' || Month || '/' || Day || Time || Stand 

 Return( DateString )
/*----------------------------------------------------------------------*/
/*           Other Supporting Functions and Procedures                  */
/*----------------------------------------------------------------------*/

GETINBASKETNAME: Procedure

 Arg PostDir
 basfile = PostDir || '\INBASKET.NIX'
 found = 0

 Say;Say "Enter your Inbasket name: "
 Pull inName

 If inName = '' then
   outName = GetInbasketName( PostDir )
 Else Do
   basfile = PostDir || '\INBASKET.NIX'
   Do While lines(basfile) > 0 & found <> 1
     lin = Translate( LineIn( basfile ) )
     inName = Translate( inName )
     dirName = Word( lin, 1 )
     BasIdent = SubWord( lin,2, Words(lin)-1 )
     If inName = BasIdent then found = 1
   end /* While Do */

   Call LineOut basfile

   If found <> 1 then Signal Err4
   Else outName = dirName

 end  /* Else Do */
 Say; Say;

 Return( outName )
/*----------------------------------------------------------------------*/
  
LoadRexxUtil: Procedure
  If rxFuncQuery( 'SysLoadFuncs' ) then Do
    If RxFuncAdd( 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' ) then Do
       Say "Error: Couldn't load RexxUtil library."
       Return 1
    end /* If Do */
    Call SysLoadFuncs
  end /* If Do */
 Return 0
/*----------------------------------------------------------------------*/

BRINGUPMENU:

  Call SysCls
  Call GreetingMsg

  Call SysCurState 'OFF'
  Call CharOut 'CON:', colorNormal
  Do r = 1 to menu.0
     Call SysCurPos menu.r.row, menu.r.col
     Call CharOut 'CON:', menu.r.txt
  end
  r = 1

  Return
/*------------------------------------------------------------------------*/

EXITING:
 
 Say;Say;
 Say '      ' BkCount 'Address books converted.'
 Say '      ' fldcount 'Folders converted.'
 EXIT
/*----------------------------------------------------------------------*/

HALT:
  Call SysCls
  Say;Say 'Program Interupted..'
  Say 'Ending UML2POST.CMD run...'
 
  Exit
/*----------------------------------------------------------------------*/

HELP:

 Say ''
 Say 'PM2POSTR.CMD converts PmMail folders and address books for use with the'
 Say 'Post Road Mailer.'
 Say ''
 Say 'Syntax is:  PM2POSTR <path>'
 Say ''
 Say 'All PmMail folders and address books will be visible in PostRoad Mailer'
 Say 'after execution of this utiltity.'
 Say ''
 Say 'The Inbasket name can be found on the Title bar of the PostRoad Mailer'
 Say ''
 Say 'PM2POSTR will prompt for the PmMail subdirectory if a path is not'
 Say '         specified.'
 Say ''
 Exit

/*--------------------------------------------------------------------------*/

GREETINGMSG:
  Say ''
  Say Center('PM2POSTR.CMD Converting Utility                 (c)Innoval Systems Solutions,Inc', 79)
  Say ''
  Say Center('*--Converts PmMail folders and address books for use with the--*',79)
  Say Center( 'Post Road Mailer', 79 )
  Say ''
  RETURN
/*---------------------------------------------------------------------------*/

ERR:
 Say 'Err: This Utility must be run from within PostRoad Mailer root directory.'
 Call Beep 450, 250
 Exit 1
/*--------------------------------------------------------------------------*/
ERR1:
 Say 'Err: PmMail is not installed in this directory or is missing files.'
 Call Beep 450, 250
 Exit 1
/*--------------------------------------------------------------------------*/
ERR2:
 Say 'Err: File' filespec 'does not appear to be in ascii address book format.'
 Call LineOut filespec
 Call Beep 450, 250
 Exit 1
/*---------------------------------------------------------------------------*/
ERR3:
 Say 'Err: Error writing to file' AdrFile
 Call LineOut filespec
 Call CharOut AdrFile
 Call Beep 450, 250
 Exit 1
/*---------------------------------------------------------------------------*/
ERR4:
 Say;Say 'Err:' inName 'is not an inbasket name.'
 Say '     Please review your PostRoad Mailer title bar for the Inbasket name.'
 Call Beep 450, 250
 Exit 1
