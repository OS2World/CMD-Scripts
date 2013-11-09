/**/
/*    WorkServ.CMD starts Slip Server and required daemons        */
/* Attach this to a program reference object to run it with a click */
/* Below, put start commands for all the daemons I want running  */

/* 
This is how to get a colored window in WorkServ.
Worksrvd.cmd contains "@sc bw" but this has no effect unless it is
run from CMD.EXE. There is no color with "start worksrvd".
To get color, it is not sufficient to just run it under CMD. The cmd 
window has to be cleared with color BEFORE running Worksrvd.
Hence we run two commands which can be combined using & like this:
sc bw & worksrvd
However, this won't work with "start" because the & is interpreted
as a second program to run after "start" has finished. Hence, we
put quotes aroud "sc bs & workservd" cause both of these commands
to be passed as parameters to cmd.exe.
*/

/* Start the slip server */
'start "WorkSrvD" cmd /c "sc bw & worksrvd " '

/* 
Lines below here are commented out. We assume that the Work machine is already
on the Internet and is running these servers.
/* Start the ftp server */
'start "FtpD" cmd /c "sc bw & staftpd " '

/* Start Web server */
'start stagosrv'   /* This takes the name GoServe HTTP automatically */

*/
