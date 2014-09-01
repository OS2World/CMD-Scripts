/* */
Say "Sample Rexx program for demonstrating RXKILLPROCESS function"
Say "RxFnSet by Leshek Fiedorowicz"
Say

Arg Number
    Call RxFuncDrop 'RXKILLPROCESS'

    Call RxFuncAdd 'RXKILLPROCESS', 'RXFN32', 'RXKILLPROCESS'

    Call RxKillProcess Number

    say 'Return code from kill:'result'.'
    if result \=  0 then 
    do
      say "Syntax: RxKill <pid>;"
      say "        execute <RxTlst> to display the list of active tasks."
      say "See OS/2 CP Program Ref. (DosKillProcess) for deteils."
    end

    Call RxFuncDrop 'RXKILLPROCESS'
Exit
