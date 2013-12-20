/*  ADR2ASC.CMD -- Convert Post Road Mailer address book to ASCII file.   */
/*                     Parameters: address_book_file                      */
/*  Output files have same filename as ADR, with ASC and GRP extensions.  */
/*   (c) Copyright 1995, InnoVal System Solutions, Inc., Tom Springall    */
/*        (c) Copyright 1996, modifications, InnoVal, Kari Jackson        */
/*    InnoVal Systems Solutions, Inc., and the authors cannot be held     */
/*   responsible for damage that might occur while using this program.    */
/*                         Use at your own risk.                          */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
signal on syntax name ERR5
call SysLoadFuncs
signal on syntax name Syntax

 CRLF = '0D'x||'0A'x

 SAVE_FILECARDS        = X2C('0700') ; SAVE_GROUPS           = X2C('0800')
 SAVE_GNAME            = X2C('2000') ; SAVE_ADDRESSES        = X2C('2200')
 SAVE_GADDRESS         = X2C('2400') ; SAVE_BOOK_NAME        = X2C('3000')
 SAVE_FIRST            = X2C('3500') ; SAVE_CNAME            = X2C('4000')
 SAVE_COMPANY          = X2C('4500') ; SAVE_EMAIL1           = X2C('5000')
 SAVE_EMAIL2           = X2C('7500') ; SAVE_EMAIL3           = X2C('7600')
 SAVE_EMAIL4           = X2C('7700') ; SAVE_EMAIL5           = X2C('7800')
 SAVE_PHONE1           = X2C('8000') ; SAVE_PHONE2           = X2C('8500')
 SAVE_FAX              = X2C('9000') ; SAVE_ADDRESS          = X2C('9500')
 SAVE_NICKNAME1        = X2C('0001') ; SAVE_NICKNAME2        = X2C('0101')
 SAVE_NICKNAME3        = X2C('0201') ; SAVE_NICKNAME4        = X2C('0301')
 SAVE_NICKNAME5        = X2C('0401')

 Arg filespec
 If filespec = '' | Pos('?',filespec) <> 0 then Signal Help

 If Pos('.', filespec) = 0 then filespec = filespec || '.ADR'
 If Stream(filespec,'C','QUERY EXISTS') = '' then Signal Err1

 Parse var filespec file '.' ext
 If ext <> 'ADR' then Signal Err2

 filename = SubStr(file, LastPos('\',file) + 1)
 outfile = filename || '.ASC'
 groupfile = filename || '.GRP'

 outexists=stream(outfile,'c','query exists')
 groupexists=stream(groupfile,'c','query exists')
 If outexists<>'' | groupexists<>'' then do
    say ""
    say "Output file exists....Type 1 to replace, 2 to append all"
    say "entries, 3 to append unique entries only, or 4 to exit."
    do forever
       key=sysgetkey()
       if key=4 then exit 1
       if key=1 | key=2 | key=3 then leave
       say ""
       say "Please type 1, 2, 3, or 4."
    end
    if key=1 then do
       if outexists<>'' then call sysfiledelete outfile
       if groupexists<>'' then call sysfiledelete groupfile
       outexists=''
       groupexists=''
    end
    if key=2 then append='all'
    if key=3 then append='unique'
 end

 If SAVE_BOOK_NAME <> GetCodeLen() then Signal Err3
 valu = CharIn(filespec,,len)
 if outexists='' then do
    If LineOut(outfile, valu '(Post Road Mailer address book' filespec')')<>0 then Signal Err4
    Call LineOut outfile, 'The fields are:'
    Call LineOut outfile, 'Last Name<tab>First Name<tab>Organization<tab>Email 1<tab>Nickname 1<tab>....Email 5<tab>Nickname 5<tab>Telephone 1<tab>Telephone 2<tab>Fax<tab>Notes 1<tab>Notes 2<tab>Notes 3<tab>....Notes X'
    call lineout outfile,''
 end
 if groupexists='' then do
    If LineOut(groupfile, valu '(Post Road Mailer address groups' filespec')')<>0 then Signal Err4
    Call lineOut groupfile, 'The fields are:'
    Call LineOut groupfile, 'Group Name<tab>Address 1<tab>Address 2<tab>Address 3<tab>....Address X'
    call lineout groupfile,''
 end

 typ = '' ; cards = 0 ; groups = 0 ; data. = '' ; carddata. = '' ; groupdata. = ''

 if append='unique' then do
    do 4
       if groupexists<>'' then call linein groupfile
       if outexists<>'' then call linein outfile
    end
    i=0
    do while lines(outfile)
       lin=linein(outfile)
       parse upper var lin . '09'x . '09'x . '09'x Unique1 '09'x . '09'x Unique2 '09'x . '09'x Unique3 '09'x . '09'x Unique4 '09'x . '09'x Unique5 '09'x .
       do j=1 to 5
          check=value(Unique||j)
          if check<>'' then do
             i=i+1
             carddata.i=check
          end
       end
    end
    carddata.0=i
    i=0
    do while lines(groupfile)
       lin=linein(groupfile)
       i=i+1
       parse upper var lin groupdata.i '09'x .
    end
    groupdata.0=i
 end

 Do While Chars(filespec) > 0

   /* read in code value and length of field */
   code = GetCodeLen()                  /* len is also returned */
   /* read in value of field */
   valu = CharIn(filespec,,len)

   Select                               /* handle various code values */
     When code = SAVE_FILECARDS then nop
     When code = SAVE_GROUPS then nop

     When code = SAVE_GNAME then do     /* beginning of a new group */
       Call ProcessPrior typ            /* write prior group or page */
       typ = 'GROUP'
       groups = groups + 1
       data. = ''
       addresses = 0                    /* my count of addresses in group */
       data.GROUP_NAME = valu
       end

     When code = SAVE_ADDRESSES then nop

     When code = SAVE_GADDRESS then do   /* a group address */
       addresses = addresses + 1
       data.GADDRESS.addresses = valu
       end

     When code = SAVE_CNAME then do      /* beginning of a new address page */
       Call ProcessPrior typ             /* write prior page or group */
       typ = 'CARD'
       cards = cards + 1
       data. = ''
       data.LAST_NAME = valu             /* last name */
       end

     When code = SAVE_FIRST then data.FIRST_NAME = valu
     When code = SAVE_COMPANY then data.ORGANIZATION = valu
     When code = SAVE_EMAIL1 then data.EMAIL1 = valu
     When code = SAVE_EMAIL2 then data.EMAIL2 = valu
     When code = SAVE_EMAIL3 then data.EMAIL3 = valu
     When code = SAVE_EMAIL4 then data.EMAIL4 = valu
     When code = SAVE_EMAIL5 then data.EMAIL5 = valu
     When code = SAVE_PHONE1 then data.PHONE1 = valu
     When code = SAVE_PHONE2 then data.PHONE2 = valu
     When code = SAVE_FAX then data.FAX = valu
     When code = SAVE_ADDRESS then data.COMMENTS = valu
     When code = SAVE_NICKNAME1 then data.NICKNAME1 = valu
     When code = SAVE_NICKNAME2 then data.NICKNAME2 = valu
     When code = SAVE_NICKNAME3 then data.NICKNAME3 = valu
     When code = SAVE_NICKNAME4 then data.NICKNAME4 = valu
     When code = SAVE_NICKNAME5 then data.NICKNAME5 = valu

     Otherwise Nop

     End /* of Select */

   end /* of Do While */

 Call ProcessPrior typ            /* write last page or group */

 Call CharOut filespec            /* close files */
 Call LineOut outfile
 Call LineOut groupfile

 Say ''
 Say 'The ASCII version of' filespec
 Say 'is now in' outfile
 Say cards 'entries were processed.'
 Say ''
 if groups>0 then do
   Say 'The address groups in' filespec
   Say 'are now in' groupfile
   Say groups 'entries were processed.'
   Say ''
 end

 Exit                            /* all done. */

/*----------------------------------------------------------------------*/
HELP:
 Say ''
 Say 'ADR2ASC.CMD converts a Post Road Mailer address book to a text file.'
 Say ''
 Say 'Syntax is:  ADR2ASC <path>filename.ADR'
 Say ''
 Say 'The ASCII files will be created in the current directory; one with'
 Say 'an .ASC extension and the other (the address groups) with a .GRP'
 Say 'extension.'
 Say ''
 Exit
/*---------------------------------------------------------------------------*/
GETCODELEN: Procedure Expose filespec len

   /* get 1st 2 words of each record: code, length */
   w1w2 = CharIn(filespec,,8)

   /* save length of what follows (in bytes) */
   len = C2D(Intel(Substr(w1w2,5,2)))

   /* return code for field type */
   Return Left(w1w2,2)

/*---------------------------------------------------------------------------*/
INTEL:  Procedure    /* Swaps bytes in an Intel 2 or 4 byte number. */
 Parse arg x

 If Length(x) = 2 then
   Return Right(x,1) || Left(x,1)

 Else
   Return Intel(Right(x,2)) || Intel(Left(x,2))

/*---------------------------------------------------------------------------*/
PROCESSPRIOR:
 /* Writes field for prior record to the output file. */
 Arg typ

 Select
   When typ = 'CARD' then do            /* address page */

     if append='unique' then do m=1 to 5
        check=translate(value('data.EMAIL'||m))
        if check<>'' then do n=1 to carddata.0
           if check=carddata.n then return
        end
     end

     holding=''
     Do While data.COMMENTS <> ''
       Parse var data.COMMENTS left (crlf) data.COMMENTS
       if holding='' then holding=left
       else holding=holding||'09'x||left
     end
     data.COMMENTS=holding
     if 0<>LineOut(outfile, data.LAST_NAME||'09'x||data.FIRST_NAME||'09'x||data.ORGANIZATION||'09'x||data.EMAIL1||'09'x||data.NICKNAME1||'09'x||data.EMAIL2||'09'x||data.NICKNAME2||'09'x||data.EMAIL3||'09'x||data.NICKNAME3||'09'x||data.EMAIL4||'09'x||data.NICKNAME4||'09'x||data.EMAIL5||'09'x||data.NICKNAME5||'09'x||data.PHONE1||'09'x||data.PHONE2||'09'x||data.FAX||'09'x||data.COMMENTS) then signal err4
   end /* of When */

   When typ = 'GROUP' then do        /* group of addresses */

     if append='unique' then do
        check=translate(data.GROUP_NAME)
        do q=1 to groupdata.0
           if check=groupdata.q then return
        end
     end

     Do i = 1 to addresses
       data.GROUP_NAME=data.GROUP_NAME||'09'x||data.GADDRESS.i
     end

     if 0<>LineOut(groupfile, data.GROUP_NAME) then signal err4

   end /* of When */

   Otherwise Nop

 End /* of Select */

 Return

/*---------------------------------------------------------------------------*/
ERR1:
 Say 'File' filespec 'not found.'
 Exit 1
/*---------------------------------------------------------------------------*/
ERR2:
 Say 'File' filespec 'does not have an address book (.ADR) extension.'
 Exit 1
/*---------------------------------------------------------------------------*/
ERR3:
 Say 'File' filespec 'does not appear to be an address book.'
 Call CharOut filespec
 Exit 1
/*---------------------------------------------------------------------------*/
ERR4:
 Say 'Error writing to file'
 Call CharOut filespec
 Call LineOut outfile
 Call LineOut groupfile
 Exit 1
/*---------------------------------------------------------------------------*/
ERR5:
 say 'Unable to load the REXXUtil functions.  Either the REXXUTIL.DLL file'
 say 'is not on the LIBPATH or REXX support is not installed on this system.'
 exit 1
