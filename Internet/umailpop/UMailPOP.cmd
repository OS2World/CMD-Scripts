/* Poll for incoming POP Mails                                     */
/* (C) Copyright Volker Weber 1994                                 */
/*                                                                 */
/* My local user name in UltiMail:      vowe                       */
/* Inbound Dir as speccified in LamPOP: \tcpip\etc\mail            */
/* Inbound Dir for UltiMail Server:     \tcpip\umail\server\inbox  */
/* UltiMail program directory:          \tcpip\umail               */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

Say "This REXX script will poll the inbound directory for new POP mail"
Say "every 60 seconds. Press Ctrl-C to terminate ..."
do forever
   '@for %%a in (\tcpip\etc\mail\*.pop) do \tcpip\umail\umailer -dest \tcpip\umail\server\inbox -to vowe < %%a && del %%a'
   call SysSleep 60
end
