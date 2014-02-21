/*\
|*| This REXX script will decode resource file from
|*| "Sam and Max hit the road" Lucasart's game so you
|*| can use later MIDRIP on it. You should run this
|*| script in S&M directory. It will create a file
|*| named S&M.DEC, you should run MIDRIP on it later.
\*/

 table = '';
 do i = 0 to 255
  table = table||bitxor(d2c(i),'69'x)
 end;
 fsz = chars('samnmax.sm1');
 call charout ,'be patient '
 '@del "s&m.dec" 1>nul 2>nul'
 do while fsz > 0
  bs = min(65536,fsz);
  file = charin('samnmax.sm1',,bs);
  file = translate(file, table, xrange('00'x,'FF'x));
  call charout 's&m.dec', file;
  fsz = fsz - bs;
  call charout ,'.'
 end;
 say ""
 say "now run <MIDrip S&M.DEC>"
