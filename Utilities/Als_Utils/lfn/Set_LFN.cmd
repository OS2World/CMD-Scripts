/* This procedure will change the long name of   */
/* a file without changing the actual file name. */
/* Useage:                                       */
/*    SET_LFN myfil.ext "Long File Name"         */

call RxFuncAdd 'SysPutEA', 'RexxUtil', 'SysPutEA'
call SysLoadFuncs

parse arg FileName '"'LongName'"'
if LongName = '' then
   parse arg FileName LongName

if FileName = '' then DO
  say 'Please specify a file name!'
  exit 1
  end  /* Do */

say 'File Name:' FileName
say 'Long Name:' LongName
if LongName = ''
   then RetCode = SysPutEA(FileName, '.LONGNAME','')
   else RetCode = SysPutEA(FileName, '.LONGNAME',,
                  'FDFF'x||D2C(LENGTH(LongName))||'00'x||LongName)
say 'Return Code: 'RetCode

EXIT
