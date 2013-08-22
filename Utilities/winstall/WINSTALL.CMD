/************************************************************/
/* REXX - WIN-OS/2 Installation Utility for OS/2 Warp v3    */
/* David J. Looney  19 November 1994                        */
/* Windows is a Trademark of Microsoft Corporation          */
/* WIN-OS/2, OS/2, & OS/2 Warp v3 are Trademarks of IBM     */
/*                                                          */
/* This utility is distributed free into the public domain. */
/* No warranty is made as the performance or suitability of */
/* this code for user purposes, and no liability for damage */
/* to data, equipment, loss of revenue or impairment of     */
/* physical or emotional health due to use of this program  */
/* is assumed.  Use at your own risk.                       */
/*                                                          */
/* This program should only be used by those holding valid  */
/* IBM OS/2 2.10 or 2.11 AND OS/2 Warp v3 licenses.  Note   */
/* that 'UPGRADE' licenses may exclude concurrent use.      */
/************************************************************/
'@echo OFF'

Call RxFuncAdd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs';
Call SysLoadFuncs; 

Call SysCls
Say ""
Say "         WIN-OS/2 Installation Utility for OS/2 Warp v3(TM)"
Say ""
Say "      ษออออออออออออออป"
Say "  ษอออน WINSTALL 1.0 ฬอออออออออออออออออออออออออออออออออออออออออออป"
Say "  บ   ศออออออออออออออผ                                           บ"
Say "  บ This utility will build WIN-OS/2 under Warp v3 from the      บ"
Say "  บ 2.1 (Fullpack) AND  OS/2 2.11 CSD full version diskettes     บ"
Say "  บ or a 2.11 \os2\mdos\winos2 backup.   If you do not use       บ" 
Say "  บ the 2.11 CSD version,   you will probably not find seam-     บ"
Say "  บ less WIN-OS/2 support satisfactory. Though seamless pro-     บ"
Say "  บ grams will load and run on the desktop they can only be      บ"
Say "  บ maximized and restored, but not resized, moved, or mini-     บ"
Say "  บ mized, and can sometimes hang the system. In addition, to    บ"
Say "  บ run 'seamless' WIN-OS/2 your card must support SVGA or       บ"
Say "  บ 8514 resolution under drivers supplied by OS/2 Warp v3 to    บ"
Say "  บ function  properly --- I have not been able to get seam-     บ"
Say "  บ less VGA using my TVGA8900CL. If you have a backup of the    บ"
Say "  บ winos2 and winos2\system directories after 2.11 CSD appli-   บ"
Say "  บ cation, you may wish to skip the 2.1x disks and restore      บ"
Say "  บ your 2.11 winos2 directory and subdirectories after run-     บ"
Say "  บ ning WINSTALL.  Be aware that many programs enter data and   บ"
Say "  บ replace Windows(TM) drivers,and that restoring may not       บ"
Say "  บ lead to a successful install of WIN-OS/2.                    บ"
Say "  บ                                                              บ"
Say "  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
'pause'

Call SysCls
Say ""
Say ""
Say "      ษออออออออออออออป"
Say "  ษอออน WINSTALL 1.0 ฬอออออออออออออออออออออออออออออออออออออออออออป"
Say "  บ   ศออออออออออออออผ                                           บ"
Say "  บ                                                              บ"
Say "  บ You will also need OS/2 Warp v3 on diskette or CD-ROM, and   บ"
Say "  บ may  wish to use Inimaint (Carey Associates) or a similar    บ"
Say "  บ utility to backup your desktop. Backup your system before    บ"
Say "  บ attempting to install WIN-OS/2 support.                      บ"
Say "  บ                                                              บ"
Say "  บ WINSTALL also requires you to use ED or TEDIT to change      บ"
Say "  บ path information in the config.sys file, and autoexec.bat    บ"
Say "  บ files, as well as system.ini file, and progman.ini files.    บ"
Say "  บ                                                              บ"
Say "  บ Use selective install to put your system into standard VGA   บ"
Say "  บ configuration before using WINSTALL unless you are running   บ"
Say "  บ default XGA configurations on hardware that uses the OS/2    บ"
Say "  บ standard XGA drivers (XGA default not tested by author).     บ"
Say "  บ                                                              บ"
Say "  บ Press Ctrl-C or Ctrl-Break now to abort.                     บ"
Say "  บ                                                              บ"
Say "  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
'pause'

Call SysCls
Say ""
Say ""

CurDir=directory()
Result=CHAROUT( ,"Enter the drive letter on which OS/2 Warp v3 is installed: ", );
PULL ANS .
OS2DRV=SubStr(ANS,1,1);
WINDIR=OS2DRV||":\OS2\MDOS\WINOS2"
WINSYS=OS2DRV||":\OS2\MDOS\WINOS2\SYSTEM"
Call SysMkDir WINDIR
Call SysMkDir WINSYS

Call SysCls

Result=CHAROUT( ,"Do you have Warp v3 on CD-ROM (Y/N) ?" , );
PULL ANS .
CDROM=SubStr(ANS,1,1);
IF CDROM="Y" THEN
 DO
   Result=CHAROUT( ,"Enter the CD-ROM drive letter now:",);
   PULL ANS .
   CDDRV=SubStr(ANS,1,1);
   Say ""
 END

InstallWinBase:
Say ""
Say "WINSTALL now needs to install Warp WINBASE files."
Say "If Warp Winbase files are installed you may skip this section."
Result=CHAROUT( ,"Skip installation of Warp Winbase files (Y/N) ?", ); 
PULL ANS .
IF SubStr(ANS,1,1)="Y" THEN signal InstallFastLoad
pause
Say "If files are already present ignore error messages."
InsDir=directory(OS2DRV||':')
IF CDROM="Y" THEN
 DO UNTIL rc=0
   PACKAGE=CDDRV||":\os2image\disk_2\bundle /n:wincfg.dll"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
   PACKAGE=CDDRV||":\os2image\disk_9\winbase"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
 END
ELSE 
 DO 
  DO UNITL rc=0
   Say "Insert OS/2 Warp v3 Diskette 2 into Drive A:"
   'pause'
   PACKAGE="a:\bundle /n:wincfg.dll"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
  END
  DO UNTIL rc=0
   Say "Insert OS/2 Warp v3 Diskette 9 into Drive A:"
   'pause'
   PACKAGE="a:\winbase"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
  END
END
TmpDir=directory(CurDir)

InstallFastLoad:
Say ""
Say "If you do not wish to use the Win-OS/2 FASTLOAD Warp option"
Say "or it is already installed, you may skip this section."
Result=CHAROUT( ,"Skip installation of FASTLOAD files (Y/N) ?", );
PULL ANS .
IF SubStr(ANS,1,1)="Y" THEN signal Install210WinEnv
pause
Say "If files are already present ignore error messages."
InsDir=directory(OS2DRV||':\os2\mdos\winos2')
IF CDROM="Y" THEN
 DO UNTIL rc=0
   PACKAGE=CDDRV||":\os2image\disk_12\winenv "||InsDir||" /n:fastload.exe"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
 END
ELSE 
 DO 
  DO UNITL rc=0
   Say "Insert OS/2 Warp v3 Diskette 2 into Drive A:"
   'pause'
   PACKAGE="a:\winenv "||InsDir||" /n:fastload.exe"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
  END
END
TmpDir=directory(CurDir)


Install210WinEnv:
Say ""
Say "WINSTALL now needs the 2.1 diskettes."
Say "If you have previously installed 2.1 files you may skip this section."
Result=CHAROUT( ,"Skip installation of the 2.1 Environment (Y/N) ?", );
PULL ANS .
IF SubStr(ANS,1,1)="Y" THEN signal Install211WinEnv
pause
Say "If files are already present ignore error messages."
InsDir=directory(OS2DRV||':')
DO UNTIL rc=0
  '@echo Insert Diskette #6 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winenv'
END
DO UNTIL rc=0
  '@echo Insert Diskette #7 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:wininis'
END
DO UNTIL rc=0
  '@echo Insert Diskette #8 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winreadm'
END
DO UNTIL rc=0
  '@echo Insert Diskette #9 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winacces'
  '@'||OS2DRV||':\os2\unpack a:winenv'
  '@'||OS2DRV||':\os2\unpack a:wintouch'
END
DO UNTIL rc=0
  '@echo Insert Diskette #10 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winver'
END
DO UNTIL rc=0
  '@echo Insert Diskette #11 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winscrsv'
END
DO UNTIL rc=0
  '@echo Insert Diskette #12 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winenv'
END
DO UNTIL rc=0
  '@echo Insert Diskette #16 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winenv'
  '@'||OS2DRV||':\os2\unpack a:winsound'
END
DO UNTIL rc=0
  '@echo Insert Display Driver Diskette #1 into Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:winvga'
  '@'||OS2DRV||':\os2\unpack a:winxga'
END
TmpDir=directory(CurDir)
Say "WINSTALL has completed installing the basic WIN-OS/2 environment."

Install211WinEnv:
InsDir=directory(OS2DRV||':')
Say ""
Say "WINSTALL now needs 2.11 CSD full version (with WIN-OS/2) Disks."
Say "If you do not need seamless WIN-OS/2 or have a 2.11 winos2 and "
Say "winos2\system backup you may skip installation of CSD files."
Result=CHAROUT( ,"Skip 2.11 WIN-OS/2 install (Y/N) ?", );
PULL ANS .
IF SubStr(ANS,1,1)="Y" then signal Installv3Video
pause
Say "If files are already present ignore error messages."
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 2 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1090.___ \os2\mdos\winos2'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 5 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1043.___ \os2\mdos\winos2\system'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1064.___ \os2\mdos\winos2\system'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 6 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE935.___ \os2\mdos\winos2\system'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 7 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE844.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE862.___ \os2\mdos\winos2'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 8 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE993.___ \os2\mdos\winos2\system'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1084.___ \os2\mdos\winos2'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 9 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1021.___ \os2\mdos\winos2\system'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 10 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE849.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE863.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1095.___ \os2\mdos\winos2'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 11 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE877.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1086.___ \os2\mdos\winos2'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 12 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE830.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE832.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE835.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE837.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE841.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE843.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FINSTAL1.HL_ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE858.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE860.___ \os2\mdos\winos2'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1062.___ \os2\mdos\winos2\system'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1063.___ \os2\mdos\winos2\system'
END
DO UNTIL rc=0
  '@echo Insert Volume SP DISK 13 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE927.___ \os2\mdos\winos2\system'
  '@'||OS2DRV||':\os2\unpack a:\fix\os2\FILE1089.___ \os2\mdos\winos2'
END
DO UNTIL rc=0
  '@echo Insert Volume DISP 1 in Drive A:'
  'pause'
  '@'||OS2DRV||':\os2\unpack a:\WINVGA'
  '@'||OS2DRV||':\os2\unpack a:\winxga'
END
TmpDir=directory(CurDir)
Say "WINSTALL is Finished Installing 211 Win Updates !"


Installv3Video:
Say ""
Say "WINSTALL is now ready to install Warp WIN-OS/2 video drivers."
Result=CHAROUT(,"Skip Warp v3 video driver installation (Y/N) ?",);
PULL ANS .
IF SubStr(ANS,1,1)="Y" THEN signal ModifyInits
pause
Say "If files are already present ignore error messages."
IF CDROM="Y" THEN
 DO UNTIL rc=0
   PACKAGE=CDDRV||":\os2image\disp_1\winxga "||OS2DRV||":\os2\mdos\winos2\system"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
   PACKAGE=CDDRV||":\os2image\disp_1\winvga "||OS2DRV||":\os2\mdos\winos2\system"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
 END
ELSE 
 DO UNTIL rc=0
   Say "Insert OS/2 Warp v3 Display Driver Diskette 1 into Drive A:"
   'pause'
   PACKAGE="a:\winxga "||OS2DRV||":\os2\mdos\winos2\system"
   '@'||OS2DRV||':\os2\unpack '||PACKAGE
   PACKAGE="a:\winvga "||OS2DRV||":\os2\mdos\winos2\system"
   '@'||OS2DRV||':\os2\unpack  '||PACKAGE
 END
Say "Finished installing video drivers."


ModifyInits:
Say "WINSTALL now updating system INI files."
/* Need null terminator for ASCII0 type settings */
ANS0=X2C('00');

Say "Updating INSTALL.INI ....";
IniFile=OS2DRV||":\os2\install\install.ini";
App="WINOS2";
Key="PM_GlobalWindows31Settings";
KeyValue="PROGTYPE=PROG_31_STD"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Say "Updating REINSTAL.INI ....";
IniFile=OS2DRV||":\os2\install\reinstal.ini";
Key="WIN30INSTALLED";
KeyValue="NO"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="WIN31INSTALLED";
KeyValue=OS2DRV||":\OS2\MDOS\WINOS2"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="WINDOWSSUPPORT";
KeyValue="YES"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

/* os2.ini */
Say "WINSTALL is updating OS2.INI ...."
IniFile=OS2DRV||":\os2\os2.ini";
Key="PM_ClipboardSupport";
KeyValue="0"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="PM_DDESupport";
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="PM_Global31FastLoad";
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="PM_Global31SessionType"
KeyValue="19"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="PM_GlobalWin31DataExchange";
KeyValue="13"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

Key="PM_GlobalWindows31Settings";
KeyValue="DPMI_MEMORY_LIMIT=64"||ANS0||,
         "PROGTYPE=PROG_31_STD"||ANS0||,
         "KBD_ALTHOME_BYPASS=1"||ANS0||,
         "VIDEO_SWITCH_NOTIFICATION=1"||ANS0||,
         "VIDEO_8514A_XGA_IOTRAP=0"||ANS0;
Result = SysIni(IniFile,App,Key,KeyValue);
IF Result<>'' then SAY "Unable to update "||IniFile
ELSE Say "File:"||IniFile||",App:"||App||",Key:"||Key||" updated."

InstallWinObjects:
Result = SysCreateObject("WPWinConfig","WIN-OS/2 Setup","<WP_CONFIG>",,
  "HELPPANEL=4203;"||,
  "DEFAULTVIEW=SETTINGS;"||,
  "NOCOPY=YES;"||,
  "NODELETE=YES;"||,
  "NOPRINT=YES;"||,
  "ICONPOS=6 42;"||,
  "OBJECTID=<WP_WINCFG>;",,
  "Replace"); 
IF Result=1 THEN SAY "WIN-OS/2 Setup Object Installed."
ELSE SAY "Win-OS/2 Setup Object Installation Failed."

Result=SysCreateObject("WPProgram","WIN-OS/2 Full Screen","<WP_PROMPTS>",,
"HELPPANEL=8022;"||,
"DEFAULTVIEW=RUNNING;"||,
"NOPRINT=YES;"||,
"ICONPOS=8 22;"||,
"EXENAME=*;"||,
"PROGTYPE=WIN;"||,
"SET KBD_ALTHOME_BYPASS=1;"||,
"SET KBD_CTRL_BYPASS=CTRL_ESC;"||,
"SET VIDEO_SWITCH_NOTIFICATION=1;"||,
"SET VIDEO_8514A_XGA_IOTRAP=0;"||,
"SET DPMI_MEMORY_LIMIT=64;"||,
"OBJECTID=<WP_WINFS>;",,
"Replace");
If Result=1 THEN say "Object: WIN-OS/2 Full Screen created/updated."
ELSE Say "WIN-OS/2 Full Screen creation Failed."

Result = SysCreateObject("WPProgram","WIN-OS/2 Window","<WP_PROMPTS>",,
  "HELPPANEL=8022;"||,
  "DEFAULTVIEW=RUNNING;"||,
  "NOPRINT=YES;"||,
  "ICONPOS=19 7;"||,
  "EXENAME=PROGMAN.EXE;"||,
  "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"||,
  "SET KBD_ALTHOME_BYPASS=1;"||,
  "SET KBD_CTRL_BYPASS=CTRL_ESC;"||,
  "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
  "SET VIDEO_8514A_XGA_IOTRAP=0;"||,
  "SET DPMI_MEMORY_LIMIT=64;"||,
  "SET WIN_DDE=0;"||,
  "SET WIN_CLIPBOARD=0;"||,
  "OBJECTID=<WP_WIN2WIN>;",,
  "Replace");
IF Result=1 THEN SAY "Win-OS/2 Command Prompt Object Created."
ELSE SAY "Win-OS/2 Command Prompt Creation Failed."
 

Call SysCls
UserInstallation:
Say ""
Say ""
Say "      ษออออออออออออออป                                             "
Say "  ษอออน WINSTALL1.0  ฬออออออออออออออออออออออออออออออออออออออออออออป"
Say "  บ   ศออออออออออออออผ                                            บ"
Say "  บ WINSTALL has finished updating the system. You must take the  บ"
Say "  บ following steps to make WIN-OS/2 functional before reboot:    บ"
Say "  บ                                                               บ"
Say "  บ    Make the following changes to your config.sys file:        บ"
Say "  บ 1. Add "||OS2DRV||":\os2\mdos\winos2\system to your LIBPATH.             บ"
Say "  บ 2. Add "||OS2DRV||":\os2\mdos\winos2 to  your PATH.                      บ"
Say "  บ 3. Add "||OS2DRV||":\os2\mdos\winos2\system to your DPATH.               บ"
Say "  บ 4. Add DEVICE="||OS2DRV||":\OS2\MDOS\VWIN.SYS to the end                 บ"
Say "  บ    of your config.sys.                                        บ"
Say "  บ                                                               บ"
Say "  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
'pause'
CALL SysCls
Say "      ษออออออออออออออป "
Say "  ษอออน WINSTALL1.0  ฬออออออออออออออออออออออออออออออออออออออออออออป"
Say "  บ   ศออออออออออออออผ                                            บ"
Say "  บ    Make the following changes to your autoexec.bat file:      บ"
Say "  บ 5. Add "||OS2DRV||":\os2\mdos\winos2 &                                   บ"
Say "  บ    "||OS2DRV||":\os2\mdos\winos2\system to your PATH                     บ"
Say "  บ    (Make sure your DOS PATH is not over 128 chars !)          บ"
Say "  บ    And if not using default XGA setup:                        บ"
Say "  บ 6. Edit "||OS2DRV||":\os2\mdos\winos2\system.ini and change              บ"
Say "  บ    all references from 'xga' to 'vga'.                        บ"
Say "  บ 7. Edit "||OS2DRV||":\os2\mdos\winos2\progman.ini and change             บ"
Say "  บ    all references from 'xga' to 'vga'.                        บ"
Say "  บ 8. Reboot.                                                    บ"
Say "  บ 9. Run selective install to change your system video to an    บ"
Say "  บ    SVGA resolution supported by your equipment.               บ"
Say "  บ 10.After rebooting from selective install, WIN-OS/2 should runบ"
Say "  บ    fine in both seamless & full-screen modes.                 บ"
Say "  บ    Comments to DJLOON@DELPHI.COM, CIS 75246.3364              บ"
Say "  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
'pause'
