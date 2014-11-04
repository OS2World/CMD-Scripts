/* */
/**************************************
jjs - 2000-07-14  - to check for net3101
     errors which have been causing 
     TCPBeui to die.  If error found
     this will collect and log data and 
     stop/start SRV.  Then it will page.

     There is a line for
     a fireworx call to a network trace
wrm  - 2000-12-13  added netstat
jjs - 2001-5-7 - added checking for logon and doing admnlgon
jjs - 2001-5-8 - removed netstat -s because it causes traps in WarpSrv
jjs - 2001-5-8 - Added section (when net3101 occurs) to find sessions that 
            meet the criteria for causing net3101, then delete those session 
            unless they have open files , then EzPage the lists.
jjs - 2001-5-10 - Sendmail's the SuspectList.txt to RCHPCLAN
jjs - 2001-5-18 - comment out the net stop/start srv section
jjs - 2001-8-1 - change to use Bills NETSESS.cmd 
***************************************/
thedate=date('s')
thetime=time('c')
thetimeDot=TRANSLATE(THETIME,'.',':')

hour=left(time(),2)
day=translate(left(date('w'),3))

say thedate right(thetime,8) day hour

'd:'
'cd \net3101'
'@if not exist d:\net3101\Logs md d:\net3101\Logs'

'@rxqueue /clear'

'net error /r | rxqueue'
found='NO'
do queued()
  pull data
  if pos('NET3101',data)<>0 then do
     found='YES'
     'whoami'
     if rc=5 then 'call admnlgon'
     end
  end

if found='NO' then do
  say 'No net3101 errors were found.'
  end

if found='YES' then do
   'md Logs\'||thedate
   '@echo '||thedate||' '||right(thetime,8)||' '||day||' >> net3101.log'
   'call net error /r > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.err'
   'call net error /d'
   'call d:\net3101\netsess \\%hostname% > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.sess'
/*   'call net sess > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.sess' */
   'call net file > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.file'

/***** Start of NEW DELETE SECTION ********/
   '@echo Subject: Net3101 on %hostname% 'date('s')' 'time()' >> Logs\'||thedate||'\SuspectList.txt'
   '@rxqueue /clear'
/*   'call net sess | find /i " 00:0" | find /i "                         OS/2 LS 3.0" | find /i "  0  " | rxqueue' */
   'call net sess | find /i " 00:0" | find /i "                         OS/2 LS 3.0" | rxqueue'
   s=0
   do queued()
     pull data
     if data<>'' then do
        s=s+1
        pcdata.s=data
        pcname.s=strip(word(data,1))
       '@echo 'date('s')' 'left(time(),5)' 'pcdata.s'  >> Logs\'||thedate||'\SuspectList.txt'
        end 
     end /* queued */
    totalS=s
    s=0
    d=0
    n=0
    NoDelete=''
    DeleteNames=''
    do totalS
      s=s+1
      if pos("  0  ",pcdata.s)<>0 then do
        d=d+1
        DeleteNames=DeleteNames' 'strip(pcname.s,L,'\')
        '@echo 'date('s')' 'left(time(),5)' 'pcdata.s'  >> Logs\'||thedate||'\DeleteList.txt'
        'call net sess 'pcname.s' /delete'
        end
      else do
        n=n+1
        NoDelete=NoDelete' 'strip(pcname.s,L,'\')
        '@echo 'date('s')' 'left(time(),5)' 'pcdata.s'  >> Logs\'||thedate||'\NoDeleteList.txt'
        end
      end /* totalS */
   call lineout 'Logs\'||thedate||'\SuspectList.txt'
   if DeleteNames<>'' then 'call ezpage pcserver Net3101 problem Deleted 'deletenames
   if NoDelete<>'' then 'call ezpage pcserver Net3101 problem Did NOT Delete 'nodelete
   if DeleteNames='' & NoDelete='' then 'call ezpage pcserver Net3101 problem - no sessions meet criteria to delete.'
   'call sendmail -af Logs\'||thedate||'\SuspectList.txt -f %hostname%@%hostname% rchpclan@ibmusm07'

/*****   End of NEW DELETE SECTION ********/

   'call net audit /r > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.aud'
/*   'call netstat -s   > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.nstat' */
   'call net audit /d'



/****** commented out since the session Delete section is probably cleaning up problem **********
/*   'call csreq RCHD1754.DATAGLANCE 15 dgstop' */

   if day<>'SAT' & day<>'SUN' then do
     if hour<7 | hour>=17 then do
       'start /c ezpage pcserver NET3101 -Fixing with stop/start SRV'
     /*   'start /c ezpage bmarsh NET3101 -Please Check if TCPB. restarting.'  */
     /*   'start /c ezpage cstein NET3101 -Please Check dataglance.'           */
     /* 'start /c ezpage joes NET3101 -Fixing with stop/start SRV'             */
       'call net stop srv /y'
       'call net start srv'
       '@rxqueue /clear'
       'type c:\ibmlan\ibmlan.ini | find /i "computername" | find /i /v ";" | rxqueue'
       compname=''
       do queued()
         pull compname
         if right(strip(data),2)='HD' then
           'start sharehd'
         end
       end
     else do
       'start /c ezpage pcserver NET3101 -Please Check if TCPB is dead.'
      /*  'start /c ezpage bmarsh NET3101 -Please Check if TCPB is dead.'      */
       end
     end
   if day='SAT' | day='SUN' then do
     'start /c ezpage pcserver NET3101 -Fixing with stop/start SRV'
     /*   'start /c ezpage bmarsh NET3101 -Please Check if TCPB. restarting.' */
     /* 'start /c ezpage joes NET3101 -Fixing with stop/start SRV'            */
     'call net stop srv /y'
     'call net start srv'
     '@rxqueue /clear'
     'type c:\ibmlan\ibmlan.ini | find /i "computername" | find /i /v ";" | rxqueue'
     compname=''
     do queued()
       pull compname
       if right(strip(data),2)='HD' then
         'start sharehd'
       end
     end

****** commented out since the session Delete section is probably cleaning up problem **********/
   end /* Found net3101 */


EXIT
