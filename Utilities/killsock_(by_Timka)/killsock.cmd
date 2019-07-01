/* Program to shutdown sockets              */

/* USAGE: killsock [socket]                 */
/* If socket is omitted then all sockets    */
/* with status CLOSE_WAIT will be shutdown  */
/* Else the only "socket" will be shutdown  */

if \RxFuncQuery("SockLoadFuncs")
  then
    nop
  else
    do
      call RxFuncAdd "SockLoadFuncs","rxSock","SockLoadFuncs"
      call SockLoadFuncs
    end
If (ARG() <> 0) Then Do
  Parse Arg sock_to_close
  Call SockShutdown sock_to_close, 2 
  Exit
End
Address Cmd '@netstat -s |RXQUEUE > NUL'
Lines = Queued();
j = 0
Do i=1 To Lines
  Pull s . . . . t
  If DATATYPE(s)=NUM Then Do
    j = j + 1
    sock.j = s
    socktype.j = t;
  End
End
k = 0
Do i = 1 To j
  If (Pos("CLOSE_WAIT", socktype.i) <> 0) Then Do
    k = k + 1
    rc = SockShutdown(sock.i, 2) 
    Say FORMAT(sock.i, 5) " was " socktype.i " now SHUTDOWN"
  End
End
Say k "sockets are shutdown"
Exit
