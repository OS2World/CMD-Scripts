/* REXX  -  Workstation Automation Tools for OS/2 - WATools v1.0
               Written by Russell Gosse, Team OS/2
                  Email: rgosse@interlog.com

            See WAT.TXT for description and reference.
            See RETCODE.TXT for return code descriptions.
*/

!version = '1.0 - 09/18/95'

if Arg() = 0 then do
   say
   say 'Workstation Automation Tools - WATools, '!version
   say '   Written by:  Russell Gosse, Team OS/2'
   say
   say 'This is a function that is meant to be called by another REXX exec!'
   say 'Please read WAT.TXT for details.  Thanks.'
   say
   return !no_function
end

/*--- Main Routine -------------------------------------------------*/

!no_function         = '-1'
!bad_parm            = '-2'
!out_of_range        = '-3'
!no_sessions         = '-4'
!not_connected       = '-5'
!unknown_function    = '-6'
!session_in_use      = '-7'
!unsupported         = '-8'
!system_error        = '-9'
!session_not_found   = '-10'
!session_busy        = '-11'
!send_error          = '-12'
!bad_mnemonic        = '-13'
!timeout             = '-14'
!no_hllapi_loaded    = '-99'

parse arg !func , !p1 , !p2 , !p3 , !p4 , !p5 , !p6 , !p7 , !p8

!func = translate(!func)
if !func \= 'INIT' then do
   signal on syntax name _NoHllapi
   if Hllapi('Query_Sessions') = '' then return !no_sessions
   signal off syntax 
end
signal on halt name _Terminate
signal on syntax name _Invalid_Func
interpret 'retval = '!func||'()'             
return retval

/*--- Functions Used Internally ----------------------------------------*/

_Terminate:
   call reset
return
                                      
_Invalid_Func: 
return !unknown_function

_NoHllapi:
return !no_hllapi_loaded

_No_Connection: 
    !conn = ''
return

_SendKey: Procedure
   arg string
   !rc = Hllapi('SendKey',string)
   select
      when !rc = 4 then !rc = !session_busy
      when !rc = 5 then !rc = !send_error
      when !rc = 6 then !rc = !bad_mnemonic
      otherwise nop
   end
return !rc

_CheckPos: 
   arg pos
   !new_pos = ''
   !rc = 0
   if words(pos) = 2 then do
      col = word(pos,1)
      row = word(pos,2)
      if datatype(row,'W') \= 1 then !rc = !bad_parm
      if datatype(col,'W') \= 1 then !rc = !bad_parm
      if row <= 0 | row > !rows then !rc = !out_of_range
      if col <= 0 | col > !cols then !rc = !out_of_range
      if !rc = 0 then !new_pos = Hllapi('Convert_Pos',!conn,col,row)
   end
   else do
      if datatype(pos,'W') \= 1 then !rc = !bad_parm
      if pos <= 0 | pos > !scrsize then !rc = !out_of_range
      if !rc = 0 then !new_pos = pos
   end
return !rc

_SessInfo: Procedure Expose !conn !scrsize !rows !cols !sesstype
   arg sessid
   if sessid = '*' then sessid = ' '
   !conn = ''
   !scrsize = ''
   !rows = ''; !cols = ''
   signal on syntax name _No_Connection
   info = Hllapi('Query_Session_Status',sessid)
   signal off syntax
   !conn = substr(info,1,1)
   !sesstype = substr(info,10,1)
   select
      when !sesstype = 'D' then !sesstype = 'H3'
      when !sesstype = 'E' then !sesstype = 'P3'
      when !sesstype = 'F' then !sesstype = 'H5'
      when !sesstype = 'G' then !sesstype = 'P5'
      otherwise nop
   end
   parse var info 12 bin_row 14 bin_col 16
   !rows = c2d(reverse(bin_row))
   !cols = c2d(reverse(bin_col))
   !scrsize = !rows * !cols
return

/*--- Functions Callable By User ---------------------------------------*/

Init:                   /* Initializes CM/2 REXX EHLLAPI functions */
   !rc = 0
   if RxFuncQuery('HLLAPI') then       /* See if HLLAPI is registered */
      !rc = RxFuncAdd('HLLAPI','SAAHLAPI','HLLAPISRV')
   if !rc = 0 then                     /* check if CM/2 sessions active */
      if Hllapi('Query_Sessions') = '' then !rc = !no_sessions
return !rc

Conn:                   /* Starts API connection to CM/2 */
   sessid = !p1
   title = 'Emulator - 'sessid' - WAT: Connected'
   call Hllapi 'Disconnect'
   !rc = Hllapi('Connect',sessid)
   select
      when !rc = 0 then do
         call Hllapi 'Connect_PM',sessid
         call Hllapi 'Change_Switch_Name',sessid,'S',title
         call Hllapi 'Change_Window_Name',sessid,'S',title
         call Hllapi 'Disconnect_PM',sessid
      end
      when !rc = 1 then !rc = !not_connected
      when !rc = 9 then !rc = !system_error
      when !rc = 10 then !rc = !unsupported
      when !rc = 11 then !rc = !session_in_use
      otherwise
         nop
   end
return !rc

Disc:                   /* Disconnects API connection to CM/2 session id. */
   !rc = 0
   call _SessInfo '*'
   if !conn \= '' then do
      call Hllapi 'Connect_PM',!conn
      call Hllapi 'Change_Switch_Name',!conn,'R'
      call Hllapi 'Change_Window_Name',!conn,'R'
      call Hllapi 'Disconnect'
      call Hllapi 'Disconnect_PM',!conn
   end
return !rc

Reset:                  /* Resets EHLLAPI environment */
   !rc = Hllapi('Reset_System')
   if !rc = 9 then !rc = !system_error
return !rc

Info:                   /* Returns information about specified session id. */
   sessid = !p1
   !rc = ''
   if sessid = '' then do
      call _SessInfo '*'
      if !conn = '' then !rc = !not_connected
   end
   else do
      call _SessInfo sessid
      if !conn = '' then !rc = !session_not_found
   end
   if !rc = '' then do
      !rc = !sesstype !rows !cols
   end
return !rc

List:                   /* Lists active CM/2 session ids. */
   type = !p1
   p = 0; h = 0; a = 0
   !allsess = ''; !printer = ''; !host = ''
   !sess_info = Hllapi('Query_Sessions')  /* check if CM/2 sessions active */
   sessions = length(!sess_info) / 12
   if sessions \= '' then do
      do i = 1 to sessions
         sessid = substr(!sess_info,(i*12)-11,1)
         if c2d(reverse(substr(!sess_info,(i*12)-1,2))) = 0 then do
            p = p + 1
            !printer = !printer sessid
         end
         else do
            h = h + 1
            !host = !host sessid
         end
         a = a + 1
         !allsess = !allsess sessid
      end
      !allsess = space(a !allsess)
      !host = space(h !host)
      !printer = space(p !printer)
   end
   if type = 'P' then !rc = !printer
   else
      if type = 'H' then !rc = !host
      else
         !rc = !allsess
return !rc          

PFKey:                  /* Sends PFkey to connected CM/2 session */
   key = !p1
   !rc = 0
   if key = '' | key < 1 | key > 24 then !rc = !bad_parm
   else do
      call _SessInfo '*'
      if !conn = '' then !rc = !not_connected
      else do
         if key >= 10 & key <= 15 then
            key = translate(d2x(key),'abcdef','ABCDEF')
         else 
            if key > 15 then
               select
                  when key = 16 then key = 'g'
                  when key = 17 then key = 'h'
                  when key = 18 then key = 'i'
                  when key = 19 then key = 'j'
                  when key = 20 then key = 'k'
                  when key = 21 then key = 'l'
                  when key = 22 then key = 'm'
                  when key = 23 then key = 'n'
                  when key = 24 then key = 'o'
                  otherwise
                     nop
               end
          string = '@'||key
      end
   end
   if !rc = 0 then !rc = _SendKey(string)
return !rc

Send:                   /* Writes a string of text */
   string = !p1
   quicksend = translate(!p1)
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      !rc = 0
      quick_list = 'CLEAR ENTER TABF TABB EOF HOME END PA1 PA2 PRINTPS'
      if pos(quicksend,quick_list) > 0 then do
         select
            when quicksend = 'CLEAR' then string = '@C'
            when quicksend = 'ENTER' then string = '@E'
            when quicksend = 'TABF' then string = '@T'
            when quicksend = 'TABB' then string = '@B'
            when quicksend = 'EOF' then string = '@F'
            when quicksend = 'HOME' then string = '@0'
            when quicksend = 'END' then string = '@q'
            when quicksend = 'PA1' then string = '@x'
            when quicksend = 'PA2' then string = '@y'
            when quicksend = 'PRINTPS' then string = '@A@T'
            otherwise nop
         end
      end
      if !rc = 0 then !rc = _SendKey(string)
   end
return !rc

CursorPos:              /* Retrieves or sets cursor postion */
   pos = !p1
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      if pos = '' then do
         !rc = Hllapi('Query_Cursor_Pos')
      end
      else do 
         !rc = _CheckPos(pos)
         if !rc = 0 then do
            !rc = Hllapi('Set_Cursor_Pos',!new_pos)
            if !rc = 7 then !rc = !out_of_range
            else
               if !rc = 1 then !rc = !not_connected
      end
   end
return !rc

Read:                   /* Reads string of text from CM/2 session */
   pos = !p1; len = !p2
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      call Hllapi 'Set_Session_Parms','NOEAB NOATTRB NOEAD NOXLATE'
      if pos = '' & len = '' then
         !rc = Hllapi('Copy_PS')
      else do
      if pos \= '' then !rc = _CheckPos(pos)
      else
         !new_pos = Hllapi('Query_Cursor_Pos')
      if !rc = 0 then do
         if len = '' then len = !scrsize - !new_pos
         if !new_pos + len > !scrsize then !rc = !out_of_range
         else do
            !rc = Hllapi('Copy_PS_To_Str',!new_pos,len)
            if !rc = 9 then !rc = !system_error
            else
               if !rc = 7 then !rc = !out_of_range
         end
      end
   end
return !rc

ReadWord:               /* Reads a word from the specified row */
   row = !p1; word = !p2
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      if row = '' | word = '' then !rc = !bad_parm
      else do
         call Hllapi 'Set_Session_Parms','NOEAB NOATTRB NOEAD NOXLATE'
         if row < 1 | row > !rows then !rc = !out_of_range
         else do
            pos = Hllapi('Convert_Pos',!conn,1,row)
            if pos = 0 then !rc = !out_of_range
            else do
               row_text = Hllapi('Copy_PS_To_Str',pos,80)
               if words(row_text) < word then !rc = !bad_parm
               else
                  !rc = word(row_text,word)
            end
         end
      end
   end
return !rc

ReadRow:                /* Reads entire row from connect session */
   row = !p1
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      if row = '' then !rc = !bad_parm
      else do
         call Hllapi 'Set_Session_Parms','NOEAB NOATTRB NOEAD NOXLATE'
         if row < 1 | row > !rows then !rc = !out_of_range
         else do
            pos = Hllapi('Convert_Pos',!conn,1,row)
            if pos = 0 then !rc = !out_of_range
            else do
               !rc = Hllapi('Copy_PS_To_Str',pos,80)
            end
         end
      end
   end
return !rc

Find:                   /* Finds string of text */
   text = !p1; pos = !p2; direction = translate(!p3)
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      if text = '' then !rc = !bad_parm
      else
         if direction \= '' & direction \= 'B' & direction \= 'F' then
            !rc = !bad_parm
         else do
            if pos = '' then do
               !rc = 0
               !new_pos = 1
               direction = 'SRCHALL'
            end
            else do
               if direction = 'B' then direction = 'SRCHFROM SRCHBKWD'
               else
                  direction = 'SRCHFROM SRCHFRWD'
               !rc = _CheckPos(pos)
            end
            if !rc = 0 then do
               call Hllapi 'Set_Session_Parms',direction
               !rc = Hllapi('Search_PS',text,!new_pos)
               call Hllapi 'Set_Session_Parms','SRCHALL SRCHFRWD'
            end
         end     
   end
return !rc

WaitFor:                /* Waits for text string to appear */
   text = !p1; timeout = !p2;
   default_timeout = 30
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else
      if text = ''then !rc = !bad_parm
      else
         if timeout \= '' & datatype(timeout,'W') \= 1 then !rc = !bad_parm
         else do
            !rc = 0
            if timeout = '' | timeout = 0 then timeout = default_timeout
            rc = Time('R')
            elapsed = 0
            do until elapsed > timeout
               if Hllapi('Wait') \= 0 then do
                  !rc = !timeout
                  leave
               end
            if Hllapi('Search_PS',text,1) \= 0 then leave
            elapsed = time('E')
            end
         end
         if elapsed >= timeout | !rc = !timeout then 
            !rc = !timeout
return !rc

Wait:                   /* Waits for host to unlock session */
   timeout = !p1
   !rc = 0
   default_timeout = 30
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      if timeout = '' then timeout = default_timeout
      if timeout \= '' & (datatype(timeout,'W') \= 1 | timeout <= 0) then 
         !rc = !bad_parm
      else do
         call Hllapi 'Set_Session_Parms','IPAUSE'
         call Hllapi 'Start_Host_Notify',!conn,'P'
         if Hllapi('Wait') \= 0 then !rc = !timeout
         else do
            rc = Time('R')      
            do until ((pause_value = 0) | (elapsed_time > timeout))
               pause_value = Hllapi('Pause',4,!conn||'#')  
               call Hllapi 'Query_Host_Update',!conn
               elapsed_time = Time('E')
            end
            call Hllapi 'Stop_Host_Notify',!conn
            call Hllapi 'Set_Session_Parms','FPAUSE'
            if elapsed_time > timeout then
               !rc = !timeout
         end
      end
   end
return !rc

ConvertPos:             /* Converts cursor postion value */
   pos = !p1
   !rc = 0
   call _SessInfo '*'
   if !conn = '' then !rc = !not_connected
   else do
      if words(pos) = 2 then do
         col = word(pos,1)
         row = word(pos,2)
         if datatype(row,'W') \= 1 then !rc = !bad_parm
         if datatype(col,'W') \= 1 then !rc = !bad_parm
         if row <= 0 | row > !rows then !rc = !out_of_range
         if col <= 0 | col > !cols then !rc = !out_of_range
         if !rc = 0 then !rc = Hllapi('Convert_Pos',!conn,col,row)
      end
      else do
         if datatype(pos,'W') \= 1 then !rc = !bad_parm
         if pos <= 0 | pos > !scrsize then !rc = !out_of_range
         if !rc = 0 then !rc = Hllapi('Convert_Pos',!conn,pos)
      end
return !rc

/* End of WATools Functions */
