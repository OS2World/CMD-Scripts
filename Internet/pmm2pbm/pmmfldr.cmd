/*
Convert PMMail folders
to Polarbar Mailer folders
Chuck McKinnis - mckinnis@attglobal.net
*/
pbmfolder = '\PM_Mail'             /* root folder for PM Mail folders */

Trace 'N'
Call Rxfuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs
Parse Upper Arg option

Call Buildtables                          /* build translation tables */
If print Then
Exit
Call Readaccounts                                     /* get accounts */
Call Readfolders                           /* read the PMMail folders */
Call Buildfolders                       /* build the Polarbar folders */
Exit:
Exit

/* layout of PMMail folder.ini file
real name - rest
*/
Readaccounts:
pmmbase = Directory()
If Stream(pmmbase || '\pmmail.exe', 'C', 'QUERY EXISTS') = '' Then
   Do
      Say 'This routine must run in the'
      Say 'base directory of PM Mail, normally'
      Say 'x:\southsft\pmmail'
      Signal Exit
   End
Call Getpolarbar
/* find the accounts */
pbmacct. = ''
xrc = SysFileTree(pmmbase || '\*.ACT', 'pmmacct.', 'DO')
If xrc = 0 & pmmacct.0 > 0 Then
   Do z = 1 To pmmacct.0
      pbmacct.0 = z
      pbmacct.z = Getaccount(pmmacct.z) || pbmfolder
      Say ''
      Say pmmacct.z
      Say pbmacct.z
      Say ''
   End
Else
   Do
      Say 'No accounts found in' pmmbase
      Signal Exit
   End
Return

Readfolders:
Do z = 1 To pmmacct.0
   Say ''
   nametest = ''
   pmmfldr.z. = ''
   pmmfldr.z.0 = 0
   pbmfldr.z. = ''
   pbmfldr.z.0 = 0
   pmmfldr = pmmacct.z
   pbmfldr = pbmacct.z
   xrc = SysFileTree(pmmfldr || '\*.fld', 'pmmtemp.', 'DSO')
   If xrc = 0 & pmmtemp.0 > 0 Then
      Do i = 1 To pmmtemp.0
         pmmfldr.z.0 = i
         pmmfldr.z.i = pmmtemp.i
         pbmfldr.z.0 = i
         /* get real name of folder */
         realname = Linein(pmmfldr.z.i || '\folder.ini')
         Call Stream pmmfldr.z.i || '\folder.ini', 'C', 'CLOSE'
         Parse Var realname realname 'DE'x .
         /* check level */
         pmmtest = Left(pmmfldr.z.i, Lastpos('\', pmmfldr.z.i) - 1)
         found = 0
         Do x = 1 To pmmfldr.z.0
            If pmmtest = pmmfldr.z.x Then
               Do
                  found = x
                  Leave x
               End
         End
         If found > 0 Then
            pbmfldr.z.i = Checkname(realname, pbmfldr.z.found || '\')
         Else
            pbmfldr.z.i = Checkname(realname, pbmfldr || '\')
         Say pmmfldr.z.i
         Say pbmfldr.z.i
         Say ''
      End
   If pbmfldr.z.0 > 0 Then
      Say 'Found' pbmfldr.z.0 'PM Mail folders in' pmmacct.z
   Else
      Do
         Say pmmacct.z 'has no folders to convert'
         Signal Exit
      End
End
Return 0

Buildfolders:
Do z = 1 To pmmacct.0
   Call Makedir pbmacct.z
   acct_tot = 0
   Do i = 1 To pmmfldr.z.0
      Call Makedir pbmfldr.z.i
      /* read the filter.bag */
      bag. = ''
      bag.0 = 0
      bag = pmmfldr.z.i || '\FOLDER.BAG'
      xrc = Stream(bag, 'C', 'CLOSE')
      Do j = 1 While Lines(bag) > 0
         bag.0 = j
         bag.j = Linein(bag)
      End
      xrc = Stream(bag, 'C', 'CLOSE')
      /* start building the index file */
      inx = 'X' || Bin(100,4) || Bin(bag.0,4)
      /* copy the files */
      Do j = 1 To bag.0
         Parse Var bag.j bag_stat 'DE'x bag_attach 'DE'x bag_date 'DE'x ,
            bag_time 'DE'x bag_subj 'DE'x bag_to_addr 'DE'x ,
            bag_to_name 'DE'x bag_from_addr 'DE'x bag_from_name 'DE'x ,
            bag_size_k 'DE'x bag_pop_file 'DE'x bag_attach_info 'DE'x ,
            bag_size_b .
         /* copy message */
         bag_source = pmmfldr.z.i || '\' || bag_pop_file
         Parse Var bag_pop_file bag_pop_name '.' .
         bag_pop_name = bag_pop_name || '.POP'
         bag_target = pbmfldr.z.i || '\' || bag_pop_name
         Address cmd '@copy' bag_source bag_target '> nul'
         /* add to index file */
         /* pop name */
         inx_pop = Bin(Length(bag_pop_name), 2) || bag_pop_name
         inx = inx || inx_pop
         /* type */
         inx_type = Bin(0, 2)
         inx = inx || inx_type
         /* from */
         inx_from = Unitran(bag_from_name) Unitran(bag_from_addr)
         inx_from = Bin(Length(inx_from), 2) || inx_from
         inx = inx || inx_from
         /* to */
         inx_to = Unitran(bag_to_name) Unitran(bag_to_addr)
         inx_to = Bin(Length(inx_to), 2) || inx_to
         inx = inx || inx_to
         /* status */
         inx_status = Bin(0, 2)
         inx = inx || inx_status
         /* followup */
         inx_follow = Bin(0, 2)
         inx = inx || inx_follow
         /* subject */
         inx_subject = Unitran(bag_subj)
         inx_subject = Bin(Length(inx_subject), 2) || inx_subject
         inx = inx || inx_subject
         /* date */
         bag_date = Dateconv(bag_date, 'I', 'N')
         bag_day = Left(Dateconv(bag_date, 'N', 'W'), 3) || ','
         bag_date = bag_day bag_date
         inx_date = Space(bag_date bag_time)
         inx_date = Bin(Length(inx_date), 2) || inx_date
         inx = inx || inx_date
         /* date received */
         If bag_stat <> 3 Then
            Do
               msg_date = Stream(bag_source, 'C', 'QUERY DATETIME')
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
         inx = inx || inx_notes
         /* color code */
         inx_color = Bin(0, 4)
         inx = inx || inx_color
         /* size */
         msg_size = Stream(bag_source, 'C', 'QUERY SIZE')
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
         If bag_attach = 1 Then                     /* has attachment */
            inx_flag = Bitor(inx_flag, Bin(2, 0))
         inx = inx || inx_flag
      End
      /* write out the index */
      pop_index = pbmfldr.z.i || '\PopFiles.Inx'
      Do k = 1 To Length(inx)
         Call Charout pop_index, Substr(inx, k, 1)
      End
      Call Stream pop_index, 'C', 'CLOSE'
      Say bag.0 'messages copied to' pbmfldr.z.i
      acct_tot = acct_tot + bag.0
   End
   Say acct_tot 'messages copied for' pmmacct.z
   Say ''
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

fill = 'E1'x                                                   /* "á" */
sep = 'DE'x                                                    /* "Þ" */

print = Value(option = 'PRINT')
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

Getaccount: Procedure Expose pbmaccts.
Parse Arg pmmacct
acct_ini = pmmacct || '\acct.ini'
loc = X2d('0201')
len = X2d('FF')
acct_ini = Charin(pmmacct || '\acct.ini', loc, len)
Call Stream pmmacct || '\acct.ini', 'C', 'CLOSE'
pmacct = Strip(acct_ini, , '00'x)
Say 'Select a Polarbar Mailer account for'
Say 'Post Road Mailer account' pmacct '(' || Substr(pmmacct, Lastpos('\', pmmacct) + 1) || ')'
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
      Say 'Invalid selection - create an account for' pmmacct
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
