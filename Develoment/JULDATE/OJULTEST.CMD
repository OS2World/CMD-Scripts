/*#!rexx - ojultest.cmd */
parse arg adate        /* must put in full year- eg 1999 */
jul= .date~new(adate)
say 'Stardate:' jul~juldate 'is' jul~whatDay',' jul~gregDate

dst=.date~new(jul~todst)
std=.date~new(jul~Tostd)
say 'In' jul~getYear||', DST starts on:' dst~whatDay||',' dst~gregDate
say 'In' jul~getYear||', EST starts on:' std~whatDay||',' std~gregDate

If jul~isDST Then
  say 'On this date, Daylight Savings time is in effect.'
else
  say 'On this date, Standard time is in effect.'

If jul~isLeapYear Then
  say jul~getYear 'is a leap year.'
else
  say jul~getYear 'is not a leap year.'
return
::requires ojuldate.cmd
