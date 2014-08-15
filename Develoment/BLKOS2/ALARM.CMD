/*ALARM.CMD*/
/*copyright (c)C>BLACK,B.STONE,KUTEK 1993*/
/* all rights reserved*/
/* not for public release*/
/* CRON pgm sounds an alarm or starts a pgm at a set time*/
/* usage: ALARM<alarm time> <optional command and parameters>*/
/*time in form of number using 24 hour format as follows*/
/* 5PM is 170000,3:20AM is 032000*/
parse arg   x.2  x.3  x.4  x.5  x.6  x.7 x.8 x.9
say x.2 'ALARM TIME'
xxwq=  x.3 x.4 x.5 x.6 x.7 x.8 x.9
stime=time()
parse var stime xx':'yy':'zz
stt=(xx)(yy)(zz)
say stt 'start time'
std=date('S')
say std 'start date'
if x.2<stt then adate=std+1
else adate=std
say adate 'active date'
do forever
   s=time()
  nd=date('S')
parse var s aaa':'bb':'cc
nt=(aaa)(bb)cc
parse value syscurpos() with row col
say s nd x2c(1b)'[1;32mCOUNTDOWN TIME'x2c(1b)'[0m'
qq=syscurpos(row,col)
if adate\=std &nd=adate&nt>x.2 then call ring
if adate=std&nt>x.2 then call ring
else call syssleep 20
end 


ring:
if x.3='' then do 50
call beep 2500,35
call beep 2000,35
end
else do
xxwq=strip(xxwq)
'start /c' xxwq;end
call syssleep 10

