/* UML2POST.CMD -- Converts UltiMail folders and address books to
                   the Post Road Mailer */
/* Parameters: UltiMail subdirectory.  If no parameter is used, utility 
               prompts user to enter UltiMail subdirectory.*/
/* (c) Copyright, 1996, InnoVal System Solutions, Inc., Luis Reyes     */

 /* Possible code values: */
 X.SAVE_FILECARDS        = X2C('0700'); X.SAVE_GROUPS           = X2C('0800')
 X.SAVE_GNAME            = X2C('2000'); X.SAVE_ADDRESSES        = X2C('2200')
 X.SAVE_GADDRESS         = X2C('2400'); X.SAVE_BOOK_NAME        = X2C('3000')
 X.SAVE_FIRST            = X2C('3500'); X.SAVE_CNAME            = X2C('4000')
 X.SAVE_COMPANY          = X2C('4500'); X.SAVE_EMAIL1           = X2C('5000')
 X.SAVE_PHONE1           = X2C('8000'); X.SAVE_PHONE2           = X2C('8500')
 X.SAVE_FAX              = X2C('9000'); X.SAVE_ADDRESS          = X2C('9500')
 X.SAVE_NICKNAME1        = X2C('0001'); X.SAVE_NICKNAME2        = X2C('0101')

 Signal on HALT 

 If LoadRexxUtil() then Do
    Say 'Err: Could not load Rexx Library...'
    Exit
  end /* If Do */
                                        
 If Arg() <> 0 then Do
     Arg subdir
     If subdir = '?' then Signal Help
 end /* If */
 Else Do
       Say "Enter UltiMail subdirectory: "
       Pull subdir
 end  /* Else */
 
 If Right( subdir, Length( subdir ) ) = '\' then
    subdir = Left( subdir, Length( subdir ) - 1 )

 Call SysCls
 Call GreetingMsg

 PostDir = Directory()
 If Stream( PostDir|| '\POSTROAD.EXE','C','QUERY EXISTS') = '' then Signal Err
 If Stream( subdir || '\UMAIL.EXE','C', 'QUERY EXISTS') = '' then Signal Err1
 If Stream( subdir || '\UMAILSRV.PRO','C','QUERY EXISTS') = '' then Signal Err1
 
 inBas = '\' || GetInbasketName( PostDir ) || '\'
 Book. = ''
 
 Call SetUpall

Exit
/*------------------------------------------------------------------------*/
SETUPALL: Procedure Expose subdir X. Book. inBas PostDir
 /* Set up several variables, Do menu */

  UmIniFile = subdir || '\UMAILSRV.PRO'
  i = 1
  BkCount = 0
  fldCount = 0

  Do While lines( UmIniFile )
     lin = Translate( LineIn( UmIniFile ) )
     If Left( lin, 7 ) = ':ACCESS' then Do
        Parse Var lin . lin
        Do While lin <> '.'
           Parse Var lin valu . lin
           valu = Translate( valu )
           Select
              When valu = 'NAME' then
                 Book.Name.i = SubStr( lin, 2, Length( lin ) - 2 )
              When valu = 'USER' then
                 Book.User.i = SubStr( lin, 2, Length( lin ) - 2 )
              When valu = 'PASSWORD' then
                 Book.PassWord.i = SubStr( lin, 2, Length( lin ) - 2 )
              When valu = 'ACCESS' then
                 Book.AcRights.i = SubStr( lin, 2, Length( lin ) - 2 )
              When valu = 'ROOT' then
                 Book.AdrBook.i = SubStr( lin, 2, Length( lin ) - 2 )
              Otherwise Nop
           end  /* Select */
           lin = LineIn( UmIniFile )
        end /* Do While */
        Book.Count = i
        i = i + 1
     end /* If Do */
  end /* Do While */

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

  Call SysCls
  Call GreetingMsg

  Call SysCurState 'OFF'
  Call CharOut 'CON:', colorNormal
  Do r = 1 to menu.0
     Call SysCurPos menu.r.row, menu.r.col
     Call CharOut 'CON:', menu.r.txt
  end
  r = 1

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
/*------------------------------------------------------------------------*/
/*            Address Book Conversion Procedures and Functions            */
/*------------------------------------------------------------------------*/

BOOKSTART: Procedure Expose X. Book. i BkCount menu. colorNormal r
  /* Start Address Book Conversion.  */

  Call SysCurPos 13,0
  Call SysCurState( 'ON' )

  Do i = 1 to Book.count
    Say 'Do you wish to convert the' Strip( Book.user.i ) 'address book? (Y,n)'
    Pull Ans
      If Left( Ans,1 ) = 'Y' then
         Call ConvertBook
    Say;
  end /* Do i... */
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
/*-------------------------------------------------------------------------*/
CONVERTBOOK: Procedure Expose X. Book. i BkCount
  /* Read Address book and write to an ascii format */
  /* Remark out the "@ERASE outfile" commands in order to save the ascii format */
  /* of the address books */

  outfile = Book.AdrBook.i || '.ASC'

  PostDir = Directory()
  FileName = Right( Book.AdrBook.i, Length(Book.AdrBook.i)-LastPos( '\',Book.AdrBook.i))
  FileName = PostDir || '\' || FileName || '.ADR'
  NewBkName = Book.User.i

  If Stream(FileName,'C','QUERY EXISTS') <> '' then Do
    Say Strip( newBkName ) 'already exists. Do you want to replace it?(Y/n)'
    Pull ans
    If Left( ans,1) = 'Y' then
       '@ERASE' FileName
    Else Do
       Say 'Do you wish to rename destination file? (Y/n)'
       Pull ans
         If Left( ans, 1 ) = 'Y' then
            outfile = CheckFileName( outfile )
         Else Return
    end /* Else Do */
  end /* Main If Do */
 
  /* Write address book name and write to output file */
  If Book.Name.i <> '' then
     Call LineOut outfile, '<BOOK_NAME>' || Book.Name.i
  Else
     Call LineOut outfile, '<BOOK_NAME>' || Book.User.i

  Call LineOut outfile, '*Created from UltiMail' Book.User.i 'addressbook'
  Call LineOut outfile, ''

  infile = Book.AdrBook.i || '\ADDRESS.HNM'
  Entry. = ''
  Entry.Count = 0
  j = 0

  /* Read in entire input file to memory. */
  Do While Lines(infile) > 0
    lin = LineIn( infile )
    Parse Var lin valu '.' lin
    valu = Translate( valu )
    If valu = ':NICK' then
       newSeries = 1
    Else newSeries = 0
    If newSeries = 1 then Do
      Entry.Count = j
      j = j + 1
    end /* If Do */
    Select
       When valu = ':NAME'then
         Entry.j.Name = lin
       When valu = ':NICK' then
         Entry.j.Nick = lin
       When valu = ':PHONE' then
         Entry.j.Phone = lin
       When valu = ':USERID' then
         Entry.j.UserId = lin
       When valu = ':NODE' then
         Entry.j.Node = lin
       When valu = ':LIST' then
         Entry.j.List = lin
       Otherwise Nop
    end /* Select */
  end /* Do while */

  Entry.Count = Entry.Count + 1

  Call LineOut infile  /* Close infile file */

  Do j = 1 To Entry.Count
     If Translate( Entry.j.UserId ) <> 'ULTIMAIL_DISTRIBUTION_LIST' then Do
       Entry.j.Email = Entry.j.UserId || '@' || Entry.j.Node
       Call NameSave
       Call LineOut outfile, '<LAST_NAME>' || Entry.j.Last
       Call LineOut outfile, '<FIRST_NAME>' || Entry.j.First
       Call LineOut outfile, '<EMAIL1>' || Entry.j.Email
       Call LineOut outfile, '<PHONE1>' || Entry.j.Phone
       Call LineOut outfile, '<NICKNAME1>' || Entry.j.Nick
       Call LineOut outfile, '<COMMENTS>'
       Call LineOut outfile, ''
     end /* If Do */
     Else Do
       Call LineOut outfile, '<GROUP_NAME>' || Entry.j.Nick
       k = j

       Do While Words( Entry.k.List ) > 0
          j = 1
          found = 0
          Parse Var Entry.k.List nickName Entry.k.List
          Do while found <> 1 & j < Entry.Count
             If Translate( Entry.j.Nick ) = nickName then Do
                found = 1
                Call NameSave
                Email = Entry.j.UserId || '@' || Entry.j.Node
                Gaddr = Entry.j.Last || ',' Entry.j.First '<' || Email || '>'
                Call LineOut outfile, '<GADDRESS>' || Gaddr
             end  /* Do */
             Else found = 0
             j = j + 1
          end /* Do while */
       end /* Do While */
       j = k
       Call LineOut outfile, ''
     end  /* Else Do */
  end /* Do */

  Call CharOut outfile /* Close output file */
  Call Asc2Adr
  BkCount = BkCount + 1

  If Stream( outfile, 'C', 'QUERY EXISTS') <> '' then
    '@ERASE' outfile 

  Return
/*--------------------------------------------------------------------------*/

ASC2ADR: Procedure Expose X. outfile Book. i
  /* Writing to output file. */
  /* Based on Code Written by Tom Springall, Innoval Systems Solutions, Inc */

  CRLF = X2C('0D0A')
  filespec = outfile
  AdrFile = Right( outfile, Length( outfile ) - LastPos( '\',outfile ) + 1)
  AdrFile = Directory() || Left( AdrFile, LastPos( '.',AdrFile ) ) || 'ADR'
  Lin = LineIn(filespec)

 /* Must be in the first row */
  If Left(lin,11) <> '<BOOK_NAME>' then Signal Err2
  Call SaveIt X.SAVE_BOOK_NAME, Substr(lin,12)

  y = 1 ; activity = 0 ; cards = 0 ; groups = 0 ; data. = ''
                                                                             
 /* Read in entire input file to memory. */                                  
  Do While Lines(filespec) > 0
                                                                             
    lin = LineIn(filespec)
    first = Left(lin,1)
    Select
      /* blank line means new address or group */
      When first = ' ' & activity > 0 then do
        /* check values since last blank, if any */
        Call CheckI
        activity = 0
        end /* of When */
      When first = '<' then do                /* it's a tag */
        Parse var lin '<' tag '>' valu
        Select
          When tag = 'COMMENTS' then do       /* gotta append these */
            If data.y.COMMENTS <> '' then
               data.y.COMMENTS = data.y.COMMENTS || CRLF
            data.y.COMMENTS = data.y.COMMENTS || valu
            end
          When tag = 'GADDRESS' then do       /* gotta count these */
            z = data.y.addresses
            If z = '' then z = 1
            Else z = z + 1
            data.y.GADDRESS.z = valu
            data.y.addresses = z
            end
          Otherwise                           /* otherwise, just save value */
            /* assign valu to data.y.field */
            V = Value('data.y.' || tag, valu)
          end /* of Select */
        activity = 1    /* indicate that something has been saved at level i */
        end
      Otherwise Nop                          /* skip comments, etc. */
      end /* of Select */
    end /* of Do While */
  Call LineOut filespec                      /* close input file */
                                                                             
 /* entire file read in. check if last y has anything in it */
  If y <> 0 & activity > 0 then Call CheckI
                                                                             
 /* save card and group counts */                                            
  Call SaveIt X.SAVE_FILECARDS, MakeNum(cards)
  Call SaveIt X.SAVE_GROUPS, MakeNum(groups)
 
 /* write out each level (each level contains an address page or group) */   
  Do z = 1 to y - 1
    Select
      When typ.z = 'CARD' then Do
       /* address page must start with last name field */                    
        Call SaveIt X.SAVE_CNAME, data.z.LAST_NAME  /* must be 1st */
        Call SaveIt X.SAVE_FIRST, data.z.FIRST_NAME
        Call SaveIt X.SAVE_EMAIL1, data.z.EMAIL1
        Call SaveIt X.SAVE_PHONE1, data.z.PHONE1
        Call SaveIt X.SAVE_ADDRESS, data.z.COMMENTS
        Call SaveIt X.SAVE_NICKNAME1, data.z.NICKNAME1
      end /* of When */
                                                                             
      When typ.z = 'GROUP' then do         /* it's a group */
       /* group must begin with name of group */                             
        Call SaveIt X.SAVE_GNAME, data.z.GROUP_NAME
       /* number of addresses in group */                                    
        Call SaveIt X.SAVE_ADDRESSES, MakeNum(data.z.addresses)
       /* then, each address */                                              
        Do k = 1 to data.z.addresses
          Call SaveIt X.SAVE_GADDRESS, data.z.GADDRESS.k
        end                                                                 
      end /* of When */                                                     
      Otherwise Nop
    end /* of Select */                                                     
  end /* of Do j... */                                                      
                                                                             
  Call CharOut AdrFile                /* close output files */

  Return
/*--------------------------------------------------------------------------*/

NAMESAVE:
  /* Extract name */
 
  lin = Entry.j.Name
  NameNum = words( lin )
  Select
     When NameNum >= 4 then Do
        first = word( lin, 1 ) || ' ' || word( lin, 2 )
        last = word( lin, NameNum - 1) || ' ' || word( lin, NameNum )
     end  /* Do */
     When NameNum = 3 then Do
        first = word( lin, 1 ) || ' ' || word( lin, 2 )
        last = word( lin, NameNum )
     end  /* Do */
     When NameNum = 0 then Do
        first = 'Name'
        last = 'Needed'
     end  /* Do */
     Otherwise Do
       first = word(lin,1)
       last = word( lin, NameNum )
     end /* Do */
  end  /* select */

  Entry.j.First = first
  Entry.j.Last = last

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

CHECKI: Procedure Expose y data. cards groups typ.
                                                                       
  /* Check to see if any real stuff collected at the current level (y) */
  /* is it a card? */           
  If data.y.LAST_NAME <> '' | data.y.ORGANIZATION <> '' then do
    typ.y = 'CARD'
    cards = cards + 1
    y = y + 1
    end
  Else
    If data.y.GROUP_NAME <> '' then Do /* is it a group? */
      typ.y = 'GROUP'
      groups = groups + 1
      y = y + 1
    end
    Else
      data.y. = ''               /* false alarm. reset */

  Return
/*--------------------------------------------------------------------------*/

CHECKFILENAME: Procedure

  Arg outfile
  nfn = ''
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
 
  Return( nfn || '.ASC' )
/*-------------------------------------------------------------------------*/
/*                      Folder Conversion                                  */
/*-------------------------------------------------------------------------*/

CONVERTFOLDERS: Procedure Expose subdir inBas Book. fldcount menu. colorNormal r

  curdir = Directory()

  Call SysCurPos 13,0
  Call SysCurState( 'ON' )

  Say; Say 'Converting folders from UltiMail to PostRoad Mailer...'

  Do z = 1 to Book.Count
    Call SysFileTree Book.AdrBook.z || '\*.', folder, 'DO'

    Do y = 1 to folder.0
      Msgs = folder.y || '\*.'
      folder.y = Right( folder.y, Length( folder.y ) - LastPos( '\', folder.y ) )
      outfile = curdir || inBas || folder.y || '.NLG'

      If Stream( Msgs || 'ENV', 'C', 'QUERY EXISTS' ) <> '' then Do
         /* Get the names of the UltiMail msgs */
         Call SysFileTree Msgs, infile, 'DO' 
 
        outfile = CheckFoldName( outfile Book.User.z )
        Call LineOut outfile, D2C(4) || folder || ' UltiMail Folder'
        Call LineOut outfile, ''
                                                                              
        Do w = 1 to infile.0
           Note. = ''
           To_Flag = 0
           infsav = infile.w
           infile.w = infile.w || '.ENV'
           Do While Lines( infile.w ) > 0
              Lin = LineIn( infile.w )
              If To_Flag = 1 & LastPos( ':', Word( Lin, 1 ) ) > 0 then
                 To_Flag = 0
              If To_Flag = 1 then Lin = 'To: ' || Lin
              Select
                 When Word( Lin,1 ) = 'To:' then Do
                      To_Flag = 1
                      Num = Length( lin ) - Pos( '<', lin ) + 1
                      If Num >= Length( lin ) then
                         Note.UserTo = Note.UserTo || SubWord(lin, 2, Words(lin) )
                      Else
                         Note.UserTo = Note.UserTo || Right( lin, Num )
                 end /* When Do */
                 When Word( Lin,1 ) = 'From:' then
                    Note.From = Word( Lin, 2 )
                 When Word( Lin,1 ) = 'Subject:' then
                    Note.SubjLine = Right( lin, Length( lin ) - 9 )
                 When Word( Lin,1 ) = 'Date:' then
                    Note.DateLin = Right( lin, Length( lin ) - 6 )
                 When Word( Lin,1 ) = 'Reply-To:' then
                    Note.ReplyLine = Word( Lin, 2 )
                 When Word( Lin,1 ) = 'Sender:' then
                    Note.Nick = SubWord( lin, 2, Words( lin ) - 1 )
                 Otherwise Nop
              end  /* select */
           end /* Do While */

           num = WordLength( Note.DateLin, Words( Note.DateLin ) )
           Note.DateLin = Left( Note.DateLin, Length( Note.DateLin ) - num )
           Note.RUser = Right(Note.UserTo,Length(Note.UserTo)-LastPos(',',Note.UserTo ) )

           Call WriteNote

           Call LineOut outfile, ''
           Call LineOut infile.w
        end /* Do While */
 
        Call Charout outfile
        fldcount = fldcount + 1
      end /* If Stream */
    end /* Do while */
  end /*Do z.. */

  '@PAUSE'

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
/*----------------------------------------------------------------------*/
WRITENOTE: Procedure Expose Note. outfile infsav
/* Writes Letter to Folder in PRM Format */

  num = 49 - Length( Note.RUser )

  Call CharOut outfile, '<<NEW NOTE>> ' || D2C(1) || Strip( Note.RUser )
  Call CharOut outfile, Copies(' ', num )
  Call CharOut outfile, ConvertDate( Note.DateLin ) || 'STZ            '
  Call CharOut outfile, '0   ' || Note.From || D2C(1) || Note.SubjLine
  Call CharOut outfile, D2C(1) || D2C(1) || Note.From||D2C(2)||Note.UserTo
  Call LineOut outfile, D2C(3) || Note.ReplyLine
  Call LineOut outfile, 'To:' Note.UserTo
  Call LineOut outfile, 'Date:' Note.DateLin || 'STZ'
  Call LineOut outfile, 'From:' Note.From
  Call LineOut outfile, 'Reply-To: <' || Note.ReplyLine || '>'
  Call LineOut outfile, ''
  Call LineOut outfile, 'Subject:' Note.SubjLine
  Call LineOut outfile, ''

  Call SysFileTree infsav || '\*.TXT', TxtFile, 'FO' 

  Do i = 1 to TxtFile.0
    Do While Lines( TxtFile.i ) > 0
      Lin = LineIn( TxtFile.i )
      Call LineOut outfile, Lin
    end /* Do While */
    Call LineOut TxtFile.i
  end /*Do While */

  Call LineOut outfile, D2C( 254 ) || D2C( 4 ) || Note.SubjLine

  Return
/*-------------------------------------------------------------------------*/

CHECKFOLDNAME: Procedure
 /* Check to see if folder file exists. If so, rename it */

  Arg outfile user

  fn = Right( outfile, Length(outfile) - LastPos( '\',outfile ) )
  FoldName = Left( fn, LastPos( '.', fn ) - 1 )
  folddir = Left( outfile, LastPos( '\', outfile ) )
  i = 0

  If Stream( outfile, 'C', 'QUERY EXISTS') <> '' then Do
    If Length( fn ) >= 12 then
      outfile = Left( outfile, LastPos( '.', outfile ) - 2 )
    Else
      outfile = Left( outfile, LastPos( '.', outfile ) - 1 )

    Do until Stream( outfile || i || '.NLG', 'C', 'QUERY EXISTS') = ''
       i = i + 1
    end /* Do Until */

    outfile = outfile || i || '.NLG'

    Say 'A' Strip( FoldName ) 'folder already exists.'
    Say 'Creating another' Strip(FoldName) 'folder for Ultimail user' Strip(User);Say;

  end /* If Stream Do */
  Else Do
     If fn > 8 then
        fn = Left( fn, 8 )
     If LastPos( '.', fn ) <> 0 then
        Num = LastPos( '.', fn ) - 1
     Else Num = Length( fn )
     outfile = folddir || Strip( Left( fn, Num )) || '.NLG'
     If Stream( outfile, 'C', 'QUERY EXISTS') <> '' then
        outfile = checkFoldName( outfile user )
  end  /* Do */

  Return( outfile )
/*----------------------------------------------------------------------*/

CONVERTDATE: Procedure
/* Function returns a numeric equivalent from the abbreviated month */               
                                                                                     
  Arg Date
                                                                                     
  Dummy = Word( Date, 1 )
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

  DateString = '0'|| Year || '/' || Month || '/' || Day || Time

  Return( DateString )
/*----------------------------------------------------------------------*/
/*                      Other Functions and Procedures                  */
/*----------------------------------------------------------------------*/

GETINBASKETNAME: Procedure
/* Matches inbasket Name and extracts directory */

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
/*--------------------------------------------------------------------------*/

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

EXITING:
 
 Say;Say;
 Say '      ' BkCount 'Address books converted.'
 Say '      ' fldcount 'Folders converted.'
 EXIT
/*----------------------------------------------------------------------*/

HPFS: Procedure
/* This function puts quotes around a directory name to enable the HPFS to read the directory*/

  Arg DirName

  Do While Pos( '"', DirName ) <> 0
    If Pos( '"', DirName ) = 1 then
      DirName = Right( DirName, Length( DirName ) - 1 )
    Else
      DirName = Left( DirName, Pos( '"', DirName ) - 1 )
  end /* Do While */

  DirName = '"' || DirName || '"'

  Return DirName
/*----------------------------------------------------------------------*/

HALT:
  Call SysCls
  Say;Say 'Program Interupted..'
  Say 'Ending UML2POST.CMD run...'
 
  Exit
/*----------------------------------------------------------------------*/

HELP:

 Say ''
 Say 'UML2POST.CMD converts UltiMail folders and address books for use with'
 Say 'the Post Road Mailer.'
 Say ''
 Say 'Syntax is:  UML2POST <path>'
 Say ''
 Say 'All UltiMail folders and address books will be visible in PostRoad'
 Say 'Mailer after execution of this utiltity.'
 Say ''
 Say 'UML2POST will prompt for the UltiMail subdirectory if a path is not'
 Say '         specified.'
 Say ''

 Exit
/*--------------------------------------------------------------------------*/

GREETINGMSG:
  Say ''
  Say Center('UML2POST.CMD Converting Utility               (c)Innoval Systems Solutions,Inc',79)
  Say ''
  Say Center( '*--Converts UltiMail folders and address books for use with the--*',79)
  Say Center( 'Post Road Mailer',79)
  Say ''

  Return
/*---------------------------------------------------------------------------*/

ERR:
 Say 'Err: This Utility must be run from within PostRoad Mailer root directory.'
 Call Beep 450, 250
 Exit 1
/*--------------------------------------------------------------------------*/

ERR1:
 Say 'Err: UltiMail is not installed in this directory or is missing files.'
 Call Beep 450, 250
 Exit 1
/*--------------------------------------------------------------------------*/

ERR2:
 Say 'Err: File' Strip(filespec) 'does not appear to be in ascii address book format.'
 Call LineOut filespec
 Call Beep 450, 250
 Exit 1
/*---------------------------------------------------------------------------*/

ERR3:
 Say 'Err: Error writing to file' Strip( AdrFile )
 Call LineOut filespec
 Call CharOut AdrFile
 Call Beep 450, 250
 Exit 1
/*---------------------------------------------------------------------------*/

ERR4:
 Say;Say 'Err:' Strip( inName ) 'is not an inbasket name.'
 Say '     Please review your PostRoad Mailer title bar for the Inbasket name.'
 Call Beep 450, 250
 Exit 1    
