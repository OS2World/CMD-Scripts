/* rexx */
parse arg infile
call stream infile, 'c', 'open read'
desc = charin(infile, 108, 48)
call stream infile, 'c', 'close'
desc = strip(desc,'B','00'x)
if desc = '' then do
  say infile' has no title'
  end
else do
  'describe' infile '"'desc'"'
  end
exit