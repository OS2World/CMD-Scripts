/**/
/*    HomeServ.CMD starts Slip Server and required daemons        */
/* Attach this to a program reference object to run it with a click */
/* Below, put start commands for all the daemons I want running  */

/* 
This is how to get a colored window in HomeServ.
Homesrvd.cmd contains "@sc bw" but this has no effect unless it is
run from CMD.EXE. There is no color with "start homesrvd".
To get color, it is not sufficient to just run it under CMD. The cmd 
window has to be cleared with color BEFORE running Homesrvd.
Hence we run two commands which can be combined using & like this:
sc bw & homesrvd
However, this won't work with "start" because the & is interpreted
as a second program to run after "start" has finished. Hence, we
put quotes aroud "sc bs & homeservd" cause both of these commands
to be passed as parameters to cmd.exe.
*/

/* Start the slip server */
'start "HomeSrvD" cmd /c "sc bw & homesrvd " '

/* Start the ftp server */
'start "FtpD" cmd /c "sc bw & staftpd " '

/* Start Web server */
'start stagosrv'   /* This takes the name GoServe HTTP automatically */

