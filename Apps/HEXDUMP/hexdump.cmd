/* hexdump.cmd,v 1.3 1999-08-13 10:01:43-04 rl Exp */

/****************************************************************
 *                                                              *
 * hexdump.cmd                                                  *
 * Generate hex dump in printable form                          *
 *                                                              *
 ****************************************************************/

parse arg opts
uopts = translate( opts )

if (pos('-H',uopts) > 0) | (pos('/H',uopts) > 0) | (opts = '') then
  do
  call help
  exit 1
  end

if pos('/',opts) > 0 then
  do
  parse var opts '/' maxbytes ' ' file
  call stream file, 'command', 'open read'
  end
else
  do
  file = opts
  call stream file, 'command', 'open read'
  maxbytes = chars( file )
  end

template = copies( ' ', 3 * 16 )
n = length( maxbytes )

do i = 0 by 16 while i < maxbytes
  hex = ''
  asc = ''
  do k = 0 to 15 while i + k < maxbytes
    c = charin( file )
    hex = hex' ' || c2x(c)
    if c >= 32 then
      asc = asc || c
    else
      asc = asc'.'
  end
  say format(i,n) || ' ' || overlay(hex,template,1) || ' 'asc
end

call stream file, 'command', 'close'

exit 0


/****************************************************************
 *                                                              *
 * help()                                                       *
 * Print help screen for user                                   *
 *                                                              *
 ****************************************************************/
help: procedure
  say ''
  say 'HexDump 1.3, by Rolf Lochbuehler <rolf@together.net>'
  say 'Purpose:'
  say '  Generate printable hex dump of binary file'
  say 'Usage:'
  say '  hexdump [/h] [[/N] File]'
  say 'Arguments:'
  say '  /h     Print help, then exit'
  say '  N      Print only first N bytes'
  say '  File   Binary file'
  say 'Note:'
  say '  To print into a file use > or >>'
  say 'Examples:'
  say '  hexdump /100 1.jpg'
  say '  hexdump 2.jpg > 2.txt'
  return


