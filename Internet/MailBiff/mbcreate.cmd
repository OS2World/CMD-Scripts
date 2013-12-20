/* MailBiff WPS object creation utility */

   call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   call SysLoadFuncs

   say 'Welcome to the MailBiff v0.01 WPS object creation utility.'
   say 'This program will assist you in seting up MailBiff to run from the Workplace Shell.'
   say 'You may terminate this program at any time by hitting ctrl-c.'
   say 

   say 'What is the name or ip address of your POP3 mail server?'
    Server = linein()
 
   say 'What is your userid on 'Server'?'
    Userid  = linein()

   say 'What is the password for 'Userid' on 'Server'?'
    Password = linein()
 
    DO UNTIL datatype( Refresh ) = 'NUM'
     say 'How often would you like to check the mailbox on 'Server'? ( in seconds )'
     Refresh = linein()
      IF datatype( Refresh ) = 'CHAR' THEN
       SAY 'That was not a number.  Try again!'
    END

   say 'Would you like the WPS icon changed to reflect the current mail count? ( Y/N )'
      pull WPS

   if WPS = 'Y' then
     do
       say 'Would you like to have a text window that show the current status of the connect to 'Server'? ( Y/N )'
        pull Detach
     end
   else Detach = 'Y'

   say
   say 'The Mailbiff icon will be created with these parameters:'
   say '  Server - 'Server
   say '  Userid - 'Userid
   say '  Password - 'Password
   say '  Refresh rate - 'Refresh
   say '  WPS icon update - 'WPS
   say '  Text windows - 'Detach
   say
   say 'Press enter to continue'
 
    pause = linein() 

   CmdLine = '-server 'Server
   CmdLine = CmdLine' -user 'Userid
   CmdLine = CmdLine' -pass 'Password
   CmdLine = CmdLine' -refresh 'Refresh

   if WPS = 'Y' then
     CmdLine = CmdLine' -wps '

   if Detach <> 'Y' then
     CmdLine = CmdLine' -detach '

   say CmdLine

   Setup = 'EXENAME='directory()'\mb.cmd;'
   Setup = Setup'MINIMIZED=YES;'
   Setup = Setup'PROGTYPE=WINDOWABLEVIO;'
   Setup = Setup'NOAUTOCLOSE=NO;'
   Setup = Setup'PARAMETERS='CmdLine';'
   Setup = Setup'STARTUPDIR='directory()

   If SysCreateObject("WPProgram", Server, "<WP_DESKTOP>", Setup )  Then
     Say 'Program object for server 'Server' has been created.'
   Else Say 'Could not create program object for server 'Server'!'
            
  


