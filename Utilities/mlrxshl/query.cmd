/* query.cmd - compute connect time                          20050825 */
/* (C) Copyright Martin Lafaix 1995-2005.  All rights reserved.       */

/* Recognized command line args

   query Date
   query Time
   query [timeframe] [DETAILED] CONNECT TIME [FOR ...]
   query [timeframe] [AVERAGE] DAILY CONNECT TIME [FOR ...]
   query [timeframe] [LAST] CONNECT MESSAGE [FOR ...]
   query [timeframe] MAIL [FOR name] [FROM ...] [IN foldername] [WHERE condition]
   query [Last] NEWS [Refresh]
   query DISK [unit]
   query PICTure DIMension FOR ...
   query OS [Version]
   query [component] Version
   query SYStem (DEVices|DRIVERS|IRQs|MEMory)
   query PROCess ID
   query DIRector(y|ies) STACK
   query [LAST] NEWS [REFRESH]

   timeframe  == [THIS|LAST] (YEAR|MONTH|monthname)['S]
   monthname  == JANuary | FEBruary | MARch | APRil | MAY | JUNe | JULy |
                 AUGust | SEPtember | OCTober | NOVember | DECember
   foldername == name | "name" | * | foldername, foldername
   condition  == element operator value [(OR|AND) condition]
   element    == FROM | TO | SUBJECT | SENDER [['S] DOMAIN]
   operator   == CONTAINS | = | == | > | < | \= | <>
   unit       == * | letter[:] | unit unit
   component  == REXX | JAVA | OS

   examples

   query connect time
   query this year connect time for user1
   query detailed november connect time for user1 user2
   query last connect message
   query mail for user1 in in-basket where subject contains "PAGING"
   query disk
   query disk e f
   query os version
*/

if RxFuncQuery("SysLoadFuncs") then
   do
   call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
   call SysLoadFuncs
   end

arg user_arg
parse arg request

select
   when abbrev('DATE', user_arg, 1) then
      say date()
   when abbrev('TIME', user_arg, 1) then
      say time()
   when wordpos('CONNECT',user_arg) > 0 then
      say connect()
   when wordpos('MAIL', user_arg) > 0 then
      say mail()
   when wordpos('DISK', user_arg) > 0 then
      say disk()
   when wordpos('NEWS', user_arg) > 0 then
      say news()
   when abbrev('PICTURE', word(user_arg,1), 4) then
      say picture()
   when abbrev('SYSTEM',word(user_arg,1),3) & words(user_arg) = 2 then
      select
         when word(user_arg,2) = 'DRIVERS' then
            say drivers()
         when abbrev('DEVICES',word(user_arg,2),3) then
            '@rmview /hw'
         when abbrev('MEMORY',word(user_arg,2),3) then
            say memory()
         when abbrev('IRQS',word(user_arg,2),3) then
            say irqs()
         when word(user_arg,1) = 'OS' then
            if abbrev('VERSION',word(user_arg,2),1) then
               '@ver /r'
            else
               '@ver'
      otherwise
         say 'Unknown request:' request
      end
   when abbrev('VERSION',word(user_arg,2),1) & words(user_arg) = 2 then
      say version()
   when abbrev('PROCESS',word(user_arg,1),4) & word(user_arg,2) = 'ID' & words(user_arg) = 2 then
      say DosGetInfoBlocks('PID TID')
   when wordpos('STACK', user_arg) > 0 then
      say dirstack()
   when value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' & wordpos(user_arg,value('HELP.SWITCHES',,'OS2ENVIRONMENT')) > 0 then
      'call %HELP.COMMAND% QUERY' user_arg
otherwise
   say 'Unknown request:' request
end  /* select */

exit


/* query ... CONNECT ... */
connect:
   disconnect = 'D‚connexion aprŠs' /* 'Disconnected after' */
   monthname = '\JANUARY  \FEBRUARY \MARCH    \APRIL    \MAY      \JUNE     '||,
               '\JULY     \AUGUST   \SEPTEMBER\OCTOBER  \NOVEMBER \DECEMBER'
   detailed = wordpos('DETAILED',user_arg) > 0
   daily = wordpos('DAILY',user_arg) > 0
   average = wordpos('AVERAGE',user_arg) > 0
   currentDate = ''
   currentTime = 0
   msg = wordpos('MESSAGE',user_arg)+wordpos('MESSAGES',user_arg) > 0
   this = wordpos('THIS',user_arg) > 0
   last = wordpos('LAST',user_arg) > 0
   user = wordpos('FOR',user_arg) > 0
   mm = wordpos('MONTH',user_arg)+wordpos('MONTH''S',user_arg) > 0
   yy = wordpos('YEAR',user_arg)+wordpos('YEAR''S',user_arg) > 0
   m = 0
   do i = 1 to words(user_arg)
      w = pos('\'word(user_arg,i),monthname)
      if w > 0 then
         if abbrev(substr(monthname,w+1,9),word(user_arg,i),3) = 1 then
            if m \= 0 then
               return 'Incorrect request:' request
            else
               m = 1 + w % 10
   end /* do */

   count = \user
   if user then
      userlist = substr(request,wordindex(user_arg,wordpos('FOR',user_arg))+4)

   if this & last | mm & yy | mm & (m > 0) | daily & msg | average & msg then
      return 'Incorrect request:' request

   log = value('ETC',,'OS2ENVIRONMENT')'\Connect.log'
   time = 0
   parse value date('S') with year 5 month 7 .
   if last & mm then month = month-1
   if last & yy then year = year-1
   if yy then month = ''
   if m \= 0 then month = m
   yymm = year'/'right(month,2,0)

   message = ''
   curLine = 1
   do while lines(log) \= 0
      line = linein(log); curLine = curLine+1
      if substr(line,21,1) = 'Ä' then beginning = curLine
      if count & msg & curLine > beginning+2 & substr(line,21,length(disconnect)) <> disconnect then
         if last & curLine = beginning+3 then
            message = line
         else
            message = message || copies('0d0a'x,1+(curLine = beginning+3)) || line
      else
      if word(line,5) = 'dialed' then do
         if user then
            count = wordpos(word(line,4),userlist) > 0
         dialed = left(line,length(yymm))
         end
      else
      if count & substr(line,21,length(disconnect)) = disconnect then
         select
            when yymm = dialed & left(line,length(yymm)) = yymm then
               time = time + seconds(word(line,5), line)
            when dialed < yymm & left(line,length(yymm)) = yymm then
               time = time + seconds(substr(line,12,8), line)
            when yymm = dialed then
               time = time + seconds(word(line,5), line) - seconds(substr(line,12,8), line)
         otherwise
         end  /* select */
   end

   call stream log, 'c', 'close'

   if daily & currentTime \= 0 then
      say currentDate (currentTime % 3600)':' || right((currentTime // 3600) % 60,2,0)':' || right(time // 60,2,0)

   if msg then
      return message
   else
   if daily & average then do
      time = time % right(date('S'),2)
      return year'/'right(month,2,0) 'Average daily connect time' (time % 3600)':' || right((time // 3600) % 60,2,0) || ':' || right(time // 60,2,0)
      end
   else
   if yy then
      return year 'Yearly connect time' (time % 3600)':' || right((time // 3600) % 60,2,0) || ':' || right(time // 60,2,0)
   else
      return year'/'right(month,2,0) 'Monthly connect time' (time % 3600)':' || right((time // 3600) % 60,2,0) || ':' || right(time // 60,2,0)

seconds:
   parse value arg(1) with h ':' m ':' s
   if detailed then say word(arg(2),1) arg(1)
   else
   if daily then do
      if currentDate = word(arg(2), 1) then
         currentTime = currentTime + max(35, s + 60 * m + 3600 * h)
      else do
         if currentDate \= '' then
            say currentDate (currentTime % 3600)':' || right((currentTime // 3600) % 60,2,0)':' || right(time // 60,2,0)
         currentDate = word(arg(2), 1)
         currentTime = max(35, s + 60 * m + 3600 * h)
         end
      end
   return max(35, s + 60 * m + 3600 * h)


/* query [timeframe] MAIL [FOR name] [FROM ...] [IN foldername] [WHERE condition] */
mail:
   NUMERIC DIGITS 10

   MAIL.checkfor = wordpos('FOR', user_arg) \= 0
   MAIL.checkfrom = wordpos('FROM', user_arg) \= 0
   MAIL.checkin = wordpos('IN', user_arg) \= 0
   MAIL.checkwhere = wordpos('WHERE', user_arg) \= 0

   umpath = SysSearchPath('PATH', 'umail.exe')
   if umpath = '' then
      return 'Ultimedia Mail/Lite not found!'
   umpath = left(umpath,lastpos('\', umpath))'MailStor'
   olddir = directory()

   if MAIL.checkfor then do
      parse var user_arg . ' FOR ' user .
      umpath = umpath'\'user
      end
   else do
      call SysFileTree umpath'\*', 'users', 'DO'
      if users.0 \= 1 then
         return 'More than one mailbox available!  Please specify one.'
      umpath = users.1
      end

   if directory(umpath) = '' then
      return 'Mailbox not found!'

   if MAIL.checkfrom then do
      parse var user_arg . ' FROM ' who ' WHERE ' .
      parse var who who ' IN ' .
      MAIL.from_who = '00'x||translate(space(strip(who),0),'00'x,',')'00'x
      end

   if MAIL.checkin then do
      parse var user_arg . ' IN ' in ' WHERE ' .
      parse var in in ' FROM ' .
      MAIL.in_what = '00'x||translate(space(strip(in),0),'00'x,',')'00'x
      end

   if MAIL.checkwhere then do
      parse var user_arg . ' WHERE ' where
      MAIL.where_what = where
      end

   call explore

   call directory olddir

   return 'Done!'

explore:
   procedure expose MAIL.

   infile = directory()'\UMAIL.NDX'
   call stream infile,'c','open read'
   do while chars(infile) > 0
      call charin infile,,6
      size = x2d(c2x(charin(infile,,2)))
      data = charin(infile,,size)
      type = x2d(c2x(substr(data,9,2)))
      select
         when type = 0    then nop /* call charout ,'Letter ' */
         when type = 1    then nop /* call charout ,'Folder ' */
         when type = 16   then nop /* call charout ,'In-Box ' */
         when type = 3840 then call charout ,'A-Book '
      otherwise
         call charout ,'['type'] '
      end  /* select */
      call display
   end /* do */
   call stream infile,'c','close'

   return

display:
   procedure expose data type MAIL.
   select
      when type = 0 & MAIL.checkfrom & substr(data,12,1) = '04'x then nop
      when type = 0 then do
         parse value substr(data,88) with header '00'x file1 '00'x from '00'x to '00'x subject '00'x sender '00'x domain '00'x
         if (\ MAIL.checkfrom | pos('00'x||space(translate(sender),0)'00'x, MAIL.from_who) > 0) &,
            (\ MAIL.checkwhere | inwhere()) then
            say ' 'sender ':' subject
         end
      when type = 1 | type = 16 then do
         parse value substr(data,88) with header '00'x name '00'x fsname '00'x .
         if \ MAIL.checkin | pos('00'x||space(translate(name),0)'00'x, MAIL.in_what) \= 0 then do
            say '['name']'
            call directory fsname
            call explore
            call directory '..'
            end
         end
   otherwise
      say  substr(data,88)
   end  /* select */
   return

inwhere:
   return 1


/* query DISK [unit] */
disk:
   if translate(word(request, 1)) \= 'DISK' then
      return 'Incorrect request:' request
   drv = subword(request, 2)

   drives = ''
   if drv = '*' then
      drives = SysDriveMap()
   else
   if drv = '' then
      drives = filespec('d', directory())
   else
   do i = 1 to words(drv)
      unit = word(drv, i)
      if length(unit) > 2 | datatype(left(unit, 1), 'M') \= 1 | (length(unit) = 2 & right(unit, 1) \= ':') then
         return 'Incorrect request:' request
      drives = drives left(unit':', 2)
   end /* do */

   str = ''
   do i = 1 to words(drives)
      parse value SysDriveInfo(word(drives,i)) with drive free max label
      if drive = '' then iterate
      used = max-free
      if max = 0 then
         capacity = 100
      else
         capacity = used/max*100
      str = str || '0d0a'x drive 'disk usage:' used % 1024 || 'k ('strip(format(capacity,3,0)'%')')'
   end
   return substr(str,3)


/* query PICTure DIMension FOR ... */
picture:
   /* code for GIF and JPEG adapted from E-Zine 2-9 and 2-10 */
   /* code for PNG according to w3c specs */
   if abbrev('DIMENSION', word(user_arg,2), 3) = 0 then
      return 'Incorrect request:' request
   if word(user_arg,3) \= 'FOR' then
      return 'Incorrect request:' request
   str = ''
   parse var user_arg . "FOR" list
   do i = 1 to words(list)
      f = word(list,i)
      if right(f,4) = '.GIF' then
         str = str||gifsize(f)'0d0a'x
      else
      if right(f,4) = '.JPG' | right(f,5) = '.JPEG' then
         str = str||jpgsize(f)'0d0a'x
      else
      if right(f,4) = '.PNG' then
         str = str||pngsize(f)'0d0a'x
      else
         say 'Unsupported format:' word(list,i)
   end /* do */
   if right(str,2) = '0d0a'x then
      return left(str,length(str)-2)
   else
      return str

gifsize:
   call charin f,1,6
   width = c2d(reverse(charin(f,,2)))
   height = c2d(reverse(charin(f,,2)))
   call stream f, 'c', 'close'
   return width'x'height

jpgsize:
   type = ''
   if c2x(charin(f,1,2)) \= "FFD8" then
      return 'Incorrect JPEG format'
   nextseg=3
   height="HEIGHT"
   do while type \= "D9" & nextseg \= -1 & height = "HEIGHT"
      nextseg = readsegment(nextseg)
   end /* do */
   call stream f, 'c', 'close'
   return width'x'height

readsegment:
   arg SegPos

   if c2x(charin(f, SegPos)) \= "FF" then
      return -1
   type = c2x(charin(f))
   if type = "01" | type >= "D0" & type <= "D9" then
      res = SegPos+2
   else
      res = SegPos+2+c2d(charin(f,,2))

   if type ="C0" | type = "C2" then do
      call charin f
      height = c2d(charin(f,,2))
      width = c2d(charin(f,,2))
      end

   return res

pngsize:
   if c2x(charin(f,1,8)) \= "89504E470D0A1A0A" then
     return 'Incorrect PNG format'
   call charin f,,8
   width = c2d(charin(f,,4))
   height = c2d(charin(f,,4))
   call stream f, 'c', 'close'
   return width'x'height


/* query SYStem DRIVERS */
drivers:
   str = ''
   localqueue = rxqueue('create')
   oldqueue = rxqueue('set', localqueue)

   '@rmview /d /r | find "Driver:" | rxqueue' localqueue

   do while (queued() > 0)
      parse pull line
      if line \= '' then
         str = str||substr(line, 9)'0d0a'x
   end /* do */

   call rxqueue 'delete', localqueue
   call rxqueue 'set', oldqueue

   return str


/* query [component] Version */
version:
   if wordpos('JAVA', user_arg) > 0 then do
      str = ''
      localqueue = rxqueue('create')
      oldqueue = rxqueue('set', localqueue)

      'java -version 2>&1 | rxqueue' localqueue

      do while (queued() > 0)
         parse pull line
         if line \= '' then
            str = str||line'0d0a'x
      end /* do */

      call rxqueue 'delete', localqueue
      call rxqueue 'set', oldqueue

      if right(str,2) = '0d0a'x then
         str = left(str,length(str)-2)

      return str
      end
   else
   if wordpos('REXX', user_arg) > 0 then do
      parse version v
      return v
      end
   else
      return 'Incorrect request:' request


/* query DIRector(y|ies) STACK */
dirstack:
   str = ''
   if words(user_arg) = 2 & (abbrev('DIRECTORY',word(user_arg,1),3) | abbrev('DIRECTORIES',word(user_arg,1),3)) then do
      envvar = 'DIRSTACK.'translate(DosGetInfoBlocks(), '.', ' ')
      qname = value(envvar,,'OS2ENVIRONMENT')
      if qname = '' then
         return 'Directory stack empty!'
      oldq = RxQueue('Set', qname)
      i = 0
      do while queued() \= 0
         i = i + 1
         pull stack.i
      end /* do */
      stack.0 = i;
      do i = stack.0 to 1 by -1
         push stack.i
         str = str||stack.i'0d0a'x
      end /* do */

      if right(str,2) = '0d0a'x then
         return left(str,length(str)-2)
      else
         return str
      end
   return 'Incorrect request:' request


/* query SYStem MEMory */
memory:
   signal on syntax name memoryerror
   if RxFuncQuery("rxuinit") then
      do
      call RxFuncAdd 'rxuinit','rxu','rxuinit'
      call rxuinit
      end

   dosrc = RxQuerySysInfo(info.)

   str = "  Physical memory on board: " format(info.17/1024, 8) "KB"||"0a0d"x
   str = str||"  Locked by OS/2:           " format(info.18/1024, 8) "KB"||"0a0d"x
   str = str||"  Allocatable memory:       " format(info.19/1024, 8) "KB"||"0a0d"x
   str = str||"  Memory page size:         " format(info.10, 8) "bytes"||"0a0d"x

   return str

memoryerror:
   say 'RXU is required for:' request
   exit


/* query SYStem IRQs */
irqs:
   str = ''
   localqueue = rxqueue('create')
   oldqueue = rxqueue('set', localqueue)

   '@rmview /irq | rxqueue' localqueue

   do while (queued() > 0)
      parse pull line
      if word(line,1) = 'IRQ' then
         str = str||strip(line)'0d0a'x
   end /* do */

   call rxqueue 'delete', localqueue
   call rxqueue 'set', oldqueue

   return str


/* query [LAST] NEWS [REFRESH] */
news:
   return stream(value('HOME',,'OS2ENVIRONMENT')'/newsrc', 'c', 'query datetime')
