/* Create a bootable 3.5" floppy */
/* Version: 1994 March 14 */
/* Technique from Moskowitz D, Kerr D. "OS/2 Unleashed." Sams Publishing, 1993. */
/* trace ?all */
say "Enter the boot drive letter (e.g.: C:):"
pull bootDrive .
if right(bootDrive,1)\=':' then bootDrive=bootDrive':'

do forever
	say "Enter 1 if your machine is ISA or EISA, or 2 if Microchannel PS/2:"
	pull busType .
	if busType="1" | busType="2" then leave
	beep(262, 500)
	say "Illegal answer!"
end

do forever
	say "Do you have a SCSI drive? (Y/N)"
	pull scsi .
	if scsi="Y" | scsi="N" then leave
	beep(262, 500)
	say "Illegal answer!"
end
if scsi="Y" then driveType="2SCSI"
else driveType="1S506"

call rxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

workDir=SysTempFileName(bootDrive'\TEMP????')
call SysMkDir(workDir)
call Directory workDir

call loadDisk "Installation Diskette", "DISK 0"
'copy A:\SYSINSTX.COM .'
call loadDisk "Disk 1", "DISK 1"
'copy A:\KEYBOARD.DCP .'
'copy A:\SYSINST1.EXE .'

do until answer="N"
	say "Insert destination disk in drive a: and press 'ENTER'.  DISK WILL BE FORMATTED!"
	pull
	address cmd 'format A: /v:"OS2 BOOTDSK" /once'

	'.\sysinstx A:'

	address cmd 'attrib -h -r -s' bootDrive'\OS2KRNL'
	address cmd 'attrib -h -r -s' bootDrive'\OS2LDR'
	address cmd 'attrib -h -r -s' bootDrive'\OS2LDR.MSG'
	address cmd 'copy' bootDrive'\OS2KRNL' 'a:\'
	address cmd 'copy' bootDrive'\OS2LDR' 'a:\'
	address cmd 'copy' bootDrive'\OS2LDR.MSG' 'a:\'
	address cmd 'attrib +h +r +s' bootDrive'\OS2KRNL'
	address cmd 'attrib +h +r +s' bootDrive'\OS2LDR'
	address cmd 'attrib +h +r +s' bootDrive'\OS2LDR.MSG'

	'copy KEYBOARD.DCP A:\'
	'copy SYSINST1.EXE A:\'

	address cmd 'copy' bootDrive'\OS2\DLL\ANSICALL.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\DOSCALL1.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\NLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\BKSCALLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\KBDCALLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\OS2CHAR.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\BMSCALLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\MOUCALLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\QUECALLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\BVHINIT.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\NPXEMLTR.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\MSG.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\SESMGR.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\BVSCALLS.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\NAMPIPES.DLL A:\'
	address cmd 'copy' bootDrive'\OS2\DLL\VIOCALLS.DLL A:\'

	address cmd 'copy' bootDrive'\OS2\SYSTEM\HARDERR.EXE A:\'
	address cmd 'copy' bootDrive'\OS2\SYSTEM\COUNTRY.SYS A:\'

	address cmd 'copy' bootDrive'\OS2\INSTALL\SYSLEVEL.OS2 A:\'

	address cmd 'copy' bootDrive'\OS2\CMD.EXE A:\'
	address cmd 'copy' bootDrive'\OS2\DOS.SYS A:\'
	address cmd 'copy' bootDrive'\OS2\IBMINT13.I13 A:\'
	address cmd 'copy' bootDrive'\OS2\OS2DASD.DMD A:\'
	address cmd 'copy' bootDrive'\OS2\HPFS.IFS A:\'
	address cmd 'copy' bootDrive'\OS2\CHKDSK.COM A:\'

	address cmd 'copy' bootDrive'\OS2\CLOCK0'busType'.SYS A:\'
	address cmd 'copy' bootDrive'\OS2\KBD0'busType'.SYS A:\'
	address cmd 'copy' bootDrive'\OS2\PRINT0'busType'.SYS A:\'
	address cmd 'copy' bootDrive'\OS2\SCREEN0'busType'.SYS A:\'
	address cmd 'copy' bootDrive'\OS2\IBM'busType'FLPY.ADD A:\'
	if busType="2" then 'echo . > A:\ABIOS.SYS'

	address cmd 'copy' bootDrive'\OS2\IBM'driveType'.ADD A:\'

	call LineOut 'A:\CONFIG.SYS','IFS=HPFS.IFS /CACHE:64'
	call LineOut 'A:\CONFIG.SYS','BUFFERS=32'
	call LineOut 'A:\CONFIG.SYS','IOPL=YES'
	call LineOut 'A:\CONFIG.SYS','MEMMAN=NOSWAP'
	call LineOut 'A:\CONFIG.SYS','PROTSHELL=SYSINST1.EXE'
	call LineOut 'A:\CONFIG.SYS','SET OS2_SHELL=CMD.EXE'
	call LineOut 'A:\CONFIG.SYS','DISKCACHE=64,LW'
	call LineOut 'A:\CONFIG.SYS','PROTECTONLY=YES'
	call LineOut 'A:\CONFIG.SYS','LIBPATH=.;\;'
	call LineOut 'A:\CONFIG.SYS','PAUSEONERROR=NO'
	call LineOut 'A:\CONFIG.SYS','CODEPAGE=850'			/* Change for different country */
	call LineOut 'A:\CONFIG.SYS','DEVINFO=KBD,US,KEYBOARD.DCP'	/* Change for different country */
	call LineOut 'A:\CONFIG.SYS','DEVICE=\DOS.SYS'
	call LineOut 'A:\CONFIG.SYS','SET PATH=.;\'
	call LineOut 'A:\CONFIG.SYS','SET DPATH=\;'
	call LineOut 'A:\CONFIG.SYS','SET KEYS=ON'
	call LineOut 'A:\CONFIG.SYS','BASEDEV=PRINT0'busType'.SYS'
	call LineOut 'A:\CONFIG.SYS','BASEDEV=IBM'busType'FLPY.ADD'
	call LineOut 'A:\CONFIG.SYS','BASEDEV=IBMINT13.I13'
	call LineOut 'A:\CONFIG.SYS','BASEDEV=OS2DASD.DMD'
	call LineOut 'A:\CONFIG.SYS','BASEDEV=IBM'driveType'.ADD'

	do forever
		say 'Create another boot disk? (Y/N)'
		pull answer
		if answer="Y" | answer="N" then leave
		beep(262, 500)
		say "Illegal answer!"
	end
end

'cmd /c del *.* /n'			/* Must use cmd, not 4os2 */
address cmd 'cmd.exe /c' bootDrive
call Directory('\');
address cmd 'rmdir' workDir

exit

loadDisk:
do forever
	say "Insert" arg(1) "in drive a: and press 'ENTER'"
	pull
	driveInfo=SysDriveInfo('A:')
	parse var driveInfo . . . label
	if label=arg(2) then leave
	beep(262, 100)
	say "Incorrect disk!"
end
return
