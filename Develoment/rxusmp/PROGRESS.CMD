/* Rexx */

/*******************************************************************
  
  The following swatch of Rexx code illustrates how you might use
  some functions in the YDBAUTIL function package to do multi-
  threaded Rexx programming.

  In the example below, we are going to display a "progress" message
  to show some sign of life to a user while the program waits on
  some external event.  In this case, we just want to display a
  "counter" on the screen while the main thread is waiting for
  a user to press any key to release the "pause" command.

*******************************************************************/

/* Register Rexx external functions */
If RxFuncQuery('SYSSLEEP') Then
  Do
  Call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
  Call SysLoadFuncs
  End
If RxFuncQuery('RxCreateRexxThread') Then
  Do
  Call RxFuncAdd 'RxYdbaUtilInit','YDBAUTIL','RxYdbaUtilInit'
  Call RxYdbaUtilInit
  End

/* InStorage code to be executed on another thread while waiting for */
/* response from partner */
instr = "Say;Say 'Executing instruction(s) at partner LU';Say"
instr = instr || ";Say 'Waiting for external event to end ...'"
instr = instr || ";call time 'r';do forever;call syssleep 2;call charout ,'0d'x||Trunc(time('e')) 'Seconds elapsed';end"
instr = RxTokenize(instr)

tid = RxCreateRexxThread('&'instr)

/* ... perform something which waits on an external event */
'@pause'
/* ... (such as an APPC "Receive_And_Wait", etc.)         */

call rxkillthread tid;say

Exit
