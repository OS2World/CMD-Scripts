/* */
Say "Sample Rexx program for demonstrating RXQUERYFILESYSTEM function"
Say "RxFnSet by Leshek Fiedorowicz"
Say

/* Sample program for demonstrating 'RXQUERYFILESYSTEM' function */

Arg Device
    if Device = '' then
      device = "C:"

    Call RxFuncDrop 'RXQUERYFILESYSTEM'

    Call RxFuncAdd 'RXQUERYFILESYSTEM', 'RXFN32', 'RXQUERYFILESYSTEM'

    Call RxQueryFileSystem Device

    if (Length(Result) = 0) then do
            say 'ERROR - Check your parameter ('Device').'
            say '        D: is expected, where D - device (disk) letter followed by colon.'
         end
    else
       say 'File System for 'Device' is 'Result'.'


    Call RxFuncDrop 'RXQUERYFILESYSTEM'
Exit
