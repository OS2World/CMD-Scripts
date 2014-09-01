/* */
Say "Sample Rexx program for demonstrating RXWILDCARD function"
Say "RxFnSet by Leshek Fiedorowicz"
Say


Arg Number

    Call RxFuncDrop 'RXWILDCARD'

    Call RxFuncAdd 'RXWILDCARD', 'RXFN32', 'RXWILDCARD'

    say
    MF = 'MYFILE.cmd'
    WC = '*.cmd'
    Result = RxWildCard(MF, WC)
    if Result = MF then 
      say MF' matches Wildcard 'WC' (Edited name is:'Result
    else
      say MF' does not match Wildcard 'WC' (Edited name is:'Result

    say
    MF = 'MYFILE.cmd'
    WC = '*.bbb'
    Result = RxWildCard(MF, WC)
    if Result = MF then 
      say MF' matches Wildcard 'WC' (Edited name is:'Result
    else
      say MF' does not match Wildcard 'WC' (Edited name is:'Result

    say
    MF = 'MYFILE.cmd'
    WC = '*.bat'
    Result = RxWildCard(MF, WC)
    say 'If you call >COPY 'MF WC' your file 'MF' will be copied to 'Result

    Call RxFuncDrop 'RXWILDCARD'
Exit
