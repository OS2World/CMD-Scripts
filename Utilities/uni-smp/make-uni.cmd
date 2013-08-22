/* -------------------------------------- */
/* MAKE-UNI v1.0 (c) 2000 Fernando Cassia */
/* -------------------------------------- */
/* Switch Aurora from SMP to UNI Kernel   */
/*-------------------------------------------------*/
/* fernando@cassia.com.ar - fcassia@compuserve.com */
/* Buenos Aires, Argentina                         */
/*-------------------------------------------------*/

Call RxFuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

bootdrive=filespec('drive',value('RUNWORKPLACE',,'OS2ENVIRONMENT'))
unipath=bootdrive||"\os2\install\uni\"
smppath=bootdrive||"\os2\install\smp\"
dllpath=bootdrive||"\os2\dll\"
rootdir=bootdrive||"\"
letter=LEFT(bootdrive,1)
/*
say bootdrive
say unipath
say smppath
say dllpath
say rootdir
say letter
*/

do i=1 to 24
    say " "
end

SAY "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»"
SAY "º MAKE-UNI (from UNI-SMP package) - Switches SMP to UNI-Kernel on WSeB  º"
SAY "º Hacked in a few mins by Fernando Cassia. Buenos Aires, Argentina      º"
SAY "º fcassia@compuserve.com - fernando@cassia.com.ar - http://i.am/fcassia º"
SAY "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼"
SAY ""
SAY "This process involves a reboot. If you want to abort press Ctrl-C, or"
'pause'
SAY ""
SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
SAY "ş UNLOCKING DOSCALL1..."
SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
'unlock 'dllpath'\doscall1.dll'
SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
SAY "ş Copying UNI Kernel files"
SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
'copy 'unipath'\doscall1.dll 'dllpath
'copy 'unipath'\os2ldr. 'rootdir
'copy 'unipath'\os2krnl. 'rootdir
SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
SAY "ş *** OPERATION COMPLETED *** Now system will reboot with SMP kernel...  "
SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
SAY ""
'pause'

/** REBOOT CODE **/
params="/IBD:"||LETTER
'SETBOOT 'params

exit
