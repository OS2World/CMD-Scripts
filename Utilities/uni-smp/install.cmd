/* -------------------------------------- */
/* UNI-SMP v1.0 (c) 2000 Fernando Cassia  */
/* -------------------------------------- */
/* Switch Aurora from UNI to SMP Kernel   */
/* and vice-versa  == INSTALL SCRIPT ==   */
/* ----------------------------------------------- */
/* fernando@cassia.com.ar - fcassia@compuserve.com */
/* Buenos Aires, Argentina                         */
/* ----------------------------------------------- */

Call RxFuncadd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs
'@echo off'
bootdrive=filespec('drive',value('RUNWORKPLACE',,'OS2ENVIRONMENT'))
os2path=bootdrive||"\os2\"
do i=1 to 24
    say " "
end

SAY "�����������������������������������������������������������������������ͻ"
SAY "� UNI-SMP package - Switches SMP to UNI-Kernel and vice-versa on WSeB   �"
SAY "� Hacked in a few mins by Fernando Cassia. Buenos Aires, Argentina      �"
SAY "� fcassia@compuserve.com - fernando@cassia.com.ar - http://i.am/fcassia �"
SAY "�����������������������������������������������������������������������ͼ"
SAY ""
SAY "This install.cmd file will copy all rexx utilities and related exe files "
SAY "to your system so you can call MAKE-UNI.CMD and MAKE-SMP from any dir."
SAY ""
'pause'
'copy unlock.exe 'os2path
'copy make-uni.cmd 'os2path
'copy make-smp.cmd 'os2path
say ""
SAY "� OPERATION COMPLETED! Email any suggestions/thanks/criticism to fcassia@csi.com "
SAY "You can now call make-uni and make-smp when you need to switch kernels"

exit
