
  Read-Me for RXPOP 1.0
  =====================
  
  Contents: Overview - Usage - History - Requirements - License - Author


  Overview:
  ---------

  RXPOP means REXX-Utils for POP-Mailing and enables to check a POP 
  account and automatically download messages.
 

  Usage:
  ------

  * ChkPOP.cmd <POP-Server> <User-ID> <Passwort>

  ChkPOP means "Check POP" and checks if there are messages in your POP 
  mailbox. If there are some ones, the size of each message is told to
  you.


  * GetPOP.cmd <POP-Server> <User-ID> <Passwort> <File-Mask>

  GetPOP means "Get POP mail" and downloads your mails and deletes them 
  on the POP-Server. 
  If File-Mask is a real mask (should contain up to 4 '?' so that 
  SysTempFileName can calculate enough filenames), each message is stored 
  in a single file that meets the given filemask. 
  If File-Mask names a certain file (existing or not), the mails are 
  appended to this file.


  * PollPOP.cmd

  PollPOP means "Poll the POP-server" and is just an example how to force 
  your system to download POP-mails automatically. It basically calls 
  GetPOP.cmd in certain intervals. But: 
  !!! This file has to be maintained by each user to work for him/she !!! 
  This can easily be done with any text editor. You just put your data in 
  the line where GetPOP.cmd is called.


  History:
  --------

  1.0   First Release
  1.1   Better error handling in case of wrong username or password
  1.2   Fixes for real RFC compatibility
        Appends to one file if a filename is given instead of a filemask


  Requirements:
  -------------

  Of course, REXX and TCP/IP has to be installed. Also, a connection to your 
  POP server must be possible.

  Further, the RXSock-Package is needed that is EWS-Ware (Employee Written 
  Software, IBM) done by Patrick Mueller. I think it is part of the Warp IAK
  and of Warp Connect's TCP/IP 3.0.
  

  License:
  --------
  
  From my point of view, this package is absolut Freeware.
  If you like it, feel free to mail me or to send money :-))

  Freeware means that you may do anything you want, but: You may NOT get 
  money for this packages except usual time-dependent online charges.

  Further, my scripts are based on one from Patrick Mueller, so his copyrights
  and the usual EWS terms has also to be fulfilled.


  About the author:
  -----------------

  Name:         Christoph Lechleitner
  EMail:        lech@lech.priv.at
  Snail-Mail 1: Kugelfangweg 11 b, A-6063 Rum, Austria, Europe
  Snail-Mail 2: Julius-Raab-Straáe 10, A-4040 Linz/Dornach
  Phone:        +43/512/269115 or +43/732/2457/432
  WWW:          http://www.lech.priv.at/~lech/

  (Warning: I am going to change some of these things soon ...)

