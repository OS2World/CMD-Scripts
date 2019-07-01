/* Program to close sockets              */

/* USAGE: closesock [socket]                 */
/* If socket is omitted then all sockets    */
/* with status CLOSE will be closed  */
/* Else the only "socket" will be closed  */

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
  Call SockClose sock_to_close, 2 
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
  If (Pos("CLOSED", socktype.i) <> 0) Then Do
    k = k + 1
    rc = SockClose(sock.i) 
    Say FORMAT(sock.i, 5) " was " socktype.i " - now closed with SockClose()"
  End
End
Say k "sockets are closed"
Exit
