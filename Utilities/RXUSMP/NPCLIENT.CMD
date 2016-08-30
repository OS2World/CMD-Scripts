/* rexx */

/* named-pipe client */

pipename = '\pipe\mypipe'
fn = 'c:\config.sys'

do while lines(fn) > 0
  call lineout pipename,linein(fn)
end

call stream fn,'c','close'
call stream pipename,'c','close'

exit
