/*
Convert PMMail address book entries
to Polarbar Mailer address books
Chuck McKinnis - mckinnis@attglobal.net
*/

Call Initialize                                      /* get arguments */
Call Readbooks                       /* read the PMMail address books */
Call Readaddrs                        /* read the PMMail address data */
Call Buildbooks                   /* build the Polarbar address books */
Exit:
Exit

/* layout of PMMail address data
test@email - test.alias - test name - 1 - company - title -
home street - home building - home city - home state - home zip -
home phone - home ext - home fax -
business street - business building - business city -
business state - business zipcode -
business phone - business ext - business fax -
notes - book number - home country - business country -
*/
fill = 'E1'x                                                   /* "á" */
sep = 'DE'x                                                    /* "Þ" */

Initialize:
Call Rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs
If Stream('books.db', 'C', 'QUERY EXISTS') = '' Then
   Do
      Say 'You must execute this routine in the PM Mail'
      Say 'sub-directory containing books.db, normally'
      Say 'x:\southsft\tools'
      Signal Exit
   End
Call Getpolarbar
If Stream('*.html', 'C', 'QUERY EXISTS') <> '' Then
   Address cmd '@ERASE *.html'
If Stream('*.ABH', 'C', 'QUERY EXISTS') <> '' Then
   Address cmd '@ERASE *.ABH'
Return

Readbooks:
books. = ''
books.0 = 0
books = 'books.db'
booktest = ''
Do While Lines(books) > 0
   bookline = Linein(books)
   Parse Value bookline With book 'DE'x parm1 'DE'x parm2 'DE'x bookno 'DE'x .
   i = bookno
   If i > books.0 Then
      books.0 = i
   books.i = Bookname(book)
   books.i.0 = 0
End
booktest = ''
Return 0

Bookname: Procedure Expose do83 booktest
Parse Arg book, .
book = Translate(Space(book), '_____', ' ./\?')
If do83 & Length(book) > 8 Then              /* need to reduce length */
   book = Left(book, 8)
Do While Wordpos(book, booktest) <> 0                  /* make unique */
   book = SysTempFileName(Left(book, Length(book) - 1) || '?')
End
booktest = booktest book
If do83 Then
   book = book || '.ABH'
Else
   book = book || '.AddressBook.html'
Return book

Readaddrs:
addr = 'addr.db'
Do While Lines(addr) > 0
   addrline = Linein(addr)
   addrline = Translate(addrline, ' ', 'E1'x)
   Parse Value addrline With email 'DE'x nickname 'DE'x realname 'DE'x ,
      popup 'DE'x company 'DE'x title 'DE'x home_street 'DE'x ,
      home_bldg 'DE'x home_city 'DE'x home_state 'DE'x home_zip 'DE'x ,
      home_phone 'DE'x home_ext 'DE'x home_fax 'DE'x bus_street 'DE'x ,
      bus_bldg 'DE'x bus_city 'DE'x bus_state 'DE'x bus_zip 'DE'x ,
      bus_phone 'DE'x bus_ext 'DE'x bus_fax 'DE'x notes 'DE'x ,
      addr_books 'DE'x home_country 'DE'x bus_country 'DE'x .
   Do Until addr_books = ''
      Parse Var addr_books addr_book ';' rest
      i = addr_book
      j = books.i.0
      j = j + 1
      books.i.0 = j
      books.i.j = addrline
      addr_books = rest
   End
End
Return

Buildbooks:
pbmhdr. = ''
pbmhdr.1 = '<HTML><!-- ADDRESS BOOK -->'
pbmhdr.2 = '<HEAD><TITLE>Polarbar Address Book</TITLE></HEAD><BODY>'
pbmhdr.3 = '<P><B>NICKNAME:</B>'
pbmhdr.4 = '<P><B>DOMAIN:</B>'
pbmhdr.5 = '<P><B>SORTSTYLE:</B> 0'
pbmhdr.6 = '<P><B>SORTTYPE:</B> 0'
pbmhdr.7 = '<TABLE BORDER=1 CELLPADDING=4>'
pbmhdr.8 = '<TH>Nickname</TH>'
pbmhdr.9 = '<TH>Email Address</TH>'
pbmhdr.10 = '<TH>Full Name</TH>'
pbmhdr.11 = '<TH>Groups</TH>'
pbmhdr.12 = '<TH>Alert</TH>'
pbmhdr.13 = '<TH>Folder</TH>'
pbmhdr.14 = '<TH>Notes</TH>'
pbmhdr.15 = '<TH>Title</TH>'
pbmhdr.16 = '<TH>Organization</TH>'
pbmhdr.17 = '<TH>Postal Address</TH>'
pbmhdr.18 = '<TH>Phone Number</TH>'
pbmhdr.19 = '<TH>Fax Number</TH>'
pbmhdr.20 = '<TH>Short List</TH>'
pbmhdr.21 = '<TH>Persona</TH>'
pbmhdr.0 = 21

Do i = 1 To books.0
   If books.i = '' Then
      Iterate i
   pbmfile = books.i
   Do k = 1 To pbmhdr.0
      lrc = Lineout(pbmfile, pbmhdr.k)
   End
   nicktest = ''
   Do j = 1 To books.i.0
      addrline = books.i.j
      Parse Value addrline With email 'DE'x nickname 'DE'x realname 'DE'x ,
         popup 'DE'x company 'DE'x title 'DE'x home_street 'DE'x ,
         home_bldg 'DE'x home_city 'DE'x home_state 'DE'x home_zip 'DE'x ,
         home_phone 'DE'x home_ext 'DE'x home_fax 'DE'x bus_street 'DE'x ,
         bus_bldg 'DE'x bus_city 'DE'x bus_state 'DE'x bus_zip 'DE'x ,
         bus_phone 'DE'x bus_ext 'DE'x bus_fax 'DE'x notes 'DE'x ,
         addr_books 'DE'x home_country 'DE'x bus_country 'DE'x .
      lrc = Lineout(pbmfile, '<TR VALIGN=TOP>')
      nickname = Newnick(nickname)
      lrc = Lineout(pbmfile, '<TD><B>' || nickname || '</B></TD>')
      lrc = Lineout(pbmfile, '<TD>' || email || '</TD>')
      lrc = Lineout(pbmfile, '<TD>' || realname || '</TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD>' || notes || '</TD>')
      lrc = Lineout(pbmfile, '<TD>' || title || '</TD>')
      lrc = Lineout(pbmfile, '<TD>' || company || '</TD>')
      pbmaddr = ''
      /* check the home address */
      street = home_street
      bldg = home_bldg
      city = home_city
      state = home_state
      zip = home_zip
      country = home_country
      pbmaddr = Addrbuild('Home -', Space(street), '<BR>')
      pbmaddr = Addrbuild(pbmaddr, Space(bldg), '<BR>')
      pbmaddr = Addrbuild(pbmaddr, Space(city), '<BR>')
      pbmaddr = Addrbuild(pbmaddr, Space(state), ', ')
      pbmaddr = Addrbuild(pbmaddr, Space(zip), '  ')
      pbmaddr = Addrbuild(pbmaddr, Space(country), '<BR>')
      If pbmaddr = 'Home -' Then
         pbmaddr = ''
      /* check the business address */
      street = bus_street
      bldg = bus_bldg
      city = bus_city
      state = bus_state
      zip = bus_zip
      country = bus_country
      If pbmaddr <> '' Then
         Do
            pbmaddr = Addrbuild(pbmaddr, 'Business -', '<BR>')
            pbmaddr = Addrbuild(pbmaddr, Space(street), '<BR>')
         End
      Else
         pbmaddr = Addrbuild('Business -', Space(street), '<BR>')
      pbmaddr = Addrbuild(pbmaddr, Space(bldg), '<BR>')
      pbmaddr = Addrbuild(pbmaddr, Space(city), '<BR>')
      pbmaddr = Addrbuild(pbmaddr, Space(state), ', ')
      pbmaddr = Addrbuild(pbmaddr, Space(zip), '  ')
      pbmaddr = Addrbuild(pbmaddr, Space(country), '<BR>')
      If pbmaddr = 'Business -' Then
         pbmaddr = ''
      lrc = Lineout(pbmfile, '<TD>' || pbmaddr || '</TD>')
      phone = Space(home_phone home_ext)
      If phone = '' Then
         phone = Space(bus_phone bus_ext)
      lrc = Lineout(pbmfile, '<TD>' || phone || '</TD>')
      fax = home_fax
      If fax = '' Then
         fax = bus_fax
      lrc = Lineout(pbmfile, '<TD>' || fax || '</TD>')
      lrc = Lineout(pbmfile, '<TD>false</TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '</TR>')
   End
   lrc = Lineout(pbmfile, '</TABLE>')      /* mark end of individuals */
   lrv = Lineout(pbmfile, '</BODY></HTML>')       /* mark end of book */
   Call Stream pbmfile, 'C', 'CLOSE'
   Say 'Converted' books.i.0 'addresses to' pbmfile
   nicktest = ''
End
Return

Newnick: Procedure Expose nicktest
Parse Arg nick
nick = Translate(Space(nick), '___', ' .?')
Do While Wordpos(nick, nicktest) <> 0                  /* make unique */
   nicktest = SysTempFileName(Left(nick, Length(nick) - 1) || '?')
End
nicktest = nicktest nick
Return nick

Addrbuild: Procedure
Parse Arg addr, next, break
If next <> '' Then
   Do
      If addr <> '' Then
         addr = addr || break || next
      Else
         addr = next
   End
Return addr

Getpolarbar:
/* locate polarbar base */
Say 'Enter the path to Polarbar Mailer'
Parse Pull pbmbase
pbmbase = pbmbase || '\mailer\maildata'
xrc = SysFileTree(pbmbase || '\*', 'pbmaccts.', 'DO')
If xrc <> 0 | pbmaccts.0 = 0 Then
   Do
      Say pbmbase 'not found'
      Signal Exit
   End
/* check for 8.3 naming */
file_system = GetFileSystemType(pbmbase)
If file_system <> '' Then
   Do
      If file_system = 'FAT' Then
         Do
            do83 = 1
            Say 'Using 8.3 naming conventions'
         End
      Else
         do83 = 0
   End
Else
   Do
      Say 'Use 8.3 naming conventions? (Yes or No, default No)'
      Parse Upper Pull do83 .
      If Abbrev(do83, 'Y') Then
         do83 = 1
      Else
         do83 = 0
   End
Return

/*
 GetFileSystemType - return file system of drive to caller

 Object Rexx and higher levels of Classic Rexx support the RexxUtil
 function SysFileSystemType(drive) that returns the file system type on
 a drive to the caller.  This routine will use the function if
 available or check for an eadata file on the drive (only found on FAT
 drives) and return the file system type (HPFS, FAT, JFS) to the caller.
 To use as a called procedure, uncomment the Procedure statement.
*/
Getfilesystemtype: Procedure

If Rxfuncquery('SysDropFuncs') Then
   Do
      Call Rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
      Call SysLoadFuncs
   End

Parse Upper Arg drive .
drive = Left(drive, 1) || ':'

If \Rxfuncquery('SysFileSystemType') Then
   Do
      file_system = SysFileSystemType(drive)
   End
Else
   Do
      file_system = 'HPFS'                             /* assume HPFS */
      ea_data = drive || '\eadata*'
      xrc = SysFileTree(ea_data, 'ea_data.', 'FO')
      If xrc = 0 & ea_data.0 > 0 Then
         file_system = 'FAT'
   End
Return file_system
