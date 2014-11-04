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
   'call net sess > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.sess'
   'call net file > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.file'
   'call net audit /r > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.aud'
/*   'call netstat -s   > Logs\'||thedate||'\'||thedate||'.'||thetimeDot||'.nstat' */
   'call net audit /d'

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
   end


EXIT
