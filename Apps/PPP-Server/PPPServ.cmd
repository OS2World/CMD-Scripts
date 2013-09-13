/*
   --- PPP Server ---

   by Andrey Vasilkin AKA Digi, 2001-2006y.

   Запускной скрипт.
   Читает конфигурационный файл %ETC%\dialin.cfg
   Создает очереди и стартует ppplog.cmd, pppcnt.cmd для каждого из портов.

   Для работы требуется драйвер PPP версии 1.18b
*/

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

signal on halt

ETCPath = value('ETC',,'OS2ENVIRONMENT')

parse arg CmdLine
parse value strip(CmdLine) with '-'Cmd' 'CmdLine
CmdLine = strip(CmdLine)
Cmd = translate(Cmd)

select
  when Cmd='R' then signal Server
  when Cmd='V' then signal State
  when Cmd='S' then signal Shutdown
  when Cmd='H' then signal Hangup
  when Cmd='-0' then signal DialinProcess
  when Cmd='-1' then signal LogProcess
  OTHERWISE signal Help
end

Exit


/***************************************************************/
/*                                                             */
/*                           Server                            */
/*                                                             */
/***************************************************************/
Server:

if CmdLine='' then PortN = 0
else do
  parse upper value CmdLine with 'COM'PortN
  if \DataType(PortN,'N') | N<=0 then signal Help
end

CfgFile = ETCPath'\dialin.cfg'

ComPorts.0 = 1
ComPorts.1 = 1
LogFile = ETCPath'\dialin.stat'

if lines(CfgFile)=0 then
do
  say 'Can''t open file 'CfgFile
  Exit
end

do i=1 by 1 while lines(CfgFile)\=0
  Line = space(linein(CfgFile))
  if (Left(Line,1) \= '#') & (Line\='') then
  do
    P = translate(Word(Line,1))
    select
      when P = 'PORTS' then do
        if Words(Line) = 1 then signal CfgErr
        do j=1 to Words(Line)-1
          ComPorts.j = Right(Word(Line,j+1),1)
          if \DataType(ComPorts.j,'N') | (ComPorts.j=0) then signal CfgErr
          do k=1 to j-1
            if ComPorts.k = ComPorts.j then signal CfgErr
          end
        end
        ComPorts.0 = j-1
      end
      when P = 'STATFILE' then LogFile = SubWord(Line,2)
      otherwise
CfgErr:
        say 'Error in 'CfgFile' at line 'i': "'Line'"'
        Exit
    end
  end
end
call stream CfgFile,'c','close'

parse SOURCE sCmd sFunc SrcScript

MsgQ = rxqueue('Create','pppmsg')

say 'please wait...'

if PortN\=0 then do
  ComPorts.0 = 1
  ComPorts.1 = PortN
end

do i=1 to ComPorts.0
  j = ComPorts.i
  newqCOM.j = rxqueue('Create') /*,'com'j'log')*/
  '@start /c /min "Dialin COM'j'" 'SrcScript' --0 com'j' 'newqCOM.j' 'MsgQ
  call SysSleep 5
end

oq = rxqueue('Set',MsgQ)
do i=1 to ComPorts.0
  parse pull Line
  parse value Line with 'Started ('Port')'
  if translate(left(Port,3))='COM' then
  do
    j = substr(Port,4)
    if datatype(j,'N') then
    do
      '@start /min "COM'j' Log" 'SrcScript' --1 'Port' 'newqCOM.j' 'LogFile
      newqCOM.j = 'DONE'
    end
  end
  say Line
end
say 'done.'

signal halt
Exit


/* ------------------------------------------ */
/* |                 State                  | */
/* ------------------------------------------ */
State:

call GetState
do i = 1 to PortList.0
  say PortList.i
end

Exit


/* ------------------------------------------ */
/* |                 Shutdown               | */
/* ------------------------------------------ */
Shutdown:

if CmdLine='' then N = 0
else do
  parse upper value CmdLine with 'COM'N
  if \DataType(N,'N') | N<=0 then signal Help
end

call GetState

if N = 0 then do
  do j = 0 to 1
    do i = 1 to PortList.0
      parse value PortList.i with 'com'PortN': 'state' 'line
      if state = 'ON' then do
        if j = 0 then do
          call SysFileDelete(ETCPath'\ppp-com'PortN'\ppp.st')
          N = -1
        end
        else call ShutDownPort PortN,line
      end
    end
    if j = 0 & N \= -1 then do
      say 'Is PPPServ starting?'
      leave
    end
  end
end
else do
  do i = 1 to PortList.0
    parse value PortList.i with 'com'PortN': 'state' 'line
    if state = 'ON' & PortN = N then do
      call ShutDownPort PortN,line
      PortN = -1
      leave
    end
  end
  if PortN \= -1 then say 'PPPServ was not started on port COM'N
end

Exit

ShutDownPort: PROCEDURE EXPOSE ETCPath
  PortN = Arg(1)
  parse upper value Arg(2) with 'PPP'pppN' 'Line
  call charout '','Stoping the PPPServ on COM'PortN'..'
  FN = ETCPath'\ppp-com'PortN'\ppp.st'
  do 10
    Line = linein(FN)
    call stream FN, 'c', 'close'
    if Line \= 'stop' then do
      rc = SysFileDelete(FN)
      if rc=0 & pppN\='' then '@pppkill ppp'pppN' >nul'
    end
    else leave
    call SysSleep 1
    call charout '','.'
    if rc \= 0 then iterate
  end
  if Line = 'stop' then say ' done'
  else say ' error'
return


/* ------------------------------------------ */
/* |                 Hangup                 | */
/* ------------------------------------------ */
Hangup:

parse upper value CmdLine with 'COM'N
if \DataType(N,'N') | N<=0 then signal Help

call GetState

do i = 1 to PortList.0
  parse value PortList.i with 'com'PortN': 'state' ppp'pppN' 'line
  if PortN = N then do
    if state \= 'ON' then leave
    if \DataType(pppN,'N') then pppN = -2
    else do
      '@pppkill ppp'pppN
      pppN = -1
    end
    leave
  end
end
if pppN = -2 then say 'Port COM'N' is not online'
else if pppN \= -1 then say 'PPPServ was not be started on COM'N

Exit


/* ------------------------------------------ */
/* |                  Help                  | */
/* ------------------------------------------ */
Help:

say 'PPPServ {-R [COMn], -S [COMn], -V, -H COMn}'
say '  R - start PPP-server'
say '  S - stop server'
say '  V - read state'
say '  H - hangup connection'
Exit


/* ------------------------------------------ */

GetState: PROCEDURE EXPOSE PortList. ETCPath

rc = SysFileTree(ETCPath'\ppp-com*', 'list', 'DO', '*****')
j = 0
do i = 1 to list.0
  parse upper value filespec('name',list.i) with 'PPP-COM'N
  if \DataType(N,'N') then iterate

  L = 'com'N': '
  FName = list.i'\ppp.flg'
  rc = SysFileDelete(FName)
  if rc\=32 then L = L || 'OFF'
  else do
    FN = list.i'\ppp.st'
    L = L || 'ON 'linein(FN)
    call stream FN, 'c', 'close'
  end
  j = j+1
  PortList.j = L
end
PortList.0 = j

return


/***************************************************************/
/*                                                             */
/*                         Dialin Process                      */
/*                                                             */
/***************************************************************/
DialinProcess:
say '++++'
parse value CmdLine with ComPort ' ' QueueName ' ' MsgQ
say '('ComPort') ('QueueName') ('MsgQ')'

SystemETCPath = value('ETC',,'OS2ENVIRONMENT')
ETCPath = SystemETCPath'\PPP-'ComPort
rc = value('ETC',ETCPath,'OS2ENVIRONMENT')
PPPCfgFile = ETCPath'\ppp.cfg'
AuthFile = SystemETCPath'\ppp.usr'

oq = rxqueue('Set',MsgQ)

if lines(PPPCfgFile)=0 then 
do
  push ComPort': Can''t open file 'PPPCfgFile
  Exit
end

if lines(AuthFile)=0 then 
do
  push ComPort': Can''t open file 'AuthFile
  Exit
end
call stream AuthFile,'c','close'

ValidTimeCount = 0
i = 0
PortSpeed = '115200'
do while lines(PPPCfgFile)\=0
  i = i+1
  Line = translate(strip(linein(PPPCfgFile)))
  if left(Line,3)='COM' & datatype(substr(Line,4),'N') & Line\=translate(ComPort) then
  do
    push ComPort': Error in 'PPPCfgFile' at line 'i': must be "'ComPort'"'
    Exit
  end
  else if DataType(Line,'N') then
    PortSpeed = Line
  else if left(Line,2)='#$' then
    do
      parse value Line with Pref dow tfrom '-' tto
      ValidTime.ValidTimeCount.0 = strip(dow)
      ValidTime.ValidTimeCount.1 = tomin(tfrom)
      ValidTime.ValidTimeCount.2 = tomin(tto)
      if (ValidTime.ValidTimeCount.1=-1) | (ValidTime.ValidTimeCount.2=-1) then
        push ComPort': Error in 'PPPCfgFile' at line 'i
      else
        ValidTimeCount = ValidTimeCount+1
    end
end
call stream PPPCfgFile,'c','close'

rc = stream(ETCPath'\ppp.flg','c','open')
if rc = 'NOTREADY:32' then do
  push ComPort': File 'ETCPath'\ppp.flg opened, it seems PPPServ already running on this port.'
  Exit
end

ModeQ = rxqueue('Create','modemsg')
'@MODE 'ComPort': 'PortSpeed',N,8,1,TO=OFF,XON=OFF,OCTS=OFF,RTS=HS,DTR=ON,IDSR=ON,ODSR=ON 2>&1|RXQUEUE 'ModeQ
call rxqueue 'Set',ModeQ
parse pull 'SYS'N': 'ModeMsg
call rxqueue 'Set',MsgQ
call rxqueue 'Delete',ModeQ
if N \= '' then do
  push ComPort': 'ModeMsg
  Exit
end

FState = ETCPath'\ppp.st'
call SysFileDelete FState
call lineout FState, 'started'
call lineout FState

queue 'Started ('ComPort')'
call rxqueue 'Set',QueueName

call UpdateAuthFile
SleepTime = 0
TimeOut = 0
do while stream(FState,'c','QUERY EXISTS') \= ''
  if TimeOut > 0 then TimeOut = TimeOut-1
  else do
    '@slattach -p 'ComPort' -t 400 "ATZ" "OK" >nul'
    if rc\=0 then do
      queue '! SLATTACH faluture, rc='rc
      TimeOut = 12
    end
    else do
      NewSleepTime = TestValidTime()=0
      if NewSleepTime \= SleepTime then do
        SleepTime = NewSleepTime
        if SleepTime then do
          '@slattach -p 'ComPort' "ats0=0" "OK" >nul'
          queue '! waiting for the spare time'
        end
      end

      if \SleepTime then do
        queue '! waiting for the RING'
        call UpdateAuthFile
        '@ppp 2>&1|RXQUEUE 'QueueName
        iterate
      end
    end
  end
  call SysSleep 5
end

signal halt
Exit

/* ------------------------------------------ */

TestValidTime:
  if ValidTimeCount=0 then return 1
  dow = translate(left(date('W'),3))
  now = time('M')
  do i=0 to ValidTimeCount-1
    if ((ValidTime.i.0='ANY') | (dow=ValidTime.i.0)) & (now>=ValidTime.i.1) & (now<ValidTime.i.2)
      then return 1
  end
return 0

UpdateAuthFile:
  rc = SysFileTree(AuthFile, 'list', 'FT', '*****') 
  NewSecFileTime = word(list.1,1)

  if NewSecFileTime\=SecFileTime then
  do
    '@copy 'AuthFile' 'ETCPath'\pap.sct >nul'
    '@copy 'AuthFile' 'ETCPath'\chap.sct >nul'
    SecFileTime = NewSecFileTime
  end
return



/***************************************************************/
/*                                                             */
/*                        Logging Process                      */
/*                                                             */
/***************************************************************/
LogProcess:

parse value CmdLine with ComPort QueueName LogFile

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

OnLine = 0
Timer = 0
Pref = ''

ETCPath = value('ETC',,'OS2ENVIRONMENT')
ValidTimeFile = ETCPath'\ppp-time.cfg'
i = 0
InRule = 0

oq = rxqueue('Set',QueueName)
do forever
  do while queued()=0
    call SysSleep 1
    if OnLine then
    do
      if (i // 10 = 0) then
        if TestValidUserTime()=0 then
        do
          say 'Time access deny'
          '@pppkill 'PPPNow
        end
      i = i+1
    end
  end

  parse pull Line
  i = 0

  if left(Line,2) = '! ' then 
  do
    call FixState SubStr(Line,3)
    if Line = '! stop' then do
      do 3
        if rxqueue("Delete",QueueName)=10 then call SysSleep 1 
        else leave
      end
      leave
    end
  end
  else if left(Line,7) = 'CONNECT' then StateLine = PPPNow' 'Line
  else if (Line = 'Exiting...' | Line='info   : Terminating link.') & OnLine then
    Action = 'lcp_down'
  else parse value Line with 'notice : 'Action': 'pLine
  
  if OnLine then Pref = '│'; else Pref = ''

  select
    when Action = 'Linking' then do
      parse value pLine with PPPNow' <--> 'PortNow
      call GetStat PPPNow
    end
    when Action = 'ipcp_up' then do
      parse value pLine with Point' IP address 'HostIPAddr
      if Point = 'local' then do
        ServAddr = HostIPAddr
        StateLine = StateLine' 'ServAddr
        Pref = '┌'
      end
      else if Point = 'remote' then do
        OnLine = 1
        Addr = Time('R')
        Addr = HostIPAddr
        call FixState StateLine':'Addr
/*        'route add -host 'Addr' 'ServAddr*/
        '@route change -host 'Addr' 'ServAddr
        '@ipgate on'

         /* read time-list */
        ValidTimeCount = 0
        do while lines(ValidTimeFile)\=0
          i = i+1
          Line1 = space(linein(ValidTimeFile))
          if (Left(Line1,1)\='#') & (Line1\='') then 
          do
            parse upper value Line1 with rule Port ip ':' dow tfrom '-' tto
            if (Port='ANY') | (Port=ComPort) then
            do
              ValidTime.ValidTimeCount.0 = strip(ip)
              ValidTime.ValidTimeCount.1 = strip(dow)
              ValidTime.ValidTimeCount.2 = tomin(tfrom)
              ValidTime.ValidTimeCount.3 = tomin(tto)
              if rule='ALLOW' then ValidTime.ValidTimeCount.4 = 1
              else if rule='DENY' then ValidTime.ValidTimeCount.4 = 0
              else do
                say 'Error in 'ValidTimeFile'at line 'i': rule type must be ALLOW or DENY'
                iterate
              end
              if (ValidTime.ValidTimeCount.2=-1) | (ValidTime.ValidTimeCount.3=-1)
              then say 'Error in 'ValidTimeFile' at line 'i
              else ValidTimeCount = ValidTimeCount+1
            end
          end
        end
        call stream ValidTimeFile,'c','close'
      end
    end
    when Action = 'lcp_down' then do
      OnLine=0
      Timer = Time('E')
      Pref = Pos('.',Timer)
      if Pref=0 then Timer = 0
        else Timer = SubStr(Timer,1,Pref-1)
      Pref = '└'
      WasBytesReceived = BytesReceived
      WasBytesSent = BytesSent
      call GetStat PPPNow
      BytesReceived = BytesReceived - WasBytesReceived
      BytesSent = BytesSent - WasBytesSent 
    end
    otherwise
  end

  if left(Line,23)\='error  : [NETW] Invalid' then say Pref''Line

  if Timer\=0 then
  do
    say '> Time online ('Addr'): ' SecToTime(Timer)
    say 'Bytes received: 'BytesReceived
    say 'Bytes sent: 'BytesSent
    say
    call AddTime Addr,Timer
    Timer = 0
  end
end

Exit


/* ---------------------------------------------- */

TimeToSec:
  parse value Arg(1) with HH ':' MM ':' SS
return HH*60*60+MM*60+SS

SecToTime:
  Sec = Space(Arg(1))
  if Sec='' then return '0:00:00' 
  else do
    HH = Sec%(60*60)
    Sec = Sec//(60*60) 
    MM = Sec%60
    SS = Sec//60
    if MM<10 then MM = '0'MM
    if SS<10 then SS = '0'SS
  end
return HH':'MM':'SS

AddTime:
  do i=1 by 1 while lines(LogFile)\=0
    Line.i = linein(LogFile)
  end
  Line.0 = i-1
  call stream LogFile,'c','close'
  AddTime = Arg(2)
  Addr = Arg(1)
  NewTime = -1
  do i=1 to Line.0
    if word(Line.i,1) = Arg(1) then
    do
      NewTime = TimeToSec(word(Line.i,2))
      NewTime = SecToTime(NewTime+AddTime)
      NewBytesReceived = word(Line.i,5)+BytesReceived
      NewBytesSent = word(Line.i,6)+BytesSent
      Line.i = Addr' 'NewTime' 'Date('E')' 'Time()' 'NewBytesReceived' 'NewBytesSent
      leave
    end
  end
  if NewTime=-1 then
  do
    Line.i = Addr' 'SecToTime(AddTime)' 'Date('E')' 'Time()' 'BytesReceived' 'BytesSent
    Line.0 = i
  end
  call SysFileDelete LogFile
  do i=1 to Line.0
    call lineout LogFile, Line.i
  end
  call stream LogFile,'c','close'
return


GetStat:
  PPPInf = Arg(1)
  NetStatPPPStr = 'Serial Interface'

  netstatq = rxqueue('Create')
  saveq = rxqueue('Set',netstatq)
  S = translate(NetStatPPPStr' 'PPPInf)
  '@netstat -n |RXQUEUE 'netstatq
  do while queued()>0
    parse upper pull StatLine

    if translate(SubWord(StatLine,3)) = S then 
    do
      BytesReceived = ReadData('total bytes received','всего байтов получено',4)
      BytesSent = ReadData('total bytes sent ','всего байтов послано ',4)
      leave
    end
  end
  S = rxqueue('Set',saveq)
  S = rxqueue('Delete',netstatq)
return

ReadData:
  Se = translate(Arg(1))
  Sr = translate(Arg(2))
  do while queued()>0
    parse upper pull DataLine
    S = SubStr(DataLine,1,length(S))
    if (S=Se) | (S=Sr) then 
      return SubWord(DataLine,Arg(3))
  end
return -1

TestValidUserTime:
  if ValidTimeCount=0 then return 1
  dow = translate(left(date('W'),3))
  now = time('M')
  do i=0 to ValidTimeCount-1
    if ((ValidTime.i.0='ANY') | (Addr=ValidTime.i.0)) & ((ValidTime.i.1='ANY') | (dow=ValidTime.i.1)) & (now>=ValidTime.i.2) & (now<ValidTime.i.3) then
      return ValidTime.i.4
  end
return 0

FixState:
  FN = ETCPath'\ppp-'ComPort'\ppp.st'
  call stream FN,'c','open write'
  call stream FN,'c','seek 1'
  call lineout FN, Arg(1)
  call stream FN,'c','close'
return




/***************************************************************/

tomin:
  parse value strip(Arg(1)) with HH ':' MM
  if DataType(HH,'N') & DataType(MM,'N') then return (MM+(HH*60))
  else return -1
return


halt:

select
  when Cmd='R' then do
    /* Delete queues for sessions with errors (without "COMn Log" sessions) */
    do i=1 to ComPorts.0
      j = ComPorts.i
      if newqCOM.j \= 'DONE' then call rxqueue "Delete",newqCOM.j
    end
    call rxqueue 'Set',oq
    call rxqueue "Delete",MsgQ
  end
  when Cmd='-0' then do
    push '! stop'
    rc = stream(ETCPath'\ppp.flg','c','close')
  end
end
EXIT