/*旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
  �                                                                          �
  �    RAFL.CMD -- A REXX Archive File Lister      by Russel Havens          �
  �                                                  on 10-02-92             �
  �                                                                          �
  �              Written in OS/2 REXX using Visual REXX                      �
  �                                                                          �
  �  This requires VREXX.EXE in the PATH, VREXX.DLL & DEVBASE.DLL in the	 �
  �  DLL Path (DPATH), and UNZIP.EXE, UNARJ.EXE and LH.EXE in the PATH. 	 �
  �    These programs are all free for personal use and are available        �
  �  in their separate archives.											 �
  �    This also uses EPM.EXE, which is included with the OS/2 package. 	 �
  �                                                                          �
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/

'@echo off'
call RxFuncAdd 'VInit', 'VREXX', 'VINIT'
initcode = VInit()
if initcode = 'ERROR' then signal CLEANUP

signal on failure name CLEANUP
signal on halt name CLEANUP
signal on syntax name CLEANUP


/* Begin with Visual REXX's VFileBox */
BEGIN:
result = 1
DO WHILE result = 1
    call VDialogPos 20, 50
	button = VFileBox('Pick an archive file...', '*.ZIP', 'file')
    if button = OK then
        filename = file.vstring
    else
        call CLEANUP
    call WHICH
    result = ENDQ()
END
call CLEANUP

/*  This subroutine determines which type of archiver to call  */
WHICH:
signature = CHARIN(filename,1,5);
if (substr(signature,1,2) = 'PK') then
    do
        temp = stream(filename,'c','close')
        call VIEWZIP
    end
else
    if (substr(signature,1,2) = '`�') then
        do
            temp = stream(filename,'c','close')
            call VIEWARJ
        end
    else
        if (substr(signature,3,3) = '-lh') then
            do
                temp = stream(filename,'c','close')
                call VIEWLZH
            end
        else
            call BADARCHIVE
RETURN



/*  View ARJ file  */
VIEWARJ:
    'unarj l' filename '> afl%%tmp.$$$'
	'epm afl%%tmp.$$$'
	'del afl%%tmp.$$$'
RETURN

/*  View ZIP file  */
VIEWZIP:
	'unzip -v' filename '> afl%%tmp.$$$'
	'epm afl%%tmp.$$$'
	'del afl%%tmp.$$$'
RETURN


/*  View LZH file  */
VIEWLZH:
	'lh l' filename '> afl%%tmp.$$$'
	'epm afl%%tmp.$$$'
	'del afl%%tmp.$$$'
RETURN


/* Report that archive was not ZIP, ARJ or LZH */
BADARCHIVE:
	msg.0 = 1
	msg.1 = 'Only ZIP, ARJ and LZH archives are supported'

	call VDialogPos 50, 50
	rb = VMsgBox('Archive File Lister', msg, 1)
RETURN

/* Query for End of Program */
ENDQ:

msg.0 = 1
msg.1 = '  Do you wish to see another .ZIP file? '

call VDialogPos 50, 50
rb = VMsgBox('Archive File Lister', msg, 6)
if rb = 'YES' then do
    RETURN 1
end
else RETURN 0


/* Deinitialize Visual REXX and EXIT */
CLEANUP:
   call VExit

exit

/* end of CMD file */
