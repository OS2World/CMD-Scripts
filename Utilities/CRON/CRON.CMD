/* CRON.CMD -- cheap UNIX cron clone for OS/2
   Jeroen Hoppenbrouwers (hoppie@kub.nl), October 1994
   Bug fixes by Paul Ratcliffe, October 2003
*/
signal on halt
parse upper source . . me
crondir = filespec('D', me) || filespec('P', me)
call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'
say 'CRON started' date() time()
do forever
  currMin = time('m')-time('h')*60
  currHour = time('h')
  today = date('o')
  parse var today currYear '/' currMonth '/' currDay
  today = date('w')
  currDow = wordPos(today,'Monday Tuesday Wednesday Thursday Friday Saturday Sunday')
  cronfile = crondir || 'crontab'
  line = lineIn(cronfile,1)
  do while line<>''
    parse var line minutes hours days months dows command
    isMin   = matches(minutes, currMin)
    isHour  = matches(hours, currHour)
    isDay   = matches(days,currDay)
    isMonth = matches(months,currMonth)
    isDow   = matches(dows,currDow)
    if ((left(line, 1) >= '0' & left(line, 1) <= '9') | left(line, 1) = '*') ,
	 & isMin & isHour & isDay& isMonth & isDow
      then do
        say currMin'm' currHour'h' currDay'd' currMonth'm' currDow'w:' line
        "@detach" command
      end
    line = lineIn(cronfile)
  end
  call stream cronfile,'c','close'
  call SysSleep 60-(time('s')-time('m')*60)
end

matches:
args = arg(1)
if args='*' then return 1
matched = 0
parse var args value ',' args
do while value<>''
  if value=arg(2) then matched = 1
  parse var value from '-' to
  if from<=arg(2) & arg(2)<=to then matched = 1
  parse var args value ',' args
end
return matched

halt:
say 'CRON stopped' date() time()
