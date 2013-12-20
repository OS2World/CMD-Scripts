/**/
Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL','SysLoadFuncs'
Call SysLoadFuncs
parse upper arg zipfile
call directory 'h:\dl'
'@echo off'
slash = lastpos("\",zipfile)
extlength = length(zipfile) - lastpos(".",zipfile)
say extlength
baselen = (length(zipfile) - slash) - (extlength + 1)
basename = substr(zipfile, slash + 1, baselen)
extension = right(zipfile, extlength)
target = translate(directory())"\"basename
call SysMkDir basename
call directory basename
select
   when extension = 'ZIP' then
      call extract unzip
   when extension = 'GZ' then
      call extract gzip -drv
   when extension = 'TAR' then
      call extract tar -xvf
   otherwise
      say "Copying" zipfile "to directory" target
      'copy' zipfile .
end

call SysSetObjectData directory(), "OPEN=ICON;"
exit

extract:
   say "Extracting" zipfile "to directory" target
   ''arg(1) arg(2) zipfile
return
