/* This procedure will get the long name of      */
/* a file without changing the actual file name. */
/* Useage:                                       */
/*    GET_LFN myfil.ext                          */

call RxFuncAdd 'SysPutEA', 'RexxUtil', 'SysPutEA'
call SysLoadFuncs

parse arg FileName
FileName = strip(FileName,'B','"')

if FileName = '' then DO
  say 'Please specify a file name!'
  exit 1
  end  /* Do */

RetCode = SysGetEA(FileName, '.LONGNAME','LongName')
if RetCode = 0 & length(LongName) > 4 then LongName = delstr(LongName,1,4)
say 'File Name: 'FileName
say 'Long Name: 'LongName
say 'Return Code: 'RetCode

EXIT
