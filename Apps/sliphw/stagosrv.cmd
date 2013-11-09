/* StaGoSrv.cmd Starts GoServ from command line */
/* Method 1 (works):  Change to directory and call it */
/* If this is used with
   "call goserv", STAGOSRV.CMD won't finish until GoServ is finished.
   If this is used with
   "start goserv" then STAGOSRV.CMD exits and leaves GoServ running.
*/
'setlocal'
'K:'
'cd \goserv\server'
'start goserve HTTP'
'endlocal'
'exit'  /* leaving off the quotes makes this a Rexx command */
       /* The exit is supposed to close the window running StaGoSrv.cmd*/
/*******************************************************/
/* Method 2 (also works): Using DeskMan/2 */
/* If this is used, STAGOSRV.CMD exits and leaves GoServ running */
/*
object="<GoServe>"
folder='Desktop'
setupString='OPEN=DEFAULT'

rc=SysSetObjectData('<DeskMan1>',,
                    'PerformSetup='object','folder','setupString';');
     If rc <> 1 then do
          Say  "DeskMan/2 PERFORM: error performing wpSetup on the "object" object!";
          exit 99
        end
*/
