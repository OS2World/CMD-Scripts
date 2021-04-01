/* DIALER.CMD */
/*  This is a fancy-schmancy phone dialer program.
    You need VREXX installed for it to work however. which of course you will
    because VRexx is just so darn nifty! :)
    This uses only one other file than itself, any old text file you have
    laying around in which to keep your names and phone numbers.
    All entries in your PHONELST file are configured as follows:
    # Firstname Lastname Phonenumber
    (i.e.  # Ken Kavanagh 555-1234)
    You can space the words out as far as you want, it doesnt matter. and
    the program should pretty much ignore any thing else in your file that
    doesnt have a # in front. (Don't quote me on that)

--Set the comport and the name of your phonelist file below and you're set.--

p.s. All code was joyously stolen from other REXX scripts to create this one
so Enjoy it and change it and send me a finished/improved copy

Ken Kavanagh
1:153/7070
*/
'@echo off'
comport = "COM5"
phonelst = "c:\desktop\stuff!1.ken"

call RxFuncAdd 'SysLoadFuncs' , 'RexxUtil' , 'SysLoadFuncs'
call SysLoadFuncs
call SysFileSearch '#',phonelst,'list'
call stream sat_in,'c','close'
call sysdropfuncs

call RxFuncAdd 'VInit', 'VREXX', 'VINIT'
initcode = VInit()
if initcode = 'ERROR' then signal CLEANUP

signal on failure name CLEANUP
signal on halt name CLEANUP
signal on syntax name CLEANUP

/* OPENING SCREEN */
msg.0 = 4
msg.1 = 'Kens Phone Dialer'
msg.2 = 'written January 1994'
msg.3 = 'By Ken Kavanagh'
msg.4 = '1:153/7070'
call VDialogPos 50, 50
rb = VMsgBox('DIALER.CMD', msg, 1)
CrLf = X2C("0D0A")
phone = 0

do while phone = 0
   /* ListBox */
   list.vstring = list.1          /* default selection */
   call VDialogPos 50, 50
   return_button = VListBox('Select a Person to Call and Press YES', list, 60, 10, 3)
   if (return_button = "OK")
   then do
          selection = list.vstring
          parse upper var selection nil fname lname number rest
          CALL CALLNUMBER
          msg.0 = 4
          msg.1 = 'Currently Dialing...'
          msg.2 =  Fname
          msg.3 =  number
          msg.4 = 'Press OK to Hang Up'
          call VDialogPos 50, 50
          call VMsgBox 'Kens Dialer', msg, 1
          call hangup
          msg.0 = 1
          msg.1 = "Dial Another?"
          call VDialogPos 50, 50
          answer = VMsgBox('KENS DIALER', msg, 6)
            if answer = "YES"
               then phone = 0
            if answer = "NO"
               then phone = 1
         end
         else phone = 1
end
/* end of CMD file */

CLEANUP:
   call VExit
   exit

CALLNUMBER:
State = STREAM(ComPort,"C","OPEN")
"@MODE" ComPort":19200,N,8,1 > NUL"
CALL LINEOUT ComPort, "ATDT"Number||CrLf    /* Dial In */
return

HANGUP:
State = STREAM(ComPort,"C","OPEN")
"@MODE" ComPort":19200,N,8,1 > NUL"
CALL LINEOUT ComPort, "ATh0"||CrLf    /* Dial In */
State = STREAM(ComPort,"C","CLOSE")
return
