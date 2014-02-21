/* REXX Procedure -- CUCKOO.CMD */

call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'

say 'Genuine Swiss Cuckoo Clock (made in Holland)'
say 'REXX script by Jeroen Hoppenbrouwers'

do forever
  
  /* First, go to bed until we reach x:30 or x:00 hours */

  seconds = time('s')-(time('h')*60*60)
  if seconds<1800
    then sleep = 1800-seconds
    else sleep = 3600-seconds

  say ' '
  say 'Cuckoo now sleeping for' sleep 'seconds...'
  call SysSleep sleep

  /* Compute the number of beats required */
  
  hours   = time('h')
  minutes = (time('m')-(hours*60))
  if hours>12 then hours = hours-12
  if hours=0  then hours = 12
  if minutes=30
    then beats = 1
    else beats = hours

  if beats=1
    then say 'Cuckoo Clock beating 1 time...'
    else say 'Cuckoo Clock beating' beats 'times...'

  /* Beating can be done with # of beats player calls, but that might
     be interrupted by the system. This method won't */
  
  do beats
    "@type cuckoo.raw >>cuckoo.tmp"
  end
  "@player -r 11000 cuckoo.tmp >nul"
  "@del cuckoo.tmp"
end

/* Problems:
   - What if the SBDSP$ device is not available due to other programs?
     The system now generates a "device not functioning" pop-up.
*/

