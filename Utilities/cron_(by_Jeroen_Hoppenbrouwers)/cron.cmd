/* CRON.CMD -- cheap UNIX cron clone for OS/2
   Jeroen Hoppenbrouwers (hoppie@kub.nl), October 1994

   Corrected by Digi 2005
*/

signal on halt
call rxFuncAdd 'sysSleep', 'rexxUtil', 'sysSleep'

/* Parse and check the crontab file */
ETCPath = value('ETC',,'OS2ENVIRONMENT')
FName = ETCPath'\crontab'

say 'CRON started' date() time()
do forever

  /* determine current time and date */
  currMin = time('m')-time('h')*60
  currHour = time('h')
  today = date('o')
  parse var today currYear '/' currMonth '/' currDay
  today = date('w')
  currDow = wordPos(today,'Sunday Monday Tuesday Wednesday Thursday Friday Saturday')-1

  do while lines(FName)\=0
    line = lineIn(FName)
    if line<>'' && left(line,1)='#' then 
    do
      parse var line minutes hours days months dows command
      isMin   = matches(minutes, currMin)
      isHour  = matches(hours, currHour)
      isDay   = matches(days,currDay)
      isMonth = matches(months,currMonth)
      isDow   = matches(dows,currDow)
      if isMin & isHour & isDay & isMonth & isDow then
      do
          say currMin'm' currHour'h' currDay'd' currMonth'm' currDow'w:' line
          execcmd = "start /min /c " command
          execcmd
/* 'cmd /c 'command */
      end
    end
  end
  call stream FName,'c','close'
  call sysSleep 60-(time('s')-time('m')*60)

end  /* main loop */

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
say ''
say 'CRON stopped' date() time()

/* end of file */

