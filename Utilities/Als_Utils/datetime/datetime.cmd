/* Update local Date and Time from a remote time server using DayTime syntax */
parse arg nServers servers '!' opts

/* define the default time servers
      (list from http://tf.nist.gov/tf-cgi/servers.cgi# )        */
servers.1 = 'time.nist.gov'                       /* default global address */
servers.2 = 'time-a.nist.gov'
servers.3 = 'time-b.nist.gov'
servers.4 = 'time-c.nist.gov'
servers.5 = 'time-d.nist.gov'
servers.6 = 'time-a-wwv.nist.gov'
servers.7 = 'time-b-wwv.nist.gov'
servers.8 = 'time-c-wwv.nist.gov'
servers.9 = 'time-d-wwv.nist.gov'
servers.10 = 'time-a-b.nist.gov'
servers.11 = 'time-b-b.nist.gov'
servers.12 = 'time-c-b.nist.gov'
servers.13 = 'time-d-b.nist.gov'
servers.14 = 'utcnist.colorado.edu'
servers.15 = 'utcnist2.colorado.edu'

servers.0 = 15

defPort = 13    /* default DayTime protocol port */

if nServers = '?' | nServers = '-?' then do
   parse source . . us .
   exname = filespec('name',us)
   lDot = lastpos('.',exname)
   exname = left(exname,lDot-1)
   say 'Help for' us
   say ''
   say '  By default, this exec queries one server at random from a pool of servers,'
   say '  and if the local differs by more than 1 second, synchronizes the local time.'
   say '  This exec queries a daytime server on port' defPort
   say ''
   say '  1st variation on the operation is to specify a number of servers to query'
   say '  and take the average of the current time reported.'
   say '  For example: "' exname '3"  would average the returns of 3 different servers.'
   say ''
   say '  2nd variation on the operation accepts a user supplied list of servers.'
   say '  For example:"' exname '2 server1 server2 server3" would query 2 servers'
   say '  at random from the list of three servers specified.'
   say '  A server specification is the host name and optional port (if not' defPort ').'
   say '  An example of specifying a specific server: "time.nist.gov:13"'
   say ''
   say '  To just query the remote time without setting it, use the "!NOSET" option.'
   say '  For example "'||exname '!NOSET"  or "'||exname '2 !NOSET" to query 2 servers'
   exit 100
end

/* a specific server to query? */
if left(nServers,1) = '#' then do
   parse var nServers . '#' theServer .
   nServers = 1                          /* we will query only this one server */
end

/* if just a list of servers was passed in without specifying how many to query */
if nServers = '' | datatype(nServers) <> 'NUM' then do
   if servers \= ''
      then parse arg servers '!'        /* reparse to get the full list */
   nServers = 1     /* how many servers to query is assumed to be ONE */
end

/* when a list of specific servers was provided */
if servers \= '' then do
   /* use that list instead of our default list */
   servers.0 = words(servers)
   do n = 1 to servers.0
      servers.n = word(servers,n)
   end
end

/* Parse the TZ variable from the Environment to see how to proceed */
tz = value('TZ',,'OS2ENVIRONMENT')
parse var tz std ',' override
st = left(std,3)
offset = substr(std||'    ',4,1) * 60 * 60   /* number of seconds to offset from UTC */
dt = substr(std||'    ',5,3)
if override = '' then override = '4,1,0,7200,10,4,0,7200,3600'
parse var override sm ',' sw ',' sd ',' ssec ',' em ',' ew ',' ed ',' esec ',' adj .

/* set up Leap Year calculations */
lYear = substr(date('S'),1,4)
daysInMonth = '31 28 31 30 31 30 31 31 30 31 30 31'
if lYear // 4 = 0 & (right(lYear,2) \= '00' | lYear // 400 = 0)
   then daysInMonth = '31 29 31 30 31 30 31 31 30 31 30 31'

/* determine what day of the week today is */
days = 'SUN MON TUE WED THU FRI SAT'
today = date('USA')
weekday = date('Weekday')
if pos('?',opts) > 0 then do
   say 'Testing the week start algorithm.   This is not normal operation!'
   say 'what date and day'
   pull today weekday
end

/* determine what day of the week it is today */
dayOfWeek = wordpos(substr(translate(weekday),1,3),days) - 1

/* compute when this week ends, so we know what week it is */
parse var today mm '/' dd '/' yy

/* compute what day of the week is the 1st of the month */
monthStart = dayOfWeek
do first = dd-1 to 1 by -1
   monthStart = monthStart - 1
   if monthStart < 0 then monthStart = monthStart + 7
end

/* determine how many seconds past midnight it is for TODAY */
now = time('Minutes') * 60

/* assume no adjustment for daylight savings time */
dstAdjust = 0
if mm = sm then do                               /* compute when DST starts */
   dstStart = (sw * 7) + sd - monthStart + 1
   if monthStart = 0 then dstStart = dstStart - 7
   say 'DST Starts' mm||'/'dstStart
   if dd > dstStart | (dd = dstStart & now >= ssec) /* past that date & time in the month */
      then dstAdjust = adj            /* adjust the time zone offset for daylight saving time */
end
else if mm = em then do                          /* or when DST ends */
   dstEnd = (ew * 7) + ed - monthStart + 1
   if monthStart = 0 then dstEnd = dstEnd - 7
   say 'DST Ends' mm||'/'dstEnd
   if dd < dstEnd | (dd = dstEnd & now < esec)  /* before when it ends in the month */
      then dstAdjust = adj            /* adjust the time zone offset for daylight saving time */
end
else if mm > sm & mm < em then do                /* or if it is even in effect */
   say 'DST is in effect'
   dstAdjust = adj            /* adjust the time zone offset for daylight saving time */
end
else do
   say 'DST is NOT in effect'
end

if dstAdjust \= 0 & opts \= ''
   then say 'Adjusting for daylight savings time by' dstAdjust 'seconds'

if RxFuncQuery("SysLoadFuncs") then do
   call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
   call SysLoadFuncs
end
OSVer = SysOS2Ver()

if RxFuncQuery("SockLoadFuncs") then do
  rc=RxFuncAdd("SockLoadFuncs","rxSock","SockLoadFuncs")
  rc=SockLoadFuncs()
end

/* track the servers we've tried to contact */
do n = 1 to nServers
   tried.n = 'No'
end

/* Prepare to randomly pick some servers to query */
seed = date('days') * time('seconds')
halfSeed = trunc((length(seed)/2)+.5)
seed = left(seed,halfSeed) + right(seed,halfSeed)
s = random(1, servers.0, seed)
s = 1 /* however, first try the master server 'time.nist.gov' */

if datatype(theServer) = 'NUM' & theServer < servers.0
   then s = theServer

attempt = 0
serversContacted = 0
do n = 1 to nServers while attempt < servers.0
   /* give us a safety valve out of the loop */
   attempt = attempt + 1

   /* don't contact the same server more than once */
   if tried.s = 'Yes' then n = n - 1
   else do

      say 'Try #'||n||'. Attempting connect to server index' s 'of' servers.0 'servers =' servers.s

      /* get the server's TCP/IP information */
      tried.s = 'Yes'
      parse var servers.s host':'port .
      if port = '' then port = defPort
      family  ='AF_INET'

      /* query that server for the current time and date (to the second) */
      parse value getTime() with e lt ld '|' . d t . . . . rtz .

      /* if there wasn't an error contacting the server */
      if e >= 0 & lt <> '<timeout>' & d <> '' & t <> '' then do
         /* put the local date into equivalent form */
         lYear = substr(ld,1,4)
         lMonth = substr(ld,5,2)
         lDay = substr(ld,7,2)
         localDate = lMonth||'-'||lDay||'-'||lYear

         /* display the time information we got back */
         serversContacted = serversContacted + 1
         latencyAdjust = trunc((e / 2) + .5)
         say 'Contacted' host '          roundtrip delay:' e
         say 'Local:' substr(lYear,3,2)||'-'||lMonth||'-'||lDay lt
         say 'Remote:' d t rtz 'using a latency of' latencyAdjust 'seconds.'

         /* parse the local and remote times */
         parse var lt lh ':' lm ':' ls .
         parse var t  rh ':' rm ':' rs .

         /* convert the local time (of when the request was processed) to seconds */
         localTime = ls + (60*lm) + (3600*lh) - latencyAdjust

         /* the correct date is always from the server */
         parse var d y '-' m '-' d .

         /* adjust the server's UTC time to local time */
         correctTime = rs + (60*rm) + (3600*rh) - offset + dstAdjust
         if correctTime < 0 then do
            /* acount for midnight adjustment ... i.e. its the previous day */
            correctTime = correctTime + (24 * 60 * 60)
            d = d - 1
            if d < 1 then do
               m = m - 1
               d = word(daysInMonth,m)
               if m < 1 then do
                  m = m + 12
                  y = y - 1
               end
            end
         end
         correctDate = right('0'||m,2)||'-'||right('0'||d,2)||'-20'||right('0'||y,2)

         difference.n = localTime - correctTime
         say 'Clock drift' difference.n 'seconds'

      end
      else do
         say 'Could not contact' host
         n = n - 1
      end
   end

   s = random(1, servers.0)
end

avgDiff = 0
rspServers = 0          /* responding servers */
do n = 1 to nServers
   if datatype(difference.n) = 'NUM' then do
      avgDiff = avgDiff + difference.n
      rspServers = rspServers + 1
   end
end
if rspServers > 0
   then avgDiff = avgDiff / rspServers

how = ''
if avgDiff < 0
   then how = '(slow)'
   else if avgDiff > 0
      then how = '(fast)'
say 'Average clock drift across' rspServers 'servers is about' abs(avgDiff) 'seconds' how

/* if the clock has drifted */
if abs(avgDiff) >= 1 & pos('NOSET',translate(opts)) = 0 then do
   /* and the date is acceptable or we weren't told to abort when way out */
   if localDate = correctDate | pos('NODATE',translate(opts)) = 0 then do

      /* adjust the local clock based on the average descrepancy */
      parse value time('N') with hh ':' mm ':' sec .
      sec = sec - trunc(avgDiff)

      /* account for the seconds wrapping */
      do while sec >= 60
         sec = sec - 60
         mm = mm + 1
         if mm >= 60 then do
            mm = mm - 60
            hh = hh + 1
            if hh >= 24 then do
               say 'Too close to midnight to change the clock.  Ignoring!'
               exit
            end
         end
      end
      do while sec < 0
         sec = sec + 60
         mm = mm - 1
         if mm < 0 then do
            mm = mm + 60
            hh = hh - 1
            if hh < 0 then do
               say 'Too close to midnight to change the clock.  Ignoring!'
               exit
            end
         end
      end

      /* format the time string and set the correct information */
      tm = hh||':'||mm||':'||sec
      '@time' tm
      if pos('NODATE',translate(opts)) = 0 then '@date' correctDate
      say 'Local date/time is now' date() time()
   end
   else do
      say 'No adjustment made because dates vary too much.'
      say '   Local:' localDate 'vs Remote:' d
   end
end
else if rspServers = 0
   then say 'No servers could be contacted'

exit

getTime:
  if opts \= '' then say 'Attempting to contact' host

  rc=sockgethostbyname(host, "serv.0")  /* get dotaddress of server */
  if rc \= 1 then return -1
  dotserver=serv.0addr                  /* .. */

  gosaddr.0family=family                /* set up address */
  gosaddr.0port  =port
  gosaddr.0addr  =dotserver

  gosock = SockSocket(family, "SOCK_STREAM", "IPPROTO_TCP")
  rc = SockSetSockOpt(gosock,"SOL_SOCKET","SOC_RCVTIMEO",1)
  rc = SockSetSockOpt(gosock,"SOL_SOCKET","SOC_SNDTIMEO",1)

  response = ''
  call time 'r'
  rc = SockConnect(gosock,"gosaddr.0")
  if rc = 0 then do
     conn = time('e')
     localClock = time('N') date('S') '|'
     /* our socket should be ready to read the response */
     rr.0 = 1
     rr.1 = gosock
     rc = SockSelect("rr.",,,1)
     if rc \= 1 | rr.1 \= gosock
        then localClock = '<timeout>'
        else rc = SockRecv(gosock, "response", 200)
     response = localClock response
  end
  else conn = -1

  close_rc = SockClose(gosock)

return conn response
