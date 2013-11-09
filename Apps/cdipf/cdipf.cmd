/* REXX -- Cheap and Dirty IP Finder
   Extract current dial-up IP from PPP log file
*/

If RxFuncQuery('SysLoadFuncs') Then Do
    Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    Call SysLoadFuncs
End

In_File = VALUE('etc',,OS2ENVIRONMENT) || '\ppp0.log'

Do While lines(In_File) > 0
   Line_In = Linein(In_File)
   If Wordpos('local', Line_In) > 0 Then
      Say 'The current dial-up IP is 'Word(Line_In, Words(Line_In))
End

Exit
