/******************************************************************************
*                                 BSMTP/2                                     *
*                           (c) 2000 by IzzySoft                              *
*******************************************************************************
*          Send content of BSMTP format files to an SMTP server               *
* Syntax:                                                                     *
*          BSMTP <InFile> [<Hostname> [<Port>]]                               *
*            where <InFile>   is the name of the BSMTP file to process        *
*                  <Hostname> is the name of the host running the server      *
*                  <Port>     is the port used (if not standard port 25)      *
*******************************************************************************
* needs nvt.dll !! (from rxtelnet package: rxtelnet.zip on hobbes)            *
* needs rxu.dll !! (from rxu package     : rxu1a.zip    on hobbes)            *
******************************************************************************/

  version    = '0.43a'

/* Read commandline arguments */

  parse arg infile a_hostname a_port

/* Programm structure */

  Call Load_Lib                             /* load REXX libs */
  Call Config                               /* do the configuration */
  Call Logo                                 /* Cls and Logo */
  if infile = '' then signal error_syntax
  Call Init_Socket                          /* open connection to SMTP */
  Call Open_Infile                          /* read input bsmtp file to stem */
  BSmtp.ReadLine = 1                        /* in what line are we? */
  MailCount      = 0                        /* This is Mail number x */
  DeliveredCount = 0                        /* numbers of delivered mails */
  Do While ( BSmtp.ReadLine < BSmtp.0 )     /* send content of input file */
    MailCount = MailCount + 1
    MajorDomo.Mail = 0                      /* Mail is not to a Mailing List */
    Call ReadMail                           /* Preparing Mail. stem */
    If MajorDomo.Is Then Call TestMail      /* check if ToLocal or even List *
                                             * (needs only to be called when *
                                             * MajorDomo function used;      *
                                             * MajorDomo is called from here *
                                             * if necessary                  */
    Call Envelope
    if connected = 0 then leave
    Call MailData
    if connected = 0 then leave
    If ( Mail.Bounced = 1 ) Then Call BounceMail
    /* If ( Mail.Bounced = 2 ) Then Call FailedBounce */ /* just notify postmaster */
  End
  If DeletePkt then
   Do
    If (MailCount = DeliveredCount) then
      do
        rc = SysFileDelete(infile)
        Call ScrPut '- All Msgs sent successfully, packet deleted.'
        Call WriteLog '- All Msgs delivered successfully, packet deleted.'
      end /* do if MailCount */
   End /* do if DeletePkt */
  Call Quit                                    /* shutdown connection */
  Exit                                         /* leave the program */

/* =======================================================[ subroutines ]=== */

/* -----------------------------------------------------[ configuration ]--- */

Config:

  parse source . . maindir                           /* get source directory */
  parse value reverse(maindir) with '\' maindir
  maindir = reverse(maindir)

  DeletePkt = 0                       /* delete pkt if all msgs sent ok? */
  port   = 25                                                /* set defaults */
  connected  = 0
  debug      = 0                      /* debug info ? = 1 */
  LogFile    = 'bsmtp.log'
  BadMailDir = 'BadMail'              /* directory to put bad mail */
  hostname   = ''
  LocalDomain      = 'qumran.org'     /* domain for listmails */
  MajorDomo.Is     = 0                /* act as MajorDomo? = 1 */
  ListFile         = 'maillist.cfg'   /* list definition */
  MajorDomo.Cmd    = 'QMDomo.Cmd'     /* Cmd for MajorDomo */
  MajorDomo.Weasel = 0                /* Weasel-Style Call? */
  TimeOut          = 1000
  UseLogLevel      = '+!$-#x'
  ScrLogLevel      = '+!$-#x'

  Call read_cfg                                   /* read in the config file */
  If ( a_hostname <> '' ) Then hostname = a_hostname
  If ( a_port     <> '' ) Then port     = a_port
  LocalHost        = value('hostname',,'OS2ENVIRONMENT')||'.'||LocalDomain

  Call WriteLog "+ BSmtp/2 v"||version||" coming up"
  Call WriteLog "$ Ã Using main configuration file "config_file
  Call WriteLog "$ À Using list configuration file "ListFile

  If MajorDomo.Is Then Call List_Cfg             /* read in list definitions */

  EOT = '04'x /* diamond */
  ACK = '06'x /* spade */
  BEL = '07'x /* dot */
  OUT = '18'x /* up-arrow */
  IN  = '19'x /* down-arrow */

  signal on halt                                 /* signals */
  signal on error
  signal on syntax

Return

/* ----------------------- Konfiguration einlesen -------------------------- */

read_cfg:

  config_file = maindir'\BSmtp.Cfg'                 /* KonfigDatei festlegen */

  Zeile = 0
  Do While lines(config_file)
    Zeile = Zeile + 1
    Parse Value linein(config_file) with KeyWord KeyContent ';' .
    KeyWord = translate(strip(KeyWord))
    KeyContent = strip(KeyContent)
    Select
      When KeyWord = 'DEBUG'
        then Debug = 1
      When KeyWord = 'DELETEPKT'
        then DeletePkt = 1
      When KeyWord = 'LOGFILE'
        then LogFile = KeyContent
      When KeyWord = 'HOSTNAME'
        then hostname = KeyContent
      When KeyWord = 'PORT'
        then port = KeyContent
      When KeyWord = 'TIMEOUT'
        then TimeOut = KeyContent
      When KeyWord = 'BADMAILDIR'
        then BadMailDir = KeyContent
      When KeyWord = 'LOCALDOMAIN'
        then LocalDomain = KeyContent
      When KeyWord = 'MAJORDOMO'
        then MajorDomo.Is = 1
      When KeyWord = 'LISTFILE'
        then ListFile = KeyContent
      When KeyWord = 'LOGLEVEL'
        then UseLogLevel = KeyContent
      When KeyWord = 'SCRLEVEL'
        then UseScrLevel = KeyContent
      When KeyWord = ';'
        then nop
      When KeyWord = '#'
        then nop
      When KeyWord = ''
        then nop
      Otherwise
        signal error_keyword
    End /* Select */
  End /* Do While lines(config_file) */

Return

/* ------------------------------------------------[ list configuration ]--- */

List_Cfg:

  Call ScrPut "# Opening "||ListFile||" and reading it into variable MailLists."
  Call WriteLog "# Opening "||ListFile||" and reading it into variable MailLists."
  rc = RxExecI(ListFile,,'MailLists.','s')  /* Read ListFile into stem MailLists */
  Parse Var rc InLines InBytes
  Say "Read "||InBytes||" Bytes in "||InLines||" lines."
  Call WriteLog "x Read "||InBytes||" Bytes in "||InLines||" lines."
  If InLines = 0                               /* InFile not found or empty! */
    then signal value error_fileopen('List-Konfigurations-Datei 'ListFile)
  ListCount = 0
  ListNames = ''
  Do i = 1 To MailLists.0                      /* Lines of MailList.Cfg */
    Parse Value MailLists.i With ListName Participant
    rc = WordPos(ListName,ListNames)
    If (rc <> 0)
      Then Do
        TempNr = MailList.rc.0 + 1
        MailList.rc.TempNr = Participant
        MailList.rc.0 = TempNr
        Drop TempNr
      End
      Else Do
        Select
          When KeyWord = ';'
            then nop
          When KeyWord = '#'
            then nop
          When KeyWord = ''
            then nop
          Otherwise Do
            ListCount = ListCount + 1
            ListNames = ListNames||" "||ListName
            MailList.ListCount.1 = Participant
            MailList.ListCount.0 = 1
          End /* otherwise */
        End /* Select */
      End /* else do */
  End /* Do i */

Return

/* ----------------------------------------------------[ load libraries ]--- */

Load_Lib:

  If RxFuncQuery('NvtQuery') \= 0 Then
   Do
    call RxFuncAdd "NvtLoadFuncs","Nvt","NvtLoadFuncs"
    call NvtLoadFuncs
    call RxFuncDrop "NvtLoadFuncs"
   End
  If RxFuncQuery('SysLoadFuncs') \= 0 Then
   Do
    Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    Call SysLoadFuncs
   End
  If RxFuncQuery('RxUQuery') \= 0 Then
   Do
    call rxfuncadd "rxuinit","rxu","rxuinit"
    call rxuinit
   End

Return

/* --------------------------------------------------------[ print logo ]--- */

Logo:
call SysCls
say '   ************************************************************************'
say '   *          BSMTP/2 v'version'                (c) 2000 by IzzySoft          *'
say '   *                                                                      *'
say '   *     This software is protected by the GNU General Public License     *'
say '   *    version 2.  No warranty is given! (see the file named COPYING)    *'
say '   ************************************************************************'
say ''
Return


/* ---------------------------------------------------------[ Write Log ]--- */

WriteLog:
 parse arg loglevel message
 if ( pos(loglevel,useloglevel) = 0 ) then return
 if loglevel = "x" then loglevel = " "
 parse value date("E") with Tag "/" Monat "/" Jahr
 Datum = Tag||"."||Monat"."||Jahr
 if message <> ''
  then call lineout LogFile, loglevel Datum time() message
  else call lineout LogFile, ''
 call stream ln,"c","Close"
return

/* --------------------------------------------------------[ Put2Screen ]--- */

ScrPut:
 parse arg scrlevel message
 if ( pos(scrlevel,usescrlevel) = 0 ) then return
 if loglevel = "x" then loglevel = " "
 if message <> ''
  then Say message
  else Say ''
return

/* -------------------------------------------------------[ init socket ]--- */

Init_Socket:
Call ScrPut '$ Port is: '||port
  socket = Telnet(hostname,port)

  if socket = ''
    then do
        Call ScrPut '! telnet connection failed'
        Call WriteLog '! Telnet connection to '||hostname||':'||port||' failed'
        Call Quit
        Exit 12
      end
    else do
      connected = 1
      Call WriteLog '+ Opened telnet connection to '||hostname||' on Port '||port
      Call ScrPut '$ status='tctl(socket) BEL
      Data2Sock = 'HELO '||LocalHost
      c = Tput(socket,Data2Sock)            /* say "HELO" to the SMTP server */
      do forever
        SockData = Tget(socket,TimeOut)
        if debug then dummy = lineout('session.log','<'||SockData)
        select
          when SockData = EOT then leave    /* intro done, send mail */
          when SockData = ''
            then do; connected = 0; return; end;
          otherwise                /* normally 2 lines: 220 <server>, 250 OK */
            Call ScrPut '+ '||SockData
        end /* select */
      end /* do forever */
    end /* else do (if connection) */

Return

/* -------------------------------------------------------[ open infile ]--- */

Open_Infile:

  Call ScrPut "# Opening "||InFile||" and reading it into variable BSmtp."
  Call WriteLog "# Opening "||InFile||" and reading it into variable BSmtp."
  rc = RxExecI(InFile,,'BSmtp.','s')          /* Read InFile into stem BSmtp */
  Parse Var rc InLines InBytes
  Call ScrPut "# Read "||InBytes||" Bytes in "||InLines||" lines."
  Call WriteLog "# Read "||InBytes||" Bytes in "||InLines||" lines."
  If InLines = 0                               /* InFile not found or empty! */
    then signal value error_fileopen('Eingabedatei 'infile)

Return

/* -------------------------------------------------------[ parse mails ]--- */

ReadMail:

  Say ''
  Call ScrPut "x Reading Message number "||MailCount||":"
  Mail.Bounced   = 0                            /* original mail, no bounce */
  Mail.Env.To.0  = 0                            /* no recipient yet */
  MajorDomo.Mail = 0                            /* assume no mailing list */
  Call ScrPut "$ - Evaluating Envelope..."

  Do Until ( BSmtp.Line = 'DATA' )             /* read envelope */
    Line = BSmtp.ReadLine
    Parse Value BSmtp.Line with KeyWordA ':' KeyValue
    Parse Upper Value KeyWordA with KeyWord
    Select
      When KeyWord = 'MAIL FROM' Then Mail.Env.From = KeyValue
      When KeyWord = 'RCPT TO' Then
        Do
          i = Mail.Env.To.0
          i = i + 1                            /* one more recipient */
          Mail.Env.To.i = KeyValue             /* add recipient */
          Mail.Env.To.0 = i                    /* recipient added */
        End
      When KeyWord = 'DATA' Then nop
      When BSmtp.ReadLine = BSmtp.0 Then       /* End of Data reached */
        Do
          Call Quit
          Exit 9 /* unexpected end of data */
        End
      Otherwise nop                            /* illegal Data in Envelope? */
    End /* Select */
    BSmtp.ReadLine = BSmtp.ReadLine + 1
  End /* Envelope */

  Mail.1 = 'Received: by '||LocalHost||' (BSmtp/2 v'||version||'); '
  Mail.1 = Mail.1||Date('N')||' '||Time()
  Mail.0 = 1                                   /* no mail data yet but above */
  i      = 1                                   /* line-counter */
  Mail.ReplyTo  = ''                           /* init header VARs */
  Mail.ReplyToZ = 0
  Mail.Sender   = Mail.Env.From
  Mail.FromZ    = 0
  Mail.To.0     = 0
  Mail.To.Z1    = 0

  Call ScrPut "$ - Evaluating Header..."
  Do Until ( Mail.i = '' )                    /* read & interpret header */
    i = i + 1
    Line = BSmtp.ReadLine
    Mail.i = BSmtp.Line
    Parse Value Mail.i with KeyWordA ':' KeyValue
    Parse Upper Value KeyWordA with KeyWord
    Select
      When KeyWord = 'TO' Then                 /* Recipients of current mail */
        Do
          If ( Mail.To.Z1 = 0  ) Then Mail.To.Z1 = i
          k = Mail.To.0
          k = k + 1
          Mail.To.k = KeyValue
          Mail.To.0 = k
          Drop k                               /* remove temp VAR */
        End /* Do 'TO' */
      When KeyWord = 'SENDER' Then Mail.Sender = KeyValue
      When KeyWord = 'FROM' Then
        Do
          Parse Value Mail.i With 'From:' Mail.From
          Mail.From = Strip(Mail.From)
          If ( Mail.FromZ = 0 ) Then Mail.FromZ = i
        End /* Do 'FROM' */
      When KeyWord = 'REPLY-TO' Then
      Do
        Mail.ReplyTo = KeyValue
        Mail.ReplyToZ = i
      End /* Do 'REPLY-TO' */
      Otherwise nop
    End /* Select */
    Mail.HeadZ = i
    BSmtp.ReadLine = BSmtp.ReadLine + 1
  End /* Do Header */

  If Mail.ReplyToZ = 0 Then Do                /* insert Reply-To if missing */
    Mail.ReplyTo  = Mail.From
    Mail.i        = 'Reply-To: '||Mail.ReplyTo
    Mail.ReplyToZ = i
    i             = i + 1
    Mail.i        = ''
  End

  Call ScrPut "$ - Storing Body..."
  Do Until ( BSmtp.Line = '..' )                /* read & store body */
    i = i + 1
    Line = BSmtp.ReadLine
    If ( BSmtp.Line = '..' ) Then Mail.i = '.'
      Else Mail.i = BSmtp.Line
    BSmtp.ReadLine = BSmtp.ReadLine + 1
  End /* Do Body */

  Mail.0 = i
  Drop i

Return

/* ------------------------------------------------------[ Domain Check ]--- */

IsOurDomain:
 Parse Arg MailAddress
 Select
   When Pos('>',MailAddress) <> 0
    Then Parse Upper Value MailAddress With '<' UserName '@' UpperDomainName '>'
   When Pos(')', MailAddress) <> 0
    Then Parse Upper Value MailAddress With UserName '@' UpperDomainName Dummy
   Otherwise Parse Upper Value MailAddress With UserName '@' UpperDomainName
 End /* Select */
 Parse Upper Var LocalDomain UpperListDomain
 If ( UpperDomainName = UpperListDomain )
  Then Return 1
  Else Return 0

/* ------------------------------------------------[ Test Mail if local ]--- */

TestMail:

  Call ScrPut "x Checking Message number "||MailCount||":"
  TDAddress.0 = 0
  Do i = 1 To Mail.Env.To.0
    If IsOurDomain(Mail.Env.To.i) Then Do
      Call ScrPut "- - Rcpt To local user ("||Mail.Env.To.i||") - checking if ListMail."
      Call WriteLog "- Rcpt To local user ("||Mail.Env.To.i||") - checking if ListMail."
      Do k = 1 To Words(ListNames)
        Select
          When Pos('>',Mail.Env.To.i) <> 0
           Then Parse Upper Value Mail.Env.To.i With '<' TempUser '@' dummy
          Otherwise Parse Upper Value Mail.Env.To.i With TempUser '@' dummy
        End /* Select */
        Parse Upper Value Word(ListNames,k) With TempList
        If ( TempUser = TempList ) Then Do
          MajorDomo.Mail = 1
          Call ScrPut "x - Mail to MailingList: "||TempList
          Call WriteLog "x Mail to MailingList: "||TempList
          TNr           = TDAddress.0 + 1       /* insert mailing list into */
          TDAddress.TNr = Mail.Env.To.i         /* temporary storage */
          TDAddress.0   = TNr
          Mail.Env.To.i = '$deleted$'           /* mark address for removal */
        End /* IsList */
      End /* Do k */
    End /* If IsOurDomain */
  End /* Do i */
  
  If MajorDomo.Mail Then
    Do
      TMAddress.0 = 0
      Do i = 1 To Mail.Env.To.0
        If Mail.Env.To.i = '$deleted$' Then Nop
        Else Do
          TNr           = TMAddress.0 + 1
          TMAddress.TNr = Mail.Env.To.i
          TMAddress.0   = TNr
        End
      End
      Mail.Env.To.0 = 1                        /* Truncate Envelope-To */
      Do i = 1 To TDAddress.0
        Mail.Env.To.1 = TDAddress.i            /* prepare for QMDomo */
        Call ScrPut "x - Mail is to our lists, invoking QMDomo."
        Call WriteLog "x À Mail is to our lists, invoking QMDomo."
        If \ MajorDomo.Weasel
          Then Call QMDomo

        Call Envelope                          /* Now send the ListMail */
        if connected = 0 then signal error_connection
        Call MailData
        if connected = 0 then signal error_connection
        If ( Mail.Bounced = 1 ) Then Call BounceMail
      End

      Mail.Env.To.0 = 0                        /* completely truncate Env.To */
      Do i = 1 To TMAddress.0                  /* rebuild Env-To w/o listmail */
        TNr             = Mail.Env.To.0 + 1
        Mail.Env.To.TNr = TMAddress.i
        Mail.Env.To.0   = TNr
      End
    End
   Else
    Do
      Call ScrPut "x - Mail is not to any of our lists."
      Call WriteLog "x À Mail is not to any of our lists."
    End

  Drop TempUser TempList dummy TNr TDAddress. TMAddress.

Return /* From TestMail */


/* --------------------------------------------------------[ Major Domo ]--- */

QMDomo: PROCEDURE EXPOSE Mail. ListNames MailList. LocalDomain

  TListNames = ''
  Do i = 1 To Words(ListNames)                   /* TListnames includes Domain */
    TListNames = TListNames||' '||Word(ListNames,i)||'@'||LocalDomain
  End

  Parse Upper Value TListNames With ListNames

  Do k = 1 To Words(ListNames)
    If Pos('<',Mail.Env.To.1) <> 0
      Then Parse Upper Value Mail.Env.To.1 With '<' TUser '>' Dummy
      Else Parse Upper Value Mail.Env.To.1 With TUser Dummy
    If ( TUser = Word(ListNames,k) ) Then Do
      Mail.Env.To.0 = 0
      Do l = 1 To MailList.k.0
        If Pos('<',MailList.k.l) <> 0
          Then Parse Value MailList.k.l With '<' TMUser '>' Dummy
          Else Parse Value MailList.k.l With TMUser Dummy
        TempNr = Mail.Env.To.0 + 1
        Mail.Env.To.TempNr = '<'||TMUser||'>' /* Append to end of RCPT TO list */
        Mail.Env.To.0 = TempNr
      End
      Mail.Env.From = 'owner-'||Word(TListNames,k)
      TempNr        = Mail.ReplyToZ
      Mail.TempNr   = 'Reply-To: <'Word(TListNames,k)'>'
      Mail.ReplyTo  = Word(TListNames,k)
      Drop TempNr TMUser
      Leave
    End
  End

Return

/* -----------------------------------------------------[ send envelope ]--- */

Envelope:

  receivers  = 0                                       /* no receiver yet ;) */
  Failed.0   = 0                                   /* nothing bounced yet ;) */
  If ( Mail.Bounced ) = 0 Then
    Call WriteLog "x Processing Msg Nr. "MailCount
  Else Call WriteLog "x Processing Bounce from Msg Nr. "MailCount

  SockData = ToSocket('MAIL FROM:'||Mail.Env.From)            /* Send 'FROM' */

  Do i = 1 To Mail.Env.To.0
    SockData = ToSocket('RCPT TO:'||Mail.Env.To.i)
    Parse Value SockData With rc rc_comment
    Select
      when rc = '000' then leave                     /* connection broken */
      when rc = '250' then do 
        receivers = receivers + 1                    /* '250 mailbox ok' */
        Call WriteLog "+ Delivering to "||Mail.Env.To.i
        Call ScrPut "+ Delivering to "||Mail.Env.To.i
        End
      /*  when rc = '551' then */       /* administrative reject (spam?) */
      /*  when rc = '553' then */                  /* '553 user unknown' */
      otherwise
        Select
          When ( Mail.Bounced = 0 ) Then Do
            /* notice failure for further processing */
            k = Failed.0 + 1
            Failed.k = Mail.Env.To.i
            Failed.Data.k = SockData
            Failed.0 = k
            /* Write Msg to BadMailDir */
            If (Failed.0 = 1) Then Do
              BadMsg = BadMailDir||'\'||SysTempFileName(????.MSG)
              rc = LineOut(BadMsg,'MAIL FROM:'||Mail.Env.From)
              do k = 1 To Mail.Env.To.0
                rc = LineOut(BadMsg,'RCPT TO:'||Mail.Env.To.k)
              end
              rc = stream(BadMsg,'c','close')
              rc = RxExecO(BadMsg,'a','Mail.','s')
            End /* Do (Failed.0 = 1) */
            /* Make entry to LogFile about rejected msg */
            Call WriteLog "!  Mail rejected, response was: "||SockData
            Call WriteLog "!  Ã Mail could not be delivered to "||Mail.Env.To.i
            Call WriteLog "!  À Message was saved to "||BadMsg
           End
          When ( Mail.Bounced = 1 ) Then Do
            Call WriteLog "!  Mail rejected, response was: "||SockData
            Call WriteLog "!  Ã it is a bounce mail, so sender was bounced again!"
            Call WriteLog "!  À original message was already saved to "||BadMsg
           End
          Otherwise Do
            Call WriteLog "! Mail rejected, response was: "||SockData
            Call WriteLog "! Ã it is a notify of failed bounce to postmaster!!!"
            Call WriteLog "! À original message was already saved to "||BadMsg
           End
          Drop k rc
        End /* Select */
    End /* Select */
  End /* 'RCPT TO' */

  if ( Failed.0 > 0 ) then Mail.Bounced = Mail.Bounced + 1
  if ( receivers > 0) then do
    SockData = ToSocket('DATA')
    SockData = Tget(socket,TimeOut)
    if debug then dummy = lineout('session.log','<'||SockData)
    parse value SockData with rc rc_comment
    select
      when rc = '354' then         /* '354 socket to me' => all ok */
        do
          SockData = Tget(socket,TimeOut)
          if debug then dummy = lineout('session.log','<'||SockData)
          parse value SockData with rc rc_comment
          if rc <> EOT then nop   /* "AfterBurner" Diamond */
        end
      when rc = EOT then nop /* what does the Diamond have to do here? */
      otherwise
        connection = 0
        if debug then dummy = lineout('session.log','! Trouble! socket sent '||rc)
        return
    end /* select */
  end /* if receivers */

Return

/* ----------------------------------------------------[ send to socket ]--- */

ToSocket:

  Parse Arg Data2Sock
  if debug then dummy = lineout('session.log','>'||Data2Sock)
  c = Tput(socket,Data2Sock)                          /* send to socket */
  if c <> 0                                        /* connection broken */
    then do; connected = 0; return '000 connection broken' ; end;
  Sock2Data = Tget(socket,TimeOut)
  if debug then dummy = lineout('session.log','<'||Sock2Data)
  select
    when Sock2Data = EOT  then nop        /* "AfterBurner" Diamond */
    when Sock2Data = ''
      then do; connected = 0; return Sock2Data; end;
    otherwise
      Call ScrPut "$ "||Sock2Data
  end /* select */

Return Sock2Data

/* ---------------------------------------------------------[ send mail ]--- */

MailData:

  if connected = 0 then return
  if receivers > 0 then do                  /* mail is to be delivered */
    If ( Mail.Bounced = 1 ) Then Call BounceHeader
    Do i = 1 To Mail.0
      If Debug Then dummy = lineout('session.log','>'||Mail.i)
      putline = Mail.i
      islong  = Length(putline)
      Do Until (islong < 256)              /* tput() is limited to 256 chars */
        islong = Length(putline)
        if (islong > 255) then
          do
            linepart = Left(putline,255)||"="             /* imitate mime LF */
            putline  = SubStr(putline,256,islong-255)
          end
          else linepart = putline
        Data2Sock = Tput(socket,linepart)
        if Data2Sock <> 0 then do; connected = 0; leave; end;
      End /* Do Until */
      Drop islong putline linepart
      if ( Mail.i = '.' ) Then
        do
          SockData = Tget(socket,TimeOut)
          if debug then do
            dummy = lineout('session.log','<'||SockData)
            dummy = Lineout('session.log','! End of Mail reached!')
          end
          parse value SockData with rc rc_comment
          select
            when rc = '250' then do             /* '250 OK' => all ok */
              Call ScrPut '- Mail sent successfully.'
              Call WriteLog '- À delivered successfully.'
              DeliveredCount = DeliveredCount + 1
              leave
            end
            otherwise nop
          end /* select */
        end /* do */
    End /* Do to Mail.0 */
   End /* Do receivers */
  Else Return
  Drop Data2Sock SockData rc rc_comment

Return

BounceHeader:

  Do k = 1 To Failed.Msg.0
    If Debug Then dummy = lineout('session.log','>'||Failed.Msg.k)
    Data2Sock = Tput(socket,Failed.Msg.k)
    if Data2Sock <> 0 then do; connected = 0; leave; end;
  End

Return

/* -------------------------------------------------------[ bounce mail ]--- */

BounceMail:

  Mail.Env.To.1 = Mail.Env.From
  Mail.Env.To.0 = 1
  Mail.Env.From = "postmaster@"||LocalDomain
  Mail.From     = "Mailer Daemon <postmaster@"||LocalDomain||">"

  Failed.Msg.1  = "From: Mailer Daemon <postmaster@"||LocalDomain||">"
  Failed.Msg.2  = "To: "Mail.Env.To.1
  Failed.Msg.3  = ""
  Failed.Msg.4  = "Your mail was not delivered to the following recipient(s):"
  Failed.Msg.5   = ""
  Do i = 6 To ( Failed.0 + 5 )
    k = i - 5
    Failed.Msg.i = "  "||Failed.k||": "||Failed.Data.k
  End
  Failed.Msg.i   = ""
  i = i + 1
  Failed.Msg.i  = "There will be no further attempts to deliver this mail."
  i = i + 1
  Failed.Msg.i   = ""
  Failed.Msg.0  = i

  Say "Sending BounceMail with "Failed.Msg.0" lines:"
  Call Envelope
  Call MailData

Return

/* ----------------------------------------------------[ error messages ]--- */

  error_keyword:
    Say ' W A R N I N G ! ! !'
    Say 'Unknown KeyWord 'KeyWord' on line 'Zeile' of 'config_file
    Say 'Programm aborted'
    Exit 1                        /* Rexx error 1: "Invalid function number" */

  error_syntax:
    Call Logo
    Say ''
    Say 'Syntax:'
    Say '  BSMTP <InFile> [<Hostname> [<Port>]]'
    Say '    where <InFile>   is the name of the BSMTP file to process'
    Say '          <Hostname> is the name of the host running the server'
    Say '          <Port>     is the port used (if not standard port 25)'
    Call SysSleep 2
    Exit 1

  error_fileopen:
    Parse Arg Datei
    Say ' W A R N I N G ! ! !'
    Say Datei' could not be opened!'
    Say 'Programm aborted.'
    Call WriteLog "! "Datei" could not be opened!"
    Call WriteLog "! Programm aborted."
    Call quit
    Exit 2                                 /* Rexx error 2: "File not found" */

  error_connection:
    Say '!!! Connection lost !!!'
    Say 'Programm aborted.'
    Call WriteLog "! Connection lost!"
    Call WriteLog "! Programm aborted."
    Call quit
    Exit 11                              /* ErrorLevel 11: "Connection lost" */

  syntax:
   say '! syntax'
  error:
   say '! error'
  halt:
   say '! halt'


/* -----------------------------------------------[ shutdown connection ]--- */


  quit:
   c = Tput(socket,'QUIT')
   call Tquit socket
   Call WriteLog '+ Closed sockets.'
   Call WriteLog "+ BSmtp/2 v"||version||" closing down"
   Call WriteLog "x"

/* remove comment if you want to DeRegister the Rexx Libraries
 * 
 * call RxFuncAdd "NvtDropFuncs","Nvt","NvtDropFuncs"
 * call NvtDropFuncs
 * call RxFuncDrop "NvtDropFuncs"
 *
 * call RxuTerm
 *
 * call SysDropFuncs
 */
   return
