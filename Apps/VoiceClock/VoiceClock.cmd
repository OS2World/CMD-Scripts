/*************************************************************************/
/* VoiceClock REXX Program v0.02   Chris Boyd                            */
/*                                 email: cboyd@ksu.ksu.edu              */  
/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
/*  VoiceClock/REXX v0.02 by Chris Boyd  August 26, 1996  OS/2 freeware  */
/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
/*                                                                       */
/* Ths REXX program will announce the TIME and DATE through a WAVEAUDIO  */
/* device (such as a SoundBlaster audio card).                           */
/*                                                                       */
/* Type VOICECLOCK /? to see a list of options                           */
/*                                                                       */
/*************************************************************************/

signal on halt

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

a = 0
b = 0
c = 0
d = 0
e = 0 
f = 0
g = 0
x = 0
FirstWait  = 0
SecondWait = 0

arg param1 param2 param3

/* Process command line parameters */

if param1 = '/?' then c = 1
if param1 = '-?' then c = 1
if param1 = '?' then c = 1
if left(param1,2) = '/C' then do
   a = 1
   pp1 = length(param1)
   if pp1 = 2 then x = 0
   if pp1 <> 2 then x = right(param1,pp1-2)
   if x = 'Q' then do
      e = 1
      g = 1
      x = 0
   end
   if x = 0 then e = 1
end
if param1 = '/D' then b = 1
if param1 = '/T' then b = 2
if param1 = '/N' then d = 1
if left(param2,2) = '/C' then do
   a = 1
   pp2 = length(param2)
   if pp2 = 2 then x = 0
   if pp2 <> 2 then x = right(param2,pp2-2)
   if x = 'Q' then do
      e = 1
      g = 1
      x = 0
   end
   if x = 0 then e = 1
end
if param2 = '/?' then c = 1
if param2 = '-?' then c = 1
if param2 = '?' then c = 1
if param2 = '/D' then b = 1
if param2 = '/T' then b = 2
if param2 = '/N' then d = 1
if param3 = '/?' then c = 1
if param3 = '-?' then c = 1
if param3 = '?' then c = 1
if left(param3,2) = '/C' then do
   a = 1
   pp3 = length(param3)
   if pp3 = 2 then x = 0
   if pp3 <> 2 then x = right(param3,pp3-2)
   if x = 'Q' then do
      e = 1
      g = 1
      x = 0
   end
   if x = 0 then e = 1
end
if param3 = '/D' then b = 1
if param3 = '/T' then b = 2
if param3 = '/N' then d = 1

f=1

if c = 1 then do
   say ''
   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   say 'VoiceClock/REXX v0.02 by Chris Boyd  August 26, 1996   OS/2 freeware'
   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   say ''
   say '  Usage: VOICECLOCK (switches)'
   say ''
   say '  Switches:'
   say ''
   say '        /Cx = CONTINUOUS announce mode'
   say '              x = minutes between announcements'
   say '              x = 0 to announce on the half hour and hour'
   say '              x = Q to announce on quarter, half hour, and hour'
   say ''
   say '        /T = Announce TIME only'      
   say '        /D = Announce DATE only'      
   say ''
   say '        /N = Disables screen output  /? = Displays help screen'
   say ''
   exit
end

if a = 0 then WhenAnnounce = '  ş SINGLE announce mode'
if a = 1 then WhenAnnounce = '  ş CONTINUOUS announce mode'
if a = 1 then do
   if e = 0 then InteAnnounce = '  ş Announce every ' x ' minute(s)'
   if e = 1 then do
      if g = 0 then InteAnnounce = '  ş Announce on every half hour and hour'
      if g = 1 then InteAnnounce = '  ş Announce on every quarter, half hour, and hour'
   end
end
if b = 1 then WhatAnnounce = '  ş DATE only'
if b = 2 then WhatAnnounce = '  ş TIME only' 

if d = 0 then do
   say ''
   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   say 'VoiceClock/REXX v0.02 by Chris Boyd  August 26, 1996   OS/2 freeware'
   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   say ''
   say WhenAnnounce
   if b <> 0 then say WhatAnnounce
   if a = 1 then say InteAnnounce
   say ''
   if a = 1 then say 'Press CTRL-C to quit'
   if a = 1 then say ''
end

/* CONTINUOUS ANNOUNCE LOOP START (IF A = 1) */
do until a = 0
   
   /* Parse the DATE and TIME */

   TodayMonth         = DATE('M')
   TodayDaySpecific   = DATE('W')
   TodayDayNumber     = DATE('E')
   TodayDayNumber     = LEFT(TodayDayNumber,2)
   NowHour            = TIME('H')
   IF NowHour > 12 THEN NowHour = NowHour - 12
   NowMinute          = TIME('N')
   NowMinute = RIGHT(LEFT(NowMinute,5),2)
   NowAP = RIGHT(TIME('C'),2)

   /* Calculate the filenames of WAV files */

   DayFilename = ('the'TodayDayNumber'.WAV')
   DayArg = ('FILE='DayFilename)
   MonthFilename = (TodayMonth'.WAV')
   MonthArg = ('FILE='MonthFilename)
   DaySFilename = (TodayDaySpecific'.WAV')
   DaySArg = ('FILE='DaySFilename)
   if NowHour = 0 then NowHour = 12
   HourFilename = (NowHour'.WAV')
   HourArg = ('FILE='HourFilename)
   if NowHour < 10 then HourArg = ('FILE=0'HourFilename)
   MinuteFilename = (NowMinute'.WAV')
   if NowMinute < 10 then MinuteFilename = ('O'NowMinute'.WAV') 
   MinuteArg = ('FILE='MinuteFilename)
   APFilename = (NowAP'.WAV')
   APArg = ('FILE='APFilename)

   /* ANNOUNCE THE TIME */

   if b <> 1 then do
      call Play.cmd 'FILE=TheTimeIs.WAV'
      call Play.cmd HourArg
      if NowMinute <> 0 then do
         call Play.cmd MinuteArg
      end
      call Play.cmd APArg
   end

   /* ANNOUNCE THE DATE */
   if b <> 2 then do
      call Play.cmd 'FILE=TodayDate.WAV'
      call Play.cmd DaySArg
      call Play.cmd MonthArg
      call Play.cmd DayArg
   end 

   /* IF CONTINUOUS MODE, SLEEP FOR SPECIFIED INTERVALS */

   if a = 1 then do
      if f = 1 then do
         NowMinute     = TIME('N')
         NowMinute     = RIGHT(LEFT(NowMinute,5),2)
         NowSeconds    = RIGHT(TIME('N'),2)
         TotalSeconds  = (NowMinute*60)+NowSeconds
         if NowSeconds <> 0 then FirstWait=(((x-1)*60)+(60-NowSeconds))
         if e = 1 then do 
            if NowMinute < 30 then FirstWait = (1800-TotalSeconds)
            if NowMinute > 30 then FirstWait = (3600-TotalSeconds)
            if NowMinute = 30 then FirstWait = (1800-NowSeconds)
            if NowMinute = 0  then FirstWait = (1800-NowSeconds)
            if g = 1 then do
               FirstWait = (3600-TotalSeconds)
               if NowMinute = 45 then FirstWait = (900-NowSeconds)
               if NowMinute < 45 then FirstWait = (2700-TotalSeconds)
               if NowMinute = 30 then FirstWait = (900-NowSeconds)
               if NowMinute < 30 then FirstWait = (1800-TotalSeconds)
               if NowMinute = 15 then FirstWait = (900-NowSeconds)
               if NowMinute < 15 then FirstWait = (900-TotalSeconds)
               if NowMinute =  0 then FirstWait  = (900-NowSeconds)
            end
         end
      end
      if f = 0 then do
         SecondWait = (x*60)
         NowMinute     = TIME('N')
         NowMinute     = RIGHT(LEFT(NowMinute,5),2)
         NowSeconds    = RIGHT(TIME('N'),2)
         TotalSeconds  = (NowMinute*60)+NowSeconds
         if NowSeconds <> 0 then SecondWait = (((x-1)*60)+(60-NowSeconds))
         if e = 1 then do 
            if NowMinute < 30 then SecondWait = (1800-TotalSeconds)
            if NowMinute > 30 then SecondWait = (3600-TotalSeconds)
            if NowMinute = 30 then SecondWait = (1800-NowSeconds)
            if NowMinute = 0  then SecondWait = (1800-NowSeconds)
            if g = 1 then do
               SecondWait = (3600-TotalSeconds)
               if NowMinute = 45 then SecondWait = (900-NowSeconds)
               if NowMinute < 45 then SecondWait = (2700-TotalSeconds)
               if NowMinute = 30 then SecondWait = (900-NowSeconds)
               if NowMinute < 30 then SecondWait = (1800-TotalSeconds)
               if NowMinute = 15 then SecondWait = (900-NowSeconds)
               if NowMinute < 15 then SecondWait = (900-TotalSeconds)
               if NowMinute =  0 then SecondWait  = (900-NowSeconds)
           end
         end
      end
   if f = 1 then call SysSleep FirstWait
   if f = 0 then call SysSleep SecondWait
   f = 0
   end
end

halt:


