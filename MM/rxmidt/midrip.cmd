/*\
|*| This REXX script will extract a set of .MID files from a
|*| resource file (container). Many games keeps their MID files
|*| packed together in a single file: this script will do the
|*| reverse thing. It will accept as a parameter the filemask
|*| of files to be scanned for encapsulated MID files. Example:
|*|
|*| MIDRIP *.res
\*/

 call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs

 fname = arg(1);
 if fname = ''
 then do
       say 'Usage: MIDrip <filemask>';
       exit 1;
      end;
 if (left(fname, 1) = '"') & (right(fname, 1) = '"')
 then fname = substr(fname, 2, length(fname)-2);
 call SysFileTree fname, 'found', 'FO'
 select
  when found.0 = 0
  then do
        say 'No files found fitting filemask 'fname;
        exit 1;
       end;
  when found.1 = 1
  then exit ripfile(found.1);
  otherwise
  do i = 1 to found.0
   call ripfile(found.i);
  end;
 end;
exit 0;

ripfile: procedure;
 fname = arg(1);
 file = charin(fname,,chars(fname));
 call stream fname, 'C', 'CLOSE';
 num = lastpos('.', fname);
 if (num = 0) | (num < lastpos('/', fname)) | (num < lastpos('\', fname))
  then base = fname
  else base = substr(fname, 1, num - 1);

 rp = 1; num = 1;
 do forever
  hdp = pos('MThd', file, rp);
  if hdp = 0 then leave;
  chunkpos = hdp;
  chunkcount = c2d(substr(file, chunkpos+10, 1))*256 +,
               c2d(substr(file, chunkpos+11, 1));
  ofile = base||'$'||num'.mid';
  num = num + 1;
  call charout ,ofile': ';
  do i = 0 to chunkcount
   chunktype = substr(file, chunkpos, 4);
   chunklen = c2d(substr(file, chunkpos+4, 1))*16777216 +,
              c2d(substr(file, chunkpos+5, 1))*65536 +,
              c2d(substr(file, chunkpos+6, 1))*256 +,
              c2d(substr(file, chunkpos+7, 1));
   if (chunktype <> 'MThd') & (chunktype <> 'MTrk') then leave;
   call charout ofile, substr(file, chunkpos, 4 + 4 + chunklen);
   if i > 0 then call charout ,',';
   call charout ,chunktype;
   chunkpos = chunkpos + 4 + 4 + chunklen;
  end;
  call stream ofile, 'C', 'CLOSE';
  say '';
  rp = hdp + 1;
 end;
 drop file;
return 0;
