/*
Convert Post Road Mailer folders
to Polarbar Mailer folders
Chuck McKinnis - mckinnis@attglobal.net
*/
pbmfolder = '\PostRoad'   /* root folder for Post Road Mailer folders */

Trace 'N'
Call Rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs
Parse Upper Arg option

Call Buildtables                          /* build translation tables */
If print Then
Exit
Call Readaccounts                                     /* get accounts */
Call Readfolders                 /* read the Post Road Mailer folders */
Call Buildfolders                       /* build the Polarbar folders */
Exit:
Exit

Readaccounts:
prmbase = Directory()
If Stream(prmbase || '\postroad.exe', 'C', 'QUERY EXISTS') = '' Then
   Do
      Say 'This routine must run in the'
      Say 'base directory of Post Road Mailer'
      Signal Exit
   End
Call Getpolarbar
/* find the accounts */
xrc = 0
prmindex = prmbase || '\inbasket.nix'
prmacct. = ''
prmacct.0 = 0
Do i =1 While Lines(prmindex) > 0
   prmacct = Linein(prmindex)
   Parse Var prmacct prmacct . '09'x prmpath
   If prmpath <> '' Then
      prmacct.i = Left(prmpath, Lastpos('\', prmpath) - 1)
   Else
      prmacct.i = prmbase || '\' || prmacct
   prmacct.0 = i
End
Call Stream prmindex, 'C', 'CLOSE'
Say ''
If xrc = 0 & prmacct.0 > 0 Then
   Do z = 1 To prmacct.0
      pbmacct.z = Getaccount(prmacct.z) || pbmfolder
      Say ''
      Say prmacct.z
      Say pbmacct.z
      Say ''
   End
Else
   Do
      Say 'No accounts found in' prmbase
      Signal Exit
   End
Return

Readfolders:
Do z = 1 To prmacct.0
   Say ''
   nametest = ''
   prmfldr.z. = ''
   prmfldr.z.0 = 0
   pbmfldr.z. = ''
   pbmfldr.z.0 = 0
   prmfldr = prmacct.z
   pbmfldr = pbmacct.z
   xrc = SysFileTree(prmfldr || '\*', 'prmtemp.', 'DSO')
   If xrc = 0 & prmtemp.0 > 0 Then
      Do i = 1 To prmtemp.0
         prmfldr.z.0 = i
         prmfldr.z.i = prmtemp.i
         pbmfldr.z.0 = i
         /* get real name of folder */
         Call SysGetEA prmtemp.i, 'POSTFOLDERNAME', 'realname'
         If realname = '' Then
            realname = Filespec('NAME', prmtemp.i)
         /* check level */
         prmtest = Left(prmfldr.z.i, Lastpos('\', prmfldr.z.i) - 1)
         found = 0
         Do x = 1 To prmfldr.z.0
            If prmtest = prmfldr.z.x Then
               Do
                  found = x
                  Leave x
               End
         End
         If found > 0 Then
            pbmfldr.z.i = Checkname(realname, pbmfldr.z.found || '\')
         Else
            pbmfldr.z.i = Checkname(realname, pbmfldr || '\')
         Say prmfldr.z.i
         Say pbmfldr.z.i
         Say ''
      End
   If prmfldr.z.0 > 0 Then
      Say 'Found' prmfldr.z.0 'Post Road Mailer folders in' prmacct.z
   Else
      Do
         Say prmacct.z 'has no folders to convert'
         Signal Exit
      End
End
Return 0

Buildfolders:
save_ea = Value(Wordpos('SAVEEA', option) > 0)        /* save ea data */
Do z = 1 To prmacct.0
   acct_tot = 0
   Call Makedir pbmacct.z
   Do i = 1 To prmfldr.z.0
      Call Makedir pbmfldr.z.i
      ea_file = pbmfldr.z.i || '\save_ea.txt'
      xrc = SysFileDelete(ea_file)
      /* read the pop file entries */
      bag = prmfldr.z.i || '\*.pop'
      pop_index = pbmfldr.z.i || '\PopFiles.Inx'
      xrc = SysFileTree(bag, 'bag.', 'FO')
      /* copy messages */
      If bag.0 > 0 Then
         Do
            bag_source = prmfldr.z.i || '\*.pop'
            bag_target = pbmfldr.z.i || '\*.*'
            Address cmd '@copy' bag_source bag_target '> nul'
         End
      /* start building the index file */
      inx = 'X' || Bin(100,4) || Bin(bag.0,4)
      /* build the PopFiles.Inx */
      Do j = 1 To bag.0
         /* add to index file */
         /* pop name */
         bag_pop_name = Filespec('NAME', bag.j)
         inx_pop = Bin(Length(bag_pop_name), 2) || bag_pop_name
         inx = inx || inx_pop
         Trace 'n'
         Call SysGetEA bag.j, 'POPNOTEBUFFER', 'pop_info'
         Parse Var pop_info bag_from_name '09'x bag_from_email ,
            '09'x bag_to_name '09'x bag_to_email '09'x bag_replyto ,
            '09'x bag_date_time '09'x bag_subj ,
            '09'x pop_attr '09'x bag_nine '09'x .
         Parse Var pop_attr bag_attach 2 bag_open 3 bag_eleven
         Parse Var bag_eleven . 3 bag_sent 5 .
         /* analyze message info */
         If \Abbrev(bag_from_name, '15'x) Then
            Say bag_pop_name '- prefix =' C2x(Left(bag_from_name, 1))
         bag_from = Space(Substr(bag_from_name, 2) bag_from_email)
         bag_to = Space(bag_to_name bag_to_email)
         If save_ea Then
            Do
               xrc = Lineout(ea_file, bag_pop_name '-' bag_from '-' bag_to)
               xrc = Lineout(ea_file, 'bag_eleven =' bag_eleven '-' C2x(bag_eleven))
               xrc = Lineout(ea_file, 'bag_nine =' bag_nine '-' C2x(bag_nine))
               xrc = Lineout(ea_file, 'open =' C2x(bag_open) 'attach =' C2x(bag_attach) 'sent =' C2x(bag_sent))
               xrc = Lineout(ea_file, '')
            End
         Parse Var bag_date_time bag_date 9 bag_time 14 bag_zone
         If bag_attach = '03'x Then
            bag_attach = 1
         Else
            bag_attach = 0
         If bag_open = '01'x Then
            bag_stat = 1
         Else
            bag_stat = 0
         If bag_sent = '0101'x Then
            bag_stat = 3
         Trace 'n'
         /* type */
         inx_type = Bin(0, 2)
         inx = inx || inx_type
         /* from */
         If bag_from = '' Then
            Do
               xrc = SysFileSearch('From:', bag.j, 'bag_from.')
               If xrc = 0 & bag_from.0 > 0 Then
                  Do k = 1 To bag_from.0
                     If Abbrev(bag_from.k, 'From:') Then
                        Do
                           Parse Var bag_from.k 'From:' bag_from
                           bag_from = Space(bag_from)
                           Leave k
                        End
                  End
            End
         inx_from = Unitran(bag_from)
         inx_from = Bin(Length(inx_from), 2) || inx_from
         inx = inx || inx_from
         /* to */
         If bag_to = '' Then
            Do
               xrc = SysFileSearch('To:', bag.j, 'bag_to.')
               If xrc = 0 & bag_to.0 > 0 Then
                  Do k = 1 To bag_to.0
                     If Abbrev(bag_to.k, 'To:') Then
                        Do
                           Parse Var bag_to.k 'To:' bag_to
                           bag_to = Space(bag_to)
                           Leave k
                        End
                  End
            End
         inx_to = Unitran(bag_to)
         inx_to = Bin(Length(inx_to), 2) || inx_to
         inx = inx || inx_to
         /* status */
         inx_status = Bin(0, 2)
         inx = inx || inx_status
         /* followup */
         inx_follow = Bin(0, 2)
         inx = inx || inx_follow
         /* subject */
         If bag_subj = '' Then
            Do
               xrc = SysFileSearch('Subject:', bag.j, 'bag_subj.')
               If xrc = 0 & bag_subj.0 > 0 Then
                  Do k = 1 To bag_subj.0
                     If Abbrev(bag_subj.k, 'Subject:') Then
                        Do
                           Parse Var bag_subj.k 'Subject:' bag_subj
                           bag_subj = Space(bag_subj)
                           Leave k
                        End
                  End
            End
         inx_subject = Unitran(bag_subj)
         inx_subject = Bin(Length(inx_subject), 2) || inx_subject
         inx = inx || inx_subject
         /* date */
         If bag_date <> '' Then
            Do
               bag_date = Dateconv(bag_date, 'O', 'N')
               bag_day = Left(Dateconv(bag_date, 'N', 'W'), 3) || ','
               bag_date = bag_day bag_date
               inx_date = Space(bag_date bag_time bag_zone)
            End
         Else
            Do
               xrc = SysFileSearch('Date:', bag.j, 'bag_date.')
               If xrc = 0 & bag_date.0 > 0 Then
                  Do k = 1 To bag_date.0
                     If Abbrev(bag_date.k, 'Date:') Then
                        Do
                           Parse Var bag_date.k 'Date:' bag_date
                           inx_date = Space(bag_date)
                           Leave k
                        End
                  End
            End
         inx_date = Bin(Length(inx_date), 2) || inx_date
         inx = inx || inx_date
         /* date received */
         If bag_stat <> 3 Then
            Do
               msg_date = Stream(bag.j, 'C', 'QUERY DATETIME')
               Parse Var msg_date msg_date msg_time .
               msg_date = Dateconv(Translate(msg_date, '/', '-'), 'U', 'N')
               msg_day = Left(Dateconv(msg_date, 'N', 'W'), 3) || ','
               msg_date = msg_day msg_date
               inx_date_received = Space(msg_date msg_time)
               inx_date_received = Bin(Length(inx_date_received), 2) || inx_date_received
            End
         Else
            inx_date_received = Bin(0,2)
         inx = inx || inx_date_received
         /* notes */
         inx_notes = Bin(0, 2)
         If bag_attach Then
            Do
               Trace 'n'
               bag_notes = ''
               Call SysQueryEAList bag.j, 'bag_ea.'
               If bag_ea.0 > 0 Then
                  Do k = 1 To bag_ea.0
                     If Abbrev(bag_ea.k, 'ATTACH') Then
                        Do
                           If SysGetEA(bag.j, bag_ea.k, 'bag_ea_data') = 0 Then
                              bag_notes = bag_notes bag_ea.k 'in' prmacct.z || ,
                              '\..\tranfile\' || bag_ea_data || crlf
                        End
                  End
               If bag_notes <> '' Then
                  inx_notes = Bin(Length(bag_notes), 2) || bag_notes
               Else
                  bag_attach = 0
               Trace 'n'
            End
         inx = inx || inx_notes
         /* color code */
         inx_color = Bin(0, 4)
         inx = inx || inx_color
         /* size */
         msg_size = Stream(bag.j, 'C', 'QUERY SIZE')
         inx_size = Bin(msg_size, 4)
         inx = inx || inx_size
         /* sent (1), attached (2), opened (4), replied (8) */
         inx_flag = Bin(0,2)
         Select
            When bag_stat = 1 Then                          /* opened */
               inx_flag = Bitor(inx_flag, Bin(4, 2))
            When bag_stat = 2 Then           /* opened and replied to */
               inx_flag = Bitor(Bitor(inx_flag, Bin(4, 2)), Bin(8,2))
            When bag_stat = 3 Then                            /* sent */
               inx_flag = Bitor(Bitor(inx_flag, Bin(4,2)), Bin(1,0))
            Otherwise Nop                                 /* unopened */
         End
         If bag_attach Then                         /* has attachment */
            inx_flag = Bitor(inx_flag, Bin(2, 0))
         inx = inx || inx_flag
      End
      /* write out the index */
      Call SysFileDelete pop_index
      Do k = 1 To Length(inx)
         Call Charout pop_index, Substr(inx, k, 1)
      End
      Call Stream pop_index, 'C', 'CLOSE'
      If save_ea Then
         Call Stream ea_file, 'C', 'CLOSE'
      Say bag.0 'messages copied to' pbmfldr.z.i
      acct_tot = acct_tot + bag.0
   End
   Say acct_tot 'messages copied for' prmacct.z
   Say ''
End
Return

Bin: Procedure
Parse Arg num, length
num = Right(X2c(D2x(num)), length, '00'x)
Return num

Unitran: Procedure Expose fill blank_out low_ascii code uni. base. unicode.
Parse Arg data
If data <> fill Then
   Do                 /* translate low ASCII codes to blanks and test */
      test = Translate(data, blank_out, low_ascii)
      If test = '' Then                 /* no special build necessary */
         newdata = data
      Else
         Do                                   /* translate to Unicode */
            data = Space(Translate(data, uni.code, base.code))
            newdata = ''
            Do i = 1 To Length(data)               /* build new field */
               j = C2d(Substr(data, i, 1))
               newdata = newdata || unicode.j
            End
         End
   End
Else
   newdata = '(null)'
Return newdata

Buildtables:
code_pages = '850'
code = SysQueryProcessCodePage()             /* get current code page */
If Wordpos(code, code_pages) <> 0 Then
   Say 'Using codepage -' code
Else
   Do
      Say 'Cannot run with codepage -' code
      Say 'The supported code page(s) are:'
      Say code_pages
      print = 1
   End
Say ''
base.code = Xrange('00'x, 'FF'x)                 /* current code page */
low_ascii = Xrange('01'x, '7F'x)   /* codes not requiring translation */
blank_out = Copies(' ', 127)

/* 850 translate table (double byte characters set to blank) */
uni.850 = Xrange('00'x, '7F'x)
uni.850 = uni.850 || ,
   D2c(199) || D2c(252) || D2c(233) || D2c(226) || D2c(228) || D2c(224) || D2c(229) || D2c(231) || ,
   D2c(234) || D2c(235) || D2c(232) || D2c(239) || D2c(238) || D2c(236) || D2c(196) || D2c(197) || ,
   D2c(201) || D2c(230) || D2c(198) || D2c(244) || D2c(246) || D2c(242) || D2c(251) || D2c(249) || ,
   D2c(255) || D2c(214) || D2c(220) || D2c(248) || D2c(163) || D2c(216) || D2c(215) || D2c(032) || ,
   D2c(225) || D2c(237) || D2c(243) || D2c(250) || D2c(241) || D2c(209) || D2c(170) || D2c(186) || ,
   D2c(191) || D2c(174) || D2c(172) || D2c(189) || D2c(188) || D2c(161) || D2c(171) || D2c(187) || ,
   D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(193) || D2c(194) || D2c(192) || ,
   D2c(169) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(162) || D2c(165) || D2c(032) || ,
   D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(227) || D2c(195) || ,
   D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(164) || ,
   D2c(240) || D2c(208) || D2c(202) || D2c(203) || D2c(200) || D2c(032) || D2c(205) || D2c(206) || ,
   D2c(207) || D2c(032) || D2c(032) || D2c(032) || D2c(032) || D2c(166) || D2c(204) || D2c(032) || ,
   D2c(211) || D2c(223) || D2c(212) || D2c(210) || D2c(245) || D2c(213) || D2c(181) || D2c(254) || ,
   D2c(222) || D2c(218) || D2c(219) || D2c(217) || D2c(253) || D2c(221) || D2c(175) || D2c(180) || ,
   D2c(173) || D2c(177) || D2c(032) || D2c(190) || D2c(182) || D2c(167) || D2c(247) || D2c(184) || ,
   D2c(176) || D2c(168) || D2c(183) || D2c(185) || D2c(179) || D2c(178) || D2c(032) || D2c(160)

/* Unicode character set values */
Do i = 0 To 255
   If i <> 0 & i < 128 Then
      unicode.i = D2c(i)
   Else
      Do
         byte1 = X2b(C2x(D2c(i)))                /* convert to binary */
         byte1 = '000000' || Left(byte1, 2)          /* shift right 6 */
         byte1 = X2c(B2x(byte1))                    /* convert to hex */
         byte1 = Bitor('C0'x, Bitand('1F'x, byte1))
         byte2 = Bitor('80'x, Bitand('3F'x, D2c(i)))
         unicode.i = byte1 || byte2
      End
End

fill = ''                                              /* empty field */
sep = '09'x                                /* POPNOTEBUFFER delimiter */
crlf = D2c(13) || D2c(10)               /* carriage return + linefeed */

print = Value(Wordpos('PRINT', option) > 0)
dont_print = D2c(0) || D2c(9) || D2c(10) || D2c(13) || D2c(26)
If print Then
   Do x = 1 To Words(code_pages)
      this_code = Word(code_pages, x)
      Do i = 0 To 255                              /* translate table */
         If i = 0 Then
            Do
               Say ''
               Say 'CP' this_code 'to Unicode translate table'
               Say 'CP' this_code '        Unicode'
               Say 'Dec - X  - C - Dec - X  - Unicode'
            End
         j = C2d(Substr(base.code, i + 1, 1))
         If Pos(D2c(j), dont_print) = 0 Then
            s_char = D2c(j)
         Else
            s_char = ' '
         k = C2d(Substr(uni.code, j + 1, 1))         /* Unicode value */
         Say Right(j, 3) '-' Right(D2x(j), 2, '0') '-' s_char '-' ,
            Right(k, 3) '-' Right(D2x(k), 2, '0') '-' ,
            Left(C2x(unicode.k), 4)
      End
   End
If print Then
   Say ''
Return

Makedir: Procedure
Parse Arg newdir
xrc = SysMkDir(newdir)
If xrc = 0 Then
   Say 'Created' newdir
Else
   Do
      If xrc = 5 Then
         Do
            Say newdir 'already exists'
            If SysDestroyObject(newdir) Then
               Do
                  Say 'Destroyed' newdir
                  xrc = SysMkDir(newdir)
                  If xrc = 0 Then
                     Say 'Created' newdir
                  Else
                     Do
                        Say 'Unable to create' newdir 'return code -' xrc
                        Signal Exit
                     End
               End
            Else
               Do
                  Say 'Unable to destroy' newdir
                  Signal Exit
               End
         End
      Else
         Do
            Say 'Unable to create' newdir 'return code -' xrc
            Signal Exit
         End
   End
Return

Checkname: Procedure Expose do83 nametest
Parse Arg name, tree, .
name = Translate(Space(name), '_____', ' ./\?')
If do83 & Length(name) > 8 Then              /* need to reduce length */
   newname = Left(name, 8)
Else
   newname = name
tree = Left(tree, Lastpos('\', tree) -1)
newname = tree || '\' || newname
Do While Wordpos(newname, test) <> 0                   /* make unique */
   newname = SysTempFileName(Left(newname, Length(newname) - 1) || '?')
End
nametest = nametest newname
Return newname

Getaccount: Procedure Expose pbmaccts.
Parse Arg prmacct
Say 'Select a Polarbar Mailer account for'
Say 'Post Road Mailer account' Substr(prmacct, Lastpos('\', prmacct) + 1)
Do i = 1 To pbmaccts.0
   If pbmaccts.i <> '' Then
      Say i '-' pbmaccts.i
End
Parse Pull num
If pbmaccts.num <> '' Then
   Do
      pbmacct = pbmaccts.num
      pbmaccts.num = ''
   End
Else
   Do
      Say 'Invalid selection - create an account for' prmacct
      Signal Exit
   End
Return pbmacct

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
file_system= GetFileSystemType(pbmbase)
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
