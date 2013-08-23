/***************************************************************/
/*                                                             */
/*                      ULTIMATE.CMD                           */
/*                                                             */
/*      This Rexx file recreates the Welcome Folder, the       */
/*      Extended Services Program Icon, the Lan Services       */
/*      Program Icon, the Toolkit icon, and any default        */ 
/*      OS/2 Icon, back onto any system that previously        */
/*      had these features on the Desktop.                     */
/*                                                             */
/*      NOTE:  ULTIMATE.CMD merely calls the EXE files that    */
/*             are already located on the hard drive in the    */
/*             default path.  The default path would be the    */
/*             path in which OS/2 installed these files.       */
/*             These EXE files must be on the hard drive in    */
/*             the default path for this Utility to work       */
/*             properly.                                       */
/*                                                             */
/*                     Shawn McAlhany                          */
/*                     December 06, 1992                       */
/*                     Beta:  December 09, 1992                */
/*                     Completed:  December 17, 1992           */
/***************************************************************/

call rxfuncadd 'sysloadfuncs', 'rexxutil', 'sysloadfuncs'
call sysloadfuncs                /* register system functions */
address cmd '@echo off'          /* echo is turned off */

call intro

start:

say 'What directory are the ultimate ico files located? Drive and'
say 'Path Please (default> c:\ultimate) <enter> for default.'
pull location
if location = '' then location = ultimate
else do    
   say 'The location of the ico files is: ' location
   say 'Is this correct (Y/N)?'
   yesno = SysGetKey()
   yesno = translate(yesno)
   if yesno <> 'Y'  then call choice
      else nop
   say
end  /* do */
'cd\'
'copy 'location'\*.ico'

call choice
call quit

welcintro:

/***************************************************************/
/*      WELCOME.CMD                                            */
/*                                                             */
/*      This Rexx file recreates the Welcome Folder and        */
/*      all of its utilities.  If the Executable files         */
/*      that are related to the Welcome Folder are             */
/*      removed from the hard drive, this program will         */
/*      not completely restore the Welcome Folder to           */
/*      its original state.                                    */
/*                                                             */
/*                      Shawn McAlhany                         */
/*                     November 5, 1992                        */
/*                 Completed: November 10, 1992                             */
/***************************************************************/

/***************************************************************/
/* This procedure explains the utility to the user and calls   */
/* other procedures to continue or terminate the program.      */
/***************************************************************/

say
say 'This portion recreates the Welcome Folder and all of its utilities.'
say 'If the Executable files that are related to the Welcome Folder are'
say 'removed from the hard drive, this program will not completely restore'
say 'the Welcome Folder to its original state.'
say

call option

say
say 'Creation of Welcome Folder has been asked to continue at the users discretion. . .'

call create_welcome

end:

say
say 'Creation of the Welcome Folder has been completed.'
say 'The Welcome Folder that came with the preloaded system'
say 'had two more folders in the Applications folder.  These folders'
say 'are named Games and Productivity and are both located in'
say 'the OS/2 System icon.'
say
'pause'

call choice

eslsintro:

say
say 'This portion recreates the Extended Services Folder, Lan Services'
say 'Folder, Communications Manager Folder, and User Profile Management'
say 'Services along with their associated program icons.  This utility is primarily'
say 'used to recreate the icons with their associated EXE files already on the'
say 'hard drive.  If these files have been moved from their default path or'
say 'removed from the fixed disk, this utility may not work properly.'
call option2

say
say 'Creation of the Extended Services Icon and Lan Services Icon has been asked to'
say 'continue at the users discretion. . .'

call mkeslan

say
say 'Creation of the Extended Services Folder and Lan Services Folder'
say 'has been completed.'
say
say 'Programmed by:'
say 'Georg Haschek (61804212 at VIEVMA)'
say
'pause'

call choiceb

toolintro:

say
say 'This portion recreates the toolkit and all the icons and'
say 'folders associated with it.  This utility is primarily'
say 'used to recreate the icons with their associated EXE files' 
say 'already on the hard drive.  If these files have been moved' 
say 'from their default path or removed from the fixed disk,' 
say 'this utility may not work properly.'
call option6

say
say 'Creation of the Toolkit has been asked to continue at the'
say 'users discretion. . .'

call toolkit

say
say 'Creation of the Toolkit has been completed.'
say
say 'Programmed by:'
say 'Georg Haschek (61804212 at VIEVMA)'
say
'pause'

call choiceb

os2sysintro:

say
say 'This portion recreates the OS/2 System Icon and all of its contents'
say 'that you choose to restore.'
say

call option3

say
say 'Creation of the OS/2 System Icon has been asked to continue at users discretion...'

call os2sys

say 'OS/2 System Folder Successfully created.'
say
'pause'

call choice2

infointro:

say
say 'This portion recreates the Information Icon and all of its contents'
say 'that you wish to restore.'
say

call option4

say
say 'Creation of the Information Icon has been asked to continue at users discretion....'

call information

say 'Information Folder Successfully created.'
say
'pause'

call choice3

/***************************************************************/ 
/* Procedure: create_welcome                                   */
/*                                                             */
/* This procedure creates the icons and folders that are part  */
/* of the original Welcome Folder.                             */
/***************************************************************/    

create_welcome:

say
say 'Creating Welcome Folder...'

/* create Welcome Folder */

rc = SysCreateObject('WPFolder','Welcome','<WP_DESKTOP>','OBJECTID=<WELCOME>')
if rc = 1 then do
   say 'Welcome folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Welcome folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Configuration Tools in Welcome Folder */

rc = SysCreateObject('WPFolder','Configuration Tools','<WELCOME>','OBJECTID=<CONFIGURE>;ICONFILE=\OS2\INSTALL\PRELOAD\TOOLS.ICO')

if rc = 1 then do
   say 'Configuration Tools folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Configuration Tools folder .  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Applications Folder in Welcome Folder */

rc = SysCreateObject('WPFolder','Applications','<WELCOME>','OBJECTID=<APPS>')
if rc = 1 then do
   say 'Applications folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Applications folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Features Folder in Welcome Folder */

rc = SysCreateObject('WPFolder','Features','<WELCOME>','OBJECTID=<FEATURES>')
if rc = 1 then do
   say 'Features folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Features folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Tutorials Folder in Welcome Folder */

rc = SysCreateObject('WPFolder','Tutorials','<WELCOME>','OBJECTID=<TUTORIALS>;ICONFILE=C:\OS2\INSTALL\PRELOAD\TUTFOLD.ICO')
if rc = 1 then do
   say 'Tutorials folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Tutorials folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Welcome & Quick Tour Book in Welcome Folder */

rc = SysCreateObject('WPProgram','Welcome & Quick Tour','<WELCOME>','EXENAME=\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=QTOUR.INF WELCOME;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')

if rc = 1 then do
   say 'Welcome & Quick Tour icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Welcome & Quick Tour icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Create Utility Diskettes in Configuration Tools folder */

rc = SysCreateObject('WPProgram','Create Utility Diskettes','<CONFIGURE>','EXENAME=\OS2\INSTALL\PRELOAD\BOOTDISK.EXE;PROGTYPE=PM;PARAMETERS=;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')
                                                                                                                                                                            
if rc = 1 then do
   say 'Create Utility Diskettes icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Create Utility Diskettes icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Configure in Configuration Tools folder */

rc = SysCreateObject('WPProgram','Configure','<CONFIGURE>','EXENAME=\OS2\INSTALL\PRELOAD\CONFIG.EXE;PROGTYPE=PM;PARAMETERS=;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')

if rc = 1 then do
   say 'Configure icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Configure icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Selective Uninstall in Configuration Tools folder */

rc = SysCreateObject('WPProgram','Selective Uninstall','<CONFIGURE>','EXENAME=\OS2\INSTALL\PRELOAD\UNINSTAL.EXE;PROGTYPE=PM;PARAMETERS=;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')

if rc = 1 then do
   say 'Selective Uninstall icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Selective Unistall icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end  /* do */

/* create Application Installation Overview in Applications folder */

rc = SysCreateObject('WPProgram','Application Installation Overview','<APPS>','EXENAME=\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=INSTALL.INF INSTALLING YOUR APPLICATIONS;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')

if rc = 1 then do
   say 'Application Installation Overview icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Application Installation Overview.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Services and Support in Features folder */

rc = SysCreateObject('WPProgram','Services and Support','<FEATURES>','EXENAME=\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=SERVICES.INF SERVICES AND SUPPORT;STARTUPDIR=\OS2\INSTALL\PRELOAD\;ICONFILE=C:\OS2\INSTALL\PRELOAD\HLPWARER.ICO')

if rc = 1 then do
   say 'Services and Support icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Services and Support.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* Preloaded 85XX systems do not come with the System Information       */
/* Utility.  This procedure prompts the user for a system of this type. */
/* If the system is an 85XX Type, it will not install the System        */
/* Information Utility, otherwise, it will be installed.                */

say
say 'Look on or below the faceplate of the computer, where the power button'
say 'is located, for a label that mentions the Type.  Use the first four digits'
say 'of the Type to answer the following question:'
say 'Is this computer an 8556 or 8557 Type (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then call jump
otherwise nop

say 

/* create Your System in Features folder */

rc = SysCreateObject('WPProgram','Your System','<FEATURES>','EXENAME=\OS2\APPS\SYSINFO.EXE;PROGTYPE=PM;PARAMETERS=;STARTUPDIR=\OS2\APPS\;')

if rc = 1 then do
   say 'Your System icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Your System icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

jump:

/* create For the DOS User in Tutorials folder */

rc = SysCreateObject('WPProgram','For the DOS User','<TUTORIALS>','EXENAME=\OS2\INSTALL\PRELOAD\DOSUSER.EXE;PROGTYPE=DOSFULLSCREEN;PARAMETERS=D;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')

if rc = 1 then do
   say 'For the DOS User icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Your System icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */    

/* create System Overview in Tutorials folder */

rc = SysCreateObject('WPProgram','System Overview','<TUTORIALS>','EXENAME=\OS2\INSTALL\PRELOAD\SYSOVER.EXE;PROGTYPE=DOSFULLSCREEN;PARAMETERS=;STARTUPDIR=\OS2\INSTALL\PRELOAD\;ICONFILE=C:\OS2\INSTALL\PRELOAD\OSTUTOR.ICO')

if rc = 1 then do
   say 'System Overview icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'System Overview icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */    

/* create Application Installation Overview in Tutorials folder */

rc = SysCreateObject('WPProgram','Application Installation Overview','<TUTORIALS>','EXENAME=\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=INSTALL.INF INSTALLING YOUR APPLICATIONS;STARTUPDIR=\OS2\INSTALL\PRELOAD\;')

if rc = 1 then do
   say 'Application Installation Overview icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Application Installation Overview.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

/* create Tutorial in the Tutorials folder */

rc = SysCreateObject('WPProgram','Tutorial','<TUTORIALS>','EXENAME=\OS2\TUTORIAL.EXE;PROGTYPE=PM;PARAMETERS=D;STARTUPDIR=\OS2\HELP\;')

if rc = 1 then do
   say 'Tutorial icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'System Overview icon.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */   

call end

/***************************************************************/
/* Procedure: option                                           */
/*                                                             */
/* Prompts the user for continuation of creation of the        */
/* Welcome Folder.                                             */
/***************************************************************/

option:

Say "Do you want to continue (Y/N)?"
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then return
otherwise call choice
end  /* select */

mkeslan:

/****************************************************************/
/* MKESLAN.CMD                  Version 1.1; August 11, 1992    */
/*                                                              */
/* Function:                                                    */
/*      Build the WPS entries for the following products:       */
/*              Extended Services:                              */
/*                      Communications Manager                  */
/*                      Database Manager                        */
/*              LAN Requester                                   */
/* Parameters:                                                  */
/*      None                                                    */
/*                                                              */
/* Programmed by:                                               */
/*      Georg Haschek (61804212 at VIEVMA)                      */
/*                                                              */
/* Change history:                                              */
/*      1.0  92/07/31 ... First release to OS2TOOLS             */
/*      1.1  92/08/11 ... Fix lowercase problem in PATH         */
/*                        processing                            */
/*                                                              */
/****************************************************************/
Trace 'O'
Address CMD
'@ECHO OFF'
Signal On Halt
Signal On Syntax

/**************/
/* Initialize */
/**************/
landrive = ''
cmdrive = ''
dbdrive = ''
upmdrive = ''
bootdrive = Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\OS2\SYSTEM',Value('PATH',,'OS2ENVIRONMENT'))-2,2)
If Pos('\IBMLAN',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then landrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\IBMLAN',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If Pos('\CMLIB',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then cmdrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\CMLIB',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If Pos('\SQLLIB',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then dbdrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\SQLLIB',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If Pos('\MUGLIB',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then upmdrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\MUGLIB',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If landrive = '' & cmdrive = '' & dbdrive = '' Then Do
  Say "No Extended Services or LAN Requester found, terminating."
  'pause'
  Call choiceb
End

'CLS'
Say "Your system is installed on the" bootdrive "drive."
Say " "
Say "The following components have been found:"
Say " "
If landrive <> '' Then Say "     LAN Requester on drive" landrive
If cmdrive <> '' Then Say "     Communications Manager on drive" cmdrive
If dbdrive <> '' Then Say "     Database Manager on drive" dbdrive
If upmdrive <> '' Then Say "     User Profile Management on drive" upmdrive
Say " "
Say "This program will now create a folder for each identified product on your"
Say "desktop, which will contain the standard WPS entries."
Say " "
Say "Do you want to continue (Y/N)?"
Parse Upper Pull yesno .
If Substr(yesno,1,1) <> 'Y' Then Call choice

If landrive <> '' Then Do
  Call SysCreateObject 'WPFolder','LAN Services','<WP_DESKTOP>','OBJECTID=<LAN_FOLDER>;','R'
  Call SysCreateObject 'WPProgram','OS/2 LAN Services Installation/Configuration','<LAN_FOLDER>','EXENAME='||landrive||'\IBMLAN\INSTALL\LANINST.EXE;PROGTYPE=WINDOWABLEVIO;STARTUPDIR='||landrive||'\IBMLAN\INSTALL;','R'
  Call SysCreateObject 'WPProgram','LAN Messaging','<LAN_FOLDER>','EXENAME='||landrive||'\IBMLAN\NETPROG\NETSEND.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||landrive||'\IBMLAN\NETPROG;','R'
  Call SysCreateObject 'WPProgram','LAN Requester','<LAN_FOLDER>','EXENAME='||landrive||'\IBMLAN\NETPROG\NET.EXE;PROGTYPE=FULLSCREEN;STARTUPDIR='||landrive||'\IBMLAN\NETPROG;','R'
  Call SysCreateObject 'WPProgram','OS/2 LAN Command Reference','<LAN_FOLDER>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS='||landrive||'\IBMLAN\BOOK\A3ALANCR.INF;STARTUPDIR='||bootdrive||'\OS2;','R'
  Call SysCreateObject 'WPProgram','OS/2 LAN Online Reference','<LAN_FOLDER>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS='||landrive||'\IBMLAN\BOOK\A3ALANOR.INF;STARTUPDIR='||bootdrive||'\OS2;','R'
End

If cmdrive <> '' | dbdrive <> '' Then Do
  Call SysCreateObject 'WPFolder','Extended Services','<WP_DESKTOP>','OBJECTID=<ES_FOLDER>;','R'
  Call SysCreateObject 'WPProgram','View Install History File','<ES_FOLDER>','EXENAME='||bootdrive||'\OS2\INSTALL\VIEWLOG.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||bootdrive||'\OS2\INSTALL;','R'
  Call SysCreateObject 'WPProgram','Add or Remove Features','<ES_FOLDER>','EXENAME='||bootdrive||'\OS2\INSTALL\REINST.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||bootdrive||'\OS2\INSTALL;','R'
  Call SysCreateObject 'WPProgram','Basic Configuration and Installation','<ES_FOLDER>','EXENAME='||bootdrive||'\OS2\INSTALL\ESCFG.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||bootdrive||'\OS2\INSTALL;','R'
  Call SysCreateObject 'WPProgram','Extended Services Command Reference','<ES_FOLDER>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=ESCMDREF.INF;STARTUPDIR='||bootdrive||'\OS2\BOOK;','R'
  Call SysCreateObject 'WPProgram','View Custom Build History File','<ES_FOLDER>','EXENAME='||bootdrive||'\OS2\INSTALL\VIEWBLOG.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||bootdrive||'\OS2\INSTALL;','R'
  Call SysCreateObject 'WPProgram','Create Custom Install Diskette','<ES_FOLDER>','EXENAME='||bootdrive||'\OS2\INSTALL\CUSTBLD.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||bootdrive||'\OS2\INSTALL;','R'
End

Call SysCreateObject 'WPFolder','User Profile Management','<WP_DESKTOP>','OBJECTID=<UPM_FOLDER>;','R'
Call SysCreateObject 'WPProgram','Logoff','<UPM_FOLDER>','EXENAME='||upmdrive||'\MUGLIB\LOGOFF.EXE;PARAMETER=/L;STARTUPDIR='||upmdrive||'\OS2\INSTALL;','R'
Call SysCreateObject 'WPProgram','User Profile Management','<UPM_FOLDER>','EXENAME='||upmdrive||'\MUGLIB\UPMACCTS.EXE;STARTUPDIR='||upmdrive||'\OS2\INSTALL;','R'
Call SysCreateObject 'WPProgram','Logon','<UPM_FOLDER>','EXENAME='||upmdrive||'\MUGLIB\LOGON.EXE;STARTUPDIR='||upmdrive||'\OS2\INSTALL;','R'

If dbdrive <> '' Then Do
  Call SysCreateObject 'WPFolder','Database Manager','<WP_DESKTOP>','OBJECTID=<DBM_FOLDER>;','R'
  Call SysCreateObject 'WPProgram','Directory Tool','<DBM_FOLDER>','EXENAME='||dbdrive||'\SQLLIB\DIRECT.EXE;PROGTYPE=PM;STARTUPDIR='||dbdrive||'\SQLLIB;','R'
  Call SysCreateObject 'WPProgram','Database Manager Messages','<DBM_FOLDER>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS='||dbdrive||'\SQLLIB\BOOK\DBMSG.INF;STARTUPDIR='||dbdrive||'\SQLLIB;','R'
  Call SysCreateObject 'WPProgram','DBM Command Line Interface','<DBM_FOLDER>','EXENAME=CMD.EXE;PROGTYPE=WINDOWABLEVIO;PARAMETERS=/K DBM.CMD -S & STARTDBM.EXE;STARTUPDIR='||ldbdrive||'\SQLLIB;','R'
  Call SysCreateObject 'WPProgram','Query Manager','<DBM_FOLDER>','EXENAME='||dbdrive||'\SQLLIB\QUERYMGR.EXE;PROGTYPE=PM;STARTUPDIR='||dbdrive||'\SQLLIB;','R'
  Call SysCreateObject 'WPProgram','Configuration Tool','<DBM_FOLDER>','EXENAME='||dbdrive||'\SQLLIB\CONFIG.EXE;PROGTYPE=PM;STARTUPDIR='||dbdrive||'\SQLLIB;','R'
  Call SysCreateObject 'WPProgram','Recovery Tool','<DBM_FOLDER>','EXENAME='||dbdrive||'\SQLLIB\RECOVERY.EXE;PROGTYPE=PM;STARTUPDIR='||dbdrive||'\SQLLIB;','R'
End

If cmdrive <> '' Then Do
  Call SysCreateObject 'WPFolder','Communications Manager','<WP_DESKTOP>','OBJECTID=<CM_FOLDER>;','R'
  Call SysCreateObject 'WPProgram','Display SNA Configuration Log','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\APPNLOG2.EXE;PROGTYPE=PM;PARAMETERS=[Enter configuration log (.LOG) file name];STARTUPDIR='||cmdrive||'\CMLIB;','R'
  Call SysCreateObject 'WPProgram','Display Active SNA Configuration','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\PMDSPLAY.EXE;PROGTYPE=PM;STARTUPDIR='||cmdrive||'\CMLIB\APPN;','R'
  Call SysCreateObject 'WPProgram','Manage SNA Logical Links','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\APPNLINK.EXE;PROGTYPE=PM;STARTUPDIR='||cmdrive||'\CMLIB\APPN;','R'
  Call SysCreateObject 'WPProgram','Verify SNA Network Definitions','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\VERIFYNS.CMD;PROGTYPE=WINDOWABLEVIO;PARAMETERS=[Enter node definitions (.NDF) file name];STARTUPDIR='||cmdrive||'\CMLIB\APPN;','R'
  Call SysCreateObject 'WPProgram','SNA Network Definitions Configuration','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\APPNC2.EXE;PROGTYPE=PM;PARAMETERS=[Enter node definitions (.NDF) file name];STARTUPDIR='||cmdrive||'\CMLIB;','R'
  Call SysCreateObject 'WPProgram','Communications Manager','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\STARTCM.CMD;PROGTYPE=FULLSCREEN;STARTUPDIR='||cmdrive||'\CMLIB;','R'
  Call SysCreateObject 'WPProgram','Configuration File Manager','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\COPYCFG.EXE;PROGTYPE=PM;STARTUPDIR='||cmdrive||'\CMLIB;','R'
  Call SysCreateObject 'WPProgram','Start/Stop CM Trace','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\CMTRACE.EXE;PROGTYPE=WINDOWABLEVIO;PARAMETERS=[Enter trace options];STARTUPDIR='||cmdrive||'\CMLIB\APPN;','R'
  Call SysCreateObject 'WPProgram','Format SNA Trace Information','<CM_FOLDER>','EXENAME='||cmdrive||'\CMLIB\APPN\FMTTRACE.EXE;PROGTYPE=WINDOWABLEVIO;PARAMETERS=[Enter optional flags and trace (.TRC) file name];STARTUPDIR='||cmdrive||'\CMLIB\APPN;','R'
End

/********************************/
/* Notify user in case of error */
/********************************/
Telluser: Procedure
Parse source . . tell_name .
tell_name = Filespec('name',tell_name)
Parse Upper Var tell_name tell_name '.' .
ulogfile = tell_name
If Arg(2,'e') = 0 Then Do
  Say tell_name||':' Date('U') Time() Arg(1)
End
Else Do
  If Arg(2) = 0 Then Do
    Say tell_name||':' Date('U') Time() Arg(1)
  End
  Else Do
    Say Copies(' ',15+Length(tell_name)) Arg(1)
  End
End
Return 0

/*************************/
/* Handle SIGNAL ON HALT */
/*************************/
Halt:
Call Telluser 'Halt signalled in line' SIGL'.'
Call choiceb

/***************************/
/* Handle SIGNAL ON SYNTAX */
/***************************/
Syntax:
myrc = rc
errormsg ='REXX error' myrc 'in line' SIGL':' Errortext(myrc)
errormsg2 = Substr('     ',1,6-Length(SIGL))(SIGL)' *-*   'Sourceline(sigl)
Call Telluser errormsg
Call Telluser errormsg2,1
Call choiceb

/***************************************************************/
/* Procedure: option2                                          */
/*                                                             */
/* Prompts the user for continuation of creation of the        */
/* Extended Services and Lan Services.                         */
/***************************************************************/

option2:

Say "Do you want to continue (Y/N)?"
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then return
otherwise call choiceb
end  /* select */

toolkit:

/****************************************************************/
/* MKTOOLKIT.CMD                Version 1.0; September 3, 1992  */
/*                                                              */
/* Function:                                                    */
/*      Build the WPS entries for the following products:       */
/*              Toolkit                                         */
/*              C Set/2                                         */
/*              WorkFrame/2                                     */
/* Parameters:                                                  */
/*      None                                                    */
/*                                                              */
/* Programmed by:                                               */
/*      Georg Haschek (61804212 at VIEVMA)                      */
/*                                                              */
/* Change history:                                              */
/*      1.0  92/09/03 ... First release to OS2TOOLS             */
/*                                                              */
/****************************************************************/
Trace 'O'
Address CMD
'@ECHO OFF'
Signal On Halt
Signal On Syntax

/**************/
/* Initialize */
/**************/

Parse Version v
v = Translate(Word(v,5)||Right(Wordpos(Word(v,4),'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'),2)||Right(Word(v,3),2),'0',' ')
If v < 19920708 Then Do
  Say "The version of REXX on your system is backlevel."
  Say " "
  Say "Please get the latest version from OS2TOOLS (REXX20 PACKAGE), or from"
  Say "the OS2CSD disk. The success of MKTOOLKT is not guaranteed!"
  'PAUSE'
End

tooldrive = ''
csetrive = ''
workdrive = ''
bootdrive = Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\OS2\SYSTEM',Value('PATH',,'OS2ENVIRONMENT'))-2,2)
If Pos('\TOOLKT20',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then tooldrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\TOOLKT20',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If Pos('\IBMC',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then csetdrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\IBMC',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If Pos('\IBMWF',Translate(Value('PATH',,'OS2ENVIRONMENT'))) > 0 Then workdrive = Translate(Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\IBMWF',Translate(Value('PATH',,'OS2ENVIRONMENT')))-2,2))
If tooldrive = '' & csetdrive = '' & workdrive = '' Then Do
  Say "No Toolkit, WorkFrame/2, or C Set/2 found, terminating."
  Call choiceb
End

iconfile = 'GROUP.ICO'
iconparm = ''
If Stream(iconfile,'C','QUERY EXISTS') = '' Then Do
  Parse Source . . myname .
  mydir = Filespec('D',myname)||Filespec('P',myname)
  If Stream(mydir||iconfile,'C','QUERY EXISTS') = '' Then Do
    If SysSearchPath('PATH',iconfile) = '' Then Do
      If SysSearchPath('DPATH',iconfile) <> '' Then Do
        iconparm = 'ICONFILE='||SysSearchPath('DPATH',iconfile)||';'
      End
    End
    Else Do
      iconparm = 'ICONFILE='||SysSearchPath('PATH',iconfile)||';'
    End
  End
  Else Do
    iconparm = 'ICONFILE='||mydir||iconfile||';'
  End
End
Else Do
  iconparm = 'ICONFILE='||Directory()||'\'||iconfile||';'
End

'CLS'
Say "Your system is installed on the" bootdrive "drive."
Say " "
Say "The following components have been found:"
Say " "
If tooldrive <> '' Then Say "     Toolkit for OS/2 2.0 on drive" tooldrive
If csetdrive <> '' Then Say "     C Set/2 on drive" csetdrive
If workdrive <> '' Then Say "     WorkFrame/2 on drive" workdrive
Say " "
Say "This program will now create a folder for each identified product on your"
Say "desktop, which will contain the default WPS entries for the listed products."
Say " "
Say "Do you want to continue (Y/N)?"
Parse Upper Pull yesno .
If Substr(yesno,1,1) <> 'Y' Then Call choiceb

If tooldrive <> '' Then Do
  Call SysCreateObject 'WPFolder','Toolkit','<WP_DESKTOP>','OBJECTID=<TOOLKIT_FOLDER>;ICONFILE='||tooldrive||'\TOOLKT20\ICON\UTILS.ICO','R'
  Call SysCreateObject 'WPFolder','Toolkit Information','<TOOLKIT_FOLDER>','OBJECTID=<TOOLKIT_INFO>;ICONFILE='||tooldrive||'\TOOLKT20\ICON\ICONINFO.ICO','R'
  Call SysCreateObject 'WPProgram','REXX Reference','<TOOLKIT_INFO>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=REXXAPI.INF;STARTUPDIR='||tooldrive||'\TOOLKT20\BOOKS;','R'
  Call SysCreateObject 'WPProgram','IPF Reference','<TOOLKIT_INFO>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=IPFC20.INF;STARTUPDIR='||tooldrive||'\TOOLKT20\BOOKS;','R'
  Call SysCreateObject 'WPProgram','SOM Reference','<TOOLKIT_INFO>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=SOM.INF;STARTUPDIR='||tooldrive||'\TOOLKT20\BOOKS;','R'
  Call SysCreateObject 'WPProgram','Tools Reference','<TOOLKIT_INFO>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=TOOLINFO.INF;STARTUPDIR='||tooldrive||'\TOOLKT20\BOOKS;','R'
  Call SysCreateObject 'WPProgram','PM Reference','<TOOLKIT_INFO>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=PMREF;STARTUPDIR='||tooldrive||'\TOOLKT20\BOOKS;','R'
  Call SysCreateObject 'WPProgram','CP Reference','<TOOLKIT_INFO>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=PROGREF20;STARTUPDIR='||tooldrive||'\TOOLKT20\BOOKS;','R'
  Call SysCreateObject 'WPFolder','Sample Programs','<TOOLKIT_FOLDER>','OBJECTID=<TOOLKIT_SAMPLES>;ICONFILE='||tooldrive||'\TOOLKT20\ICON\OSTUTOR.ICO','R'
  samples.1 = tooldrive||'\TOOLKT20\C\SAMPLES\ANIMALS\ANIMALS.CMD WINDOWABLEVIO ;; SOM Inheritance Sample'
  samples.2 = tooldrive||'\TOOLKT20\C\SAMPLES\CLIPBRD\CLIPBRD.EXE PM ;; Clipboard Sample'
  samples.3 = tooldrive||'\TOOLKT20\C\SAMPLES\CLOCK\CLOCK.EXE PM ;; Clock Sample'
  samples.4 = tooldrive||'\TOOLKT20\C\SAMPLES\DIALOG\DIALOG.EXE PM ;; Introductory Dialog Box Sample'
  samples.5 = tooldrive||'\TOOLKT20\C\SAMPLES\DLLAPI\DLLAPI.EXE PM ;; Dynamic Link Library Sample'
  samples.6 = tooldrive||'\TOOLKT20\C\SAMPLES\DRAGDROP\DRAGDROP.EXE PM ;; Dragdrop Sample'
  samples.7 = tooldrive||'\TOOLKT20\C\SAMPLES\EAS\EAS.EXE PM ;; Edit Extended Attributes Sample'
  samples.8 = tooldrive||'\TOOLKT20\C\SAMPLES\GRAPHIC\GRAPHIC.EXE PM ;; Retained Graphics Sample'
  samples.9 = tooldrive||'\TOOLKT20\C\SAMPLES\HANOI\HANOI.EXE PM ;; Towers of Hanoi Sample'
  samples.10 = tooldrive||'\TOOLKT20\C\SAMPLES\HELLO\HELLO.EXE PM ;; Standard Window Sample'
  samples.11 = tooldrive||'\TOOLKT20\C\SAMPLES\IMAGE\IMAGE32.EXE PM ;; Image Sample'
  samples.12 = tooldrive||'\TOOLKT20\C\SAMPLES\JIGSAW\JIGSAW.EXE PM ;; Jigsaw Puzzle Sample'
  samples.13 = tooldrive||'\TOOLKT20\C\SAMPLES\NPIPE\SVRNPIPE.EXE PM ;CLINPIPE.EXE; Tic-Tac-Toe Sample'
  samples.14 = tooldrive||'\TOOLKT20\C\SAMPLES\PRINT\PRTSAMP.EXE PM ;; Print Sample'
  samples.15 = tooldrive||'\TOOLKT20\C\SAMPLES\QUEUES\SVRQUEUE.EXE PM ;CLIQUEUE.EXE; Queues Sample'
  samples.16 = tooldrive||'\TOOLKT20\C\SAMPLES\SEMAPH\SEMAPH.EXE PM ;; Semaphore Sample'
  samples.17 = tooldrive||'\TOOLKT20\C\SAMPLES\SORT\SORT.EXE PM ;; Sorting Algorithm Sample'
  samples.18 = tooldrive||'\TOOLKT20\C\SAMPLES\STYLE\STYLE.EXE PM ;; Style Sample'
  samples.19 = tooldrive||'\TOOLKT20\C\SAMPLES\TEMPLATE\TEMPLATE.EXE PM ;; Application Templace Sample'
  samples.20 = tooldrive||'\TOOLKT20\C\SAMPLES\TP\TP.CMD WINDOWABLEVIO ;; SOM Text Processing Sample'
  samples.21 = tooldrive||'\TOOLKT20\C\SAMPLES\VMM\VMM.EXE PM ;; Virtual Memory Management Sample'
  samples.22 = tooldrive||'\TOOLKT20\C\SAMPLES\WORMS\WORMS.EXE WINDOWABLEVIO ;-30; Mixed Mode Sample'
  samples.23 = tooldrive||'\TOOLKT20\REXX\SAMPLES\CALLREXX\CALLREXX.CMD WINDOWABLEVIO ;; REXX Interpreter Invocation Sample'
  samples.24 = tooldrive||'\TOOLKT20\REXX\SAMPLES\DEVINFO\DEVINFO.CMD WINDOWABLEVIO ;; REXX Variable Pool Interface Sample'
  samples.25 = tooldrive||'\TOOLKT20\REXX\SAMPLES\PMREXX\PMREXX.EXE PM ;REXXTRY.CMD; Presentation Manager REXX Interface Sample'
  samples.26 = tooldrive||'\TOOLKT20\REXX\SAMPLES\REXXUTIL\REXXUDEM.CMD WINDOWABLEVIO ;; REXX Utility Functions Sample'
  samples.27 = tooldrive||'\TOOLKT20\REXX\SAMPLES\RXMACDLL\RXMACDLL.CMD WINDOWABLEVIO ;; External Functions in REXX Macrospace Sample'
  samples.0 = 27
  Do i = 1 to samples.0
    Parse Var samples.i program type ';' parms ';' title
    program = Strip(program)
    type = Strip(title)
    parms = Strip(parms)
    title = Strip(title)
    If parms = '' Then Do
      Call SysCreateObject 'WPProgram',title,'<TOOLKIT_SAMPLES>','EXENAME='||program||';PROGTYPE='||type||';STARTUPDIR='||Filespec('D',program)||Substr(Filespec('P',program),1,Length(Filespec('P',program))-1)||';','R'
    End
    Else Do
      Call SysCreateObject 'WPProgram',title,'<TOOLKIT_SAMPLES>','EXENAME='||program||';PROGTYPE='||type||';PARAMETERS='||parms||';STARTUPDIR='||Filespec('D',program)||Substr(Filespec('P',program),1,Length(Filespec('P',program))-1)||';','R'
    End
  End
  Call SysCreateObject 'WPProgram','Information Presentation Facility Sample','<TOOLKIT_SAMPLES>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=IPF.INF;STARTUPDIR='||tooldrive||'\TOOLKT20\C\SAMPLES\IPF;','R'
  Call SysCreateObject 'WPFolder','PM Development Tools','<TOOLKIT_FOLDER>','OBJECTID=<TOOLKIT_TOOLS>;ICONFILE='||tooldrive||'\TOOLKT20\ICON\FXICON.ICO','R'
  Call SysCreateObject 'WPProgram','Dialog Editor','<TOOLKIT_TOOLS>','EXENAME='||tooldrive||'\TOOLKT20\OS2BIN\DLGEDIT.EXE;PROGTYPE=PM;STARTUPDIR='||tooldrive||'\TOOLKT20\OS2BIN;','R'
  Call SysCreateObject 'WPProgram','Font Editor','<TOOLKIT_TOOLS>','EXENAME='||tooldrive||'\TOOLKT20\OS2BIN\FONTEDIT.EXE;PROGTYPE=PM;STARTUPDIR='||tooldrive||'\TOOLKT20\OS2BIN;','R'
  Call SysCreateObject 'WPProgram','Icon Editor','<TOOLKIT_TOOLS>','EXENAME='||tooldrive||'\TOOLKT20\OS2BIN\ICONEDIT.EXE;PROGTYPE=PM;STARTUPDIR='||tooldrive||'\TOOLKT20\OS2BIN;','R'
  Call SysRegisterObjectClass 'WPKlist', tooldrive||'\TOOLKT20\DLL\WPCLSLST.DLL'
  Call SysCreateObject 'WPKlist', 'WP Class List','<TOOLKIT_TOOLS>'
End

If csetdrive <> '' Then Do
  Call SysCreateObject 'WPFolder','IBM C Set/2','<WP_DESKTOP>','OBJECTID=<CSET_FOLDER>;'||iconparm,'R'
  Call SysCreateObject 'WPProgram','IBM C Set/2 Online Help','<CSET_FOLDER>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=DDE4HELP.INF;STARTUPDIR='||csetdrive||'\IBMC\HELP;','R'
  Call SysCreateObject 'WPProgram','IBM C Set/2 Debugger','<CSET_FOLDER>','EXENAME='||csetdrive||'\IBMC\BIN\IPMD.EXE;PROGTYPE=PM;STARTUPDIR='||csetdrive||'\IBMC\BIN;','R'
End

If workdrive <> '' Then Do
  Call SysCreateObject 'WPFolder','IBM WorkFrame/2','<WP_DESKTOP>','OBJECTID=<WKFR_FOLDER>;'||iconparm,'R'
  Call SysCreateObject 'WPProgram','IBM WorkFrame/2 Online Help','<WKFR_FOLDER>','EXENAME='||bootdrive||'\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=DDE3WF.INF;STARTUPDIR='||workdrive||'\IBMWF\HELP;','R'
  Call SysCreateObject 'WPProgram','IBM WorkFrame/2','<WKFR_FOLDER>','EXENAME='||workdrive||'\IBMWF\BIN\WF.EXE;PROGTYPE=PM;STARTUPDIR='||workdrive||'\IBMWF;','R'
End

/********************************/
/* Notify user in case of error */
/********************************/
Telluser: Procedure
Parse source . . tell_name .
tell_name = Filespec('name',tell_name)
Parse Upper Var tell_name tell_name '.' .
ulogfile = tell_name
If Arg(2,'e') = 0 Then Do
  Say tell_name||':' Date('U') Time() Arg(1)
End
Else Do
  If Arg(2) = 0 Then Do
    Say tell_name||':' Date('U') Time() Arg(1)
  End
  Else Do
    Say Copies(' ',15+Length(tell_name)) Arg(1)
  End
End
Return 0

/*************************/
/* Handle SIGNAL ON HALT */
/*************************/
Halt:
Call Telluser 'Halt signalled in line' SIGL'.'
Call choiceb

/***************************/
/* Handle SIGNAL ON SYNTAX */
/***************************/
Syntax:
myrc = rc
errormsg ='REXX error' myrc 'in line' SIGL':' Errortext(myrc)
errormsg2 = Substr('     ',1,6-Length(SIGL))(SIGL)' *-*   'Sourceline(sigl)
Call Telluser errormsg
Call Telluser errormsg2,1
Call choiceb

/***************************************************************/
/* Procedure: option6                                          */
/*                                                             */
/* Prompts the user for continuation of creation of the        */
/* Toolkit.                                                    */
/***************************************************************/

option6:

Say "Do you want to continue (Y/N)?"
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then return
otherwise call choiceb
end  /* select */

os2sys:

/***************************************************************/
/* Procedure: os2sys                                           */
/*                                                             */
/* Recreates the OS/2 System Icon and all of its contents.     */
/***************************************************************/

say
say 'Creating OS/2 System Folder. . .'

/* create OS/2 System Folder */

rc = SysCreateObject('WPFolder','OS/2 System','<WP_DESKTOP>','HELPPANEL=4002;OBJECTID=<WP_OS2SYS>;ICONFILE=\OS2.ICO')
if rc = 1 then do
   say 'OS/2 System Folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'OS/2 System Folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

'pause'
call choice2

call choice

 /* Creating Command Prompts */

cmdprmts:

say
say 'Creating Command Prompts. . .'

rc=SysCreateObject('WPFolder','Command Prompts','<WP_OS2SYS>','HELPPANEL=8008;OBJECTID=<WP_PROMPTS>')
rc=SysCreateObject('WPProgram','OS/2 Full Screen','<WP_PROMPTS>','EXENAME=*;PROGTYPE=FULLSCREEN;HELPPANEL=8009;OBJECTID=<WP_OS2FS>')
rc=SysCreateObject('WPProgram','OS/2 Window','<WP_PROMPTS>','EXENAME=*;PROGTYPE=WINDOWABLEVIO;HELPPANEL=8010;OBJECTID=<WP_OS2WIN>')
rc=SysCreateObject('WPProgram','DOS Full Screen','<WP_PROMPTS>','EXENAME=*;PROGTYPE=VDM;HELPPANEL=8011;OBJECTID=<WP_DOSFS>')
rc=SysCreateObject('WPProgram','DOS Window','<WP_PROMPTS>','EXENAME=*;PROGTYPE=WINDOWEDVDM;HELPPANEL=8012;OBJECTID=<WP_DOSWIN>')
rc=SysCreateObject('WPProgram','WIN-OS/2 Full Screen','<WP_PROMPTS>','EXENAME=WINOS2.COM;PROGTYPE=VDM;SET KBD_ALTHOME_BYPASS=1;SET KBD_CTRL_BYPASS=CTRL_ESC;SET VIDEO_SWITCH_NOTIFICATION=0;SET VIDEO_8514A_XGA_IOTRAP=1;HELPPANEL=8022;OBJECTID=<WP_WINFS>')
rc=SysCreateObject('WPProgram','DOS from Drive A:','<WP_PROMPTS>','EXENAME=*;PROGTYPE=VDM;SET DOS_STARTUP_DRIVE=A:;HELPPANEL=8529;OBJECTID=<WP_DOS_DRV_A>')

say 'Is your system setup for the Dual Boot feature?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (continue <> yes) then call choice2
   when (yesno = "N") & (continue = yes) then call drives
   otherwise nop
end  /* select */
rc=SysCreateObject('WPProgram','Dual Boot','<WP_PROMPTS>','EXENAME=BOOT.COM;PROGTYPE=WINDOWABLEVIO;PARAMETERS=/DOS;HELPPANEL=8029;OBJECTID=<WP_DBOOT>')

say 'Command Prompts was successfully installed.'
if continue <> yes then
   do
      'pause'
      call choice2
   end  /* do */
else nop

/* Creating Drives Icon */

drives:

say
say 'THE DRIVES FOLDER YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.'  
say 'ARE YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (continue <> yes) then call choice2
   when (yesno = "N") & (continue = yes) then call startup
otherwise nop
end  /* select */

say
say 'Creating Drives Icon. . .'

rc=SysCreateObject('WPDrives','Drives','<WP_OS2SYS>','OBJECTID=<WP_DRIVES>')

if rc = 1 then do
   say 'Drives Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Drives Icon.  This folder was not' 
   say 'created successfully.'
   call reason
   say
end /* do */

if continue <> yes then
   do
      'pause'
      call choice2
   end  /* do */
else nop

 /* create Startup Folder */

startup:

say
say 'Creating Startup Folder. . .'

rc=SysCreateObject('WPStartup','Startup','<WP_OS2SYS>','HELPPANEL=8002;OBJECTID=<WP_START>;ICONFILE=\STARTUP.ICO')

if rc = 1 then do
   say 'Startup Folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Startup Folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if continue <> yes then
   do
      'pause'
      call choice2
   end  /* do */
else nop

/* Games Folder */

games:

say
say 'Creating Games Folder. . .'

rc=SysCreateObject('WPFolder','Games','<WP_OS2SYS>','HELPPANEL=13091;OBJECTID=<WP_GAMES>;ICONFILE=')
rc=SysCreateObject('WPProgram','Solitaire - Klondike','<WP_GAMES>','EXENAME=KLONDIKE.EXE;PROGTYPE=PM;HELPPANEL=20295;OBJECTID=<WP_KLDK>')
rc=SysCreateObject('WPProgram','Reversi','<WP_GAMES>','EXENAME=REVERSI.EXE;PROGTYPE=PM;HELPPANEL=20297;OBJECTID=<WP_RVRSI>')
rc=SysCreateObject('WPProgram','Scramble','<WP_GAMES>','EXENAME=SCRAMBLE.EXE;PROGTYPE=PM;HELPPANEL=20298;OBJECTID=<WP_SCRBL>')
rc=SysCreateObject('WPProgram','Cat and Mouse','<WP_GAMES>','EXENAME=NEKO.EXE;PROGTYPE=PM;HELPPANEL=20293;OBJECTID=<WP_NEKO>')
rc=SysCreateObject('WPProgram','Jigsaw','<WP_GAMES>','EXENAME=JIGSAW.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\BITMAP;HELPPANEL=20294;OBJECTID=<WP_JIGSAW>')
rc=SysCreateObject('WPProgram','OS/2 Chess','<WP_GAMES>','EXENAME=OS2CHESS.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20296;OBJECTID=<WP_CHESS>')

say 'Games Folder was successfully installed.'

if continue <> yes then
   do
      'pause'
      call choice2
   end  /* do */
else nop

productivity:

say
say 'Creating Productivity Folder. . .'

 /* Productivity Folder */

rc=SysCreateObject('WPFolder','Productivity','<WP_OS2SYS>','HELPPANEL=13090;OBJECTID=<WP_TOOLS>;ICONFILE=')
rc=SysCreateObject('WPProgram','Enhanced Editor','<WP_TOOLS>','EXENAME=EPM.EXE;PROGTYPE=PM;HELPPANEL=20278;OBJECTID=<WP_EPM>')
rc=SysCreateObject('WPProgram','Seek and Scan Files','<WP_TOOLS>','EXENAME=PMSEEK.EXE;PROGTYPE=PM;HELPPANEL=20285;OBJECTID=<WP_SEEK>')
rc=SysCreateObject('WPProgram','Icon Editor','<WP_TOOLS>','EXENAME=ICONEDIT.EXE;PROGTYPE=PM;ASSOCFILTER=*.BMP,*.PTR,*.ICO;HELPPANEL=20279;OBJECTID=<WP_ICON>')
rc=SysCreateObject('WPProgram','PM Terminal','<WP_TOOLS>','EXENAME=SOFTERM.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20286;OBJECTID=<WP_TERM>')
rc=SysCreateObject('WPProgram','Pulse','<WP_TOOLS>','EXENAME=PULSE.EXE;PROGTYPE=PM;HELPPANEL=20284;OBJECTID=<WP_PULSE>')
rc=SysCreateObject('WPProgram','PM Chart','<WP_TOOLS>','EXENAME=PMCHART.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20283;OBJECTID=<WP_CHART>')
rc=SysCreateObject('WPProgram','Calculator','<WP_TOOLS>','EXENAME=PMDCALC.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20272;OBJECTID=<WP_DCALC>')
rc=SysCreateObject('WPProgram','Notepad','<WP_TOOLS>','EXENAME=PMDNOTE.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20281;OBJECTID=<WP_DNOTE>')
rc=SysCreateObject('WPProgram','Alarms','<WP_TOOLS>','EXENAME=PMDALARM.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20270;OBJECTID=<WP_DALARM>')
rc=SysCreateObject('WPProgram','Calendar','<WP_TOOLS>','EXENAME=PMDCALEN.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20273;OBJECTID=<WP_DCALEM>')
rc=SysCreateObject('WPProgram','Planner Archive','<WP_TOOLS>','EXENAME=PMDDARC.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20282;OBJECTID=<WP_DDARC>')
rc=SysCreateObject('WPProgram','Daily Planner','<WP_TOOLS>','EXENAME=PMDDIARY.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20275;OBJECTID=<WP_DDIARY>')
rc=SysCreateObject('WPProgram','Activities List','<WP_TOOLS>','EXENAME=PMDLIST.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20271;OBJECTID=<WP_DLIST>')
rc=SysCreateObject('WPProgram','Monthly Planner','<WP_TOOLS>','EXENAME=PMDMONTH.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20280;OBJECTID=<WP_DMNTH>')
rc=SysCreateObject('WPProgram','To-Do List Archive','<WP_TOOLS>','EXENAME=PMDTARC.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20290;OBJECTID=<WP_DTARC>')
rc=SysCreateObject('WPProgram','To-Do List','<WP_TOOLS>','EXENAME=PMDTODO.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20289;OBJECTID=<WP_TODO>')
rc=SysCreateObject('WPProgram','Tune Editor','<WP_TOOLS>','EXENAME=PMDTUNE.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20291;OBJECTID=<WP_TUNE>')
rc=SysCreateObject('WPProgram','Spreadsheet','<WP_TOOLS>','EXENAME=PMSPREAD.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20287;OBJECTID=<WP_SPREAD>')
rc=SysCreateObject('WPProgram','Sticky Pad','<WP_TOOLS>','EXENAME=PMSTICKY.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20288;OBJECTID=<WP_STICKY>')
rc=SysCreateObject('WPProgram','Database','<WP_TOOLS>','EXENAME=PMMBASE.EXE;PROGTYPE=PM;STARTUPDIR=\OS2\APPS;HELPPANEL=20276;OBJECTID=<WP_DBASE>')
rc=SysCreateObject('WPProgram','Clipboard Viewer','<WP_TOOLS>','EXENAME=CLIPOS2.EXE;PROGTYPE=PM;HELPPANEL=20274;OBJECTID=<WP_CLIPV>')
rc=SysCreateObject('WPProgram','Picture Viewer','<WP_TOOLS>','EXENAME=PICVIEW.EXE;PROGTYPE=PM;ASSOCTYPE=Metafile,PIF file,,;ASSOCFILTER=*.MET,*.PIF,,;OBJECTID=<WP_PICV>')
rc=SysCreateObject('WPProgram','OS/2 System Editor','<WP_TOOLS>','EXENAME=E.EXE;HELPPANEL=9289;PROGTYPE=PM;ASSOCTYPE=Plain Text,OS/2 Command File,DOS Command File,,;ASSOCFILTER=*.DOC,*.TXT,,;OBJECTID=<WP_SYSED>')

say 'Productivity Folder was successfully installed.'

if continue <> yes then
   do
      'pause'
      call choice2
   end  /* do */
else nop

 /* System Setup */

system:

say
say 'Creating System Setup Icon. . .'

rc=SysCreateObject('WPFolder','System Setup','<WP_OS2SYS>','HELPPANEL=1220;ICONRESOURCE=59 PMWP;OBJECTID=<WP_CONFIG>')

if rc = 1 then do
   say 'System Setup Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'System Setup Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

continue = no           /* continue is reinitialized to no, for */
                                 /* any reinstallation of the icons */
'pause'
call choice4

all:

say
say 'You have asked to recreate the entire OS/2 System Folder.'
call option3
say
say 'Please wait while the OS/2 System Folder is created. . .'

continue=yes                  /* continue is initialized to yes to */
                                       /* continued installation of all features */
call cmdprmts

 /* System Clock */

sysclock:

say
say 'THE SYSTEM CLOCK ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4
   when (yesno = "N") & (cont3 = yes) then call sinstal
otherwise nop
end  /* select */

say
say 'Creating System Clock Icon. . .'

rc=SysCreateObject('WPClock','System Clock','<WP_CONFIG>','OBJECTID=<WP_CLOCK>;ICONFILE=CLOCK.ICO')

if rc = 1 then do
   say 'System Clock Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'System Clock Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then 
   do
      pause
      call choice4
   end
else nop

 /* Selective Install */

sinstal:

say
say 'Creating Selective Install Icon. . .'

rc=SysCreateObject('WPProgram','Selective Install','<WP_CONFIG>','EXENAME=\OS2\INSTALL\INSTALL.EXE;PROGTYPE=PM;HELPPANEL=12220;OBJECTID=<WP_INST>')

if rc = 1 then do
   say 'Selective Install Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Selective Install Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Device Driver Install */

ddrvr:

say
say 'Creating Device Driver Install Icon. . .'

rc=SysCreateObject('WPProgram','Device Driver Install','<WP_CONFIG>','EXENAME=\OS2\INSTALL\DDINSTAL.EXE;PROGTYPE=PM;HELPPANEL=12221;OBJECTID=<WP_DDINST>')

if rc = 1 then do
   say 'Device Driver Install Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Device Driver Install Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Migrate Applications */

migrate:

say
say 'Creating Migrate Applications Icon. . .'

rc=SysCreateObject('WPProgram','Migrate Applications','<WP_CONFIG>','EXENAME=\OS2\INSTALL\MIGRATE.EXE;PROGTYPE=PM;HELPPANEL=4508;OBJECTID=<WP_MIGAPP>')

if rc = 1 then do
   say 'Migrate Applications Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Migrate Applications Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Create Scheme Palette */

scheme:

say
say 'Creating Scheme Palette. . .'

rc=SysCreateObject('WPSchemePalette','Scheme Palette','<WP_CONFIG>','AUTOSETUP=YES;OBJECTID=<WP_SCHPAL>;ICONFILE=\SCHEME.ICO')

if rc = 1 then do
   say 'Scheme Palette was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Scheme Palette.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4
   end
else nop
 
 /* Create Color Palette */

color:

say
say 'Creating Color Palette. . .'

rc=SysCreateObject('WPColorPalette','Color Palette','<WP_CONFIG>','OBJECTID=<WP_CLRPAL>;ICONFILE=\COLOR.ICO')

if rc = 1 then do
   say 'Color Palette was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Color Palette.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4
   end
else nop

 /* Creating Font Palette */

font:

say
say 'Creating Font Palette. . .'

rc=SysCreateObject('WPFontPalette','Font Palette','<WP_CONFIG>','OBJECTID=<WP_FNTPAL>;ICONFILE=\FONT.ICO')

if rc = 1 then do
   say 'Font Palette was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Font Palette.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4
   end
else nop

 /* Create Keyboard Icon */

keybd:

say
say 'THE KEYBOARD ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4b
   when (yesno = "N") & (cont3 = yes) then call mouse
otherwise nop
end  /* select */

say
say 'Creating Keyboard Icon. . .'

rc=SysCreateObject('WPKeyboard','Keyboard','<WP_CONFIG>','OBJECTID=<WP_KEYB>;ICONFILE=\KEYBD.ICO')

if rc = 1 then do
   say 'Keyboard Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Keyboard Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Create Mouse Icon */

mouse:

say
say 'THE MOUSE ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4b
   when (yesno = "N") & (cont3 = yes) then call touch
otherwise nop
end  /* select */

say
say 'Creating Mouse Icon. . .'

rc=SysCreateObject('WPMouse','Mouse','<WP_CONFIG>','OBJECTID=<WP_MOUSE>;ICONFILE=\MOUSE.ICO')

if rc = 1 then do
   say 'Mouse Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Mouse Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Create Touch Icon */

touch:

say
say 'Do you have a touch display?'
yesno = SysGetKey()
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4b
   when (yesno = "N") & (cont3 = yes) then call sound
otherwise nop
end  /* select */

say 'THE TOUCH DISPLAY ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4b
   when (yesno = "N") & (cont3 = yes) then call sound
otherwise nop
end  /* select */

say
say 'Creating Touch Display Icon. . .'

rc=SysCreateObject('WPTouch','Touch','<WP_CONFIG>','OBJECTID=<WP_TOUCH>;ICONFILE=\TOUCH.ICO')

if rc = 1 then do
   say 'Touch Display Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Touch Display Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Create Sound Icon */

sound:

say
say 'THE SOUND ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4b
   when (yesno = "N") & (cont3 = yes) then call sys
otherwise nop
end  /* select */

say
say 'Creating Sound Icon. . .'

rc=SysCreateObject('WPSound','Sound','<WP_CONFIG>','OBJECTID=<WP_SOUND>;ICONFILE=\SOUND.ICO')

if rc = 1 then do
   say 'Sound Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Sound Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4b
   end
else nop

 /* Create System Icon */

sys:

say
say 'THE SYSTEM ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4
   when (yesno = "N") & (cont3 = yes) then call country
otherwise nop
end  /* select */

say
say 'Creating System Icon. . .'

rc=SysCreateObject('WPSystem','System','<WP_CONFIG>','HELPPANEL=9259;OBJECTID=<WP_SYSTEM>;ICONFILE=\SYSTEM.ICO')

if rc = 1 then do
   say 'System Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'System Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4
   end
else nop

 /* Create Country Icon */

country:

say
say 'THE COUNTRY ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when (yesno = "N") & (cont3 <> yes) then call choice4
   when (yesno = "N") & (cont3 = yes) then call spooler
otherwise nop
end  /* select */

say
say 'Creating Country Icon. . .'

rc=SysCreateObject('WPCountry','Country','<WP_CONFIG>','OBJECTID=<WP_CNTRY>;ICONFILE=\COUNTRY.ICO')

if rc = 1 then do
   say 'Country Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Country Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont3 <> yes then
   do
      pause
      call choice4
   end
else nop

 /* Create Spooler Icon */

spooler:

say
say 'THE SPOOLER ICON YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.  ARE'
say 'YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "N" then call choice4
otherwise nop
end  /* select */

say
say 'Creating Spooler Icon. . .'

rc=SysCreateObject('WPSpool','Spooler','<WP_CONFIG>','OBJECTID=<WP_SPOOL>;ICONFILE=\SPOOL.ICO')

if rc = 1 then do
   say 'Spooler Icon was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Spooler Icon.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

cont3 = no                      /* continue 2 is reinitialized to no, for */
                                       /* any reinstallation of the icons */
'pause'
call choice4

all3:

say
say 'You have asked to recreate the entire System Setup Folder.'
call option5
say
say 'Please wait while entire System Setup Folder is created. . .'

cont3 = yes                     /* continue 3 is initialized to yes to */
                                       /* continued installation of all features */

call sysclock

templates:

/***************************************************************/
/* Procedure: templates                                        */
/*                                                             */
/* Recreates the Templates Icon and all of its contents.       */
/***************************************************************/

say
say 'THE TEMPLATES FOLDER YOU ARE ABOUT TO INSTALL'
say 'CANNOT BE REMOVED FROM THE HARD DRIVE ONCE IT IS'
say 'INSTALLED.  ARE YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "N" then call choice
otherwise nop
end  /* select */

say
say 'Creating Templates Folder. . .'

/* create Templates Folder */

rc=SysCreateObject('WPTemplates','Templates','<WP_DESKTOP>','HELPPANEL=15680;OBJECTID=<WP_TEMPS>')

if rc = 1 then do
   say 'Templates Folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Templates Folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

'pause'
call choice

minwin:

/***************************************************************/
/* Procedure: minintro                                         */
/*                                                             */
/* Recreates the Minimized Window Icon Viewer and all of its contents.     */
/***************************************************************/

say
say 'THE MINIMIZED WINDOW VIEWER YOU ARE ABOUT TO'
say 'INSTALL CANNOT BE REMOVED FROM THE HARD DRIVE'
say 'ONCE IT IS INSTALLED.  ARE YOU SURE YOU WANT TO'
say 'CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "N" then call choice
otherwise nop
end  /* select */

say
say 'Create Minimized Window Icon Viewer. . .'

/* create Minimized Window Icon Viewer */

rc = SysCreateObject('WPMinWinViewer','Minimized^Window Viewer','<WP_DESKTOP>','ICONPOS=5 31;OBJECTID=<WP_VIEWER>')

if rc = 1 then do
   say 'Minimized Window Icon Viewer was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Minimized Window Icon Viewer.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

'pause'
call choice

information:

/***************************************************************/
/* Procedure: information                                      */
/*                                                             */
/* Recreates the Information Icon and all of its contents.     */
/***************************************************************/

say
say 'Creating Information Folder. . .'

/* create Information Folder */

rc = SysCreateObject('WPFolder','Information','<WP_DESKTOP>','HELPPANEL=13092;OBJECTID=<INFO>;ICONFILE=\INFO.ICO')
if rc = 1 then do
   say 'Information Folder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Information Folder.  This folder was not'
   say 'created successfully.'
   call reason
   say
end /* do */

'pause'
call choice3

readme:

/* create ReadMe File */

rc=SysCreateObject('WPShadow','ReadMe','<INFO>','SHADOWID=?:\readme')

if rc = 1 then do
   say 'Readme file was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Readme file.  This file was not created'
   say 'successfully.'
   call reason
   say
end /* do */

if cont2 <> yes then 
   do
      'pause'
      call choice3
   end
else nop

rexx:

/* create REXX Information */

rc = SysCreateObject('WPProgram','REXX Information','<INFO>','EXENAME=\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=REXX.INF;HELPPANEL=9301;ICONFILE=\REXX.ICO')

if rc = 1 then do
   say 'REXX Information was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'REXX Information.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont2 <> yes then
   do
      'pause'
      call choice3
   end
else nop

cmdref:

/* create Command Reference */

rc = SysCreateObject('WPProgram','Command Reference','<INFO>','EXENAME=\OS2\VIEW.EXE;PROGTYPE=PM;PARAMETERS=CMDREF.INF;ASSOCFILTER=*.INF;HELPPANEL=9301')

if rc = 1 then do
   say 'Command Reference was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Command Reference.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont2 <> yes then
   do
      'pause'
      call choice3
   end
else nop

tutorial:

/* create Tutorial */

rc = SysCreateObject('WPProgram','Tutorial','<INFO>','EXENAME=\OS2\TUTORIAL.EXE;PROGTYPE=PM;PARAMETERS=;STARTUPDIR=\OS2\HELP;HELPPANEL=13093;ICONFILE=\TUTOR.ICO')

if rc = 1 then do
   say 'Tutorial was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Tutorial.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont2 <> yes then
   do
      'pause'
      call choice3
   end
else nop

 /* creating Glossary */

glossary:

say
say 'THE GLOSSARY YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.'
say 'ARE YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "N" then call choice3
otherwise nop
end  /* select */

rc=SysCreateObject('Mindex','Glossary','<INFO>','INDEX=GLOSSARY;ICONFILE=\GLOSS.ICO')

if rc = 1 then do
   say 'Glossary was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Glossary.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

if cont2 <> yes then
   do
      'pause'
      call choice3
   end
else nop

starthere:

/* create Start Here */

rc = SysCreateObject('WPProgram','Start Here','<INFO>','EXENAME=\OS2\STHR.EXE;PROGTYPE=PM;PARAMETERS=;STARTUPDIR=\OS2\HELP;HELPPANEL=9278;ICONFILE=\START.ICO')

if rc = 1 then do
   say 'Start Here was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Start Here.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

cont2 = no              /* continue 2 is reinitialized to no, for */
                               /* any reinstallation of the icons */
'pause'
call choice3

all2:

say
say 'You have asked to recreate the entire information folder.'
call option4
say
say 'Please wait while the entire Information Folder is created. . .'

cont2 = yes                     /* continue 2 is initialized to yes to */
                                       /* continued installation of all features */
call readme

shred:

/***************************************************************/
/* Procedure: Shred                                           */
/*                                                             */
/* Recreates the Shredder Icon and all of its contents.     */
/***************************************************************/

say
say 'THE SHREDDER YOU ARE ABOUT TO INSTALL CANNOT BE'
say 'REMOVED FROM THE HARD DRIVE ONCE IT IS INSTALLED.'
say 'ARE YOU SURE YOU WANT TO CONTINUE (Y/N)?'
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "N" then call choice
otherwise nop
end  /* select */

say
say 'Creating Shredder. . .'

/* create Shredder */

rc=SysCreateObject('WPShredder','Shredder','<WP_DESKTOP>','ICONPOS=90 8;OBJECTID=<WP_SHRED>')

if rc = 1 then do
   say 'Shredder was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Shredder.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

'pause'
call choice

master:

/***************************************************************/
/* Procedure: masterintro                                      */
/*                                                             */
/* Recreates the Master Help Index and all of its contents.    */
/***************************************************************/

say
say 'Creating Master Help Index. . .'

rc=SysCreateObject('Mindex','Master Help Index','<WP_DESKTOP>','ICONPOS=5 44;OBJECTID=<WP_MINDEX>')

if rc = 1 then do
   say 'Master Help Index was successfully installed.'
end /* do */

else do
   say
   say 'A problem occured during the installation of the'
   say 'Master Help Index.  This icon was not'
   say 'created successfully.'
   call reason
   say
end /* do */

'pause'
call choice

/***************************************************************/
/* Procedure: option3                                          */
/*                                                             */
/* Prompts the user for continuation of creation of the        */
/* OS/2 System Folder.                                         */
/***************************************************************/

option3:

Say "Do you want to continue (Y/N)?"
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then return
otherwise call choice2
end  /* select */

/***************************************************************/
/* Procedure: option4                                          */
/*                                                             */
/* Prompts the user for continuation of creation of the        */
/* Information.                                                */
/***************************************************************/

option4:

Say "Do you want to continue (Y/N)?"
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then return
otherwise call choice3
end  /* select */

/***************************************************************/
/* Procedure: option5                                          */
/*                                                             */
/* Prompts the user for continuation of creation of the        */
/* System Setup.                                               */
/***************************************************************/

option5:

Say "Do you want to continue (Y/N)?"
yesno = SysGetKey()
yesno = translate(yesno)
say
select
   when yesno = "Y" then return
otherwise call choice4
end  /* select */


/***************************************************************/
/* Procedure: reason                                           */
/*                                                             */
/* This procedure gives the user some knowledge as to why the  */
/* icon did not successfully install.                          */
/***************************************************************/

reason:
   say 'The icon may not have installed because:'
   say '   1.  This Feature has already been created.'
   say '   2.  This is not a feature that was preloaded on your system.'
   say '   3.  The executable file was not located on your system.  It'
   say '       may have been deleted.'
return

/***************************************************************/
/* Procedure: choice                                           */
/*                                                             */
/* Determine which features the user wishes to restore.        */
/***************************************************************/

choice:

call syscls

say
say 'Please choose from among the characters in brackets to restore'
say 'the features of your choice to the desktop <* Letter Only, No Enter Key'
say 'necessary anywhere in the program *> :'
say
say '[W]elcome Folder'
say
say '[O]S/2 System Icon'
say
say '[T]emplates Folder'
say
say '[M]inimized Window Icon'
say
say '[I]nformation Folder'
say
say '[S]hredder'
say
say 'M[A]ster Help Index'
say
say 'Page [D]own for more options'
say
say '[Q]uit'
say
say
say 'Enter your choice: '

do forever
   key = sysgetkey('echo')
   key = translate(key)
   say
   select
      when key = 'W' then call welcintro
      when key = 'O' then call os2sysintro
      when key = 'T' then call templates
      when key = 'M' then call minwin
      when key = 'I' then call infointro
      when key = 'S' then call shred
      when key = 'A' then call master
      when key = 'D' then call choiceb
      when key = 'Q' then call quit
   otherwise do
      say 'Invalid input. Enter your choice to restore: '
      iterate
   end /* do */
   end  /* select */
end /* do */
call choice

/***************************************************************/
/* Procedure: choiceb                                          */
/*                                                             */
/* Determine which features the user wishes to restore.        */
/***************************************************************/

choiceb:

call syscls

say
say 'Please choose from among the characters in brackets to restore'
say 'the features of your choice to the desktop <* Letter Only, No Enter Key'
say 'necessary anywhere in the program *> :'
say
say '[E]xtended Services Icon and Lan Services Icon'
say
say '[T]oolkit'
say
say 'Page [B]ack to previous page'
say
say '[Q]uit'
say
say 'Enter your choice: '

do forever
   key = sysgetkey('echo')
   key = translate(key)
   say
   select
      when key = 'E' then call eslsintro
      when key = 'T' then call toolintro
      when key = 'B' then call choice
      when key = 'Q' then call quit
   otherwise do
      say 'Invalid input. Enter your choice to restore: '
      iterate
   end /* do */
   end  /* select */
end /* do */
call choiceb

/***************************************************************/
/* Procedure: choice2                                          */
/*                                                             */
/* Determine which features the user wishes to restore.        */
/***************************************************************/

choice2:

call syscls

say
say 'Please choose from among the characters in brackets to restore'
say 'the features of your choice to the desktop <* Letter Only, No Enter Key'
say 'necessary anywhere in the program *>     >> OS/2 System <<:'
say
say '[C]ommand Prompts'
say
say '[D]rives'
say
say '[G]ames'
say
say '[P]roductivity'
say
say '[S]tartup'
say
say 'S[Y]stem Setup'
say
say '[A]ll'
say
say '[Q]uit to Main Menu'
say
say
say 'Enter your choice: '

do forever
   key = sysgetkey('echo')
   key = translate(key)
   say
   select
      when key = 'C' then call cmdprmts
      when key = 'D' then call drives
      when key = 'G' then call games
      when key = 'P' then call productivity
      when key = 'S' then call startup
      when key = 'Y' then call system
      when key = 'A' then call all
      when key = 'Q' then call choice
   otherwise do
      say 'Invalid input. Enter your choice to restore: '
      iterate
   end /* do */
   end  /* select */
end /* do */
call choice2

/***************************************************************/
/* Procedure: choice3                                          */
/*                                                             */
/* Determine which features the user wishes to restore.        */
/***************************************************************/

choice3:

call syscls

say
say 'Please choose from among the characters in brackets to restore'
say 'the features of your choice to the desktop <* Letter Only, No Enter Key'
say 'necessary anywhere in the program *>     >> Information <<:'
say
say '[R]eadme'
say
say 'Rexx [I]nformation'
say
say '[C]ommand Reference'
say
say '[T]utorial'
say
say '[G]lossary'
say
say '[S]tart Here'
say
say '[A]ll'
say
say '[Q]uit to Main Menu'
say
say
say 'Enter your choice: '

do forever
   key = sysgetkey('echo')
   key = translate(key)
   say
   select
      when key = 'R' then call readme
      when key = 'I' then call rexx
      when key = 'C' then call cmdref
      when key = 'T' then call tutorial
      when key = 'G' then call glossary
      when key = 'S' then call starthere
      when key = 'A' then call all2
      when key = 'Q' then call choice
   otherwise do
      say 'Invalid input. Enter your choice to restore: '
      iterate
   end /* do */
   end  /* select */
end /* do */
call choice3

/***************************************************************/
/* Procedure: choice4                                          */
/*                                                             */
/* Determine which features the user wishes to restore.        */
/***************************************************************/

choice4:

call syscls

say
say 'Please choose from among the characters in brackets to restore'
say 'the features of your choice to the desktop <* Letter Only, No Enter Key'
say 'necessary anywhere in the program *>     >> System Setup <<:'
say
say '[S]ystem Clock'
say
say 'S[P]ooler'
say
say 'Sc[H]eme Palette'
say
say '[C]olor Palette'
say
say '[F]ont Palette'
say
say 'C[O]untry'
say
say 'S[Y]stem'
say
say 'Page [D]own for more options'
say
say '[Q]uit to OS/2 System'
say
say
say 'Enter your choice: '

do forever
   key = sysgetkey('echo')
   key = translate(key)
   say
   select
      when key = 'S' then call sysclock
      when key = 'P' then call spooler
      when key = 'H' then call scheme
      when key = 'C' then call color
      when key = 'F' then call font
      when key = 'O' then call country
      when key = 'Y' then call sys
      when key = 'D' then call choice4b
      when key = 'Q' then call choice2
   otherwise do
      say 'Invalid input. Enter your choice to restore: '
      iterate
   end /* do */
   end  /* select */
end /* do */
call choice4

/***************************************************************/
/* Procedure: choice4b                                         */
/*                                                             */
/* Determine which features the user wishes to restore.        */
/***************************************************************/

choice4b:

call syscls

say
say 'Please choose from among the characters in brackets to restore'
say 'the features of your choice to the desktop <* Letter Only, No Enter Key'
say 'necessary anywhere in the program *>  >> System Setup <<:'
say
say '[S]ound'
say
say '[M]igrate Applications'
say
say '[D]evice Driver Install'
say
say 'M[O]use'
say
say 'S[E]lective Install'
say
say '[K]eyboard'
say
say '[T]ouch display'
say
say 'Page [B]ack to previous page'
say
say '[A]ll'
say
say '[Q]uit to OS/2 System'
say
say
say 'Enter your choice: '

do forever
   key = sysgetkey('echo')
   key = translate(key)
   say
   select
      when key = 'S' then call sound
      when key = 'M' then call migrate
      when key = 'D' then call ddrvr
      when key = 'O' then call mouse
      when key = 'E' then call sinstal
      when key = 'K' then call keybd
      when key = 'T' then call touch
      when key = 'B' then call choice4
      when key = 'A' then call all3
      when key = 'Q' then call choice2
   otherwise do
      say 'Invalid input. Enter your choice to restore: '
      iterate
   end /* do */
   end  /* select */
end /* do */
call choice4b

/***************************************************************/
/* Procedure: quit                                             */
/*                                                             */
/* This procedure terminates the program at the appropriate    */
/* time.  Determined by user or program completion             */
/***************************************************************/

quit:

'cd\'
'del drives.ico'
'del shred.ico'
'del startup.ico'
'del disk.ico'
'del template.ico'
'del info.ico'
'del sysset.ico'
'del ult.ico'
'del minwin.ico'
'del tutor.ico'
'del os2.ico'
say
say 'Program terminated.'
say
say 'Thank you for using Ultimate.'
say
say 'Any fixes or updates to this utility will be available on'
say 'the IBM Bulletin Board System.'
say
say 'Creator: Shawn McAlhany'
say
'pause'

exit

/* Intro */

intro:

call syscls

say
say
say
say
say
say
say
say
say '                           ULTIMATE'
say '                          12/09/1992'
say 
say '                  Created by Shawn McAlhany'
say
say 'This is a REXX Utility that allows users to recreate any icons'
say 'or folders on the desktop that may have been lost or removed'
say 'and were on the system with the original OS/2.'
say
say 'The purpose of this utility is to allow the user to recreate'
say 'the necessary icons or folders without having to recreate the'
say 'desktop.  Customized icons may still reside on the desktop'
say 'while the lost icons are recreated unlike makeini or ALT-F1.'
say 'The F1 key on icons is implemented, so the help features of'
say 'OS/2 are also available.'
say
say 'Any Questions, Comments, or Problems can be reported to me on'
say 'the IBM Electronic BBS at 404-835-6600.  This is also where any'
say 'updates will be made available.'
say
'pause'
return

