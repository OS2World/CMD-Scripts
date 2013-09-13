/* 
      Author:     Dennis Peterson, Sysop, OS/2 Northwest BBS
      FidoNet:    1:343/179
      Internet:   dpeterso@os2nw.ces.wa.com
      Date:       Feb. 3, 1995
      Version:    3.5
      Warranty:   Guaranteed to occupy space on your disk

      History:
         3.1 - first release
         3.5 - added abilty to return only messages that contain a pattern
               provided on command line.
             - added defaults for commandline args

      Purpose:
      This utility reads QWK-format messages.dat files as found in a QKW
      download and converts the messages to ASCII text. If a pattern is
      included it will extract only messages that contain that pattern. The
      pattern match is case sensitive.

      Usage:
      1) Unpack a .QWK message packet
      2) Look for a file called messages.dat. It's there.
      3) Run this REXX program. Use the > character to redirect the output
         to a file. That's it! The file will be coverted to a text file.

         qwk2text [messages.dat] [pattern] (defaults: messages.dat ---)      

      If no args are provided messages.dat is assumed and all messages
      will be extracted using --- for pattern.
*/


/* Initialize REXX */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* define constants */
CR    = '0d'x
QWKLF = 'e3'x


parse arg messages_file pattern debris

/* messages.dat is the message file normally found in QWK packets */
if messages_file = "" then
   messages_file = 'messages.dat'

/* --- is standard QWK end of message string and is found in all messages */
if pattern = "" then
   pattern = '---'

rc = SysFileTree(messages_file, 'file', 'F')
if file.0 = 0 then do
   say 'Error: 'messages_file' not found'
   exit
end

/* Read and ignore QWK packet message header - may use it in next version */

Header_block = charin(messages_file,1,128)

/* Start message translation loop */

Do while Chars(messages_file) > 0

/* Get the message header block, extract message #, date, time, to:, from:, 
   subject:, discard rest */

   message_block = charin(messages_file,,128)

/* Each message is made up of 128 byte records. The number of records in a
   particular message is found at offset:length 117:6 in the message header
   block. This number includes the message header block so 1 is subtracted. */

   num_recs = strip(substr(message_block,117,6) - 1,'B')
   message_body = charin(messages_file,,num_recs * 128)

/* convert QWK end-of-line to CR (sans LF) and say result  */
   result = translate(message_body, CR, QWKLF)

   if POS(pattern, result) > 0 then do
      say '*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*'
      say 'Message: 'strip(substr(message_block,2,7),'B')
      say 'Date:    'substr(message_block,9,8)'	Time:    'substr(message_block,17,5)
      say 'From:    'strip(substr(message_block,47,25),'B')
      say 'To:      'strip(substr(message_block,22,25),'B')
      say 'Subject: 'strip(substr(message_block,72,25),'B')
      say '--------------------------------------------------------------------'
      say
      say result
   end
end
exit
