/*
Convert Post Road Mailer address book
to Polarbar Mailer address book
*/

Call Initialize                                      /* get arguments */
Call Readbooks                    /* read the Post Road address books */
Call Readaddrs                     /* read the Post Road address data */
Call Buildbooks                   /* build the Polarbar address books */
Exit:
Exit

Initialize:
Call Rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs
cur_dir = Directory()
If Stream(cur_dir || '\*.adr', 'C', 'QUERY EXISTS') = '' Then
   Do
      Say 'This routine must run in your Post Road'
      Say 'directory, normally x:\postroad'
      Signal Exit
   End
Call Getpolarbar
If Stream('*.html', 'C', 'QUERY EXISTS') <> '' Then
   Address cmd '@ERASE *.html'
If Stream('*.ABH', 'C', 'QUERY EXISTS') <> '' Then
   Address cmd '@ERASE *.ABH'
Return

Readbooks:                 /* find all of the Post Road address books */
frc = SysFileTree(cur_dir || '\*.adr', 'books.', 'FO')

/* convert Post Road address books to tab separated data */
'@ERASE' cur_dir || '\*.asc'
'@ERASE' cur_dir || '\*.grp'
Do i = 1 To books.0
   Call Adr2Asc books.i
End

/* develop Polarbar Mailer address book names */
addrs. = ''
addrs.0 = books.0
groups. = ''
groups.0 = books.0
Do i = 1 To books.0       /* build a list of address books and groups */
   addrs.i = Substr(books.i, 1, Lastpos('.', books.i)) || 'asc'
   groups.i = Substr(books.i, 1, Lastpos('.', books.i)) || 'grp'
End
/* get the real address book names and make unique */
booktest = ''
Do i = 1 To addrs.0
   realname = Linein(addrs.i)
   Parse Var realname realname '(' .
   realname = Bookname(Space(realname))
   addrs.i = addrs.i realname
   addrs.i.0 = 0
   Call Stream Word(addrs.i, 1), 'C', 'CLOSE'
End
booktest = ''
Return

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

Readaddrs:         /* process converted Post Road Mailer address book */
Do i = 1 To addrs.0
   addrbook = addrs.i
   Parse Var addrbook addrbook realname
   Do j = 1 To 4                             /* skip the header lines */
      addr = Linein(addrbook)
   End
   addrs.i. = ''
   j = 0
   addrs.i.0 = j
   nicktest = ''
   Do While Lines(addrbook) > 0   /* process the address book entries */
      addr = Linein(addrbook)
      If addr <> '' Then
         Do
            Parse Var addr lname '09'x fname '09'x company '09'x ,
               email1 '09'x nick1 '09'x email2 '09'x nick2 '09'x ,
               email3 '09'x nick3 '09'x email4 '09'x nick4 '09'x ,
               email5 '09'x nick5 '09'x ,
               tele1 '09'x tele2 '09'x fax '09'x notes
            name = Space(fname lname)
            If email1 <> '' Then
               Do
                  nick1 = Newnick(nick1, name, company)
                  addr1 = nick1 || '09'x || name || '09'x || company '09'x || ,
                     email1 || '09'x || tele1 || '09'x || tele2 || '09'x || ,
                     fax || '09'x || notes
                  j = j + 1
                  addrs.i.0 = j
                  addrs.i.j = addr1
               End
            If email2 <> '' Then
               Do
                  nick2 = Newnick(nick2, name, company)
                  addr2 = nick2 || '09'x || name || '09'x || company '09'x || ,
                     email2 || '09'x || tele1 || '09'x || tele2 || '09'x || ,
                     fax || '09'x || notes
                  j = j + 1
                  addrs.i.0 = j
                  addrs.i.j = addr2
               End
            If email3 <> '' Then
               Do
                  nick3 = Newnick(nick3, name, company)
                  addr3 = nick3 || '09'x || name || '09'x || company '09'x || ,
                     email3 || '09'x || tele1 || '09'x || tele2 || '09'x || ,
                     fax || '09'x || notes
                  j = j + 1
                  addrs.i.0 = j
                  addrs.i.j = addr3
               End
            If email4 <> '' Then
               Do
                  nick4 = Newnick(nick4, name, company)
                  addr4 = nick4 || '09'x || name || '09'x || company '09'x || ,
                     email4 || '09'x || tele1 || '09'x || tele2 || '09'x || ,
                     fax || '09'x || notes
                  j = j + 1
                  addrs.i.0 = j
                  addrs.i.j = addr4
               End
            If email5 <> '' Then
               Do
                  nick5 = Newnick(nick5, name, company)
                  addr5 = nick5 || '09'x || name || '09'x || company '09'x || ,
                     email5 || '09'x || tele1 || '09'x || tele2 || '09'x || ,
                     fax || '09'x || notes
                  j = j + 1
                  addrs.i.0 = j
                  addrs.i.j = addr5
               End
         End
   End
   Say 'Found' j 'addresses in' realname
   Call Stream addrbook, 'C', 'CLOSE'
   /* process the group entries for addrs.i */
   groupbook = groups.i
   Do 4                                      /* skip the header lines */
      group = Linein(groupbook)
   End
   groups.i. = ''
   j = 0
   groups.i.0 = j
   nicktest = ''
   Do While Lines(groupbook) > 0    /* process the group book entries */
      group = Linein(groupbook)
      If group <> '' Then
         Do
            Parse Var group groupname '09'x rest
            groupnick = Newnick('', groupname, '')
            j = j + 1
            groups.i.0 = j
            groups.i.j = groupname || '09'x || groupnick
            k = 0
            groups.i.j.0 = k
            Do While rest <> ''
               Parse Var rest emailaddr '09'x rest
               Parse Var emailaddr . '<' email '>' .
               entrynick = Findnick(email)
               If entrynick <> '' Then
                  Do
                     k = k + 1
                     groups.i.j.0 = k
                     groups.i.j.k = entrynick
                  End
               Else
                  Say 'Unable to locate entry for' emailaddr
            End
         End
      Say 'Found' k 'addresses in' groupname 'group'
   End
   Say 'Found' j 'groups in' realname
   Call Stream groupbook, 'C', 'CLOSE'
   nicktest = ''
End
Return

Newnick: Procedure Expose nicktest
Parse Arg nick, name, company
If nick = '' Then
   Do
      nick = name
      If nick = '' Then
         nick = company
   End
nick = Translate(Space(nick), '___', ' .?')
Do While Wordpos(nick, nicktest) <> 0                  /* make unique */
   nicktest = SysTempFileName(Left(nick, Length(nick) - 1) || '?')
End
nicktest = nicktest nick
Return nick

Findnick: Procedure Expose addrs. i
Parse Arg email
Do j = 1 To addrs.i.0 Until email = aemail
   Parse Var addrs.i.j nick '09'x name '09'x company '09'x ,
      aemail '09'x tele1 '09'x tele2 '09'x ,
      fax '09'x notes
End
If email <> aemail Then
   nick = ''
Return nick

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

Do i = 1 To addrs.0
   Parse Var addrs.i . pbmfile
   Do k = 1 To pbmhdr.0
      lrc = Lineout(pbmfile, pbmhdr.k)
   End
   Say 'Adding' addrs.i.0 'addresses to' pbmfile
   Do j = 1 To addrs.i.0
      Parse Var addrs.i.j nickname '09'x realname '09'x company '09'x ,
         email '09'x phone '09'x tele2 '09'x ,
         fax '09'x notes
      lrc = Lineout(pbmfile, '<TR VALIGN=TOP>')
      lrc = Lineout(pbmfile, '<TD><B>' || nickname || '</B></TD>')
      lrc = Lineout(pbmfile, '<TD>' || email || '</TD>')
      lrc = Lineout(pbmfile, '<TD>' || realname || '</TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD>' || notes || '</TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD>' || Space(company) || '</TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '<TD>' || phone || '</TD>')
      lrc = Lineout(pbmfile, '<TD>' || fax || '</TD>')
      lrc = Lineout(pbmfile, '<TD>false</TD>')
      lrc = Lineout(pbmfile, '<TD></TD>')
      lrc = Lineout(pbmfile, '</TR>')
   End
   lrc = Lineout(pbmfile, '</TABLE>')
   Say 'Adding' groups.i.0 'groups to' pbmfile
   Do j = 1 To groups.i.0
      Parse Var groups.i.j groupname '09'x groupnick
      lrc = Lineout(pbmfile, '<P><B>' || groupname || '</B> [' || groupnick || ']')
      lrc = Lineout(pbmfile, '<UL>')
      Say 'Adding' groups.i.j.0 'addresses to group' groupname
      Do k = 1 To groups.i.j.0
         lrc = Lineout(pbmfile, '<LI>' || groups.i.j.k)
      End
      lrc = Lineout(pbmfile, '</UL>')
   End
   lrc = Lineout(pbmfile, '</BODY></HTML>')       /* mark end of book */
   Call Stream pbmfile, 'C', 'CLOSE'
End
Return

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
