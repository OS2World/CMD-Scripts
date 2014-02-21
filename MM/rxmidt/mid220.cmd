/*\
|*| This script will convert a MIDI type 2 file into a set of
|*| type 0 files, which you can play separately. OS/2's multimedia
|*| subsystem does not accept type 2 MIDI files. It will accept
|*| the filemask of files to be processed and a optional second
|*| parameter (currently only DELETEORIGINAL is accepted, which
|*| instructs MID220 to delete original type 2 MIDI file). Second
|*| parameter can be shortened up to a single letter, i.e.
|*|
|*| MID220 *.mid D
|*|
|*| command will convert all type2 .mid files, deleting originals.
\*/

 call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs
 parse arg fname delorig;
 if fname = ''
 then do
       say 'Usage: mid220 <filemask> {D{ELETEORIGINAL}}';
       exit 1;
      end;
 if (left(fname, 1) = '"') & (right(fname, 1) = '"')
 then fname = substr(fname, 2, length(fname)-2);
 if delorig <> ''
 then if abbrev('DELETEORIGINAL', translate(delorig), 1)
      then delorig = 1
      else do
            say 'Unrecognized option: "'delorig'"';
            exit 1;
           end
 else delorig = 0;
 call SysFileTree fname, 'found', 'FO'
 select
  when found.0 = 0
  then do
        say 'No files found';
        exit 1;
       end;
  when found.1 = 1
  then exit type2to0(found.1);
  otherwise
  do i = 1 to found.0
   call type2to0(found.i);
  end;
 end;
exit 0;

type2to0: procedure expose delorig;
 fname = arg(1);
 file = charin(fname,,chars(fname));
 call stream fname, 'C', 'CLOSE';
 num = lastpos('.', fname);
 if (num = 0) | (num < lastpos('/', fname)) | (num < lastpos('\', fname))
  then base = fname
  else base = substr(fname, 1, num - 1);

 chunklen = c2d(substr(file, 5, 1))*16777216 +,
            c2d(substr(file, 6, 1))*65536 +,
            c2d(substr(file, 7, 1))*256 +,
            c2d(substr(file, 8, 1));
 header = substr(file, 1, 4 + 4 + chunklen);
 if substr(header,1,4) <> 'MThd'
 then do
       say 'Invalid MIDI header';
       return 1;
      end;

 format = c2d(substr(file, 4+4+1, 1))*256 + c2d(substr(file, 4+4+2, 1));
 if format <> 2
 then do
       say 'mid220 can handle only MIDI type 2 files, this file is type 'format;
       return 2;
      end;
 numtrk = c2d(substr(file, 4+4+3, 1))*256 + c2d(substr(file, 4+4+4, 1));
 header = overlay('00000001'x, header, 4+4+1);
 chunkpos = length(header)+1;
 do i = 1 to numtrk
  oname = base'$'i'.mid';
  call charout ,oname': ';
  call charout oname, header;
  call charout ,substr(header, 1, 4)',';
  chunktype = substr(file, chunkpos, 4);
  chunklen = c2d(substr(file, chunkpos+4, 1))*16777216 +,
             c2d(substr(file, chunkpos+5, 1))*65536 +,
             c2d(substr(file, chunkpos+6, 1))*256 +,
             c2d(substr(file, chunkpos+7, 1));
  if (chunktype <> 'MThd') & (chunktype <> 'MTrk') then leave;
  call charout oname, substr(file, chunkpos, 4+4+chunklen);
  call charout ,substr(file, chunkpos, 4);
  call stream oname, 'C', 'CLOSE';
  say '';
  chunkpos = chunkpos + 4 + 4 + chunklen;
 end;
 if delorig
 then call SysFileDelete(fname);
return 0;
