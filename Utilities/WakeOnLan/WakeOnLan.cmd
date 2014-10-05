/* WakeOnLan.Cmd: Wake on LAN requester

    Copyright (c) 2001, 2003 Steven Levine and Associates, Inc.

    Adapted from code:

    Copyright (c) 2000 José Pedro Oliveira.

    This is free software.  You may modify it and distribute it under
    Perl's Artistic Licence.  Modified versions must be clearly indicated.

    $TLIB$: $ &(#) %n - Ver %v, %f $
    TLIB: $ $

    Revisions	07 Apr 01 SHL - Release
		11 Jan 03 SHL - Correct Usage.  Update standard code

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call Initialize

Main:

  /* Load socket functions */
  rc = RxFuncAdd('SockLoadFuncs','rxSock','SockLoadFuncs')

  rc = SockLoadFuncs(0)

  parse arg sz

  /* Preset */
  Gbl.!Version = '0.11';
  Gbl.!IP = '255.255.255.255';		/* Default broadcast */
  Gbl.!Port = 9				/* Service 9 = discard, getservbyname('discard', 'udp'); */
  Gbl.!aHwAddrs.0 = 0

  call ScanArgs(sz)

  /* Send wakeups */

  do i = 1 to Gbl.!aHwAddrs.0
    rc = Wake(Gbl.!aHwAddrs.i, Gbl.!IP, Gbl.!Port)
  end

  exit 0

/* end main */

/*=== Initialize: Intialize globals ===*/

Initialize:

  call GetCmdName
  call LoadRexxUtil

  return

/* end Initialize */

/*=== ScanArgs(Args) scan command line arguments and switches ===*/

ScanArgs: procedure expose Gbl.

  /* Evaluate arguments - override
     Return Gbl.!f*. and Gbl.!aArgs. etc.
  */

  parse arg szRest
  szRest = strip(szRest)

  if szRest == '' then
    call UsageHelp

  /* Set defaults */
  Gbl.!fDebug = 0			/* Debug messages */
  Gbl.!aHwAddrs.0 = 0			/* Init arg count */

  /* Prepare scanner */
  szSwCtl = 'fip'		       /* Switches that take args */
  fKeepQuoted = 0			/* Set to 1 to keep arguments quoted */
  szArg = ''				/* Current argument string */
  szSw = ''				/* Current switch list */
  fSwEnd = 0				/* End of switches */

  do while szRest \== '' | szArg \== '' | szSw \== ''

    if szArg == '' then do
      /* Buffer empty, refill */
      szQ = left(szRest, 1)		/* Remember quote */
      if \ verify(szQ,'''"', 'M') then do
	parse var szRest szArg szRest	/* Not quoted */
      end
      else do
	/* Arg is quoted */
	szArg = ''
	do forever
	  /* Parse dropping quotes */
	  parse var szRest (szQ)szArg1(szQ) szRest
	  szArg = szArg || szArg1
	  /* Check for escaped quote within quoted string (i.e. "" or '') */
	  if left(szRest, 1) \== szQ then
	    leave				/* No, done */
	  szArg = szArg || szQ		/* Append quote */
	  if fKeepQuoted then
	    szArg = szArg || szQ		/* Append escaped quote */
	  parse var szRest (szQ) szRest
	end /* do */
	if fKeepQuoted then
	  szArg = szQ || szArg || szQ	/* Requote */
      end /* if quoted */
    end

    /* If switch buffer empty, refill */
    if szSw == '' then do
      if left(szArg, 1) == '-' & szArg \== '-' then do
	if fSwEnd then
	  call Usage 'switch '''szArg''' unexpected'
	else if szArg == '--' then
	  fSwEnd = 1
	else do
	  szSw = substr(szArg, 2)	/* Remember switch string */
	  szArg = ''			/* Mark empty */
	  iterate			/* Refill arg buffer */
	end
	parse var szRest szArg szRest
      end
    end

    /* If switch in progress */
    if szSw \== '' then do
      sz = left(szSw, 1)		/* Next switch */
      szSw = substr(szSw, 2)		/* Drop from pending */
      /* Check switch requires argument */
      if pos(sz, szSwCtl) \= 0 then do
	if szSw \== '' then do
	  szOpt = szSw			/* Use rest of switch string for switch argument */
	  szSw = ''
	end
	else if szArg \== '' & left(szArg, 1) \= '-' then do
	  szOpt = szArg			/* Use arg string for switch argument */
	  szArg = ''			/* Mark empty */
	end
	else
	  call Usage 'Switch' sz 'requires argument'
      end
      select

      when sz == 'd' then
	Gbl.!fDebug = 1
      when sz == 'f' then do
	Gbl.!FileName = szOpt
	call Usage '-f not implemented'	/* fixme */
      end
      when sz == 'h' | sz == '?' then
	call UsageHelp
      when sz == 'i' then
	Gbl.!IP = szOpt
      when sz == 'p' then
	Gbl.!Port = szOpt
      when sz == 'V' then do
	say Gbl.!CmdName Gbl.!Version
	exit
      end
      otherwise
	call Usage 'switch '''sz''' unexpected'
      end /* select */
    end /* if switch */

    /* If arg */
    else if szArg \== '' then do
      /* Got non switch arg */
      fSwEnd = 1			/* No more switches */
      i = Gbl.!aHwAddrs.0 + 1
      Gbl.!aHwAddrs.i = szArg
      Gbl.!aHwAddrs.0 = i
      szArg = ''
    end

  end /* while szRest */

  return

/* end ScanArgs */

/*=== TCPFatal(szReq): Report TCPFatal Error... ===*/

TCPFatal:

  parse arg szReq

  call Fatal szReq 'failed, errno:' errno ', h_errno:' h_errno
  say 'Ooops'

  exit 253

/* end TCPFatal */

/*=== Usage(szMsg): Report Usage Error... ===*/

Usage:

  parse arg szMsg

  say szMsg
  say 'Usage:' Gbl.!CmdName '[-h] [-V] [p port] [-i IPAddr] HwAddrs...'

  exit 255

/* end Usage */

/*=== Usage: Display help ===*/

UsageHelp:

  say
  say 'Usage:' Gbl.!CmdName '[-h] [-V] [p port] [-i IPAddr] HwAddrs...'
  say
  say ' -h       This message'
  say ' -i IP    IP address (ddd.ddd.ddd.ddd, default 255.255.255.255)'
  say ' -p Port  Port address( default = 9)'
  if 0 then say ' -f File  File of hardware addresses xx:xx:xx:xx:xx:xx - not implemented fixme'
  say ' -v       Report version'
  say
  say ' HwAddrs  NIC hardware address list (xx:xx:xx:xx:xx:xx, default none)'

  exit 255

/* end UsageHelp */

/*=== Wake(HwAddr, IPAddr, Port): Send packet ===*/

Wake: procedure expose Gbl.

  parse arg  szHwAddr, szIPAddr, nPort

  /*
  # Validate hardware address (ethernet address)

  $hwaddr_re = join(':', ('[0-9A-Fa-f]{1,2}') x 6);
  if ($hwaddr !~ m/^$hwaddr_re$/) {
	  warn "Invalid hardware address: $hwaddr\n";
	  return undef;
  }
  */

  /*
  # Generate magic sequence
  # The 'magic packet' consists of 6 times 0xFF followed by 16 times
  # the hardware address of the NIC. This sequence can be encapsulated
  # in any kind of packet, in this case UDP to the discard port (9).


  foreach (split /:/, $hwaddr) {
	  $pkt .= chr(hex($_));
  }
  */

  /* Convert hex to character and validate */
  sz = translate(szHwAddr, ' ', ':')	/* Colons to spaces */
  fOK = 0
  signal on syntax name WakeNotOK
  achHwAddr = x2c(sz)
  fOK = 1
WakeNotOK:
  signal on syntax
  if \ fOK then
    call Usage szHwAddr 'is not a valid NIC address'
  if length(achHwAddr) \= 6 then
    call Usage szHwAddr 'is not a valid NIC address'

  if Gbl.!fDebug then
    say ' * achHwAddr' c2x(achHwAddr)

  achPkt = copies(x2c('ff'), 6) || copies(achHwAddr, 16)

  if Gbl.!fDebug then
    say ' * achPkt' c2x(achPkt)

  /* Convert host name to IP address */
  /* $raddr = gethostbyname($ipaddr); */
  rc = SockGetHostByName(szIPAddr,'theHost.!')
  if rc \= 1 then
    call TCPFatal 'SockGetHostByName' szIPAddr

  if Gbl.!fDebug then do
    if szIPAddr \= theHost.!addr then
      say ' * IP' theHost.!addr
  end

  /* $them = pack_sockaddr_in($port, $raddr); */

  /* $proto = getprotobyname('udp'); */

  /* socket(S, AF_INET, SOCK_DGRAM, $proto) or die "socket : $!"; */
  sckt = SockSocket('AF_INET', 'SOCK_DGRAM', 'IPPROTO_UDP')
  if sckt = -1 then
    call TCPFatal 'Socket'

  /* SockSetSockOpt is broken on object rexx so bypass if testing under OREXX */
  parse version szRexxVer .
  if szRexxVer == 'OBJREXX' then
    say 'Running OREXX.  Bypassing SockSetSockOpt'
  else do
  /* setsockopt(S, SOL_SOCKET, SO_BROADCAST, 1) or die "setsockopt :$!"; */
  rc = SockSetSockOpt(sckt, 'SOL_SOCKET', 'SO_BROADCAST', 1)
  if rc = -1 then
    call TCPFatal 'SockSetSockOpt'
  end

  say 'Sending magic packet to' szIPAddr':'nPort 'for' szHwAddr

  /* send(S, $pkt, 0, $them) or die "send : $!"; */
  theHost.!family = 'AF_INET'
  theHost.!port = nPort
  rc = SockSendTo(sckt, achPkt,'theHost.!')
  if rc = -1 then
    call TCPFatal 'SockSendTo' theHost.!addr

  return 0

/* end Wake */

/*========================================================================== */
/*=== Standard functions - Delete unused.  Move modified above this mark === */
/*========================================================================== */

/*=== Error() Report ERROR, FAILURE etc. - return szCondition or exit ===*/

Error:
  say
  parse source . . szThisCmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' szThisCmd
  if 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error' RC':' 'ERRORTEXT'(RC)
  say 'Source =' 'SOURCELINE'(SIGL)
  if 'CONDITION'('I') == 'CALL' then do
    szCondition = 'CONDITION'('C')
    say 'Returning'
    return
  end
  trace '?A'
  say 'Exiting'
  call 'SYSSLEEP' 2
  exit

/* end Error */

/*=== Fatal(Message) Report fatal error and exit ===*/

Fatal:
  parse arg szMsg
  say
  say Gbl.!CmdName':' szMsg
  call Beep 200, 300
  exit 254

/* end Fatal */

/*=== GetCmdName() Get script name, set Gbl.!CmdName ===*/

GetCmdName: procedure expose Gbl.
  parse source . . sz
  sz = filespec('N', sz)		/* Chop path */
  c = lastpos('.', sz)
  if c > 1 then
    sz = left(sz, c - 1)		/* Chop extension */
  Gbl.!CmdName = translate(sz, xrange('a', 'z'), xrange('A', 'Z'))	/* Lowercase */
  return

/* end GetCmdName */

/*=== Halt() Report HALT condition - return szCondition or exit ===*/

Halt:
  say
  parse source . . szThisCmd
  say 'CONDITION'('C') 'signaled at' SIGL 'of' szThisCmd
  say 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
  if 'CONDITION'('I') == 'CALL' then do
    szCondition = 'CONDITION'('C')
    say 'Returning'
    return
  end
  say 'Exiting'
  exit

/* end Halt */

/*=== LoadRexxUtil() Load RexxUtil functions ===*/

LoadRexxUtil:
  if RxFuncQuery('SysLoadFuncs') then do
    call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
    if RESULT then
      call Fatal 'Cannot load SysLoadFuncs'
    call SysLoadFuncs
  end
  return

/* end LoadRexxUtil */

/*=== Warn(Message) Report warning ===*/

Warn: procedure
  parse arg szMsg
  call lineout 'STDERR', szMsg
  return

/* end Warn */

/* The end */
