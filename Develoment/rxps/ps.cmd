/* PS.CMD - OS/2 - Display equivalent to unix 'ps' command.
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ REXX PS v1.7 ³ Peter Gamache ³ 3076 Mississippi St, Saint Paul, MN 55112 ³
ÆËËËËÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍËËËËËËËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËËËËËµ
ÆÎÎÎ¹ Copyright October 1992, P Gamache ÌÎÎÎÎÎ¹ Use at your own risk! ÌÎÎÎÎµ
ÀĞĞĞĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞĞĞĞĞĞĞÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄĞĞĞĞĞÙ
* Donate money if you wish, this is kindware, you CANNOT sell it.         *
* To see more of my rexx scripts, call: Duonet/The Edge @ (612)636-2155   */

say ''
arg args
if args \="" then do
  do x=2 to 6
    say sourceline(x)
  end
  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Shell Number'
  say '³   ÚÄÄÄÄÄÄÄÄÄÄÄÄ Process ID'
  say '³   ³    ÚÄÄÄÄÄÄÄ Parent Process ID'
  say '³   ³    ³    ÚÄÄ Process Priority'
end
say 'SN PID  PPID PRTY Name'left('',41)'BlockID  Status' /* Our Title   */
if queued()=0 then signal GetData   /* If queue is empty, don't dawdle  */

MTDQ:                               /* Empty the queue...               */
do forever                          /* Operation(MTDQ) Loop             */
  if queued()=0 then leave          /* If queue = empty, we're done     */
  LINE=linein('QUEUE:')             /* set dummy variable & pull line   */
end                                 /* end operation(MTDQ) loop         */

GetData:            /* Let's get the info from PSTAT.EXE                */
'pstat /c|rxqueue'  /* Not too tough to exec a command, is it?          */

ParseLoop:          /* Pull lines off the queue and clean them up       */
do forever                               /* Operation(PARSE) loop       */
  if queued()=0 then leave               /* if QUEUE empty, we're done  */
  parse value linein('QUEUE:') with LINE /* set variable & fetch a line */
  if pos('EXE',LINE)=0 then iterate      /* if no 'EXE', then skip      */
  parse value LINE with X1 X2 X3 X4 XX1 X5 X6 X7 XX2  /* Break it down  */
  if X4='C:\OS2\PSTAT.EXE' then iterate  /* Let's not list pstat.exe    */
  X4=left(X4,44)                         /* force X4 to proper length   */
  say X3 X1 X2 X5 X4 X6 X7
end                                      /* end of operation(PARSE) loop*/

exit 0                                   /* We're done!                 */
