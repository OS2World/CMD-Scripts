REM This fragment demonstrates documenting a batch file. When mkflag utility is
REM run with a filename with extension "CMD" then "#" becomes "REM ".
REM The "REM <mkflag>" is case sensitive and has one space.
REM This fragment is from file "make.cmd".
REM Any undocumented flag is described as "*** unknown flag ***".

REM <mkflag> gcc_fsf
REM  DOS2                     Define macro as 1 (if defn is missing) or defn
REM  O2                       Optimize even more.
REM  Zomf                     Zomf  *** unknown flag ***
REM  Zsys                     Zsys  *** unknown flag ***
REM  o                        Place output in file file.
gcc -DOS2 -O2 -Zomf -Zsys -o compress.exe compress.c isvalid.c
