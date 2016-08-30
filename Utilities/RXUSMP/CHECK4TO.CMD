/* Rexx */

/*******************************************************************

  This Rexx program is a generic timeout detecting function which can
  be used to time some activity a Rexx program is performing, and
  perform some timeout-handling action when a specified time limit
  has been exceeded.  The general scheme of use is as such:

  handler_string = "Say 'Timeout detected!!'"
  timerid = check4to('Init',handler_string,10000)  // wait 10 seconds
  ...
  Call check4to 'Start', timerid
  {
   ... do whatever you want to time ...
  }
  Call check4to 'Stop', timerid
  ...
  Call check4to 'End', timerid

  ==================================================================

  The argument list for "check4to" is:

    timerid = check4to(func, handler_string, timelimit, arglist)

  where:

    func         = 'INIT', 'START', 'STOP', 'END'
    handler_code = Rexx program source string to be executed when
                   a timeout is detected
    timelimit    = integer indicating how many miliseconds timer
                   is to wait before executing "handler_string"
    arglist      = argument string for "handler_string" program
    timerid      = token returned when func = 'INIT' and used on
                   subsequent calls (func = 'START','STOP','END')

  ==================================================================

  This program illustrates one way in which you can use some of the
  functions from the YDBAUTIL package.  Of course, you could modify
  this code to call a normal on-disk Rexx program (i.e. a .CMD file)
  instead of the "handler_string" for instance.  Or you might want
  to keep all the semaphore handles in a blob of allocated memory
  (RxAllocMem) rather than in a Rexx Queue.  In any event, this
  should demonstrate how you can build some quite sophisticated
  programs entirely in Rexx.

  ==================================================================

  This program demonstrates the use of the following functions in
  the YDBAUTIL function package:

  - RxCreateRexxThread()
  - RxCallInstore()
  - RxCreateEventSem()
  - RxPostEventSem()
  - RxResetEventSem()
  - RxWaitEventSem()
  - RxQueryEventSem()
  - RxCloseEventSem()
  - RxPullQueue()
  - RxAddQueue()

*******************************************************************/

If rxfuncquery('RxCreateRexxThread') Then
  Do
  Call rxfuncadd 'rxydbautilinit','ydbautil','rxydbautilinit'
  Call rxydbautilinit
  End

Arg func

Select
  When Left(func,3) = 'INI' Then
    Do
    Return Initialize_Timeout_Thread(Arg(2),Arg(3),Arg(4))
    End
  When Left(func,3) = 'STA' Then
    Do
    Call Get_Timeout_Info Arg(2)
    Call rxwaiteventsem hev_enable
    Call rxreseteventsem hev_enable
    Call rxposteventsem hev_start
    End
  When Left(func,3) = 'STO' Then
    Do
    Call Get_Timeout_Info Arg(2)
    Call rxposteventsem hev_free
    End
  When Left(func,3) = 'END' Then
    Do
    Call Get_Timeout_Info Arg(2)
    Call rxposteventsem hev_free
    Call rxwaiteventsem hev_enable
    Call rxreseteventsem hev_enable
    Call rxposteventsem hev_term
    Call rxposteventsem hev_start
    Call rxposteventsem hev_free
    End
  Otherwise
    Nop
End

Exit

/*                                                                */
/*    Get timeout information from queue                          */
/*                                                                */
Get_Timeout_Info: Procedure Expose hev_enable hev_start hev_free hev_term tid
Arg qname
If \RxQExists(qname) Then
  Exit
hev_enable = rxpullqueue(qname);Call rxaddqueue hev_enable,qname
hev_start  = rxpullqueue(qname);Call rxaddqueue hev_start,qname
hev_free   = rxpullqueue(qname);Call rxaddqueue hev_free,qname
hev_term   = rxpullqueue(qname);Call rxaddqueue hev_term,qname
tid        = rxpullqueue(qname);Call rxaddqueue tid,qname
If hev_enable = '' | hev_start = '' | hev_free = '' | hev_term = '',
 | tid = '' Then
  Exit
Return

/*                                                                */
/*    Initialize Timeout Checking Thread                          */
/*                                                                */
Initialize_Timeout_Thread: Procedure

Parse Arg handler, timelimit, arglist

If handler = '' Then
  Exit
If timelimit = '' Then
  timelimit = 30000    /* 30 seconds, by default */
If \DataType(timelimit,'W') Then
  Exit

/* Prepare for and start timeout-checking thread */
tempq = RxQueue('Create')
semrc = rxcreateeventsem('hev_enable')
semrc = rxcreateeventsem('hev_start')
semrc = rxcreateeventsem('hev_free')
semrc = rxcreateeventsem('hev_term')
crlf = '0d0a'x;eof = '1a'x
pstr =       "parse arg hev_enable, hev_start, hev_free, hev_term, timelimit, handler, arglist, qname"crlf
pstr = pstr||"Do Forever"crlf
pstr = pstr||"  Call rxposteventsem hev_enable"crlf
pstr = pstr||"  Call rxwaiteventsem hev_start"crlf
pstr = pstr||"  Call rxreseteventsem hev_start"crlf
pstr = pstr||"  waitrc = rxwaiteventsem(hev_free,timelimit)"crlf
pstr = pstr||"  If waitrc = 640 Then"crlf
pstr = pstr||"    Call RxCallInStore handler, arglist, timelimit"crlf
pstr = pstr||"  terminfo = rxqueryeventsem(hev_term)"crlf
pstr = pstr||"  If Word(terminfo,2) > 0 Then"crlf
pstr = pstr||"    Do"crlf
pstr = pstr||"    Call rxcloseeventsem hev_enable"crlf
pstr = pstr||"    Call rxcloseeventsem hev_start"crlf
pstr = pstr||"    Call rxcloseeventsem hev_free"crlf
pstr = pstr||"    Call rxcloseeventsem hev_term"crlf
pstr = pstr||"    Call rxqueue 'delete',qname"crlf
pstr = pstr||"    Exit"crlf
pstr = pstr||"    End"crlf
pstr = pstr||"  Call rxreseteventsem hev_free"crlf
pstr = pstr||"End"crlf
pstr = pstr||"exit"crlf||eof
tid = rxcreaterexxthread('$'pstr,hev_enable,hev_start,hev_free,hev_term,timelimit,handler,arglist,tempq)

Call RxAddQueue hev_enable,tempq
Call RxAddQueue hev_start,tempq
Call RxAddQueue hev_free,tempq
Call RxAddQueue hev_term,tempq
Call RxAddQueue tid,tempq

Return tempq
